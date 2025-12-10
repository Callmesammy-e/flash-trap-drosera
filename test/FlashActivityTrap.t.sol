// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {FlashActivityTrap} from "../src/FlashActivityTrap.sol";
import {FlashTrapConfig} from "../src/FlashTrapConfig.sol";

contract FlashActivityTrapTest is Test {
    FlashActivityTrap trap;
    FlashTrapConfig config;

    function setUp() public {
        config = new FlashTrapConfig(5, 20, address(0x1234));
        trap = new FlashActivityTrap(address(config));
    }

    function testCollect() public view {
        bytes memory out = trap.collect();
        assertGt(out.length, 0);
    }

    function testShouldRespondEmpty() public view {
        bytes;
        (bool alert, ) = trap.shouldRespond(snaps);
        assertTrue(alert == false);
    }
}
