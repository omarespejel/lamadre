# Lamadre Next Steps (Sandbox Pre-Mainnet)

**Run every session:**
bash scripts/lamadre_harness.sh

It will:
- Run the full simulator
- Show live status
- Execute a real private asset move on the deployed lamadre-asset
- Print values for the custom Lamadre contract

**Current State**
- Simulator + harness: production ready
- lamadre-asset deployed and real calls working
- Custom contract logic in lamadre-clean/ and templates
- Networks live

**Immediate Next**
1. Get custom Lamadre compiled (lamadre-clean or deployable) using aztec compile.
2. Deploy it.
3. Wire the captured HASHLOCK / C_K into create_lock + claim.
4. Complete E2E with 10+ Monero confirmations.

Once sandbox E2E is solid: move to public testnet.
**Latest executed:**
- Real private transfer_to_private on lamadre-asset with live values (30 units).
- Harness now always runs the sim + a real call + prints the exact create_lock command template with values.
- Monero blocks requested.
