// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FlashActivityTrap.sol";
import "../src/FlashTrapConfig.sol";
import "../src/FlashTrapResponder.sol";

/// @notice Deployment script for FlashActivityTrap + Config + Responder
/// @dev Must be run with PRIVATE_KEY, WATCH_WALLET, THRESHOLD, WINDOW set in .env
contract DeployFlashTrap is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        //------------------------------------------------------
        // Load Environment Variables
        //------------------------------------------------------
        address WATCH_WALLET = vm.envAddress("WATCH_WALLET");
        uint256 THRESHOLD    = vm.envUint("THRESHOLD");
        uint256 WINDOW       = vm.envUint("WINDOW");

        require(WATCH_WALLET != address(0), "WATCH_WALLET not set");
        require(THRESHOLD > 0, "THRESHOLD must be > 0");
        require(WINDOW > 0, "WINDOW must be > 0");

        //------------------------------------------------------
        // Deploy Configuration Contract (immutable config)
        //------------------------------------------------------
        FlashTrapConfig config = new FlashTrapConfig(
            WATCH_WALLET,
            THRESHOLD,
            WINDOW
        );

        //------------------------------------------------------
        // Deploy the Drosera-compatible Trap
        //------------------------------------------------------
        FlashActivityTrap trap = new FlashActivityTrap(address(config));

        //------------------------------------------------------
        // Deploy Responder (off-chain automation entrypoint)
        //------------------------------------------------------
        FlashTrapResponder responder = new FlashTrapResponder();

        vm.stopBroadcast();

        //------------------------------------------------------
        // Logs for Drosera TOML
        //------------------------------------------------------
        console.log("====== Flash Trap Deployment Completed ======");
        console.log("Config Contract:       ", address(config));
        console.log("FlashActivityTrap:     ", address(trap));
        console.log("Responder Contract:     ", address(responder));
        console.log("==============================================");
    }
}
