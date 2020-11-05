(* This is free and unencumbered software released into the public domain. *)

(* See: https://docs.soliditylang.org/en/develop/abi-spec.html *)
module ABI : sig
  (* See: https://docs.soliditylang.org/en/develop/types.html *)
  type t =
    | Address of string
    | Bool of bool
    | Bytes32 of string
    | Uint of int
    | Uint256 of Big_int.big_int

  val encode_with_signature : string -> t list -> string
  val encode_with_selector : string -> t list -> string
  val encode_function_prototype : string -> string list -> string
  val encode_function_signature : string -> string
  val encode_parameter : t -> string
  val encode_address_as_bytes32 : string -> string
  val encode_string_as_bytes32 : string -> string
  val encode_int_as_uint256 : int -> string
  val encode_int32_as_uint256 : int32 -> string
  val encode_int64_as_uint256 : int64 -> string
  val encode_bigint_as_uint256 : Big_int.big_int -> string
end
