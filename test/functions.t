var-get:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-data-var counter int 0)
  > (define-read-only (test)
  >   (var-get counter))
  > EOF
  JUMPDEST POP PUSH1 0x00 SLOAD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

var-set:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-data-var counter int 0)
  > (define-public (test)
  >  (begin
  >    (var-set counter 42)
  >    (ok true)))
  > EOF
  JUMPDEST POP PUSH1 0x2a PUSH1 0x00 SSTORE PUSH1 0x01 PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP
