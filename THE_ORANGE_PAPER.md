# The Orange Paper: Bitcoin Protocol Specification
## A Complete Mathematical Description of the Bitcoin Consensus System

**Version 1.0**  
**Based on Bitcoin Core Implementation Analysis**  
**Authors: BTCDecoded.org, MyBitcoinFuture.com, @secsovereign**
---

## Abstract

This paper presents a complete mathematical specification of the Bitcoin consensus protocol as implemented in Bitcoin Core. Unlike previous descriptions, this specification is derived entirely from the current codebase and represents the protocol as it exists today, not as it was originally conceived. This "Orange Paper" serves as the definitive reference for Bitcoin's consensus rules, state transitions, and economic model.

## Document Structure

The Orange Paper is split into two documents for clarity:

| Document | Content |
|----------|---------|
| **[PROTOCOL.md](PROTOCOL.md)** | Consensus rules, invariants, predicates — *what must hold*. Implementation-agnostic. |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Implementation algorithms, design choices — *how to achieve it*. One valid approach among others. |

### PROTOCOL.md — Consensus Rules

Sections 1–9 (foundations, core, mempool), plus protocol portions of 10–13:

- **1–9**: Introduction, System Model, Mathematical Foundations, Constants, State Transitions, Economic Model, Proof of Work, Security Properties, Mempool Protocol
- **10**: Message Types (10.1), Block Sync (10.4), Transaction Relay (10.5)
- **11**: SegWit (11.1), Taproot (11.2), UTXO Commitments (11.4), Signet (11.5)
- **12**: Coinbase Transaction (12.2), Block Template Requirements (12.4)
- **13**: Integration Proofs (13.3)

### ARCHITECTURE.md — Implementation Design

- **10**: Connection Management (10.2), Peer Discovery (10.3), Dandelion++ (10.6)
- **11**: Chain Reorganization (11.3, 11.3.1)
- **12**: Block Template Generation (12.1), Mining Process (12.3)
- **13**: Performance (13.1), Security (13.2), Peer Consensus Protocol (13.4)
- **14**: Conclusion
- **15**: Governance Model

## Spec-Lock Verification

For full Z3 verification (default), run from `blvm-spec-lock`:

```bash
cd blvm-spec-lock
cargo run --bin cargo-spec-lock -- verify --strict \
  --spec-path ../blvm-spec/PROTOCOL.md --spec-path ../blvm-spec/ARCHITECTURE.md \
  --crate-path ../blvm-consensus
```

Or from `blvm-consensus` (with blvm-spec-lock sibling):

```bash
cd blvm-consensus
../blvm-spec-lock/target/release/cargo-spec-lock verify --strict \
  --spec-path ../blvm-spec/PROTOCOL.md --spec-path ../blvm-spec/ARCHITECTURE.md \
  --crate-path .
```

`--strict` fails on any partial (requires full Z3 verification). Z3 is the default feature; use `--no-default-features` only if you cannot build with libclang.

## References

- [PROTOCOL.md](PROTOCOL.md) — Full protocol specification
- [ARCHITECTURE.md](ARCHITECTURE.md) — Implementation architecture
- [docs/BLVM_SPEC_PROTOCOL_VS_ARCHITECTURE.md](../docs/BLVM_SPEC_PROTOCOL_VS_ARCHITECTURE.md) — Section classification
- [GOVERNANCE_SPECIFICATION.md](GOVERNANCE_SPECIFICATION.md) — Referenced by section 15

---

*This document represents the current state of Bitcoin. The protocol continues to evolve through the BIP process.*
