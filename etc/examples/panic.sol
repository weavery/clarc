// SPDX-License-Identifier: Unlicense

pragma solidity ^0.7.0;

contract Panic {
  uint128 private trigger = 0;

  function panicPrivate() private view {
    // TODO
  }

  function panicReadOnly() public view {
    panicPrivate();
  }

  function panic() public {
    panicPrivate();
  }
}
