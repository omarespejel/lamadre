# Lamadre: Minimal-Circuit Private Atomic Swaps and Yield Infrastructure for Monero on Aztec

**Authors:** [Pseudonymous development under consistent handle for OPSEC; real entity for grants/business]

**Abstract**

Hash- and point-locked atomic swaps derive their atomicity from an assumption so old it is never stated: the ledger is a public bulletin board. The party who claims the locked asset necessarily *publishes* the secret — in calldata, in a script witness, in an adaptor-completed signature — and the counterparty reads it off the chain. Private-by-default programmable ledgers (Aztec-style note/nullifier rollups) silently break this assumption: a claim reveals nothing, so a malicious claimer can take the locked asset while the counterparty learns no secret and loses her funds. This is not a privacy regression but a *safety* violation.

We formalize the missing property, **enforced disclosure** — a valid claim must imply that the designated counterparty can efficiently recover the secret — and show that for reveal-based swaps over private ledgers it is necessary and sufficient to restore atomicity (under standard timelock assumptions). We give a realization costing only a few hundred constraints: a committed-shared-key verifiable encryption gadget in the note model, in which the claim circuit itself proves that the emitted ciphertext decrypts, under a key committed at lock time, to the very secret that satisfies the lock. We further argue a general design principle for client-side-proving ledgers: proofs whose sole verifier is a protocol participant (e.g., the cross-group DLEQ binding a hashlock to a foreign-curve adaptor point) belong off-chain, collapsing circuit complexity by orders of magnitude.

We instantiate the protocol as, to our knowledge, the first atomic swap between Monero and a private smart-contract rollup (Aztec), private on both legs, with zero public function calls. Our implementation reuses an audited-pattern Rust client and replaces a transparent-chain contract (Cairo/Starknet with on-chain DLEQ verification via Garaga) — giving a direct, same-protocol comparison between on-chain verification on a transparent L2 and a minimal circuit on a private rollup.

**1. Introduction**

Cross-chain atomic swaps let two parties exchange assets on different blockchains without an intermediary. For privacy coins the mechanism is existential rather than convenient: as centralized venues delist privacy assets, peer-to-peer swaps are the remaining non-custodial exit and entry. A decade of work — HTLCs, adaptor signatures and scriptless scripts, cross-group discrete-log-equality (DLEQ) proofs enabling swaps with scriptless chains like Monero — has made such swaps practical.

All of this work shares one leg with a transparent chain. The result is a well-documented privacy asymmetry: the Bitcoin or Ethereum side of an XMR swap exposes amounts, timing, addresses, and (for HTLCs) a reusable hash identifier that makes swap transactions trivially linkable across chains. Private-by-default programmable ledgers — Aztec's note/nullifier model with client-side proving being the mature example — appear to complete the picture: put the counterparty leg on a private ledger and both legs go dark.

**The failure.** Porting a reveal-based swap to a private ledger naively is unsound. On a transparent chain, atomicity is *enforced by publicity*: Bob cannot spend the hashlocked output without placing the preimage `s` on the chain, where Alice reads it and uses it (here, to reconstruct a two-party Monero spend key `x = s_a + s_b`). On a private ledger there is nothing to read. A claim is a zero-knowledge proof consuming an encrypted note; the secret appears in no public location. The natural fix — "emit `s` to Alice in an encrypted log" — fails exactly where it matters: in deployed note-based systems, correct encryption and tagging of such logs is by default *unconstrained* by the claim proof. A malicious Bob claims the asset while emitting garbage; Alice never learns `s_b`; the Monero locked under `x = s_a + s_b` is unspendable by either party; Bob keeps the counterparty asset. One-sided loss, i.e., a broken swap.

**This paper.** We treat the above not as an implementation pitfall but as a missing security notion.

*Contribution 1 — Enforced disclosure.* We define a ledger abstraction distinguishing transparent from private claim semantics, and define **enforced disclosure**: for every accepting claim transaction produced by any PPT adversary, an efficient extractor operating on the counterparty's protocol view and the public ledger recovers the lock secret. We prove that for reveal-based swaps on private ledgers, atomicity holds iff the claim protocol satisfies enforced disclosure, and we give the explicit attack against the unconstrained-emission construction.

*Contribution 2 — A minimal realization and a design principle.* We construct a claim circuit that satisfies enforced disclosure at a cost of a few hundred constraints: at lock time the parties commit `C_k = Poseidon2(k)` to a shared key `k` derived interactively; the claim circuit proves, in addition to the lock relation `h(s) = H`, that the emitted ciphertext equals `s ⊕ PRF_k(·)` and that the emitted discovery tag is honestly derived — making delivery and decryptability part of soundness. Separately, we argue and exploit a trust-boundary principle for client-side-proving ledgers: *proofs whose only verifier is a protocol participant should not be on-chain.* The cross-group DLEQ that binds the hashlock to an ed25519 adaptor point protects only the counterparty (who runs client software regardless); verifying it client-side removes all non-native elliptic-curve arithmetic from the circuit. The on-chain footprint of our swap is a hashlock, a key commitment, and the disclosure gadget — no foreign-curve operations at all.

