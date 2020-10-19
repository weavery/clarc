(* This is free and unencumbered software released into the public domain. *)

let keccak256 input =
  let hash_function = Cryptokit.Hash.keccak 256 in
  let hash = Cryptokit.hash_string hash_function input in
  String.sub hash 0 4

let keccak () =
  Alcotest.(check string) "" (keccak256 "abc") "\x4e\x03\x65\x7a";
  Alcotest.(check string) "" (keccak256 "getCounter()") "\x8a\xda\x06\x6e";
  Alcotest.(check string) "" (keccak256 "increment()") "\xd0\x9d\xe0\x8a";
  Alcotest.(check string) "" (keccak256 "decrement()") "\x2b\xae\xce\xb7"

let () =
  Alcotest.run "Clar2EVM" [
    "function_hash", [
      "keccak", `Quick, keccak;
    ];
  ]
