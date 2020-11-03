(* This is free and unencumbered software released into the public domain. *)

type context =
  { vars: string list;
    funs: string list; }

let unreachable () = failwith "unreachable"

let unimplemented what = failwith (Printf.sprintf "%s not implemented yet" what)

let rec compile_contract ?(features=[]) program =
  let only_f = function Feature.OnlyFunction fn -> Some fn | _ -> None in
  let only_function = List.find_map only_f features in
  let no_deploy =
    match only_function with
    | Some _ -> true
    | None -> List.memq Feature.NoDeploy features
  in
  let is_var = function
    | Clarity.Constant _ | DataVar _ | Map _ -> true
    | _ -> false
  in
  let name_of = function
    | Clarity.Constant (name, _)
    | DataVar (name, _, _)
    | Map (name, _, _)
    | PrivateFunction (name, _, _)
    | PublicFunction (name, _, _)
    | PublicReadOnlyFunction (name, _, _) -> name
  in
  let (vars, funs) = List.partition is_var program in
  match only_function with
  | Some fn ->
    let funs = funs |> List.filter (fun f -> fn = name_of f) in
    let globals = { vars = List.map name_of vars; funs = List.map name_of funs; } in
    let program = compile_program globals funs in
    let payload = link_program program in
    ([], payload)
  | None ->
    let globals = { vars = List.map name_of vars; funs = List.map name_of funs; } in
    let dispatcher = compile_dispatcher funs in
    let program = compile_program globals funs in
    let payload = link_program (dispatcher @ program) in
    let deployer = if no_deploy then [] else compile_deployer globals vars payload in
    (deployer, payload)

and compile_deployer env vars payload =
  let inits = List.concat (List.mapi (compile_var env) vars) in
  let loader_length = 11 in  (* keep in sync with bytecode below *)
  let loader = [
    EVM.from_int (EVM.program_size payload);
    EVM.DUP 1;
    EVM.from_int (loader_length + (EVM.opcodes_size inits));
    EVM.zero;
    EVM.CODECOPY;
    EVM.zero;           (* offset = memory address 0 *)
    EVM.RETURN;         (* RETURN offset, length *)
  ] in
  [(0, inits @ loader)]

and compile_var env index = function
  | Clarity.Constant _ ->
    unimplemented "define-constant"  (* TODO *)
  | DataVar (_name, _type', value) ->
    let value = compile_expression env value in
    value @ [EVM.from_int index; EVM.SSTORE]
  | Map (_name, _, _) ->
    let value = [EVM.zero] in  (* TODO: store the byte size of the value tuple? *)
    value @ [EVM.from_int index; EVM.SSTORE]
  | _ -> unreachable ()

and compile_dispatcher program =
  let prelude = [
    EVM.from_int 0xE0;  (* b = 224 *)
    EVM.from_int 0x02;  (* a = 2 *)
    EVM.EXP;            (* EXP a, b (2^224) *)
    EVM.zero;           (* i = 0 *)
    EVM.CALLDATALOAD;   (* CALLDATALOAD i *)
    EVM.DIV;            (* DIV a, b *)
  ] in
  let tests = List.concat (List.mapi compile_dispatcher_test program) in
  let postlude = [EVM.STOP] in
  [(0, prelude @ tests @ postlude)]

and compile_dispatcher_test index = function
  | Clarity.Constant _ | DataVar _ | Map _ -> unreachable ()
  | PrivateFunction _ -> []
  | PublicFunction (name, params, _)
  | PublicReadOnlyFunction (name, params, _) ->
    let hash = function_hash name params in
    let dest = 1 + index in
    [
      EVM.DUP 1;        (* b = top of stack *)
      EVM.PUSH (4, hash);  (* a = keccak256(function_sig)[:4] *)
      EVM.EQ;           (* cond = EQ a, b *)
      EVM.from_int dest;   (* dest = the function prelude *)
      EVM.JUMPI;        (* JUMPI dest, cond *)
    ]

and compile_program env program =
  List.mapi (compile_definition env) program

and compile_definition env index = function
  | Clarity.Constant _ | DataVar _ | Map _ -> unreachable ()
  | PrivateFunction func ->
    compile_private_function env index func
  | PublicFunction func
  | PublicReadOnlyFunction func ->
    compile_public_function env index func

and compile_public_function env index (_, _, body) =
  let prelude = [
    EVM.JUMPDEST;       (* the contract dispatcher will jump here *)
    EVM.POP;            (* clean up from the dispatcher logic *)
    (* TODO: fetch function arguments *)
  ] in
  let body = List.concat_map (compile_expression env) body in
  let postlude = [      (* return value expected on top of stack *)
    EVM.zero;           (* offset = memory address 0 *)
    EVM.MSTORE;         (* MSTORE offset, value *)
    EVM.from_int 0x20;  (* length = 256 bits *)
    EVM.zero;           (* offset = memory address 0 *)
    EVM.RETURN;         (* RETURN offset, length *)
    EVM.STOP;           (* redundant, but a good marker for EOF *)
  ] in
  (1 + index, prelude @ body @ postlude)

and compile_private_function env index (_, _, body) =
  let prelude = [
    EVM.JUMPDEST;       (* the calling function will jump here, with the return PC on TOS *)
  ] in
  let body = List.concat_map (compile_expression env) body in
  let postlude = [      (* return value expected on top of stack *)
    EVM.SWAP 1;         (* destination, result -- result, destination *)
    EVM.JUMP;           (* JUMP destination *)
    EVM.STOP;           (* redundant, but a good marker for EOF *)
  ] in
  (1 + index, prelude @ body @ postlude)

and compile_expression env = function
  | Literal lit -> compile_literal lit
  | TupleExpression [("key", key)] -> compile_expression env key
  | TupleExpression _ -> unimplemented "arbitrary tuple expressions"  (* TODO *)
  | Ok expr -> compile_expression env expr
  | Err expr -> compile_expression env expr

  | VarGet var ->
    let var_slot = lookup_variable_slot env var in
    [EVM.from_int var_slot; EVM.SLOAD]  (* SLOAD key *)

  | VarSet (var, val') ->
    let var_slot = lookup_variable_slot env var in
    let val' = compile_expression env val' in
    val' @ [EVM.from_int var_slot; EVM.SSTORE]  (* SSTORE key, value *)

  | Add [a; b] ->
    let a = compile_expression env a in
    let b = compile_expression env b in
    b @ a @ [EVM.ADD]   (* ADD a, b *)

  | Sub [a; b] ->
    let a = compile_expression env a in
    let b = compile_expression env b in
    b @ a @ [EVM.SUB]   (* SUB a, b *)

  | UnwrapPanic input ->
    let input = compile_expression env input in
    input @ compile_branch [EVM.DUP 1; EVM.ISZERO]
      [EVM.POP; EVM.zero; EVM.zero; EVM.REVERT]
      [EVM.SLOAD]

  | Keyword "tx-sender" -> [EVM.CALLER]

  | FunctionCall ("get", [Identifier _; Identifier _]) ->  (* TODO *)
    [
      EVM.from_int 0x80;                 (* 128 bits *)
      EVM.from_int 2; EVM.EXP; EVM.MUL;  (* equivalent to EVM.SHL *)
      EVM.from_int 0x80;                 (* 128 bits *)
      EVM.from_int 2; EVM.EXP; EVM.SWAP 1; EVM.DIV;  (* equivalent to EVM.SWAP 1; EVM.SHR *)
    ]

  | FunctionCall ("map-set", [Identifier var; key; value]) ->  (* TODO *)
    let _ = lookup_variable_slot env var in
    let key = compile_expression env key in
    let value = compile_expression env value in
    value @ key @ [EVM.SSTORE]

  | FunctionCall ("map-get?", [Identifier var; TupleExpression [("key", _key)]]) ->  (* TODO *)
    let _ = lookup_variable_slot env var in
    let key = [EVM.CALLER] in  (* TODO *)
    key @ [EVM.SLOAD; EVM.DUP 1; EVM.ISZERO; EVM.NOT]

  | FunctionCall ("match", [input_expr; _some_binding; some_branch; none_branch]) ->
    let input_value = compile_expression env input_expr in
    let some_block = compile_expression env some_branch in
    let none_block = compile_expression env none_branch in
    input_value @ compile_branch [EVM.ISZERO] ([EVM.POP] @ none_block) some_block

  | FunctionCall (name, _args) ->
    let block_id = lookup_function_block env name in
    let call_sequence = [
        (* TODO: push function call arguments *)
        EVM.from_int block_id;
        EVM.JUMP
      ]
    in
    let call_length = EVM.opcodes_size call_sequence in
    (compile_relative_offset call_length) @ call_sequence @ [EVM.JUMPDEST]

  | _ -> unimplemented "arbitrary expressions"  (* TODO *)

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

and compile_relative_offset offset =
  let offset = 4 + offset in
  [EVM.PC; EVM.from_int offset; EVM.ADD]

and compile_literal = function
  | NoneLiteral -> [EVM.zero]
  | BoolLiteral b -> [EVM.from_int (if b then 1 else 0)]
  | IntLiteral z -> [EVM.from_big_int z]
  | UintLiteral z -> [EVM.from_big_int z]
  | BuffLiteral _ -> unimplemented "buff literals"  (* TODO *)
  | StringLiteral _ -> unimplemented "string literals"  (* TODO *)
  | TupleLiteral kvs -> compile_tuple_literal kvs

and compile_tuple_literal = function
  | [(_, (NoneLiteral as lit))]
  | [(_, (BoolLiteral _ as lit))]
  | [(_, (IntLiteral _ as lit))]
  | [(_, (UintLiteral _ as lit))] -> compile_literal lit
  | [(_, IntLiteral a); (_, IntLiteral b)] -> compile_packed_word a b
  | _ -> unimplemented "arbitrary tuple literals"  (* TODO *)

and compile_packed_word hi lo =
  (* [EVM.from_big_int hi; EVM.from_int 0x80; EVM.SHL; EVM.from_big_int lo; EVM.OR] *)
  [EVM.from_big_int hi; EVM.from_int 0x80; EVM.from_int 2; EVM.EXP; EVM.MUL; EVM.from_big_int lo; EVM.OR]

and compile_param (_, type') =
  compile_type type'

and compile_type = function
  (* See: https://solidity.readthedocs.io/en/develop/abi-spec.html#types *)
  | Clarity.Principal -> "address"
  | Bool -> "bool"
  | Int -> "int128"
  | Uint -> "uint128"
  | Buff len | String (len, _) -> Printf.sprintf "bytes%d" len
  | type' ->
    let type_name = Clarity.type_to_string type' in
    let error = Printf.sprintf "unsupported public parameter type: %s" type_name in
    failwith error

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

and lookup_variable_slot env symbol =
  match lookup_symbol env.vars symbol with
  | None -> failwith (Printf.sprintf "unknown variable: %s" symbol)
  | Some index -> index

and lookup_function_block env symbol =
  match lookup_symbol env.funs symbol with
  | None -> failwith (Printf.sprintf "unknown function: %s" symbol)
  | Some index -> 1 + index

and lookup_symbol symbols symbol =
  let rec loop index = function
    | [] -> None
    | hd :: tl ->
      if hd = symbol then Some index
      else loop (index + 1) tl
  in
  loop 0 symbols

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
    | EVM.PUSH (1, block_id) :: (EVM.JUMP as jump) :: rest
    | EVM.PUSH (1, block_id) :: (EVM.JUMPI as jump) :: rest ->
      let block_id = String.get block_id 0 |> Char.code in
      let block_pc = List.nth block_offsets block_id in
      EVM.from_int block_pc :: jump :: link_block rest
    | op :: rest -> op :: link_block rest
  in
  let rec link_blocks = function
    | [] -> []
    | (id, body) :: rest -> (id, link_block body) :: link_blocks rest
  in
  link_blocks program

and function_hash name params =
  let params = List.map compile_param params |> String.concat "," in
  let input = Printf.sprintf "%s(%s)" (mangle_name name) params in
  let hash = keccak256 input in
  String.sub hash 0 4

and keccak256 input =
  let hash_function = Cryptokit.Hash.keccak 256 in
  Cryptokit.hash_string hash_function input
