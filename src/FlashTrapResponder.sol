// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title FlashTrapResponder
/// @notice Executes when FlashTrap signals shouldRespond == true
/// @dev For PoC: Emits events only. No state mutation required.

contract FlashTrapResponder {
    event FlashActivityAlert(
        address indexed wallet,
        uint256 actionDelta,
        uint256 threshold,
        uint256 window
    );

    /// @notice Called by Drosera Operator when trap fires
    /// @param data ABI-encoded alert: (address wallet, uint256 delta, uint256 threshold, uint256 window)
    function respond(bytes calldata data) external {
        (
            address wallet,
            uint256 delta,
            uint256 threshold,
            uint256 window
        ) = abi.decode(data, (address, uint256, uint256, uint256));

        emit FlashActivityAlert(wallet, delta, threshold, window);
    }
}
