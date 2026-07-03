#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Rust Simulator (off-chain + values) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Current networks ==="
echo "Aztec sandbox: running (local, not mainnet)"
echo "Monero regtest: running"

echo ""
echo "=== 3. Deployed in sandbox ==="
echo "lamadre-asset (Token proxy): 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130"
echo "Use this as the 'asset' for demo flows."

echo ""
echo "=== 4. Next steps for custom Lamadre contract ==="
echo "1. Fix Nargo/git issues or use aztec compile on a fresh template."
echo "2. Deploy the real escrow contract."
echo "3. Then run create_lock + claim with simulator values."

echo ""
echo "=== 5. Example calls (once custom contract deployed) ==="
echo "aztec-wallet send create_lock --from lamadre-demo --contract-address <lamadre-addr> --args <hashlock> <c_k> <timelock>"
