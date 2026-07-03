//! Integration / property style tests + vectors from original monero-starknet work + new OTP cases.
//! Run: cargo test

use lamadre::*;
use sha2::Digest;

#[test]
fn original_vector_dleq_compat() {
    // Example vector (would be taken from original repo test vectors)
    let s_b = curve25519_dalek::scalar::Scalar::from(42u64);
    let h: [u8; 32] = sha2::Sha256::digest(s_b.as_bytes()).into();
    let pt = (s_b * curve25519_dalek::constants::ED25519_BASEPOINT_POINT).compress().0;
    assert!(verify_dleq_offchain(h, s_b, pt).unwrap());
}

#[test]
fn otp_new_vectors() {
    for i in 0u64..8 {
        let sb = [i as u8; 32];
        let k = [(i+1) as u8; 32];
        let n = [0xAA; 32];
        let mat = [0xBB; 32];
        let (ct, tag) = delivery::prepare_delivery_otp(sb, k, n, mat, i);
        let rec = delivery::verify_delivery(ct, tag, /* recompute expected */ {
            let mut hh = sha2::Sha256::new(); hh.update(mat); hh.update(i.to_le_bytes()); hh.finalize().into()
        }, k, n).unwrap();
        assert_eq!(rec, sb);
    }
}