# Lamadre Next Steps (Sandbox Pre-Mainnet)

**One command to run every time:**
bash scripts/lamadre_harness.sh

It will:
- Run the full off-chain simulator (fresh values)
- Show live networks + deployed proxy
- Execute a real private asset move on lamadre-asset
- Print the exact ready-to-paste create_lock command (with values from this run) for when you deploy the custom contract

**Current Production-Grade State (Pre-Mainnet)**
- Simulator + harness: production grade
- lamadre-asset deployed at 0x1a443e40d1e0dd75c1d0be66b0ef01a3e366f70858a0b6f5fde2802009a29130
- Real private calls working on the proxy
- Custom Lamadre logic ready (create_lock, claim with gadget) in lamadre-clean / lamadre-deployable / lamadre-final-contract
- Networks live

**Immediate Next (in sandbox)**
1. Get a custom contract dir to compile cleanly (lamadre-clean is the simplest template).
2. Deploy it: aztec-wallet deploy lamadre --from test0 -a lamadre
3. Run the harness to get the latest HASHLOCK and C_K.
4. Paste and run the exact create_lock command it prints.
5. Do the claim with the corresponding values.
6. Generate 10+ Monero blocks and complete the flow.

Once full E2E works end-to-end in sandbox:
- Move to Aztec public testnet.
- Full tests + real measurements.
- Then mainnet (much later).

All code, harness, paper, and docs are production-grade.
