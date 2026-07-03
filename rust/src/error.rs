use thiserror::Error;

#[derive(Error, Debug)]
pub enum LamadreError {
    #[error("DLEQ verification failed")]
    DleqVerificationFailed,
    #[error("invalid share or keygen")]
    InvalidKeygen,
    #[error("delivery preparation failed")]
    DeliveryError,
    #[error("tranche error: {0}")]
    TrancheError(String),
    #[error("crypto error: {0}")]
    Crypto(String),
    #[error("io: {0}")]
    Io(#[from] std::io::Error),
}