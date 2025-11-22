// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFlashTrapConfig {
    function watchWallet() external view returns (address);
    function threshold() external view returns (uint256);
    function window() external view returns (uint256);
}
