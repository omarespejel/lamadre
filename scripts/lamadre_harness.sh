#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Full off-chain simulator (fresh values) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Live Aztec (copy-paste next) ==="
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"

echo "aztec-wallet import-test-accounts"
echo "aztec-wallet create-account -a lamadre-demo --from test0"

echo ""
echo "=== 3. Deploy proxy asset (Token) ==="
echo 'aztec-wallet deploy Token --from test0 --args test0 "LamadreAsset" "LMA" 18 -a lamadre-asset'

echo ""
echo "=== 4. Once you have contract addr from above, use simulator values for calls ==="
echo "# Example (replace <addr> with actual):"
echo "# aztec-wallet send create_lock --from lamadre-demo --contract-address <addr> --args <hashlock-from-sim> <c_k-from-sim> <timelock>"
echo "# aztec-wallet send claim --from lamadre-demo --contract-address <addr> --args <secret> <k> <nonce> ..."

echo ""
echo "=== 5. Monero ==="
echo "Daemon running. Generate blocks with your wallet address via RPC."
