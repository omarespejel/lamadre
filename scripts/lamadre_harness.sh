#!/bin/bash
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== 1. Rust Simulator (full off-chain flow + values) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Aztec (live network) ==="
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval "$(/Users/espejelomar/.aztec/bin/aztec-up env 2>/dev/null || true)"
/Users/espejelomar/.aztec/versions/4.3.1/node_modules/.bin/aztec-wallet import-test-accounts 2>&1 | tail -1 || true
echo "Create account if needed: aztec-wallet create-account -a lamadre-demo --from test0"

echo ""
echo "=== 3. Example on-chain calls (once contract deployed) ==="
echo "Deploy example: aztec-wallet deploy Token --from test0 -a lamadre-asset"
echo "Then use values from simulator above for:"
echo "  aztec-wallet send create_lock --contract-address <addr> --args <hashlock> <c_k> <timelock> ..."
echo "  aztec-wallet send claim --contract-address <addr> --args <secret> <k> <nonce> ..."

echo ""
echo "=== 4. Monero ==="
echo "Daemon running at 18081. Generate blocks as needed."
