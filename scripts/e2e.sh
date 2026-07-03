#!/bin/bash
# Lamadre E2E starter (what we can run autonomously)
# 1. Runs the full off-chain simulator
# 2. Starts Monero regtest (requires binary - see comments)
# 3. Prints exact commands for Aztec local network

set -e

ROOT=$(cd "$(dirname "$0")/.." && pwd)
echo "=== Lamadre E2E Starter ==="
echo "Root: $ROOT"

echo ""
echo "=== 1. Off-chain flow (Rust simulator - fully autonomous, no external binaries) ==="
cd "$ROOT/rust"
cargo run --bin simulate_swap

echo ""
echo "=== 2. Noir gadget test ==="
cd "$ROOT/noir"
~/.nargo/bin/nargo test || /Users/espejelomar/.aztec/versions/4.3.1/internal-bin/nargo test || echo "Use your nargo"

echo ""
echo "=== 3. Monero regtest ==="
echo "Download CLI from https://www.getmonero.org/downloads/ (mac arm8)"
echo "Example:"
echo "  cd ~/monero-regtest"
echo "  # put monerod and monero-wallet-cli here"
echo "  ./monerod --regtest --offline --rpc-bind-ip 127.0.0.1 --rpc-bind-port 18081 &"
echo "  ./monero-wallet-cli --regtest --generate-new-wallet /tmp/alice --password '' "
echo "Generate blocks as needed for confirmations."

echo ""
echo "=== 4. Aztec local network (from this session) ==="
echo "export PATH=\"/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:\$PATH\""
echo "eval \$(\"/Users/espejelomar/.aztec/bin/aztec-up\" env)"
echo "aztec start --local-network"
echo ""
echo "Then in another shell:"
echo "  aztec-wallet import-test-accounts"
echo "  # adapt lamadre-aztec/ and compile with aztec-nargo or aztec CLI"
echo "  # private create_lock / claim using the gadget for enforced disclosure"

echo ""
echo "=== To run a 'full' test when tools are ready: adapt the lamadre-aztec contract and use aztec-wallet for private txs ==="
echo "See docs/SETUP_AND_NEXT_STEPS.md and lamadre-aztec/ for the skeleton."
echo "The simulator proves the core protocol (DLEQ + OTP delivery + recovery) already works."
