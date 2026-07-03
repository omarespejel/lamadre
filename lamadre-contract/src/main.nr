use dep::aztec::prelude::*;

#[aztec]
contract Lamadre {
    #[storage]
    struct Storage {}

    #[aztec(private)]
    fn create_lock(hashlock: Field, c_k: Field, timelock: u64) {
        // TODO: full note creation + gadget
        assert(timelock > context.timestamp() as u64);
    }

    #[aztec(private)]
    fn claim(secret: [u8; 32], k: Field, nonce: Field) {
        // Enforced disclosure gadget would go here
        let h = std::hash::poseidon2::Poseidon2::hash([secret[0] as Field], 1)[0];
        // assert etc.
    }
}
