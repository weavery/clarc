(* This is free and unencumbered software released into the public domain. *)

let rec compile_contract program =
  let is_var = function Clarity.DataVar _ -> true | _ -> false in
  let (vars, program) = List.partition is_var program in
  let dispatcher = compile_dispatcher program in
  let program = compile_program program in
  let payload = link_program (dispatcher @ program) in
  let deployer = compile_deployer vars payload in
  (deployer, payload)

and compile_deployer vars payload =
  let inits = List.concat (List.mapi compile_data_var vars) in
  let loader_length = 11 in  (* keep in sync with bytecode below *)
  let loader = [
    EVM.from_int (EVM.program_size payload);
    EVM.DUP 1;
    EVM.from_int (loader_length + (EVM.opcodes_size inits));
    EVM.from_int 0;
    EVM.CODECOPY;
    EVM.from_int 0;
    EVM.RETURN;
  ] in
  [(0, inits @ loader)]

and compile_data_var index = function
  | Clarity.DataVar (_name, _type', value) ->
    compile_expression value @ [EVM.from_int index; EVM.SSTORE]
  | _ -> failwith "unreachable"

and compile_dispatcher program =
  let prelude = [
    EVM.from_int 0xE0;
    EVM.from_int 0x02;
    EVM.EXP;  (* 2^224 *)
    EVM.from_int 0;
    EVM.CALLDATALOAD;
    EVM.DIV;
  ] in
  let tests = List.concat (List.mapi compile_dispatcher_test program) in
  let postlude = [EVM.STOP] in
  [(0, prelude @ tests @ postlude)]

and compile_dispatcher_test index = function
  | Clarity.DataVar _ -> failwith "unreachable"
  | PublicFunction (name, _, _)
  | PublicReadOnlyFunction (name, _, _) ->
    [
      EVM.DUP 1;
      EVM.PUSH (4, (function_hash name));
      EVM.EQ;
      EVM.from_int (1 + index);
      EVM.JUMPI;
    ]
  | _ -> failwith "not implemented yet"  (* TODO *)

and compile_program program =
  List.mapi compile_definition program

and compile_definition index = function
  | Clarity.DataVar _ -> failwith "unreachable"
  | PublicFunction func -> compile_function index func
  | PublicReadOnlyFunction func -> compile_function index func
  | _ -> failwith "not implemented yet"  (* TODO *)

and compile_function index (_name, _params, _body) =
  (1 + index, [EVM.JUMPDEST; EVM.POP; EVM.from_int (1 + index); EVM.STOP])  (* TODO *)

and compile_expression = function
  | Literal lit -> compile_literal lit
  | _ -> failwith "not implemented yet"  (* TODO *)

and compile_literal = function
  | IntLiteral z -> [EVM.from_big_int z]
  | _ -> failwith "not implemented yet"  (* TODO *)

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

and function_hash = function
  | "get-counter" -> "\x8a\xda\x06\x6e"
  | "increment" -> "\xd0\x9d\xe0\x8a"
  | "decrement" -> "\x2b\xae\xce\xb7"
  | _ -> failwith "not implemented yet"  (* TODO: implement Keccak-256 *)
