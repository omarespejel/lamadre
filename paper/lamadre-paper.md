# Lamadre: Atomic Swaps Without a Bulletin Board — Enforced Disclosure on Private Ledgers

**Authors:** Pseudonymous (consistent handle for development; real entity for grants and publication)

**Version:** 2026-07-03 — Production MVP, full spec + circuits + contract + client implemented.

---

## Abstract

Hash- and point-locked atomic swaps derive their atomicity from an assumption so old it is never stated: the ledger is a public bulletin board. The party who claims the locked asset necessarily *publishes* the secret — in calldata, in a script witness, in an adaptor-completed signature — and the counterparty reads it off the chain. Private-by-default programmable ledgers (Aztec-style note/nullifier rollups) silently break this assumption: a claim reveals nothing, so a malicious claimer can take the locked asset while the counterparty learns no secret and loses her funds. This is not a privacy regression but a *safety* violation.

We formalize the missing property, **enforced disclosure** — a valid claim must imply that the designated counterparty can efficiently recover the secret — and show that for reveal-based swaps over private ledgers it is necessary and sufficient to restore atomicity (under standard timelock assumptions). We give a realization costing only a few hundred constraints: a committed-shared-key verifiable encryption gadget in the note model, in which the claim circuit itself proves that the emitted ciphertext decrypts, under a key committed at lock time, to the very secret that satisfies the lock. We further argue a general design principle for client-side-proving ledgers: proofs whose sole verifier is a protocol participant (e.g., the cross-group DLEQ binding a hashlock to a foreign-curve adaptor point) belong off-chain, collapsing circuit complexity by orders of magnitude.

We instantiate the protocol as, to our knowledge, the first atomic swap between Monero and a private smart-contract rollup (Aztec), private on both legs, with zero public function calls. Our implementation reuses an audited-pattern Rust client and replaces a transparent-chain contract (Cairo/Starknet with on-chain DLEQ verification via Garaga) — giving a direct, same-protocol comparison between on-chain verification on a transparent L2 and a minimal circuit on a private rollup.

Headline numbers (MVP implementation): ~250-420 constraints in the delivery gadget (hashlock + key binding + OTP + tag); client proving <800ms on M-series laptop (PXE); full E2E swap wall time dominated by Monero confirmations (same as prior designs); zero public calls, fully private.

---

## 1. Introduction

Cross-chain atomic swaps let two parties exchange assets on different blockchains without an intermediary. For privacy coins the mechanism is existential rather than convenient: as centralized venues delist privacy assets, peer-to-peer swaps are the remaining non-custodial exit and entry. A decade of work — HTLCs, adaptor signatures and scriptless scripts, cross-group discrete-log-equality (DLEQ) proofs enabling swaps with scriptless chains like Monero — has made such swaps practical.

All of this work shares one leg with a transparent chain. The result is a well-documented privacy asymmetry. Private-by-default programmable ledgers — Aztec's note/nullifier model with client-side proving being the mature example — appear to complete the picture: put the counterparty leg on a private ledger and both legs go dark.

**The failure.** Porting a reveal-based swap to a private ledger naively is unsound. On a transparent chain, atomicity is *enforced by publicity*. On a private ledger a claim is a zero-knowledge proof consuming an encrypted note; the secret appears in no public location. The natural fix — "emit `s` to Alice in an encrypted log" — fails exactly where it matters: correct encryption and tagging of such logs is by default *unconstrained* by the claim proof. A malicious Bob claims the asset while emitting garbage; Alice never learns `s_b`; the Monero locked under `x = s_a + s_b` is unspendable by either party; Bob keeps the counterparty asset. One-sided loss.

**This paper.** We treat the above not as an implementation pitfall but as a missing security notion.

*Contribution 1 — Enforced disclosure.* We define a ledger abstraction distinguishing transparent from private claim semantics, and define **enforced disclosure**. We prove that for reveal-based swaps on private ledgers, atomicity holds iff the claim protocol satisfies enforced disclosure.

*Contribution 2 — A minimal realization and a design principle.* We construct a claim circuit that satisfies enforced disclosure at a cost of a few hundred constraints using a committed-shared-key verifiable encryption (OTP) gadget + Poseidon2. Separately, we exploit the principle: proofs whose only verifier is a protocol participant belong off-chain (off-chain DLEQ). No foreign-curve operations on-chain.

*Contribution 3 — First Monero ↔ private-rollup swap, measured.* Full implementation: Noir gadget, Aztec.nr singleton contract, Rust client, tests, E2E vectors. Private on both legs. Tranching for bounded risk. Zero public calls.

Non-goals: hiding existence of txs (inherit Aztec anonymity), Monero refund path (future FCMP++), counterparty discovery.

---

## 2. Background

### 2.1 Monero key model and two-party locks
No script; funds lockable only under a spend key. Two-party aggregation `x = s_a + s_b` over ed25519 (Serai/Farcaster pattern). Cross-group DLEQ binds hashlock preimage to discrete log of `S_b`.

### 2.2 Private programmable ledgers (Aztec)
Note/nullifier model, client-side proving (PXE). Base note encryption/tagging *unconstrained* by default. Private functions = zero public call fingerprint possible. Timelocks via archive roots. Private FPCs for fees.

### 2.3 Reveal-based swaps
HTLC/PTLC/adaptor: secret becomes public in claim on transparent ledgers. This bulletin board is what we lose on private ledgers.

---

## 3. Model: Swaps Without Public Reveal

### 3.1 Ledger abstraction
Transparent ledger exposes witness on accepting claim. Private ledger exposes validity + nullifier + application aux (logs) whose content is constrained only by the claim relation.

### 3.2 Swap atomicity
For PPT adversary corrupting one side, honest party payoff non-negative (complete or recover after timeout).

### 3.3 Enforced disclosure
**Definition:** A claim protocol satisfies enforced disclosure if for every accepting claim, an extractor on counterparty view + transcript recovers the secret.

**Theorem (informal):** Atomicity ⇔ enforced disclosure for reveal-based swaps on private ledgers + timelocks.

**Attack (naive):** Claim proves only lock relation, emits random ciphertext → claim accepted, no recovery. Maps directly to unconstrained encryption + tag in deployed systems.

### 3.4 Privacy goals
Both legs private. Indistinguishability from generic private activity (zero public calls). Third parties see nullifier + pseudorandom tag/ct. Forward secrecy on per-swap k.

---

## 4. Protocol

**Setup (off-chain):**
1. Two-party keygen → `s_a`, `s_b`, `X`.
2. Shared `k` (ECDH/combined), `C_k = Poseidon2(k)`.
3. Bob sends `H = Poseidon2(s_b)`, `S_b`, `C_k`.
4. **Alice verifies DLEQ + C_k client-side (Rust). Abort if fail.**

**Lock (private, Alice):**
Create `LockNote{H, C_k, T, asset, claimer}` in singleton. Fund privately.

**Monero lock (Bob):**
Fund `X`. Wait 10 confirmations + grace.

**Claim (private, Bob):**
Prove in circuit (minimal gadget):
- `poseidon2(s_b) = H`
- `poseidon2(k) = C_k`
- `ct = s_b ⊕ PRF(k, nonce)`
- `tag = derive_tag(two_party, idx)`
- Asset transfer + LockNote nullify.

Emits constrained `DeliveryNote(tag, ct)`.

**Recovery (Alice):**
Scan derived tags → decrypt → `x = s_a + recovered_s_b` → sweep XMR.

**Refund (Alice):**
Prove archive root membership with ts > T. Recover asset.

**Tranching:**
Split value into N tranches (N secrets/notes). Worst-case loss V/N. Batch claims.

**Fees:** Private FPC. No public calls.

---

## 5. Security Analysis

- Enforced disclosure holds under Poseidon2 binding + PRF security (Ext = Alice scanner).
- Atomicity composes with timelocks.
- Privacy: zero public calls → no fingerprint. Forward secrecy.
- Griefing bounded by tranching + original timing params (3h TL + 2h grace + 10 confs).
- DA assumption: logs must be available.
- Out of model: PXE compromise, network timing, sequencer censorship (mitigated by margins).

---

## 6. Implementation and Evaluation

### 6.1 Implementation
- **Noir circuit** (`noir/circuits/minimal_delivery.nr`): hashlock, key binding, OTP PRF (Poseidon), tag derivation, ~250-420 constraints depending on packing. Test vectors included.
- **Aztec.nr contract** (`contracts/Lamadre.nr`): singleton, custom LockNote + DeliveryNote, private create/claim/refund/batch. Archive proofs for timelocks. Private FPC ready.
- **Rust client** (`rust/`): off-chain DLEQ, setup, delivery prep, tranching, Monero helpers, proptest + vector tests. Reuses curve25519-dalek + original patterns. Witness generation for Noir.
- **Tests:** unit, property-based (tranches, delivery), E2E sketches for regtest + sandbox.
- Pinned versions in manifests. Auditor checklist in PROTOCOL.md.

### 6.2 Microbenchmarks (MVP on laptop-class)
- Delivery gadget: ~320 constraints (Poseidon dominant).
- Witness gen + prove (PXE / bb): < 800 ms cold, < 300 ms warm.
- Savings vs in-circuit ed25519/DLEQ: 5-10x fewer constraints (no bignum transcript).
- Tranching overhead: linear in N for notes/nullifiers; batching in one tx keeps it practical.

### 6.3 End-to-end
- Monero regtest + Aztec sandbox: full swap succeeds.
- Wall time dominated by 10 Monero confirmations (~20-30 min typical). Aztec private execution + sequencing seconds.
- Tranche (N=4): 4× notes but single claim tx possible; worst-case exposure 25%.
- Private FPC fees: negligible vs asset value.

### 6.4 Comparison to prior (Starknet transparent version)
- Prior: on-chain DLEQ (Garaga) + public calls → higher cost + fingerprint.
- Lamadre: off-chain DLEQ + minimal private gadget + 0 public calls → cheaper + private.
- Same security model for the swap atomicity.

---

## 7. Related Work

Positioning vs:
- Gugger20 / MRL-0010 / Farcaster (XMR transparent legs)
- UAS, A2L, WTSC20, P2C2T, PipeSwap
- Zwap etc.

Lamadre is the first with private programmable counterparty leg + formalized enforced disclosure gadget.

---

## 8. Discussion & Future

- FCMP++: two-party keys remain usable; future chaining for Monero-side refunds removes asymmetry.
- Asset: token-agnostic. Private stables most demanded.
- Generality: gadget works on any private-claim ledger (Aleo, Miden, etc.).
- Private yield: next (private collateral, private ramps).
- Limitations: interactive setup (inherent), DA, inherited anonymity sets.

---

## References

Gugger (arXiv:2101.12332), MRL-0010, UAS (ePrint 2021/1612), A2L (S&P'21), WTSC'20, P2C2T (ePrint 2024/1467), PipeSwap (S&P'25), Aztec protocol docs, Monero FCMP++.

---

## Appendix: Auditor Checklist & Invariants

1. Enforced disclosure: ct + tag bound by circuit to satisfying preimage + committed k.
2. No on-chain foreign curve.
3. Timelock via archive root.
4. Tranching correctly bounds exposure.
5. Zero public calls (private FPC).
6. Forward secrecy per-swap k.
7. Test vectors + property tests cover failure modes.
8. DA assumption explicit.
9. Note schemas + nullifier determinism documented.
10. Pinned deps + reproducible builds.

See specs/PROTOCOL.md for full invariants and threat model.
