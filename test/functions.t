https://docs.blockstack.org/references/language-functions

+: For two parameters. Without overflow checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (+ 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 ADD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

-: For two parameters. Without underflow checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (- 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 SUB PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

*: For two parameters. Without overflow checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (* 6 7))
  > EOF
  PUSH1 0x07 PUSH1 0x06 MUL PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

/: For two parameters. Without division-by-zero checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (/ 6 3))
  > EOF
  PUSH1 0x03 PUSH1 0x06 DIV PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

<:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (< 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 LT PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

<=:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (<= 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 DUP2 DUP2 LT SWAP2 SWAP1 EQ OR PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

>:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (> 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 GT PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

>=:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (>= 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 DUP2 DUP2 GT SWAP2 SWAP1 EQ OR PUSH1 0x00 MSTORE
  PUSH1 0x20 PUSH1 0x00 RETURN STOP

append:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (append (list 5 6 7) 8))
  > EOF
  PUSH1 0x05 PUSH1 0x06 PUSH1 0x07 PUSH1 0x03 POP PUSH1 0x08 PUSH1 0x04
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

asserts!:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (asserts! false (err 7)))
  > EOF
  PUSH1 0x00 ISZERO PC PUSH1 0x0c ADD JUMPI PUSH1 0x01 PC PUSH1 0x0a ADD JUMP
  JUMPDEST PUSH1 0x00 DUP1 REVERT JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

concat:

default-to:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (default-to 7 none))
  > EOF
  PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x08 ADD JUMP JUMPDEST
  PUSH1 0x07 JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (default-to 7 (some 9)))
  > EOF
  PUSH1 0x09 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x08 ADD JUMP
  JUMPDEST PUSH1 0x07 JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

err:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (err 5))
  > EOF
  PUSH1 0x05 PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (err u5))
  > EOF
  PUSH1 0x05 PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

filter:

fold:

ft-get-balance:

ft-mint?:

ft-transfer?:

hash160:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (hash160 0))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 PUSH1 0x10 PUSH1 0x00
  PUSH1 0x03 GAS STATICCALL POP PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

is-eq: For two parameters.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq true false))
  > EOF
  PUSH1 0x00 PUSH1 0x01 EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq true true))
  > EOF
  PUSH1 0x01 PUSH1 0x01 EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq 7 9))
  > EOF
  PUSH1 0x09 PUSH1 0x07 EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq 9 9))
  > EOF
  PUSH1 0x09 PUSH1 0x09 EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq u9 u9))
  > EOF
  PUSH1 0x09 PUSH1 0x09 EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq 0xAB 0xAB))
  > EOF
  PUSH1 0xab PUSH1 0xab EQ PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-eq true 42))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(is-eq bool int) not supported")
         
  [125]

is-err:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-err (err u5)))
  > EOF
  PUSH1 0x05 PUSH1 0x00 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-err (ok true)))
  > EOF
  PUSH1 0x01 PUSH1 0x01 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-err 42))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(is-err int) not supported")
         
  [125]

is-none:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-none none))
  > EOF
  PUSH1 0x00 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-none (some 5)))
  > EOF
  PUSH1 0x05 PUSH1 0x01 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-none 42))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(is-none int) not supported")
         
  [125]

is-ok:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-ok (err u5)))
  > EOF
  PUSH1 0x05 PUSH1 0x00 ISZERO ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00
  RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-ok (ok true)))
  > EOF
  PUSH1 0x01 PUSH1 0x01 ISZERO ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00
  RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-ok 42))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(is-ok int) not supported")
         
  [125]

is-some:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-some none))
  > EOF
  PUSH1 0x00 ISZERO ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-some (some 5)))
  > EOF
  PUSH1 0x05 PUSH1 0x01 ISZERO ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00
  RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (is-some 42))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(is-some int) not supported")
         
  [125]

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

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (keccak256 (+ 1 2)))
  > EOF
  PUSH1 0x02 PUSH1 0x01 ADD PUSH1 0x00 MSTORE PUSH1 0x10 PUSH1 0x00 SHA3
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (keccak256 true))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(keccak256 bool) not supported")
         
  [125]

len: Only for literals.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (len ""))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (len "Hello, world!"))
  > EOF
  PUSH1 0x0d PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (len 0xDEADBEEF))
  > EOF
  PUSH1 0x04 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (len (list)))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (len (list 1 2 3)))
  > EOF
  PUSH1 0x03 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

list:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (list))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (list 7))
  > EOF
  PUSH1 0x07 PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (list 1 2 3))
  > EOF
  PUSH1 0x01 PUSH1 0x02 PUSH1 0x03 PUSH1 0x03 PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

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

mod: Without division-by-zero checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (mod 5 2))
  > EOF
  PUSH1 0x02 PUSH1 0x05 MOD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

nft-get-owner?:

nft-mint?:

nft-transfer?:

not:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (not false))
  > EOF
  PUSH1 0x00 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (not true))
  > EOF
  PUSH1 0x01 ISZERO PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

ok:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (ok true))
  > EOF
  PUSH1 0x01 PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (ok 5))
  > EOF
  PUSH1 0x05 PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

pow: Without overflow checking.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (pow 2 3))
  > EOF
  PUSH1 0x03 PUSH1 0x02 EXP PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

principal-of?:

