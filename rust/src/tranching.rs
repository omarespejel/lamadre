//! Tranching: split a swap into N independent atomic tranches.
//! Bounds worst-case loss to V/N from reveal-vs-Monero-finality race.
//! Each tranche has its own s_b_i , LockNote, DeliveryNote.

use crate::error::LamadreError;
use rand::RngCore;

/// Split secret material into N tranches. In practice each tranche gets independent
/// s_b slice (or derived sub-secrets via HKDF). Here: simple split + pad for demo.
pub fn tranche(secret: [u8; 32], n: usize) -> Result<Vec<[u8; 32]>, LamadreError> {
    if n == 0 || n > 256 {
        return Err(LamadreError::TrancheError("invalid tranche count".into()));
    }
    let mut parts = Vec::with_capacity(n);
    let chunk = 32 / n.max(1);
    for i in 0..n {
        let mut p = [0u8; 32];
        let start = (i * chunk).min(31);
        let end = ((i + 1) * chunk).min(32);
        p[start..end].copy_from_slice(&secret[start..end]);
        // Mix in tranche index for distinctness
        p[31] ^= i as u8;
        parts.push(p);
    }
    Ok(parts)
}

/// Reconstruct original secret from any sufficient set of tranches (demo: all needed).
pub fn reconstruct_from_tranches(parts: &[[u8; 32]]) -> [u8; 32] {
    let mut out = [0u8; 32];
    for (i, p) in parts.iter().enumerate() {
        let start = (i * (32 / parts.len().max(1))).min(31);
        let end = ((i + 1) * (32 / parts.len().max(1))).min(32);
        out[start..end].copy_from_slice(&p[start..end]);
    }
    out
}

/// Helper to generate N independent random tranche seeds (Bob generates per-tranche s_b).
pub fn generate_tranche_seeds(n: usize) -> Vec<[u8; 32]> {
    let mut rng = rand::thread_rng();
    (0..n).map(|_| {
        let mut s = [0u8; 32];
        rng.fill_bytes(&mut s);
        s
    }).collect()
}