# Lamadre Aztec Contract Skeleton

This is the production-ready structure for the Lamadre singleton private escrow contract.

## After you have Aztec tools active (from the run):

```bash
export PATH="/opt/homebrew/opt/node@24/bin:/Users/espejelomar/.aztec/bin:$PATH"
eval $(/Users/espejelomar/.aztec/bin/aztec-up env)

# In this dir (or copy main.nr + Nargo.toml into a fresh `aztec project`)
aztec-nargo compile   # or the equivalent aztec command for the contract
```

## Key pieces (from the redesign)

- Private `create_lock`
- Private `claim` that **must** emit constrained `ct` + `tag` (enforced disclosure via committed-key OTP + Poseidon2)
- Private `refund` using archive root for timelock
- Tranching support

See the parent repo `contracts/Lamadre.nr` (original detailed pseudocode), `noir/circuits/minimal_delivery.nr` (gadget), and the Rust simulator which already proves the flow.

When the local network is up (`aztec start --local-network`), use `aztec-wallet` to drive private transactions and validate that a claim without correct delivery is rejected by the circuit.

This is the minimal on-chain footprint that makes the Monero leg atomic and private.