print: Only for literals. Without a meaningful return value.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (print 123))
  > EOF
  PUSH1 0x00
  PUSH32 0x4e0c1d1d00000000000000000000000000000000000000000000000000000000
  PUSH1 0x00 MSTORE
  PUSH32 0x0000007b00000000000000000000000000000000000000000000000000000000
  PUSH1 0x01 MSTORE PUSH1 0x00 PUSH1 0x00 PUSH1 0x24 PUSH1 0x00
  PUSH20 0x000000000000000000636f6e736f6c652e6c6f67 GAS STATICCALL POP
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (print "Hello, world!"))
  > EOF
  PUSH1 0x00
  PUSH32 0x41304fac00000000000000000000000000000000000000000000000000000000
  PUSH1 0x00 MSTORE
  PUSH32 0x0000000d48656c6c6f2c20776f726c6421000000000000000000000000000000
  PUSH1 0x01 MSTORE
  PUSH32 0x0000000000000000000000000000000000000000000000000000000000000000
  PUSH1 0x02 MSTORE PUSH1 0x00 PUSH1 0x00 PUSH1 0x44 PUSH1 0x00
  PUSH20 0x000000000000000000636f6e736f6c652e6c6f67 GAS STATICCALL POP
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

secp256k1-recover?: Not implemented yet.

secp256k1-verify: Not implemented yet.

sha256:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (sha256 0))
  > EOF
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 PUSH1 0x10 PUSH1 0x00
  PUSH1 0x02 GAS STATICCALL POP PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  STOP

sha512: Not implemented yet.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (sha512 0))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(sha512 int) not implemented yet")
         
  [125]

sha512/256: Not implemented yet.

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (sha512/256 0))
  > EOF
  clarc: internal error, uncaught exception:
         Failure("(sha512/256 int) not implemented yet")
         
  [125]

some:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (some 5))
  > EOF
  PUSH1 0x05 PUSH1 0x01 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

sqrti: Not implemented yet.

stx-burn?: Not supported.

stx-get-balance: Not supported.

stx-transfer?: Not supported.

to-int:

to-uint:

try!:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (try! none))
  > EOF
  PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x10 ADD JUMP JUMPDEST
  PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN JUMPDEST PUSH1 0x00
  MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (try! (some 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x10 ADD JUMP
  JUMPDEST PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN JUMPDEST
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (try! (err 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x13 ADD JUMP
  JUMPDEST PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x01 MSTORE PUSH1 0x40 PUSH1 0x00
  RETURN JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (try! (ok 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x13 ADD JUMP
  JUMPDEST PUSH1 0x00 PUSH1 0x00 MSTORE PUSH1 0x01 MSTORE PUSH1 0x40 PUSH1 0x00
  RETURN JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

unwrap-err!:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-err! (err 7) 9))
  > EOF
  PUSH1 0x07 PUSH1 0x00 ISZERO PC PUSH1 0x15 ADD JUMPI POP PUSH1 0x09
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN PC PUSH1 0x06 ADD JUMP
  JUMPDEST JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-err! (ok 7) 9))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x15 ADD JUMPI POP PUSH1 0x09
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN PC PUSH1 0x06 ADD JUMP
  JUMPDEST JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

unwrap-err-panic:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-err-panic (err 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x00 ISZERO PC PUSH1 0x0f ADD JUMPI POP PUSH1 0x00 DUP1
  REVERT PC PUSH1 0x06 ADD JUMP JUMPDEST JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-err-panic (ok 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0f ADD JUMPI POP PUSH1 0x00 DUP1
  REVERT PC PUSH1 0x06 ADD JUMP JUMPDEST JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

unwrap!:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap! none 9))
  > EOF
  PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x10 ADD JUMP JUMPDEST
  PUSH1 0x09 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN JUMPDEST PUSH1 0x00
  MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap! (some 7) 9))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x10 ADD JUMP
  JUMPDEST PUSH1 0x09 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN JUMPDEST
  PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap! (err 7) 9))
  > EOF
  PUSH1 0x07 PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x11 ADD JUMP
  JUMPDEST POP PUSH1 0x09 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap! (ok 7) 9))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x11 ADD JUMP
  JUMPDEST POP PUSH1 0x09 PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN
  JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP

unwrap-panic:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-panic none))
  > EOF
  PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x0a ADD JUMP JUMPDEST
  PUSH1 0x00 DUP1 REVERT JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00
  RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-panic (some 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x0a ADD JUMP
  JUMPDEST PUSH1 0x00 DUP1 REVERT JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-panic (err 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x00 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x0b ADD JUMP
  JUMPDEST POP PUSH1 0x00 DUP1 REVERT JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (unwrap-panic (ok 7)))
  > EOF
  PUSH1 0x07 PUSH1 0x01 ISZERO PC PUSH1 0x0a ADD JUMPI PC PUSH1 0x0b ADD JUMP
  JUMPDEST POP PUSH1 0x00 DUP1 REVERT JUMPDEST PUSH1 0x00 MSTORE PUSH1 0x20
  PUSH1 0x00 RETURN STOP

xor:

  $ clarc -t opcode -f only-function=test <<EOF
  > (define-read-only (test) (xor 1 2))
  > EOF
  PUSH1 0x02 PUSH1 0x01 XOR PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP
