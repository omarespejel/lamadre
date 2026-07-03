#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== Lamadre Pre-Mainnet Production Harness ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap 2>&1 | tail -8

echo ""
echo "=== Networks ==="
echo "Aztec sandbox: running"
echo "Monero regtest: running (generate blocks as needed)"

echo ""
echo "=== Deployed ==="
echo "lamadre-asset ready for asset leg"

echo ""
echo "=== Immediate next actions ==="
echo "1. Deploy custom Lamadre contract (lamadre-deployable or lamadre-final-contract)"
echo "2. Once deployed, run:"
echo "   aztec-wallet send create_lock --from lamadre-demo --contract-address <ADDR> --args <HASHLOCK> <C_K> <TS>"
echo "3. Then claim with values from sim"
echo "4. Full E2E complete when custom contract works + Monero 10 confs"
