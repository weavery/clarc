https://docs.blockstack.org/references/language-functions

and: For two parameters.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (and true false))
  > EOF
  PUSH1 0x00 PUSH1 0x01 AND PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

as-contract:

as-max-len?:

at-block: Not implemented yet.

begin:

contract-call?: Not implemented yet.

contract-of: Not implemented yet.

get:

get-block-info?: Not implemented yet.

if:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (if true 5 7))
  > EOF
  PUSH1 0x01 ISZERO PC PUSH1 0x0c ADD JUMPI PUSH1 0x05 PC PUSH1 0x08 ADD JUMP
  JUMPDEST PUSH1 0x07 JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

impl-trait: Not implemented yet.

let:

match:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (match (some 3) x 5 7))
  > EOF
  PUSH1 0x03 PUSH1 0x01 ISZERO ISZERO PC PUSH1 0x0d ADD JUMPI POP PUSH1 0x07 PC
  PUSH1 0x08 ADD JUMP JUMPDEST PUSH1 0x05 JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

or: For two parameters.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (or true false))
  > EOF
  PUSH1 0x00 PUSH1 0x01 OR PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

tuple:

use-trait: Not implemented yet.

var-get:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-data-var counter int 0)
  > (define-read-only (test)
  >   (var-get counter))
  > EOF
  PUSH1 0x00 SLOAD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

var-set:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-data-var counter int 0)
  > (define-public (test)
  >  (begin
  >    (var-set counter 42)
  >    (ok true)))
  > EOF
  PUSH1 0x2a PUSH1 0x00 SSTORE PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP
