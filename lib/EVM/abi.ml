(* This is free and unencumbered software released into the public domain. *)

module ABI = struct
  type type' =
    | Address
    | Bool
    | Bytes32
    | BytesN of int
    | Int128
    | Int256
    | Uint128
    | Uint256

  type word =
    | AddressVal of string
    | BoolVal of bool
    | Bytes32Val of string
    | BytesNVal of int * string
    | IntVal of int
    | Int128Val of Big_int.big_int
    | Int256Val of Big_int.big_int
    | UintVal of int
    | Uint128Val of Big_int.big_int
    | Uint256Val of Big_int.big_int

  let keccak256 = Cryptokit.hash_string (Cryptokit.Hash.keccak 256)

  let type_of = function
    | AddressVal _ -> Address
    | BoolVal _ -> Bool
    | Bytes32Val _ -> Bytes32
    | BytesNVal (n, _) -> BytesN n
    | IntVal _ -> Int256
    | Int128Val _ -> Int128
    | Int256Val _ -> Int256
    | UintVal _ -> Uint256
    | Uint128Val _ -> Uint128
    | Uint256Val _ -> Uint256

  and type_to_string = function
    | Address -> "address"
    | Bool -> "bool"
    | Bytes32 -> "bytes32"
    | BytesN n -> Printf.sprintf "bytes%d" n
    | Int128 -> "int128"
    | Int256 -> "int256"
    | Uint128 -> "uint128"
    | Uint256 -> "uint256"

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
    let params = String.concat "," (List.map type_to_string params) in
    let signature = Printf.sprintf "%s(%s)" name params in
    encode_function_signature signature

  and encode_function_signature signature =
    String.sub (keccak256 signature) 0 4

  and encode_parameter = function
    | AddressVal s -> encode_address_as_bytes32 s
    | BoolVal b -> encode_int_as_uint256 (if b then 1 else 0)
    | Bytes32Val s -> encode_string_as_bytes32 s
    | BytesNVal (_, s) -> encode_string_as_bytes32 s
    | IntVal z | UintVal z -> encode_int_as_uint256 z
    | Int128Val z | Uint128Val z -> encode_bigint_as_uint256 z
    | Int256Val z | Uint256Val z -> encode_bigint_as_uint256 z

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
