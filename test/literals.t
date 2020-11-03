none:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) none)
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

false:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) false)
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

true:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) true)
  > EOF
  PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

integer:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 42)
  > EOF
  PUSH1 0x2a PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
