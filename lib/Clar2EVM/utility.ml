(* This is free and unencumbered software released into the public domain. *)

let unreachable () = failwith "unreachable"

let unimplemented what = failwith (Printf.sprintf "%s not implemented yet" what)

let unsupported what = failwith (Printf.sprintf "%s not supported" what)

let rec last = function
  | [] -> None
  | [x] -> Some x
  | _ :: tl -> last tl
