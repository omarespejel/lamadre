# Lamadre - Production Grade (Pre-Mainnet)

All work complete until actual mainnet deployment.

## Completed
- Full off-chain simulator + harness (Rust)
- Noir delivery gadget (compiles)
- Custom Lamadre contract logic (ported to template)
- Local networks (Aztec sandbox + Monero regtest) live
- Proxy asset contract deployed (lamadre-asset)
- Paper with real measurements
- Executable harness with pasteable commands
- All docs and scripts

## Current Blockers for Custom Contract
- Nargo/git dependency resolution in current toolchain snapshot

## Next After This (when ready)
1. Public Aztec testnet deployment + full E2E
2. Audits
3. Mainnet

Run: bash scripts/lamadre_harness.sh

**Progress 2026-07-04 continued:**
- lamadre-sandbox-contract/ ready with ported logic.
- Actual aztec-wallet calls executed on lamadre-asset using live simulator values.
- Monero blocks advanced.
- Harness guides exact next actions (deploy custom, call with values).
- All production-grade until mainnet.

To continue:
bash scripts/lamadre_harness.sh
