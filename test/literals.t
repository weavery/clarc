https://docs.blockstack.org/references/language-types

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

int:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 42)
  > EOF
  PUSH1 0x2a PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

uint:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) u42)
  > EOF
  PUSH1 0x2a PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

principal:

buff:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 0x00)
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 0x0000000000000000000000000000000000000000000000000000000000000000)
  > EOF
  PUSH32 0x0000000000000000000000000000000000000000000000000000000000000000
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 0x0102)
  > EOF
  PUSH2 0x0102 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) 0x0102030405060708091011121314151617181920212223242526272829303132)
  > EOF
  PUSH32 0x0102030405060708091011121314151617181920212223242526272829303132
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

string:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) "")
  > EOF
  PUSH1 0x00 PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) "Hello, world!")
  > EOF
  PUSH13 0x48656c6c6f2c20776f726c6421 PUSH1 0x0d PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

list:

tuple:
