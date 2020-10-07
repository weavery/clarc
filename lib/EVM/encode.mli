(* This is free and unencumbered software released into the public domain. *)

val encode_program : program -> string

val encode_program_into_buffer : Buffer.t -> program -> unit

val encode_block : block -> string

val encode_block_into_buffer : Buffer.t -> block -> unit

val encode_opcodes : opcode list -> string

val encode_opcodes_into_buffer : Buffer.t -> opcode list -> unit

val encode_opcode : opcode -> int
