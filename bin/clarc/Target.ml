(* This is free and unencumbered software released into the public domain. *)

type t =
  | Auto
  | Bytecode
  | Opcode
  | Debug

let of_string = function
  | "auto" -> Ok Auto
  | "bytecode" -> Ok Bytecode
  | "opcode" -> Ok Opcode
  | "debug" -> Ok Debug
  | _ -> Error (`Msg "invalid output format")

let to_string = function
  | Auto -> "auto"
  | Bytecode -> "bytecode"
  | Opcode -> "opcode"
  | Debug -> "debug"
