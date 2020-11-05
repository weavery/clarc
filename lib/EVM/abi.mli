(* This is free and unencumbered software released into the public domain. *)

module ABI : sig
  val encode_function : string -> string list -> string
  val encode_function_signature : string -> string
  val encode_int_parameter_as_uint256 : int -> string
  val encode_int32_parameter_as_uint256 : int32 -> string
  val encode_int64_parameter_as_uint256 : int64 -> string
  val encode_bigint_parameter_as_uint256 : Big_int.big_int -> string
end
