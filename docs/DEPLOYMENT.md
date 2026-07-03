# Lamadre Production Deployment Guide

## Private Git (for development)
Use self-hosted Forgejo (GitHub-like, private repos) or Radicle (P2P decentralized, key-only IDs).
- Forgejo: Docker on VPS in Switzerland, access via Tailscale/Tor.
- Radicle: Local node, share peer IDs with team (pseudonym).
See PRIVATE_GIT.md.

## Contract Deployment
- Singleton on Aztec (Alpha/Testnet then main).
- `aztec deploy` or aztec.js with private account + private FPC for fees.
- One-time: `create_lock` / claim / refund all private functions.
- Pin versions: see noir/Nargo.toml and aztec-nr import.

Singleton address published after first deploy. All users point to it.

## Testing (heavy)
- Noir: `cd noir && nargo test`
- Rust: `cd rust && cargo test --all-features`
- Property: proptest on delivery + tranching invariants.
- E2E: Monero regtest (bitcoind style) + Aztec sandbox. Scripts in `scripts/`.
- Vectors: original + OTP/delivery + tranche cases.
- Full audit checklist in specs/PROTOCOL.md §9.

## Monitoring & Ops
- PXE (private execution env) for note discovery & tag scanning.
- Private delivery logs (constrained).
- Tranche management UI/CLI (recover partials).
- Nullifier & archive root watch for refunds.

## Upgrades & Versioning
- Contract is intentionally minimal. Future versions deploy new singletons + migration notes.
- Circuit upgrades require new lock types or versioned gadgets.

## Company / Grants
See COMPANY.md and README.

## Private Yield / Future
Once core swap stable: private lending/ramp primitives (Vesu-like private collateral on Aztec notes).

