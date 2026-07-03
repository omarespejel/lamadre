//! Lamadre end-to-end flow simulation (off-chain heavy).
//! This binary demonstrates the full protocol flow using only the Rust client.
//! Aztec side is mocked (in real you would call aztec-wallet / PXE for the private fns).
//!
//! Run: cargo run --bin simulate_swap

use lamadre::*;
use curve25519_dalek::scalar::Scalar;

fn main() {
    println!("=== Lamadre Private XMR <-> Aztec Swap Simulation ===\n");

    // === SETUP (off-chain, interactive) ===
    println!("[1] Two-party keygen + setup");
    let (s_a, s_b) = monero::two_party_keygen();
    let setup = perform_setup(s_a, s_b).expect("setup succeeds");
    println!("   s_a, s_b shares generated");
    println!("   Aggregate X pub: {:?}", setup.x_pub);
    println!("   Hashlock H: {:x?}", setup.hashlock);
    println!("   Delivery key commit C_k: {:x?}", setup.c_k);
    println!("   DLEQ verified off-chain: OK (Alice would do this before locking)\n");

    // Alice "locks" on Aztec (mock)
    println!("[2] Alice creates LockNote on Aztec (private tx)");
    println!("   hashlock={:?}, c_k={:?}, timelock=now+3h, tranche 0/4", setup.hashlock, setup.c_k);
    // In real: aztec-wallet send create_lock --args ...
    println!("   LockNote created privately. Bob sees note commitment off-chain or via note.\n");

    // Bob locks XMR on regtest (mock)
    println!("[3] Bob locks XMR under aggregate key X on Monero regtest");
    println!("   Wait 10 confirmations + grace...\n");

    // === CLAIM (Bob) ===
    println!("[4] Bob claims on Aztec (private, with enforced disclosure gadget)");
    let nonce = [0x01u8; 32];
    let (ct, tag) = delivery::prepare_delivery_otp(
        setup.s_b.to_bytes(),
        setup.delivery_k,
        nonce,
        setup.delivery_k, // material
        0,
    );
    println!("   Proves in circuit:");
    println!("     - hash(s_b) == hashlock");
    println!("     - Poseidon(k) == c_k");
    println!("     - ct = s_b XOR PRF(k, nonce)   <--- constrained!");
    println!("     - tag = derive(...)            <--- constrained!");
    println!("   Emits DeliveryNote(tag={:x?}, ct=...) ", tag);
    println!("   Asset transferred to Bob. LockNote nullified.\n");

    // === RECOVERY (Alice) ===
    println!("[5] Alice recovers s_b from DeliveryNote");
    let recovered = delivery::verify_delivery(ct, tag, tag /* recomputed in real */, setup.delivery_k, nonce)
        .expect("tag matches, recovers secret");
    println!("   Recovered s_b (first bytes): {:x?}", &recovered[0..4]);

    let _final_x = recover_monero_spend(s_a, Scalar::from_bytes_mod_order(recovered));
    println!("   Reconstructed full spend secret x = s_a + s_b");
    println!("   Alice can now sweep the XMR on Monero side.\n");

    println!("=== SWAP COMPLETE (atomic, private on both legs) ===");
    println!("Tranching would repeat for other 3 tranches.");
}
