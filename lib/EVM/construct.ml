(* This is free and unencumbered software released into the public domain. *)

type addr = int

type ptr = int

let from_string s =
  PUSH (String.length s, s)

let rec from_big_int z =
  match Big_int.int_of_big_int_opt z with
  | Some z -> from_int z
  | None -> PUSH (32, ABI.encode_bigint_as_uint256 z)

and from_int z =
  if z < 0 then unimplemented "encoding of negative integers"  (* FIXME *)
  else if z <= 0xFF then PUSH (1, Char.chr z |> String.make 1)
  else PUSH (32, ABI.encode_int_as_uint256 z)

let from_bool b = from_int (if b then 1 else 0)

let from_addr = function
  | addr -> from_int addr

let from_ptr = function
  | ptr -> from_int ptr

let zero = from_int 0

let one = from_int 1

let two = from_int 2

let add a b =
  b @ a @ [ADD]

let and' a b =
  b @ a @ [AND]

let caller = [CALLER]

let div a b =
  b @ a @ [DIV]

let exp a b =
  b @ a @ [EXP]

let ge a b =
  b @ a @ [DUP 2; DUP 2; GT; SWAP 2; SWAP 1; EQ; OR]

let gt a b =
  b @ a @ [GT]

let iszero x =
  x @ [ISZERO]

let jump dest =
  [from_int dest; JUMP]

let jumpdest = [JUMPDEST]

let le a b =
  b @ a @ [DUP 2; DUP 2; LT; SWAP 2; SWAP 1; EQ; OR]

let lt a b =
  b @ a @ [LT]

let mload ptr =
  [from_ptr ptr; MLOAD]

let mod' a b =
  b @ a @ [MOD]

let mstore ptr val' =
  val' @ [from_ptr ptr; MSTORE]

let mul a b =
  b @ a @ [MUL]

let number = [NUMBER]

let or' a b =
  b @ a @ [OR]

let origin = [ORIGIN]

let pop = [POP]

let sha3 input_ptr input_size =
  [from_int input_size; from_int input_ptr; SHA3]

let sload key =
  [from_int key; SLOAD]

let sstore key val' =
  val' @ [from_int key; SSTORE]

let staticcall ?(gas=0) addr input_ptr input_size output_ptr output_size =
  [
    from_int output_size;
    from_ptr output_ptr;
    from_int input_size;
    from_ptr input_ptr;
    from_addr addr;
    if gas > 0 then from_int gas else GAS;
    STATICCALL (* gas, addr, argsOffset, argsLength, retOffset, retLength *)
  ]

let staticcall_hash160 input_ptr input_size output_ptr =
  staticcall 0x03 input_ptr input_size output_ptr 32

let staticcall_sha256 input_ptr input_size output_ptr =
  staticcall 0x02 input_ptr input_size output_ptr 32

let stop = [STOP]

let sub a b =
  b @ a @ [SUB]

let xor a b =
  b @ a @ [XOR]
