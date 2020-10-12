(* This is free and unencumbered software released into the public domain. *)

val print_program_as_bytecode : Format.formatter -> program -> unit

val print_program_as_opcode : Format.formatter -> program -> unit

val print_opcodes : Format.formatter -> opcode list -> unit

val print_opcode : Format.formatter -> opcode -> unit

val to_string : opcode -> string
