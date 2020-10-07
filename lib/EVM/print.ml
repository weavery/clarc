(* This is free and unencumbered software released into the public domain. *)

let rec print_program_as_bytecode ppf program =
  List.iter (print_block_as_bytecode ppf) program

and print_program_as_opcode ppf program =
  List.iter (print_block_as_opcode ppf) program

and print_block_as_bytecode ppf block =
  let bytecode = encode_block block in
  let print_byte b = Format.fprintf ppf "%02x@," @@ Char.code b in
  String.iter print_byte bytecode

and print_block_as_opcode ppf = function
  | (_, []) -> ()
  | (_, block_body) -> print_opcodes ppf block_body

and print_opcodes ppf ops =
  let open Format in
  pp_print_list ~pp_sep:pp_print_space print_opcode ppf ops

and print_opcode ppf op =
  Format.fprintf ppf "%s" @@ to_string op

and print_operand ppf s =
  Format.pp_print_string ppf "0x";
  String.iter (fun b -> Format.fprintf ppf "%02x" (Char.code b)) s

and to_string = function
  | STOP -> "STOP"
  | ADD -> "ADD"
  | MUL -> "MUL"
  | SUB -> "SUB"
  | DIV -> "DIV"
  | SDIV -> "SDIV"
  | MOD -> "MOD"
  | SMOD -> "SMOD"
  | ADDMOD -> "ADDMOD"
  | MULMOD -> "MULMOD"
  | EXP -> "EXP"
  | SIGNEXTEND -> "SIGNEXTEND"
  | LT -> "LT"
  | GT -> "GT"
  | SLT -> "SLT"
  | SGT -> "SGT"
  | EQ -> "EQ"
  | ISZERO -> "ISZERO"
  | AND -> "AND"
  | OR -> "OR"
  | XOR -> "XOR"
  | NOT -> "NOT"
  | BYTE -> "BYTE"
  | SHL -> "SHL"
  | SHR -> "SHR"
  | SAR -> "SAR"
  | SHA3 -> "SHA3"
  | ADDRESS -> "ADDRESS"
  | BALANCE -> "BALANCE"
  | ORIGIN -> "ORIGIN"
  | CALLER -> "CALLER"
  | CALLVALUE -> "CALLVALUE"
  | CALLDATALOAD -> "CALLDATALOAD"
  | CALLDATASIZE -> "CALLDATASIZE"
  | CALLDATACOPY -> "CALLDATACOPY"
  | CODESIZE -> "CODESIZE"
  | CODECOPY -> "CODECOPY"
  | GASPRICE -> "GASPRICE"
  | EXTCODESIZE -> "EXTCODESIZE"
  | EXTCODECOPY -> "EXTCODECOPY"
  | RETURNDATASIZE -> "RETURNDATASIZE"
  | RETURNDATACOPY -> "RETURNDATACOPY"
  | EXTCODEHASH -> "EXTCODEHASH"
  | BLOCKHASH -> "BLOCKHASH"
  | COINBASE -> "COINBASE"
  | TIMESTAMP -> "TIMESTAMP"
  | NUMBER -> "NUMBER"
  | DIFFICULTY -> "DIFFICULTY"
  | GASLIMIT -> "GASLIMIT"
  | POP -> "POP"
  | MLOAD -> "MLOAD"
  | MSTORE -> "MSTORE"
  | MSTORE8 -> "MSTORE8"
  | SLOAD -> "SLOAD"
  | SSTORE -> "SSTORE"
  | JUMP -> "JUMP"
  | JUMPI -> "JUMPI"
  | PC -> "PC"
  | MSIZE -> "MSIZE"
  | GAS -> "GAS"
  | JUMPDEST -> "JUMPDEST"
  | PUSH (n, s) -> begin
      let buffer = Buffer.create (2 * (String.length s)) in
      let ppf = Format.formatter_of_buffer buffer in
      print_operand ppf s;
      Format.pp_print_flush ppf ();
      Format.sprintf "PUSH%d %s" n (Buffer.contents buffer)
    end
  | DUP n -> Format.sprintf "DUP%d" n
  | SWAP n -> Format.sprintf "SWAP%d" n
  | LOG0 -> "LOG0"
  | LOG1 -> "LOG1"
  | LOG2 -> "LOG2"
  | LOG3 -> "LOG3"
  | LOG4 -> "LOG4"
  | CREATE -> "CREATE"
  | CALL -> "CALL"
  | CALLCODE -> "CALLCODE"
  | RETURN -> "RETURN"
  | DELEGATECALL -> "DELEGATECALL"
  | CREATE2 -> "CREATE2"
  | STATICCALL -> "STATICCALL"
  | REVERT -> "REVERT"
  | INVALID -> "INVALID"
  | SELFDESTRUCT -> "SELFDESTRUCT"
