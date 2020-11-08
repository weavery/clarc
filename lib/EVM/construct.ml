(* This is free and unencumbered software released into the public domain. *)

type addr = string

type ptr = int

type slice = ptr * int

let rec addr_of_int z =
  match from_int z with PUSH (_, s) -> s | _ -> unreachable ()

and ptr_of_int z = z

and from_string s =
  PUSH (String.length s, s)

and from_big_int z =
  match Big_int.int_of_big_int_opt z with
  | Some z -> from_int z
  | None -> PUSH (32, ABI.encode_bigint_as_uint256 z)

and from_int z =
  if z < 0 then unimplemented "encoding of negative integers"  (* FIXME *)
  else if z <= 0xFF then PUSH (1, Char.chr z |> String.make 1)
  else PUSH (32, ABI.encode_int_as_uint256 z)

and from_bool b = from_int (if b then 1 else 0)

and from_ptr = function
  | ptr -> from_int ptr

and bytes32 s =
  match String.length s with
  | n when n = 32 -> PUSH (n, s)
  | n when n > 0 && n < 32 ->
    let buffer = Buffer.create 32 in
    Buffer.add_string buffer s;
    for _ = n + 1 to 32 do Buffer.add_char buffer '\x00' done;
    PUSH (32, Buffer.contents buffer)
  | _ -> unreachable ()

let from_addr = from_string

let zero = from_int 0

let one = from_int 1

let two = from_int 2

let add a b = b @ a @ [ADD]

let and' a b = b @ a @ [AND]

let caller = [CALLER]

let div a b = b @ a @ [DIV]

let eq a b = b @ a @ [EQ]

let exp a b = b @ a @ [EXP]

let ge a b = b @ a @ [DUP 2; DUP 2; GT; SWAP 2; SWAP 1; EQ; OR]

let gt a b = b @ a @ [GT]

let iszero x = x @ [ISZERO]

let jump dest = [from_int dest; JUMP]

let jumpdest = [JUMPDEST]

let le a b = b @ a @ [DUP 2; DUP 2; LT; SWAP 2; SWAP 1; EQ; OR]

let lt a b = b @ a @ [LT]

let mload ptr = [from_ptr ptr; MLOAD]

let mod' a b = b @ a @ [MOD]

let mstore ptr val' = val' @ [from_ptr ptr; MSTORE]

let mstore_bytes ptr input =
  let input_size = String.length input in
  let rec loop ptr offset result =
    if offset >= input_size then result
    else begin
      let length = min (input_size - offset) 32 in
      let word = bytes32 (String.sub input offset length) in
      loop (ptr + 1) (offset + 32) ([word; from_ptr ptr; MSTORE] :: result)
    end
  in
  loop ptr 0 [] |> List.rev |> List.concat

let mul a b = b @ a @ [MUL]

let not' x = x @ [NOT]

let number = [NUMBER]

let or' a b = b @ a @ [OR]

let origin = [ORIGIN]

let pop = [POP]

let return' = function
  | data_ptr, data_size when data_ptr = data_size -> [from_int data_size; DUP 1; RETURN]
  | data_ptr, data_size -> [from_int data_size; from_int data_ptr; RETURN]

let revert = function
  | data_ptr, data_size when data_ptr = data_size -> [from_int data_size; DUP 1; REVERT]
  | data_ptr, data_size -> [from_int data_size; from_int data_ptr; REVERT]

let sha3 = function
  | input_ptr, input_size -> [from_int input_size; from_int input_ptr; SHA3]

let sload key = [from_int key; SLOAD]

let sstore key val' = val' @ [from_int key; SSTORE]

let staticcall ?(gas=0) addr (input_ptr, input_size) (output_ptr, output_size) =
  [
    from_int output_size;
    from_ptr output_ptr;
    from_int input_size;
    from_ptr input_ptr;
    from_addr addr;
    if gas > 0 then from_int gas else GAS;
    STATICCALL (* gas, addr, argsOffset, argsLength, retOffset, retLength *)
  ]

let staticcall_hash160 (input_ptr, input_size) output_ptr =
  staticcall (addr_of_int 0x03) (input_ptr, input_size) (output_ptr, 32)

let staticcall_sha256 (input_ptr, input_size) output_ptr =
  staticcall (addr_of_int 0x02) (input_ptr, input_size) (output_ptr, 32)

let stop = [STOP]

let sub a b = b @ a @ [SUB]

let xor a b = b @ a @ [XOR]
