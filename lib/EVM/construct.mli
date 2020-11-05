(* This is free and unencumbered software released into the public domain. *)

val zero : opcode

val one : opcode

val two : opcode

val from_big_int : Big_int.big_int -> opcode

val from_int : int -> opcode

val from_string : string -> opcode
