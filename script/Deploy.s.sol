// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FlashActivityTrap.sol";
import "../src/FlashTrapConfig.sol";
import "../src/FlashTrapResponder.sol";

contract DeployFlashTrap is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // ---- Configuration ----
        address WATCH_WALLET = vm.envAddress("WATCH_WALLET");
        uint256 THRESHOLD = vm.envUint("THRESHOLD"); // e.g. 5
        uint256 WINDOW = vm.envUint("WINDOW");       // e.g. 10

        // ---- Deploy Config ----
        FlashTrapConfig config = new FlashTrapConfig(
            WATCH_WALLET,
            THRESHOLD,
            WINDOW
        );

        // ---- Deploy Trap ----
        FlashActivityTrap trap = new FlashActivityTrap(address(config));

        // ---- Deploy Responder ----
        FlashTrapResponder responder = new FlashTrapResponder();

        vm.stopBroadcast();

        console.log("====== Flash Trap Deployment Completed ======");
        console.log("Config Contract:    ", address(config));
        console.log("Trap Contract:      ", address(trap));
        console.log("Responder Contract: ", address(responder));
        console.log("============================================");
    }
}
