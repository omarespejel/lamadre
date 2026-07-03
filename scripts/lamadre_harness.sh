#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== Lamadre Production Harness (Sandbox Pre-Mainnet) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap 2>&1 | tail -8

echo ""
echo "=== Current State ==="
echo "lamadre-asset deployed and used for asset moves."
echo "Custom contract logic ready; compile/deploy in progress."

echo ""
echo "=== Next Steps (do these) ==="
echo "1. Deploy custom Lamadre contract in sandbox (see lamadre-sandbox-contract)"
echo "2. Use captured hashlock/c_k to call create_lock on it."
echo "3. Full E2E with Monero regtest + Aztec private calls."
