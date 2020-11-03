(* This is free and unencumbered software released into the public domain. *)

module Feature = struct
  type t =
    | None
    | NoDeploy
    | OnlyFunction of string

  let of_string s =
    match String.split_on_char '=' s with
    | [] -> Ok None
    | ["no-deploy"] -> Ok NoDeploy
    | ["only-function"; fn] -> Ok (OnlyFunction fn)
    | _ -> Error (`Msg "invalid feature flag")

  let to_string = function
    | None -> ""
    | NoDeploy -> "no-deploy"
    | OnlyFunction fn -> Printf.sprintf "only-function=%s" fn
end
