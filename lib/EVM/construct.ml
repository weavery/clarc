(* This is free and unencumbered software released into the public domain. *)

let from_string s =
  PUSH (String.length s, s)

let rec from_big_int z =
  match Big_int.int_of_big_int_opt z with
  | Some z -> from_int z
  | None -> PUSH (32, ABI.encode_bigint_as_uint256 z)

and from_int z =
  if z < 0 then unimplemented "encoding of negative integers"  (* FIXME *)
  else if z <= 0xFF then PUSH (1, Char.chr z |> String.make 1)
  else PUSH (32, ABI.encode_int_as_uint256 z)

let zero = from_int 0

let one = from_int 1

let two = from_int 2
