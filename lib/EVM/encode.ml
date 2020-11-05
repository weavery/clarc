(* This is free and unencumbered software released into the public domain. *)

let rec encode_program program =
  let buffer = Buffer.create (program_size program) in
  encode_program_into_buffer buffer program;
  Buffer.contents buffer

and encode_program_into_buffer buffer program =
  List.iter (encode_block_into_buffer buffer) program

and encode_block block =
  let buffer = Buffer.create (block_size block) in
  encode_block_into_buffer buffer block;
  Buffer.contents buffer

and encode_block_into_buffer buffer (_, block_body) =
  encode_opcodes_into_buffer buffer block_body

and encode_operands = function
  | PUSH (_, s) -> s
  | _ -> ""

and encode_opcodes ops =
  let buffer = Buffer.create (List.length ops) in  (* TODO *)
  encode_opcodes_into_buffer buffer ops;
  Buffer.contents buffer

and encode_opcodes_into_buffer buffer ops =
  let rec encode_loop = function
  | [] -> ()
  | op :: ops -> begin
      let opcode = encode_opcode op |> Char.chr in
      let operands = encode_operands op in
      Buffer.add_char buffer opcode;
      Buffer.add_string buffer operands;
      encode_loop ops
    end
  in
  encode_loop ops

and encode_opcode = function
  | STOP -> 0x00
  | ADD -> 0x01
  | MUL -> 0x02
  | SUB -> 0x03
  | DIV -> 0x04
  | SDIV -> 0x05
  | MOD -> 0x06
  | SMOD -> 0x07
  | ADDMOD -> 0x08
  | MULMOD -> 0x09
  | EXP -> 0x0A
  | SIGNEXTEND -> 0x0B
  | LT -> 0x10
  | GT -> 0x11
  | SLT -> 0x12
  | SGT -> 0x13
  | EQ -> 0x14
  | ISZERO -> 0x15
  | AND -> 0x16
  | OR -> 0x17
  | XOR -> 0x18
  | NOT -> 0x19
  | BYTE -> 0x1A
  | SHL -> 0x1B
  | SHR -> 0x1C
  | SAR -> 0x1D
  | SHA3 -> 0x20
  | ADDRESS -> 0x30
  | BALANCE -> 0x31
  | ORIGIN -> 0x32
  | CALLER -> 0x33
  | CALLVALUE -> 0x34
  | CALLDATALOAD -> 0x35
  | CALLDATASIZE -> 0x36
  | CALLDATACOPY -> 0x37
  | CODESIZE -> 0x38
  | CODECOPY -> 0x39
  | GASPRICE -> 0x3A
  | EXTCODESIZE -> 0x3B
  | EXTCODECOPY -> 0x3C
  | RETURNDATASIZE -> 0x3D
  | RETURNDATACOPY -> 0x3E
  | EXTCODEHASH -> 0x3F
  | BLOCKHASH -> 0x40
  | COINBASE -> 0x41
  | TIMESTAMP -> 0x42
  | NUMBER -> 0x43
  | DIFFICULTY -> 0x44
  | GASLIMIT -> 0x45
  | POP -> 0x50
  | MLOAD -> 0x51
  | MSTORE -> 0x52
  | MSTORE8 -> 0x53
  | SLOAD -> 0x54
  | SSTORE -> 0x55
  | JUMP -> 0x56
  | JUMPI -> 0x57
  | PC -> 0x58
  | MSIZE -> 0x59
  | GAS -> 0x5A
  | JUMPDEST -> 0x5B
  | PUSH (0, _) -> unreachable ()
  | PUSH (n, _) -> 0x60 + n - 1
  | DUP n -> 0x80 + n - 1
  | SWAP n -> 0x90 + n - 1
  | LOG0 -> 0xA0
  | LOG1 -> 0xA1
  | LOG2 -> 0xA2
  | LOG3 -> 0xA3
  | LOG4 -> 0xA4
  | CREATE -> 0xF0
  | CALL -> 0xF1
  | CALLCODE -> 0xF2
  | RETURN -> 0xF3
  | DELEGATECALL -> 0xF4
  | CREATE2 -> 0xF5
  | STATICCALL -> 0xFA
  | REVERT -> 0xFD
  | INVALID -> 0xFE
  | SELFDESTRUCT -> 0xFF
