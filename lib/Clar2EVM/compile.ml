(* This is free and unencumbered software released into the public domain. *)

let rec compile_contract program =
  let is_var = function Clarity.DataVar _ -> true | _ -> false in
  let (vars, program) = List.partition is_var program in
  (compile_deployer vars, compile_program program)

and compile_deployer vars =
  let loader = [] in
  let vars = List.concat (List.mapi compile_data_var vars) in
  [(0, loader @ vars); (1, [])]

and compile_data_var index = function
  | Clarity.DataVar (_name, _type', value) ->
    compile_expression value @ [EVM.from_int index; EVM.SSTORE]
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
  | IntLiteral z -> [EVM.from_big_int z]
  | _ -> failwith "not implemented yet"  (* TODO *)
