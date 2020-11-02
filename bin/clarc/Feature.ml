(* This is free and unencumbered software released into the public domain. *)

type t =
  | None
  | NoDeploy

let of_string = function
  | "" -> Ok None
  | "no-deploy" -> Ok NoDeploy
  | _ -> Error (`Msg "invalid feature flag")

let to_string = function
  | None -> ""
  | NoDeploy -> "no-deploy"
