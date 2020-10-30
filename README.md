# Clarc

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Discord](https://img.shields.io/discord/755852964513579099?label=discord)](https://discord.gg/AvHRCDa)

**Clarc** compiles [Clarity] smart contracts into [Ethereum] virtual machine
(EVM) bytecode.

More specifically, the Clarc compiler, called `clarc`, parses `.clar` files and
compiles them into an equivalent EVM bytecode program that runs on the Ethereum
blockchain.

[![Screencast](https://asciinema.org/a/365265.svg)](https://asciinema.org/a/365265)

*Note: Here be dragons. This is a pre-alpha, work-in-progress
project. Assume nothing works, and you may be pleasantly surprised on
occasion.*

## Installation

We are working on building release binaries for Windows, macOS, and Linux.
They will be available here later.

In the meantime, if you wish to try out Clarc, you will need to build it from
source code yourself, which entails setting up an OCaml development
environment.

For the impatient and adventurous, reserve at least an hour of time and
[see further down](#development) in this document for the particulars.

## Usage

To view Clarc's built-in man page that documents all command-line options, run:

```bash
clarc --help
```

![Manpage](https://github.com/weavery/clarc/blob/master/etc/manpage.jpg)

## Examples

### Supported Contracts

The currently tested contracts, deployed to the public [Ropsten] testnet, are:

| Contract ID | Contract Code | Contract Bytecode | Contract ABI |
| :---------- | :------------ | :---------------- | :----------- |
| [0x8a90b1e93020933295b3bd4ce2317062319351d4] | [`counter.clar`] | [`counter.bin`] | [`counter.json`] |
| [0x2e2487c64b1420111e8d66d751f75f69515c5476] | [`kv-store.clar`] | [`kv-store.bin`] | [`kv-store.json`] |
| [0x9a1b29fc432af1e37af03ed2fee00d742ff7372f] | [`panic.clar`] | [`panic.bin`] | [`panic.json`] |

[MyEtherWallet] is the easiest way to interact with these deployed contracts.

[0x8a90b1e93020933295b3bd4ce2317062319351d4]: https://ropsten.etherscan.io/address/0x8a90b1e93020933295b3bd4ce2317062319351d4
[0x2e2487c64b1420111e8d66d751f75f69515c5476]: https://ropsten.etherscan.io/address/0x2e2487c64b1420111e8d66d751f75f69515c5476
[0x9a1b29fc432af1e37af03ed2fee00d742ff7372f]: https://ropsten.etherscan.io/address/0x9a1b29fc432af1e37af03ed2fee00d742ff7372f

### Example: Counter

#### [`counter.clar`]

```scheme
(define-data-var counter int 0)

(define-read-only (get-counter)
  (ok (var-get counter)))

(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) 1))
    (ok (var-get counter))))

(define-public (decrement)
  (begin
    (var-set counter (- (var-get counter) 1))
    (ok (var-get counter))))
```

#### `counter.opcode`

```bash
$ clarc counter.clar -t opcode
PUSH1 0x00 PUSH1 0x00 SSTORE PUSH1 0x64 DUP1 PUSH1 0x10 PUSH1 0x00 CODECOPY
PUSH1 0x00 RETURN PUSH1 0xe0 PUSH1 0x02 EXP PUSH1 0x00 CALLDATALOAD DIV DUP1
PUSH4 0x8ada066e EQ PUSH1 0x28 JUMPI DUP1 PUSH4 0xd09de08a EQ PUSH1 0x36
JUMPI DUP1 PUSH4 0x2baeceb7 EQ PUSH1 0x4d JUMPI STOP JUMPDEST POP PUSH1 0x00
SLOAD PUSH1 0x00 MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP JUMPDEST POP
PUSH1 0x01 PUSH1 0x00 SLOAD ADD PUSH1 0x00 SSTORE PUSH1 0x00 SLOAD PUSH1 0x00
MSTORE PUSH1 0x20 PUSH1 0x00 RETURN STOP JUMPDEST POP PUSH1 0x01 PUSH1 0x00
SLOAD SUB PUSH1 0x00 SSTORE PUSH1 0x00 SLOAD PUSH1 0x00 MSTORE PUSH1 0x20
PUSH1 0x00 RETURN STOP
```

#### [`counter.bin`]

```bash
$ clarc counter.clar -t bytecode
600060005560648060106000396000f360e060020a6000350480638ada066e146028578063d09de08a1460365780632baeceb714604d57005b5060005460005260206000f3005b5060016000540160005560005460005260206000f3005b5060016000540360005560005460005260206000f300
```

## Design

Clarc is written in [OCaml], an excellent programming language for crafting
compiler toolchains.

Clarc is a standard multi-pass compiler consisting of the following stages:

![Flowchart](https://github.com/weavery/clarc/blob/master/etc/flowchart.png)

The Clarity parser and abstract syntax tree ([AST]) are maintained as a
subproject in an OCaml library called [Clarity.ml]. The library enables anyone
familiar with OCaml to quickly and easily develop more best-of-class tooling
for Clarity contracts.

### Lexical analysis

See Clarity.ml's [`lexer.mll`] for the lexical analyzer source code.

[`lexer.mll`]: https://github.com/weavery/clarity.ml/blob/master/src/lexer.mll

### Syntactic analysis

See Clarity.ml's [`parser.mly`] and [`parse.ml`] for the parser source code.

[`parse.ml`]:   https://github.com/weavery/clarity.ml/blob/master/src/parse.ml
[`parser.mly`]: https://github.com/weavery/clarity.ml/blob/master/src/parser.mly

### Semantic analysis

See Clarity.ml's [`grammar.ml`] for the structure of the Clarity [AST].

[`grammar.ml`]: https://github.com/weavery/clarity.ml/blob/master/src/grammar.ml

## Development

This section documents how to get set up with a development environment for
building Clarc from source code. It is only of interest to people who wish to
contribute to Clarc.

### Prerequisites

The following baseline tooling is required in order to build Clarc from source
code:

- [Git](https://git-scm.com/downloads)

- [OCaml] 4.11+

- [OPAM](https://opam.ocaml.org)

- [Dune](https://dune.build)

- [Docker](https://docs.docker.com/get-docker/) (for release builds only)

We would recommend you *don't* install OCaml from a package manager.

Rather, [get set up with OPAM](https://opam.ocaml.org/doc/Install.html) and
then let OPAM install the correct version of OCaml as follows:

```bash
opam init -c 4.11.1        # if OPAM not yet initialized
opam switch create 4.11.1  # if OPAM already initialized
```

Once OPAM and OCaml are available, install Dune as follows:

```bash
opam install dune
```

### Dependencies

The following OCaml tools and libraries are required in order to build
Clarc from source code:

- [Alcotest](https://opam.ocaml.org/packages/alcotest/)
  for unit tests

- [Clarity.ml] for parsing Clarity code

- [Cmdliner](https://opam.ocaml.org/packages/cmdliner/)
  for the command-line interface

- [Cppo](https://opam.ocaml.org/packages/cppo/)
  for code preprocessing

- [Cryptokit](https://opam.ocaml.org/packages/cryptokit/)
  for the Keccak-256 hash function

- [ISO8601](https://opam.ocaml.org/packages/ISO8601/)
  for date handling

- [Num](https://opam.ocaml.org/packages/num/)
  for 128-bit integers

- [Ocolor](https://opam.ocaml.org/packages/ocolor/)
  for terminal colors

These aforementioned dependencies are all best installed via OPAM:

```bash
opam install -y alcotest cmdliner cppo cryptokit iso8601 num ocolor
opam pin add -y clarity-lang https://github.com/weavery/clarity.ml -k git
```

### Running the program

```bash
alias clarc='dune exec bin/clarc/clarc.exe --'

clarc --help
```

### Installing from source code

```bash
git clone https://github.com/weavery/clarc.git

cd clarc

dune build

sudo install _build/default/bin/clarc/clarc.exe /usr/local/bin/clarc
```

## Acknowledgments

We thank the [Stacks Foundation] for [sponsoring] the development of Clarc.

We thank [Blockstack] and [Algorand] for having developed the Clarity language,
an important evolution for the future of smart contracts.

[Algorand]:          https://algorand.com
[AST]:               https://en.wikipedia.org/wiki/Abstract_syntax_tree
[Blockstack]:        https://blockstack.org
[Clarity]:           https://clarity-lang.org
[Clarity.js]:        https://github.com/weavery/clarity.js
[Clarity.ml]:        https://github.com/weavery/clarity.ml
[Ethereum]:          https://ethereum.org
[IR]:                https://en.wikipedia.org/wiki/Intermediate_representation
[MyEtherWallet]:     https://www.myetherwallet.com/interface/interact-with-contract
[OCaml]:             https://ocaml.org
[Ropsten]:           https://ropsten.etherscan.io
[sponsoring]:        https://github.com/stacksgov/Stacks-Grants/issues/16
[Stacks Foundation]: https://stacks.org

[`counter.clar`]:    https://github.com/weavery/clarc/blob/master/etc/examples/counter.clar
[`counter.bin`]:     https://gist.github.com/artob/1f08c37a55965ff486e6ca99f1ade00d
[`counter.json`]:    https://github.com/weavery/clarc/blob/master/etc/examples/counter.json

[`kv-store.clar`]:   https://github.com/weavery/clarc/blob/master/etc/examples/kv-store.clar
[`kv-store.bin`]:    https://gist.github.com/artob/b0f176f52d6d538d7b195c2fb7f6058a
[`kv-store.json`]:   https://github.com/weavery/clarc/blob/master/etc/examples/kv-store.json

[`panic.clar`]:      https://github.com/weavery/clarc/blob/master/etc/examples/panic.clar
[`panic.bin`]:       https://gist.github.com/artob/945397b444402f6bea7512993608b02c
[`panic.json`]:      https://github.com/weavery/clarc/blob/master/etc/examples/panic.json
