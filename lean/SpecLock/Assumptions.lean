namespace SpecLock

/-- Cryptographic hypotheses used by a particular theorem.
    These are fields a proof takes as an argument. They are not axioms:
    a global hash-injectivity axiom is false by the pigeonhole principle. -/
structure CryptoAssumptions where
  sha256Preimage : Prop
  ripemd160Preimage : Prop
  secp256k1DiscreteLog : Prop
  /-- Theorem 8.3, used only as a hypothesis. -/
  signatureUnforgeable : Prop

end SpecLock
