//! Provable delivery (OTP) preparation and verification.
//! Matches the Noir gadget: ct = s_b XOR PRF(k, nonce)
//! Tag derivation for constrained discovery.
//! Rust side uses SHA256-modeled Poseidon for witness generation compatibility.
//! Real circuit uses native Poseidon2.

use sha2::{Sha256, Digest};
use curve25519_dalek::scalar::Scalar;

/// Derive the shared delivery key k from the two-party shares (simple additive for demo;
/// production: ECDH(a, B) or HKDF on combined material + nonces).
pub fn derive_delivery_key(s_a: Scalar, s_b: Scalar) -> [u8; 32] {
    let combined = s_a + s_b;
    Sha256::digest(combined.as_bytes()).into()
}

/// Prepare the ciphertext + tag that Bob will prove in the claim gadget.
/// ct = secret XOR stream(k, nonce)
/// tag = PRF(two_party_material, tranche_idx)
pub fn prepare_delivery_otp(
    s_b: [u8; 32],
    k: [u8; 32],
    nonce: [u8; 32],
    two_party_material: [u8; 32],
    tranche_idx: u64,
) -> ([u8; 32], [u8; 32]) {
    let stream = prf_stream(k, nonce);
    let ct = xor_bytes(s_b, stream);

    let tag = derive_tag(two_party_material, tranche_idx);
    (ct, tag)
}

fn prf_stream(k: [u8; 32], nonce: [u8; 32]) -> [u8; 32] {
    // Model Poseidon PRF as sha256(k || nonce) for witness; circuit uses Poseidon2
    let mut hasher = Sha256::new();
    hasher.update(k);
    hasher.update(nonce);
    hasher.finalize().into()
}

fn derive_tag(material: [u8; 32], idx: u64) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(material);
    hasher.update(idx.to_le_bytes());
    hasher.finalize().into()
}

fn xor_bytes(a: [u8; 32], b: [u8; 32]) -> [u8; 32] {
    let mut out = [0u8; 32];
    for i in 0..32 {
        out[i] = a[i] ^ b[i];
    }
    out
}

/// Verify a received delivery (Alice side). Recovers s_b if tag matches expectation.
pub fn verify_delivery(
    ct: [u8; 32],
    tag: [u8; 32],
    expected_tag: [u8; 32],
    k: [u8; 32],
    nonce: [u8; 32],
) -> Option<[u8; 32]> {
    if tag != expected_tag {
        return None;
    }
    let stream = prf_stream(k, nonce);
    let recovered = xor_bytes(ct, stream);
    Some(recovered)
}