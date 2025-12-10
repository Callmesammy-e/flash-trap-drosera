// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";
import {IFlashTrapConfig} from "./IFlashTrapConfig.sol";

/// @title FlashActivityTrap
/// @notice A stateless Drosera-compatible trap that measures activity based on block differences.
/// @dev Drosera executes `collect()` off-chain and feeds the returned bytes into `shouldRespond()`.
contract FlashActivityTrap is ITrap {
    IFlashTrapConfig public immutable config;

    constructor(address _config) {
        require(_config != address(0), "INVALID_CONFIG");
        config = IFlashTrapConfig(_config);
    }

    /// -----------------------------------------------------------------------
    /// COLLECT
    /// -----------------------------------------------------------------------
    /// @notice Called by Drosera off-chain for every sampled block.
    /// @return Encoded data: (wallet, blockNumber, threshold, window)
    ///
    /// NOTE:
    /// - We return the *current block.number*.
    /// - Drosera will pass TWO samples into shouldRespond(): [old, new].
    /// - shouldRespond() measures delta = newBlock - oldBlock.
    ///
    function collect() external view override returns (bytes memory) {
        return abi.encode(
            config.watchWallet(),
            block.number,          // raw block height, NOT pre-calculated delta
            config.threshold(),
            config.window()
        );
    }

    /// -----------------------------------------------------------------------
    /// SHOULD RESPOND
    /// -----------------------------------------------------------------------
    /// @notice Performs the trap alert logic.
    /// @dev Drosera will pass an array like: [older_sample, newer_sample]
    /// @param data Encoded: (wallet, blockNumber, threshold, window)
    /// @return (alert, payload)
    ///
    /// SAFETY:
    /// - Guards against empty planner input
    /// - Cleanly handles insufficient history
    ///
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        // -----------------------------
        // Safety guards for Drosera planner
        // -----------------------------
        if (data.length < 2) {
            return (false, "");
        }
        if (data[0].length == 0 || data[1].length == 0) {
            return (false, "");
        }

        // Decode first sample (older)
        (
            address wallet,
            uint256 oldBlock,
            uint256 threshold,
            uint256 window
        ) = abi.decode(data[0], (address, uint256, uint256, uint256));

        // Decode second sample (newer)
        (
            ,
            uint256 newBlock,
            ,
        ) = abi.decode(data[1], (address, uint256, uint256, uint256));

        // -----------------------------
        // Sliding window activity delta
        // -----------------------------
        uint256 delta = newBlock - oldBlock;

        // -----------------------------
        // Response condition
        // -----------------------------
        if (delta >= threshold) {
            return (true, abi.encode(wallet, delta, threshold, window));
        }

        return (false, "");
    }
}
