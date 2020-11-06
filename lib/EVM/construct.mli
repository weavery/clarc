(* This is free and unencumbered software released into the public domain. *)

type addr = int

type ptr = int

val zero : opcode

val one : opcode

val two : opcode

val from_big_int : Big_int.big_int -> opcode

val from_bool : bool -> opcode

val from_int : int -> opcode

val from_string : string -> opcode

val from_addr : addr -> opcode

val from_ptr : ptr -> opcode

val add : opcode list -> opcode list -> opcode list

val and' : opcode list -> opcode list -> opcode list

val caller : opcode list

val div : opcode list -> opcode list -> opcode list

val exp : opcode list -> opcode list -> opcode list

val ge : opcode list -> opcode list -> opcode list

val gt : opcode list -> opcode list -> opcode list

val iszero : opcode list -> opcode list

val jump : int -> opcode list

val jumpdest : opcode list

val le : opcode list -> opcode list -> opcode list

val lt : opcode list -> opcode list -> opcode list

val mload : ptr -> opcode list

val mod' : opcode list -> opcode list -> opcode list

val mstore : ptr -> opcode list -> opcode list

val mul : opcode list -> opcode list -> opcode list

val number : opcode list

val or' : opcode list -> opcode list -> opcode list

val origin : opcode list

val pop : opcode list

val sha3 : ptr -> int -> opcode list

val sload : int -> opcode list

val sstore : int -> opcode list -> opcode list

val staticcall : ?gas:int -> addr -> ptr -> int -> ptr -> int -> opcode list

val staticcall_hash160 : ptr -> int -> ptr -> opcode list

val staticcall_sha256 : ptr -> int -> ptr -> opcode list

val stop : opcode list

val sub : opcode list -> opcode list -> opcode list

val xor : opcode list -> opcode list -> opcode list
