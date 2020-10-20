(* This is free and unencumbered software released into the public domain. *)

let unreachable () = failwith "unreachable"

let rec compile_contract program =
  let is_var = function
    | Clarity.Constant _ | DataVar _ | Map _ -> true
    | _ -> false
  in
  let (vars, program) = List.partition is_var program in
  let dispatcher = compile_dispatcher program in
  let program = compile_program program in
  let payload = link_program (dispatcher @ program) in
  let deployer = compile_deployer vars payload in
  (deployer, payload)

and compile_deployer vars payload =
  let inits = List.concat (List.mapi compile_var vars) in
  let loader_length = 11 in  (* keep in sync with bytecode below *)
  let loader = [
    EVM.from_int (EVM.program_size payload);
    EVM.DUP 1;
    EVM.from_int (loader_length + (EVM.opcodes_size inits));
    EVM.from_int 0;
    EVM.CODECOPY;
    EVM.from_int 0;     (* offset = memory address 0 *)
    EVM.RETURN;         (* RETURN offset, length *)
  ] in
  [(0, inits @ loader)]

and compile_var index = function
  | Clarity.Constant _ ->
    failwith "define-constant not implemented yet"  (* TODO *)
  | DataVar (_name, _type', value) ->
    compile_expression value @ [EVM.from_int index; EVM.SSTORE]
  | Map _ ->
    failwith "define-map not implemented yet"  (* TODO *)
  | _ -> unreachable ()

and compile_dispatcher program =
  let prelude = [
    EVM.from_int 0xE0;  (* b = 224 *)
    EVM.from_int 0x02;  (* a = 2 *)
    EVM.EXP;            (* EXP a, b (2^224) *)
    EVM.from_int 0;     (* i = 0 *)
    EVM.CALLDATALOAD;   (* CALLDATALOAD i *)
    EVM.DIV;            (* DIV a, b *)
  ] in
  let tests = List.concat (List.mapi compile_dispatcher_test program) in
  let postlude = [EVM.STOP] in
  [(0, prelude @ tests @ postlude)]

and compile_dispatcher_test index = function
  | Clarity.Constant _ | DataVar _ | Map _ -> unreachable ()
  | PrivateFunction _ -> []
  | PublicFunction (name, _, _)
  | PublicReadOnlyFunction (name, _, _) ->
    let hash = function_hash name in
    let dest = 1 + index in
    [
      EVM.DUP 1;        (* b = top of stack *)
      EVM.PUSH (4, hash);  (* a = keccak256(function_sig)[:4] *)
      EVM.EQ;           (* cond = EQ a, b *)
      EVM.from_int dest;   (* dest = the function prelude *)
      EVM.JUMPI;        (* JUMPI dest, cond *)
    ]

and compile_program program =
  List.mapi compile_definition program

and compile_definition index = function
  | Clarity.Constant _ | DataVar _ | Map _ -> unreachable ()
  | PrivateFunction func -> compile_function index func
  | PublicFunction func -> compile_function index func
  | PublicReadOnlyFunction func -> compile_function index func

and compile_function index (_, _, body) =
  let prelude = [
    EVM.JUMPDEST;       (* the dispatcher will jump here *)
    EVM.POP;            (* clean up from the dispatcher logic *)
  ] in
  let body = List.concat_map compile_expression body in
  let postlude = [      (* value expected on top of stack *)
    EVM.from_int 0;     (* offset = memory address 0 *)
    EVM.MSTORE;         (* MSTORE offset, value *)
    EVM.from_int 0x20;  (* length = 256 bits *)
    EVM.from_int 0;     (* offset = memory address 0 *)
    EVM.RETURN;         (* RETURN offset, length *)
    EVM.STOP;           (* redundant, but a good marker for EOF *)
  ] in
  (1 + index, prelude @ body @ postlude)

and compile_expression = function
  | Literal lit -> compile_literal lit
  | Ok expr -> compile_expression expr
  | VarGet (_) -> [
      EVM.from_int 0;   (* TODO: lookup *)
      EVM.SLOAD;        (* SLOAD key *)
    ]
  | VarSet (_, val') ->
    let val' = compile_expression val' in
    val' @ [
      EVM.from_int 0;   (* TODO: lookup *)
      EVM.SSTORE;       (* SSTORE key, value *)
    ]
  | Add [a; b] ->
    let a = compile_expression a in
    let b = compile_expression b in
    b @ a @ [EVM.ADD]   (* ADD a, b *)
  | Sub [a; b] ->
    let a = compile_expression a in
    let b = compile_expression b in
    b @ a @ [EVM.SUB]   (* SUB a, b *)
  | UnwrapPanic input ->
    let input = compile_expression input in
    input @ compile_branch [EVM.DUP 1; EVM.ISZERO]
      [EVM.POP; EVM.STOP]
      [EVM.SLOAD]
  | FunctionCall _ -> []  (* TODO *)
  | _ -> failwith "expression not implemented yet"  (* TODO *)

and compile_branch condition then_block else_block =
  let else_block = [EVM.JUMPDEST] @ else_block in
  let else_length = EVM.opcodes_size else_block in
  let then_block = then_block @ (compile_relative_jump else_length EVM.JUMP) in
  let then_length = EVM.opcodes_size then_block in
  condition @ [EVM.ISZERO] @ (compile_relative_jump then_length EVM.JUMPI) @
    then_block @ else_block @ [EVM.JUMPDEST]

and compile_relative_jump offset jump =
  let offset = 5 + offset in
  [EVM.PC; EVM.from_int offset; EVM.ADD; jump]

and compile_literal = function
  | NoneLiteral -> [EVM.from_int 0]
  | IntLiteral z -> [EVM.from_big_int z]
  | _ -> failwith "literal not implemented yet"  (* TODO *)

and link_offsets program =
  let rec loop pc = function
    | [] -> []
    | (_, body) :: rest ->
      let next_pc = pc + EVM.opcodes_size body in
      pc :: loop next_pc rest
  in
  loop 0 program

and link_program program =
  let block_offsets = link_offsets program in
  let rec link_block = function
    | [] -> []
    | EVM.PUSH (1, block_id) :: EVM.JUMPI :: rest ->
      let block_id = String.get block_id 0 |> Char.code in
      let block_pc = List.nth block_offsets block_id in
      EVM.from_int block_pc :: EVM.JUMPI :: link_block rest
    | op :: rest -> op :: link_block rest
  in
  let rec link_blocks = function
    | [] -> []
    | (id, body) :: rest -> (id, link_block body) :: link_blocks rest
  in
  link_blocks program

and function_hash name =
  let signature = Printf.sprintf "%s()" (mangle_name name) in  (* TODO *)
  let hash_function = Cryptokit.Hash.keccak 256 in
  let hash = Cryptokit.hash_string hash_function signature in
  String.sub hash 0 4

and mangle_name = function
  | "*" -> "mul"
  | "+" -> "add"
  | "-" -> "sub"
  | "/" -> "div"
  | "<" -> "lt"
  | "<=" -> "le"
  | ">" -> "gt"
  | ">=" -> "ge"
  | "sha512/256" -> "sha512_256"
  | "try!" -> "tryUnwrap"
  | name ->
    let filtered_chars = Str.regexp "[/?!]" in
    let name = Str.global_replace filtered_chars "" name in
    let words = String.split_on_char '-' name in
    let words = List.map String.capitalize_ascii words in
    String.uncapitalize_ascii (String.concat "" words)
