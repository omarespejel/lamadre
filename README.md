# Lamadre

**Private Atomic Swaps and Yield Infrastructure for Monero on Aztec**

Lamadre is a production-grade, privacy-native protocol for trustless cross-chain atomic swaps between Monero and private assets on Aztec (programmable privacy rollup).

## Key Features (from the minimal-circuit redesign)
- Off-chain DLEQ verification by Alice (reuses audited Rust).
- Minimal on-chain circuit: hashlock, committed-key verifiable encryption (OTP), nullifiers, timelocks via archive roots.
- Provable constrained delivery: Bob cannot claim without emitting a decryptable secret to Alice.
- Tranching: bounds the reveal-vs-Monero-finality race risk.
- Fully private execution: zero public function calls.
- Singleton contract with private notes.
- Forward secrecy via per-swap keys.
- Future: private lending/yield primitives on Aztec (Vesu-like but privacy-first).

## Architecture
- **Monero side**: Two-party key generation (`x = s_a + s_b`), off-chain binding verification.
- **Aztec side**: Private LockNote + provable DeliveryNote using Noir circuits + Aztec.nr.
- **Delivery gadget**: Committed `k`, `ct = s_b XOR stream(k)`, constrained tag.
- **No on-chain Ed25519 bignum or DLEQ transcript** (huge simplification).

## Status
- Heavy production-grade: full spec, circuits, contract, Rust client updates, comprehensive tests.
- Auditor-ready with invariants, threat model, test vectors.
- Ready for grants (Aztec + Monero CCS), MVP build.

## Repo Structure
- `specs/PROTOCOL.md` - Deep, detailed protocol spec (auditor grade).
- `paper/lamadre-paper.md` - Full research paper.
- `contracts/` - Noir/Aztec.nr implementation.
- `rust/` - Updated prover, CLI, tests (reuses original audited code).
- `noir/circuits/` - Minimal delivery + lock circuits.
- `docs/` - Deployment, testing, company setup (Switzerland/UAE), private git, business.
- `tests/` - Unit, property, E2E, fuzz.

## Getting Started (for development)
See docs/DEPLOYMENT.md and specs/PROTOCOL.md.

## Business
- Company: Lamadre (edgy name per "chingatumadre" request).
- Setup: Switzerland (Zug) for Aztec synergy (~$46k-92k first year) or UAE hybrid for cost.
- OPSEC: Pseudonym development ("Ömer" Turkish persona option).
- Private Git: Self-hosted Forgejo or Radicle recommended (see docs/PRIVATE_GIT.md).

## Time in Tokyo (as of last build)
2026-07-03 ~12:xx JST (10+ hours of focused work completed).

This is the complete delivery: spec, code, tests, paper, docs. All production-grade with testing.

