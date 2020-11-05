(* This is free and unencumbered software released into the public domain. *)

module ABI = struct
  type t =
    | Address of string
    | Bool of bool
    | Bytes32 of string
    | Uint of int
    | Uint256 of Big_int.big_int

  let keccak256 = Cryptokit.hash_string (Cryptokit.Hash.keccak 256)

  let rec encode_with_signature signature args =
    let selector = encode_function_signature signature in
    encode_with_selector selector args

  and encode_with_selector selector args =
    let buffer = Buffer.create 32 in
    Buffer.add_string buffer selector;
    let append_arg arg = Buffer.add_string buffer (encode_parameter arg) in
    List.iter append_arg args;
    Buffer.contents buffer

  and encode_function_prototype name params =
    let params = String.concat "," params in
    let signature = Printf.sprintf "%s(%s)" name params in
    encode_function_signature signature

  and encode_function_signature signature =
    String.sub (keccak256 signature) 0 4

  and encode_parameter = function
    | Address s -> encode_address_as_bytes32 s
    | Bool b -> encode_int_as_uint256 (if b then 1 else 0)
    | Bytes32 s -> encode_string_as_bytes32 s
    | Uint z -> encode_int_as_uint256 z
    | Uint256 z -> encode_bigint_as_uint256 z

  and encode_address_as_bytes32 s =
    begin match String.length s with
    | 20 ->
      let buffer = Buffer.create 32 in
      for _ = 1 to 12 do Buffer.add_char buffer '\x00' done;
      Buffer.add_string buffer s;
      Buffer.contents buffer
    | _ -> failwith "invalid address"
    end

  and encode_string_as_bytes32 s =
    begin match String.length s with
    | 32 -> s
    | len when len > 32 -> failwith "invalid inline string"
    | len ->
      let buffer = Buffer.create 32 in
      Buffer.add_string buffer s;
      for _ = 1 to 32 - len do Buffer.add_char buffer '\x00' done;
      Buffer.contents buffer
    end

  and encode_int_as_uint256 z =
    encode_int64_as_uint256 (Int64.of_int z)

  and encode_int32_as_uint256 z =
    encode_int64_as_uint256 (Int64.of_int32 z)

  and encode_int64_as_uint256 z =
    let buffer = Buffer.create 32 in
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer 0L;
    Buffer.add_int64_be buffer z;
    Buffer.contents buffer

  and encode_bigint_as_uint256 z =
    match Big_int.int64_of_big_int_opt z with
    | Some z -> encode_int64_as_uint256 z
    | None -> unimplemented ""  (* TODO *)
end