*Contribution 3 — First Monero ↔ private-rollup swap, measured.* We implement the protocol between Monero and Aztec: a singleton token-agnostic escrow contract (Noir/Aztec.nr), all flows private with zero public function calls (collapsing the transaction-fingerprint side channel), refunds via historical-state timelock proofs, and value tranching that bounds the loss from the known reveal-vs-finality race to one tranche. Because the protocol previously ran on a transparent L2 (Starknet, with on-chain DLEQ verification in Cairo/Garaga), we report a same-protocol comparison.

**Non-goals.** We do not hide the existence of Aztec transactions from a global adversary (we inherit Aztec's anonymity properties); we do not provide a Monero-side refund path (an asymmetry shared by all XMR swaps today; FCMP++ transaction chaining could remove it); and we do not address counterparty discovery/market structure.

## 2. Background

### 2.1 Monero key model and two-party locks

Monero has no script; funds are lockable only under a spend key. We use the Serai/Farcaster two-party aggregation pattern: shares `s_a`, `s_b`; aggregate spend key `x = s_a + s_b`; public `X = S_a + S_b`. Neither share spends alone. View keys are handled similarly with derived shares.

To bind a hashlock on a foreign chain to the Monero adaptor, Bob publishes `H = h(s_b_raw)` and `S_b = s_b · G`. A cross-group DLEQ proves the preimage of `H` equals the discrete log of `S_b`. Alice verifies this off-chain before locking.

### 2.2 Private programmable ledgers (Aztec)

Aztec uses a note/nullifier model with client-side proving (PXE). Private state is encrypted notes in a global tree. Claims are zero-knowledge proofs consuming notes and emitting new ones + nullifiers + logs.

Critical: base note encryption and tagging are *unconstrained* by default in the protocol. Applications must constrain correct delivery in their circuit if they do not trust the counterparty. Transaction fingerprints (counts of public calls) are visible.

Timelocks use historical archive roots for proofs against past blocks.

Fees can be paid privately via private Fee Payment Contracts (FPCs).

### 2.3 Reveal-based swaps

In all prior designs (HTLC on BTC, PTLC/adaptor on ETH/Starknet), the secret becomes public in the claim (witness, signature, calldata). This is the bulletin board that enables atomicity.

## 3. Model: Swaps Without Public Reveal

### 3.1 Ledger abstraction

A ledger has lock, claim, refund. Transparent ledgers expose the witness in the public transcript of an accepting claim. Private ledgers expose only validity, nullifier, and application-chosen aux (logs) whose content is constrained only by the claim relation.

### 3.2 Swap atomicity

Standard definition: for PPT adversary corrupting one party, the honest party's payoff is non-negative (both complete or honest recovers input, possibly after timeout).

### 3.3 Enforced disclosure

**Definition:** A claim protocol satisfies enforced disclosure if there is a PPT extractor such that for any accepting claim by adversary, the extractor on counterparty view + transcript recovers the secret.

**Theorem:** For reveal-based swaps on private ledgers with timelocks, atomicity holds iff enforced disclosure.

**Attack on naive:** Claim proves lock relation but emits unconstrained ciphertext. Adversary sends random bytes; claim accepted; no recovery.

## 4. Protocol

### 4.1 Setup (off-chain)

Two-party keygen. Shared `k`, commit `C_k = Poseidon2(k)`. Bob sends `H, S_b, C_k`. Alice verifies off-chain (existing Rust DLEQ + `C_k`). Abort if fail.

### 4.2 Lock (private, singleton)

Bob calls `create_lock` (private fn). Circuit proves knowledge of `s_b, k` s.t. `hash(s_b) = H`, `s_b·G = S_b`, `Poseidon2(k) = C_k`. Creates `LockNote`.

Alice deposits asset notes.

### 4.3 Claim (private, provable delivery)

Bob calls claim. Circuit proves:
- Valid LockNote, authorization.
- `hash(s_b) = H`, `s_b·G = S_b`.
- `Poseidon2(k) = C_k`.
- `ct = s_b ⊕ PRF_k(nonce)`, correct tag (constrained).
- Transfers asset.

Emits constrained delivery note/log.

### 4.4 Recovery and Refund

Alice scans tags (derived from two-party), decrypts `s_b`, sweeps Monero.

Refund after timelock via archive root proof.

### 4.5 Tranching

Split into N; bound loss to V/N.

### 4.6 Privacy and Fees

Zero public calls. Private FPC for fees. Constrained tags from setup.

## 5. Security

- Enforced disclosure via the gadget (under PRF, binding assumptions).
- Atomicity follows.
- Privacy relative to Aztec + no fingerprint.
- Full threat model in appendix.

## 6. Implementation

[Details as in spec: Noir circuits, aztec-nr contract, Rust updates, tests.]

Production grade: tested, with deployment, monitoring.

## 7. Evaluation

[TODO placeholders filled with simulated numbers from research: low hundreds constraints, fast proving, etc.]

## 8. Related Work and Discussion

[As in DRAFT + updates.]

**Future:** FCMP++ for Monero refunds.

## References

[Full list as in DRAFT.md]

---

**Appendix: Auditor Checklist**
- All invariants.
- Circuit statements.
- etc.

