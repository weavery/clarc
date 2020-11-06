(* This is free and unencumbered software released into the public domain. *)

(* See: https://docs.soliditylang.org/en/develop/abi-spec.html *)
(* See: https://docs.soliditylang.org/en/develop/types.html *)
module ABI : sig
  type type' =
    | Address
    | Bool
    | Bytes32
    | BytesN of int
    | Bytes
    | Int128
    | Int256
    | Uint128
    | Uint256

  type word =
    | AddressVal of string
    | BoolVal of bool
    | Bytes32Val of string
    | BytesNVal of int * string
    | BytesVal of string
    | IntVal of int
    | Int128Val of Big_int.big_int
    | Int256Val of Big_int.big_int
    | UintVal of int
    | Uint128Val of Big_int.big_int
    | Uint256Val of Big_int.big_int

  val type_of : word -> type'
  val type_to_string : type' -> string

  val encode_with_signature : string -> word list -> string
  val encode_with_selector : string -> word list -> string
  val encode_function_prototype : string -> type' list -> string
  val encode_function_signature : string -> string
  val encode_parameter : word -> string
  val encode_address_as_bytes32 : string -> string
  val encode_string_as_bytes32 : string -> string
  val encode_int_as_uint256 : int -> string
  val encode_int32_as_uint256 : int32 -> string
  val encode_int64_as_uint256 : int64 -> string
  val encode_bigint_as_uint256 : Big_int.big_int -> string
end
