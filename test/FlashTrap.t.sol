// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {FlashActivityTrap} from "../src/FlashActivityTrap.sol";
import {FlashTrapConfig} from "../src/FlashTrapConfig.sol";

contract FlashTrapTest is Test {
    FlashActivityTrap trap;
    FlashTrapConfig config;

    function setUp() public {
        config = new FlashTrapConfig();
        trap = new FlashActivityTrap(address(config));
    }

    function testShouldRespondEmpty() public view {
        // simulate operator passing empty data array
        bytes;

        // encode dummy snapshot
        snapshots[0] = abi.encode(
            address(0x1234),   // wallet
            uint256(0),        // delta
            uint256(10),       // threshold
            uint256(5)         // window
        );

        (bool alert, bytes memory payload) = trap.shouldRespond(snapshots);

        // delta = 0 < threshold = 10 → no alert
        assertEq(alert, false);
        assertEq(payload.length, 0);
    }

    function testCollectDoesNotRevert() public view {
        trap.collect();
    }
}
