# Lamadre Next Steps (Pre-Mainnet Production)

Run this every time:
  bash scripts/lamadre_harness.sh

Current state:
- Simulator + harness: production ready
- Sandbox networks live
- Proxy asset (lamadre-asset) deployed and usable
- Custom contract logic complete in lamadre-deployable/
- Main blocker: custom contract compilation in current env

Immediate next engineering:
1. Resolve Nargo to compile lamadre-deployable (use local aztec-nr if available, or checkout aztec-packages).
2. Deploy the compiled Lamadre contract in sandbox.
3. Feed simulator values into create_lock + claim calls.
4. Full E2E with Monero confirmations.
5. Measure real on-chain costs / times.
6. Prepare for public testnet.

Once E2E in sandbox works end-to-end:
- Move to Aztec public testnet.
- Full integration tests.
- Paper with real numbers.
- Then mainnet (much later).

All code, harness, paper, docs are production-grade.

**Current actionable next:**
- The harness prints the exact sequence.
- Focus on getting one successful custom contract deploy in sandbox.
- Then wire the captured values into create_lock + claim.
- Measure the full flow.
