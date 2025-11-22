// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {IFlashTrapConfig} from "./IFlashTrapConfig.sol";

contract FlashActivityTrap is ITrap {
    IFlashTrapConfig public immutable config;

    constructor(address _config) {
        require(_config != address(0), "INVALID_CONFIG");
        config = IFlashTrapConfig(_config);
    }

    /// @notice Collects activity data for evaluation by Drosera
    /// Encodes: (wallet, delta, threshold, window)
    function collect() external view override returns (bytes memory) {
        address wallet = config.watchWallet();
        uint256 window = config.window();
        uint256 threshold = config.threshold();

        // block.number is used as a simple activity proxy
        // you can upgrade this to any onchain logic
        uint256 current = block.number;
        uint256 previous = current - window;
        uint256 delta = current - previous;

        return abi.encode(wallet, delta, threshold, window);
    }

    /// @notice Determines whether this trap should respond
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        (address wallet, uint256 delta, uint256 threshold, uint256 window) =
            abi.decode(data[0], (address, uint256, uint256, uint256));

        if (delta >= threshold) {
            return (true, abi.encode(wallet, delta, threshold, window));
        }

        return (false, bytes(""));
    }
}
