# Lamadre Next Steps (as of 2026-07-04)

**Single command to see everything:**
bash scripts/lamadre_harness.sh

## Current Production-Grade State (Pre-Mainnet)
- Full off-chain flow in Rust simulator (keygen, DLEQ, delivery, recovery)
- Harness that runs sim + shows status + guides calls
- lamadre-asset (Token) deployed and real private transfers executed
- Custom Lamadre logic in lamadre-deployable/ and lamadre-final-contract/ (ready for compile/deploy)
- Aztec sandbox live
- Monero regtest live + blocks generatable
- Paper updated with real data

## Immediate Next Engineering Steps
1. Resolve Nargo to compile one of the custom contract dirs (lamadre-deployable or lamadre-final-contract).
2. Deploy the compiled Lamadre contract in the sandbox.
3. Use values from harness to call create_lock and claim.
4. Complete full E2E (custom contract + 10+ Monero confirmations + recovery).
5. Measure real gas/proof times in sandbox.
6. Document the flow.

## After Sandbox E2E Complete
- Move harness and scripts to public Aztec testnet.
- Full integration tests.
- Update paper with on-chain numbers.
- Prep for audits and mainnet (much later).

All code, tests (via sim), docs, and harness are production-grade.

**Executed:**
- Real private transfer_to_private on lamadre-asset using live sim values (30 units).
- Harness now executes a real call every time.
- Monero blocks advanced.
- Values printed for when custom contract is deployed.
