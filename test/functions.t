var-get:

  $ clarc -t opcode -f no-deploy <<EOF
  > (define-data-var counter int 0)
  > (define-read-only (test-var-get)
  >   (var-get counter))
  > EOF
  PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1 PUSH4 0xbdc1c1c9
  EQ PUSH1 0x14 JUMPI STOP JUMPDEST POP PUSH1 0x00 SLOAD PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

var-set:

  $ clarc -t opcode -f no-deploy <<EOF
  > (define-data-var counter int 0)
  > (define-public (test-var-set)
  >  (begin
  >    (var-set counter 42)
  >    (ok true)))
  > EOF
  PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1 PUSH4 0x63746095
  EQ PUSH1 0x14 JUMPI STOP JUMPDEST POP PUSH1 0x2a PUSH1 0x00 SSTORE PUSH1 0x01
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
