# The Orange Paper: Bitcoin Protocol Specification
## A Complete Mathematical Description of the Bitcoin Consensus System

**Version 1.0**  
**Consensus specification (implementation-agnostic)**  
**Authors: BTCDecoded.org, MyBitcoinFuture.com, @secsovereign**
---

## Abstract

This paper presents a mathematical specification of the Bitcoin consensus protocol as observed on the live network and in widely deployed node software. This “Orange Paper” states rules, invariants, and state transitions in precise notation so independent implementations can be checked for equivalence.

## Document Structure

The Orange Paper is split into two documents for clarity:

| Document | Content |
|----------|---------|
| **[PROTOCOL.md](PROTOCOL.md)** | Consensus rules, invariants, predicates (*what must hold*). Implementation-agnostic. |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Implementation algorithms, design choices (*how to achieve it*). One valid approach among others. |

**Outside this specification:** [Bitcoin Commons governance](https://github.com/BTCDecoded/governance) (repository and process policy) is not Bitcoin consensus and is not part of PROTOCOL.md or ARCHITECTURE.md.

### PROTOCOL.md: Consensus Rules

Sections 1–9 (foundations, core, mempool), plus protocol portions of 10–13:

- **1–9**: Introduction, System Model, Mathematical Foundations, Constants, State Transitions, Economic Model, Proof of Work, Security Properties, Mempool Protocol
- **10**: Message Types (10.1), Block Sync (10.4), Transaction Relay (10.5)
- **11**: SegWit (11.1), Taproot (11.2), UTXO Commitments (11.4), Signet (11.5)
- **12**: Coinbase Transaction (12.2), Block Template Requirements (12.4)
- **13**: Integration Proofs (13.3)

### ARCHITECTURE.md: Implementation Design

- **10**: Connection Management (10.2), Peer Discovery (10.3), Dandelion++ (10.6)
- **11**: Chain Reorganization (11.3, 11.3.1)
- **12**: Block Template Generation (12.1), Mining Process (12.3)
- **13**: Performance (13.1), Security (13.2), Peer Consensus Protocol (13.4)
- **14**: Conclusion

## Spec-Lock Verification

Clone [blvm-spec](https://github.com/BTCDecoded/blvm-spec), [blvm-spec-lock](https://github.com/BTCDecoded/blvm-spec-lock), and [blvm-consensus](https://github.com/BTCDecoded/blvm-consensus) to paths of your choice. Set absolute paths (or shell variables) for each working copy, for example:

```bash
export BLVM_SPEC_ROOT=/path/to/blvm-spec
export BLVM_SPEC_LOCK_ROOT=/path/to/blvm-spec-lock
export BLVM_CONSENSUS_ROOT=/path/to/blvm-consensus
```

**From `blvm-spec-lock`** (after `cargo build --release --bin cargo-spec-lock`):

```bash
cd "$BLVM_SPEC_LOCK_ROOT"
cargo run --release --bin cargo-spec-lock -- verify --strict \
  --spec-path "$BLVM_SPEC_ROOT/PROTOCOL.md" --spec-path "$BLVM_SPEC_ROOT/ARCHITECTURE.md" \
  --crate-path "$BLVM_CONSENSUS_ROOT"
```

**Or from `blvm-consensus`** using a built `cargo-spec-lock` binary:

```bash
cd "$BLVM_CONSENSUS_ROOT"
"$BLVM_SPEC_LOCK_ROOT/target/release/cargo-spec-lock" verify --strict \
  --spec-path "$BLVM_SPEC_ROOT/PROTOCOL.md" --spec-path "$BLVM_SPEC_ROOT/ARCHITECTURE.md" \
  --crate-path .
```

`--strict` fails on any partial (requires full Z3 verification). Z3 is the default feature; use `--no-default-features` only if you cannot build with libclang.

## References

- [PROTOCOL.md](PROTOCOL.md): Full protocol specification
- [ARCHITECTURE.md](ARCHITECTURE.md): Implementation architecture

Protocol vs. architecture section placement is summarized in the **Document Structure** table above; there is no separate classification file in this repository.

---

*This document represents the current state of Bitcoin. The protocol continues to evolve through the BIP process.*
