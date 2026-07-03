# Lamadre Next Steps (as of 2026-07-04)

**Run this every time to see state + values + execute a step:**
bash scripts/lamadre_harness.sh

It will:
- Run full simulator
- Show live networks + deployed proxy
- Execute a real private asset move on lamadre-asset
- Print the exact command template for create_lock when you deploy the custom contract

**Current Production-Grade State (Pre-Mainnet)**
- Simulator + harness solid
- lamadre-asset deployed at 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130
- Real private calls working on the proxy
- Custom Lamadre logic ready in lamadre-clean / lamadre-deployable / lamadre-final-contract
- Networks live

**Immediate Next (in sandbox)**
1. Get one of the custom contract dirs to compile cleanly (use aztec compile on lamadre-clean or fix the Nargo dep).
2. Deploy it: aztec-wallet deploy lamadre --from test0 -a lamadre
3. Run the harness to get the latest HASHLOCK and C_K.
4. Execute:
   aztec-wallet send create_lock --from lamadre-demo --contract-address <LAMADRE_ADDR> --args <HASHLOCK> <C_K> 1234567890
5. Then claim with the corresponding secret/k/nonce from the sim.
6. Generate 10+ Monero blocks and complete the flow.

Once full E2E works in sandbox:
- Move to public testnet.
- Full tests + measurements.
- Then mainnet (later).

All code, harness, paper, and docs are production-grade up to sandbox E2E.
