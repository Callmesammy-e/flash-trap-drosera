// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title FlashTrapConfig
/// @notice Minimal config storage for the Flash Activity Trap.
/// @dev No constructor. All state is set after deployment to ensure
///      persistence under Drosera's shadow-fork execution model.

contract FlashTrapConfig {
    address public owner;

    // Protocol contract we are monitoring (e.g. DEX, lending pool)
    address public protocol;

    // Wallets to track for flash-activity
    address[] public monitoredWallets;

    // Threshold: minimum number of actions in window to trigger alert
    uint256 public threshold;  // ex: 5

    // Window size: number of snapshots (blocks) to compute delta
    uint256 public window;     // ex: 10

    // --------------------------------------------------------------------
    // Events
    // --------------------------------------------------------------------
    event OwnerChanged(address indexed newOwner);
    event ProtocolUpdated(address indexed newProtocol);
    event WalletAdded(address indexed wallet);
    event WalletRemoved(address indexed wallet);
    event ThresholdUpdated(uint256 newThreshold);
    event WindowUpdated(uint256 newWindow);

    // --------------------------------------------------------------------
    // Constructor alternative: initializer for owner
    // --------------------------------------------------------------------
    function initialize(address _owner) external {
        require(owner == address(0), "Already initialized");
        require(_owner != address(0), "Invalid owner");
        owner = _owner;
        emit OwnerChanged(_owner);
    }

    // --------------------------------------------------------------------
    // Modifiers
    // --------------------------------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // --------------------------------------------------------------------
    // Owner functions
    // --------------------------------------------------------------------

    function setProtocol(address _protocol) external onlyOwner {
        require(_protocol != address(0), "Invalid protocol");
        protocol = _protocol;
        emit ProtocolUpdated(_protocol);
    }

    function addMonitoredWallet(address wallet) external onlyOwner {
        require(wallet != address(0), "Invalid wallet");
        monitoredWallets.push(wallet);
        emit WalletAdded(wallet);
    }

    function removeMonitoredWallet(uint256 index) external onlyOwner {
        require(index < monitoredWallets.length, "Index out of range");
        address removed = monitoredWallets[index];

        monitoredWallets[index] = monitoredWallets[monitoredWallets.length - 1];
        monitoredWallets.pop();

        emit WalletRemoved(removed);
    }

    function setThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold > 0, "Must be > 0");
        threshold = _threshold;
        emit ThresholdUpdated(_threshold);
    }

    function setWindow(uint256 _window) external onlyOwner {
        require(_window > 1, "Must be > 1");
        window = _window;
        emit WindowUpdated(_window);
    }

    // --------------------------------------------------------------------
    // View helpers
    // --------------------------------------------------------------------
    function getMonitoredWallets() external view returns (address[] memory) {
        return monitoredWallets;
    }
}
