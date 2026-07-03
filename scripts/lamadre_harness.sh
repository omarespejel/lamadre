#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Run simulator and capture values ==="
cd "$ROOT/rust"
SIM=$(cargo run --bin simulate_swap 2>&1)
echo "$SIM" | tail -15

# Extract values (simplified parsing from output)
HASHLOCK=$(echo "$SIM" | grep -o 'hashlock=\[[^]]*\]' | head -1 | sed 's/hashlock=//')
CK=$(echo "$SIM" | grep -o 'c_k=\[[^]]*\]' | head -1 | sed 's/c_k=//')
TAG=$(echo "$SIM" | grep -o 'tag=\[[^]]*\]' | head -1 | sed 's/tag=//')

echo ""
echo "=== Captured values (use in wallet calls) ==="
echo "HASHLOCK=$HASHLOCK"
echo "C_K=$CK"
echo "TAG=$TAG"

echo ""
echo "=== 2. Aztec live commands (run these) ==="
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"

echo "Import test accounts:"
echo '  aztec-wallet import-test-accounts'

echo ""
echo "Create account (already done in previous runs):"
echo '  aztec-wallet create-account -a lamadre-demo --from test0'

echo ""
echo "Deploy Token as asset proxy (fix constructor if needed):"
echo '  aztec-wallet deploy Token --from test0 --args test0 "LamadreAsset" "LMA" 18 -a lamadre-asset'

echo ""
echo "Once you have contract addresses, example calls with values:"
echo "  aztec-wallet send create_lock --from lamadre-demo --contract-address <lamadre-addr> --args $HASHLOCK $CK <timelock>"

echo ""
echo "=== 3. Monero ==="
echo "Daemon: running. Generate blocks with your wallet address via RPC."
