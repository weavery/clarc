(* This is free and unencumbered software released into the public domain. *)

let rec compile_contract program =
  let is_datavar = function Clarity.DataVar _ -> true | _ -> false in
  let (head, body) = List.partition is_datavar program in
  (compile_deployer head, compile_program body)

and compile_deployer program =
  List.map compile_datavar program  (* TODO: standard prelude *)

and compile_datavar = function
  | Clarity.DataVar (_name, _type', value) ->
    (0, [compile_expression value; EVM.from_int 0; EVM.SSTORE])
  | _ -> failwith "unreachable"

and compile_program program =
  List.map compile_definition program

and compile_definition = function
  | Clarity.DataVar _ -> failwith "unreachable"
  | PublicFunction func -> compile_function func
  | PublicReadOnlyFunction func -> compile_function func
  | _ -> failwith "not implemented yet"  (* TODO *)

and compile_function (_name, _params, _body) =
  (0, [])  (* TODO *)

and compile_expression = function
  | Literal lit -> compile_literal lit
  | _ -> failwith "not implemented yet"  (* TODO *)

and compile_literal = function
  | IntLiteral z -> EVM.from_big_int z
  | _ -> failwith "not implemented yet"  (* TODO *)
