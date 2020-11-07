(* This is free and unencumbered software released into the public domain. *)

let unsupported_function name type' =
  unsupported (Printf.sprintf "(%s %s)" name (Clarity.type_to_string type'))

let unsupported_function2 name type1 type2 =
  let typename1 = Clarity.type_to_string type1 in
  let typename2 = Clarity.type_to_string type2 in
  unsupported (Printf.sprintf "(%s %s %s)" name typename1 typename2)

let rec type_of_expression = function
  | Clarity.Literal lit -> type_of_literal lit
  | Identifier _ -> Clarity.Unit  (* FIXME: unimplemented "type_of_expression for variable bindings" *)

  | TupleExpression _ -> unimplemented "type_of_expression for tuple expressions"
  | ListExpression _ -> unimplemented "type_of_expression for list expressions"
  | SomeExpression expr -> Clarity.Optional (type_of_expression expr)
  | Ok expr -> Response (type_of_expression expr, Unit)
  | Err expr -> Response (Unit, type_of_expression expr)

  | Add _ | Sub _ | Mul _ | Div _ | Mod _ | Pow _ | Xor _ -> Clarity.Int
  | Ge _ | Gt _ | Le _ | Lt _ -> Bool

  | And _ | Or _ | Not _ -> Bool
  | DefaultTo (default, _) -> type_of_expression default
  | If (_, then', _) -> type_of_expression then'
  | IsEq _ | IsNone _ | IsSome _ | IsErr _ | IsOk _ -> Bool
  | Len _ -> Uint
  | Let (_, body) -> type_of_expression (match last body with Some x -> x | None -> unreachable ())
  | Match (input, (_, ok_expr), (_, err_expr)) ->
    begin match type_of_expression input with
    | Optional _ | Response _ ->
      begin match type_of_expression ok_expr, type_of_expression err_expr with
      | Response _, Response _ -> Response (Unit, Unit)  (* FIXME *)
      | ok_type, err_type when ok_type = err_type -> Response (Unit, Unit)
      | ok_type, err_type -> unsupported_function2 "match" ok_type err_type
      end
    | t -> unsupported_function "match" t
    end
  | ToInt _ -> Int
  | ToUint _ -> Uint
  | Try _ -> unimplemented "type_of_expression for try!"
  | Unwrap (_, _)
  | UnwrapPanic _
  | UnwrapErr (_, _)
  | UnwrapErrPanic _ -> unimplemented "type_of_expression for unwrap forms"
  | VarGet _ -> unimplemented "type_of_expression for var-get"
  | VarSet _ -> Bool

  | Keyword "block-height" -> Uint
  | Keyword "burn-block-height" -> Uint
  | Keyword "contract-caller" -> Principal
  | Keyword "is-in-regtest" -> Bool
  | Keyword "stx-liquid-supply" -> Uint
  | Keyword "tx-sender" -> Principal
  | Keyword id -> unimplemented (Printf.sprintf "type_of_expression for %s" id)

  | FunctionCall ("get", [_; tuple]) -> type_of_expression tuple
  | FunctionCall ("hash160", _) -> Buff 20
  | FunctionCall ("keccak256", _) -> Buff 32
  | FunctionCall ("map-set", _) -> Bool
  | FunctionCall ("map-get?", _) -> Optional (Tuple [])
  | FunctionCall ("sha256", _) -> Buff 32
  | FunctionCall ("sha512", _) -> Buff 64
  | FunctionCall ("sha512/256", _) -> Buff 32
  | FunctionCall (id, _) -> unimplemented (Printf.sprintf "type_of_expression for '%s'" id)

and type_of_literal = function
  | Clarity.NoneLiteral -> Clarity.Optional Unit
  | BoolLiteral _ -> Bool
  | IntLiteral _ -> Int
  | UintLiteral _ -> Uint
  | TupleLiteral kvs -> Tuple (List.map (fun (id, lit) -> (id, type_of_literal lit)) kvs)
  | BuffLiteral s -> Buff (String.length s)
  | StringLiteral s -> String (String.length s, Clarity.UTF8)