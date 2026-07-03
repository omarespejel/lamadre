#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
echo "=== Lamadre Harness ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap 2>&1 | tail -5
echo ""
echo "lamadre-asset: 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130"
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"
TEST0=0x1fff360b8e1f7c01426157d723037fe8aaa0f5d60a80e32984a11167ccb68222
aztec-wallet send transfer_to_private --from test0 --contract-address 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130 --args $TEST0 30 2>&1 | tail -2
echo ""
echo "When custom deployed:"
echo "aztec-wallet send create_lock --from lamadre-demo --contract-address <LAMADRE> --args <HASHLOCK> <C_K> <TS>"
