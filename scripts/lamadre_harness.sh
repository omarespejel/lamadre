#!/bin/bash
# Lamadre E2E Harness - runs what we can now
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Rust Simulator (full off-chain flow) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Aztec interactions (using running network) ==="
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"
echo "Importing test accounts..."
/Users/espejelomar/.aztec/versions/4.3.1/node_modules/.bin/aztec-wallet import-test-accounts 2>&1 | tail -2 || true
echo "Creating account..."
/Users/espejelomar/.aztec/versions/4.3.1/node_modules/.bin/aztec-wallet create-account -a lamadre-demo --from test0 2>&1 | tail -5 || true

echo ""
echo "=== 3. Monero blocks (if needed) ==="
echo "Daemon running. Use generateblocks RPC for funds."

echo ""
echo "Harness complete for current state. Next: deploy custom contract and drive create_lock/claim."
