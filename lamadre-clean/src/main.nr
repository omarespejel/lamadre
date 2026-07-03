use dep::aztec::prelude::*;

#[aztec]
contract Lamadre {
    #[storage]
    struct Storage {}

    #[aztec(private)]
    fn create_lock(hashlock: Field, adaptor: [u8; 32], c_k: Field, timelock: u64) {
        assert(timelock > (context.timestamp() as u64) + 10800);
    }

    #[aztec(private)]
    fn claim(secret: [u8; 32], k: Field, nonce: Field, two_party_material: Field, tranche_idx: Field) {
        let h = std::hash::poseidon2::Poseidon2::hash([secret[0] as Field], 1)[0];
    }

    #[aztec(private)]
    fn refund(timelock: u64) {}
}
