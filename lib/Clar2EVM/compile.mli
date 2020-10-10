(* This is free and unencumbered software released into the public domain. *)

val compile_contract : Clarity.program -> EVM.contract

val compile_program : Clarity.program -> EVM.program

val compile_definition : Clarity.definition -> EVM.block

(* val compile_expression : Clarity.expression -> expression *)

(* val compile_type : Clarity.type' -> type' *)
