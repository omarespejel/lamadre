#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Rust Simulator (off-chain flow + values) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Networks (local only) ==="
echo "Aztec: local sandbox (not mainnet)"
echo "Monero: local regtest"

echo ""
echo "=== 3. Already deployed in this sandbox ==="
echo "lamadre-asset (Token proxy for the asset leg)"
echo "Address: 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130"
echo "Alias:   lamadre-asset"

echo ""
echo "=== 4. Custom Lamadre contract status ==="
echo "Logic ready (create_lock, claim with gadget, refund)."
echo "Full custom deploy not yet successful (Nargo/git dep friction)."
echo "Next engineering step: get it deployed in this sandbox."

echo ""
echo "=== 5. How to drive a flow right now (using the proxy) ==="
echo "Use simulator values above + the deployed lamadre-asset as the 'asset'."
echo "Example asset move:"
echo "  aztec-wallet send transfer_to_private --from test0 --contract-address contracts:lamadre-asset --args test0 100"
