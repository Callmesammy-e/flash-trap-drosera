// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IFlashTrapConfig.sol";

contract FlashTrapConfig is IFlashTrapConfig {
    address public owner;

    address public override watchWallet;
    uint256 public override threshold;
    uint256 public override window;

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor(
        address _watchWallet,
        uint256 _threshold,
        uint256 _window
    ) {
        require(_watchWallet != address(0), "INVALID_WALLET");
        owner = msg.sender;
        watchWallet = _watchWallet;
        threshold = _threshold;
        window = _window;
    }

    function update(
        address _watchWallet,
        uint256 _threshold,
        uint256 _window
    ) external onlyOwner {
        watchWallet = _watchWallet;
        threshold = _threshold;
        window = _window;
    }
}
