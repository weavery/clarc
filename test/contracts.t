counter.clar:

  $ clarc -t opcode ../../../../../etc/examples/counter.clar
  PUSH1 0x00 PUSH1 0x00 SSTORE PUSH1 0x66 DUP1 PUSH1 0x10 PUSH1 0x00 CODECOPY
  PUSH1 0x00 RETURN PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1
  PUSH4 0x8ada066e EQ PUSH1 0x28 JUMPI DUP1 PUSH4 0xd09de08a EQ PUSH1 0x38
  JUMPI DUP1 PUSH4 0x2baeceb7 EQ PUSH1 0x4f JUMPI STOP JUMPDEST POP PUSH1 0x00
  SLOAD PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP JUMPDEST
  POP PUSH1 0x01 PUSH1 0x00 SLOAD ADD PUSH1 0x00 SSTORE PUSH1 0x00 SLOAD
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP JUMPDEST POP PUSH1 0x01
  PUSH1 0x00 SLOAD SUB PUSH1 0x00 SSTORE PUSH1 0x00 SLOAD PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

kv-store.clar:

  $ clarc -t opcode ../../../../../etc/examples/kv-store.clar
  PUSH1 0x00 PUSH1 0x00 SSTORE PUSH1 0x6a DUP1 PUSH1 0x10 PUSH1 0x00 CODECOPY
  PUSH1 0x00 RETURN PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1
  PUSH4 0x3ccc0522 EQ PUSH1 0x1e JUMPI DUP1 PUSH4 0x6435c3e7 EQ PUSH1 0x50
  JUMPI STOP JUMPDEST POP CALLER SLOAD DUP1 ISZERO NOT ISZERO ISZERO PC
  PUSH1 0x0f ADD JUMPI POP PUSH1 0x00 PUSH1 0x00 PC PUSH1 0x15 ADD JUMP
  JUMPDEST PUSH1 0x80 PUSH1 0x02 EXP MUL PUSH1 0x80 PUSH1 0x02 EXP SWAP1 DIV
  PUSH1 0x01 JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
  JUMPDEST POP PUSH1 0x64 PUSH1 0x80 PUSH1 0x02 EXP MUL PUSH1 0x07 OR ORIGIN
  SSTORE PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

panic.clar:

  $ clarc -t opcode ../../../../../etc/examples/panic.clar
  PUSH1 0x00 PUSH1 0x00 SSTORE PUSH1 0x62 DUP1 PUSH1 0x10 PUSH1 0x00 CODECOPY
  PUSH1 0x00 RETURN PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1
  PUSH4 0xc2187034 EQ PUSH1 0x3a JUMPI DUP1 PUSH4 0x4700d305 EQ PUSH1 0x4f
  JUMPI STOP JUMPDEST PUSH1 0x00 SLOAD DUP1 ISZERO ISZERO PC PUSH1 0x0f ADD
  JUMPI POP PUSH1 0x00 DUP1 REVERT PC PUSH1 0x07 ADD JUMP JUMPDEST SLOAD
  JUMPDEST SWAP1 JUMP STOP JUMPDEST POP PC PUSH1 0x07 ADD PUSH1 0x1e JUMP
  JUMPDEST PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
  JUMPDEST POP PC PUSH1 0x07 ADD PUSH1 0x1e JUMP JUMPDEST PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP
