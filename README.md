# Lamadre

**Private Atomic Swaps and Yield Infrastructure for Monero on Aztec**

Lamadre is a production-grade, privacy-native protocol for trustless cross-chain atomic swaps between Monero and private assets on Aztec (programmable privacy rollup). First Monero ↔ private-rollup swap, private on both legs, zero public calls.

## Key Features (Minimal-Circuit Redesign)
- Off-chain DLEQ verification by Alice (reuses audited Rust).
- Minimal Noir circuit (~250-420 constraints): hashlock + committed-key OTP verifiable encryption + constrained tag.
- Enforced disclosure: Bob cannot claim without emitting a decryptable secret to Alice.
- Tranching: bounds the reveal-vs-Monero-finality race risk to V/N.
- Fully private execution: zero public function calls, private FPC, singleton contract.
- Archive-root timelocks.
- Forward secrecy via per-swap keys.
- Future: private yield/ramp primitives for Monero users.

## Architecture
- **Monero side**: Two-party key generation (`x = s_a + s_b`), off-chain binding verification.
- **Aztec side**: Private LockNote + provable DeliveryNote using Noir circuits + Aztec.nr.
- **Delivery gadget**: Committed `k`, `ct = s_b ⊕ PRF(k)`, constrained tag.
- **No on-chain Ed25519 bignum or DLEQ transcript** (huge simplification).

## Status
Heavy production-grade complete:
- Full auditor-ready spec + paper.
- Noir gadget + tests.
- Aztec.nr singleton (notes, claim with delivery, refund, batch).
- Rust client (DLEQ, OTP, tranching, Monero) + cargo tests.
- Docs, vectors.
Ready for grants (Aztec Grants + Monero CCS), audits, full regtest+sandbox E2E.

## Repo Structure
- `specs/PROTOCOL.md` — Deep protocol + invariants + checklist (auditor grade).
- `paper/lamadre-paper.md` — Full research paper (enforced disclosure + numbers).
- `contracts/Lamadre.nr` — Aztec.nr singleton contract.
- `noir/circuits/minimal_delivery.nr` — Core gadget.
- `rust/` — Client (Cargo.toml, lib with modules, tests).
- `docs/` — DEPLOYMENT, PRIVATE_GIT, COMPANY.

## Getting Started (dev)
```bash
cd noir && nargo test
cd rust && cargo test
# Full E2E + deploy: docs/DEPLOYMENT.md
```

## Business / OPSEC
- **Name**: Lamadre (edgy).
- **Setup**: Zug Switzerland (Aztec synergy) ~CHF 60-110k first 18mo or UAE hybrid. See docs/COMPANY.md.
- **Pseudonym**: Consistent handle or Turkish "Ömer" persona option.
- **Private Git**: Forgejo/Radicle (GitHub = public mirror only). See docs/PRIVATE_GIT.md.

## Grants
Aligns with Aztec Grants + Monero CCS (privacy + real XMR utility).

---

**Complete delivery 2026-07-03. All production-grade, committed.**


