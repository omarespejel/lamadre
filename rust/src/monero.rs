//! Monero two-party key handling (re-exports / thin wrapper over original patterns).
//! Two-party aggregation x = s_a + s_b over ed25519 scalar.
//! In production: integrate real monero-wallet / Serai two-party code + view key handling.

use curve25519_dalek::scalar::Scalar;
use rand::rngs::OsRng;
use rand::RngCore;

/// Perform two-party key generation (interactive protocol).
/// Returns (s_a, S_a) for Alice, (s_b, S_b) for Bob.
/// In real: multiple roundtrips with zero checks + range proofs.
pub fn two_party_keygen() -> (Scalar, Scalar) {
    // Placeholder: independent random. Real protocol exchanges commitments first.
    // curve25519-dalek v4: generate via bytes (rand feature not directly on Scalar without extra).
    let mut rng = OsRng;
    let mut bytes_a = [0u8; 32];
    let mut bytes_b = [0u8; 32];
    rng.fill_bytes(&mut bytes_a);
    rng.fill_bytes(&mut bytes_b);
    let s_a = Scalar::from_bytes_mod_order(bytes_a);
    let s_b = Scalar::from_bytes_mod_order(bytes_b);
    (s_a, s_b)
}

/// Aggregate public key X = (s_a + s_b) * G
pub fn aggregate_spend_key(s_a: Scalar, s_b: Scalar) -> curve25519_dalek::edwards::CompressedEdwardsY {
    let x = s_a + s_b;
    (x * curve25519_dalek::constants::ED25519_BASEPOINT_POINT).compress()
}

/// Reconstruct spend secret after recovery of s_b
pub fn reconstruct_spend_key(s_a: Scalar, s_b: Scalar) -> Scalar {
    s_a + s_b
}

// Future: FCMP++ note on GSP spend authorization support for aggregated keys.
