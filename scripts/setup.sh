#!/bin/bash
# Lamadre full local setup script (updated from autonomous run 2026-07-03)
# Run after git clone https://github.com/omarespejel/lamadre.git

set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "=== Lamadre Local Setup (macOS) ==="

# 1. Rust
echo "[Rust]"
cd "$ROOT/rust"
cargo test
cargo run --bin simulate_swap   # full protocol demo (off-chain + logic)

# 2. Aztec (from what worked in this session)
echo ""
echo "[Aztec]"
echo "Node 24:"
echo '  export PATH="/opt/homebrew/opt/node@24/bin:$PATH"'
echo ""
echo "Aztec tools (aztec-up discovered/installed 4.3.1):"
echo '  export PATH="/Users/espejelomar/.aztec/bin:$PATH"'
echo '  eval $(/Users/espejelomar/.aztec/bin/aztec-up env)'
echo '  aztec start --local-network   # or the versioned equivalent'
echo ""
echo "Contract skeleton ready in $ROOT/lamadre-aztec (adapt + compile with aztec-nargo once tools active)"
echo "See scripts/e2e.sh and lamadre-aztec/src/main.nr"

# 3. Monero regtest
echo ""
echo "[Monero]"
echo "Place monerod + monero-wallet-cli (arm64) from getmonero.org in ~/monero-regtest/"
echo "Then:"
echo "  ./monerod --regtest --offline --rpc-bind-ip 127.0.0.1 --rpc-bind-port 18081 &"

# 4. Private git demo
echo ""
echo "[Private Git]"
echo "  cd ~/forgejo-demo && docker run -d -p 3001:3000 -p 2222:22 -v $(pwd)/data:/data codeberg.org/forgejo/forgejo:15"
echo "  Visit http://localhost:3001 , create admin + private 'lamadre' repo, then git remote add private ... ; git push private"

echo ""
echo "See docs/SETUP_AND_NEXT_STEPS.md for full details."
echo "Core value delivered autonomously: working Rust simulator of the entire private swap flow (enforced disclosure via OTP + DLEQ off-chain)."
