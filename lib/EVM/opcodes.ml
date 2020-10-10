(* This is free and unencumbered software released into the public domain. *)

type contract = program * program

and program = block list

and block = int * opcode list

and opcode =
  (* 0x00s: Stop & Arithmetic Operations *)
  | STOP
  | ADD
  | MUL
  | SUB
  | DIV
  | SDIV
  | MOD
  | SMOD
  | ADDMOD
  | MULMOD
  | EXP
  | SIGNEXTEND

  (* 0x10s: Comparison & Bitwise Logic Operations *)
  | LT
  | GT
  | SLT
  | SGT
  | EQ
  | ISZERO
  | AND
  | OR
  | XOR
  | NOT
  | BYTE
  | SHL  (* EIP-145 *)
  | SHR  (* EIP-145 *)
  | SAR  (* EIP-145 *)

  (* 0x20s: SHA3 *)
  | SHA3

  (* 0x30s: Environmental Information *)
  | ADDRESS
  | BALANCE
  | ORIGIN
  | CALLER
  | CALLVALUE
  | CALLDATALOAD
  | CALLDATASIZE
  | CALLDATACOPY
  | CODESIZE
  | CODECOPY
  | GASPRICE
  | EXTCODESIZE
  | EXTCODECOPY
  | RETURNDATASIZE  (* EIP-211 *)
  | RETURNDATACOPY  (* EIP-211 *)
  | EXTCODEHASH  (* EIP-1052 *)

  (* 0x40s: Block Information *)
  | BLOCKHASH
  | COINBASE
  | TIMESTAMP
  | NUMBER
  | DIFFICULTY
  | GASLIMIT

  (* 0x50s: Stack, Memory, Storage, and Flow Operations *)
  | POP
  | MLOAD
  | MSTORE
  | MSTORE8
  | SLOAD
  | SSTORE
  | JUMP
  | JUMPI
  | PC
  | MSIZE
  | GAS
  | JUMPDEST

  (* 0x60-70s: Push Operations *)
  | PUSH of int * string

  (* 0x80s: Duplication Operations *)
  | DUP of int

  (* 0x90s: Exchange Operations *)
  | SWAP of int

  (* 0xA0s: Logging Operations *)
  | LOG0
  | LOG1
  | LOG2
  | LOG3
  | LOG4

  (* 0xF0s: System Operations *)
  | CREATE
  | CALL
  | CALLCODE
  | RETURN
  | DELEGATECALL
  | CREATE2  (* EIP-1014 *)
  | STATICCALL  (* EIP-214 *)
  | REVERT  (* EIP-140 *)
  | INVALID  (* EIP-141 *)
  | SELFDESTRUCT
