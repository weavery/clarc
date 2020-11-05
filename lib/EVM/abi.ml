(* This is free and unencumbered software released into the public domain. *)

module ABI = struct
  let keccak256 = Cryptokit.hash_string (Cryptokit.Hash.keccak 256)

  let rec encode_function name params =
    let params = String.concat "," params in
    let signature = Printf.sprintf "%s(%s)" name params in
    encode_function_signature signature

  and encode_function_signature signature =
    String.sub (keccak256 signature) 0 4

  and encode_int_parameter_as_uint256 z =
    encode_int64_parameter_as_uint256 (Int64.of_int z)

  and encode_int32_parameter_as_uint256 z =
    encode_int64_parameter_as_uint256 (Int64.of_int32 z)

  and encode_int64_parameter_as_uint256 z =
    let buffer = Buffer.create 32 in
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer z;
    Buffer.contents buffer

  and encode_bigint_parameter_as_uint256 z =
    match Big_int.int64_of_big_int_opt z with
    | Some z -> encode_int64_parameter_as_uint256 z
    | None -> unimplemented ""  (* TODO *)
end
