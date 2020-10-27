// SPDX-License-Identifier: Unlicense

pragma solidity ^0.7.0;

contract Counter {
  int128 private count = 0;

  function getCounter() public view returns (int128) {
    return count;
  }

  function increment() public returns (int128) {
    count += 1;
    return count;
  }

  function decrement() public returns (int128) {
    count -= 1;
    return count;
  }
}
