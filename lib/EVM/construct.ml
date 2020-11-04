(* This is free and unencumbered software released into the public domain. *)

let from_string s =
  PUSH (String.length s, s)

let rec from_big_int z =
  match Big_int.int_of_big_int_opt z with
  | Some z -> from_int z
  | None -> failwith "not implemented yet"  (* TODO *)

and from_int z =
  if z < 0 then failwith "not implemented yet"  (* TODO *)
  else if z <= 0xFF then PUSH (1, Char.chr z |> String.make 1)
  else failwith "not implemented yet"  (* TODO *)

let zero = from_int 0

let one = from_int 1
