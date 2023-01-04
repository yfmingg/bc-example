// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

// goerli: 0xbc67B624157DC325957b8BAADeFbF1EdFEC8c821
contract Foo {
  function bar(bytes3[2] memory m) public pure {}
  function baz(uint32 x, bool y) public pure returns (bool r) { r = x > 32 || y; }
  function sam(bytes memory a, bool b, uint[] memory c) public pure {}
}