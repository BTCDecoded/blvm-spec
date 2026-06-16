# The Orange Paper: Bitcoin Protocol Specification
## A Complete Mathematical Description of the Bitcoin Consensus System

**Version 1.0**  
**Consensus specification (implementation-agnostic)**  
**Authors: BTCDecoded.org, MyBitcoinFuture.com, @secsovereign**
---

## Abstract

This paper presents a mathematical specification of the Bitcoin consensus protocol as observed on the live network and in widely deployed node software. Unlike informal descriptions, this work states rules, invariants, and state transitions in precise notation so independent implementations can be checked for equivalence. This “Orange Paper” is intended as a definitive reference for consensus rules, state transitions, and the imposed economic model.

## Table of Contents

1. [Introduction](#1-introduction)
   - 1.1 [Key Contributions](#11-key-contributions)
   - 1.2 [Document Structure](#12-document-structure)
2. [System Model](#2-system-model)
   - 2.1 [Participants](#21-participants)
   - 2.2 [Network Assumptions](#22-network-assumptions)
   - 2.2.1 [Networks and Parameters](#221-networks-and-parameters)
3. [Mathematical Foundations](#3-mathematical-foundations)
   - 3.1 [Basic Types](#31-basic-types)
   - 3.2 [Core Data Structures](#32-core-data-structures)
   - 3.3 [Script System](#33-script-system)
4. [Consensus Constants](#4-consensus-constants)
   - 4.1 [Monetary Constants](#41-monetary-constants)
   - 4.2 [Block Constants](#42-block-constants)
   - 4.3 [Script Constants](#43-script-constants)
   - 4.4 [Difficulty Constants](#44-difficulty-constants)
5. [State Transition Functions](#5-state-transition-functions)
   - 5.1 [Transaction Validation](#51-transaction-validation)
     - 5.1.1 [Transaction Sighash Calculation](#511-transaction-sighash-calculation)
   - 5.2 [Script Execution](#52-script-execution)
     - 5.2.1 [P2SH Push-Only Validation](#521-p2sh-push-only-validation)
     - 5.2.2 [Signature Operation Counting](#522-signature-operation-counting)
     - 5.2.3 [Stack Operations](#523-stack-operations)
     - 5.2.4 [Conditional Opcode Execution](#524-conditional-opcode-execution)
     - 5.2.5 [Script Verification Flags](#525-script-verification-flags)
     - 5.2.6 [Script Flag Exceptions](#526-script-flag-exceptions)
   - 5.3 [Block Validation](#53-block-validation)
     - 5.3.1 [Header Validation](#531-header-validation)
     - 5.3.2 [Transaction Application Equivalence](#532-transaction-application-equivalence)
   - 5.4 [BIP Validation Rules](#54-bip-validation-rules)
     - 5.4.1 [BIP30: Duplicate Coinbase Prevention](#541-bip30-duplicate-coinbase-prevention)
     - 5.4.2 [BIP34: Block Height in Coinbase](#542-bip34-block-height-in-coinbase)
     - 5.4.3 [BIP66: Strict DER Signatures](#543-bip66-strict-der-signature-validation)
     - 5.4.4 [BIP90: Block Version Enforcement](#544-bip90-block-version-enforcement)
     - 5.4.5 [BIP147: NULLDUMMY Enforcement](#545-bip147-nulldummy-enforcement)
     - 5.4.6 [BIP119: OP_CHECKTEMPLATEVERIFY (CTV)](#546-bip119-op_checktemplateverify-ctv)
     - 5.4.7 [BIP65: OP_CHECKLOCKTIMEVERIFY (CLTV)](#547-bip65-op_checklocktimeverify-cltv)
     - 5.4.8 [BIP348: OP_CHECKSIGFROMSTACK (CSFS)](#548-bip348-op_checksigfromstack-csfs)
     - 5.4.9 [BIP54: Consensus Cleanup](#549-bip54-consensus-cleanup)
   - 5.5 [Sequence Locks (BIP68)](#55-sequence-locks-bip68)
6. [Economic Model](#6-economic-model)
   - 6.1 [Block Subsidy](#61-block-subsidy)
   - 6.2 [Total Supply](#62-total-supply)
   - 6.3 [Supply Limit Validation](#63-supply-limit-validation)
   - 6.4 [Coinbase Detection](#64-coinbase-detection)
   - 6.5 [Fee Market](#65-fee-market)
7. [Proof of Work](#7-proof-of-work)
   - 7.1 [Difficulty Adjustment](#71-difficulty-adjustment)
   - 7.2 [Block Validation](#72-block-validation)
8. [Security Properties](#8-security-properties)
   - 8.1 [Economic Security](#81-economic-security)
   - 8.2 [Integration and Round-Trip Properties](#82-integration-and-round-trip-properties)
     - 8.2.1 [Integration Properties](#821-integration-properties)
     - 8.2.2 [Round-Trip Properties](#822-round-trip-properties)
   - 8.3 [Cryptographic Security](#83-cryptographic-security)
   - 8.4 [Merkle Tree Security](#84-merkle-tree-security)
     - 8.4.1 [ComputeMerkleRoot](#841-computemerkleroot)
   - 8.5 [Deterministic Properties](#85-deterministic-properties)
9. [Mempool Protocol](#9-mempool-protocol)
   - 9.1 [Mempool Validation](#91-mempool-validation)
     - 9.1.1 [Transaction Finality](#911-transaction-finality)
   - 9.2 [Standard Transaction Rules](#92-standard-transaction-rules)
   - 9.3 [Replace-By-Fee (RBF)](#93-replace-by-fee-rbf)
10. [Network Protocol](#10-network-protocol)
    - 10.1 [Message Types](#101-message-types)
      - 10.1.1 [Message Header Parsing](#1011-message-header-parsing)
    - 10.2 [Connection Management](#102-connection-management)
      - 10.2.1 [Handshake Invariants](#1021-handshake-invariants)
    - 10.3 [Peer Discovery](./ARCHITECTURE.md#103-peer-discovery)
    - 10.4 [Block Synchronization](#104-block-synchronization)
    - 10.5 [Transaction Relay](#105-transaction-relay)
    - 10.6 [Dandelion++ k-Anonymity](./ARCHITECTURE.md#106-dandelion-k-anonymity)
11. [Advanced Features](#11-advanced-features)
    - 11.1 [Segregated Witness (SegWit)](#111-segregated-witness-segwit)
      - 11.1.1 [Weight and Size Calculations](#1111-weight-and-size-calculations)
      - 11.1.2 [Witness Structure Validation](#1112-witness-structure-validation)
      - 11.1.3 [Witness Program Extraction](#1113-witness-program-extraction)
      - 11.1.4 [Witness Merkle Root](#1114-witness-merkle-root)
      - 11.1.5 [Witness Commitment Validation](#1115-witness-commitment-validation)
      - 11.1.6 [SegWit Transaction Detection](#1116-segwit-transaction-detection)
      - 11.1.7 [Block Validation](#1117-block-validation)
      - 11.1.8 [Nested SegWit (P2WSH-in-P2SH, P2WPKH-in-P2SH)](#1118-nested-segwit-p2wsh-in-p2sh-p2wpkh-in-p2sh)
      - 11.1.9 [BIP143 Witness Sighash (ComputeWitnessSignatureHash)](#1119-bip143-witness-sighash-computewitnesssignaturehash)
      - 11.1.9.1 [DeriveWitnessScriptCode (BIP143 scriptCode)](#11191-derivewitnessscriptcode-bip143-scriptcode)
    - 11.2 [Taproot](#112-taproot)
      - 11.2.1 [Taproot Script Validation](#1121-taproot-script-validation)
      - 11.2.2 [Taproot Key Operations](#1122-taproot-key-operations)
      - 11.2.3 [Taproot Script Path](#1123-taproot-script-path)
      - 11.2.4 [Taproot Witness Structure](#1124-taproot-witness-structure)
      - 11.2.5 [Taproot Transaction Validation](#1125-taproot-transaction-validation)
      - 11.2.6 [Taproot Signature Hash](#1126-taproot-signature-hash)
      - 11.2.7 [Tapscript Signature Hash (BIP 342)](#1127-tapscript-signature-hash-bip-342)
      - 11.2.8 [Tapscript Opcodes and SigOp Counting (BIP 342)](#1128-tapscript-opcodes-and-sigop-counting-bip-342)
    - 11.3 [Chain Reorganization](./ARCHITECTURE.md#113-chain-reorganization)
      - 11.3.1 [Undo Log Pattern](./ARCHITECTURE.md#1131-undo-log-pattern)
    - 11.4 [UTXO Commitments](#114-utxo-commitments)
    - 11.5 [Signet (BIP325)](#115-signet-bip325)
12. [Mining Protocol](#12-mining-protocol)
    - 12.1 [Block Template Generation](./ARCHITECTURE.md#121-block-template-generation)
    - 12.2 [Coinbase Transaction](#122-coinbase-transaction)
    - 12.3 [Mining Process](./ARCHITECTURE.md#123-mining-process)
    - 12.4 [Block Template Interface](#124-block-template-interface)
13. [Engineering-Specific Edge Cases](#13-engineering-specific-edge-cases)
    - 13.1 [Performance](./ARCHITECTURE.md#131-performance)
    - 13.2 [Security](./ARCHITECTURE.md#132-security)
    - 13.3 [Engineering Invariants](#133-engineering-invariants)
      - 13.3.1 [Integer Arithmetic Overflow/Underflow](#1331-integer-arithmetic-overflowunderflow)
      - 13.3.2 [Serialization/Deserialization Correctness](#1332-serializationdeserialization-correctness)
      - 13.3.3 [Resource Limit Enforcement](#1333-resource-limit-enforcement)
      - 13.3.4 [Parser Determinism](#1334-parser-determinism)
      - 13.3.5 [Integration Proofs](#1335-integration-proofs)
    - 13.4 [Peer Consensus Protocol](./ARCHITECTURE.md#134-peer-consensus-protocol)

## 1. Introduction

Bitcoin is a distributed consensus system that maintains a shared ledger of transactions without requiring trusted intermediaries. The system achieves consensus through proof-of-work and enforces economic rules through cryptographic validation. This paper provides a complete mathematical description of how Bitcoin operates.

### 1.1 Key Contributions

- **Complete State Machine**: Formal specification of Bitcoin's state transitions
- **Economic Model**: Mathematical description of the monetary system
- **Validation Rules**: Precise definition of all consensus-critical checks
- **Security Properties**: Formal statements of Bitcoin's security guarantees

### 1.2 Document Structure

This specification is organized into four main parts:

1. **Foundations** ([§2](#2-system-model)–[§4](#4-consensus-constants)): Mathematical foundations, data structures, and constants
2. **Core Protocol** ([§5](#5-state-transition-functions)–[§8](#8-security-properties)): State transitions, economic model, proof-of-work, and security
3. **Network Layer** ([§9](#9-mempool-protocol)–[§11](#11-advanced-features)): Mempool, P2P protocol, and advanced features
4. **Mining Protocol** ([§12](#12-mining-protocol)): Block creation and mining process ([§12.1](./ARCHITECTURE.md#121-block-template-generation) and [§12.3](./ARCHITECTURE.md#123-mining-process) are in `ARCHITECTURE.md`; [§12.2](#122-coinbase-transaction) and [§12.4](#124-block-template-interface) are in this file)

Each section builds upon previous sections, with cross-references to maintain consistency.

**Companion file:** [`ARCHITECTURE.md`](./ARCHITECTURE.md) shares the same section numbering for implementation-oriented material. `cargo-spec-lock verify` merges both files. [§10.2](#102-connection-management) (connection types) and [§10.2.1](#1021-handshake-invariants) are in this file; headings that exist only in the companion file include, for example: [§10.3](./ARCHITECTURE.md#103-peer-discovery), [§10.6](./ARCHITECTURE.md#106-dandelion-k-anonymity), [§11.3](./ARCHITECTURE.md#113-chain-reorganization), [§12.1](./ARCHITECTURE.md#121-block-template-generation), [§12.3](./ARCHITECTURE.md#123-mining-process), [§13.1](./ARCHITECTURE.md#131-performance), [§13.2](./ARCHITECTURE.md#132-security), [§13.4](./ARCHITECTURE.md#134-peer-consensus-protocol). In this file only (among §13): [§13.3](#133-engineering-invariants) and [§13.3.1](#1331-integer-arithmetic-overflowunderflow)–[§13.3.5](#1335-integration-proofs).

## 2. System Model

### 2.1 Participants

- **Miners**: Create blocks and compete for block rewards
- **Nodes**: Validate transactions and maintain the blockchain
- **Users**: Create transactions to transfer value

### 2.2 Network Assumptions

- **Asynchronous Network**: Messages may be delayed or reordered
- **Byzantine Fault Tolerance**: Some participants may behave maliciously
- **Economic Rationality**: Participants act to maximize their utility

### 2.2.1 Networks and Parameters

Consensus rules are identical across networks. Only parameters differ.

**Network set**: $\text{Network} = \{\text{mainnet}, \text{testnet}, \text{testnet4}, \text{signet}, \text{regtest}\}$

For each $n \in \text{Network}$, the following parameters may differ:

| Parameter | mainnet | testnet | testnet4 | signet | regtest |
|-----------|---------|---------|----------|--------|---------|
| $\text{EnforceBIP94}(n)$ | false | false | true | false | configurable |
| $\text{SignetChallenge}(n)$ | $\emptyset$ | $\emptyset$ | $\emptyset$ | script | $\emptyset$ |
| $\text{ScriptFlagExceptions}(n)$ | 2 blocks | 1 block | 0 | 0 | 0 |
| Genesis, difficulty, retarget | distinct per $n$ | distinct | distinct | distinct | minimal |

**References:** BIP94 (timewarp mitigation), BIP325 (signet), [§5.2.5](#525-script-verification-flags) (script flags), [§7.1](#71-difficulty-adjustment) (difficulty).

## 3. Mathematical Foundations

### 3.1 Basic Types

**Hash Values**: $\mathbb{H} = \{0,1\}^{256}$ - Set of [256-bit hashes](https://en.wikipedia.org/wiki/SHA-2)  
**Byte Strings**: $\mathbb{S} = \{0,1\}^*$ - Set of [byte strings](https://en.wikipedia.org/wiki/Bit_string)  
**Natural Numbers**: $\mathbb{N} = \{0, 1, 2, \ldots\}$ - Set of [natural numbers](https://en.wikipedia.org/wiki/Natural_number)  
**Integers**: $\mathbb{Z} = \{\ldots, -2, -1, 0, 1, 2, \ldots\}$ - Set of [integers](https://en.wikipedia.org/wiki/Integer)  
**Rational Numbers**: $\mathbb{Q}$ - Set of [rational numbers](https://en.wikipedia.org/wiki/Rational_number)

**Notation**: Throughout this document, we use:
- $h \in \mathbb{N}$ for block height
- $tx \in \mathcal{TX}$ for transactions  
- $us \in \mathcal{US}$ for UTXO sets
- $b \in \mathcal{B}$ for blocks
- $x \parallel y$ for **byte-string concatenation** (when written in formulas; see also Taproot tagged-hash definitions in [§11.2](#112-taproot))

**Implicit conventions** (omitted from individual Properties sections):  
Four invariants are universal across this specification and never restated per-function:

1. **Boolean codomain**: every $\mathbb{B}$-valued function satisfies $result \in \{\text{true}, \text{false}\}$ — definition of $\mathbb{B}$, not a proof obligation.
2. **Non-negative naturals**: every $\mathbb{N}$-valued (unsigned) function satisfies $result \geq 0$ — unsigned integers cannot be negative.
3. **Determinism**: every function in this spec is **pure** — for all inputs $\vec{a}$, $f(\vec{a}_1) = f(\vec{a}_2) \iff \vec{a}_1 = \vec{a}_2$. This is the definition of a mathematical function and is not restated per-function. The only Deterministic bullets that appear are for **non-trivial** equivalences, e.g. where the output depends on fewer inputs than the full argument list.
4. **Input index bounds**: any function $f(tx, i, \ldots)$ implicitly requires $0 \leq i < |tx.\text{inputs}|$. This precondition is not restated per-function.

`blvm-spec-lock` infers (1) and (2) from the Rust return type via `auto_type_contracts`. All `F_*` formula bodies are mechanically verified by `blvm-spec-lock` unless marked *unverified*. Properties sections state only mathematically non-trivial constraints beyond these four.

### 3.2 Core Data Structures

**OutPoint**: $\mathcal{O} = \mathbb{H} \times \mathbb{N}$ (see [§3.2](#32-core-data-structures), [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product))  
**Transaction Input**: $\mathcal{I} = \mathcal{O} \times \mathbb{S} \times \mathbb{N}$ (see [§3.3](#33-script-system))  
**Transaction Output**: $\mathcal{T} = \mathbb{Z} \times \mathbb{S}$ (see [§4.1](#41-monetary-constants))  
**Transaction**: $\mathcal{TX} = \mathbb{N} \times \mathcal{I}^* \times \mathcal{T}^* \times \mathbb{N}$ (see [Transaction Validation](#51-transaction-validation), [Kleene star](https://en.wikipedia.org/wiki/Kleene_star))  
**Block Header**: $\mathcal{H} = \mathbb{Z} \times \mathbb{H} \times \mathbb{H} \times \mathbb{N} \times \mathbb{N} \times \mathbb{N}$ (see [Block Validation](#53-block-validation))  
**Block**: $\mathcal{B} = \mathcal{H} \times \mathcal{TX}^*$ (see [Block Validation](#53-block-validation))  
**UTXO**: $\mathcal{U} = \mathbb{Z} \times \mathbb{S} \times \mathbb{N}$ (see [Theorem 8.1](#81-economic-security))  
**UTXO Set**: $\mathcal{US} = \mathcal{O} \rightarrow \mathcal{U}$ (see [State Transition Functions](#5-state-transition-functions), [function type](https://en.wikipedia.org/wiki/Function_type))

### 3.3 Script System

**Script**: $\mathcal{SC} = \mathbb{S}$ (sequence of [opcodes](https://en.bitcoin.it/wiki/Script))  
**Witness**: $\mathcal{W} = \mathbb{S}^*$ (stack of [witness data](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki))  
**Stack**: $\mathcal{ST} = \mathbb{S}^*$ (execution stack, see [Script Execution](#52-script-execution))

## 4. Consensus Constants

### 4.1 Monetary Constants

$C = 10^8$ (satoshis per BTC, see [Economic Model](#6-economic-model))  
$M_{max} = 21 \times 10^6 \times C$ (maximum money supply, see [§6.2](#62-total-supply))  
$H = 210,000$ (halving interval, see [Block Subsidy](#61-block-subsidy))

### 4.2 Block Constants

$W_{max} = 4 \times 10^6$ (maximum block weight, see [Block Validation](#53-block-validation))  
$S_{max} = 80,000$ (maximum sigops per block, see [Script Execution](#52-script-execution))  
$R = 100$ (coinbase maturity requirement, see [Transaction Validation](#51-transaction-validation))

### 4.3 Script Constants

$L_{script} = 10,000$ (maximum script length, see [§8.3](#83-cryptographic-security))  
$L_{stack} = 1,000$ (maximum stack size, see [Theorem 8.4](#83-cryptographic-security))  
$L_{ops} = 201$ (maximum operations per script, see [Theorem 8.4](#83-cryptographic-security))  
$L_{element} = 520$ (maximum element size, see [Script Execution](#52-script-execution))

### 4.4 Difficulty Constants

$D_{interval} = 2016$ (blocks per difficulty adjustment period, see [Difficulty Adjustment](#71-difficulty-adjustment))  
$T_{block} = 600$ (target block time in seconds, 10 minutes)  
$T_{future} = 7200$ (maximum allowed block time in future, 2 hours, see [Block Validation](#53-block-validation))

## 5. State Transition Functions

### 5.1 Transaction Validation

*Intuition.* Validating a transaction is not one monolithic predicate. Consensus first enforces **syntax and local bounds** (non-empty inputs and outputs, sensible values, no duplicate spends *within* the same transaction, and coinbase vs non-coinbase shape). Only then does it relate the transaction to the **current UTXO set** and **chain height**: non-coinbase inputs must spend coins that exist and cover the outputs (the fee is the remainder), and **script execution** (see [§5.2](#52-script-execution)) finally authorizes each spend. Failures at an earlier layer short-circuit later checks. The same bytecode can be valid or invalid depending on flags, height, and sighash mode; the formal presentation below factors that into named functions so implementations can match the reference ordering.

**CheckTransaction**: $\mathcal{TX} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

A transaction $tx = (v, ins, outs, lt)$ is valid if and only if:

1. $|ins| > 0 \land |outs| > 0$
2. $\forall o \in outs: 0 \leq o.value \leq M_{max}$
3. $\sum_{o \in outs} o.value \leq M_{max}$
4. $\forall i,j \in ins: i \neq j \Rightarrow i.prevout \neq j.prevout$
5. If $tx$ is coinbase: $2 \leq |ins[0].scriptSig| \leq 100$
6. If $tx$ is not coinbase: $\forall i \in ins: \neg i.prevout.IsNull()$

```mermaid
flowchart TD
    A[Transaction Input] --> B{CheckTransaction}
    B --> C{Inputs/Outputs Empty?}
    C -->|Yes| D[❌ Invalid: Empty]
    C -->|No| E{Value Range Check}
    E -->|Invalid| F[❌ Invalid: Value]
    E -->|Valid| G{Duplicate Inputs?}
    G -->|Yes| H[❌ Invalid: Duplicates]
    G -->|No| I{Coinbase Check}
    I -->|Invalid| J[❌ Invalid: Coinbase]
    I -->|Valid| K[✅ Valid Transaction]
    
    K --> L[CheckTxInputs]
    L --> M{UTXO Available?}
    M -->|No| N[❌ Invalid: UTXO]
    M -->|Yes| O{Sufficient Value?}
    O -->|No| P[❌ Invalid: Insufficient]
    O -->|Yes| Q[VerifyScript]
    Q --> R{Script Valid?}
    R -->|No| S[❌ Invalid: Script]
    R -->|Yes| T[✅ Valid & Executable]
    
    style A fill:#e1f5fe
    style T fill:#c8e6c9
    style D fill:#ffcdd2
    style F fill:#ffcdd2
    style H fill:#ffcdd2
    style J fill:#ffcdd2
    style N fill:#ffcdd2
    style P fill:#ffcdd2
    style S fill:#ffcdd2
```

**Properties**:
- Structure validation: $result = \text{valid} \implies |tx.\text{inputs}| > 0 \land |tx.\text{outputs}| > 0$
- Input bounds: $result = \text{valid} \implies |tx.\text{inputs}| \leq M_{\text{max\_inputs}}$
- Output bounds: $result = \text{valid} \implies |tx.\text{outputs}| \leq M_{\text{max\_outputs}}$
- Empty rejection: $|tx.\text{inputs}| = 0 \lor |tx.\text{outputs}| = 0 \implies \text{CheckTransaction}(tx) \neq \text{valid}$
- Output value bounds: $result = \text{valid} \implies \forall o \in tx.\text{outputs}: 0 \leq o.\text{value} \leq M_{\text{max}}$
- Total output sum: $result = \text{valid} \implies \sum_{o \in tx.\text{outputs}} o.\text{value} \leq M_{\text{max}}$
- Stripped-size weight (consensus): $result = \text{valid} \implies 4 \cdot \text{CalculateTransactionSize}(tx) \leq W_{\max}$ (same $W_{\max}$ as block weight cap, §11.1.1; see **CalculateTransactionSize** below)
- No duplicate prevouts: $result = \text{valid} \implies \forall i,j \in tx.\text{inputs}: i \neq j \implies i.\text{prevout} \neq j.\text{prevout}$
- Coinbase scriptSig length: $result = \text{valid} \land \text{IsCoinbase}(tx) \implies 2 \leq |tx.\text{inputs}[0].\text{scriptSig}| \leq 100$
**Note**: For non-coinbase transactions, all inputs have non-null prevouts: $\neg \text{IsCoinbase}(tx) \implies \forall i \in tx.\text{inputs}: \neg i.\text{prevout}.\text{IsNull}()$

**CheckTxInputs**: $\mathcal{TX} \times \mathcal{US} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\} \times \mathbb{Z}$

**Properties**:
- Coinbase fee: $result = \text{true} \implies \text{CheckTxInputs}(tx, us, h) = (\text{valid}, 0)$
- Value conservation: $result = (\text{valid}, fee) \land \neg \text{IsCoinbase}(tx) \implies \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} = \sum_{o \in tx.\text{outputs}} o.\text{value} + fee$
- Fee calculation: $result = (\text{valid}, fee) \land \neg \text{IsCoinbase}(tx) \implies fee = \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Non-negative fee: $result = (\text{valid}, fee) \implies fee \geq 0$
- Insufficient funds: $result = (\text{invalid}, 0) \land \neg \text{IsCoinbase}(tx) \implies \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} < \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Result type: $result \in \{(\text{valid}, \mathbb{Z}), (\text{invalid}, 0)\}$

$$\text{CheckTxInputs}(tx, us, h) = \begin{cases}
(\text{valid}, 0) & \text{if } \text{IsCoinbase}(tx) \\
(\text{invalid}, 0) & \text{if } \neg\text{IsCoinbase}(tx) \land \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} < \sum_{o \in tx.\text{outputs}} o.\text{value} \\
(\text{valid}, \text{fee}) & \text{otherwise}
\end{cases}$$

$$\text{where} \quad \text{fee} := \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$$

**CalculateTransactionSize**: $\mathcal{TX} \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Stripped bytes: $result = |\text{SerializeNoWitness}(tx)|$. Consensus weight bound: $4 \cdot \text{CalculateTransactionSize}(tx) \leq W_{\max}$ for any transaction accepted as valid.

**CalculateTxId**: $\mathcal{TX} \rightarrow \mathbb{H}$

**Properties**:
- Defined: $\text{true}$

**Note**: Hash length invariant: $|result| = 32$ (32-byte SHA256d hash).

#### 5.1.1 Transaction Sighash Calculation

**CalculateSighash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \text{SighashType} \times \mathbb{N} \rightarrow \mathbb{H}$

**Properties**:
- Defined: $\text{true}$

**Note**: Hash length: the result is always a 32-byte double-SHA256 hash.

For transaction $tx$, input index $i$, UTXO set $us$, sighash type $st$, and height $h$:

$$\text{CalculateSighash}(tx, i, us, st, h) = \text{SHA256}(\text{SHA256}(\text{SighashPreimage}(tx, i, us, st, h)))$$

**SighashScriptCode**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \rightarrow \mathbb{S}$

**Properties**:
- P2SH handling: $result = \text{RedeemScript}(tx, i) \iff \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (P2SH uses redeem script)
- Non-P2SH handling: $result = us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} \iff \neg \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (non-P2SH uses scriptPubkey)
- UTXO existence: $\text{SighashScriptCode}(tx, i, us)$ requires $tx.\text{inputs}[i].\text{prevout} \in us$ (UTXO must exist)
- Codomain: $result \in \mathbb{S}$

For transaction $tx$, input index $i$, and UTXO set $us$:

$$\text{SighashScriptCode}(tx, i, us) = \begin{cases}
\text{RedeemScript}(tx, i) & \text{if } \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey}) \\
us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} & \text{otherwise}
\end{cases}$$

Where $\text{RedeemScript}(tx, i)$ is the redeem script extracted from the stack after executing scriptSig for input $i$.

**FindAndDelete**: $\mathbb{S} \times \mathbb{S} \rightarrow \mathbb{S}$

**Properties**:
- Defined: $\text{true}$

**Note**: The result is the input script with all occurrences of $pattern$ removed; $|result| \leq |script|$. Empty pattern: $|pattern| = 0 \implies result = script$ (no-op). Pattern longer than script: $|pattern| > |script| \implies result = script$. Opcode boundaries are preserved.

For script $script \in \mathbb{S}$ and pattern $pattern \in \mathbb{S}$:

$$\text{FindAndDelete}(script, pattern) = \begin{cases}
script & \text{if } |pattern| = 0 \lor |pattern| > |script| \\
\text{RemoveAll}(script, pattern) & \text{otherwise}
\end{cases}$$

Where $\text{RemoveAll}(script, pattern)$ removes all occurrences of $pattern$ from $script$ while preserving opcode boundaries.

**SerializeScriptCode**: $\mathbb{S} \rightarrow \mathbb{S}$

**Properties**:
- Defined: $\text{true}$
- Length bound: $|result| \leq |script|$

$$\text{SerializeScriptCode}(script) = \text{RemoveOpcode}(script, 0xab)$$

Where $\text{RemoveOpcode}$ deletes bytes at OP_CODESEPARATOR **opcode positions only** (bytes inside push-data payloads are preserved). Legacy sighash preimages use $\text{varint}(|\text{SerializeScriptCode}(code)|) \parallel \text{SerializeScriptCode}(code)$.

**SighashScriptCodeWithSigVersion**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \text{SigVersion} \times \mathbb{S} \rightarrow \mathbb{S}$

(Extends the three-argument **SighashScriptCode** above with signature version `sv` and executing signature push `sig` for Find-and-delete semantics in `SigVersion::Base`.)

**Properties** (Updated):
- P2SH handling: $result = \text{RedeemScript}(tx, i) \iff \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (P2SH uses redeem script)
- Non-P2SH handling: $result = us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} \iff \neg \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (non-P2SH uses scriptPubkey)
- FindAndDelete application: $\text{SigVersion} = \text{Base} \land \text{IsSignatureOpcode}(opcode) \implies \text{SighashScriptCode}(tx, i, us, sv, sig) = \text{FindAndDelete}(\text{BaseScriptCode}(tx, i, us), \text{SerializePush}(sig))$
**Note**: For SegWit signature versions (WitnessV0, Tapscript), FindAndDelete is not applied; script code is used as-is.
- UTXO existence: $\text{SighashScriptCode}(tx, i, us, sv, sig)$ requires $tx.\text{inputs}[i].\text{prevout} \in us$ (UTXO must exist)

For transaction $tx$, input index $i$, UTXO set $us$, signature version $sv$, and signature $sig$:

$$\text{SighashScriptCode}(tx, i, us, sv, sig) = \begin{cases}
\text{FindAndDelete}(\text{BaseScriptCode}(tx, i, us), \text{SerializePush}(sig)) & \text{if } sv = \text{Base} \land \text{IsSignatureOpcode}(opcode) \\
\text{BaseScriptCode}(tx, i, us) & \text{otherwise}
\end{cases}$$

Where:
- $result$ is the base script code (redeem script for P2SH, scriptPubkey otherwise)
- $result$ is the serialized push operation for signature $sig$
- $result \iff op \in \{0x\text{ac}, 0x\text{ad}, 0x\text{ae}, 0x\text{af}\}$ (OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY)

**SighashType**: $\mathbb{N}_{8} \times \mathbb{N} \rightarrow \text{SighashType}$

**Properties**:
- BIP66 legacy handling: $result = \text{AllLegacy} \iff h < H_{66}$ (legacy 0x00 only before BIP66)
- Standard types: $result \in \{\text{All}, \text{None}, \text{Single}\} \iff byte \in \{0x01, 0x02, 0x03\}$ (standard types)
- AnyoneCanPay flag: $result \text{ has AnyoneCanPay flag } \iff byte \in \{0x81, 0x82, 0x83\}$ (AnyoneCanPay types)
- Invalid handling: $result = \text{Invalid} \iff byte \notin \{0x00, 0x01, 0x02, 0x03, 0x81, 0x82, 0x83\} \lor (byte = 0x00 \land h \geq H_{66})$ (invalid bytes or post-BIP66 0x00)
- Result type: $result \in \{\text{AllLegacy}, \text{All}, \text{None}, \text{Single}, \text{All} \mid \text{AnyoneCanPay}, \text{None} \mid \text{AnyoneCanPay}, \text{Single} \mid \text{AnyoneCanPay}, \text{Invalid}\}$

For sighash byte $byte$ and height $h$:

$$\text{SighashType}(byte, h) = \begin{cases}
\text{AllLegacy} & \text{if } byte = 0x00 \land h < H_{66} \\
\text{All} & \text{if } byte = 0x01 \\
\text{None} & \text{if } byte = 0x02 \\
\text{Single} & \text{if } byte = 0x03 \\
\text{All} \mid \text{AnyoneCanPay} & \text{if } byte = 0x81 \\
\text{None} \mid \text{AnyoneCanPay} & \text{if } byte = 0x82 \\
\text{Single} \mid \text{AnyoneCanPay} & \text{if } byte = 0x83 \\
\text{Invalid} & \text{otherwise}
\end{cases}$$

Where $H_{66}$ is the BIP66 activation height (mainnet: 363,725).

**Early Bitcoin Legacy**: In early Bitcoin (pre-BIP66), sighash type $0x00$ was accepted and treated as SIGHASH_ALL. This is represented as $\text{AllLegacy}$ to preserve the correct byte value for sighash computation.

**Theorem 5.1.1** (P2SH Redeem Script Sighash): For P2SH transactions, the sighash must use the redeem script instead of the scriptPubKey.

*Proof*: By construction, P2SH scriptPubKeys contain only a hash of the redeem script. The actual script logic is in the redeem script, which must be used for sighash calculation to ensure signatures validate correctly. This is proven by the requirement that $\text{SighashScriptCode}$ returns the redeem script for P2SH transactions.

**Theorem 5.1.2** (Sighash Type AllLegacy): Early Bitcoin (pre-BIP66) accepted sighash type 0x00 as SIGHASH_ALL.

*Proof*: Historical Bitcoin blocks at heights $< H_{66}$ (on mainnet, heights up to 363,724) contain transactions with sighash type 0x00. These transactions are valid and must be accepted. The $\text{SighashType}$ function maps $0x00$ to $\text{AllLegacy}$ for heights $< H_{66}$ to preserve compatibility with these historical transactions.

**Theorem 5.1.3** (FindAndDelete Sighash Requirement): For legacy scripts, FindAndDelete must be applied to scriptCode before sighash computation.

$$\forall tx \in \mathcal{TX}, i \in \mathbb{N}, sig \in \mathbb{S}, sv = \text{Base}: \text{IsSignatureOpcode}(opcode) \implies \text{CalculateSighash}(tx, i, us, st, h) \text{ uses } \text{FindAndDelete}(\text{BaseScriptCode}(tx, i, us), \text{SerializePush}(sig))$$

*Proof*: From the definition of $\text{SighashScriptCode}$, FindAndDelete is applied to remove signature patterns from scriptCode before computing sighash for legacy signature opcodes (OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY). This ensures that signatures appearing in the redeem script (e.g., P2SH multisig edge cases where signatures appear as "pubkeys") do not affect the sighash computation. For SegWit (BIP143), FindAndDelete is explicitly omitted, so this only applies to SigVersion::Base. The piecewise definition above requires FindAndDelete for legacy scripts when signature opcodes are used.

**SigVersion**: $\text{SigVersion} \in \{\text{Base}, \text{WitnessV0}, \text{Tapscript}\}$

Signature verification and sighash dispatch depend on the active signature version:
- **Base**: legacy $\text{CalculateSighash}$ with $\text{SerializeScriptCode}$ and FindAndDelete as above.
- **WitnessV0**: BIP143 $\text{ComputeWitnessSignatureHash}$ (§11.1.9); FindAndDelete is not applied.
- **Tapscript**: BIP341/BIP342 tapscript sighash (§11.2.7); distinct from legacy and BIP143.

**BaseScriptCode**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \rightarrow \mathbb{S}$

For legacy sighash, the script code is the subscript of the currently executing script from the last **executed** OP_CODESEPARATOR (0xab) to the end. Unexecuted conditional branches do not contribute. Legacy sighash uses $\text{SerializeScriptCode}$ (§5.1.1).

**Theorem 5.1.4** (CHECKMULTISIG Sighash Dispatch): OP_CHECKMULTISIG sighash depends on SigVersion.

$$\forall sv = \text{WitnessV0}: \text{CHECKMULTISIG sighash} = \text{ComputeWitnessSignatureHash}(tx, i, witnessScript, amount, type)$$

$$\forall sv = \text{Base}: \text{CHECKMULTISIG removes all signature pushes from BaseScriptCode before any sighash computation, then applies SerializeScriptCode and CalculateSighash}$$

*Proof*: BIP143 defines witness sighash over the full witness script without FindAndDelete. Legacy CHECKMULTISIG removes each signature push from scriptCode before computing any input's sighash. WitnessV0 CHECKMULTISIG uses BIP143 with the witness script as scriptCode (§11.1.9.1).

### 5.2 Script Execution

Bitcoin uses a stack-based scripting language for transaction validation. Scripts are executed to determine whether a transaction output can be spent.

**EvalScript**: $\mathcal{SC} \times \mathcal{ST} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Defined: $\text{true}$
- Boolean result: $result \in \{\text{true}, \text{false}\}$

$\text{EvalScript}(script, S_0, f) = \text{true}$ iff execution terminates without failure and the final stack $S_f$ satisfies $|S_f| = 1 \land S_f[0] \neq 0$.

Execution fails (yielding $\text{false}$) iff at any step:
- $result$: $|S| > L_{stack}$, or
- $result$: operation count $c > L_{ops}$, or
- $result$: execution of $op$ on stack $S$ fails.

Formally: $\text{EvalScript}(script, S_0, f, sv) = \text{false} \iff \text{Execute}(script, S_0, f, sv) \downarrow \land (\text{Overflow} \lor \text{OverOps} \lor \text{OpFail})$, where $\downarrow$ indicates termination and the disjunction holds at some step.

**Resource limits by SigVersion**:
- **Base** and **WitnessV0**: $|script| \leq L_{script} = 10{,}000$; non-push opcode count $c \leq L_{ops} = 201$.
- **Tapscript**: neither the 10k script-size nor 201-op limits apply; BIP342 enforces tapscript validation weight and sigops budget separately (§11.2.8).

```mermaid
sequenceDiagram
    participant S as Script
    participant VM as Virtual Machine
    participant ST as Stack
    participant O as Opcodes
    
    Note over S,ST: Script Execution Process
    
    S->>VM: Load Script
    VM->>ST: Initialize Empty Stack
    
    loop For each opcode
        VM->>O: Execute Opcode
        O->>ST: Push/Pop/Modify Stack
        
        alt Stack Overflow
            ST-->>VM: |S| + |AltStack| > 1000
            VM-->>S: ❌ Return false
        else Operation Limit
            O-->>VM: Count > 201
            VM-->>S: ❌ Return false
        else Execution Error
            O-->>VM: Opcode fails
            VM-->>S: ❌ Return false
        end
    end
    
    VM->>ST: Check Final State
    alt Valid Result
        ST-->>VM: |S| = 1 ∧ S[0] ≠ 0
        VM-->>S: ✅ Return true
    else Invalid Result
        ST-->>VM: |S| ≠ 1 ∨ S[0] = 0
        VM-->>S: ❌ Return false
    end
```

**Properties**:
- Script verification correctness: $result = \text{true} \iff$ script execution succeeds with final stack having exactly one true value
- P2SH validation: $(f \land 0x01) \neq 0 \land \text{IsP2SH}(spk) \implies \text{P2SHPushOnlyCheck}(ss) = \text{valid}$
- Execution order: $result$ executes $ss$ first, then $spk$, then $w$ if present
- Stack initialization: $result$ starts with empty stack for $ss$ execution
- Final stack condition: $result = \text{true} \implies$ final stack has exactly one non-zero element

**VerifyScript**: $\mathcal{SC} \times \mathcal{SC} \times \mathcal{W} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Stack depth bound: $result = \text{true} \implies \text{stack.len}() \leq \text{MAX\_STACK\_SIZE}$. P2SH precondition: $(f \land 0x01) \neq 0 \land \text{IsP2SH}(spk) \implies \text{P2SHPushOnlyCheck}(ss) = \text{valid}$.

For scriptSig $ss$, scriptPubKey $spk$, witness $w$, and flags $f$:

1. **P2SH Push-Only Validation**: If $(f \land 0x01) \neq 0$ (SCRIPT_VERIFY_P2SH) and $\text{IsP2SH}(spk)$, then $\text{P2SHPushOnlyCheck}(ss)$ must be valid
2. Execute $ss$ on empty stack
3. Execute $spk$ on resulting stack
4. If witness present: execute $w$ on stack
5. Return final stack has exactly one true value

#### 5.2.1 P2SH Push-Only Validation

**P2SHPushOnlyCheck**: $\mathbb{S} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Push-only validation: $\text{P2SHPushOnlyCheck}(ss) = \text{valid} \iff \forall op \in ss : \text{IsPushOpcode}(op)$
- Boolean result: $\text{P2SHPushOnlyCheck}(ss) \in \{\text{valid}, \text{invalid}\}$
- Empty script: $\text{P2SHPushOnlyCheck}(\emptyset) = \text{valid}$ (empty script is valid push-only)
- Non-push opcode: If $\exists op \in ss : \neg \text{IsPushOpcode}(op)$, then $\text{P2SHPushOnlyCheck}(ss) = \text{invalid}$

For P2SH scriptSig $ss$:

$$\text{P2SHPushOnlyCheck}(ss) = \begin{cases}
\text{valid} & \text{if } \forall op \in ss : \text{IsPushOpcode}(op) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

Where $\text{IsPushOpcode}(op) \iff op \in \text{PushOpcode}$, and $\text{PushOpcode}$ is the set of valid push encodings:
- Direct push: $0x01 \leq op \leq 0x4b$ (push 1-75 bytes)
- OP_PUSHDATA1: $op = 0x4c$ (followed by 1-byte length)
- OP_PUSHDATA2: $op = 0x4d$ (followed by 2-byte length)
- OP_PUSHDATA4: $op = 0x4e$ (followed by 4-byte length)
- OP_0: $op = 0x00$ (push empty array)

**P2SH Detection**: $\text{IsP2SH}(spk) = (|spk| = 23) \land (spk[0] = 0xa9) \land (spk[1] = 0x14) \land (spk[22] = 0x87)$

Where:
- $0xa9$ is OP_HASH160
- $0x14$ is push 20 bytes
- $0x87$ is OP_EQUAL

**Security Property**: P2SH push-only validation prevents script injection attacks:

$$\forall ss, spk \in \mathbb{S}, f \in \mathbb{N}_{32} : (f \land 0x01) \neq 0 \land \text{IsP2SH}(spk) \land \neg \text{P2SHPushOnlyCheck}(ss) \implies \text{VerifyScript}(ss, spk, w, f) = \text{false}$$

**Theorem 5.2.1** (P2SH Push-Only Security): P2SH scriptSig must contain only push operations to prevent script injection.

*Proof*: By construction, if a P2SH scriptSig $ss$ contains any non-push opcode, then $\text{P2SHPushOnlyCheck}(ss) = \text{invalid}$, causing $\text{VerifyScript}(ss, spk, w, f) = \text{false}$ before script execution. This prevents malicious opcodes from being executed, ensuring that only data (the redeem script) is pushed onto the stack.

**Activation**: Block 173,805 (mainnet) - Same as P2SH activation (BIP16)

---

#### 5.2.2 Signature Operation Counting

Signature operations (sigops) are counted to enforce the `MAX_BLOCK_SIGOPS_COST` limit (80,000) per block. Sigops include OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, and OP_CHECKMULTISIGVERIFY operations.

**CountSigOpsInScript**: $\mathbb{S} \times \{\text{true}, \text{false}\} \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Sigop count is bounded by script length ($result \leq |s|$) and is zero for empty scripts ($|s| = 0 \implies result = 0$).

For script $s$ and accurate flag $a$:

$$\text{CountSigOpsInScript}(s, a) = \sum_{i=0}^{|s|-1} \text{SigOpCount}(s[i], s, i, a)$$

Where $\text{SigOpCount}(op, s, i, a)$ returns:
- $1$ if $op \in \{0xac, 0xad\}$ (OP_CHECKSIG, OP_CHECKSIGVERIFY)
- $n$ if $op \in \{0xae, 0xaf\}$ (OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY) where:
  - If $a = \text{true}$ and $i > 0$ and $s[i-1] \in [0x51, 0x60]$ (OP_1 to OP_16), then $n = s[i-1] - 0x50$
  - Otherwise, $n = 20$ (MAX_PUBKEYS_PER_MULTISIG)
- $0$ otherwise

**GetLegacySigOpCount**: $\mathcal{TX} \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Coinbase inputs may contain opcodes that contribute to the signature operation count.

For transaction $tx$:

$$\text{GetLegacySigOpCount}(tx) = \sum_{i \in tx.\text{inputs}} \text{CountSigOpsInScript}(i.\text{scriptSig}, \text{false}) + \sum_{o \in tx.\text{outputs}} \text{CountSigOpsInScript}(o.\text{scriptPubkey}, \text{false})$$

**GetP2SHSigOpCount**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Coinbase transactions contribute zero P2SH sigops. P2SH-attributed sigops only arise when at least one input spends a P2SH output: $\text{GetP2SHSigOpCount}(tx, us) > 0 \implies \exists i \in tx.\text{inputs}: \text{IsP2SH}(us(i.\text{prevout}).\text{scriptPubkey})$

For transaction $tx$ and UTXO set $us$:

$$\text{GetP2SHSigOpCount}(tx, us) = \begin{cases}
0 & \text{if } \text{IsCoinbase}(tx) \\
\sum_{i \in tx.\text{inputs}} \text{P2SHSigOps}(i, us) & \text{otherwise}
\end{cases}$$

Where $\text{P2SHSigOps}(i, us) = \begin{cases}
\text{CountSigOpsInScript}(r, \text{true}) & \text{if } \text{IsP2SH}(us(i.\text{prevout}).\text{scriptPubkey}) \land \text{ExtractRedeemScript}(i.\text{scriptSig}) = r \\
0 & \text{otherwise}
\end{cases}$

**GetTransactionSigOpCost**: $\mathcal{TX} \times \mathcal{US} \times \mathcal{W}^? \times \mathbb{N}_{32} \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Cost formula: $result = \text{GetLegacySigOpCount}(tx) \times 4 + \text{GetP2SHSigOpCount}(tx, us) \times 4 \times \text{IsP2SHEnabled}(f) + \text{CountWitnessSigOps}(tx, w, us, f)$. Block limit: $\sum_{tx \in block.transactions} \text{GetTransactionSigOpCost}(tx, us, w, f) \leq M_{\text{max\_block\_sigops}}$ for valid blocks.

For transaction $tx$, UTXO set $us$, witness $w$, and flags $f$:

$$\text{GetTransactionSigOpCost}(tx, us, w, f) = \text{GetLegacySigOpCount}(tx) \times 4 + \text{GetP2SHSigOpCount}(tx, us) \times 4 \times \text{IsP2SHEnabled}(f) + \text{CountWitnessSigOps}(tx, w, us, f)$$

Where:
- $\text{IsP2SHEnabled}(f) = (f \land 0x01) \neq 0$
- $\text{CountWitnessSigOps}(tx, w, us, f)$ adds witness sigop cost **only for witness outputs of version 0** (P2WPKH and P2WSH). For each such input, P2WPKH contributes **1**; P2WSH uses $\text{CountSigOpsInScript}$ on the witness stack’s last push (the witness script), with accurate multisig counting. **Witness version 1 (P2TR / Taproot) contributes 0** to this term; taproot signature-related limits are enforced via **BIP 342** tapscript validation weight during script execution, not by adding tapscript sigops into $\text{GetTransactionSigOpCost}$. Implementations must not fold $\text{CountTapscriptSigOps}$ into $\text{CountWitnessSigOps}$ or they will over-count and reject valid mainnet blocks.

**Block SigOps Limit**: For block $b$:

$$\sum_{tx \in b.\text{transactions}} \text{GetTransactionSigOpCost}(tx, us, w_{tx}, f) \leq S_{max}$$

Where $S_{max} = 80,000$ (MAX_BLOCK_SIGOPS_COST).

---

#### 5.2.3 Stack Operations

**AltStack**: $\mathcal{ST}_{alt} = \mathbb{S}^*$ (alternate stack for temporary storage)

**Combined Stack Size Limit**: $|stack| + |altstack| \leq L_{stack}$ (combined size must not exceed maximum)

**OP_TOALTSTACK** (opcode 0x6b):
- **Stack Input**: $[item]$ where $item \in \mathbb{S}$
- **Stack Output**: $\emptyset$ (item moved to altstack)
- **AltStack Output**: $[item]$ (item added to altstack)
- **Validation**: $|stack| > 0 \land |stack| + |altstack| < L_{stack} \implies \text{OP_TOALTSTACK}(stack, altstack) = (stack', altstack')$ where $stack' = stack[1..]$ and $altstack' = altstack \cup [stack[0]]$
- **Error**: $|stack| = 0 \implies \text{OP_TOALTSTACK}(stack, altstack) = \text{error}$ (empty stack)

**OP_FROMALTSTACK** (opcode 0x6c):
- **Stack Input**: $\emptyset$
- **Stack Output**: $[item]$ where $item \in \mathbb{S}$ (item moved from altstack)
- **AltStack Input**: $[item]$ where $item \in \mathbb{S}$
- **AltStack Output**: $\emptyset$ (item removed from altstack)
- **Validation**: $|altstack| > 0 \land |stack| + |altstack| \leq L_{stack} \implies \text{OP_FROMALTSTACK}(stack, altstack) = (stack', altstack')$ where $stack' = stack \cup [altstack[0]]$ and $altstack' = altstack[1..]$
- **Error**: $|altstack| = 0 \implies \text{OP_FROMALTSTACK}(stack, altstack) = \text{error}$ (empty altstack)

**Properties**:
- Stack preservation: $\text{OP_TOALTSTACK}(stack, altstack) = (stack', altstack') \implies |stack| + |altstack| = |stack'| + |altstack'|$ (total items preserved)
- Combined size limit: $\text{OP_TOALTSTACK}(stack, altstack) = (stack', altstack') \implies |stack'| + |altstack'| \leq L_{stack}$
- Round-trip: $\text{OP_FROMALTSTACK}(\text{OP_TOALTSTACK}(stack, altstack)) = (stack, altstack)$ (if no errors)

**OP_DEPTH** (opcode 0x74):
- **Stack Input**: $\emptyset$
- **Stack Output**: $[\text{EncodeCScriptNum}(|stack|)]$ where $|stack|$ is the current stack depth
- **Validation**: $\text{OP_DEPTH}(stack) = stack \cup [\text{EncodeCScriptNum}(|stack|)]$
- **CScriptNum Encoding**: Depth is encoded as a minimal little-endian byte string (CScriptNum format)

**Properties**:
- Depth accuracy: $\text{OP_DEPTH}(stack) = stack' \implies \text{DecodeCScriptNum}(stack'[|stack'|-1]) = |stack|$ (pushed value equals stack depth before OP_DEPTH)
- Stack growth: $\text{OP_DEPTH}(stack) = stack' \implies |stack'| = |stack| + 1$ (adds one element)
- Deterministic: $\text{OP_DEPTH}(stack_1) = \text{OP_DEPTH}(stack_2) \iff |stack_1| = |stack_2|$

#### 5.2.4 Conditional Opcode Execution

**Execution State**: $fExec \in \{\text{true}, \text{false}\}$ (current execution state)

**OP_VER** (opcode 0x62):
- **Stack Input**: $\emptyset$
- **Stack Output**: $\emptyset$ (opcode fails if executing)
- **Validation**: 
  - If $fExec = \text{true}$: $\text{OP_VER}(stack, fExec) = \text{error}$ (disabled opcode, fails when executing)
  - If $fExec = \text{false}$: $\text{OP_VER}(stack, fExec) = \text{skip}$ (skipped in non-executing branch)
- **Special Behavior**: OP_VER differs from truly disabled opcodes (OP_CAT, OP_MUL, etc.) which always fail

**Properties**:
- Conditional failure: $\text{OP_VER}(stack, \text{true}) = \text{error}$ (fails when executing)
- False branch skip: $\text{OP_VER}(stack, \text{false}) = \text{skip}$ (skipped in false branch)
- Distinction from disabled: Truly disabled opcodes fail regardless of $fExec$, but OP_VER only fails when $fExec = \text{true}$

**Theorem 5.2.3** (OP_VER Conditional Behavior): OP_VER fails only when executing, not in false branches.

$$\forall stack \in \mathcal{ST}: \text{OP_VER}(stack, fExec) = \begin{cases}
\text{error} & \text{if } fExec = \text{true} \\
\text{skip} & \text{if } fExec = \text{false}
\end{cases}$$

*Proof*: From the piecewise definition, OP_VER yields error only when $fExec = \text{true}$. In non-executing branches ($fExec = \text{false}$), it yields skip and advances the instruction pointer. Truly disabled opcodes fail unconditionally; OP_VER is conditional.

**Instruction Pointer Advancement**: For conditional opcodes in false branches, the instruction pointer must advance:

$$\forall opcode \in \{\text{OP_IF}, \text{OP_NOTIF}\}, script \in \mathcal{SC}, i \in \mathbb{N}, fExec = \text{false}: \text{ExecuteConditional}(opcode, script, i, fExec) \implies i' = i + 1$$

Where $i'$ is the new instruction pointer position after handling the conditional in a false branch.

**Properties**:
- False branch advancement: In false branches, instruction pointer must increment before continuing to prevent infinite loops
- OP_IF and OP_NOTIF: Both opcodes must advance instruction pointer in false branches: $i' = i + 1$
- Loop prevention: Without instruction pointer advancement, the same opcode would be processed repeatedly, causing infinite loops

**Implementation Note**: This is an implementation detail that ensures correct script execution. The mathematical specification focuses on the observable behavior (script execution succeeds or fails), but implementations must ensure instruction pointer advancement to prevent infinite loops.

**IsMinimalIfCondition**: $\mathbb{B}^* \rightarrow \{\text{true}, \text{false}\}$

Returns true iff the byte string is a minimal encoding of a boolean (SegWit MINIMALIF rule): empty, or exactly 1 byte encoding a valid boolean or small number.

**Properties**:
- Empty is minimal: $|bytes| = 0 \implies result = \text{true}$ (covered by **F_MinimalIfEmptyTrue**)
- Long is not minimal: $|bytes| > 1 \implies result = \text{false}$ (covered by **F_MinimalIfLongFalse**)

**Formula** (**F_MinimalIfEmptyTrue**):
$$result == true$$

When the byte string is empty ($|bytes| = 0$), IsMinimalIfCondition always returns true. An empty stack element is the minimal encoding of false.

**Formula** (**F_MinimalIfLongFalse**):
$$result == false$$

When the byte string has more than one byte ($|bytes| > 1$), IsMinimalIfCondition always returns false. Multi-byte encodings are not minimal for a boolean condition.

#### 5.2.5 Script Verification Flags

**CalculateScriptFlags**: $\mathcal{TX} \times \mathcal{W}^? \times \mathbb{N} \times \text{Network} \rightarrow \mathbb{N}_{32}$

**Properties**:
- Flag activation: $result = f \implies \forall flag \in f: h \geq H_{flag}(n)$
- Per-transaction calculation: $\text{CalculateScriptFlags}(tx_1, w_1, h, n) \neq \text{CalculateScriptFlags}(tx_2, w_2, h, n)$ (may differ for different transactions)
- Non-negative bitmask: $result \geq 0$ (flags are a $32$-bit unsigned mask; consensus uses only defined bits)

**Note**: Flag sets are monotone in height — flags are never removed once activated: for $h_1 \leq h_2$, $\text{CalculateScriptFlags}(tx, w, h_1, n) \subseteq \text{CalculateScriptFlags}(tx, w, h_2, n)$. This is a set-containment property not directly modelable in Z3's integer arithmetic.

For transaction $tx$, witness $w$, height $h$, and network $n$:

$$\text{CalculateScriptFlags}(tx, w, h, n) = \bigcup_{flag \in \text{ActiveFlags}(tx, w, h, n)} flag$$

Where $\text{ActiveFlags}(tx, w, h, n) \subseteq \text{AllFlags}$ is the set of flags active for $(tx, w)$ at height $h$ on network $n$:

$$\text{ActiveFlags}(tx, w, h, n) = \{f : f \in \text{AllFlags} \land \text{IsFlagActive}(f, tx, w, h, n)\}$$

**Flag Activation**: $\text{IsFlagActive}(f, tx, w, h, n) = (h \geq H_f(n)) \land \text{FlagCondition}(f, tx, w)$

Where:
- $H_f(n)$ is the activation height for flag $f$ on network $n$
- $result$ is the transaction-specific condition for flag $f$

**Consensus vs relay**: Many nodes apply **SCRIPT_VERIFY_STRICTENC** and **SCRIPT_VERIFY_LOW_S** only as **mempool / relay (standardness)** rules. For **block connection**, the consensus script flags OR in **SCRIPT_VERIFY_DERSIG** at BIP66 height, not `STRICTENC` or `LOW_S`. Mainnet may therefore contain **post-BIP66** confirmed transactions whose ECDSA signatures are strictly DER (required by **DERSIG**) but are not low-$S$; consensus still accepts them. This specification states **consensus** behavior; **relay** policy remains implementation-defined (including $\text{AcceptToMemoryPool}$-class admission rules).

**Flag Definitions**:
- **SCRIPT_VERIFY_P2SH** ($f = 0x01$): $H_f(\text{mainnet}) = 173,805$, $\text{FlagCondition} = \text{true}$ (always active after activation)
- **SCRIPT_VERIFY_STRICTENC** ($f = 0x02$): **Relay / standardness** (not added by consensus block script-flag height gating at BIP66). $\text{FlagCondition}$ and activation for blocks: **not applicable** to $\text{ConnectBlock}$ parity.
- **SCRIPT_VERIFY_DERSIG** ($f = 0x04$): $H_f(\text{mainnet}) = 363,725$ (BIP66), $\text{FlagCondition} = \text{true}$. **Consensus** base flag after activation (strict DER encodings for ECDSA signatures in executed scripts).
- **SCRIPT_VERIFY_LOW_S** ($f = 0x08$): **Relay / standardness** (not added by consensus block script-flag height gating at BIP66). $\text{FlagCondition}$ for blocks: **not applicable** to $\text{ConnectBlock}$ parity.
- **SCRIPT_VERIFY_NULLDUMMY** ($f = 0x10$): $H_f(\text{mainnet}) = 481,824$ (BIP147), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY** ($f = 0x200$): $H_f(\text{mainnet}) = 388,381$ (BIP65), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_CHECKSEQUENCEVERIFY** ($f = 0x400$): $H_f(\text{mainnet}) = 419,328$ (BIP112 / BIP9 `csv` deployment on mainnet), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_WITNESS** ($f = 0x800$): $H_f(\text{mainnet}) = 481,824$ (SegWit), $\text{FlagCondition} = (\text{HasNonEmptyInputWitness}(w) \lor \text{IsSegWitTransaction}(tx))$

Where $\text{HasNonEmptyInputWitness}(w)$ is true iff witness data $w$ contains at least one input stack $w_i$ with $\neg\text{IsWitnessEmpty}(w_i)$. Witness-extended block serialization may attach empty stacks to legacy inputs; those empty stacks alone must not satisfy the witness flag condition.
- **SCRIPT_VERIFY_WITNESS_PUBKEYTYPE** ($f = 0x8000$): $H_f(\text{mainnet}) = 709,632$ (Taproot), $\text{FlagCondition} = \exists o \in tx.\text{outputs} : \text{IsP2TR}(o.\text{scriptPubkey})$

**P2TR Detection**: $\text{IsP2TR}(spk) = (|spk| = 34) \land (spk[0] = 0x51) \land (spk[1] = 0x20)$

Where:
- $0x51$ is OP_1
- $0x20$ is push 32 bytes

**Mathematical Property**: Flags are calculated per-transaction, not per-block:

$$\forall tx_1, tx_2 \in \mathcal{TX}, tx_1 \neq tx_2 : \text{CalculateScriptFlags}(tx_1, w_1, h, n) \neq \text{CalculateScriptFlags}(tx_2, w_2, h, n) \text{ (may differ)}$$

**Theorem 5.2.2** (Per-Transaction Flag Calculation): Script verification flags must be calculated per-transaction based on transaction characteristics and block height.

*Proof*: From the definition of $\text{CalculateScriptFlags}$, flags depend on both block height (activation) and transaction characteristics (witness presence, output types). Different transactions in the same block may have different flags, so flags must be computed per transaction.

**Activation Heights** (Mainnet, consensus **block** flags):
- P2SH: Block 173,805
- BIP66 (consensus **DERSIG**): Block 363,725
- BIP65 (CLTV): Block 388,381
- BIP112 (CHECKSEQUENCEVERIFY): Block 419,328
- SegWit (WITNESS, NULLDUMMY / BIP147): Block 481,824
- Taproot (WITNESS_PUBKEYTYPE): Block 709,632

#### 5.2.6 Script Flag Exceptions

Some blocks use different script verification flags than the default (historical BIP16 and Taproot activation exceptions).

**ScriptFlagExceptions**: $\text{Network} \rightarrow (\mathbb{H} \rightharpoonup \mathbb{N}_{32})$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Override masks: if $f = \text{ScriptFlagExceptions}(n)(h_b)$ is defined, then $f \geq 0$ (consensus uses 32-bit unsigned script flag words).

For each network $n$, $\text{ScriptFlagExceptions}(n)$ is a partial map from block hash to override flags. When validating transactions in block $b$, if $\text{hash}(b) \in \text{dom}(\text{ScriptFlagExceptions}(n))$, use the override; otherwise use $\text{CalculateScriptFlags}(tx, w, h, n)$.

**GetBlockScriptFlags**: $\mathbb{H} \times \mathcal{TX} \times \mathcal{W}^? \times \mathbb{N} \times \text{Network} \rightarrow \mathbb{N}_{32}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Exception dispatch: if $h_b \in \text{dom}(\text{ScriptFlagExceptions}(n))$ then $result = \text{ScriptFlagExceptions}(n)(h_b)$.

$$\text{GetBlockScriptFlags}(h_b, tx, w, h, n) = \begin{cases}
\text{ScriptFlagExceptions}(n)(h_b) & \text{if } h_b \in \text{dom}(\text{ScriptFlagExceptions}(n)) \\
\text{CalculateScriptFlags}(tx, w, h, n) & \text{otherwise}
\end{cases}$$

Where $h_b = \text{hash}(b)$ is the block hash. Mainnet has 2 exceptions (BIP16, Taproot); testnet has 1 (BIP16). See [§2.2.1](#221-networks-and-parameters).

### 5.3 Block Validation

*Intuition.* A block is accepted only if its **header** satisfies proof-of-work, version, and time rules relative to chain context ([§5.3.1](#531-header-validation), detailed with PoW in [§7](#7-proof-of-work)) and its **body** applies cleanly to the UTXO set at the connecting height. Concretely, transactions are checked in order: each must pass structural checks and input/value rules against the **evolving** UTXO set after prior transactions in the same block; the **first** transaction is the coinbase, whose outputs are capped by block subsidy plus the fees aggregated from non-coinbase transactions. Separating header checks from Merkle/consensus transaction checks reflects what nodes can validate locally versus what binds the ordered tx list to `merkle_root` (enforced inside connect logic rather than inside the header predicate alone).

**ConnectBlock**: $\mathcal{B} \times \mathcal{US} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\} \times \mathcal{US}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Block structure: $result = \text{valid} \implies |b.transactions| > 0$. Coinbase requirement: $result = \text{valid} \implies \text{IsCoinbase}(b.transactions[0]) = \text{true}$. On success, $us'$ reflects all transactions in $b$; every transaction passes `CheckTransaction` and `CheckTxInputs`.

For block $b = (h, txs)$ with UTXO set $us$ at height $height$:

#### 5.3.1 Header Validation

**ValidBlockHeader**: $\mathcal{H} \times \mathbb{N} \times \mathcal{C} \rightarrow \{\text{true}, \text{false}\}$

`ValidBlockHeader(h, height, ctx)` is the conjunction of the following rules. The `ConnectBlock` formula above writes it as `ValidBlockHeader(h)` for brevity; in practice the block height and time context are always available.

| Rule | Condition | Implementation |
|------|-----------|----------------|
| H01 — Minimum version | $h.\text{version} \geq 1$ | `validate_block_header` (§5.3) |
| H02 — Height-dependent version (BIP90) | $h.\text{version} \geq \text{MinVersion}(height)$ | `check_bip90` (§5.4.4) |
| H03 — Non-zero timestamp | $h.\text{timestamp} \neq 0$ | `validate_block_header` |
| H04 — Timestamp within window | $h.\text{timestamp} \leq ctx.\text{network\_time} + \text{MAX\_FUTURE\_BLOCK\_TIME}$ | `validate_block_header` |
| H05 — Timestamp above MTP (BIP113) | $h.\text{timestamp} \geq \text{MedianTimePast}(\text{recent headers})$ | `validate_block_header` |
| H06 — Non-zero bits | $h.\text{bits} \neq 0$ | `validate_block_header` |
| H07 — Proof of work | $\text{SHA256}(\text{SHA256}(\text{serialize}(h))) < \text{ExpandTarget}(h.\text{bits})$ | `check_proof_of_work` (§7.2) |
| H08 — Parent hash | $h.\text{prev\_block\_hash} = \text{hash}(\text{parent header})$ | node layer (chain linkage) |

$$\text{MinVersion}(height) = \begin{cases} 4 & \text{if BIP65 active at } height \\ 3 & \text{if BIP66 active at } height \\ 2 & \text{if BIP34 active at } height \\ 1 & \text{otherwise} \end{cases}$$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Version floor: $result = \text{true} \implies h.\text{version} \geq 1$. Non-zero timestamp: $result = \text{true} \implies h.\text{timestamp} \neq 0$. Non-zero bits: $result = \text{true} \implies h.\text{bits} \neq 0$. PoW necessary: $result = \text{true} \implies \text{CheckProofOfWork}(h) = \text{true}$.

**Notes:**

H01 and H02 compose: H01 is the unconditional floor (version 0 is always rejected); H02 enforces tighter minimums after BIP activation heights. Version 1 is valid before BIP34, invalid after.

H08 (parent hash linkage) is enforced by the node chain layer, not by `blvm-consensus`. Rules H01–H07 are the consensus-local subset checked inside `connect_block`.

Merkle root correctness is *not* part of `ValidBlockHeader`. The `bits` field check (H06) rejects an all-zero `bits` as a structural sanity check; cryptographic verification of the merkle root against the block's transaction list happens inside `connect_block` itself after header validation passes.

H04 and H05 require a time context (network time and recent-header MTP). When no context is available (e.g. headers-first sync), only H01, H03, H06 are enforced.

**Formula** (**F_HeaderVersionFloor**):
$$result = 0$$

When block version is 0 (`block_version == 0`), header validation always returns false (H01 rejected). Version 0 has never been valid in Bitcoin: $\text{ValidBlockHeader}(h, \ldots) = \text{false}$ when $h.\text{version} = 0$.

**Formula** (**F_HeaderBitsFloor**):
$$result = 0$$

When the compact bits word is zero (`bits == 0`), header validation always returns false (H06 rejected). A zero bits field encodes an invalid difficulty target: $\text{ValidBlockHeader}(h, \ldots) = \text{false}$ when $h.\text{bits} = 0$.

#### 5.3.2 Transaction Application Equivalence

**Theorem 5.3.2** (ApplyTransaction Equivalence): The functions `apply_transaction` and `apply_transaction_with_id` produce identical results:

$$\forall tx \in \mathcal{TX}, us \in \mathcal{US}, h \in \mathbb{N}:$$
$$\text{ApplyTransaction}(tx, us, h) = \text{ApplyTransactionWithId}(tx, \text{CalculateTxId}(tx), us, h)$$

*Proof*: Both functions apply identical UTXO set transformations. The sole difference is the source of the transaction identifier: $\text{ApplyTransaction}$ computes $\text{CalculateTxId}(tx)$ internally, while $\text{ApplyTransactionWithId}$ accepts it as argument. The outputs are identical by structural induction on the transaction application steps.

**Corollary 5.3.2.1**: Transaction application is deterministic and side-effect-free, regardless of which function is used.

$$\text{ConnectBlock}(b = (h, txs), us, \text{height}) = \begin{cases}
(\text{invalid}, us) & \text{if } \neg\text{ValidBlockHeader}(h) \\
(\text{invalid}, us) & \text{if } \exists tx \in txs : \text{CheckTransaction}(tx) \neq \text{valid} \\
(\text{invalid}, us) & \text{if } \exists tx \in txs : \text{CheckTxInputs}(tx, us, \text{height}) = (\text{invalid}, \cdot) \\
(\text{invalid}, us) & \text{if } \exists tx \in txs : \neg\text{VerifyScripts}(tx, us, \text{height}) \\
(\text{invalid}, us) & \text{if } \text{coinbase output} > \sum_{tx \in txs} \text{fee}(tx) + \text{GetBlockSubsidy}(\text{height}) \\
(\text{valid}, us') & \text{otherwise}
\end{cases}$$

Where $us' = \text{ApplyTransactions}(txs, us)$ in the final case.

```mermaid
flowchart TD
    A[Block Input] --> B[Validate Block Header]
    B --> C{Header Valid?}
    C -->|No| D[❌ Invalid Block]
    C -->|Yes| E[Initialize Validation]
    
    E --> F[For each Transaction]
    F --> G[CheckTransaction]
    G --> H{Transaction Valid?}
    H -->|No| I[❌ Invalid Transaction]
    H -->|Yes| J[CheckTxInputs]
    J --> K{UTXO Available?}
    K -->|No| L[❌ Invalid UTXO]
    K -->|Yes| M[VerifyScript]
    M --> N{Script Valid?}
    N -->|No| O[❌ Invalid Script]
    N -->|Yes| P{More Transactions?}
    P -->|Yes| F
    P -->|No| Q[Calculate Fees & Subsidy]
    
    Q --> R{Coinbase Valid?}
    R -->|No| S[❌ Invalid Coinbase]
    R -->|Yes| T[Apply Transactions to UTXO]
    T --> U[✅ Valid Block]
    
    style A fill:#e1f5fe
    style U fill:#c8e6c9
    style D fill:#ffcdd2
    style I fill:#ffcdd2
    style L fill:#ffcdd2
    style O fill:#ffcdd2
    style S fill:#ffcdd2
```

**ApplyTransaction**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathcal{US}$

**Properties**:
- Defined: $\text{true}$

**Note**: Undo entries match inputs: $result = (us', ul) \implies |ul| = |tx.inputs|$. Coinbase has no undo entries: $\text{IsCoinbase}(tx) \implies ul = \emptyset$.
- UTXO consistency: $result = (us', ul) \implies$ UTXO set $us'$ reflects transaction $tx$ applied to $us$
- Spent inputs removed: $result = (us', ul) \land \neg \text{IsCoinbase}(tx) \implies \forall i \in tx.inputs : i.prevout \notin us'$ (spent inputs removed)
- Outputs added: $result = (us', ul) \implies \forall i \in [0, |tx.outputs|) : (tx.id, i) \in us'$ (all outputs added)
- UTXO set size: $result = (us', ul) \land \neg \text{IsCoinbase}(tx) \implies |us'| = |us| - |tx.inputs| + |tx.outputs|$
- Coinbase UTXO set size: $result = (us', ul) \land \text{IsCoinbase}(tx) \implies |us'| = |us| + |tx.outputs|$
- Idempotency with undo: $result = (us', ul) \implies \text{ApplyUndo}(us', ul) = us$ where $ul$ is undo log from ConnectBlock

$$\text{ApplyTransaction}(tx, us, h) = \begin{cases}
us \cup \{(tx.\text{id}, i) \mapsto tx.\text{outputs}[i] : i \in [0, |tx.\text{outputs}|)\} & \text{if } \text{IsCoinbase}(tx) \\
(us \setminus \{i.\text{prevout} : i \in tx.\text{inputs}\}) \cup \{(tx.\text{id}, i) \mapsto tx.\text{outputs}[i] : i \in [0, |tx.\text{outputs}|)\} & \text{otherwise}
\end{cases}$$

```mermaid
stateDiagram-v2
    [*] --> UTXO_Set
    
    state UTXO_Set {
        [*] --> Input_Validation
        Input_Validation --> Remove_Spent_UTXOs
        Remove_Spent_UTXOs --> Add_New_UTXOs
        Add_New_UTXOs --> [*]
    }
    
    UTXO_Set --> Transaction_Application : ApplyTransaction(tx, us)
    
    state Transaction_Application {
        [*] --> Check_Type
        Check_Type --> Coinbase_Transaction : isCoinbase(tx)
        Check_Type --> Regular_Transaction : !isCoinbase(tx)
        
        Coinbase_Transaction --> Add_Outputs : us ∪ {new outputs}
        Regular_Transaction --> Remove_Inputs : us - {spent inputs}
        Remove_Inputs --> Add_Outputs : us ∪ {new outputs}
        Add_Outputs --> [*]
    }
    
    Transaction_Application --> Updated_UTXO_Set : Return us'
    Updated_UTXO_Set --> UTXO_Set : Next transaction
    
    note right of UTXO_Set
        UTXO Set maintains:
        - Unspent transaction outputs
        - Value conservation
        - No double spending
    end note
```

### 5.4 BIP Validation Rules

This section specifies the mathematical properties of critical Bitcoin Improvement Proposals (BIPs) that enforce consensus rules for block and transaction validation.

#### 5.4.1 BIP30: Duplicate Coinbase Prevention

**BIP30Check**: $\mathcal{B} \times \mathcal{US} \times \mathbb{N} \times \text{Network} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Deactivation pass: $h > H_{30\_deact}(n) \implies result = \text{true}$. Before the deactivation height, `BIP30Check` rejects any block when the coinbase txid already exists in the UTXO set.

For block $b = (h, txs)$ with UTXO set $us$, height $h$, and network $n$:

$$\text{BIP30Check}(b, us, h, n) = \begin{cases}
\text{valid} & \text{if } h > H_{30\_deact}(n) \\
\text{invalid} & \text{if } h \leq H_{30\_deact}(n) \land \exists tx \in txs : \text{IsCoinbase}(tx) \land \text{txid}(tx) \in \text{CoinbaseTxids}(us) \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where:
- $H_{30\_deact}(n)$ is the BIP30 deactivation height for network $n$:
  - Mainnet: $H_{30\_deact}(\text{mainnet}) = 91,722$
  - Testnet: $H_{30\_deact}(\text{testnet}) = 0$ (never enforced)
  - Regtest: $H_{30\_deact}(\text{regtest}) = 0$ (never enforced)
- $result$ is the set of all coinbase transaction IDs that have created UTXOs in $us$.

**Deactivation**: BIP30 was disabled after block 91,722 (mainnet) to allow duplicate coinbases in blocks 91,842 and 91,880 (historical bug, grandfathered exception).

**Mathematical Property**: BIP30 ensures coinbase transaction uniqueness before deactivation:

$$\forall b_1, b_2 \in \mathcal{B}, b_1 \neq b_2, h \leq H_{30\_deact}(n) : \text{IsCoinbase}(tx_1) \land \text{IsCoinbase}(tx_2) \implies \text{txid}(tx_1) \neq \text{txid}(tx_2)$$

**Theorem 5.4.1** (BIP30 Uniqueness): BIP30 prevents duplicate coinbase transactions before deactivation height.

*Proof*: By construction, if a coinbase transaction $tx$ at height $h \leq H_{30\_deact}(n)$ has $\text{txid}(tx) \in \text{CoinbaseTxids}(us)$, then $\text{BIP30Check}(b, us, h, n) = \text{invalid}$, preventing the block from being accepted. Since coinbase transactions create new UTXOs, their transaction IDs are recorded in the UTXO set, ensuring uniqueness across all blocks before deactivation.

**Activation**: Block 0 (always active until deactivation)  

**Formula** (**F_BIP30DeactivationPass**):
$$result == 1$$

When `bip30_active == 0` (fork inactive), the duplicate-coinbase check always passes (returns 1). The full property $\forall b, us, n : h > H_{30\_\text{deact}}(n) \implies \text{BIP30Check}(b, us, h, n) = \text{valid}$ is stated in prose; the Z3-verifiable guard is the postcondition under `requires(bip30_active == 0)`.

---

#### 5.4.2 BIP34: Block Height in Coinbase

**BIP34Check**: $\mathcal{B} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Pre-activation pass: $h < H_{34} \implies \text{result} = \text{true}$
- Height requirement: $\text{BIP34Check}(b, h) = \text{valid} \implies h < H_{34} \lor (\forall tx \in b.transactions : \text{IsCoinbase}(tx) \implies \text{ExtractHeight}(tx) = h)$
- Coinbase height: $\text{BIP34Check}(b, h) = \text{invalid} \implies h \geq H_{34} \land \exists tx \in b.transactions : \text{IsCoinbase}(tx) \land \text{ExtractHeight}(tx) \neq h$
- Validation correctness: $\text{BIP34Check}(b, h)$ ensures coinbase contains correct block height after activation

For block $b = (h, txs)$ at height $h$:

$$\text{BIP34Check}(b, h) = \begin{cases}
\text{invalid} & \text{if } h \geq H_{34} \land \exists tx \in txs : \text{IsCoinbase}(tx) \land \text{ExtractHeight}(tx) \neq h \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where:
- $H_{34}$ is the BIP34 activation height (mainnet: 227,931; testnet: 21,111; regtest: 0)
- $result$ extracts the block height from coinbase scriptSig using CScriptNum encoding

**Height Encoding**: The block height is encoded in the coinbase scriptSig as a script number:

$$\text{EncodeHeight}(h) = \text{CScriptNum}(h)$$

Where $\text{CScriptNum}$ encodes the height as a variable-length integer in the script format.

**Mathematical Property**: BIP34 ensures coinbase height consistency:

$$\forall b = (h, txs) \in \mathcal{B}, h \geq H_{34} : \text{IsCoinbase}(tx) \implies \text{ExtractHeight}(tx) = h$$

**Theorem 5.4.2** (BIP34 Height Consistency): BIP34 ensures that coinbase transactions encode the correct block height.

*Proof*: For any block $b$ at height $h \geq H_{34}$, if the coinbase transaction $tx$ does not encode height $h$ in its scriptSig, then $\text{BIP34Check}(b, h) = \text{invalid}$, preventing block acceptance. This ensures that all blocks after activation height have consistent height encoding.

**Formula** (**F_BIP34PreActivationPass**):
$$result == 1$$

When `bip34_active == 0` (fork inactive), the coinbase-height check always passes (returns 1). The full property $\forall b, n : h < H_{34}(n) \implies \text{BIP34Check}(b, h) = \text{valid}$ is stated in prose; the Z3-verifiable guard is the postcondition under `requires(bip34_active == 0)`.

---

#### 5.4.3 BIP66: Strict DER Signature Validation

**BIP66Check**: $\mathbb{S} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Strict DER requirement: $\text{BIP66Check}(sig, h) = \text{valid} \implies h < H_{66} \lor \text{IsStrictDER}(sig)$
- DER validation: $\text{BIP66Check}(sig, h) = \text{invalid} \implies h \geq H_{66} \land \neg \text{IsStrictDER}(sig)$
- Validation correctness: $\text{BIP66Check}(sig, h)$ enforces strict DER encoding after activation height

For signature $sig \in \mathbb{S}$ at block height $h$:

$$\text{BIP66Check}(sig, h) = \begin{cases}
\text{invalid} & \text{if } h \geq H_{66} \land \neg \text{IsStrictDER}(sig) \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where:
- $H_{66}$ is the BIP66 activation height (mainnet: 363,725; testnet: 330,776; regtest: 0)
- $result$ verifies that $sig$ is strictly DER-encoded according to [X.690](https://www.itu.int/rec/T-REC-X.690/) ASN.1 encoding rules

**Strict DER Requirements**:
1. **Sequence Structure**: $sig$ must be a valid DER-encoded SEQUENCE
2. **Integer Encoding**: Both $r$ and $s$ values must be strictly DER-encoded integers
3. **No Leading Zeros**: Integers must not have leading zero bytes (except for negative numbers)
4. **Minimal Length**: Encoding must use minimal length representation

**Mathematical Property**: BIP66 enforces strict DER signature encoding:

$$\forall sig \in \mathbb{S}, h \geq H_{66} : \text{BIP66Check}(sig, h) = \text{valid} \implies \text{IsStrictDER}(sig)$$

**Theorem 5.4.3** (BIP66 Strict DER Enforcement): BIP66 ensures all signatures after activation height are strictly DER-encoded.

*Proof*: For any signature $sig$ at height $h \geq H_{66}$, if $\neg \text{IsStrictDER}(sig)$, then $\text{BIP66Check}(sig, h) = \text{invalid}$, causing script validation to fail. This ensures that all signatures after activation conform to strict DER encoding, preventing signature malleability.

**Formula** (**F_BIP66PreActivationPass**):
$$result == 1$$

Before BIP66 activation (fork not yet active), the DER signature check always passes. Any signature is accepted when the fork is inactive.

---

#### 5.4.4 BIP90: Block Version Enforcement

**BIP90Check**: $\mathcal{H} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Version requirement: $\text{BIP90Check}(h, height) = \text{valid} \implies height < H_{34} \lor h.version \geq 2$
- Version enforcement: $\text{BIP90Check}(h, height) = \text{invalid} \implies height \geq H_{34} \land h.version < 2$
- Validation correctness: $\text{BIP90Check}(h, height)$ enforces minimum block version after BIP34 activation

For block header $h = (version, \ldots)$ at height $height$:

$$\text{BIP90Check}(h, height) = \begin{cases}
\text{invalid} & \text{if } height \geq H_{34} \land version < 2 \\
\text{invalid} & \text{if } height \geq H_{66} \land version < 3 \\
\text{invalid} & \text{if } height \geq H_{65} \land version < 4 \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where:
- $H_{34}$ is BIP34 activation height (mainnet: 227,931)
- $H_{66}$ is BIP66 activation height (mainnet: 363,725)
- $H_{65}$ is BIP65 activation height (mainnet: 388,381)

**Mathematical Property**: BIP90 enforces minimum block versions:

$$\forall h = (version, \ldots) \in \mathcal{H}, height \in \mathbb{N} : \text{BIP90Check}(h, height) = \text{valid} \implies version \geq \text{MinVersion}(height)$$

Where $\text{MinVersion}(height)$ is the minimum required block version at height $height$:

$$\text{MinVersion}(height) = \begin{cases}
4 & \text{if } height \geq H_{65} \\
3 & \text{if } height \geq H_{66} \\
2 & \text{if } height \geq H_{34} \\
1 & \text{otherwise}
\end{cases}$$

**Theorem 5.4.4** (BIP90 Version Enforcement): BIP90 ensures blocks use appropriate versions based on activation heights.

*Proof*: For any block header $h$ at height $height$, if $version < \text{MinVersion}(height)$, then $\text{BIP90Check}(h, height) = \text{invalid}$, preventing block acceptance. This ensures that blocks after each BIP activation use the correct minimum version, simplifying activation logic.

**Formula** (**F_BIP90PreActivationPass**):
$$result == 1$$

Before BIP90 activation (fork not yet active), all blocks pass the version enforcement check regardless of version number.

---

#### 5.4.5 BIP147: NULLDUMMY Enforcement

**BIP147Check**: $\mathbb{S} \times \mathbb{S} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- NULLDUMMY requirement: $\text{BIP147Check}(scriptSig, scriptPubkey, h) = \text{valid} \implies h < H_{147} \lor \neg \text{ContainsMultisig}(scriptPubkey) \lor \text{IsNullDummy}(scriptSig)$
- Multisig validation: $\text{BIP147Check}(scriptSig, scriptPubkey, h) = \text{invalid} \implies h \geq H_{147} \land \text{ContainsMultisig}(scriptPubkey) \land \neg \text{IsNullDummy}(scriptSig)$
- Validation correctness: $\text{BIP147Check}(scriptSig, scriptPubkey, h)$ enforces NULLDUMMY for multisig after activation

For scriptSig $scriptSig$, scriptPubkey $scriptPubkey$ containing OP_CHECKMULTISIG, and block height $h$:

$$\text{BIP147Check}(scriptSig, scriptPubkey, h) = \begin{cases}
\text{invalid} & \text{if } h \geq H_{147} \land \text{ContainsMultisig}(scriptPubkey) \land \neg \text{IsNullDummy}(scriptSig) \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where:
- $H_{147}$ is the BIP147 activation height (mainnet: 481,824; testnet: 834,624; regtest: 0)
- $result$ checks if $scriptPubkey$ contains OP_CHECKMULTISIG (0xae)
- $result$ verifies that the dummy element (extra stack element consumed by OP_CHECKMULTISIG) is empty (OP_0)

**DecodeCScriptNum**: $\mathbb{S} \rightarrow \mathbb{Z}$

**Properties**:
- Empty byte array: $|bytes| = 0 \implies \text{DecodeCScriptNum}(bytes) = 0$ (empty array decodes to 0)
- Minimal encoding: $result$ interprets bytes as minimal little-endian signed integer
- Range: $result \in \mathbb{Z}$ (can be negative or positive)

For byte string $bytes \in \mathbb{S}$:

$$\text{DecodeCScriptNum}(bytes) = \begin{cases}
0 & \text{if } |bytes| = 0 \\
\text{DecodeLittleEndian}(bytes) & \text{otherwise}
\end{cases}$$

Where $\text{DecodeLittleEndian}(bytes)$ decodes bytes as a minimal little-endian signed integer.

**OP_CHECKMULTISIG Stack Consumption**: OP_CHECKMULTISIG consumes $m + n + 2$ stack elements where:
1. $m$ signatures
2. $n$ public keys
3. $m = \text{DecodeCScriptNum}(stack[|stack|-2])$ (signature threshold, decoded via CScriptNum)
4. $n = \text{DecodeCScriptNum}(stack[|stack|-1])$ (public key count, decoded via CScriptNum)
5. **Dummy element** (must be empty with BIP147)

**Properties**:
- CScriptNum decoding: $m = \text{DecodeCScriptNum}(m_{bytes})$ and $n = \text{DecodeCScriptNum}(n_{bytes})$ where $m_{bytes}$ and $n_{bytes}$ are the byte strings on the stack
- Empty array handling: $|m_{bytes}| = 0 \implies m = 0$ (empty array decodes to 0)
- Minimal encoding: $m_{bytes}$ and $n_{bytes}$ must be minimally encoded (no leading zeros except for sign)

**Mathematical Property**: BIP147 enforces NULLDUMMY for multisig scripts:

$$\forall scriptSig, scriptPubkey \in \mathbb{S}, h \geq H_{147} : \text{ContainsMultisig}(scriptPubkey) \land \text{BIP147Check}(scriptSig, scriptPubkey, h) = \text{valid} \implies \text{IsNullDummy}(scriptSig)$$

**Theorem 5.4.5** (BIP147 NULLDUMMY Enforcement): BIP147 ensures that OP_CHECKMULTISIG dummy elements are empty after activation height.

*Proof*: For any scriptSig $scriptSig$ and scriptPubkey $scriptPubkey$ containing OP_CHECKMULTISIG at height $h \geq H_{147}$, if $\neg \text{IsNullDummy}(scriptSig)$, then $\text{BIP147Check}(scriptSig, scriptPubkey, h) = \text{invalid}$, causing script validation to fail. This ensures that all multisig scripts after activation use empty dummy elements, which is required for SegWit compatibility.

**Formula** (**F_BIP147PreActivationPass**):
$$result == 1$$

Before BIP147 activation (fork not yet active), all CHECKMULTISIG operations pass the null-dummy check regardless of the dummy element's content.

**Theorem 5.4.5.1** (OP_CHECKMULTISIG CScriptNum Requirement): OP_CHECKMULTISIG must use CScriptNum decoding for $m$ and $n$ values.

$$\forall stack \in \mathcal{ST}: \text{OP_CHECKMULTISIG}(stack) \text{ uses } m = \text{DecodeCScriptNum}(stack[|stack|-2]) \land n = \text{DecodeCScriptNum}(stack[|stack|-1])$$

*Proof*: From the definition of $\text{DecodeCScriptNum}$, OP_CHECKMULTISIG parameters use CScriptNum decoding. This allows empty byte arrays to be interpreted as 0, which is required for certain edge cases (e.g., block 299,917). Raw byte parsing would reject empty arrays, but CScriptNum correctly decodes them to 0.

---

#### 5.4.6 BIP119: OP_CHECKTEMPLATEVERIFY (CTV)

**BIP119Check**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{H} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Template hash validation: $\text{BIP119Check}(tx, i, h) = \text{valid} \iff \text{TemplateHash}(tx, i) = h$
- Validation correctness: $\text{BIP119Check}(tx, i, h)$ validates template hash matches expected value

For transaction $tx$, input index $i$, and template hash $h$:

$$\text{BIP119Check}(tx, i, h) = \begin{cases}
\text{valid} & \text{if } \text{TemplateHash}(tx, i) = h \\
\text{invalid} & \text{otherwise}
\end{cases}$$

**Template Hash Calculation**:

$$\text{TemplateHash}(tx, i) = \text{SHA256}(\text{SHA256}(\text{TemplatePreimage}(tx, i)))$$

Where $\text{TemplatePreimage}(tx, i)$ is the serialized template structure:

$$\text{TemplatePreimage}(tx, i) = \text{Version}(tx) || \text{Inputs}(tx) || \text{Outputs}(tx) || \text{Locktime}(tx) || i$$

**Template Preimage Serialization**:

1. **Transaction Version** (4 bytes, little-endian):
   $$\text{Version}(tx) = \text{LE32}(tx.\text{version})$$

2. **Input Count** (varint):
   $$\text{InputCount}(tx) = \text{VarInt}(|tx.\text{inputs}|)$$

3. **Input Serialization** (for each input $in \in tx.\text{inputs}$):
   - Previous output hash (32 bytes): $in.\text{prevout}.\text{hash}$
   - Previous output index (4 bytes, little-endian): $\text{LE32}(in.\text{prevout}.\text{index})$
   - Sequence (4 bytes, little-endian): $\text{LE32}(in.\text{sequence})$
   - **Note**: $\text{scriptSig}$ is **NOT** included in template (key difference from sighash)

4. **Output Count** (varint):
   $$\text{OutputCount}(tx) = \text{VarInt}(|tx.\text{outputs}|)$$

5. **Output Serialization** (for each output $out \in tx.\text{outputs}$):
   - Value (8 bytes, little-endian): $\text{LE64}(out.\text{value})$
   - Script length (varint): $result$
   - Script bytes: $out.\text{scriptPubkey}$

6. **Locktime** (4 bytes, little-endian):
   $$\text{Locktime}(tx) = \text{LE32}(tx.\text{lockTime})$$

7. **Input Index** (4 bytes, little-endian):
   $$i = \text{LE32}(i)$$

**Mathematical Properties**:

**Theorem 5.4.6.1** (CTV Determinism): Template hash is deterministic:

$$\forall tx \in \mathcal{TX}, i \in \mathbb{N} : \text{TemplateHash}(tx, i) \text{ is unique and deterministic}$$

*Proof*: By construction, $\text{TemplateHash}$ uses SHA256, which is a deterministic cryptographic hash function. Given the same transaction structure and input index, the template preimage is identical, producing the same hash.

**Theorem 5.4.6.2** (CTV Uniqueness): Different transactions produce different template hashes with overwhelming probability:

$$\forall tx_1, tx_2 \in \mathcal{TX}, tx_1 \neq tx_2 : P(\text{TemplateHash}(tx_1, i) = \text{TemplateHash}(tx_2, i)) \approx 2^{-256}$$

*Proof*: SHA256 is a cryptographic hash function with collision resistance. The probability of two different transactions producing the same template hash is approximately $2^{-256}$, which is negligible.

**Theorem 5.4.6.3** (CTV Input-Specific): Template hash depends on input index:

$$\forall tx \in \mathcal{TX}, i_1, i_2 \in \mathbb{N}, i_1 \neq i_2 : \text{TemplateHash}(tx, i_1) \neq \text{TemplateHash}(tx, i_2)$$

*Proof*: The input index $i$ is included in the template preimage. Since $i_1 \neq i_2$, the preimages differ, and by the collision resistance of SHA256, the hashes must differ.

**Theorem 5.4.6.4** (CTV ScriptSig Independence): Template hash does not depend on scriptSig:

$$\forall tx_1, tx_2 \in \mathcal{TX}, i \in \mathbb{N} : (\text{Structure}(tx_1) = \text{Structure}(tx_2) \land tx_1.\text{inputs}[i].\text{scriptSig} \neq tx_2.\text{inputs}[i].\text{scriptSig}) \implies \text{TemplateHash}(tx_1, i) = \text{TemplateHash}(tx_2, i)$$

Where $\text{Structure}(tx)$ includes all fields except scriptSig.

*Proof*: By construction, scriptSig is not included in the template preimage. Therefore, changes to scriptSig do not affect the template hash, allowing the same template to be satisfied by different scriptSigs.

**Opcode Behavior**:

OP_CHECKTEMPLATEVERIFY (opcode 0xb3, OP_NOP4):
- **Stack Input**: $[h]$ where $h \in \mathbb{H}$ is a 32-byte template hash
- **Stack Output**: Nothing (opcode fails if template doesn't match)
- **Validation**: $\text{BIP119Check}(tx, i, h) = \text{valid}$
- **Soft Fork**: Uses OP_NOP4 (0xb3) as upgrade path

**Use Cases**:

1. **Congestion Control**: Transaction batching with predefined templates
2. **Vault Contracts**: Time-locked withdrawals with specific output structures
3. **Payment Channels**: State updates with committed transaction structures
4. **Smart Contracts**: Covenants and state machines with transaction templates

**Activation heights (Bitcoin chain consensus)**:

- **Mainnet**: Not consensus-active. BIP119 has **no** deployed soft fork on the canonical Bitcoin mainnet chain (through the documented chain tip); on chain, opcode **0xb3** remains **OP_NOP4** for consensus purposes. This section specifies the rules **if and when** a deployment activates them; BLVM may implement them behind a feature flag for testing.
- **Public test networks** (default `testnet` / `testnet4` parameters): Same as mainnet under default parameters (no consensus activation unless a future network explicitly deploys BIP119).
- **Regtest**: Height **0** when the local node enables the proposal for development (implementation-defined feature gate).

**Implementation Notes**:

- Template hash calculation must match BIP119 specification exactly
- Input index must be within bounds: $0 \leq i < |tx.\text{inputs}|$
- Transaction must have at least one input and one output
- Template hash is 32 bytes (SHA256 output)
- Opcode requires full transaction context (cannot be used in basic script execution)

---

#### 5.4.7 BIP65: OP_CHECKLOCKTIMEVERIFY (CLTV)

**BIP65Check**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{N} \times \mathbb{H} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Defined: $\text{true}$
- Boolean result: $result \in \{\text{true}, \text{false}\}$
- Type consistency: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$ (types must match)
- Locktime ordering (BIP65): $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \geq lt$ (transaction locktime must be **≥** stack locktime; stack value greater than `tx.lockTime` fails)
- Zero locktime: $(tx.\text{lockTime}, lt) = (0, 0)$ with matching types **may** be valid (mainnet block 659901); BIP65 does **not** unconditionally reject `tx.lockTime = 0`
- Two-argument form: $\text{LocktimeType}(a) = \text{LocktimeType}(b) \land a \geq b \implies \text{valid}$

For transaction $tx$, input index $i$, locktime value $lt$, and block header $h$:

$$\text{BIP65Check}(tx, i, lt, h) = \begin{cases}
\text{invalid} & \text{if } \text{LocktimeType}(tx.\text{lockTime}) \neq \text{LocktimeType}(lt) \\
\text{invalid} & \text{if } tx.\text{lockTime} < lt \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where $\text{LocktimeType}(x) = \begin{cases} \text{BlockHeight} & x < 5\times10^8 \\ \text{Timestamp} & \text{otherwise} \end{cases}$.

**OP_CHECKLOCKTIMEVERIFY (opcode 0xb1)**:
- **Stack Input**: $[lt]$ where $lt$ is a locktime value (encoded as minimal byte string)
- **Stack Output**: Nothing (opcode fails if locktime check doesn't pass)
- **Validation**: $\text{BIP65Check}(tx, i, \text{DecodeLocktime}(lt), h) = \text{valid}$

**Locktime Type Determination**: 

$$\text{LocktimeType}(lt) = \begin{cases}
\text{BlockHeight} & \text{if } lt < 500000000 \\
\text{Timestamp} & \text{otherwise}
\end{cases}$$

**Locktime Encoding/Decoding**: Locktime values are encoded as minimal little-endian byte strings (max 5 bytes) on the script stack.

**Theorem 5.4.7.1** (Locktime Encoding Round-Trip): Locktime encoding and decoding are inverse operations:

$$\forall lt \in \mathbb{N}_{32}: \text{DecodeLocktime}(\text{EncodeLocktime}(lt)) = lt$$

*Proof*: By construction, the encoding uses minimal little-endian representation and decoding reconstructs the value from the byte string. This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.2** (Locktime Type Determination Correctness): Locktime type determination is correct:

$$\forall lt \in \mathbb{N}_{32}: \text{LocktimeType}(lt) = \begin{cases}
\text{BlockHeight} & \text{if } lt < 500000000 \\
\text{Timestamp} & \text{otherwise}
\end{cases}$$

*Proof*: By construction, the threshold $500000000$ correctly separates block heights (which are always $< 500000000$) from Unix timestamps (which are always $\geq 500000000$). This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.3** (CLTV Type Matching Requirement): CLTV requires matching locktime types:

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: \text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$$

*Proof*: By construction, if the types don't match, $\text{BIP65Check}$ returns $\text{invalid}$. This ensures that block height locktimes are only compared with block heights, and timestamps are only compared with timestamps. This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.4** (CLTV locktime ordering): Valid CLTV requires transaction locktime at least the stack value.

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: \text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \geq lt$$

*Proof*: Matches BIP65: the script fails when the stack locktime exceeds `tx.lockTime`.

**Formula** (**F_BIP65Passes**):
$$result == true$$

When locktime types match and transaction locktime meets the script minimum ($tx\_locktime \geq stack\_locktime$), CLTV validation passes. $(tx\_locktime, stack\_locktime) = (0, 0)$ with matching types is valid on mainnet (block 659901).

**Formula** (**F_BIP65PassesTimestamp**):
$$result == true$$

Symmetric to F_BIP65Passes for the timestamp domain: when transaction locktime is a timestamp ($tx\_locktime \geq 500{,}000{,}000$), stack locktime is also a timestamp ($stack\_locktime \geq 500{,}000{,}000$), and $tx\_locktime \geq stack\_locktime$ — CLTV validation passes. Both locktimes share the same type, satisfying the type-match guard; the value comparison passes by the `requires`.

**Formula** (**F_BIP65RejectsZeroLocktime**):
$$result == false$$

When the transaction locktime is zero ($tx\_locktime = 0$), the first guard `tx_locktime != 0` is false and CLTV validation always rejects regardless of the script locktime. A transaction with `nLockTime = 0` can never satisfy any OP_CHECKLOCKTIMEVERIFY script.

**Formula** (**F_BIP65RejectsTypeMismatch**):
$$result == false$$

When the transaction uses a block-height-type locktime ($tx\_locktime < 500{,}000{,}000$) but the script requires a timestamp-type locktime ($stack\_locktime \geq 500{,}000{,}000$), the type-match guard `tx_is_height == sk_is_height` is `true == false = false` and CLTV validation rejects. Proves the cross-type incompatibility invariant.

**Formula** (**F_BIP65RejectsTypeMismatchReverse**):
$$result == false$$

When the transaction uses a timestamp-type locktime ($tx\_locktime \geq 500{,}000{,}000$) but the script requires a block-height-type locktime ($stack\_locktime < 500{,}000{,}000$), the type-match guard fails and CLTV validation rejects. Symmetric to F_BIP65RejectsTypeMismatch.

**Formula** (**F_BIP65RejectsValueTooLow**):
$$result == false$$

When both locktimes are the same type (both block-heights) but the transaction locktime does not meet the script minimum ($tx\_locktime < stack\_locktime$), CLTV validation rejects. The value-comparison term `tx_locktime >= stack_locktime` is false under this precondition.

**Formula** (**F_BIP65RejectsTimestampValueTooLow**):
$$result == false$$

When both locktimes are timestamps ($tx\_locktime \geq 500{,}000{,}000$ and $stack\_locktime \geq 500{,}000{,}000$) but the transaction locktime does not meet the script minimum ($tx\_locktime < stack\_locktime$), CLTV validation rejects. Symmetric to F_BIP65RejectsValueTooLow in the timestamp domain. Together all rejection and acceptance cases form a complete case analysis of BIP65 correctness.

---

#### 5.4.8 BIP348: OP_CHECKSIGFROMSTACK (CSFS)

**BIP348Check**: $\mathbb{S} \times \mathbb{S} \times \mathbb{S} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Tapscript-only. Zero pubkey → invalid. Empty sig → valid (pushes empty). Unknown pubkey type ($|pk| \neq 32 \land |pk| > 0$) → valid. Valid Schnorr sig → valid and push `[0x01]`. Invalid Schnorr sig → invalid.

For message $msg \in \mathbb{S}$, public key $pk \in \mathbb{S}$, signature $sig \in \mathbb{S}$, and block height $h$:

$$\text{BIP348Check}(msg, pk, sig, h) = \begin{cases}
\text{invalid} & \text{if } |pk| = 0 \\
\text{invalid} & \text{if } \text{SigVersion} \neq \text{Tapscript} \\
\text{valid} & \text{if } |sig| = 0 \text{ (push empty vector)} \\
\text{valid} & \text{if } |pk| = 32 \land \text{VerifySchnorr}(msg, pk, sig) = \text{true} \text{ (push [0x01])} \\
\text{invalid} & \text{if } |pk| = 32 \land \text{VerifySchnorr}(msg, pk, sig) = \text{false} \\
\text{valid} & \text{if } |pk| \neq 32 \land |pk| > 0 \text{ (unknown type, succeeds)}
\end{cases}$$

**BIP 340 Schnorr Signature Verification**:

$$\text{VerifySchnorr}(msg, pk, sig) = \begin{cases}
\text{true} & \text{if } |pk| = 32 \land |sig| = 64 \land \text{SchnorrVerify}(\text{SHA256}(msg), pk, sig) = \text{true} \\
\text{false} & \text{otherwise}
\end{cases}$$

Where:
- $pk$ is a 32-byte x-only public key (BIP 340)
- $sig$ is a 64-byte Schnorr signature (BIP 340)
- $msg$ is hashed with SHA256 before verification (BIP 340 accepts any size, but secp256k1 requires 32 bytes)

**Stack Operation**:

OP_CHECKSIGFROMSTACK (opcode 0xcc, replaces OP_SUCCESS204):
- **Stack Input**: $[pk, msg, sig]$ where:
  - $pk \in \mathbb{S}$ is the public key (top of stack)
  - $msg \in \mathbb{S}$ is the message (second from top)
  - $sig \in \mathbb{S}$ is the signature (third from top)
- **Stack Output**: 
  - Empty vector $\emptyset$ if $|sig| = 0$
  - $[0x01]$ (single byte) if signature is valid
  - Script fails if signature is invalid
- **Validation**: $\text{BIP348Check}(msg, pk, sig, h) = \text{valid}$
- **Context**: Tapscript only (leaf version 0xc0)
- **Sigops**: Counts against Tapscript sigops budget (BIP 342)

**Mathematical Properties**:

**Theorem 5.4.8.1** (CSFS Tapscript Restriction): CSFS is only available in Tapscript:

$$\forall msg, pk, sig \in \mathbb{S}, h \in \mathbb{N}: \text{BIP348Check}(msg, pk, sig, h) = \text{valid} \implies \text{SigVersion} = \text{Tapscript}$$

*Proof*: By construction, CSFS opcode handler checks that $\text{SigVersion} = \text{Tapscript}$ before processing. This ensures CSFS is only used in the Tapscript execution context, maintaining security boundaries.

**Theorem 5.4.8.2** (CSFS Zero Pubkey Rejection): Zero-length pubkeys always fail:

$$\forall msg, sig \in \mathbb{S}, h \in \mathbb{N}: |pk| = 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{invalid}$$

*Proof*: By construction, if $|pk| = 0$, the check immediately returns $\text{invalid}$ regardless of message or signature. This prevents degenerate cases and ensures proper key validation.

**Theorem 5.4.8.3** (CSFS Empty Signature Handling): Empty signatures push empty vector and continue:

$$\forall msg, pk \in \mathbb{S}, h \in \mathbb{N}: |sig| = 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{valid} \land \text{StackPush}(\emptyset)$$

*Proof*: By construction, if $|sig| = 0$, the check returns $\text{valid}$ and pushes an empty vector to the stack. This matches OP_CHECKSIG behavior and allows scripts to handle optional signatures.

**Theorem 5.4.8.4** (CSFS BIP 340 Verification): CSFS uses BIP 340 Schnorr signature verification:

$$\forall msg, pk, sig \in \mathbb{S}, h \in \mathbb{N}: \text{BIP348Check}(msg, pk, sig, h) = \text{valid} \land |pk| = 32 \land |sig| = 64 \implies \text{VerifySchnorr}(msg, pk, sig) = \text{true}$$

*Proof*: From the definition of $\text{BIP348Check}$, CSFS uses BIP 340 Schnorr signature verification for 32-byte pubkeys. The message is hashed with SHA256 before verification (BIP 340 accepts any size, but secp256k1 requires 32 bytes), per BIP 340 specification.

**Theorem 5.4.8.5** (CSFS Unknown Pubkey Type): Unknown pubkey types (non-32-byte) succeed:

$$\forall msg, sig \in \mathbb{S}, pk \in \mathbb{S}, h \in \mathbb{N}: |pk| \neq 32 \land |pk| > 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{valid}$$

*Proof*: By construction, if $|pk| \neq 32$ and $|pk| > 0$, the check returns $\text{valid}$ without verification. This allows future extensions while maintaining backward compatibility.

**Formula** (**F_CSFSZeroPubkeyInvalid**):
$$result == false$$

When the public key has zero length ($|pk| = 0$), CSFS always returns invalid. The zero-pubkey check fires before any signature check.

**Formula** (**F_CSFSUnknownPubkeyValid**):
$$result == true$$

When the public key has non-zero length but is not exactly 32 bytes ($|pk| > 0 \land |pk| \neq 32$), CSFS always returns valid (unknown pubkey type succeeds per BIP348 tapscript softfork upgrade rules).

**Formula** (**F_CSFSEmptySigValid**):
$$result == true$$

When the signature is empty ($|sig| = 0$) and the pubkey is non-zero ($|pk| > 0$), CSFS always returns valid and pushes an empty vector. This matches OP_CHECKSIG behavior for scripts with optional signatures.

**Use Cases**:

1. **UTXO Amount Introspection**: Verify signatures on UTXO amounts to enable CTV with amount verification
2. **Covenant Proofs**: Verify signatures on transaction data to prove covenant compliance
3. **Cross-Input Verification**: Verify signatures across different transaction inputs
4. **Arbitrary Message Signing**: Verify signatures on any data, not just transaction hashes

**Activation heights (Bitcoin chain consensus)**:

- **Mainnet**: Not consensus-active. BIP348 has **no** deployed soft fork on the canonical Bitcoin mainnet chain (through the documented chain tip); **OP_SUCCESS204** remains unconsumed for standard consensus on chain. This section specifies the rules **if and when** a deployment activates them; BLVM may implement them behind a feature flag for testing.
- **Public test networks** (default `testnet` / `testnet4` parameters): Same as mainnet under default parameters (no consensus activation unless a future network explicitly deploys BIP348).
- **Regtest**: Height **0** when the local node enables the proposal for development (implementation-defined feature gate).

**Implementation Notes**:

- CSFS is only available in Tapscript (leaf version 0xc0)
- Message is hashed with SHA256 before BIP 340 verification (BIP 340 accepts any size, but secp256k1 requires 32 bytes)
- Only 32-byte pubkeys are verified (BIP 340 x-only pubkeys)
- Empty signatures push empty vector and continue (matches OP_CHECKSIG behavior)
- Valid signatures push $[0x01]$ (single byte, not number 1)
- Invalid signatures cause script to fail
- Unknown pubkey types (non-32-byte) succeed without verification
- CSFS operations count against Tapscript sigops budget (BIP 342)

**Relationship to CTV**:

CSFS complements CTV by enabling UTXO amount introspection. CTV commits to transaction structure but cannot verify UTXO amounts. CSFS allows scripts to verify signatures on arbitrary data, including UTXO amounts, enabling complete covenant functionality.

---

**BIP65Check**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{N} \times \mathbb{H} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Defined: $\text{true}$
- Boolean result: $result \in \{\text{true}, \text{false}\}$
- Type consistency: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$ (types must match)
- Locktime ordering (BIP65): $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \geq lt$ (transaction locktime must be **≥** stack locktime; stack value greater than `tx.lockTime` fails)
- Zero locktime: $(tx.\text{lockTime}, lt) = (0, 0)$ with matching types **may** be valid (mainnet block 659901); BIP65 does **not** unconditionally reject `tx.lockTime = 0`

For transaction $tx$, input index $i$, locktime value $lt$, and block header $h$:

$$\text{BIP65Check}(tx, i, lt, h) = \begin{cases}
\text{invalid} & \text{if } \text{LocktimeType}(tx.\text{lockTime}) \neq \text{LocktimeType}(lt) \\
\text{invalid} & \text{if } tx.\text{lockTime} < lt \\
\text{valid} & \text{otherwise}
\end{cases}$$

Where $\text{LocktimeType}(x) = \begin{cases} \text{BlockHeight} & x < 5\times10^8 \\ \text{Timestamp} & \text{otherwise} \end{cases}$.

**OP_CHECKLOCKTIMEVERIFY (opcode 0xb1)**:
- **Stack Input**: $[lt]$ where $lt$ is a locktime value (encoded as minimal byte string)
- **Stack Output**: Nothing (opcode fails if locktime check doesn't pass)
- **Validation**: $\text{BIP65Check}(tx, i, \text{DecodeLocktime}(lt), h) = \text{valid}$

**Locktime Type Determination**: 

$$\text{LocktimeType}(lt) = \begin{cases}
\text{BlockHeight} & \text{if } lt < 500000000 \\
\text{Timestamp} & \text{otherwise}
\end{cases}$$

**Locktime Encoding/Decoding**: Locktime values are encoded as minimal little-endian byte strings (max 5 bytes) on the script stack.

**Theorem 5.4.7.1** (Locktime Encoding Round-Trip): Locktime encoding and decoding are inverse operations:

$$\forall lt \in \mathbb{N}_{32}: \text{DecodeLocktime}(\text{EncodeLocktime}(lt)) = lt$$

*Proof*: By construction, the encoding uses minimal little-endian representation and decoding reconstructs the value from the byte string. This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.2** (Locktime Type Determination Correctness): Locktime type determination is correct:

$$\forall lt \in \mathbb{N}_{32}: \text{LocktimeType}(lt) = \begin{cases}
\text{BlockHeight} & \text{if } lt < 500000000 \\
\text{Timestamp} & \text{otherwise}
\end{cases}$$

*Proof*: By construction, the threshold $500000000$ correctly separates block heights (which are always $< 500000000$) from Unix timestamps (which are always $\geq 500000000$). This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.3** (CLTV Type Matching Requirement): CLTV requires matching locktime types:

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: \text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$$

*Proof*: By construction, if the types don't match, $\text{BIP65Check}$ returns $\text{invalid}$. This ensures that block height locktimes are only compared with block heights, and timestamps are only compared with timestamps. This is proven by blvm-spec-lock formal verification.

**Theorem 5.4.7.4** (CLTV locktime ordering): Valid CLTV requires transaction locktime at least the stack value.

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: \text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \geq lt$$

*Proof*: Matches BIP65: the script fails when the stack locktime exceeds `tx.lockTime`.

---

**Corollary 5.4.1** (BIP Activation Consistency): All BIP validation rules are enforced consistently across the network after their respective activation heights, ensuring consensus compatibility.

*Proof*: Each BIP validation rule $P$ has an activation height $H_P$ such that for all blocks $b$ at height $h \geq H_P$, $P(b) = \text{valid}$ is required. Since all nodes enforce the same activation heights, consensus is maintained.

---

#### 5.4.9 BIP54: Consensus Cleanup

BIP54 bundles several consensus fixes (timewarp mitigation, per-tx sigop limit, 64-byte tx invalidity, coinbase nLockTime/nSequence). All are gated by a single activation height $H_{54}$.

**BIP54TimewarpCheck**: $\mathcal{H} \times \mathbb{N} \times \mathbb{N} \times \mathbb{N} \times \text{Network} \rightarrow \{\text{valid}, \text{invalid}\}$

At difficulty period boundaries, block timestamps are constrained to prevent timewarp attacks:
- Last block of period ($height \bmod 2016 = 2015$): $T_N \geq T_{N-2015}$ (current block timestamp must be $\geq$ first block of period).
- First block of period ($height \bmod 2016 = 0$): $T_N \geq T_{N-1} - 7200$ (2-hour grace).

Where $T_N$ is the block header timestamp at height $N$; $T_{N-1}$, $T_{N-2015}$ are timestamps of the previous block and the first block of the previous period. If BIP54 is active and $height \bmod 2016 \in \{0, 2015\}$, the caller must supply boundary timestamps and the check is applied; otherwise the check is skipped.

**BIP54CoinbaseCheck**: $\mathcal{TX} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

After BIP54 activation, the coinbase transaction must have $\text{lockTime} = height - 13$ and the first input's $\text{sequence} \neq 0xffffffff$.

**BIP54 64-byte tx**: Any non-coinbase transaction whose witness-stripped serialized size equals 64 bytes is invalid (Merkle tree ambiguity).

**BIP54 per-tx sigop limit**: For each non-coinbase transaction, total sigop count (legacy + P2SH + witness, with accurate legacy counting for OP_CHECKMULTISIG) must be $\leq 2500$.

**Activation**: Network-specific (e.g. regtest: 0; mainnet/testnet: configurable or $u64::\text{MAX}$ until set).

**References**: [BIP 54](https://bips.dev/54/), Bitcoin Inquisition PR #99.

**Bip9Deployment for BIP54**: all networks use the same signaling parameters:
- Signal bit: 15 (out of the 29 available BIP9 version bits)
- Start time: 0 (immediate; no time-gated start window)
- Timeout: $2^{64} - 1$ (never expires; always candidate)

**Formula** (**F_Bip54SignalBit**):
$$result == 15$$

The BIP54 version-bits deployment always uses signal bit 15, universally across mainnet, testnet, and regtest. This is a spec constant.

**Formula** (**F_Bip54StartTimeZero**):
$$result == 0$$

The BIP54 deployment start time is 0 (UNIX epoch), meaning signaling is valid from any timestamp.

The BIP54 deployment timeout is $2^{64}-1$ (never expires). This value exceeds the Z3 translator's literal range and is stated in prose rather than as a formula.

**Formula** (**F_BIP54ActivationThreshold**):
$$result == \text{true}$$

Under precondition $height \geq threshold$: `IsBip54ActiveAt` returns `true`. Proven in `spec_witnesses` with `#[requires(height >= threshold)]` and `#[ensures(result == true)]`.

**IsBip54ActiveAt**: $\mathbb{N} \times \text{Network} \times \mathbb{N}^? \rightarrow \{\text{true}, \text{false}\}$

Returns `true` iff block at `height` is at or past the BIP54 activation threshold, taking an optional caller-supplied override (e.g. from version-bits signalling) over the per-network constant.

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Monotone: $h_1 \leq h_2 \implies \text{IsBip54ActiveAt}(h_1, n, ovr) = \text{true} \implies \text{IsBip54ActiveAt}(h_2, n, ovr) = \text{true}$. Activation at threshold with override: $\text{IsBip54ActiveAt}(height, n, \text{Some}(a)) = \text{true} \iff height \geq a$.

**IsBip54Active**: $\mathbb{N} \times \text{Network} \rightarrow \{\text{true}, \text{false}\}$

Convenience wrapper over `IsBip54ActiveAt` with no override (uses per-network constant).

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Equivalent to $\text{IsBip54ActiveAt}(height, n, \text{None})$; the override parameter defaults to `None`.

**CheckBip54Coinbase**: $\mathcal{TX} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

After BIP54 activation, the coinbase transaction must satisfy both the nLockTime and nSequence constraints.

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: LockTime necessary: $result = \text{true} \implies coinbase.\text{lockTime} = height - 13$. Sequence necessary: $result = \text{true} \implies coinbase.\text{inputs}[0].\text{sequence} \neq 0\text{xffffffff}$. Non-empty inputs: $result = \text{true} \implies |coinbase.\text{inputs}| > 0$.

---

### 5.5 Sequence Locks (BIP68)

Sequence locks enforce relative locktime constraints using transaction input sequence numbers. Unlike absolute locktime (nLockTime), sequence locks are relative to when the input was confirmed.

**Sequence Number Encoding**: $nSequence \in \mathbb{N}_{32}$ (32-bit unsigned integer)

The sequence number encodes:
- **Bit 31** (0x80000000): Disable flag - if set, sequence is not treated as relative locktime
- **Bit 22** (0x00400000): Type flag - if set, locktime is time-based; otherwise block-based
- **Bits 0-15** (0x0000ffff): Locktime value

**ExtractSequenceLocktimeValue**: $\mathbb{N}_{32} \rightarrow \mathbb{N}_{16}$

**Properties**:
- Mask result: $\text{result} = (seq \land \text{0x0000FFFF})$
- Value extraction: $result = seq \land 0x0000ffff$ (bits 0-15)
- Value range: $0 \leq \text{ExtractSequenceLocktimeValue}(seq) \leq 65535$ for all $seq \in \mathbb{N}_{32}$
- Bit masking: $result$ extracts lower 16 bits

$$\text{ExtractSequenceLocktimeValue}(seq) = seq \land 0x0000ffff$$

**ExtractSequenceTypeFlag**: $\mathbb{N}_{32} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Bitflag check: $\text{result} = ((seq \land \text{0x00400000}) \neq 0)$
- Type flag extraction: $result = \text{true} \iff (seq \land 0x00400000) \neq 0$
- Bit 22: $result$ extracts bit 22 (type flag)

$$\text{ExtractSequenceTypeFlag}(seq) = (seq \land 0x00400000) \neq 0$$

**IsSequenceDisabled**: $\mathbb{N}_{32} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Bitflag check: $\text{result} = ((seq \land \text{0x80000000}) \neq 0)$
- Disabled flag extraction: $result = \text{true} \iff (seq \land 0x80000000) \neq 0$
- Bit 31: $result$ extracts bit 31 (disable flag)

$$\text{IsSequenceDisabled}(seq) = (seq \land 0x80000000) \neq 0$$

**Formula** (**F_SequenceLockTimeMask**):
$$result <= 65535$$

Extraction is bounded to the lower 16 bits: $0 \leq \text{result} \leq 65535$ for all $seq \in \mathbb{N}_{32}$. The exact definition is $\text{result} = seq \mathbin{\&} \text{0x0000FFFF}$.

**Formula** (**F_SequenceTypeTimeWhenBit22Set**):
$$result == true$$

When bit 22 of the sequence number is set ($(seq \mathbin{\&} \text{0x00400000}) \neq 0$), ExtractSequenceTypeFlag returns true (time-based relative locktime). The body evaluates to the same bitwise expression, which is nonzero under the precondition.

**Formula** (**F_SequenceTypeHeightWhenBit22Clear**):
$$result == false$$

When bit 22 of the sequence number is clear ($(seq \mathbin{\&} \text{0x00400000}) = 0$), ExtractSequenceTypeFlag returns false (block-height relative locktime). The body evaluates to the same bitwise expression, which is zero under the precondition.

**Formula** (**F_SequenceDisabledWhenBit31Set**):
$$result == true$$

When bit 31 of the sequence number is set ($(seq \mathbin{\&} \text{0x80000000}) \neq 0$), IsSequenceDisabled returns true (relative locktime disabled). The body evaluates to the same bitwise expression, which is nonzero under the precondition.

**Formula** (**F_SequenceEnabledWhenBit31Clear**):
$$result == false$$

When bit 31 of the sequence number is clear ($(seq \mathbin{\&} \text{0x80000000}) = 0$), IsSequenceDisabled returns false (relative locktime enabled). The body evaluates to the same bitwise expression, which is zero under the precondition.

**Formula** (**F_EvalSeqLocksDisabled**):
$$result == true$$

When both minimum height and minimum time are $-1$ (no constraints active), EvaluateSequenceLocks always returns true. This is the base case: $-1 < 0$ satisfies both guard conditions trivially.

**Formula** (**F_EvalSeqLocksHeightNotMet**):
$$result = 0$$

When a minimum block height constraint is active ($\text{min\_height} \geq 0$) and the current block height does not exceed it ($\text{block\_height} \leq \text{min\_height}$), EvaluateSequenceLocks returns false (locks not satisfied). The height guard `block_height > min_height` is false, short-circuiting the conjunction to false.

**Formula** (**F_EvalSeqLocksHeightMet**):
$$result == true$$

When a minimum block height constraint is active ($\text{min\_height} \geq 0$) and the block height strictly exceeds it ($\text{block\_height} > \text{min\_height}$), and there is no time constraint ($\text{min\_time} < 0$), EvaluateSequenceLocks returns true (height locks satisfied).

**Formula** (**F_EvalSeqLocksTimeNotMet**):
$$result = 0$$

When a minimum timestamp constraint is active ($\text{min\_time} \geq 0$) and the current block time does not exceed it ($\text{time} \leq \text{min\_time}$), EvaluateSequenceLocks returns false (time locks not satisfied). The time guard `time > min_time` is false, short-circuiting the conjunction to false. Symmetric to F_EvalSeqLocksHeightNotMet.

**Formula** (**F_EvalSeqLocksTimeMet**):
$$result == true$$

When a minimum timestamp constraint is active ($\text{min\_time} \geq 0$) and the block time strictly exceeds it ($\text{time} > \text{min\_time}$), and there is no height constraint ($\text{min\_height} < 0$), EvaluateSequenceLocks returns true (time locks satisfied). Symmetric to F_EvalSeqLocksHeightMet.

**Formula** (**F_EvalSeqLocksBothMet**):
$$result == true$$

When both a height constraint and a timestamp constraint are active and both are satisfied ($\text{block\_height} > \text{min\_height}$ and $\text{time} > \text{min\_time}$), EvaluateSequenceLocks returns true. Both guard clauses evaluate to true, so their conjunction holds.

**Formula** (**F_SequenceTimeEncoding**):
$$result \leq 33553920$$

The time-based sequence locktime value (in seconds) is bounded by $65535 \times 512 = 33{,}553{,}920$ seconds. Under $value \leq 65535$ (from the 16-bit mask), $result = value \times 512 \leq 33{,}553{,}920$.

**GetMedianTimePast**: $[\mathcal{H}] \rightarrow \mathbb{N}$

**Properties**:
- Defined: $\text{true}$
- Codomain: $result \geq 0$

For block headers $headers \in [\mathcal{H}]$:

$$\text{GetMedianTimePast}(headers) = \begin{cases}
0 & \text{if } |headers| = 0 \\
\text{median}(\{h.\text{timestamp} : h \in headers[\max(0, |headers| - 11):]\}) & \text{otherwise}
\end{cases}$$

Where $\text{median}(timestamps)$ is calculated as:
- If $|timestamps|$ is odd: $\text{median}(timestamps) = timestamps[\lfloor |timestamps|/2 \rfloor]$
- If $|timestamps|$ is even: $\text{median}(timestamps) = \lfloor (timestamps[|timestamps|/2 - 1] + timestamps[|timestamps|/2]) / 2 \rfloor$

**BIP113 Reference**: This function implements [BIP113: Median Time-Past](https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki), which uses the median timestamp of the last 11 blocks to prevent time-warp attacks.

**CalculateSequenceLocks**: $\mathcal{TX} \times \mathbb{N} \times [\mathbb{N}] \times [\mathcal{H}]^? \rightarrow (\mathbb{Z}, \mathbb{Z})$

**Properties**:
- Heights match inputs: $result = (min\_h, min\_t) \implies |ph| = |tx.inputs|$ (heights must match input count)
- Lock calculation: $result$ calculates minimum height and time locks from sequence numbers
- Negative locks: $result = (min\_h, min\_t) \implies min\_h \geq -1 \land min\_t \geq -1$ (locks can be -1 if disabled)

For transaction $tx$, flags $f$, previous heights $ph \in [\mathbb{N}]$, and recent headers $rh \in [\mathcal{H}]^?$:

$$\text{CalculateSequenceLocks}(tx, f, ph, rh) = (\text{min\_height}, \text{min\_time})$$

Where:
- BIP68 is only enforced if $tx.\text{version} \geq 2$ and $(f \land 0x01) \neq 0$
- For each input $i \in tx.\text{inputs}$:
  - If $result$: skip input
  - If $result$ (time-based):
    - $locktime\_value = \text{ExtractSequenceLocktimeValue}(i.\text{sequence})$
    - $locktime\_seconds = locktime\_value \times 512 = locktime\_value \ll 9$ (bit shift for efficiency)
    - $coin\_time = \text{GetMedianTimePast}(ph[i], rh)$
    - $required\_time = coin\_time + locktime\_seconds - 1$
    - $\text{min\_time} = \max(\text{min\_time}, required\_time)$
  - Else (block-based):
    - $locktime\_value = \text{ExtractSequenceLocktimeValue}(i.\text{sequence})$
    - $required\_height = ph[i] + locktime\_value - 1$
    - $\text{min\_height} = \max(\text{min\_height}, required\_height)$

**EvaluateSequenceLocks**: $\mathbb{N} \times \mathbb{N} \times (\mathbb{Z}, \mathbb{Z}) \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Lock evaluation: $result = \text{true} \iff (min\_h < 0 \lor height > min\_h) \land (min\_t < 0 \lor time > min\_t)$
- Disabled locks: $result = \text{true}$ when both $min\_h < 0$ and $min\_t < 0$ (disabled locks always pass)

$$\text{EvaluateSequenceLocks}(height, time, (min\_h, min\_t)) = \begin{cases}
\text{true} & \text{if } (min\_h < 0 \lor height > min\_h) \land (min\_t < 0 \lor time > min\_t) \\
\text{false} & \text{otherwise}
\end{cases}$$

Where:
- $min\_h < 0$ (typically $-1$) indicates no height constraint
- $min\_t < 0$ indicates no time constraint
- The comparison uses $>$ (strictly greater) because sequence locks use "last invalid" semantics (like nLockTime)

**Theorem 5.5.1** (Sequence Lock Arithmetic Safety): Sequence lock calculations never overflow for valid inputs:

$$\forall tx \in \mathcal{TX}, ph \in [\mathbb{N}], seq \in \mathbb{N}_{32}:$$
$$\text{CalculateSequenceLocks}(tx, f, ph, rh) \text{ does not overflow}$$

*Proof*: By construction, all arithmetic operations use checked addition/subtraction. The locktime value is bounded to 16 bits (0-65535), and block heights/times are bounded to 64-bit integers. This is proven by blvm-spec-lock formal verification.

**Theorem 5.5.2** (Sequence Lock Correctness): Sequence locks correctly enforce relative locktime:

$$\forall tx \in \mathcal{TX}, ph \in [\mathbb{N}]:$$
$$\text{EvaluateSequenceLocks}(h, t, \text{CalculateSequenceLocks}(tx, f, ph, rh)) = \text{true}$$
$$\iff$$
$$\forall i \in tx.\text{inputs}: \text{IsSequenceDisabled}(i.\text{sequence}) \lor \text{LocktimeSatisfied}(i, ph[i], h, t)$$

Where $\text{LocktimeSatisfied}$ checks if the relative locktime constraint is met.

*Proof*: By construction, $\text{CalculateSequenceLocks}$ computes the minimum height/time required by all inputs, and $\text{EvaluateSequenceLocks}$ checks if current height/time meets these requirements. This is proven by blvm-spec-lock formal verification.

## 6. Economic Model

### 6.1 Block Subsidy

**GetBlockSubsidy**: $\mathbb{N} \rightarrow \mathbb{Z}$

**Properties**:
- Defined: $\text{true}$

$$\text{GetBlockSubsidy}(h) = \begin{cases}
0 & \text{if } h \geq 64 \times H \\
50 \times C \times 2^{-\lfloor h/H \rfloor} & \text{otherwise}
\end{cases}$$

Where $\lfloor h/H \rfloor$ represents the number of halvings that have occurred by height $h$.

```mermaid
xychart-beta
    title "Block Subsidy Schedule (First 4 Halvings)"
    x-axis [0, 210000, 420000, 630000, 840000]
    y-axis "Subsidy (BTC)" 0 --> 50
    bar [50, 25, 12.5, 6.25, 3.125]
```

**Halving Schedule**:
- **Blocks 0-209,999**: 50 BTC per block
- **Blocks 210,000-419,999**: 25 BTC per block  
- **Blocks 420,000-629,999**: 12.5 BTC per block
- **Blocks 630,000-839,999**: 6.25 BTC per block
- **Blocks 840,000+**: 3.125 BTC per block
- **Blocks 13,440,000+**: 0 BTC per block (after 64 halvings)

**Properties**:
- Upper bound: $result \leq 50 \times C$ for all $h \in \mathbb{N}$
- Genesis block: $result = 50 \times C$
- After 64 halvings: $result = 0$ for all $h \geq 64 \times H$
- First halving: $result = 25 \times C$
- Second halving: $result = 12.5 \times C$
- Integer exhaustion: $result = 0$ for $h \geq 33 \times H$ (integer rounding exhausts INITIAL\_SUBSIDY by halving 33; the 64-halving guard is a belt-and-suspenders check)

**Theorem 6.1.1** (Halving Schedule Correctness): The block subsidy halves every 210,000 blocks:

$$\forall h \in \mathbb{N}, h < 64 \times H: \text{GetBlockSubsidy}(h + H) = \frac{\text{GetBlockSubsidy}(h)}{2}$$

Where $H = 210,000$ is the halving interval.

*Proof*: By construction, $\text{GetBlockSubsidy}(h) = 50 \times C \times 2^{-\lfloor h/H \rfloor}$. For $h + H$, we have $\lfloor (h+H)/H \rfloor = \lfloor h/H \rfloor + 1$, so $\text{GetBlockSubsidy}(h + H) = 50 \times C \times 2^{-(\lfloor h/H \rfloor + 1)} = \frac{50 \times C \times 2^{-\lfloor h/H \rfloor}}{2} = \frac{\text{GetBlockSubsidy}(h)}{2}$. This is proven by blvm-spec-lock formal verification.

**Formula** (**F_SubsidyZeroAfter64**):

$$\text{result} = 0$$

Post-condition holds under `requires(height >= HALVING_INTERVAL * 64)` (see witness
`_verify_f_subsidy_zero_after_64` in `blvm-consensus/src/spec_witnesses.rs`). The body
uses only integer division and comparison — no shifts — so Z3 proves this without
translator extensions. Full claim: ∀ h ≥ HALVING_INTERVAL × 64, GetBlockSubsidy(h) = 0.

**Formula** (**F_SubsidyPiecewise**):

$$result \geq 0 \land result \leq INITIAL\_SUBSIDY$$

Bound claim verified by witness `_verify_f_subsidy_piecewise` using a 64-arm `match`
body where every shift RHS is a literal (Z3 translates `INITIAL_SUBSIDY >> k` as
integer division by a power of two for each literal k).
Full piecewise formula: result = INITIAL_SUBSIDY >> floor(h / HALVING_INTERVAL) for k < 64, else 0.

### 6.2 Total Supply

**TotalSupply**: $\mathbb{N} \rightarrow \mathbb{Z}$

**Properties**:
- Defined: $\text{true}$

**Note**: At genesis ($h = 0$), $\text{TotalSupply}(0) = \text{GetBlockSubsidy}(0) = 50 \times C = \text{INITIAL\_SUBSIDY}$.
- Supply limit: $result \leq \text{MAX\_MONEY}$ (critical security invariant; all block subsidies sum to less than 21M BTC)
- Monotonicity: $\text{TotalSupply}(h_1) \leq \text{TotalSupply}(h_2)$ for all $h_1 \leq h_2$ (monotonically increasing)
- Supply convergence: $\lim_{h \to \infty} \text{TotalSupply}(h) = 21 \times 10^6 \times C$ (converges to 21M BTC)
- After 64 halvings: $\text{TotalSupply}(h)$ is constant for $h \geq \text{HALVING\_INTERVAL} \times 64$

**Formula** (**F_TotalSupplyNonNeg**):

$$result \geq 0$$

Non-negativity invariant: the total supply is always non-negative. Verified for the accumulation loop body by `_verify_f_total_supply_non_neg` in `blvm-consensus/src/spec_witnesses.rs`.

**Formula** (**F_TotalSupplyBound**):

$$result \leq \text{MAX\_MONEY}$$

Supply cap invariant: the total supply never exceeds the 21M BTC hard cap. Verified by `_verify_f_total_supply_bound` in `blvm-consensus/src/spec_witnesses.rs`.

$$\text{TotalSupply}(h) = \sum_{i=0}^{h} \text{GetBlockSubsidy}(i)$$

**Theorem 6.2.1** (Total Supply Monotonicity): Total supply is monotonically increasing:

$$\forall h_1, h_2 \in \mathbb{N}, h_1 \leq h_2: \text{TotalSupply}(h_1) \leq \text{TotalSupply}(h_2)$$

*Proof*: By construction, $\text{TotalSupply}(h) = \sum_{i=0}^{h} \text{GetBlockSubsidy}(i)$. Since $\text{GetBlockSubsidy}(i) \geq 0$ for all $i$, adding more terms can only increase the sum. This is proven by blvm-spec-lock formal verification.

**Theorem 6.2.2** (Total Supply Bounded): Total supply never exceeds MAX_MONEY:

$$\forall h \in \mathbb{N}: \text{TotalSupply}(h) \leq \text{MAX\_MONEY}$$

Where $\text{MAX\_MONEY} = 21 \times 10^6 \times C$ is the maximum Bitcoin supply.

*Proof*: By construction, the total supply converges to $21 \times 10^6 \times C$ as $h \to \infty$, and all block subsidies are non-negative. The implementation uses checked arithmetic to prevent overflow. This is proven by blvm-spec-lock formal verification.

**Theorem 6.2.3** (Supply Convergence): $\lim_{h \to \infty} \text{TotalSupply}(h) = 21 \times 10^6 \times C$

*Proof*: The total supply can be expressed as a sum of geometric series. For each halving period $k$ (where $k = \lfloor h/H \rfloor$), the subsidy is $50 \times C \times 2^{-k}$ for $H$ consecutive blocks.

The total supply is:
$$\text{TotalSupply}(\infty) = \sum_{k=0}^{63} H \times 50 \times C \times 2^{-k} = H \times 50 \times C \times \sum_{k=0}^{63} 2^{-k}$$

Since $\sum_{k=0}^{63} 2^{-k} = 2 - 2^{-63} \approx 2$ for large $k$:
$$\text{TotalSupply}(\infty) \approx H \times 50 \times C \times 2 = 210,000 \times 50 \times 10^8 \times 2 = 21 \times 10^6 \times 10^8 = 21 \times 10^6 \times C$$

### 6.3 Supply Limit Validation

**ValidateSupplyLimit**: $\mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

$$\text{ValidateSupplyLimit}(h) = \begin{cases}
\text{valid} & \text{if } \text{TotalSupply}(h) \leq \text{MAX\_MONEY} \\
\text{invalid} & \text{otherwise}
\end{cases}$$

Validates that the total supply at height $h$ does not exceed the maximum money supply.

**Properties**:
- Supply bound: $\text{result} = (\text{TotalSupply}(h) \leq \text{MAX\_MONEY})$
- Validation correctness: $result = \text{valid} \iff \text{TotalSupply}(h) \leq \text{MAX\_MONEY}$
- Supply limit invariant: $result = \text{valid}$ for all $h \in \mathbb{N}$ (critical security property)
- Boolean result: $result \in \{\text{valid}, \text{invalid}\}$
- Always valid: Since $result \leq \text{MAX\_MONEY}$ for all $h$, $\text{ValidateSupplyLimit}(h) = \text{valid}$ for all $h$

**Theorem 6.3.1** (Supply Limit Correctness): The supply limit validation is correct:

$$\forall h \in \mathbb{N}: \text{ValidateSupplyLimit}(h) = \text{valid} \iff \text{TotalSupply}(h) \leq \text{MAX\_MONEY}$$

*Proof*: By construction, the validation function directly checks the condition. This is proven by blvm-spec-lock formal verification.

### 6.4 Coinbase Detection

**IsCoinbase**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

A transaction $tx = (v, ins, outs, lt)$ is a coinbase transaction if and only if:

$$\text{IsCoinbase}(tx) = \begin{cases}
\text{true} & \text{if } |ins| = 1 \land ins[0].\text{prevout}.\text{hash} = 0^{32} \land ins[0].\text{prevout}.\text{index} = 2^{32} - 1 \\
\text{false} & \text{otherwise}
\end{cases}$$

Where:
- $0^{32}$ is the 32-byte zero hash (all zeros)
- $2^{32} - 1$ is the maximum 32-bit unsigned integer (0xFFFFFFFF)

**Properties**:
- Input count: $result = \text{true} \implies |tx.\text{inputs}| = 1$
- Max index: $result = \text{true} \implies tx.\text{inputs}[0].\text{prevout}.\text{index} = 2^{32} - 1$ ($\text{0xFFFFFFFF}$)
- Zero hash: $result = \text{true} \implies tx.\text{inputs}[0].\text{prevout}.\text{hash} = 0^{32}$ (null hash)
- Definition correctness: $result = \text{true} \iff |tx.\text{inputs}| = 1 \land tx.\text{inputs}[0].\text{prevout}.\text{hash} = 0^{32} \land tx.\text{inputs}[0].\text{prevout}.\text{index} = 2^{32} - 1$
- Coinbase uniqueness: In any valid block $b$, exactly one transaction satisfies $\text{IsCoinbase}(tx) = \text{true}$ (Theorem 6.4.1)
**Note**: The coinbase transaction is always the first transaction in a valid block (enforced by `ConnectBlock`).
- ScriptSig length: $result = \text{true} \land \text{CheckTransaction}(tx) = \text{valid} \implies 2 \leq |tx.\text{inputs}[0].\text{scriptSig}| \leq 100$

**Theorem 6.4.1** (Coinbase Uniqueness): Each block contains exactly one coinbase transaction:

$$\forall b = (h, txs) \in \mathcal{B}: \sum_{tx \in txs} \text{IsCoinbase}(tx) = 1$$

*Proof*: By Bitcoin consensus rules, each block must have exactly one coinbase transaction as its first transaction. This is proven by blvm-spec-lock formal verification.

### 6.5 Fee Market

**CalculateFee**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{Z}$

The fee is the difference between total input value and total output value. Coinbase transactions have fee zero by definition.

**Properties**:
- Fee formula: $result = \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Coinbase fee: $\text{IsCoinbase}(tx) \implies result = 0$
- Non-negative fee: $result \geq 0$ for valid transactions (inputs ≥ outputs)

**Formula** (**F_FeeNonNeg**):

$$result \geq 0$$

Non-negativity of transaction fees for valid transactions: total input value must be at least total output value, so the fee difference is always non-negative.

$$\text{Fee}(tx, us) = \sum_{i \in tx.inputs} us(i.prevout).value - \sum_{o \in tx.outputs} o.value$$

**Fee Rate**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{Q}$

**Properties**:
- Fee rate formula: $\text{result} = \frac{\text{Fee}(tx, us)}{\text{Weight}(tx)}$
- Non-negative rate: $\text{result} \geq 0$ for valid transactions
- Zero fee rate: $result = \text{true} \implies \text{result} = 0$

$$\text{FeeRate}(tx, us) = \frac{\text{Fee}(tx, us)}{\text{Weight}(tx)}$$

**Theorem 6.3.1** (Fee Non-Negativity): Transaction fees are always non-negative for valid transactions:

$$\forall tx \in \mathcal{TX}, us \in \mathcal{US}: \text{Fee}(tx, us) \geq 0$$

*Proof*: By construction, $\text{Fee}(tx, us) = \sum_{i \in tx.inputs} us(i.prevout).value - \sum_{o \in tx.outputs} o.value$. For a valid transaction, the sum of input values must be at least the sum of output values (otherwise the transaction would be invalid). This is proven by blvm-spec-lock formal verification.

```mermaid
flowchart TD
    A[Transaction Inputs] --> B[Sum Input Values]
    C[Transaction Outputs] --> D[Sum Output Values]
    
    B --> E[Total Input Value]
    D --> F[Total Output Value]
    
    E --> G[Calculate Fee]
    F --> G
    
    G --> H{Fee ≥ 0?}
    H -->|No| I[❌ Invalid: Negative Fee]
    H -->|Yes| J[Calculate Weight]
    
    J --> K[Calculate Fee Rate]
    G --> K
    
    K --> L[Fee Rate = Fee / Weight]
    L --> M[✅ Valid Fee]
    
    style A fill:#e1f5fe
    style C fill:#e1f5fe
    style M fill:#c8e6c9
    style I fill:#ffcdd2
```

## 7. Proof of Work

### 7.1 Difficulty Adjustment

**ExpandTarget**: $\mathbb{N} \rightarrow \mathbb{U256}$

**Properties**:
- Positive bits: $bits > 0$ is required (bits must be positive)
- Target expansion: $result$ expands compact difficulty representation to full 256-bit target
- Formula correctness: $result = \text{mantissa} \times 2^{8 \times (\text{exponent} - 3)}$ where exponent and mantissa extracted from bits
- Valid exponent domain: $result$ is defined only when $3 \leq \text{exponent} \leq 32$

$$\text{ExpandTarget}(bits) = \text{mantissa} \times 2^{8 \times (\text{exponent} - 3)}$$

**Formula** (**F_ExpandTargetDomain**):

$$\text{requires}(bits > 0)$$

Precondition: compact difficulty bits must be non-zero for a valid target expansion. Enforced by the implementation returning an error on zero or out-of-range exponent. Verified by blvm-spec-lock formal verification.

Where:
- $\text{exponent} = (bits \gg 24) \land 0xff$
- $\text{mantissa} = bits \land 0x007fffff$ (23-bit mantissa; bit `0x00800000` of the compact word lies outside this field)

- **Domain (compact exponent):** Let $e = \text{exponent}$ and $m = \text{mantissa}$. $\text{ExpandTarget}(bits)$ is defined only when $e \in \{3,4,\ldots,32\}$; for $e \notin \{3,\ldots,32\}$, the compact encoding is outside the PoW-valid domain (consensus rejects such headers). For $e \in \{3,\ldots,32\}$ and $m = 0$, $\text{ExpandTarget}(bits) = 0 \in \mathbb{U}_{256}$.

*Proof*: This function converts the compact difficulty representation (used in block headers) to a full 256-bit target value. The encoding is one exponent byte ($e$) together with a 32-bit compact word whose low 23 bits are $m$; bit `0x00800000` of that word is not part of $m$. This is proven by blvm-spec-lock formal verification.

**Formula** (**F_ExpandTargetZeroMantissa**):
$$result = 0$$

When the 23-bit mantissa of the compact bits word is zero ($bits \mathbin{\&} \text{0x007FFFFF} = 0$), the expanded target is zero.

**Formula** (**F_ExpandTargetNonZeroMantissa**):
$$result \neq 0$$

When the 23-bit mantissa of the compact bits word is non-zero ($bits \mathbin{\&} \text{0x007FFFFF} \neq 0$), the expanded target is non-zero. Complements F_ExpandTargetZeroMantissa: together they establish the exact biconditional between mantissa and target being zero.

**Formula** (**F_ExpandTargetExponent**):
$$result \leq 255$$

The exponent byte extracted from compact bits ($\text{exponent} = (bits \gg 24) \mathbin{\&} \text{0xFF}$) is always in the range $[0, 255]$. The bitwise AND with $\text{0xFF}$ masks to exactly 8 bits, bounding the result to at most 255.

**GetNextWorkRequired**: $\mathcal{H} \times \mathcal{H}^* \times \text{Network} \rightarrow \mathbb{N}$

**Properties**:
- Defined: $\text{true}$

Let $prev_{\text{last}}$ denote the last block of the difficulty period and $prev_{\text{first}}$ the first. Let $T_{\text{expected}} = 14 \times 24 \times 60 \times 60$ (2 weeks in seconds). The timespan and bits base use only the completed period; the new block $h$ does not affect the result (timewarp safety).

$$\text{timeSpan} = \text{ClampTime}(prev_{\text{last}}.\text{time} - prev_{\text{first}}.\text{time}), \quad \text{ClampTime}(t) := \max(T_{\text{expected}}/4, \min(4 T_{\text{expected}}, t))$$

Let $\text{bitsBase}(prev, n) := prev_{\text{first}}.\text{bits}$ if $\text{EnforceBIP94}(n)$, else $prev_{\text{last}}.\text{bits}$.

Let $b = \text{bitsBase}(prev, n)$, $T = \text{ExpandTarget}(b)$, and $\tau = \text{timeSpan}$. Let $\pi : \mathbb{U}_{256} \to \mathbb{N}$ embed targets as unsigned integers. Define the **partial** product $T \otimes \tau \in \mathbb{U}_{256}$ to exist iff $\pi(T) \cdot \tau < 2^{256}$, in which case $T \otimes \tau$ is the unique element of $\mathbb{U}_{256}$ with $\pi(T \otimes \tau) = \pi(T) \cdot \tau$; otherwise $T \otimes \tau$ is undefined.

Let $T_{\mathrm{adj}} := \left\lfloor \pi(T \otimes \tau) / T_{\text{expected}} \right\rfloor$ when $T \otimes \tau$ is defined. Let $c := \text{Compress}(T_{\mathrm{adj}})$ be the compact $n$Bits encoding of the full 256-bit target $T_{\mathrm{adj}}$, using the usual compact encoding (including mantissa normalization: while the provisional significand has bit `0x00800000` set, shift it right by one byte and increase the exponent size field accordingly until it fits the 23-bit mantissa). Let $\text{MAX\_TARGET} \in \mathbb{N}$ denote the compact encoding of the network’s maximum target (minimum difficulty ceiling).

$$\text{GetNextWorkRequired}(h, prev, n) = \begin{cases}
\text{initialDifficulty} & \text{if } |prev| < 2 \\
b & \text{if } |prev| \ge 2 \text{ and } T \otimes \tau \text{ is undefined} \\
\min_{\mathbb{N}}(c,\, \text{MAX\_TARGET}) & \text{if } |prev| \ge 2 \text{ and } T \otimes \tau \text{ is defined}
\end{cases}$$

where $\min_{\mathbb{N}}$ is the usual total order on $\mathbb{N}$, applied to the two compact encodings as unsigned integers.

**BIP94 Timestamp Rule** (when $\text{EnforceBIP94}(n)$): For the first block of a new difficulty period, $\text{block}.\text{time} \geq \text{prev}.\text{time} - 600$ (MAX_TIMEWARP). Violation yields invalid block.

```mermaid
flowchart TD
    A[New Block Header] --> B{Enough Blocks?}
    B -->|No| C[Return Initial Difficulty]
    B -->|Yes| D[Calculate Time Span]
    
    D --> E[Time Span = Current - Previous]
    E --> F[Expected Time = 2 weeks]
    F --> G[Calculate Adjustment]
    
    G --> H[Adjustment = Time Span / Expected]
    H --> I{Adjustment Bounds Check}
    
    I -->|Too Low| J[Clamp to 1/4]
    I -->|Too High| K[Clamp to 4x]
    I -->|Valid| L[Use Calculated Adjustment]
    
    J --> M[Calculate New Target]
    K --> M
    L --> M
    
    M --> N[New Target = Old × Adjustment]
    N --> O{Target > Max?}
    O -->|Yes| P[Clamp to Max Target]
    O -->|No| Q[Use Calculated Target]
    
    P --> R[✅ Return New Difficulty]
    Q --> R
    
    style A fill:#e1f5fe
    style R fill:#c8e6c9
    style C fill:#fff3e0
```

**Theorem 7.1** (Difficulty Adjustment Bounds): The difficulty adjustment is bounded by a factor of 4 in either direction.

*Proof*: Write $\tau_{\mathrm{raw}} = prev_{\text{last}}.\text{time} - prev_{\text{first}}.\text{time}$ and $\tau = \text{ClampTime}(\tau_{\mathrm{raw}})$. By definition of $\text{ClampTime}$, $\tau \in [T_{\text{expected}}/4,\, 4\,T_{\text{expected}}]$. The adjustment ratio $\tau / T_{\text{expected}}$ therefore lies in $[\frac{1}{4},\,4]$, which bounds multiplicative difficulty change across a retarget period.

**Corollary 7.1**: The difficulty can change by at most a factor of 4 between any two difficulty adjustment periods.

**Theorem 7.1.1** (Target expansion on valid compact domain): Let $bits \in \mathbb{N}$, $e = (bits \gg 24) \land 0xff$, $m = bits \land 0x007fffff$. If $3 \le e \le 32$, then $\text{ExpandTarget}(bits)$ is defined and coincides with the mantissa–exponent rule displayed above; in particular, for $e > 3$ and $m > 0$, $\pi(\text{ExpandTarget}(bits)) = m \cdot 2^{8(e-3)}$ as integers, and the left shift introduces no truncation in $\mathbb{U}_{256}$ for $e \le 32$. If $e \notin \{3,\ldots,32\}$, $\text{ExpandTarget}(bits)$ is undefined (invalid compact exponent for PoW).

*Proof*: Case-split on $e \le 3$ versus $e > 3$ per the expansion definition; for $e > 3$, $8(e-3) \le 232 < 256$, so the left shift stays inside $\mathbb{U}_{256}$.

**Theorem 7.1.2** (Difficulty Adjustment Bounds Enforcement): Difficulty adjustment respects maximum and minimum bounds:

$$\forall h \in \mathcal{H}, prev \in \mathcal{H}^*, n \in \text{Network}:$$
$$\text{GetNextWorkRequired}(h, prev, n) \leq \text{MAX\_TARGET} \land \text{GetNextWorkRequired}(h, prev, n) > 0$$

*Proof*: By construction, the difficulty adjustment algorithm clamps the result to ensure it never exceeds $\text{MAX\_TARGET}$ and is always positive. This is proven by blvm-spec-lock formal verification.

**Theorem 7.2** (Difficulty Convergence): Under constant hash rate, the difficulty converges to the target block time.

*Proof*: Let $H$ be the constant hash rate and $D$ be the current difficulty. The expected time for the next block is:
$$E[T] = \frac{D \times 2^{256}}{H}$$

If $E[T] > targetTime$, then $timeSpan > expectedTime$, so $adjustment > 1$, increasing difficulty. If $E[T] < targetTime$, then $adjustment < 1$, decreasing difficulty. This creates a negative feedback loop that converges to $E[T] = targetTime$.

### 7.2 Block Validation

**CheckProofOfWork**: $\mathcal{H} \rightarrow \{\text{true}, \text{false}\}$

$$\text{CheckProofOfWork}(h) = \text{SHA256}(\text{SHA256}(h)) < \text{ExpandTarget}(h.bits)$$

Where [SHA256](https://en.wikipedia.org/wiki/SHA-2) is the [Secure Hash Algorithm](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf) and $\text{ExpandTarget}$ converts the compact difficulty representation to a full 256-bit target.

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: PoW correctness: $result = \text{true} \iff \text{SHA256}(\text{SHA256}(h)) < \text{ExpandTarget}(h.bits)$. Valid target expansion requires `h.bits` to have a non-zero exponent byte.

## 8. Security Properties

### 8.1 Economic Security

**Conservation of Value**: For any valid transaction $tx$:
$$\sum_{i \in tx.inputs} us(i.prevout).value \geq \sum_{o \in tx.outputs} o.value$$

**Theorem 8.1** (UTXO Set Invariant): The UTXO set maintains the invariant that the sum of all UTXO values equals the total money supply.

*Proof*: Let $US_h$ be the UTXO set at height $h$. We prove by induction:

**Base case**: At height 0 (genesis block), the UTXO set contains only the coinbase output, so the invariant holds.

**Inductive step**: Assume the invariant holds at height $h-1$. For block $b$ at height $h$:

1. **Non-coinbase transactions**: Each transaction $tx$ satisfies:
   $$\sum_{i \in tx.inputs} us(i.prevout).value = \sum_{o \in tx.outputs} o.value + \text{fee}(tx)$$

2. **Coinbase transaction**: Only adds value (block subsidy + fees) without spending any inputs.

3. **UTXO set update**: 
   $$\sum_{utxo \in US_h} utxo.value = \sum_{utxo \in US_{h-1}} utxo.value + \text{GetBlockSubsidy}(h) + \sum_{tx \in b.transactions} \text{fee}(tx)$$

Therefore, the total UTXO value increases by exactly the block subsidy plus fees, maintaining the invariant.

**Supply Limit**: For any height $h$:
$$\text{TotalSupply}(h) \leq 21 \times 10^6 \times C$$

**Theorem 8.2** (Supply Convergence): The total supply converges to exactly 21 million BTC.

*Proof*: From [Theorem 6.2.3](#62-total-supply), we have:
$$\lim_{h \to \infty} \text{TotalSupply}(h) = 21 \times 10^6 \times C$$

Since the subsidy becomes 0 after 64 halvings (height 13,440,000), the total supply is exactly:
$$\text{TotalSupply}(13,440,000) = 50 \times C \times \sum_{i=0}^{63} \left(\frac{1}{2}\right)^i = 50 \times C \times \frac{1 - (1/2)^{64}}{1 - 1/2} = 100 \times C \times (1 - 2^{-64})$$

For practical purposes, $2^{-64} \approx 0$, so the total supply is effectively 21 million BTC.

### 8.2 Integration and Round-Trip Properties

#### 8.2.1 Integration Properties

Integration properties verify that multiple functions work together correctly in multi-function workflows.

**Property** (Economic Block Integration): For valid blocks, economic rules are consistently enforced:

$$\forall b \in \mathcal{B}, h \in \mathbb{N}: \text{ConnectBlock}(b, us, h) = \text{valid} \implies$$
$$\text{GetBlockSubsidy}(h) + \sum_{tx \in b.transactions} \text{Fee}(tx, us) \geq \sum_{o \in b.transactions[0].outputs} o.value$$

Where $b.transactions[0]$ is the coinbase transaction.

**Property** (ConnectBlock-DisconnectBlock Idempotency): Connect and disconnect operations are perfect inverses:

$$\forall b \in \mathcal{B}, us \in \mathcal{US}, h \in \mathbb{N}, ul \in \mathcal{UL}:$$
$$\text{ConnectBlock}(b, us, h) = (\text{valid}, us') \implies$$
$$\text{DisconnectBlock}(b, ul, us') = us$$

Where $ul$ is the undo log created during $\text{ConnectBlock}$.

**Property** (BIP65 + BIP112 Locktime Consistency): Locktime encoding/decoding is consistent across BIPs:

$$\forall lt \in \mathbb{N}_{32}: \text{DecodeLocktime}(\text{EncodeLocktime}(lt)) = lt$$

**Property** (RBF Conflict Requirement): RBF replacement requires transaction conflict:

$$\forall tx_1, tx_2 \in \mathcal{TX}:$$
$$\text{ReplacementChecks}(tx_1, tx_2) = \text{true} \implies$$
$$\exists i \in tx_1.inputs, j \in tx_2.inputs: i.prevout = j.prevout$$

#### 8.2.2 Round-Trip Properties

Round-trip properties ensure that encoding/decoding and serialization/deserialization operations are inverse operations.

**Property** (Transaction Serialization Round-Trip): Transaction serialization and deserialization are inverse operations:

$$\forall tx \in \mathcal{TX}: \text{DeserializeTransaction}(\text{SerializeTransaction}(tx)) = tx$$

**Property** (SegWit Transaction Serialization Round-Trip): SegWit transaction serialization and deserialization are inverse operations, where $\mathcal{W}$ denotes witness stack (see [§11.1 Segregated Witness (SegWit)](#111-segregated-witness-segwit)):

$$\forall (tx, w) \in \mathcal{TX} \times \mathcal{W}^{*}: |w| = |tx.\text{inputs}| \implies \text{DeserializeTransactionWithWitness}(\text{SerializeTransactionWithWitness}(tx, w)) = (tx, w)$$

**Property** (Block Header Serialization Round-Trip): Block header serialization and deserialization are inverse operations:

$$\forall h \in \mathcal{H}: \text{DeserializeHeader}(\text{SerializeHeader}(h)) = h$$

**Property** (Serialization Determinism): Serialization is deterministic:

$$\forall tx_1, tx_2 \in \mathcal{TX}: tx_1 = tx_2 \iff \text{SerializeTransaction}(tx_1) = \text{SerializeTransaction}(tx_2)$$

**Property** (Locktime Encoding Round-Trip): Locktime encoding and decoding are inverse operations:

$$\forall lt \in \mathbb{N}_{32}: \text{DecodeLocktime}(\text{EncodeLocktime}(lt)) = lt$$

### 8.3 Cryptographic Security

**Signature Verification**: For public key $pk$, signature $sig$, and message hash $m$:
$$\text{VerifySignature}(pk, sig, m) = \text{secp256k1\_verify}(pk, sig, m)$$

Where [secp256k1](https://en.bitcoin.it/wiki/Secp256k1) is the [elliptic curve](https://en.wikipedia.org/wiki/Elliptic_curve) used by Bitcoin and [ECDSA](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) is the signature algorithm.

**Theorem 8.3** (Signature Security): Assuming the [discrete logarithm problem](https://en.wikipedia.org/wiki/Discrete_logarithm) is hard in the secp256k1 group, signature forgery is computationally infeasible.

*Proof*: This follows directly from the security of [ECDSA](https://tools.ietf.org/html/rfc6979) with [secp256k1](https://www.secg.org/sec2-v2.pdf). Any successful signature forgery would imply a solution to the discrete logarithm problem in the secp256k1 group, which is believed to be computationally infeasible.

**Script Security**: For script $s$ and flags $f$:
$$\text{ScriptSecure}(s, f) = |s| \leq L_{script} \land \text{OpCount}(s) \leq L_{ops}$$

**Theorem 8.4** (Script Execution Bounds): Script execution is bounded in time and space.

*Proof*: From the script limits:
- Maximum script size: $L_{script} = 10,000$ bytes
- Maximum operations: $L_{ops} = 201$
- Maximum combined stack and altstack size: $L_{stack} = 1,000$ (where $|stack| + |altstack| \leq L_{stack}$)

Since each operation takes constant time and the combined stack and altstack size is bounded, script execution is [$O(L_{ops}) = O(1)$](https://en.wikipedia.org/wiki/Big_O_notation) in the worst case.

### 8.4 Merkle Tree Security

#### 8.4.1 ComputeMerkleRoot

**ComputeMerkleRoot**: $\mathcal{H}^+ \rightarrow \mathbb{H}$ (non-empty sequence of 32-byte hashes to 32-byte root hash)

**Properties**:
- Deterministic: $result(H) = result(H)$ for all $H$ (same inputs always produce same root)
- Single element: $|H| = 1 \implies result = H[0]$
- Collision resistance: $result(H_1) = result(H_2) \implies H_1 = H_2$ (assuming SHA-256 collision resistance)

**Formula** (**F_MerkleRootDeterminism**):

$$result(H_1) == result(H_2)$$

Determinism: ComputeMerkleRoot is a pure function — the same input transaction hash list always produces the same root. Verified by blvm-spec-lock formal determinism check.

**Definition** (Bitcoin standard, double SHA-256):
1. Let $L_0 = H$ (leaf level).
2. While $|L_i| > 1$:
   - **Odd-duplicate rule**: If $|L_i|$ is odd, append $L_i[|L_i|-1]$ to $L_i$.
   - **CVE-2012-2459**: If any pair $(L_i[2j], L_i[2j+1])$ has $L_i[2j] = L_i[2j+1]$, the block is invalid (mutation detected).
   - **Pair-and-hash**: $L_{i+1}[j] = \text{SHA256d}(L_i[2j] \parallel L_i[2j+1])$ for $j \in [0, |L_i|/2)$.
   - Set $L_i = L_{i+1}$.
3. $\text{ComputeMerkleRoot}(H) = L_{\text{final}}[0]$.

Where $\text{SHA256d}(x) = \text{SHA256}(\text{SHA256}(x))$ (Bitcoin's standard hash).

**Theorem 8.4.1** (ComputeMerkleRoot Uniqueness): For fixed input $H$, $\text{ComputeMerkleRoot}(H)$ is uniquely determined.

*Proof*: Each step is deterministic; the algorithm terminates when $|L_i| = 1$.

**Theorem 8.5** (Merkle Tree Integrity): The [merkle root](https://en.wikipedia.org/wiki/Merkle_tree) commits to all transactions in the block.

*Proof*: The merkle root is computed as:
$$\text{MerkleRoot}(txs) = \text{ComputeMerkleRoot}(\{\text{Hash}(tx) : tx \in txs\})$$

Any change to any transaction would result in a different merkle root, assuming [SHA-256](https://en.wikipedia.org/wiki/SHA-2) is [collision-resistant](https://en.wikipedia.org/wiki/Collision_resistance).

**Theorem 8.6** (Merkle Tree Malleability): Bitcoin's merkle tree implementation is vulnerable to [CVE-2012-2459](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2012-2459).

*Proof*: The vulnerability occurs when the number of hashes at a given level is odd, causing the last hash to be duplicated. This can result in different transaction lists producing the same merkle root. The implementation mitigates this by detecting when identical hashes are hashed together and treating such blocks as invalid.

**Corollary 8.1**: The merkle tree provides cryptographic commitment to transaction inclusion but requires additional validation to prevent malleability attacks.

### 8.5 Deterministic Properties

Many consensus functions must be deterministic to ensure all nodes reach the same results.

**Theorem 8.5.1** (Proof of Work Determinism): Proof of work validation is deterministic:

$$\forall h \in \mathcal{H}: \text{CheckProofOfWork}(h) \text{ is deterministic}$$

*Proof*: The function uses only the block header and deterministic hash functions (SHA256). Given the same header, it always produces the same result. This is proven by blvm-spec-lock formal verification.

**Theorem 8.5.2** (Transaction Application Determinism): Transaction application is deterministic:

$$\forall tx \in \mathcal{TX}, us \in \mathcal{US}, h \in \mathbb{N}:$$
$$\text{ApplyTransaction}(tx, us, h) \text{ is deterministic}$$

*Proof*: Transaction application uses only the transaction, UTXO set, and height. All operations (UTXO removal, UTXO addition) are deterministic. The consistency and correctness of transaction application is proven by blvm-spec-lock formal verification.

**Theorem 8.5.3** (Block Connection Determinism): Block connection is deterministic:

$$\forall b \in \mathcal{B}, us \in \mathcal{US}, h \in \mathbb{N}:$$
$$\text{ConnectBlock}(b, us, h) \text{ is deterministic}$$

*Proof*: Block connection applies transactions deterministically and performs deterministic validation checks. This ensures all nodes reach the same consensus state.

## 9. Mempool Protocol

### 9.1 Mempool Validation

**AcceptToMemoryPool**: $\mathcal{TX} \times \mathcal{US} \rightarrow \{\text{accepted}, \text{rejected}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Acceptance correctness: $result = \text{accepted} \implies \text{CheckTransaction}(tx) = \text{valid} \land \neg \text{IsCoinbase}(tx)$. Coinbase is always rejected.

#### 9.1.1 Transaction Finality

$\text{CheckFinalTxAtTip}(tx)$ requires that absolute lock time ($nLockTime$) and input sequence locks (BIP68/BIP112) are satisfied at the current chain tip so the transaction is not treated as non-final for relay.

**CheckFinalTxAtTip**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

Let $h$ be the current chain height and $t$ the median time past of the tip (BIP113 clock for timestamp locktimes).

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

A transaction $tx$ is accepted to the mempool if and only if:

1. **Basic Validation**: $tx$ passes [CheckTransaction](#51-transaction-validation)
2. **Non-Coinbase**: $\neg \text{IsCoinBase}(tx)$
3. **Standard Transaction**: $\text{IsStandardTx}(tx)$ (see [§9.2](#92-standard-transaction-rules))
4. **Size Limits**: $|\text{Serialize}(tx)| \geq 65$ bytes (minimum non-witness size)
5. **Finality**: $\text{CheckFinalTxAtTip}(tx)$ (see [§9.1.1](#911-transaction-finality))
6. **Fee Requirements**: $\text{FeeRate}(tx) \geq \text{minRelayFeeRate}$
7. **SigOps Limit**: $\text{SigOpsCount}(tx) \leq \text{MAX\_STANDARD\_TX\_SIGOPS\_COST}$

### 9.2 Standard Transaction Rules

**IsStandardTx**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Standard version: $result = \text{true} \implies tx.version \in \{1, 2\}$. Standard transaction subset: $result = \text{true} \implies \text{CheckTransaction}(tx) = \text{valid}$. A standard transaction also requires all outputs to use standard script types.

A transaction is standard if:

1. **Version**: $tx.version \in \{1, 2\}$
2. **Script Types**: All outputs use standard script types:
   - P2PKH: `OP_DUP OP_HASH160 <20-byte-hash> OP_EQUALVERIFY OP_CHECKSIG`
   - P2SH: `OP_HASH160 <20-byte-hash> OP_EQUAL`
   - P2WPKH: `OP_0 <20-byte-hash>`
   - P2WSH: `OP_0 <32-byte-hash>`
   - P2TR: `OP_1 <32-byte-hash>`
3. **Data Carrier**: OP_RETURN outputs $\leq$ 83 bytes
4. **Dust Threshold**: All outputs $\geq$ dust threshold
5. **Multisig**: $\leq$ 3 keys for bare multisig

### 9.3 Replace-By-Fee (RBF)

**ReplacementChecks**: $\mathcal{TX} \times \mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- RBF requirement: $result = \text{true} \implies \exists i \in tx_1.inputs : i.sequence < \text{SEQUENCE\_FINAL}$ (RBF signaling required)
- Fee bump requirement: $result = \text{true} \implies \text{FeeRate}(tx_2) > \text{FeeRate}(tx_1)$ (higher fee rate required)
- Deterministic: $\text{ReplacementChecks}(tx_{1a}, tx_{2a}) = \text{ReplacementChecks}(tx_{1b}, tx_{2b}) \iff tx_{1a} = tx_{1b} \land tx_{2a} = tx_{2b}$
**Note**: Replacement requires $tx_1$ and $tx_2$ to conflict (share at least one input).
- Same transaction ID: $result = \text{true} \implies tx_1.id \neq tx_2.id$ (different transactions)

Transaction $tx_2$ can replace $tx_1$ if:

1. **RBF Signaling**: $tx_1$ has any input with $nSequence < \text{SEQUENCE\_FINAL}$
2. **Fee Bump**: $\text{FeeRate}(tx_2) > \text{FeeRate}(tx_1)$
3. **Absolute Fee**: $\text{Fee}(tx_2) > \text{Fee}(tx_1) + \text{minRelayFee}$
4. **Conflicts**: $tx_2$ spends at least one input from $tx_1$
5. **No New Unconfirmed**: All inputs of $tx_2$ are confirmed or from $tx_1$

## 10. Network Protocol

The Bitcoin network protocol enables nodes to synchronize the blockchain and relay transactions. The protocol operates over TCP connections and uses a message-based communication system.

### 10.1 Message Types

**NetworkMessage**: $\mathcal{M} = \{\text{version}, \text{verack}, \text{addr}, \text{inv}, \text{getdata}, \text{tx}, \text{block}, \text{headers}, \text{getheaders}, \text{ping}, \text{pong}\}$

**Message Flow**:
1. **Connection**: Nodes establish TCP connections
2. **Handshake**: Exchange `version` and `verack` messages
3. **Synchronization**: Request and receive blocks/headers
4. **Transaction Relay**: Broadcast new transactions
5. **Maintenance**: Periodic `ping`/`pong` to maintain connections

```mermaid
sequenceDiagram
    participant A as Node A
    participant B as Node B
    
    Note over A,B: Connection Establishment
    A->>B: TCP Connection
    B-->>A: Connection Accepted
    
    Note over A,B: Handshake
    A->>B: version
    B->>A: version
    A->>B: verack
    B->>A: verack
    
    Note over A,B: Peer Discovery
    A->>B: getaddr
    B->>A: addr
    
    Note over A,B: Block Synchronization
    A->>B: getheaders
    B->>A: headers
    A->>B: getdata (blocks)
    B->>A: block
    
    Note over A,B: Transaction Relay
    A->>B: tx
    B->>A: inv
    A->>B: getdata (tx)
    B->>A: tx
    
    Note over A,B: Maintenance
    loop Every 2 minutes
        A->>B: ping
        B->>A: pong
    end
```

#### 10.1.1 Message Header Parsing

**MessageHeader**: 24 bytes = magic (4) ‖ command (12) ‖ payload_length (4) ‖ checksum (4)

**ParseMessage**: $\mathbb{S} \rightarrow \mathcal{M} \cup \{\text{error}\}$

Parses raw bytes into a protocol message. Rejects messages that are too short, too long, have invalid magic, unknown command, invalid checksum, or incomplete payload.

**Properties**:
- Size minimum: $|data| < 24 \implies \text{ParseMessage}(data) = \text{error}$
- Size maximum: $|data| > L_{\max} \implies \text{ParseMessage}(data) = \text{error}$ where $L_{\max} = 32 \times 10^6$
- Checksum rejection: Invalid checksum yields error

**CalculateChecksum**: $\mathbb{S} \rightarrow [0,1]^{32}$ (first 4 bytes of double SHA256)

**Properties**:
- Checksum length: $|\text{CalculateChecksum}(payload)| = 4$

**Theorem 10.1.1** (Message Size Bounds): Valid messages satisfy $24 \leq |data| \leq L_{\max}$.

**Theorem 10.1.2** (Checksum Rejection): $\text{checksum} \neq \text{CalculateChecksum}(\text{payload}) \implies \text{ParseMessage}(data) = \text{error}$

**Implementation Invariants**:
1. **Checksum length**: $|\text{CalculateChecksum}(payload)| = 4$
2. **Payload bounds**: $\text{payload\_length} \leq L_{\max} - 24$

### 10.2 Connection Management

**Connection Types**:
- **Outbound**: Active connections to other nodes
- **Inbound**: Passive connections from other nodes
- **Feeler**: Short-lived connections for peer discovery
- **Block-Relay**: Connections that only relay blocks

Further P2P lifecycle and dispatch details appear with [§10.3](./ARCHITECTURE.md#103-peer-discovery) and [§10.6](./ARCHITECTURE.md#106-dandelion-k-anonymity) in [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### 10.2.1 Handshake Invariants

**HandleVersionReceived**: On receipt of `version` message, node must send `verack` only after processing. VerAck is never sent before Version.

**Properties**:

**Note**: Version-before-VerAck ordering: $\text{VerAckSent} \implies \text{VersionReceived}$ — VerAck is only sent after Version is received and processed. This is a temporal state-machine property on protocol session state variables, not a function postcondition expressible as a Z3 arithmetic constraint.

**Theorem 10.2.1** (Handshake Ordering): Version must be received before VerAck can be sent. This ensures proper connection establishment and prevents protocol violations.

### 10.4 Block Synchronization

**GetHeaders**: Request block headers from a specific point
**Headers**: Response containing block headers
**GetBlocks**: Request block inventory (deprecated)
**Inv**: Inventory message listing available objects
**GetData**: Request specific objects (blocks, transactions)
**Block**: Full block data
**MerkleBlock**: Block with merkle proof for filtered nodes

### 10.5 Transaction Relay

**Tx**: Broadcast transaction to peers
**MemPool**: Request mempool contents
**FeeFilter**: Set minimum fee rate for transaction relay

## 11. Advanced Features

### 11.1 Segregated Witness (SegWit)

*Intuition.* SegWit changes **what counts toward block limits** without breaking old serialization for `txid`. Signature and witness material is pulled into a parallel **witness** attachment; **`txid`** still hashes the legacy-encoded body (so layered systems that depended on stable `txid` keep working), while **`wtxid`** includes the witness and drives the witness Merkle tree. **Weight** replaces naive byte size so large witnesses pay more under the limit, but the legacy 1 MB “block size” framing is superseded by the weight cap. Consensus also requires a **coinbase witness commitment** linking the block’s witness transaction Merkle root to the header-derived chain structure, so miners cannot silently omit or swap witness data compatible with the same `txid` set.

**Witness Data**: $\mathcal{W} = \mathbb{S}^*$ (stack of witness elements)

**Witness Merkle (BIP141)**: The commitment uses the **witness transaction id (wtxid)** merkle tree (not a hash of raw witness stacks). Let $\text{wtxid}(tx)$ be the 32-byte hash defined in [BIP141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki): coinbase wtxid is fixed to $0^{32}$; for other transactions, if no witness data is present, $\text{wtxid}(tx) = \text{txid}(tx)$ (legacy serialization); if witness data is present, $\text{wtxid}(tx) = \text{SHA256d}(\text{SerializeWithWitness}(tx))$.

$$\text{WitnessRoot} = \text{ComputeMerkleRoot}(\{\text{wtxid}(tx_i) : i \in [0, |block.transactions|)\})$$

**Witness commitment output (BIP141)**: The 32-byte value in the coinbase OP_RETURN is $\text{SHA256d}(\text{WitnessRoot} \,\parallel\, \text{WitnessReservedValue})$, where $\text{WitnessReservedValue}$ is the 32-byte item in the coinbase input’s witness stack (default $0^{32}$ if absent), not the raw $\text{WitnessRoot}$ alone.

**Weight Calculation** (BIP141):  
$$\text{Weight}(tx) = 3 \times |\text{Serialize}(tx \setminus witness)| + |\text{Serialize}(tx)|$$

**HashWitness**: $\mathcal{W} \rightarrow \mathbb{H}$

Hashes witness data to a 32-byte digest for inclusion in the witness Merkle tree.

**Properties**:
- Hash output: produces 32-byte hash for comparison

**CountWitnessSigOps**: $\mathcal{TX} \times \mathcal{W}^* \times \mathcal{US} \times \mathbb{N} \rightarrow \mathbb{N}$

Counts witness-committed signature operations per BIP141/BIP143.

**Properties**:
- Coinbase zero: $\text{IsCoinbase}(tx) \implies result = 0$

#### 11.1.1 Weight and Size Calculations

**CalculateTransactionWeight**: $\mathcal{TX} \times \mathcal{W}^? \rightarrow \mathbb{N}$

**Properties**:
- Non-negative: $result \geq 0$

**Note**: Weight formula: $result = 3 \times \text{BaseSize}(tx) + \text{TotalSize}(tx, w)$ (BIP141). Weight bounds: $result \leq W_{\text{max\_tx\_weight}}$ for valid transactions. Witness increases weight.

For transaction $tx$ and witness $w$:

$$\text{CalculateTransactionWeight}(tx, w) = 3 \times \text{BaseSize}(tx) + \text{TotalSize}(tx, w)$$

Where:
- $result = |\text{Serialize}(tx \setminus witness)|$ (transaction size without witness data)
- $result = |\text{Serialize}(tx)|$ (transaction size with witness data)

**WeightToVSize**: $\mathbb{N} \rightarrow \mathbb{N}$

**Properties**:
- Ceiling division: $result = \lceil weight / 4 \rceil = (weight + 3) / 4$
- Lower bound: $result \geq weight / 4$
- Upper bound: $result \leq (weight / 4) + 1$
- Zero weight: $weight = 0 \implies result = 0$
- Exact division: $weight \bmod 4 = 0 \implies result = weight / 4$

For weight $weight$:

$$\text{WeightToVSize}(weight) = \lceil weight / 4 \rceil$$

Implemented as: $\text{WeightToVSize}(weight) = (weight + 3) / 4$ (integer ceiling division).

**CalculateBlockWeight**: $\mathcal{B} \times \mathcal{W}^* \rightarrow \mathbb{N}$

**Properties**:
- Defined: $\text{true}$

For block $b$ and witnesses $w_1, \ldots, w_n$:

$$\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) = \sum_{i=1}^{|b.\text{transactions}|} \text{CalculateTransactionWeight}(b.\text{transactions}[i], w_i)$$

**Block Weight Limit**: For block $b$:

$$\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) \leq W_{max}$$

Where $W_{max} = 4,000,000$ (MAX_BLOCK_WEIGHT).

**Formula** (**F_WeightToVSizeFloor**):
$$result \geq weight / 4$$

The virtual size (vsize) is at least the floor of weight divided by 4: $\text{vsize} = \lceil weight/4 \rceil \geq \lfloor weight/4 \rfloor$. Ceiling division is always ≥ floor division.

**Formula** (**F_WeightToVSizeCeiling**):
$$result \leq weight / 4 + 1$$

The virtual size is at most one more than the floor of weight divided by 4: $\lceil weight/4 \rceil \leq \lfloor weight/4 \rfloor + 1$. This bounds the ceiling to within 1 of the floor. Together with F_WeightToVSizeFloor, this characterizes ceiling division exactly.

#### 11.1.2 Witness Structure Validation

**ValidateSegWitWitnessStructure**: $\mathcal{W} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Element size bounds: $result = \text{true} \iff \forall e \in w : |e| \leq 520$. Empty witness: $|w| = 0 \implies result = \text{true}$.

For witness $w$:

$$\text{ValidateSegWitWitnessStructure}(w) = \forall e \in w : |e| \leq 520$$

Where 520 is MAX_SCRIPT_ELEMENT_SIZE (maximum witness element size per BIP141).

**IsWitnessEmpty**: $\mathcal{W} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Empty definition: $result = \text{true} \iff (|w| = 0) \lor (\forall e \in w : |e| = 0)$

For witness $w$:

$$\text{IsWitnessEmpty}(w) = (|w| = 0) \lor (\forall e \in w : |e| = 0)$$

**Formula** (**F_WitnessEmptyByLength**):
$$result == true$$

When the witness stack has zero elements ($|w| = 0$), IsWitnessEmpty always returns true. The outer emptiness check `is_empty()` returns true immediately.

#### 11.1.3 Witness Program Extraction

**ExtractWitnessVersion**: $\mathbb{S} \rightarrow \{\text{None}, \text{SegWitV0}, \text{TaprootV1}\}$

**Properties**:
- Defined: $\text{true}$

**Note**: Version range: $result \neq \text{None} \implies |s| \geq 2 \land (s[0] = 0x00 \lor s[0] = 0x51)$. SegWitV0: $s[0] = 0x00$. TaprootV1: $s[0] = 0x51$.

For script $s$:

$$\text{ExtractWitnessVersion}(s) = \begin{cases}
\text{SegWitV0} & \text{if } |s| \geq 2 \land s[0] = 0x00 \\
\text{TaprootV1} & \text{if } |s| \geq 2 \land s[0] = 0x51 \\
\text{None} & \text{otherwise}
\end{cases}$$

**ExtractWitnessProgram**: $\mathbb{S} \times \{\text{SegWitV0}, \text{TaprootV1}\} \rightarrow \mathbb{S}^?$

**Properties**:
- Defined: $\text{true}$

**Note**: Program extraction: $result = \text{Some}(p) \implies |s| \geq 3$. SegWit program: $s[1] \in \{0x14, 0x20\}$. Taproot program: $s[1] = 0x20 \land |s| \geq 3$.

For script $s$ and version $v$:

$$\text{ExtractWitnessProgram}(s, v) = \begin{cases}
s[2..|s|] & \text{if } v = \text{SegWitV0} \land s[1] \in \{0x14, 0x20\} \\
s[2..|s|] & \text{if } v = \text{TaprootV1} \land s[1] = 0x20 \\
\text{None} & \text{otherwise}
\end{cases}$$

**ValidateWitnessProgramLength**: $\mathbb{S} \times \{\text{SegWitV0}, \text{TaprootV1}\} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Valid program length: $result = \text{true} \implies |p| > 0$
- SegWit length: $result = \text{true} \iff |p| = 20 \lor |p| = 32$
- Taproot length: $result = \text{true} \iff |p| = 32$

For program $p$ and version $v$:

$$\text{ValidateWitnessProgramLength}(p, v) = \begin{cases}
|p| = 20 \lor |p| = 32 & \text{if } v = \text{SegWitV0} \\
|p| = 32 & \text{if } v = \text{TaprootV1} \\
\text{false} & \text{otherwise}
\end{cases}$$

**Formula** (**F_WitnessProgramLength20Valid**):
$$result == true$$

When the witness program length is exactly 20 bytes, ValidateWitnessProgramLength returns true (P2WPKH).

**Formula** (**F_WitnessProgramLength32Valid**):
$$result == true$$

When the witness program length is exactly 32 bytes, ValidateWitnessProgramLength returns true (P2WSH or P2TR).

**Formula** (**F_WitnessProgramLengthInvalid**):
$$result == false$$

When the witness program length is neither 20 nor 32 bytes, ValidateWitnessProgramLength returns false (invalid length).

#### 11.1.4 Witness Merkle Root

**ComputeWitnessMerkleRoot**: $\mathcal{B} \times \mathcal{W}^* \rightarrow \mathbb{H}$

**Definition** (BIP141 wtxid tree): For each transaction index $i$, define the leaf hash $L_i$:

- $L_0 = 0^{32}$ (coinbase wtxid is fixed to zero).
- For $i > 0$: let $w^{(i)}$ be the witness data for transaction $i$ (per-input stacks). If no witness element is non-empty, $L_i = \text{txid}(b.\text{transactions}[i])$ using **legacy** serialization (no witness). Otherwise $L_i = \text{SHA256d}(\text{SerializeWithWitness}(b.\text{transactions}[i], w^{(i)}))$.

$$\text{ComputeWitnessMerkleRoot}(b, w_1, \ldots, w_n) = \text{ComputeMerkleRoot}(\{L_0, L_1, \ldots, L_{|b.\text{transactions}|-1}\})$$

**Properties**:
- Hash output: produces 32-byte hash for comparison
- Non-empty block: $|b.\text{transactions}| > 0$ (requires at least one transaction)
- CVE-2012-2459 guard: validates template hash matches expected value (odd-duplicate rejection per §8.4.1)

#### 11.1.5 Witness Commitment Validation

**ValidateWitnessCommitment**: $\mathcal{TX} \times \mathbb{H} \times \mathcal{W}^* \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Inputs**: coinbase transaction $tx$, computed witness merkle root $r$, and the coinbase transaction’s witness stacks (to obtain the **witness reserved value**).

Let $n \in \{0,1\}^{256}$ be the 32-byte witness reserved value: the first push of the first witness stack of the coinbase input, or $0^{32}$ if missing or not exactly 32 bytes.

Let $c = \text{SHA256d}(r \,\parallel\, n)$ (64-byte preimage). A valid witness commitment output stores $c$ (not $r$ alone).

**OP_RETURN format** (BIP141): `OP_RETURN` `0x24` `0xaa21a9ed` $\parallel\, c$ (total push 36 bytes after opcode: 4-byte magic + 32-byte $c$).

Consensus invokes $\text{ValidateWitnessCommitment}$ on the block’s coinbase ($b.\text{transactions}[0]$) after coinbase structure rules pass; the helper itself does not re-check $\text{IsCoinbase}$.

**Properties**:

$$\text{ValidateWitnessCommitment}(tx, r, w_{cb}) = \text{true} \iff \neg \exists \text{ commitment output} \lor \exists o \in tx.\text{outputs} : \text{ExtractCommitment}(o.\text{scriptPubkey}) = c$$

Where $\text{ExtractCommitment}(spk)$ returns the 32-byte hash after the BIP141 magic prefix when $spk$ matches the standard witness commitment pattern; otherwise undefined.

#### 11.1.6 SegWit Transaction Detection

**IsSegWitTransaction**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Output detection: $result = \text{true} \iff \exists o \in tx.\text{outputs} : \text{IsSegWitOutput}(o.\text{scriptPubkey})$. A transaction is a SegWit transaction if it has at least one SegWit-type output.

For transaction $tx$:

$$\text{IsSegWitTransaction}(tx) = \exists o \in tx.\text{outputs} : \text{IsSegWitOutput}(o.\text{scriptPubkey})$$

Where $\text{IsSegWitOutput}(spk) = (|spk| \in \{22, 34\}) \land (spk[0] = 0x00) \land ((spk[1] = 0x14) \lor (spk[1] = 0x20))$

#### 11.1.7 Block Validation

**ValidateSegWitBlock**: $\mathcal{B} \times \mathcal{W}^* \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

(Parameters: block $b$, per-transaction witness data $w_1,\ldots,w_n$, maximum block weight $W_{\text{max}}$.)

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Witness commitment (when present) must satisfy §11.1.5. Block weight must not exceed $W_{\text{max}}$.

$$\text{ValidateSegWitBlock}(b, w_1, \ldots, w_n, W_{\text{max}}) = \begin{cases}
\text{valid} & \text{if } \text{CalculateBlockWeight}(\ldots) \leq W_{\text{max}} \land \text{ValidateWitnessCommitment}(b.\text{transactions}[0], r, w_1) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

(If no witness commitment output exists in the coinbase, [§11.1.5](#1115-witness-commitment-validation) treats validation as satisfied for pre-SegWit coinbase layouts; implementations gate full SegWit rules on deployment context.)

#### 11.1.8 Nested SegWit (P2WSH-in-P2SH, P2WPKH-in-P2SH)

**Nested SegWit**: SegWit outputs can be wrapped in P2SH, creating nested SegWit transactions.

**P2WPKH-in-P2SH**: Pay-to-Witness-Public-Key-Hash wrapped in P2SH

For P2WPKH-in-P2SH:
- **Redeem Script Format**: $[0x00, 0x14, h_{20}]$ where $h_{20} \in \{0,1\}^{160}$
  - $0x00$ is OP_0
  - $0x14$ is push 20 bytes
  - $h_{20}$ is the 20-byte pubkey hash
- **Witness**: Contains signature and public key (2 elements)
- **Validation**: Witness program is 20 bytes, witness contains signature + pubkey

**P2WSH-in-P2SH**: Pay-to-Witness-Script-Hash wrapped in P2SH

For P2WSH-in-P2SH:
- **Redeem Script Format**: $[0x00, 0x20, h_{32}]$ where $h_{32} \in \{0,1\}^{256}$
  - $0x00$ is OP_0
  - $0x20$ is push 32 bytes
  - $h_{32}$ is the 32-byte script hash
- **Witness**: Contains witness script as last element
- **Validation**: Witness program is 32 bytes, witness script (last witness element) must hash to program

**Nested SegWit Detection**: $\text{IsNestedSegWit}(redeem) = (redeem[0] = 0x00) \land ((redeem[1] = 0x14) \lor (redeem[1] = 0x20))$

**Theorem 11.1.2** (Nested SegWit SigVersion): P2WSH-in-P2SH and P2WPKH-in-P2SH witness validation uses $\text{SigVersion} = \text{WitnessV0}$ and BIP143 sighash. $\text{SCRIPT\_VERIFY\_WITNESS\_PUBKEYTYPE}$ ($0x8000$) is a Schnorr pubkey-type strictness flag when Taproot outputs exist in the transaction; it does **not** select Tapscript semantics for nested SegWit v0 spends.

*Proof*: Witness program validation dispatches v0 programs to WitnessV0 regardless of WITNESS_PUBKEYTYPE; Tapscript applies only to v1 P2TR witness programs (BIP341).

**Activation**: Block 481,824 (mainnet) - Same as SegWit activation

#### 11.1.9 BIP143 Witness Sighash (ComputeWitnessSignatureHash)

**ComputeWitnessSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{S} \times \mathbb{Z} \times \mathbb{N}_{8} \rightarrow \mathbb{H}$

Computes the signature hash for SegWit (P2WPKH, P2WSH) inputs per BIP 143. Replaces legacy sighash with a committed structure that excludes scriptSig and binds the amount.

**Preimage structure** (BIP 143 byte layout):
$$\text{Preimage} = \text{nVersion}\_{32} \parallel \text{hashPrevouts}\_{256} \parallel \text{hashSequence}\_{256} \parallel \text{outpoint}\_{288} \parallel \text{scriptCode} \parallel \text{amount}\_{64} \parallel \text{nSequence}\_{32} \parallel \text{hashOutputs}\_{256} \parallel \text{nLockTime}\_{32} \parallel \text{sighashType}\_{32}$$

**Precomputed hashes**:
- $\text{hashPrevouts} = \text{SHA256d}(\text{concat}(\text{prevout}_i : i \in \text{inputs}))$ (or $0^{256}$ if ANYONECANPAY)
- $\text{hashSequence} = \text{SHA256d}(\text{concat}(\text{sequence}_i : i \in \text{inputs}))$ (or $0^{256}$ if ANYONECANPAY)
- $\text{hashOutputs} = \text{SHA256d}(\text{concat}(\text{output}_j : j \in \text{included outputs}))$ (depends on sighash type)

**Sighash type handling**:
- SIGHASH_ALL (0x01): all outputs included
- SIGHASH_NONE (0x02): no outputs; hashOutputs = $0^{256}$
- SIGHASH_SINGLE (0x03): output at input index only; hashOutputs = SHA256d of that output
- ANYONECANPAY (0x80): only signing input; hashPrevouts, hashSequence = $0^{256}$

**Definition**:
$$\text{ComputeWitnessSignatureHash}(tx, i, scriptCode, amount, type) = \text{SHA256d}(\text{Preimage})$$

**Properties**:
- Defined: $\text{true}$

**Note**: Hash length: $|\text{ComputeWitnessSignatureHash}(\ldots)| = 32$. Amount binding: signature commits to UTXO value (replay protection across outputs).

**Theorem 11.1.2** (BIP143 Sighash Determinism): For fixed $(tx, i, scriptCode, amount, type)$, $\text{ComputeWitnessSignatureHash}$ is uniquely determined.

*Proof*: Preimage is deterministic from inputs; SHA256d is deterministic. Thus the hash is unique.

#### 11.1.9.1 DeriveWitnessScriptCode (BIP143 scriptCode)

**DeriveWitnessScriptCode**: $\mathbb{S} \times \mathbb{S}^? \rightarrow \mathbb{S}$

**Properties**:
- Defined: $\text{true}$
- P2WPKH length: $|result| = 25$ when $|program| = 22$

Derives the BIP143 `scriptCode` parameter for SegWit v0 inputs. This is **not** the witness program bytes on the output chain; it is the script whose hash is committed in the BIP143 preimage (BIP143 §4.3).

**P2WPKH** (native or nested in P2SH): witness program is `OP_0 PUSH_20 <20-byte-pubkey-hash>` (22 bytes). The scriptCode is the P2PKH expansion:

$$\text{DeriveWitnessScriptCode}(program, \_) = \texttt{OP\_DUP OP\_HASH160} \parallel h_{20} \parallel \texttt{OP\_EQUALVERIFY OP\_CHECKSIG}$$

(25 bytes total; $h_{20}$ is the 20-byte pubkey hash from the program.)

**P2WSH** (native or nested in P2SH): witness program is `OP_0 PUSH_32 <32-byte-hash>` (34 bytes). The scriptCode is the **witness script** (last element of the input witness stack):

$$\text{DeriveWitnessScriptCode}(program, witnessScript) = witnessScript$$

**Properties**:
- P2WPKH length: $|result| = 25$ when $|program| = 22$ and $program[0] = 0x00$, $program[1] = 0x14$
- P2WSH: $result = witnessScript$ when $|program| = 34$ and $program[0] = 0x00$, $program[1] = 0x20$
- Distinct from program: for P2WPKH, $|result| \neq |program|$ ($25 \neq 22$)

**Theorem 11.1.3** (P2WPKH scriptCode): Using the raw 22-byte witness program as BIP143 scriptCode for P2WPKH is incorrect; implementations must expand to the P2PKH script above.

*Proof*: BIP143 §4.3 requires the P2PKH expansion for P2WPKH inputs. Signatures are validated against $\text{ComputeWitnessSignatureHash}$ with this scriptCode.

### 11.2 Taproot

**Taproot Output**: P2TR script `OP_1 <32-byte-hash>`

**P2TR Script Format**: $\text{P2TR} = [0x51, 0x20, h_{32}]$ where $h_{32} \in \{0,1\}^{256}$

**P2TR Detection**: $\text{IsP2TR}(spk) = (|spk| = 34) \land (spk[0] = 0x51) \land (spk[1] = 0x20)$

**Empty ScriptSig Requirement**: For Taproot transactions, scriptSig must be empty:

$$\forall tx \in \mathcal{TX}, i \in \mathbb{N} : \text{IsP2TR}(tx.\text{outputs}[j].\text{scriptPubkey}) \land tx.\text{inputs}[i].\text{prevout} = (txid, j) \implies tx.\text{inputs}[i].\text{scriptSig} = \emptyset$$

**Key Aggregation**: 
$$\text{OutputKey} = \text{InternalPubKey} + \text{TaprootTweak}(\text{MerkleRoot}) \times G$$

**TaprootActivationHeight**: $\text{Network} \rightarrow \mathbb{N}$

Returns the block height at which Taproot (BIP341) activated on each network.

**Formula** (**F_TaprootActivationMainnet**):
$$result == 709632$$

On mainnet ($\text{network} = 0$), TaprootActivationHeight returns 709,632 exactly.

**Formula** (**F_TaprootActivationTestnet**):
$$result == 2011968$$

On testnet ($\text{network} = 1$), TaprootActivationHeight returns 2,011,968 exactly.

**Formula** (**F_TaprootActivationRegtest**):
$$result == 0$$

On regtest ($\text{network} = 2$), TaprootActivationHeight returns 0 (immediate activation).

**Script Path**: Alternative spending path using merkle proof

**ValidateTaprootWitnessStructure**: $\mathcal{W} \times \{\text{true}, \text{false}\} \rightarrow \{\text{true}, \text{false}\}$

Checks that a Taproot spend's witness stack is well-formed: key-path spends require exactly one 64-byte Schnorr signature; script-path spends require at least a script and a control block.

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: Empty witness fails: $|w| = 0 \implies result = \text{false}$.

#### 11.2.1 Taproot Script Validation

**ValidateTaprootScript**: $\mathbb{S} \rightarrow \{\text{true}, \text{false}\}$

For script $s$:

$$\text{ValidateTaprootScript}(s) = (|s| = 34) \land (s[0] = 0x51) \land (s[1] = 0x20)$$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**Note**: $result = \text{true} \iff |s| = 34 \land s[0] = 0x51 \land s[1] = 0x20$. Scripts of other lengths are always invalid.

**ExtractTaprootOutputKey**: $\mathbb{S} \rightarrow \{[0,1]^{256}\}^?$

**Properties**:
- Defined: $\text{true}$

**Note**: Key extraction: $result = \text{Some}(k) \implies \text{ValidateTaprootScript}(s) = \text{true}$ and $|k| = 32$.

For script $s$:

$$\text{ExtractTaprootOutputKey}(s) = \begin{cases}
s[2..34] & \text{if } \text{ValidateTaprootScript}(s) \\
\text{None} & \text{otherwise}
\end{cases}$$

**IsTaprootOutput**: $\mathcal{T} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Output detection: $result = \text{true} \iff \text{ValidateTaprootScript}(o.scriptPubkey) = \text{true}$
- Script validation: $result = \text{true} \implies |o.scriptPubkey| = 34 \land o.scriptPubkey[0] = 0x51$

For transaction output $o$:

$$\text{IsTaprootOutput}(o) = \text{ValidateTaprootScript}(o.\text{scriptPubkey})$$

**Formula** (**F_TaprootOutputScriptLengthInvalid**):
$$result == false$$

When the scriptPubKey is not exactly 34 bytes, IsTaprootOutput always returns false. The P2TR format requires $|spk| = 34$ (1 byte OP_1 + 1 byte push + 32 bytes key).

#### 11.2.2 Taproot Key Operations

**ComputeTaprootTweak**: $[0,1]^{256} \times \mathbb{H} \rightarrow [0,1]^{256}$

**Properties**:
- Tweak length: $result = t \implies |t| = 32$ (32-byte tweak)
- Hash property: $result$ uses tagged hash for domain separation

For internal public key $pk$ and merkle root $root$:

$$\text{ComputeTaprootTweak}(pk, root) = \text{TaggedHash}(\text{"TapTweak"}, pk, root)$$

Where $\text{TaggedHash}$ is BIP340 tagged hash function.

**ValidateTaprootKeyAggregation**: $[0,1]^{256} \times [0,1]^{256} \times \mathbb{H} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Key aggregation correctness: $result = \text{true} \iff out = pk + \text{ComputeTaprootTweak}(pk, root) \times G$
- Elliptic curve operation: $result$ validates elliptic curve point addition

For internal public key $pk$, output key $out$, and merkle root $root$:

$$\text{ValidateTaprootKeyAggregation}(pk, out, root) = (out = pk + \text{ComputeTaprootTweak}(pk, root) \times G)$$

#### 11.2.3 Taproot Script Path

**ValidateTaprootScriptPath**: $\mathbb{S} \times [\mathbb{H}]^* \times [0,1]^{256} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Merkle proof validation: $result = \text{true} \iff \text{ComputeScriptMerkleRoot}(s, proof, v) = root$
- Script path correctness: $result$ validates script is in Taproot merkle tree

For script $s$, merkle proof $proof$, and expected merkle root $root$:

$$\text{ValidateTaprootScriptPath}(s, proof, root) = \begin{cases}
\text{true} & \text{if } \text{ComputeScriptMerkleRoot}(s, proof, v) = root \\
\text{false} & \text{otherwise}
\end{cases}$$

where $v$ is the leaf version (default $\texttt{0xc0}$ for tapscript per BIP 341).

**ComputeScriptMerkleRoot**: $\mathbb{S} \times [\mathbb{H}]^* \times \mathbb{N}_{8} \rightarrow \mathbb{H}$

**Properties**:
- Defined: $\text{true}$

Computes the Taproot script merkle root from a leaf script and merkle proof using BIP 341 TapLeaf and TapBranch tagged hashes.

**TapLeaf Hash** (BIP 341):
$$\text{TapLeafHash}(v, s) = \text{TaggedHash}(\texttt{"TapLeaf"}, v \parallel \text{CompactSize}(\lvert s \rvert) \parallel s)$$

where $v \in \{0,\ldots,255\}$ is the leaf version, $s \in \mathbb{S}$ is the script, and $\text{CompactSize}$ encodes the script length per Bitcoin varint.

**TapBranch Hash** (BIP 341):
$$\text{TapBranchHash}(h_L, h_R) = \text{TaggedHash}(\texttt{"TapBranch"}, h_L \parallel h_R)$$

where $h_L, h_R \in \mathbb{H}$ are 32-byte hashes. For sibling ordering: $(h_{\text{left}}, h_{\text{right}}) = (\min(h_{\text{current}}, h_{\text{proof}}), \max(h_{\text{current}}, h_{\text{proof}}))$ (lexicographic order).

**Definition** (iterative, BIP 341):

$$h_0 = \text{TapLeafHash}(v, s)$$

For $j = 0, \ldots, |proof|-1$:
$$(h_L, h_R) = (\min(h_j, proof[j]), \max(h_j, proof[j])) \quad \text{(lexicographic order)}$$
$$h_{j+1} = \text{TapBranchHash}(h_L, h_R)$$

$$\text{ComputeScriptMerkleRoot}(s, proof, v) = h_{|proof|}$$

**Properties**:
- Hash length: $result = h \implies |h| = 32$
- Root length: $|result| = 32$

**Theorem 11.2.2** (Script Merkle Root Uniqueness): For fixed script $s$, proof $proof$, and leaf version $v$, $\text{ComputeScriptMerkleRoot}(s, proof, v)$ is uniquely determined.

*Proof*: TapLeafHash and TapBranchHash are deterministic cryptographic hash functions. The iterative construction processes each proof element in order; sibling ordering is fixed by lexicographic comparison. Thus the computation is deterministic and produces a unique 32-byte root.

#### 11.2.4 Taproot Witness Structure

**ValidateTaprootWitnessStructure**: $\mathcal{W} \times \{\text{true}, \text{false}\} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Boolean result: $result \in \{\text{true}, \text{false}\}$

**StripTaprootAnnex**: $\mathcal{W} \rightarrow \mathcal{W} \times \mathbb{H}^?$

**Properties**:
- Defined: $\text{true}$
- Boolean tuple: $result = (w', h) \implies |w'| \leq |w|$

Optional BIP341 annex: when $|w| \geq 2$ and the last witness element begins with byte $0x50$, remove it before key/script-path dispatch and compute the annex sighash component $\text{SHA256}(\text{varint}(|annex|) \parallel annex)$.

$$\text{StripTaprootAnnex}(w) = \begin{cases}
(w[0..|w|-1], h) & \text{if annex present} \\
(w, \bot) & \text{otherwise}
\end{cases}$$

**ValidateTaprootWitnessStructure**: $\mathcal{W} \times \{\text{true}, \text{false}\} \rightarrow \{\text{true}, \text{false}\}$

**Note**: Key path: $|w| = 1$ after annex strip; $|w[0]| \in \{64, 65\}$ (BIP340 Schnorr). If $|w[0]| = 65$, byte 64 must not be explicit `SIGHASH_DEFAULT` ($0x00$). Script path structure: $|w| \geq 2$ after annex strip; control block at $w[|w|-1]$ with $(|control| - 33) \bmod 32 = 0$.

For witness $w$ and script path flag $is\_script$ (evaluated on annex-stripped stack):

$$\text{ValidateTaprootWitnessStructure}(w, is\_script) = \begin{cases}
|w| = 1 \land |w[0]| \in \{64, 65\} \land \neg(|w[0]| = 65 \land w[0][64] = 0) & \text{if } \neg is\_script \text{ (key path)} \\
|w| \geq 2 \land |w[|w|-1]| \geq 33 \land (|w[|w|-1]| - 33) \bmod 32 = 0 & \text{if } is\_script \text{ (script path)}
\end{cases}$$

#### 11.2.5 Taproot Transaction Validation

**ValidateTaprootTransaction**: $\mathcal{TX} \times \mathcal{W}^? \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- ScriptSig empty: $result = \text{valid} \implies \forall i \in tx.inputs : \text{IsP2TR}(tx.outputs[j].scriptPubkey) \implies i.scriptSig = \emptyset$
- Witness structure: $result = \text{valid} \implies \text{ValidateTaprootWitnessStructure}(w, \text{IsScriptPath}(w)) = \text{true}$
- Validation correctness: $result$ validates all Taproot-specific rules

For transaction $tx$ and witness $w$:

$$\text{ValidateTaprootTransaction}(tx, w) = \begin{cases}
\text{valid} & \text{if } \forall i \in tx.\text{inputs} : \text{IsP2TR}(tx.\text{outputs}[j].\text{scriptPubkey}) \implies i.\text{scriptSig} = \emptyset \land \text{ValidateTaprootWitnessStructure}(w, \text{IsScriptPath}(w)) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

#### 11.2.6 Taproot Signature Hash

**TryParseTaprootSchnorrWitnessSig**: $\mathbb{S} \rightarrow [0,1]^{512} \times \mathbb{N}_8^?$

**Properties**:
- Defined: $\text{true}$
- Length: $|sig| \in \{64, 65\} \implies result \neq \bot$

Parses a Taproot witness Schnorr signature element: 64 bytes → implicit `SIGHASH_DEFAULT` ($0x00$); 65 bytes → last byte is explicit sighash type (explicit $0x00$ suffix is invalid).

**ComputeTaprootSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \mathbb{N}_{32} \times \mathbb{H}^? \rightarrow \mathbb{H}$

**Properties**:
- Hash length: $result = h \implies |h| = 32$ (32-byte hash)
- Tagged hash: $result$ uses BIP340 tagged hash for domain separation
- Annex: optional annex hash $h_a$ from $\text{StripTaprootAnnex}$; $\text{spend\_type} = (\text{ext\_flag} \ll 1) \lor \text{annex\_present}$ (key path: $0x00$ or $0x01$); append $h_a$ to SigMsg when present

For transaction $tx$, input index $i$, UTXO set $us$, sighash type $type$, and optional annex hash $h_a$:

$$\text{ComputeTaprootSignatureHash}(tx, i, us, type, h_a) = \text{TaggedHash}(\text{"TapSighash"}, \text{SigMsg}(tx, i, us, type, h_a))$$

#### 11.2.7 Tapscript Signature Hash (BIP 342)

**ComputeTapscriptSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \mathbb{S} \times \mathbb{N}_{8} \times \mathbb{N}_{32} \times \mathbb{N}_{8} \times \mathbb{H}^? \rightarrow \mathbb{H}$

**Properties**:
- Defined: $\text{true}$
- Annex: same $\text{spend\_type}$ annex bit as key-path; script path uses $\text{spend\_type} = 0x02$ or $0x03$ when annex present; append annex hash before tapleaf extension fields

Computes the signature hash for tapscript (script-path) spending. Same base SigMsg structure as key-path (11.2.6), with an extension field $ext$ that binds the signature to the specific tapscript and OP_CODESEPARATOR position.

**Extension field** (BIP 342):
$$ext = \operatorname{codesep\_pos}_{32} \parallel \operatorname{key\_version}_{8} \parallel \operatorname{tapleaf\_hash}_{256}$$

where:
- $\text{codesep\_pos}_{32}$: 4-byte little-endian encoding of the last OP_CODESEPARATOR position (0 if none executed)
- $\text{key\_version}_{8}$: 1 byte, value $0x00$ for current tapscript
- $\text{tapleaf\_hash}_{256}$: 32-byte $result$ of the executing tapscript

**Definition**:
$$\text{SigMsgBase}(tx, i, us, type) = \text{version} \parallel \text{inputs} \parallel \text{outputs} \parallel \text{locktime} \parallel type \parallel i \parallel \text{value}_i \parallel \text{scriptPubKey}_i$$

$$\text{ComputeTapscriptSignatureHash}(tx, i, us, s, v, \text{codesep}, type) = \text{TaggedHash}(\texttt{"TapSighash"}, 0x00 \parallel \text{SigMsgBase}(tx, i, us, type) \parallel ext)$$

where $ext = \text{LE}_{32}(\text{codesep}) \parallel 0x00 \parallel \text{TapLeafHash}(v, s)$.

**Properties**:
- Hash length: $result = h \implies |h| = 32$
- Script binding: Signature is bound to specific tapscript via tapleaf_hash
- Codeseparator binding: OP_CODESEPARATOR position affects hash (replay protection across script versions)

**Theorem 11.2.3** (Tapscript Sighash Uniqueness): For fixed transaction $tx$, input index $i$, UTXO data $us$, tapscript $s$, leaf version $v$, codesep position $\text{codesep}$, and sighash type $type$, $\text{ComputeTapscriptSignatureHash}(tx, i, us, s, v, \text{codesep}, type)$ is uniquely determined.

*Proof*: SigMsgBase is deterministic from $(tx, i, us, type)$. TapLeafHash is deterministic. The extension $ext$ is concatenation of fixed-length fields. TaggedHash is a deterministic cryptographic hash. Thus the full computation is deterministic and produces a unique 32-byte hash.

**Theorem 11.2.1** (Taproot Empty ScriptSig): Taproot transactions require empty scriptSig for all inputs spending P2TR outputs.

*Proof*: By construction, Taproot validation happens entirely through witness data (key path or script path). The scriptPubKey `OP_1 <32-byte-hash>` is not executable as a script, so scriptSig must be empty. If scriptSig is non-empty, validation fails before witness processing.

#### 11.2.8 Tapscript Opcodes and SigOp Counting (BIP 342)

**OP_CHECKSIGADD** (opcode 0xba): Tapscript-only opcode for signature aggregation.

**Stack semantics**: Pops $(pk, n, sig)$ where $pk \in \mathbb{B}^{32}$, $n \in \mathbb{N}_{32}$, $sig \in \mathbb{B}^{64}$. Verifies BIP 340 Schnorr signature $(pk, sig)$ against the tapscript sighash. If valid: push $(n+1)$; else: fail.

$$\text{OP\_CHECKSIGADD}(pk, n, sig) = \begin{cases}
n+1 & \text{if } \text{VerifySchnorr}(pk, sig, \text{ComputeTapscriptSignatureHash}(\ldots)) = \text{true} \\
\text{fail} & \text{otherwise}
\end{cases}$$

**SigOp cost**: $\text{SigOpCount}(\texttt{0xba}) = 1$ (same as OP_CHECKSIG, OP_CHECKSIGVERIFY).

**CountTapscriptSigOps**: $\mathbb{S} \rightarrow \mathbb{N}$; counts CHECKSIG-family opcodes in a tapscript per **BIP 342** (used for the **per-tapscript sigops budget** during Tapscript execution / validation weight). This count is **not** added to the **legacy block** $\text{GetTransactionSigOpCost}$ witness term ($\text{CountWitnessSigOps}$ is witness-v0-only for that cost; see [§5.2.2](#522-signature-operation-counting)).

Parse $s$ sequentially. For each byte: if it is a push opcode (0x01–0x4b, or 0x4c/0x4d/0x4e with length bytes), skip the payload; otherwise it is an opcode byte. Count opcode bytes in $\{0xac, 0xad, 0xba\}$:

$$\text{CountTapscriptSigOps}(s) = \sum_{\text{opcode positions } i} \mathbf{1}[s[i] \in \{0xac, 0xad, 0xba\}]$$

where $0xac = \text{OP\_CHECKSIG}$, $0xad = \text{OP\_CHECKSIGVERIFY}$, $0xba = \text{OP\_CHECKSIGADD}$. Bytes inside push-data payloads are not counted (they are data, not opcodes).

**Properties**:
- Bounds: $result \leq |s|$ (each opcode byte counts at most once)
- No CHECKMULTISIG: Tapscript disables OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY; only CHECKSIG-family opcodes count

**Activation**: Block 709,632 (mainnet)

### 11.4 UTXO Commitments

**Scope:** UTXO commitments are **not consensus-active on Bitcoin mainnet** at the chain tip described in this document. They are specified for optional deployments, research implementations, and networks that choose to enable them (for example behind feature flags). Treat material in this section as **non–mainnet-mandatory** unless your deployment explicitly activates UTXO commitments.

UTXO commitments provide cryptographic commitments to the UTXO set using Merkle trees, enabling efficient UTXO set synchronization and verification without requiring full blockchain download.

**UTXO Commitment**: $\mathcal{UC} = \mathbb{H} \times \mathbb{N} \times \mathbb{H} \times \mathbb{N} \times \mathbb{N}$

A UTXO commitment contains:
- `merkle_root`: Root hash of the UTXO Merkle tree
- `block_height`: Block height at which commitment was created
- `block_hash`: Hash of the block at commitment height
- `total_supply`: Total supply committed (sum of all UTXO values)
- `utxo_count`: Number of UTXOs in the commitment

**UTXO Merkle Tree**: Sparse Merkle tree where:
- **Key**: OutPoint hash (256 bits)
- **Value**: Serialized UTXO (value, script_pubkey, height)
- **Root**: Merkle root hash committing to entire UTXO set

**GenerateCommitment**: $\mathcal{US} \times \mathbb{H} \times \mathbb{N} \rightarrow \mathcal{UC}$

**Properties**:
- Merkle root correctness: $result.\text{merkle\_root} = \text{BuildMerkleTree}(us)$ (merkle root commits to entire UTXO set)
- Height consistency: $result.\text{block\_height} = h$ (height matches input)
- UTXO count: $result.\text{utxo\_count} = |us|$ (count matches UTXO set size)
- Total supply: $result.\text{total\_supply} = \sum_{u \in us} u.\text{value}$ (total supply equals sum of UTXO values)
- Block hash: $result.\text{block\_hash} = bh$ (block hash matches input)
- Merkle root length: $result.\text{merkle\_root}$ is 32 bytes (SHA256 hash)
- Supply consistency: $result.\text{total\_supply} \leq \text{MAX\_MONEY}$ (supply respects maximum)

For UTXO set $us$, block hash $bh$, and height $h$:

$$\text{GenerateCommitment}(us, bh, h) = \begin{cases}
uc & \text{where } uc.\text{merkle\_root} = \text{BuildMerkleTree}(us) \\
& uc.\text{block\_height} = h \\
& uc.\text{block\_hash} = bh \\
& uc.\text{total\_supply} = \sum_{utxo \in us} utxo.\text{value} \\
& uc.\text{utxo\_count} = |us|
\end{cases}$$

**FindConsensus**: $[\mathcal{UC}] \times [0,1] \rightarrow \mathcal{UC}^?$

**Properties**:
- Consensus existence: $result = \text{Some}(c) \implies \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t$ (consensus requires threshold agreement)
- Threshold requirement: $result = \text{Some}(c) \implies$ at least $\lceil |cs| \times t \rceil$ commitments match $c$ (integer threshold)
- No consensus: $result = \text{None} \implies \nexists c \in cs: \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t$ (no commitment meets threshold)
- Minimum peers: $\text{FindConsensus}(cs, t)$ requires $|cs| \geq \text{min\_peers}$ (enough peers for consensus)
- Result type: $result \in \{\text{Some}(\mathcal{UC}), \text{None}\}$
- Threshold range: $\text{FindConsensus}(cs, t)$ requires $t \in [0, 1]$ (threshold must be valid probability)

For commitments $cs \in [\mathcal{UC}]$ and threshold $t \in [0,1]$:

$$\text{FindConsensus}(cs, t) = \begin{cases}
c & \text{if } \exists c \in cs: \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t \\
\text{None} & \text{otherwise}
\end{cases}$$

**VerifyConsensusCommitment**: $\mathcal{UC} \times [\mathcal{H}] \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- PoW verification: $result = \text{valid} \implies \text{VerifyPoW}(uc.\text{block\_hash}, hs) = \text{true}$ (PoW must be valid)
- Supply verification: $result = \text{valid} \implies \text{VerifySupply}(uc.\text{total\_supply}, uc.\text{block\_height}) = \text{true}$
- Non-empty headers: $|hs| = 0 \implies result = \text{invalid}$

**Note**: Header chain membership ($uc.\text{block\_hash} \in hs$) and cryptographic commitment validity are structural properties over set membership and cryptographic predicates — these require quantified set logic not expressible as Z3 arithmetic postconditions.

For commitment $uc$ and headers $hs$:

$$\text{VerifyConsensusCommitment}(uc, hs) = \begin{cases}
\text{valid} & \text{if } \text{VerifyPoW}(uc.\text{block\_hash}, hs) \land \\
& \quad \text{VerifySupply}(uc.\text{total\_supply}, uc.\text{block\_height}) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

**Theorem 11.4.1** (Consensus Threshold Correctness): Consensus threshold calculation using integer arithmetic is correct:

$$\forall cs \in [\mathcal{UC}], t \in [0,1]:$$
$$\text{FindConsensus}(cs, t) = c \iff \lceil |cs| \times t \rceil \text{ peers agree on } c$$

*Proof*: The threshold check uses integer arithmetic: $required = \lceil |cs| \times t \rceil$. If $agreement\_count \geq required$, then $agreement\_count / |cs| \geq t$ (within floating-point precision). This avoids floating-point precision issues and is proven by blvm-spec-lock formal verification.

**Integer Arithmetic for Threshold Calculations**: To avoid floating-point precision issues in consensus-critical calculations, we use integer arithmetic with ceiling operations. For threshold $t \in [0,1]$ and count $n \in \mathbb{N}$:

$$required = \lceil n \times t \rceil$$

**Theorem 11.4.2** (Integer Threshold Correctness): Integer threshold calculation correctly implements consensus thresholds:

$$\forall n \in \mathbb{N}, t \in [0,1]:$$
$$required = \lceil n \times t \rceil \implies \forall agreement \in \mathbb{N}:$$
$$(agreement \geq required \implies \frac{agreement}{n} \geq t - \epsilon) \land$$
$$(agreement < required \implies \frac{agreement}{n} < t + \epsilon)$$

Where $\epsilon$ is floating-point precision error (typically $< 10^{-15}$).

*Proof*: By properties of ceiling function and floating-point arithmetic. The integer calculation ensures we err on the side of requiring more agreement, which is safer for consensus. This is proven by blvm-spec-lock formal verification.

**Theorem 11.4.3** (Commitment Verification): UTXO commitments can be verified without full UTXO set:

$$\forall us \in \mathcal{US}, uc = \text{GenerateCommitment}(us, bh, h):$$
$$\text{VerifyCommitment}(uc, merkle\_proof, outpoint, utxo) = \text{valid}$$
$$\iff$$
$$utxo \in us \land us[\text{outpoint}] = utxo$$

*Proof*: By construction, the Merkle tree provides cryptographic commitment. A Merkle proof for a specific outpoint can verify inclusion without revealing the entire UTXO set.

### 11.5 Signet (BIP325)

Signet is a test network with an additional consensus parameter: the coinbase witness commitment must satisfy a challenge script. See BIP325.

**SignetChallenge**: $\text{Network} \rightarrow \mathbb{S}^?$

For each network $n$, $\text{SignetChallenge}(n) \in \mathbb{S} \cup \{\emptyset\}$. When $\text{SignetChallenge}(n) \neq \emptyset$, signet validation applies.

**CheckSignetBlockSolution**: $\mathcal{B} \times \text{Network} \rightarrow \{\text{valid}, \text{invalid}\}$

For block $b$ and network $n$:

$$\text{CheckSignetBlockSolution}(b, n) = \begin{cases}
\text{valid} & \text{if } \text{SignetChallenge}(n) = \emptyset \\
\text{valid} & \text{if } \text{SignetChallenge}(n) \neq \emptyset \land \text{WitnessCommitmentSatisfiesChallenge}(b, \text{SignetChallenge}(n)) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

**Witness commitment validation**: When $\text{SignetChallenge}(n) \neq \emptyset$, the block's coinbase witness commitment must commit to data that satisfies the challenge script (script is executed with witness commitment payload as input; must leave exactly one non-zero value on stack). Violation yields invalid block.

**Properties**:
- Boolean result: $result \in \{\text{valid}, \text{invalid}\}$
- No challenge always valid: $\text{SignetChallenge}(n) = \emptyset \implies result = \text{valid}$
- ConnectBlock precondition: $\text{ConnectBlock}(b, us, h) = \text{valid} \land \text{SignetChallenge}(n) \neq \emptyset \implies result = \text{valid}$

## 12. Mining Protocol

### 12.2 Coinbase Transaction

**Coinbase Transaction**: Special transaction with no inputs that creates new bitcoins

**CreateCoinbaseTransaction**: $\mathbb{N} \times \mathbb{Z} \times \mathbb{H} \times \mathbb{S} \rightarrow \mathcal{TX}$

Constructs a valid coinbase transaction for block at height $h$ with total fees $fees$, witness commitment hash $witness\_commitment$, and optional extra data $extra\_data$.

**Properties**:
- Defined: $\text{true}$

BIP34 requires the coinbase `scriptSig` to push the block height; see **Structure** and **Validation Rules** below. Full transaction equality for fixed arguments follows from the explicit field constraints above and the structural definition (a determinism obligation is not encoded as a separate **Property** because the current verifier cannot translate the coinbase constructor body).

**Structure**:
- **Input**: Single input with $prevout = \text{null}$, $scriptSig = \langle height, OP_0 \rangle$
- **Output**: Single output with $value = \text{GetBlockSubsidy}(height) + \text{totalFees}$
- **LockTime**: $nLockTime = height - 1$

**Validation Rules**:
1. **Height Encoding**: $scriptSig$ must encode current block height
2. **No Inputs**: Must have exactly one input with null $prevout$
3. **Value Limit**: $value \leq \text{GetBlockSubsidy}(height) + \text{totalFees}$
4. **LockTime**: Must equal $height - 1$

### 12.4 Block Template Interface

**BlockTemplate**: Interface for mining software

**Properties**:
- Coinbase first: returns a block with at least one transaction (coinbase must be first)
- Deterministic structure: Block structure follows deterministic rules (coinbase first, then mempool transactions)
- Non-empty: $result \in \{valid, invalid\}$

**Required Methods**:
- `getBlockHeader()`: Return block header for hashing
- `getBlock()`: Return complete block (with dummy coinbase)
- `getCoinbaseTx()`: Return actual coinbase transaction
- `getCoinbaseCommitment()`: Return witness commitment
- `submitSolution(version, timestamp, nonce, coinbase)`: Submit mining solution

**Consensus Requirements**:
1. **SegWit Support**: Must include witness commitment in coinbase
2. **Version Bits**: Must respect BIP9 deployment states
3. **Weight Limits**: Must not exceed $W_{max} = 4 \times 10^6$ weight units
4. **Transaction Selection**: Must respect mempool fee policies

## 13. Engineering-Specific Edge Cases

**PROTOCOL.md** states consensus rules mainly as mathematical predicates, types, and state transitions ([§2](#2-system-model)–[§12](#12-mining-protocol) and cross-referenced clauses). This section adds consensus-critical material not covered by those predicates alone: **engineering invariants** in [§13.3.1](#1331-integer-arithmetic-overflowunderflow)–[§13.3.4](#1334-parser-determinism) (checked arithmetic on amounts and fees, canonical serialization and decoding, exact resource-limit boundaries, and deterministic rejection of malformed data), each of which must align with observable mainnet behavior; and **cross-module integration properties** in [§13.3.5](#1335-integration-proofs). Implementations must satisfy this section as strictly as the rest of the specification so nodes do not diverge.

### 13.3 Engineering Invariants

Subsections **[13.3.1](#1331-integer-arithmetic-overflowunderflow)**–**[13.3.5](#1335-integration-proofs)** state engineering invariants and cross-module integration properties that implementations must satisfy together with the core protocol.

#### 13.3.1 Integer Arithmetic Overflow/Underflow

**Critical Requirement**: All monetary value arithmetic must use checked operations to prevent overflow/underflow.

**Edge Cases**:
1. **Value Summation**: Input/output value summation can overflow `i64::MAX` when combining many large UTXOs
2. **Fee Calculation**: `total_in - total_out` can underflow or overflow near boundaries
3. **Coinbase Value**: `subsidy + fees` can exceed `MAX_MONEY` if not checked
4. **Fee Accumulation**: Summing fees across block transactions can overflow

**Implementation**: Use `checked_add()` and `checked_sub()` for all value arithmetic. Satoshi-denominated amounts must follow the same overflow and range rules as the live network (typically a signed 64-bit money type with `MAX_MONEY` bounds).

**Formula** (**F_FeeArithmeticNonNeg**):
$$result \geq 0$$

For valid transactions with $total\_in \geq total\_out \geq 0$: fee $= total\_in - total\_out \geq 0$.

**Formula** (**F_FeeArithmeticBounded**):
$$result \leq total\_in$$

The computed fee is always bounded above by the total input value when $total\_in \geq total\_out \geq 0$.

#### 13.3.2 Serialization/Deserialization Correctness

**Critical Requirement**: Wire format must match the canonical P2P serialization observed on the network byte-for-byte.

**Edge Cases**:
1. **VarInt Encoding**: Boundary values (`0xfc`, `0xfd`, `0xfe`, `0xff`) must use correct encoding format
2. **Little-Endian**: All integers must be serialized as little-endian
3. **Block Header**: Must be exactly 80 bytes
4. **Transaction Format**: Must match the canonical transaction byte layout

**Implementation**: Consolidated serialization module with round-trip correctness guarantees, exercised by tests in the consensus implementation.

**Theorem 13.3.2.1** (Serialization Round-Trip Correctness): Serialization and deserialization are inverse operations:

$$\forall x \in \mathcal{D}: \text{deserialize}(\text{serialize}(x)) = x$$

Where $\mathcal{D}$ is the domain of serializable data structures (block headers, transactions, etc.).

*Proof*: By construction, the serialization format is designed to be lossless and reversible. All fields are encoded in a deterministic format that can be exactly reconstructed. This is proven by blvm-spec-lock formal verification.

**Theorem 13.3.2.2** (Serialization Determinism): Serialization is deterministic:

$$\forall x \in \mathcal{D}: \text{serialize}(x) \text{ is deterministic (same input always produces same output)}$$

*Proof*: The serialization process uses only the input data structure and deterministic encoding rules. There are no random elements or non-deterministic operations. This is proven by blvm-spec-lock formal verification.

#### 13.3.3 Resource Limit Enforcement

**Critical Requirement**: DoS protection limits must be enforced deterministically at exact boundaries.

**Edge Cases**:
1. **Script Operation Limit**: Exactly 201 operations must fail (limit check happens after increment)
2. **Stack Size Limit**: Exactly 1000 stack items must fail before next push
3. **Transaction Size**: Exactly 1,000,000 bytes must pass, 1,000,001 must fail
4. **Coinbase ScriptSig**: Must be exactly 2-100 bytes (boundary validation)

**Implementation**: All limits checked before resource exhaustion. Boundary behavior must match consensus on the live network exactly.

**Formula** (**F_CoinbaseScriptSigMin**):
$$result \geq 0$$

Headroom above the 2-byte minimum for a valid coinbase scriptSig: $result = len - 2 \geq 0$ when $len \geq 2$.

**Formula** (**F_CoinbaseScriptSigMax**):
$$result \geq 0$$

Distance below the 100-byte maximum for a valid coinbase scriptSig: $result = 100 - len \geq 0$ when $len \leq 100$.

**Formula** (**F_StackSizeSafe**):
$$result \geq 0$$

Stack headroom before the 1000-item limit: $result = 999 - depth \geq 0$ when $depth < 1000$.

#### 13.3.4 Parser Determinism

**Critical Requirement**: Malformed data must be rejected deterministically. All nodes must agree on invalid inputs.

**Edge Cases**:
1. **Truncated Data**: EOF at any point must be rejected with clear error
2. **Invalid Length Fields**: Length > remaining bytes, invalid VarInt encodings
3. **Malformed Structures**: Negative counts, maximum value abuse

**Implementation**: Wire-format parser with comprehensive error handling. Parser rejection behavior is covered by integration tests, for example [parser edge-case tests](https://github.com/BTCDecoded/blvm-consensus/blob/main/tests/engineering/parser_edge_cases.rs) in the `blvm-consensus` repository.

#### 13.3.5 Integration Proofs

Integration proofs verify that different consensus modules work together correctly, ensuring that cross-module interactions maintain mathematical correctness.

**Theorem 13.3.5.1** (BIP65/BIP112 Locktime Consistency): BIP65 (CLTV) and BIP112 (CSV) use shared locktime logic consistently:

$$\forall lt \in \mathbb{N}_{32}:$$
$$\text{DecodeLocktime}(\text{EncodeLocktime}(lt)) = lt \land$$
$$\text{LocktimeType}(lt) \text{ is consistent for CLTV and CSV}$$

*Proof*: Both BIP65 and BIP112 use the same locktime encoding/decoding and type determination functions. The shared implementation ensures consistency. This is proven by blvm-spec-lock formal verification.

**Formula** (**F_LocktimeTypeIsHeight**):
$$result \geq 0$$

Headroom below the block-height/timestamp boundary: $result = 500{,}000{,}000 - lt \geq 0$ when $lt < 500{,}000{,}000$. Establishes that a locktime value in the block-height range has non-negative distance from the threshold.

**Formula** (**F_LocktimeTypeIsTimestamp**):
$$result \geq 0$$

Excess above the block-height/timestamp boundary: $result = lt - 500{,}000{,}000 \geq 0$ when $lt \geq 500{,}000{,}000$. Establishes that a locktime value in the timestamp range has non-negative distance above the threshold.

**Theorem 13.3.5.2** (Locktime/Script Integration): Locktime validation integrates correctly with script execution:

$$\forall tx \in \mathcal{TX}, script \in \mathcal{SC}, lt \in \mathbb{N}_{32}:$$
$$\text{ExecuteScript}(script, tx, lt) \text{ uses consistent locktime validation}$$

*Proof*: Script execution uses the same locktime validation functions as standalone locktime checks, ensuring consistency between script-level and transaction-level locktime validation. This is proven by blvm-spec-lock formal verification.

**Theorem 13.3.5.3** (Economic/Block Integration): Economic rules integrate correctly with block validation:

$$\forall b \in \mathcal{B}, h \in \mathbb{N}:$$
$$\text{ConnectBlock}(b, us, h) \text{ enforces economic invariants (subsidy, fees, supply limits)}$$

*Proof*: Block connection validates economic rules (subsidy calculation, fee validation, supply limits) as part of the block validation process, ensuring economic correctness is maintained. This is proven by blvm-spec-lock formal verification.

#### 13.3.6 Spec-lock Formula Anchor Witness

Canonical **`Formula`** block for **named-formula** binding in **blvm-spec-lock**: downstream code may attach **`#[spec_locked("13.3", "F_SpecLockWitness")]`**, and **`cargo spec-lock verify`** (with **`--spec-path`** to this document) derives the obligation from the formula body below. The predicate is deliberately trivial (**Boolean truth**) so verification of the **`F_*`** anchor mechanism does not depend on the substantive consensus lemmas in §§13.3.1–13.3.5.

**Formula** (**F_SpecLockWitness**):

$$true$$
