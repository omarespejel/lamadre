#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== Lamadre Pre-Mainnet Production Harness ==="
cd "$ROOT/rust"
SIM=$(cargo run --bin simulate_swap 2>&1)
echo "$SIM" | tail -8

HASHLOCK=$(echo "$SIM" | grep -o 'hashlock=\[[^]]*\]' | head -1 | sed 's/hashlock=//')
CK=$(echo "$SIM" | grep -o 'c_k=\[[^]]*\]' | head -1 | sed 's/c_k=//')

echo ""
echo "=== Live State ==="
echo "lamadre-asset deployed: 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130"
echo "Aztec sandbox + Monero regtest running"

echo ""
echo "=== Executing real call now (asset move on proxy) ==="
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"
TEST0=0x1fff360b8e1f7c01426157d723037fe8aaa0f5d60a80e32984a11167ccb68222
aztec-wallet send transfer_to_private --from test0 --contract-address 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130 --args $TEST0 30 2>&1 | tail -4

echo ""
echo "=== Values for custom Lamadre contract (deploy when ready) ==="
echo "HASHLOCK=$HASHLOCK"
echo "C_K=$CK"
echo "Example: aztec-wallet send create_lock --from lamadre-demo --contract-address <LAMADRE_ADDR> --args $HASHLOCK $CK 1234567890"

echo ""
echo "=== Monero ==="
echo "Run generateblocks RPC as needed for confirmations."
