(* This is free and unencumbered software released into the public domain. *)

module Feature : sig
  type t =
    | None
    | NoDeploy

  val of_string : string -> (t, [ `Msg of string ]) result
  val to_string : t -> string
end
