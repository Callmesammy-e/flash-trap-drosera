// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/FlashActivityTrap.sol";
import "./MockProtocol.sol";

contract FlashTrapTest is Test {
    FlashActivityTrap trap;
    MockProtocol protocol;

    function setUp() public {
        trap = new FlashActivityTrap();
        protocol = new MockProtocol();
    }

    function testCollectAndRespond() public {
        protocol.deposit{value: 1 ether}();
        protocol.deposit{value: 2 ether}();

        trap.collect();

        bool alert = trap.shouldRespond();
        assert(alert == true);
    }
}
