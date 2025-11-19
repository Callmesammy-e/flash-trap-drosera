🚨 Flash Trap for Drosera

A fully Drosera-ready Trap that detects sudden burst activity (flash deposits or flash withdrawals) across multiple wallets within a sliding block window.

This repository contains:

A hardened, production-safe Drosera Trap (FlashTrap.sol)

A configuration contract (FlashTrapConfig.sol)

A simple responder (optional hook)

Full Drosera integration via drosera.toml

A detailed example of multi-wallet batch analysis

A safe + deterministic no-constructor pattern compatible with Drosera shadow-fork execution

This project is built as a reference implementation for new trap authors.

🧠 What This Trap Detects

The Flash Trap watches a set of monitored wallets and counts how many deposits and withdrawals each wallet has performed inside a rolling 10-block window.

If the number of actions by any wallet exceeds a configurable threshold
(default: 5 actions within 10 blocks),
the trap emits an alert.

This pattern is useful for:

Catching suspicious bursts of wallet activity

Flash-loan backed manipulation attempts

Protocol parameter griefing

Attackers probing a system via spam deposits/withdrawals

Anomaly detection across multiple users

🔍 Core Logic

The trap follows Drosera's architecture:

✔ collect()

Harvests deposit/withdrawal counters from the protocol contract

Reads the monitored wallet list from FlashTrapConfig

Never reverts (fully extcodesize + try/catch guarded)

Returns an encoded array of samples for the last block

✔ shouldRespond()

Receives historical samples across multiple blocks

Matches wallets by address, not array order

Computes:
delta = newestCount - oldestCount

If delta >= threshold, the trap fires

Returns encoded data for responders

🧱 Architecture
flash-trap-drosera/
│
├── src/
│   ├── FlashTrapConfig.sol     # Holds monitored wallets + protocol address
│   ├── FlashTrapResponder.sol  # Optional responder (logs events)
│   └── FlashTrap.sol           # The actual Drosera Trap
│
├── drosera.toml                # Drosera config (trap + responder)
├── foundry.toml                # Foundry tooling config
└── README.md                   # This file

🏗 How It Works (Simplified Diagram)
    ┌───────────────────┐
    │  Drosera Operator │
    └─────────┬─────────┘
              │ every block
              ▼
        collect() view
              │
    returns snapshot per wallet
              │
              ▼
 shouldRespond(previousSnapshots[])
              │
         boolean result
              │
      if true → trigger
              ▼
     Responder / Action Router

⚙️ Configuration
⚡ Monitored wallets

These are NOT stored in the trap (constructors do not persist in Drosera).
They are stored in FlashTrapConfig.sol.

You can:

add wallets

remove wallets

update protocol address

All changes take effect automatically in the next block.

🔐 Safety Guarantees

This trap implementation satisfies all Drosera safety constraints:

✔ No constructor dependencies

Drosera redeploys traps every block, so config must not come from constructors.

✔ Fully planner-safe

Handles empty data payloads from Drosera planners.

✔ Revert-proof collect()

All external calls wrapped in:

code existence checks

try/catch

fallback safe struct defaults

✔ Index-free comparisons

Wallets are matched by address, not ordering.

✔ Stable behavior across blocks

Consistent state even when protocol returns unstable values.

⛓ Example: What an Alert Looks Like

The responder receives:
struct BurstActivityAlert {
    address wallet;
    uint256 delta;
    uint256 threshold;
}

Encoded as:
abi.encode(wallet, delta, threshold)

🧪 Testing

To run tests:
forge build
forge test

Coming soon:

test suite covering windowed delta detection

mock protocol for flash activity simulation

🚀 Deployment / Integration

This repo includes:

script/Deploy.s.sol

A Foundry script that deploys:

the config contract

the trap

the responder

and sets up the monitored wallets.

Run:
forge script script/Deploy.s.sol --broadcast --rpc-url <RPC>

🌱 Contributing

Pull requests are welcome!

If you want to add:

more example traps

multi-window analysis

better responders

protocol-specific utilities

Create a new branch and submit a PR.

📜 License

MIT License — free for all use.

🧁 Credits

This repo was created as part of community exploration around Drosera Trap development.

Special thanks to the Drosera team for documentation, feedback, and guidance on trap safety patterns.
