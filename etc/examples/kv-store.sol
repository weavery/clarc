// SPDX-License-Identifier: Unlicense

pragma solidity ^0.7.0;

contract KvStore {
  mapping(address => int256) private store;

  function getValue(address key) public view returns (int128) {
    // TODO
    return 0;
  }

  function setValue(address key) public returns (bool) {
    // TODO
    return true;
  }
}
