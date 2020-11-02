(* This is free and unencumbered software released into the public domain. *)

val compile_contract : ?features:(Feature.t list) -> Clarity.program -> EVM.contract
