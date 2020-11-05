(* This is free and unencumbered software released into the public domain. *)

module ABI : sig
  val encode_function : string -> string list -> string
  val encode_function_signature : string -> string
end
