(* This is free and unencumbered software released into the public domain. *)

let unreachable () = failwith "unreachable"

let unimplemented what =
  let message =
    if what = "" then "not implemented yet"
    else Printf.sprintf "%s not implemented yet" what
  in
  failwith message

let unsupported what =
  let message =
    if what = "" then "not supported"
    else Printf.sprintf "%s not supported" what
  in
  failwith message
