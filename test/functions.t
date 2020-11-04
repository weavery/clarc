https://docs.blockstack.org/references/language-functions

add:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (+ 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 ADD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

sub:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (- 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 SUB PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

mul:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (* 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 MUL PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

div:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (/ 6 3))
  > EOF
  PUSH1 0x03 PUSH1 0x06 DIV PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

le:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (<= 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 DUP2 DUP2 LT SWAP2 SWAP1 EQ OR PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

lt:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (< 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 LT PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

ge:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (>= 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 DUP2 DUP2 GT SWAP2 SWAP1 EQ OR PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

gt:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (> 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 GT PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

and:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (and true false))
  > EOF
  PUSH1 0x00 PUSH1 0x01 AND PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

append:

as-contract:

ax-max-len?:

asserts!:

at-block:

begin:

concat:

contract-call?:

contract-of:

default-to:

err:

filter:

fold:

ft-get-balance:

ft-mint?:

ft-transfer?:

get:

get-block-info?:

hash160:

if:

impl-trait:

is-eq:

is-err:

is-none:

is-ok:

is-some:

keccak256:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (keccak256 0x01020304))
  > EOF
  PUSH4 0x01020304 PUSH1 0x00 MSTORE PUSH1 0x04 PUSH1 0x00 SHA3 PUSH1 0x00
  MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (keccak256 0))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x10 PUSH1 0x00 SHA3 PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

len:

let:

list:

map:

map-delete:

map-get?:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-map store ((key principal)) ((val int)))
  > (define-read-only (test)
  >   (map-get? store {key: tx-sender}))
  > EOF
  CALLER SLOAD DUP1 ISZERO NOT PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

map-insert:

map-set:

match:

mod:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (mod 5 2))
  > EOF
  PUSH1 0x02 PUSH1 0x05 MOD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

nft-get-owner?:

nft-mint?:

nft-transfer?:

not:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (not true))
  > EOF
  PUSH1 0x01 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

ok:

or:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (or true false))
  > EOF
  PUSH1 0x00 PUSH1 0x01 OR PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

pow:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (pow 2 3))
  > EOF
  PUSH1 0x03 PUSH1 0x02 EXP PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

principal-of?:

print:

secp256k1-recover?:

secp256k1-verify:

sha256:

sha512:

sha512/256:

some:

sqrti:

stx-burn?:

stx-get-balance:

stx-transfer?:

to-int:

to-uint:

try!:

tuple:

unwrap-err-panic:

unwrap-err!:

unwrap-panic:

unwrap!:

use-trait:

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

xor:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (xor 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 XOR PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
