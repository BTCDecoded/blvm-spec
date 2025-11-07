# The Orange Paper: Bitcoin Protocol Specification

[![CI](https://github.com/BTCDecoded/bllvm-spec/workflows/CI/badge.svg)](https://github.com/BTCDecoded/bllvm-spec/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A complete mathematical specification of the Bitcoin consensus protocol derived from Bitcoin Core implementation.

## 📄 The Paper

**[Read THE_ORANGE_PAPER.md](THE_ORANGE_PAPER.md)** - The complete mathematical specification

## 🎯 What This Is

Unlike previous descriptions, this specification is derived entirely from the current Bitcoin Core codebase and represents the protocol as it exists today. It provides:

- **Complete State Machine**: Formal specification of Bitcoin's state transitions
- **Economic Model**: Mathematical description of the monetary system  
- **Validation Rules**: Precise definition of all consensus-critical checks
- **Security Properties**: Formal statements of Bitcoin's security guarantees

## 🧮 Mathematical Foundations

The specification uses formal mathematical notation:

- **Hash Values**: $\mathbb{H} = \{0,1\}^{256}$ - Set of 256-bit hashes
- **Byte Strings**: $\mathbb{S} = \{0,1\}^*$ - Set of byte strings
- **Natural Numbers**: $\mathbb{N} = \{0, 1, 2, \ldots\}$ - Set of natural numbers
- **Integers**: $\mathbb{Z} = \{\ldots, -2, -1, 0, 1, 2, \ldots\}$ - Set of integers

### Core Data Structures
- **OutPoint**: $\mathcal{O} = \mathbb{H} \times \mathbb{N}$
- **Transaction**: $\mathcal{TX} = \mathbb{N} \times \mathcal{I}^* \times \mathcal{T}^* \times \mathbb{N}$
- **Block**: $\mathcal{B} = \mathcal{H} \times \mathcal{TX}^*$
- **UTXO Set**: $\mathcal{US} = \mathcal{O} \rightarrow \mathcal{U}$

## 📖 Document Structure

The Orange Paper is organized into 14 sections covering:

1. **[Introduction](THE_ORANGE_PAPER.md#1-introduction)** - Overview and key contributions
2. **[System Model](THE_ORANGE_PAPER.md#2-system-model)** - Participants and network assumptions
3. **[Mathematical Foundations](THE_ORANGE_PAPER.md#3-mathematical-foundations)** - Basic types and data structures
4. **[Consensus Constants](THE_ORANGE_PAPER.md#4-consensus-constants)** - Monetary, block, and script constants
5. **[State Transition Functions](THE_ORANGE_PAPER.md#5-state-transition-functions)** - Transaction and block validation
6. **[Economic Model](THE_ORANGE_PAPER.md#6-economic-model)** - Block subsidy, total supply, and fee market
7. **[Proof of Work](THE_ORANGE_PAPER.md#7-proof-of-work)** - Difficulty adjustment and block validation
8. **[Security Properties](THE_ORANGE_PAPER.md#8-security-properties)** - Economic, cryptographic, and merkle tree security
9. **[Mempool Protocol](THE_ORANGE_PAPER.md#9-mempool-protocol)** - Transaction validation and RBF
10. **[Network Protocol](THE_ORANGE_PAPER.md#10-network-protocol)** - P2P communication and synchronization
11. **[Advanced Features](THE_ORANGE_PAPER.md#11-advanced-features)** - SegWit, Taproot, and chain reorganization
12. **[Mining Protocol](THE_ORANGE_PAPER.md#12-mining-protocol)** - Block template generation and mining process
13. **[Implementation Considerations](THE_ORANGE_PAPER.md#13-implementation-considerations)** - Performance and security
14. **[Conclusion](THE_ORANGE_PAPER.md#14-conclusion)** - Summary and applications

## 🚀 Usage

This specification can be used for:

- **Formal Verification**: Proving correctness properties of Bitcoin implementations
- **Protocol Analysis**: Understanding security and economic properties
- **Implementation Reference**: Building Bitcoin-compatible software
- **Academic Research**: Studying distributed consensus systems

For best viewing experience, use a Markdown viewer that supports LaTeX mathematical notation and Mermaid diagrams.

## 🤝 Contributing

We welcome contributions to improve the mathematical precision and completeness of this specification.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes with clear mathematical justification
4. Ensure all formulas render correctly
5. Commit your changes (`git commit -am 'Add mathematical proof for X'`)
6. Push to the branch (`git push origin feature/improvement`)
7. Create a Pull Request

### Contribution Guidelines
- **Mathematical Accuracy**: All formulas must be mathematically correct
- **Proof Completeness**: Provide complete proofs for new theorems
- **Implementation Validation**: Verify against Bitcoin Core when possible
- **Clear Notation**: Use consistent mathematical notation throughout
- **Cross-References**: Update related sections when making changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 References

### Bitcoin Protocol
- [Bitcoin Core Implementation](https://github.com/bitcoin/bitcoin)
- [Bitcoin Improvement Proposals (BIPs)](https://github.com/bitcoin/bips)
- Satoshi Nakamoto, ["Bitcoin: A Peer-to-Peer Electronic Cash System"](https://bitcoin.org/bitcoin.pdf) (2008)

### Cryptographic Standards
- [FIPS 180-4: Secure Hash Standard](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
- [SEC 2: Recommended Elliptic Curve Domain Parameters](https://www.secg.org/sec2-v2.pdf)
- [RFC 6979: Deterministic Usage of DSA and ECDSA](https://tools.ietf.org/html/rfc6979)

### Mathematical Concepts
- [Set Theory](https://en.wikipedia.org/wiki/Set_theory)
- [Discrete Mathematics](https://en.wikipedia.org/wiki/Discrete_mathematics)
- [Cryptographic Hash Function](https://en.wikipedia.org/wiki/Cryptographic_hash_function)
- [Elliptic Curve Cryptography](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography)

---

**Version**: 1.0  
**Authors**: BTCDecoded.org, @secsovereign

*This document represents the current state of Bitcoin. The protocol continues to evolve through the BIP process.*
