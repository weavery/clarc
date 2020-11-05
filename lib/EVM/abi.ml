(* This is free and unencumbered software released into the public domain. *)

module ABI = struct
  let keccak256 = Cryptokit.hash_string (Cryptokit.Hash.keccak 256)

  let rec encode_function name params =
    let params = String.concat "," params in
    let signature = Printf.sprintf "%s(%s)" name params in
    encode_function_signature signature

  and encode_function_signature signature =
    String.sub (keccak256 signature) 0 4
end
