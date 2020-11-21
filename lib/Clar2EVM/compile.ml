(* This is free and unencumbered software released into the public domain. *)

type context =
  { global_vars: string list;
    global_funs: string list;
    local_vars: (string * int) list; }

let make_context global_vars global_funs local_vars =
  { global_vars; global_funs; local_vars; }

let extend_context context local_vars =
  { global_vars = context.global_vars;
    global_funs = context.global_funs;
    local_vars = local_vars @ context.local_vars; }

let _dump_context context =
  let dump_local_var (n, i) = Printf.eprintf "\t(%s, %d)" n i in
  Printf.eprintf "local_vars=%d\t" (List.length context.local_vars);
  List.iter dump_local_var context.local_vars

let unimplemented_function name type' =
  unimplemented (Printf.sprintf "(%s %s)" name (Clarity.type_to_string type'))

let unsupported_function name type' =
  unsupported (Printf.sprintf "(%s %s)" name (Clarity.type_to_string type'))

let unsupported_function2 name type1 type2 =
  let typename1 = Clarity.type_to_string type1 in
  let typename2 = Clarity.type_to_string type2 in
  unsupported (Printf.sprintf "(%s %s %s)" name typename1 typename2)

let error_in_function name message =
  failwith (Printf.sprintf "%s: %s" name message)

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
    let globals = make_context (List.map name_of vars) (List.map name_of funs) [] in
    let program = compile_program features globals funs in
    let payload = link_program program in
    ([], payload)
  | None ->
    let globals = make_context (List.map name_of vars) (List.map name_of funs) [] in
    let dispatcher = compile_dispatcher funs in
    let program = compile_program features globals funs in
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
    EVM.sstore index value
  | Map (_name, _, _) ->
    let value = [EVM.zero] in  (* TODO: store the byte size of the value tuple? *)
    EVM.sstore index value
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
  let postlude = EVM.stop in
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

and compile_program features env program =
  List.mapi (compile_definition features env) program

and compile_definition features env index = function
  | Clarity.Constant _ | DataVar _ | Map _ -> unreachable ()
  | PrivateFunction func -> compile_private_function features env index func
  | PublicFunction func -> compile_public_function features env index func ~response_only:true
  | PublicReadOnlyFunction func -> compile_public_function features env index func ~response_only:false

and compile_public_function ?(response_only=false) features env index (name, _, body) =
  let only_f = function Feature.OnlyFunction fn -> Some fn | _ -> None in
  let only_function = List.find_map only_f features in
  let prelude =
    match only_function with
    | Some _ -> []
    | None -> [
        EVM.JUMPDEST;       (* the contract dispatcher will jump here *)
        EVM.POP;            (* clean up from the dispatcher logic *)
        (* TODO: fetch function arguments *)
      ]
  in
  let rec compile_body_with_response_return = function
    | [] -> error_in_function name "function body is empty"
    | [Clarity.Ok expr]
    | [Clarity.Err expr] -> [compile_expression env expr]
    | [expr] ->
      begin match type_of_expression expr with
      | Response _ -> [compile_expression env expr]
      | _ -> error_in_function name "function must return (ok) or (err)"
      end
    | expr :: exprs -> compile_expression env expr :: compile_body_with_response_return exprs
  in
  let compile_body_with_any_return = function
    | [] -> error_in_function name "function body is empty"
    | exprs -> List.map (compile_expression env) exprs
  in
  let compile_body = if response_only
    then compile_body_with_response_return
    else compile_body_with_any_return
  in
  let body = compile_body body |> List.concat in
  let postlude =        (* (ok ...) or (err ...) expected on top of stack *)
    EVM.mstore 0 []
    @ EVM.return1
    @ EVM.stop          (* redundant, but a good marker for EOF *)
  in
  (1 + index, prelude @ body @ postlude)

and compile_private_function _features env index (_, _, body) =
  let prelude = EVM.jumpdest in  (* the calling function will jump here, with the return PC on TOS *)
  let body = List.concat_map (compile_expression env) body in
  let postlude = [      (* return value expected on top of stack *)
    EVM.SWAP 1;         (* destination, result -- result, destination *)
    EVM.JUMP;           (* JUMP destination *)
  ] @ EVM.stop          (* redundant, but a good marker for EOF *)
  in
  (1 + index, prelude @ body @ postlude)

and compile_expression env expr =
  let rec compile sp = function
    | Clarity.Literal lit -> compile_literal lit
    | TupleExpression [("key", key)] -> compile sp key
    | TupleExpression _ -> unimplemented "arbitrary tuple expressions"  (* TODO *)

    | Add [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.add a b  (* TODO: handle overflow *)

    | And [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.and' a b

    | DefaultTo (default_value, option_value) ->
      begin match type_of_expression option_value with
      | Optional _ ->
        let cond_value = compile sp option_value in
        let some_block = [] in  (* top of stack contains the unpacked value *)
        let none_block = compile sp default_value in
        compile_branch cond_value some_block none_block
      | t -> unsupported_function "default-to" t
      end

    | Div [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.div a b  (* TODO: handle division by zero *)

    | Err x -> compile sp x @ [EVM.zero]

    | Ge (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.ge a b  (* TODO: signed vs unsigned *)

    | Gt (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.gt a b  (* TODO: signed vs unsigned *)

    | Identifier id -> (* _dump_context env; *)
      begin match List.find_opt (fun (name, _) -> name = id) env.local_vars with
      | None -> failwith (Printf.sprintf "unbound variable: %s" id)
      | Some (_, local_var_index) ->
        let stack_slot = (List.length env.local_vars) - local_var_index in
        EVM.dup stack_slot
      end

    | If (cond_expr, then_branch, else_branch) ->
      begin match type_of_expression cond_expr with
      | Bool ->
        let cond_value = compile sp cond_expr in
        let then_block = compile sp then_branch in
        let else_block = compile sp else_branch in
        compile_branch cond_value then_block else_block
      | t -> unsupported_function "if" t
      end

    | IsEq [a; b] ->
      begin match type_of_expression a, type_of_expression b with
      | a_type, b_type when a_type = b_type ->
        let a = compile sp a in
        let b = compile sp b in
        EVM.eq a b
      | a_type, b_type -> unsupported_function2 "is-eq" a_type b_type
      end

    | IsErr x ->
      begin match type_of_expression x with
      | Response _ -> compile sp x |> EVM.iszero
      | t -> unsupported_function "is-err" t
      end

    | IsNone x ->
      begin match type_of_expression x with
      | Optional _ -> compile sp x |> EVM.iszero
      | t -> unsupported_function "is-none" t
      end

    | IsOk x ->
      begin match type_of_expression x with
      | Response _ -> compile sp x @ [EVM.ISZERO; EVM.ISZERO]
      | t -> unsupported_function "is-ok" t
      end

    | IsSome x ->
      begin match type_of_expression x with
      | Optional _ -> compile sp x @ [EVM.ISZERO; EVM.ISZERO]
      | t -> unsupported_function "is-some" t
      end

    | Le (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.le a b  (* TODO: signed vs unsigned *)

    | Len x ->
      begin match type_of_expression x with
      | String (n, _) | Buff n | List (n, _) -> [EVM.from_int n]
      | t -> unsupported_function "len" t
      end

    | Let (bindings, body) ->
      let local_var_count = List.length env.local_vars in
      let compile_binding_index index (name, _) = (name, local_var_count + index) in
      let compile_binding_expr (_, expr) = compile sp expr in
      let env = extend_context env (List.mapi compile_binding_index bindings) in
      let last_body_index = (List.length body) - 1 in
      let compile_body_expr index expr =
        compile_expression env expr @
          if index < last_body_index then EVM.pop1 else []
      in
      List.map compile_binding_expr bindings @
        List.mapi compile_body_expr body |> List.concat

    | ListExpression xs ->
      List.concat_map (compile sp) xs @ [EVM.from_int (List.length xs)]

    | Lt (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.lt a b  (* TODO: signed vs unsigned *)

    | Match (input_expr, (_, some_branch), (_, none_branch)) ->
      let input_value = compile sp input_expr in
      let some_block = compile sp some_branch in
      let none_block = compile sp none_branch in
      input_value @ compile_branch [EVM.ISZERO] (EVM.pop @ none_block) some_block

    | Mod (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.mod' a b  (* TODO: handle division by zero *)

    | Mul [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.mul a b  (* TODO: handle overflow *)

    | Not x ->
      let x = compile sp x in
      EVM.iszero x

    | Ok x -> compile sp x @ [EVM.one]

    | Or [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.or' a b

    | Pow (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.exp a b  (* TODO: handle overflow *)

    | SomeExpression x -> compile sp x @ [EVM.one]

    | Sub [a; b] ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.sub a b  (* TODO: handle underflow *)

    | Try input ->
      begin match type_of_expression input with
      | Optional _ ->
        let cond_value = compile sp input in
        let none_block = EVM.mstore_int 0 0 @ EVM.return1 in
        compile_branch cond_value [] none_block
      | Response _ ->
        let cond_value = compile sp input in
        let err_block = EVM.mstore_int 0 0 @ EVM.mstore 1 [] @ EVM.return2 in
        compile_branch cond_value [] err_block
      | t -> unsupported_function "try!" t
      end

    | UnwrapErr (input, thrown_value) ->
      begin match type_of_expression input with
      | Response _ ->
        let cond_value = compile sp input in
        let ok_block = EVM.pop1 @ compile sp thrown_value @ EVM.mstore 0 [] @ EVM.return1 in
        compile_branch cond_value ok_block []
      | t -> unsupported_function "unwrap-err!" t
      end

    | UnwrapErrPanic input ->
      begin match type_of_expression input with
      | Response _ ->
        let cond_value = compile sp input in
        let ok_block = EVM.pop1 @ EVM.revert0 in
        compile_branch cond_value ok_block []
      | t -> unsupported_function "unwrap-err-panic" t
      end

    | Unwrap (input, thrown_value) ->
      begin match type_of_expression input with
      | Optional _ ->
        let cond_value = compile sp input in
        let none_block = compile sp thrown_value @ EVM.mstore 0 [] @ EVM.return1 in
        compile_branch cond_value [] none_block
      | Response _ ->
        let cond_value = compile sp input in
        let err_block = EVM.pop1 @ compile sp thrown_value @ EVM.mstore 0 [] @ EVM.return1 in
        compile_branch cond_value [] err_block
      | t -> unsupported_function "unwrap!" t
      end

    | UnwrapPanic input ->
      begin match type_of_expression input with
      | Optional _ ->
        let cond_value = compile sp input in
        let none_block = EVM.revert0 in
        compile_branch cond_value [] none_block
      | Response _ ->
        let cond_value = compile sp input in
        let err_block = EVM.pop1 @ EVM.revert0 in
        compile_branch cond_value [] err_block
      | t -> unsupported_function "unwrap-panic" t
      end

    | VarGet var ->
      let var_slot = lookup_variable_slot env var in
      EVM.sload var_slot

    | VarSet (var, val') ->
      let var_slot = lookup_variable_slot env var in
      let val' = compile sp val' in
      EVM.sstore var_slot val'

    | Xor (a, b) ->
      let a = compile sp a in
      let b = compile sp b in
      EVM.xor a b

    | Keyword "block-height" -> EVM.number
    | Keyword "burn-block-height" -> EVM.number
    | Keyword "contract-caller" -> EVM.caller
    | Keyword "is-in-regtest" -> compile_literal (BoolLiteral false)
    | Keyword "stx-liquid-supply" -> unsupported "stx-liquid-supply"
    | Keyword "tx-sender" -> EVM.origin

    | FunctionCall ("append", [list; element]) ->
      begin match type_of_expression list, type_of_expression element with
      | List (n, e1), e2 when e1 = e2 ->
        let list = compile sp list in
        let element = compile sp element in
        list @ EVM.pop1 @ element @ [EVM.from_int (n + 1)]
      | t, e -> unsupported_function2 "append" t e
      end

    | FunctionCall ("asserts!", [bool_expr; _]) ->  (* TODO: thrown_value *)
      begin match type_of_expression bool_expr with
      | Bool ->
        let cond_value = compile sp bool_expr in
        let then_block = [EVM.one] in
        let else_block = EVM.revert0 in
        compile_branch cond_value then_block else_block
      | t -> unsupported_function "asserts!" t
      end

    | FunctionCall ("concat", [list1; list2]) ->
      begin match type_of_expression list1, type_of_expression list2 with
      | List (n1, e1), List (n2, e2) when e1 = e2 ->
        let list1 = compile sp list1 in
        let list2 = compile sp list2 in
        list1 @ EVM.pop1 @ list2 @ EVM.pop1 @ [EVM.from_int (n1 + n2)]
      | t1, t2 -> unsupported_function2 "concat" t1 t2
      end

    | FunctionCall ("get", [Identifier _; Identifier _]) ->  (* TODO *)
      [
        EVM.from_int 0x80;                 (* 128 bits *)
        EVM.two; EVM.EXP; EVM.MUL;         (* equivalent to EVM.SHL *)
        EVM.from_int 0x80;                 (* 128 bits *)
        EVM.two; EVM.EXP; EVM.SWAP 1; EVM.DIV;  (* equivalent to EVM.SWAP 1; EVM.SHR *)
      ]

    | FunctionCall ("hash160", [value]) ->
      begin match type_of_expression value with
      | Clarity.Buff _ | Int | Uint ->
        let input_size = size_of_expression value in
        let input_mstore = compile_mstore_of_expression env value in
        input_mstore @ EVM.staticcall_hash160 (0, input_size) 0 @ EVM.pop
      | t -> unsupported_function "hash160" t
      end

    | FunctionCall ("keccak256", [value]) ->
      begin match type_of_expression value with
      | Clarity.Buff _ | Int | Uint ->
        let input_size = size_of_expression value in
        let value = compile sp value in
        EVM.mstore 0 value @ EVM.sha3 (0, input_size)
      | t -> unsupported_function "keccak256" t
    end

    | FunctionCall ("map-set", [Identifier var; key; value]) ->  (* TODO *)
      let _ = lookup_variable_slot env var in
      let key = compile sp key in
      let value = compile sp value in
      value @ key @ [EVM.SSTORE]

    | FunctionCall ("map-get?", [Identifier var; TupleExpression [("key", _key)]]) ->  (* TODO *)
      let _ = lookup_variable_slot env var in
      let key = EVM.caller in  (* TODO *)
      key @ [EVM.SLOAD; EVM.DUP 1; EVM.ISZERO; EVM.NOT]

    | FunctionCall ("print", [expr]) ->
      begin match expr with
      | Literal value -> compile_static_print_call value
      | _ -> unimplemented "print for non-literals"  (* TODO *)
      end

    | FunctionCall ("sha256", [value]) ->
      begin match type_of_expression value with
      | Clarity.Buff _ | Int | Uint ->
        let input_size = size_of_expression value in
        let input_mstore = compile_mstore_of_expression env value in
        input_mstore @ EVM.staticcall_sha256 (0, input_size) 0 @ EVM.pop
      | t -> unsupported_function "sha256" t
    end

    | FunctionCall ("sha512", [value]) ->
      begin match type_of_expression value with
      | t -> unimplemented_function "sha512" t  (* TODO *)
      end

    | FunctionCall ("sha512/256", [value]) ->
      begin match type_of_expression value with
      | t -> unimplemented_function "sha512/256" t  (* TODO *)
      end

    | FunctionCall (name, _args) ->
      let block_id = lookup_function_block env name in
      let call_sequence =
        (* TODO: push function call arguments *)
        EVM.jump block_id
      in
      let call_length = EVM.opcodes_size call_sequence in
      (compile_relative_offset call_length) @ call_sequence @ EVM.jumpdest

    | _ -> unimplemented "arbitrary expressions"  (* TODO *)
  in
  compile 0 expr

and compile_static_print_call value =
  (* See: https://hardhat.org/hardhat-network/#console-log *)
  (* See: https://github.com/nomiclabs/hardhat/blob/master/packages/hardhat-core/console.sol *)
  let log_addr = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x63\x6F\x6e\x73\x6F\x6c\x65\x2e\x6c\x6f\x67" in
  let (signature, args) =
    match value with
    (* TODO: log(address) *)
    | NoneLiteral -> ("log()", [])
    | BoolLiteral b -> ("log(bool)", [EVM.ABI.BoolVal b])
    | IntLiteral z -> ("log(int)", [EVM.ABI.Int128Val z])
    | UintLiteral z -> ("log(uint)", [EVM.ABI.Uint128Val z])
    | BuffLiteral s ->
      let n = String.length s in
      if n > 0 && n <= 32 then (Printf.sprintf "log(bytes%d)" n, [EVM.ABI.Bytes32Val s])
      else ("log(bytes)", [EVM.ABI.BytesVal s])
    | StringLiteral s -> ("log(string)", [EVM.ABI.BytesVal s])
    | TupleLiteral _ -> unsupported_function "print" (type_of_literal value)
  in
  let payload = EVM.ABI.encode_with_signature signature args in
  let payload_size = String.length payload in
  let mstore = EVM.mstore_bytes 0 payload in
  [EVM.zero] @  (* TODO: the return value *)
  mstore @ EVM.staticcall log_addr (0, payload_size) (0, 0) @ EVM.pop

and compile_mstore_of_expression ?(offset=0) env expr =
  EVM.mstore offset (compile_expression env expr)

and compile_branch cond_block then_block else_block =
  let else_block = EVM.jumpdest @ else_block in
  let else_length = EVM.opcodes_size else_block in
  let then_block = then_block @ (compile_relative_jump else_length EVM.JUMP) in
  let then_length = EVM.opcodes_size then_block in
  cond_block @ [EVM.ISZERO] @ (compile_relative_jump then_length EVM.JUMPI) @
    then_block @ else_block @ EVM.jumpdest

and compile_relative_jump offset jump =
  let offset = 5 + offset in
  [EVM.PC; EVM.from_int offset; EVM.ADD; jump]

and compile_relative_offset offset =
  let offset = 4 + offset in
  [EVM.PC; EVM.from_int offset; EVM.ADD]

and compile_literal = function
  | NoneLiteral -> [EVM.zero]
  | BoolLiteral b -> [EVM.from_bool b]
  | IntLiteral z ->
    if (Big_int.num_bits_big_int z) <= 127 then [EVM.from_big_int z]
    else unsupported "int underflow/overflow"
  | UintLiteral z ->
    if (Big_int.num_bits_big_int z) <= 128 then [EVM.from_big_int z]
    else unsupported "uint overflow"
  | BuffLiteral s ->
    if (String.length s) <= 32 then [EVM.from_string s]
    else unimplemented "large buff literals (32+ bytes)"  (* TODO *)
  | StringLiteral s ->
    let len = String.length s in
    if len = 0 then [EVM.zero; EVM.zero]
    else if len <= 32 then [EVM.from_string s; EVM.from_int len]
    else unimplemented "large string literals (32+ bytes)"  (* TODO *)
  | TupleLiteral kvs -> compile_tuple_literal kvs

and compile_tuple_literal = function
  | [(_, (NoneLiteral as lit))]
  | [(_, (BoolLiteral _ as lit))]
  | [(_, (IntLiteral _ as lit))]
  | [(_, (UintLiteral _ as lit))] -> compile_literal lit
  | [(_, IntLiteral a); (_, IntLiteral b)] -> compile_packed_word a b
  | [(_, UintLiteral _a); (_, UintLiteral _b)] -> unimplemented "packed uint tuple literals"  (* TODO *)
  | _ -> unimplemented "arbitrary tuple literals"  (* TODO *)

and compile_packed_word hi lo =
  (* [EVM.from_big_int hi; EVM.from_int 0x80; EVM.SHL; EVM.from_big_int lo; EVM.OR] *)
  [EVM.from_big_int hi; EVM.from_int 0x80; EVM.two; EVM.EXP; EVM.MUL; EVM.from_big_int lo; EVM.OR]

and compile_param (_, type') =
  compile_type type'

and compile_type = function
  (* See: https://solidity.readthedocs.io/en/develop/abi-spec.html#types *)
  | Clarity.Principal -> EVM.ABI.Address
  | Bool -> Bool
  | Int -> Int128
  | Uint -> Uint128
  | Buff len | String (len, _) -> BytesN len
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
  match lookup_symbol env.global_vars symbol with
  | None -> failwith (Printf.sprintf "unknown variable: %s" symbol)
  | Some index -> index

and lookup_function_block env symbol =
  match lookup_symbol env.global_funs symbol with
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
  let name = mangle_name name in
  let params = List.map compile_param params in
  EVM.ABI.encode_function_prototype name params

and size_of_expression expr =
  size_of_type (type_of_expression expr)

and size_of_type = function
  | Clarity.Unit -> 0
  | Principal -> 20
  | Bool | Int | Uint -> 16
  | Optional t -> size_of_type t
  | Response (t, _) -> size_of_type t
  | Buff n -> n
  | String (n, _) -> n
  | List _ -> unimplemented "size_of_type for lists"  (* TODO *)
  | Tuple _ -> unimplemented "size_of_type for tuples"  (* TODO *)
