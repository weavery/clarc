https://docs.blockstack.org/references/language-keywords

block-height:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) block-height)
  > EOF
  NUMBER PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

burn-block-height:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) burn-block-height)
  > EOF
  NUMBER PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

contract-caller:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) contract-caller)
  > EOF
  CALLER PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

is-in-regtest:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) is-in-regtest)
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

stx-liquid-supply: Not supported.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) stx-liquid-supply)
  > EOF
  clarc: internal error, uncaught exception:
         Failure("stx-liquid-supply not supported")
         
  [125]

tx-sender:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) tx-sender)
  > EOF
  ORIGIN PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
