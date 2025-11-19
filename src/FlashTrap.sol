// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILP {
    function getDepositCount(address user) external view returns (uint256);
    function getWithdrawalCount(address user) external view returns (uint256);
}

contract FlashTrap {
    struct Sample {
        address wallet;
        uint256 deposits;
        uint256 withdrawals;
        uint256 blockNumber;
    }

    // -------- CONFIG (STATIC, since Drosera redeploys often) -------- //
    address constant PROTOCOL = 0x0000000000000000000000000000000000000000;
    address[] WALLET_LIST = [
        0x0000000000000000000000000000000000000000
    ];

    uint256 constant WINDOW = 10;
    uint256 constant THRESHOLD = 5;

    // block → wallet → sample
    mapping(uint256 => mapping(address => Sample)) public history;

    // ========== COLLECT (RUNS EVERY BLOCK) ========== //
    function collect() external {
        if (PROTOCOL.code.length == 0) return;

        ILP lp = ILP(PROTOCOL);
        uint256 b = block.number;

        for (uint256 i = 0; i < WALLET_LIST.length; i++) {
            address w = WALLET_LIST[i];

            Sample storage s = history[b][w];
            s.wallet = w;
            s.blockNumber = b;

            // planner-safe, never revert
            try lp.getDepositCount(w) returns (uint256 d) {
                s.deposits = d;
            } catch {
                s.deposits = 0;
            }

            try lp.getWithdrawalCount(w) returns (uint256 wd) {
                s.withdrawals = wd;
            } catch {
                s.withdrawals = 0;
            }
        }
    }

    // ========== SHOULD RESPOND (PLANNER-SAFE) ========== //
    function shouldRespond(bytes[] calldata data)
        external
        view
        returns (bool, bytes memory)
    {
        // planner may send empty blobs → guard everything
        if (data.length < 1) return (false, bytes(""));
        if (data[0].length == 0) return (false, bytes(""));

        // decode target wallet
        address target = abi.decode(data[0], (address));

        // evaluate sliding window
        uint256 currentBlock = block.number;

        uint256 newestDeposits;
        uint256 oldestDeposits;

        uint256 newestWithdrawals;
        uint256 oldestWithdrawals;

        bool newestSet;
        bool oldestSet;

        // walk backward WINDOW blocks
        for (uint256 i = 0; i < WINDOW; i++) {
            uint256 b = currentBlock - i;
            Sample memory s = history[b][target];

            if (s.wallet != target) continue;

            if (!newestSet) {
                newestSet = true;
                newestDeposits = s.deposits;
                newestWithdrawals = s.withdrawals;
            }

            oldestDeposits = s.deposits;
            oldestWithdrawals = s.withdrawals;
            oldestSet = true;
        }

        if (!newestSet || !oldestSet) return (false, bytes(""));

        uint256 delta =
            (newestDeposits - oldestDeposits) +
            (newestWithdrawals - oldestWithdrawals);

        if (delta >= THRESHOLD) {
            return (true, abi.encode(target, delta));
        }

        return (false, bytes(""));
    }
}
