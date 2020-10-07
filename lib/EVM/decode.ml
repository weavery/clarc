(* This is free and unencumbered software released into the public domain. *)

let rec decode input =
  let length = String.length input in
  let rec decode_loop index =
    if index = length then []
    else begin
      let byte = String.get input index |> Char.code in
      let (pc', op) = match decode_opcode byte with
      | PUSH (n, _) -> (1 + n, PUSH (n, (String.sub input (index + 1) n)))
      | op -> (1, op)
      in
      [op] @ decode_loop (index + pc')
    end
  in
  [(0, decode_loop 0)]  (* FIXME *)

and decode_opcodes input =
  match decode input with [(_, ops)] -> ops | _ -> []  (* FIXME *)

and decode_opcode = function
  | 0x00 -> STOP
  | 0x01 -> ADD
  | 0x02 -> MUL
  | 0x03 -> SUB
  | 0x04 -> DIV
  | 0x05 -> SDIV
  | 0x06 -> MOD
  | 0x07 -> SMOD
  | 0x08 -> ADDMOD
  | 0x09 -> MULMOD
  | 0x0A -> EXP
  | 0x0B -> SIGNEXTEND
  | 0x10 -> LT
  | 0x11 -> GT
  | 0x12 -> SLT
  | 0x13 -> SGT
  | 0x14 -> EQ
  | 0x15 -> ISZERO
  | 0x16 -> AND
  | 0x17 -> OR
  | 0x18 -> XOR
  | 0x19 -> NOT
  | 0x1A -> BYTE
  | 0x1B -> SHL
  | 0x1C -> SHR
  | 0x1D -> SAR
  | 0x20 -> SHA3
  | 0x30 -> ADDRESS
  | 0x31 -> BALANCE
  | 0x32 -> ORIGIN
  | 0x33 -> CALLER
  | 0x34 -> CALLVALUE
  | 0x35 -> CALLDATALOAD
  | 0x36 -> CALLDATASIZE
  | 0x37 -> CALLDATACOPY
  | 0x38 -> CODESIZE
  | 0x39 -> CODECOPY
  | 0x3A -> GASPRICE
  | 0x3B -> EXTCODESIZE
  | 0x3C -> EXTCODECOPY
  | 0x3D -> RETURNDATASIZE
  | 0x3E -> RETURNDATACOPY
  | 0x3F -> EXTCODEHASH
  | 0x40 -> BLOCKHASH
  | 0x41 -> COINBASE
  | 0x42 -> TIMESTAMP
  | 0x43 -> NUMBER
  | 0x44 -> DIFFICULTY
  | 0x45 -> GASLIMIT
  | 0x50 -> POP
  | 0x51 -> MLOAD
  | 0x52 -> MSTORE
  | 0x53 -> MSTORE8
  | 0x54 -> SLOAD
  | 0x55 -> SSTORE
  | 0x56 -> JUMP
  | 0x57 -> JUMPI
  | 0x58 -> PC
  | 0x59 -> MSIZE
  | 0x5A -> GAS
  | 0x5B -> JUMPDEST
  | 0x60 -> PUSH (1, "")
  | 0x61 -> PUSH (2, "")
  | 0x62 -> PUSH (3, "")
  | 0x63 -> PUSH (4, "")
  | 0x64 -> PUSH (5, "")
  | 0x65 -> PUSH (6, "")
  | 0x66 -> PUSH (7, "")
  | 0x67 -> PUSH (8, "")
  | 0x68 -> PUSH (9, "")
  | 0x69 -> PUSH (10, "")
  | 0x6A -> PUSH (11, "")
  | 0x6B -> PUSH (12, "")
  | 0x6C -> PUSH (13, "")
  | 0x6D -> PUSH (14, "")
  | 0x6E -> PUSH (15, "")
  | 0x6F -> PUSH (16, "")
  | 0x70 -> PUSH (17, "")
  | 0x71 -> PUSH (18, "")
  | 0x72 -> PUSH (19, "")
  | 0x73 -> PUSH (20, "")
  | 0x74 -> PUSH (21, "")
  | 0x75 -> PUSH (22, "")
  | 0x76 -> PUSH (23, "")
  | 0x77 -> PUSH (24, "")
  | 0x78 -> PUSH (25, "")
  | 0x79 -> PUSH (26, "")
  | 0x7A -> PUSH (27, "")
  | 0x7B -> PUSH (28, "")
  | 0x7C -> PUSH (29, "")
  | 0x7D -> PUSH (30, "")
  | 0x7E -> PUSH (31, "")
  | 0x7F -> PUSH (32, "")
  | 0x80 -> DUP 1
  | 0x81 -> DUP 2
  | 0x82 -> DUP 3
  | 0x83 -> DUP 4
  | 0x84 -> DUP 5
  | 0x85 -> DUP 6
  | 0x86 -> DUP 7
  | 0x87 -> DUP 8
  | 0x88 -> DUP 9
  | 0x89 -> DUP 10
  | 0x8A -> DUP 11
  | 0x8B -> DUP 12
  | 0x8C -> DUP 13
  | 0x8D -> DUP 14
  | 0x8E -> DUP 15
  | 0x8F -> DUP 16
  | 0x90 -> SWAP 1
  | 0x91 -> SWAP 2
  | 0x92 -> SWAP 3
  | 0x93 -> SWAP 4
  | 0x94 -> SWAP 5
  | 0x95 -> SWAP 6
  | 0x96 -> SWAP 7
  | 0x97 -> SWAP 8
  | 0x98 -> SWAP 9
  | 0x99 -> SWAP 10
  | 0x9A -> SWAP 11
  | 0x9B -> SWAP 12
  | 0x9C -> SWAP 13
  | 0x9D -> SWAP 14
  | 0x9E -> SWAP 15
  | 0x9F -> SWAP 16
  | 0xA0 -> LOG0
  | 0xA1 -> LOG1
  | 0xA2 -> LOG2
  | 0xA3 -> LOG3
  | 0xA4 -> LOG4
  | 0xF0 -> CREATE
  | 0xF1 -> CALL
  | 0xF2 -> CALLCODE
  | 0xF3 -> RETURN
  | 0xF4 -> DELEGATECALL
  | 0xF5 -> CREATE2
  | 0xFA -> STATICCALL
  | 0xFD -> REVERT
  | 0xFE -> INVALID
  | 0xFF -> SELFDESTRUCT
  | x -> failwith (Printf.sprintf "invalid opcode: 0x%x" x)
