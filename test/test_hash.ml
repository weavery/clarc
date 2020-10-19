(* This is free and unencumbered software released into the public domain. *)

let keccak256 = Cryptokit.hash_string (Cryptokit.Hash.keccak 256)

let keccak () =
  let abc = keccak256 "abc" in
  Alcotest.(check string) "" abc "\x4e\x03\x65\x7a\xea\x45\xa9\x4f\xc7\xd4\x7b\xa8\x26\xc8\xd6\x67\xc0\xd1\xe6\xe3\x3a\x64\xa0\x36\xec\x44\xf5\x8f\xa1\x2d\x6c\x45"

let () =
  Alcotest.run "Clar2EVM" [
    "function_hash", [
      "keccak", `Quick, keccak;
    ];
  ]
