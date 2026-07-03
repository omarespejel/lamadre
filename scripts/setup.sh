#!/bin/bash
# Lamadre full local setup script
# Run this after cloning the repo

set -e

echo "=== Lamadre Local Setup ==="

# 1. Rust (should already work)
echo "Rust tests:"
cd "$(dirname "$0")/../rust" && cargo test

# 2. Node 24 + Aztec (run manually if needed)
echo "To install Aztec:"
echo '  export PATH="/opt/homebrew/opt/node@24/bin:$PATH"'
echo '  VERSION=4.3.1 bash -i <(curl -sL https://install.aztec.network)'
echo '  aztec start --local-network'

# 3. Monero
echo "Download Monero CLI manually from https://www.getmonero.org/downloads/ (mac arm)"
echo "Place monerod and monero-wallet-cli in PATH or monero-regtest/"

# 4. Private git
echo "Local Forgejo demo:"
echo "docker run -d -p 3001:3000 -p 2222:22 -v $(pwd)/forgejo-data:/data codeberg.org/forgejo/forgejo:15"

echo "Then create private repo and push."

echo "Done basic setup checks."
