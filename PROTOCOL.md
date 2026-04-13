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
5. [State Transition Functions](#5-state-transition-functions)
   - 5.1 [Transaction Validation](#51-transaction-validation)
   - 5.2 [Script Execution](#52-script-execution)
   - 5.3 [Block Validation](#53-block-validation)
     - 5.3.1 [Transaction Application Equivalence](#531-transaction-application-equivalence)
   - 5.4 [BIP Validation Rules](#54-bip-validation-rules)
     - 5.4.1 [BIP30: Duplicate Coinbase Prevention](#541-bip30-duplicate-coinbase-prevention)
     - 5.4.2 [BIP34: Block Height in Coinbase](#542-bip34-block-height-in-coinbase)
     - 5.4.3 [BIP66: Strict DER Signatures](#543-bip66-strict-der-signatures)
     - 5.4.4 [BIP90: Block Version Enforcement](#544-bip90-block-version-enforcement)
     - 5.4.5 [BIP147: NULLDUMMY Enforcement](#545-bip147-nulldummy-enforcement)
     - 5.4.6 [BIP119: OP_CHECKTEMPLATEVERIFY (CTV)](#546-bip119-opchecktemplateverify-ctv)
     - 5.4.7 [BIP65: OP_CHECKLOCKTIMEVERIFY (CLTV)](#547-bip65-opchecklocktimeverify-cltv)
     - 5.4.8 [BIP348: OP_CHECKSIGFROMSTACK (CSFS)](#548-bip348-opchecksigfromstack-csfs)
     - 5.4.9 [BIP54: Consensus Cleanup](#549-bip54-consensus-cleanup)
   - 5.5 [Sequence Locks (BIP68)](#55-sequence-locks-bip68)
6. [Economic Model](#6-economic-model)
   - 6.1 [Block Subsidy](#61-block-subsidy)
   - 6.2 [Total Supply](#62-total-supply)
   - 6.3 [Fee Market](#63-fee-market)
7. [Proof of Work](#7-proof-of-work)
   - 7.1 [Difficulty Adjustment](#71-difficulty-adjustment)
   - 7.2 [Block Validation](#72-block-validation)
8. [Security Properties](#8-security-properties)
   - 8.1 [Economic Security](#81-economic-security)
   - 8.2 [Cryptographic Security](#82-cryptographic-security)
   - 8.3 [Merkle Tree Security](#83-merkle-tree-security)
   - 8.4 [Deterministic Properties](#84-deterministic-properties)
9. [Mempool Protocol](#9-mempool-protocol)
   - 9.1 [Mempool Validation](#91-mempool-validation)
   - 9.2 [Standard Transaction Rules](#92-standard-transaction-rules)
   - 9.3 [Replace-By-Fee (RBF)](#93-replace-by-fee-rbf)
10. [Network Protocol](#10-network-protocol)
    - 10.1 [Message Types](#101-message-types)
    - 10.2 [Connection Management](#102-connection-management)
    - 10.3 [Peer Discovery](#103-peer-discovery)
    - 10.4 [Block Synchronization](#104-block-synchronization)
    - 10.5 [Transaction Relay](#105-transaction-relay)
11. [Advanced Features](#11-advanced-features)
    - 11.1 [Segregated Witness (SegWit)](#111-segregated-witness-segwit)
    - 11.2 [Taproot](#112-taproot)
    - 11.3 [Chain Reorganization](#113-chain-reorganization)
      - 11.3.1 [Undo Log Pattern](#1131-undo-log-pattern)
    - 11.4 [UTXO Commitments](#114-utxo-commitments)
    - 11.5 [Signet (BIP325)](#115-signet-bip325)
12. [Mining Protocol](#12-mining-protocol)
    - 12.1 [Block Template Generation](#121-block-template-generation)
    - 12.2 [Coinbase Transaction](#122-coinbase-transaction)
    - 12.3 [Mining Process](#123-mining-process)
    - 12.4 [Block Template Interface](#124-block-template-interface)
13. [Engineering-Specific Edge Cases](#13-engineering-specific-edge-cases)

## 1. Introduction

Bitcoin is a distributed consensus system that maintains a shared ledger of transactions without requiring trusted intermediaries. The system achieves consensus through proof-of-work and enforces economic rules through cryptographic validation. This paper provides a complete mathematical description of how Bitcoin operates.

### 1.1 Key Contributions

- **Complete State Machine**: Formal specification of Bitcoin's state transitions
- **Economic Model**: Mathematical description of the monetary system
- **Validation Rules**: Precise definition of all consensus-critical checks
- **Security Properties**: Formal statements of Bitcoin's security guarantees

### 1.2 Document Structure

This specification is organized into four main parts:

1. **Foundations** (Sections 2-4): Mathematical foundations, data structures, and constants
2. **Core Protocol** (Sections 5-8): State transitions, economic model, proof-of-work, and security
3. **Network Layer** (Sections 9-11): Mempool, P2P protocol, and advanced features
4. **Mining Protocol** (Section 12): Block creation and mining process

Each section builds upon previous sections, with cross-references to maintain consistency.

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

**References:** BIP94 (timewarp mitigation), BIP325 (signet), §5.2.5 (script flags), §7.1 (difficulty).

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

### 3.2 Core Data Structures

**OutPoint**: $\mathcal{O} = \mathbb{H} \times \mathbb{N}$ (see [Transaction Input](#transaction-input), [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product))  
**Transaction Input**: $\mathcal{I} = \mathcal{O} \times \mathbb{S} \times \mathbb{N}$ (see [Script System](#script-system))  
**Transaction Output**: $\mathcal{T} = \mathbb{Z} \times \mathbb{S}$ (see [Monetary Values](#monetary-constants))  
**Transaction**: $\mathcal{TX} = \mathbb{N} \times \mathcal{I}^* \times \mathcal{T}^* \times \mathbb{N}$ (see [Transaction Validation](#51-transaction-validation), [Kleene star](https://en.wikipedia.org/wiki/Kleene_star))  
**Block Header**: $\mathcal{H} = \mathbb{Z} \times \mathbb{H} \times \mathbb{H} \times \mathbb{N} \times \mathbb{N} \times \mathbb{N}$ (see [Block Validation](#53-block-validation))  
**Block**: $\mathcal{B} = \mathcal{H} \times \mathcal{TX}^*$ (see [Block Validation](#53-block-validation))  
**UTXO**: $\mathcal{U} = \mathbb{Z} \times \mathbb{S} \times \mathbb{N}$ (see [UTXO Set Invariant](#theorem-81))  
**UTXO Set**: $\mathcal{US} = \mathcal{O} \rightarrow \mathcal{U}$ (see [State Transition Functions](#5-state-transition-functions), [function type](https://en.wikipedia.org/wiki/Function_type))

### 3.3 Script System

**Script**: $\mathcal{SC} = \mathbb{S}$ (sequence of [opcodes](https://en.bitcoin.it/wiki/Script))  
**Witness**: $\mathcal{W} = \mathbb{S}^*$ (stack of [witness data](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki))  
**Stack**: $\mathcal{ST} = \mathbb{S}^*$ (execution stack, see [Script Execution](#52-script-execution))

## 4. Consensus Constants

### 4.1 Monetary Constants

$C = 10^8$ (satoshis per BTC, see [Economic Model](#6-economic-model))  
$M_{max} = 21 \times 10^6 \times C$ (maximum money supply, see [Supply Limit](#supply-limit))  
$H = 210,000$ (halving interval, see [Block Subsidy](#61-block-subsidy))

### 4.2 Block Constants

$W_{max} = 4 \times 10^6$ (maximum block weight, see [Block Validation](#53-block-validation))  
$S_{max} = 80,000$ (maximum sigops per block, see [Script Execution](#52-script-execution))  
$R = 100$ (coinbase maturity requirement, see [Transaction Validation](#51-transaction-validation))

### 4.3 Script Constants

$L_{script} = 10,000$ (maximum script length, see [Script Security](#script-security))  
$L_{stack} = 1,000$ (maximum stack size, see [Script Execution Bounds](#theorem-84))  
$L_{ops} = 201$ (maximum operations per script, see [Script Execution Bounds](#theorem-84))  
$L_{element} = 520$ (maximum element size, see [Script Execution](#52-script-execution))

### 4.4 Difficulty Constants

$D_{interval} = 2016$ (blocks per difficulty adjustment period, see [Difficulty Adjustment](#71-difficulty-adjustment))  
$T_{block} = 600$ (target block time in seconds, 10 minutes)  
$T_{future} = 7200$ (maximum allowed block time in future, 2 hours, see [Block Validation](#53-block-validation))

## 5. State Transition Functions

### 5.1 Transaction Validation

**CheckTransaction**: $\mathcal{TX} \rightarrow \{\text{valid}, \text{invalid}\}$

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
- Structure validation: $\text{CheckTransaction}(tx) = \text{valid} \implies |tx.\text{inputs}| > 0 \land |tx.\text{outputs}| > 0$
- Input bounds: $\text{CheckTransaction}(tx) = \text{valid} \implies |tx.\text{inputs}| \leq M_{\text{max\_inputs}}$
- Output bounds: $\text{CheckTransaction}(tx) = \text{valid} \implies |tx.\text{outputs}| \leq M_{\text{max\_outputs}}$
- Empty rejection: $|tx.\text{inputs}| = 0 \lor |tx.\text{outputs}| = 0 \implies \text{CheckTransaction}(tx) \neq \text{valid}$
- Output value bounds: $\text{CheckTransaction}(tx) = \text{valid} \implies \forall o \in tx.\text{outputs}: 0 \leq o.\text{value} \leq M_{\text{max}}$
- Total output sum: $\text{CheckTransaction}(tx) = \text{valid} \implies \sum_{o \in tx.\text{outputs}} o.\text{value} \leq M_{\text{max}}$
- No duplicate prevouts: $\text{CheckTransaction}(tx) = \text{valid} \implies \forall i,j \in tx.\text{inputs}: i \neq j \implies i.\text{prevout} \neq j.\text{prevout}$
- Coinbase scriptSig length: $\text{CheckTransaction}(tx) = \text{valid} \land \text{IsCoinbase}(tx) \implies 2 \leq |tx.\text{inputs}[0].\text{scriptSig}| \leq 100$
- Non-coinbase prevout: $\text{CheckTransaction}(tx) = \text{valid} \land \neg \text{IsCoinbase}(tx) \implies \forall i \in tx.\text{inputs}: \neg i.\text{prevout}.\text{IsNull}()$
- Deterministic: $\text{CheckTransaction}(tx_1) = \text{CheckTransaction}(tx_2) \iff tx_1 = tx_2$ (same transaction → same result)
- Result type: $\text{CheckTransaction}(tx) \in \{\text{valid}, \text{invalid}\}$

**CheckTxInputs**: $\mathcal{TX} \times \mathcal{US} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\} \times \mathbb{Z}$

**Properties**:
- Coinbase fee: $\text{IsCoinbase}(tx) = \text{true} \implies \text{CheckTxInputs}(tx, us, h) = (\text{valid}, 0)$
- Value conservation: $\text{CheckTxInputs}(tx, us, h) = (\text{valid}, fee) \land \neg \text{IsCoinbase}(tx) \implies \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} = \sum_{o \in tx.\text{outputs}} o.\text{value} + fee$
- Fee calculation: $\text{CheckTxInputs}(tx, us, h) = (\text{valid}, fee) \land \neg \text{IsCoinbase}(tx) \implies fee = \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Non-negative fee: $\text{CheckTxInputs}(tx, us, h) = (\text{valid}, fee) \implies fee \geq 0$
- Insufficient funds: $\text{CheckTxInputs}(tx, us, h) = (\text{invalid}, 0) \land \neg \text{IsCoinbase}(tx) \implies \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} < \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Deterministic: $\text{CheckTxInputs}(tx_1, us_1, h_1) = \text{CheckTxInputs}(tx_2, us_2, h_2) \iff tx_1 = tx_2 \land us_1 = us_2 \land h_1 = h_2$
- Result type: $\text{CheckTxInputs}(tx, us, h) \in \{(\text{valid}, \mathbb{Z}), (\text{invalid}, 0)\}$

$$\text{CheckTxInputs}(tx, us, h) = \begin{cases}
(\text{valid}, 0) & \text{if } \text{IsCoinbase}(tx) \\
(\text{invalid}, 0) & \text{if } \neg\text{IsCoinbase}(tx) \land \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} < \sum_{o \in tx.\text{outputs}} o.\text{value} \\
(\text{valid}, \text{fee}) & \text{otherwise}
\end{cases}$$

Where $\text{fee} \coloneqq \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$.

#### 5.1.1 Transaction Sighash Calculation

**CalculateSighash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \text{SighashType} \times \mathbb{N} \rightarrow \mathbb{H}$

**Properties**:
- Hash length: $\text{CalculateSighash}(tx, i, us, st, h) = h \implies |h| = 32$ (32-byte hash)
- Input index requirement: $\text{CalculateSighash}(tx, i, us, st, h)$ requires $i < |tx.inputs|$ (valid input index)
- Deterministic: $\text{CalculateSighash}(tx_1, i_1, us_1, st_1, h_1) = \text{CalculateSighash}(tx_2, i_2, us_2, st_2, h_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land us_1 = us_2 \land st_1 = st_2 \land h_1 = h_2$

For transaction $tx$, input index $i$, UTXO set $us$, sighash type $st$, and height $h$:

$$\text{CalculateSighash}(tx, i, us, st, h) = \text{SHA256}(\text{SHA256}(\text{SighashPreimage}(tx, i, us, st, h)))$$

**SighashScriptCode**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \rightarrow \mathbb{S}$

**Properties**:
- P2SH handling: $\text{SighashScriptCode}(tx, i, us) = \text{RedeemScript}(tx, i) \iff \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (P2SH uses redeem script)
- Non-P2SH handling: $\text{SighashScriptCode}(tx, i, us) = us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} \iff \neg \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (non-P2SH uses scriptPubkey)
- Input index requirement: $\text{SighashScriptCode}(tx, i, us)$ requires $i < |tx.\text{inputs}|$ (valid input index)
- UTXO existence: $\text{SighashScriptCode}(tx, i, us)$ requires $tx.\text{inputs}[i].\text{prevout} \in us$ (UTXO must exist)
- Deterministic: $\text{SighashScriptCode}(tx_1, i_1, us_1) = \text{SighashScriptCode}(tx_2, i_2, us_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land us_1 = us_2$
- Codomain: $\text{SighashScriptCode}(tx, i, us) \in \mathbb{S}$

For transaction $tx$, input index $i$, and UTXO set $us$:

$$\text{SighashScriptCode}(tx, i, us) = \begin{cases}
\text{RedeemScript}(tx, i) & \text{if } \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey}) \\
us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} & \text{otherwise}
\end{cases}$$

Where $\text{RedeemScript}(tx, i)$ is the redeem script extracted from the stack after executing scriptSig for input $i$.

**FindAndDelete**: $\mathbb{S} \times \mathbb{S} \rightarrow \mathbb{S}$

**Properties**:
- Pattern removal: $\text{FindAndDelete}(script, pattern) = script' \implies$ all occurrences of $pattern$ removed from $script$
- Empty pattern: $|pattern| = 0 \implies \text{FindAndDelete}(script, pattern) = script$ (no-op for empty pattern)
- Pattern length: $|pattern| > |script| \implies \text{FindAndDelete}(script, pattern) = script$ (pattern too long)
- Opcode boundary preservation: $\text{FindAndDelete}(script, pattern)$ preserves opcode boundaries (does not split opcodes)
- Deterministic: $\text{FindAndDelete}(script_1, pattern_1) = \text{FindAndDelete}(script_2, pattern_2) \iff script_1 = script_2 \land pattern_1 = pattern_2$

For script $script \in \mathbb{S}$ and pattern $pattern \in \mathbb{S}$:

$$\text{FindAndDelete}(script, pattern) = \begin{cases}
script & \text{if } |pattern| = 0 \lor |pattern| > |script| \\
\text{RemoveAll}(script, pattern) & \text{otherwise}
\end{cases}$$

Where $\text{RemoveAll}(script, pattern)$ removes all occurrences of $pattern$ from $script$ while preserving opcode boundaries.

**SighashScriptCode** (Updated): $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \text{SigVersion} \times \mathbb{S} \rightarrow \mathbb{S}$

**Properties** (Updated):
- P2SH handling: $\text{SighashScriptCode}(tx, i, us, sv, sig) = \text{RedeemScript}(tx, i) \iff \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (P2SH uses redeem script)
- Non-P2SH handling: $\text{SighashScriptCode}(tx, i, us, sv, sig) = us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey} \iff \neg \text{IsP2SH}(us(tx.\text{inputs}[i].\text{prevout}).\text{scriptPubkey})$ (non-P2SH uses scriptPubkey)
- FindAndDelete application: $\text{SigVersion} = \text{Base} \land \text{IsSignatureOpcode}(opcode) \implies \text{SighashScriptCode}(tx, i, us, sv, sig) = \text{FindAndDelete}(\text{BaseScriptCode}(tx, i, us), \text{SerializePush}(sig))$
- SegWit exclusion: $\text{SigVersion} = \text{WitnessV0} \lor \text{SigVersion} = \text{Tapscript} \implies \text{FindAndDelete}$ not applied
- Legacy requirement: FindAndDelete applies only to legacy scripts (SigVersion::Base) for OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, and OP_CHECKMULTISIGVERIFY
- Input index requirement: $\text{SighashScriptCode}(tx, i, us, sv, sig)$ requires $i < |tx.\text{inputs}|$ (valid input index)
- UTXO existence: $\text{SighashScriptCode}(tx, i, us, sv, sig)$ requires $tx.\text{inputs}[i].\text{prevout} \in us$ (UTXO must exist)
- Deterministic: $\text{SighashScriptCode}(tx_1, i_1, us_1, sv_1, sig_1) = \text{SighashScriptCode}(tx_2, i_2, us_2, sv_2, sig_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land us_1 = us_2 \land sv_1 = sv_2 \land sig_1 = sig_2$
- Result type: $\text{SighashScriptCode}(tx, i, us, sv, sig) \in \mathbb{S}$

For transaction $tx$, input index $i$, UTXO set $us$, signature version $sv$, and signature $sig$:

$$\text{SighashScriptCode}(tx, i, us, sv, sig) = \begin{cases}
\text{FindAndDelete}(\text{BaseScriptCode}(tx, i, us), \text{SerializePush}(sig)) & \text{if } sv = \text{Base} \land \text{IsSignatureOpcode}(opcode) \\
\text{BaseScriptCode}(tx, i, us) & \text{otherwise}
\end{cases}$$

Where:
- $\text{BaseScriptCode}(tx, i, us)$ is the base script code (redeem script for P2SH, scriptPubkey otherwise)
- $\text{SerializePush}(sig)$ is the serialized push operation for signature $sig$
- $\text{IsSignatureOpcode}(op) \iff op \in \{0x\text{ac}, 0x\text{ad}, 0x\text{ae}, 0x\text{af}\}$ (OP_CHECKSIG, OP_CHECKSIGVERIFY, OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY)

**SighashType**: $\mathbb{N}_{8} \times \mathbb{N} \rightarrow \text{SighashType}$

**Properties**:
- BIP66 legacy handling: $\text{SighashType}(0x00, h) = \text{AllLegacy} \iff h < H_{66}$ (legacy 0x00 only before BIP66)
- Standard types: $\text{SighashType}(byte, h) \in \{\text{All}, \text{None}, \text{Single}\} \iff byte \in \{0x01, 0x02, 0x03\}$ (standard types)
- AnyoneCanPay flag: $\text{SighashType}(byte, h) \text{ has AnyoneCanPay flag } \iff byte \in \{0x81, 0x82, 0x83\}$ (AnyoneCanPay types)
- Invalid handling: $\text{SighashType}(byte, h) = \text{Invalid} \iff byte \notin \{0x00, 0x01, 0x02, 0x03, 0x81, 0x82, 0x83\} \lor (byte = 0x00 \land h \geq H_{66})$ (invalid bytes or post-BIP66 0x00)
- Deterministic: $\text{SighashType}(byte_1, h_1) = \text{SighashType}(byte_2, h_2) \iff byte_1 = byte_2 \land h_1 = h_2$
- Result type: $\text{SighashType}(byte, h) \in \{\text{AllLegacy}, \text{All}, \text{None}, \text{Single}, \text{All} \mid \text{AnyoneCanPay}, \text{None} \mid \text{AnyoneCanPay}, \text{Single} \mid \text{AnyoneCanPay}, \text{Invalid}\}$

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

### 5.2 Script Execution

Bitcoin uses a stack-based scripting language for transaction validation. Scripts are executed to determine whether a transaction output can be spent.

**EvalScript**: $\mathcal{SC} \times \mathcal{ST} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

$\text{EvalScript}(script, S_0, f) = \text{true}$ iff execution terminates without failure and the final stack $S_f$ satisfies $|S_f| = 1 \land S_f[0] \neq 0$.

Execution fails (yielding $\text{false}$) iff at any step:
- $\text{StackOverflow}(S)$: $|S| > L_{stack}$, or
- $\text{OpLimitExceeded}(c)$: operation count $c > L_{ops}$, or
- $\text{OpcodeFails}(op, S)$: execution of $op$ on stack $S$ fails.

Formally: $\text{EvalScript}(script, S_0, f) = \text{false} \iff \text{Execute}(script, S_0, f) \downarrow \land (\text{Overflow} \lor \text{OverOps} \lor \text{OpFail})$, where $\downarrow$ indicates termination and the disjunction holds at some step.

**Properties**:
- Success condition: $\text{EvalScript}(script, stack, flags) = \text{true} \iff |stack| = 1 \land stack[0] \neq 0$
- Stack bounds: $\text{EvalScript}(script, stack, flags) \implies |stack| + |altstack| \leq L_{\text{stack}}$ (combined stack and altstack never exceed maximum size)
- Empty script: $|script| = 0 \implies \text{EvalScript}(script, stack, flags) = \text{false}$ (empty script always fails)
- Operation limit: $\text{EvalScript}(script, stack, flags)$ fails if operation count exceeds $L_{\text{ops}}$
- Stack overflow: If $|stack| + |altstack| > L_{\text{stack}}$ during execution, $\text{EvalScript}(script, stack, flags) = \text{false}$
- Boolean result: $\text{EvalScript}(script, stack, flags) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{EvalScript}(script_1, stack_1, flags_1) = \text{EvalScript}(script_2, stack_2, flags_2) \iff script_1 = script_2 \land stack_1 = stack_2 \land flags_1 = flags_2$
- Stack preservation: During execution, combined stack and altstack size is bounded by $L_{\text{stack}}$
- Failure modes: $\text{EvalScript}(script, stack, flags) = \text{false}$ if stack overflow, operation limit exceeded, or opcode execution fails

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
- Script verification correctness: $\text{VerifyScript}(ss, spk, w, f) = \text{true} \iff$ script execution succeeds with final stack having exactly one true value
- P2SH validation: $(f \land 0x01) \neq 0 \land \text{IsP2SH}(spk) \implies \text{P2SHPushOnlyCheck}(ss)$ must be valid
- Boolean result: $\text{VerifyScript}(ss, spk, w, f) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{VerifyScript}(ss_1, spk_1, w_1, f_1) = \text{VerifyScript}(ss_2, spk_2, w_2, f_2) \iff ss_1 = ss_2 \land spk_1 = spk_2 \land w_1 = w_2 \land f_1 = f_2$
- Execution order: $\text{VerifyScript}(ss, spk, w, f)$ executes $ss$ first, then $spk$, then $w$ if present
- Stack initialization: $\text{VerifyScript}(ss, spk, w, f)$ starts with empty stack for $ss$ execution
- Final stack condition: $\text{VerifyScript}(ss, spk, w, f) = \text{true} \implies$ final stack has exactly one non-zero element

**VerifyScript**: $\mathcal{SC} \times \mathcal{SC} \times \mathcal{W} \times \mathbb{N} \rightarrow \{\text{true}, \text{false}\}$

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
- Deterministic: $\text{P2SHPushOnlyCheck}(ss_1) = \text{P2SHPushOnlyCheck}(ss_2) \iff ss_1 = ss_2$
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
- Sigop count bounded: $\text{CountSigOpsInScript}(s, a) \leq |s|$ for all scripts $s$
- Non-negativity: $\text{CountSigOpsInScript}(s, a) \geq 0$ for all scripts $s$
- Empty script: $\text{CountSigOpsInScript}(\emptyset, a) = 0$

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
- Non-negativity: $\text{GetLegacySigOpCount}(tx) \geq 0$ for all transactions $tx$
- Coinbase sigops: $\text{IsCoinbase}(tx) = \text{true} \implies \text{GetLegacySigOpCount}(tx) \geq 0$ (coinbase may have sigops in scriptSig)

For transaction $tx$:

$$\text{GetLegacySigOpCount}(tx) = \sum_{i \in tx.\text{inputs}} \text{CountSigOpsInScript}(i.\text{scriptSig}, \text{false}) + \sum_{o \in tx.\text{outputs}} \text{CountSigOpsInScript}(o.\text{scriptPubkey}, \text{false})$$

**GetP2SHSigOpCount**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{N}$

**Properties**:
- Coinbase zero: $\text{IsCoinbase}(tx) = \text{true} \implies \text{GetP2SHSigOpCount}(tx, us) = 0$
- Non-negativity: $\text{GetP2SHSigOpCount}(tx, us) \geq 0$ for all transactions $tx$ and UTXO sets $us$
- P2SH only: $\text{GetP2SHSigOpCount}(tx, us) > 0 \implies \exists i \in tx.inputs: \text{IsP2SH}(us(i.prevout).scriptPubkey)$

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
- Non-negativity: $\text{GetTransactionSigOpCost}(tx, us, w, f) \geq 0$ for all valid inputs
- Cost formula: $\text{GetTransactionSigOpCost}(tx, us, w, f) = \text{GetLegacySigOpCount}(tx) \times 4 + \text{GetP2SHSigOpCount}(tx, us) \times 4 \times \text{IsP2SHEnabled}(f) + \text{CountWitnessSigOps}(tx, w, us, f)$
- Block limit: $\sum_{tx \in block.transactions} \text{GetTransactionSigOpCost}(tx, us, w, f) \leq M_{\text{max\_block\_sigops}}$ for valid blocks

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

#### 5.2.5 Script Verification Flags

**CalculateScriptFlags**: $\mathcal{TX} \times \mathcal{W}^? \times \mathbb{N} \times \text{Network} \rightarrow \mathbb{N}_{32}$

**Properties**:
- Flag activation: $\text{CalculateScriptFlags}(tx, w, h, n) = f \implies \forall flag \in f: h \geq H_{flag}(n)$
- Per-transaction calculation: $\text{CalculateScriptFlags}(tx_1, w_1, h, n) \neq \text{CalculateScriptFlags}(tx_2, w_2, h, n)$ (may differ for different transactions)
- Flag monotonicity: $h_1 \leq h_2 \implies \text{CalculateScriptFlags}(tx, w, h_1, n) \subseteq \text{CalculateScriptFlags}(tx, w, h_2, n)$

For transaction $tx$, witness $w$, height $h$, and network $n$:

$$\text{CalculateScriptFlags}(tx, w, h, n) = \bigcup_{flag \in \text{ActiveFlags}(tx, w, h, n)} flag$$

Where $\text{ActiveFlags}(tx, w, h, n) \subseteq \text{AllFlags}$ is the set of flags active for $(tx, w)$ at height $h$ on network $n$:

$$\text{ActiveFlags}(tx, w, h, n) = \{f : f \in \text{AllFlags} \land \text{IsFlagActive}(f, tx, w, h, n)\}$$

**Flag Activation**: $\text{IsFlagActive}(f, tx, w, h, n) = (h \geq H_f(n)) \land \text{FlagCondition}(f, tx, w)$

Where:
- $H_f(n)$ is the activation height for flag $f$ on network $n$
- $\text{FlagCondition}(f, tx, w)$ is the transaction-specific condition for flag $f$

**Consensus vs relay**: Many nodes apply **SCRIPT_VERIFY_STRICTENC** and **SCRIPT_VERIFY_LOW_S** only as **mempool / relay (standardness)** rules. For **block connection**, the consensus script flags OR in **SCRIPT_VERIFY_DERSIG** at BIP66 height, not `STRICTENC` or `LOW_S`. Mainnet may therefore contain **post-BIP66** confirmed transactions whose ECDSA signatures are strictly DER (required by **DERSIG**) but are not low-$S$; consensus still accepts them. This specification states **consensus** behavior; **relay** policy remains implementation-defined (including $\text{AcceptToMemoryPool}$-class admission rules).

**Flag Definitions**:
- **SCRIPT_VERIFY_P2SH** ($f = 0x01$): $H_f(\text{mainnet}) = 173,805$, $\text{FlagCondition} = \text{true}$ (always active after activation)
- **SCRIPT_VERIFY_STRICTENC** ($f = 0x02$): **Relay / standardness** (not added by consensus block script-flag height gating at BIP66). $\text{FlagCondition}$ and activation for blocks: **not applicable** to $\text{ConnectBlock}$ parity.
- **SCRIPT_VERIFY_DERSIG** ($f = 0x04$): $H_f(\text{mainnet}) = 363,725$ (BIP66), $\text{FlagCondition} = \text{true}$. **Consensus** base flag after activation (strict DER encodings for ECDSA signatures in executed scripts).
- **SCRIPT_VERIFY_LOW_S** ($f = 0x08$): **Relay / standardness** (not added by consensus block script-flag height gating at BIP66). $\text{FlagCondition}$ for blocks: **not applicable** to $\text{ConnectBlock}$ parity.
- **SCRIPT_VERIFY_NULLDUMMY** ($f = 0x10$): $H_f(\text{mainnet}) = 481,824$ (BIP147), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY** ($f = 0x200$): $H_f(\text{mainnet}) = 388,381$ (BIP65), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_CHECKSEQUENCEVERIFY** ($f = 0x400$): $H_f(\text{mainnet}) = 419,328$ (BIP112 / BIP9 `csv` deployment on mainnet), $\text{FlagCondition} = \text{true}$
- **SCRIPT_VERIFY_WITNESS** ($f = 0x800$): $H_f(\text{mainnet}) = 481,824$ (SegWit), $\text{FlagCondition} = (w \neq \emptyset \lor \text{IsSegWitTransaction}(tx))$
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

For each network $n$, $\text{ScriptFlagExceptions}(n)$ is a partial map from block hash to override flags. When validating transactions in block $b$, if $\text{hash}(b) \in \text{dom}(\text{ScriptFlagExceptions}(n))$, use the override; otherwise use $\text{CalculateScriptFlags}(tx, w, h, n)$.

**GetBlockScriptFlags**: $\mathbb{H} \times \mathcal{TX} \times \mathcal{W}^? \times \mathbb{N} \times \text{Network} \rightarrow \mathbb{N}_{32}$

$$\text{GetBlockScriptFlags}(h_b, tx, w, h, n) = \begin{cases}
\text{ScriptFlagExceptions}(n)(h_b) & \text{if } h_b \in \text{dom}(\text{ScriptFlagExceptions}(n)) \\
\text{CalculateScriptFlags}(tx, w, h, n) & \text{otherwise}
\end{cases}$$

Where $h_b = \text{hash}(b)$ is the block hash. Mainnet has 2 exceptions (BIP16, Taproot); testnet has 1 (BIP16). See §2.2.1.

### 5.3 Block Validation

**ConnectBlock**: $\mathcal{B} \times \mathcal{US} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\} \times \mathcal{US}$

**Properties**:
- Block structure: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies |b.transactions| > 0$ (block must have transactions)
- Coinbase requirement: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies \text{IsCoinbase}(b.transactions[0]) = \text{true}$ (first transaction must be coinbase)
- UTXO consistency: $\text{ConnectBlock}(b, us, height) = (\text{valid}, us') \implies$ UTXO set $us'$ reflects all transactions in block $b$
- Transaction validation: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies \forall tx \in b.transactions : \text{CheckTransaction}(tx) = \text{valid}$
- Input validation: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies \forall tx \in b.transactions : \text{CheckTxInputs}(tx, us, height) = (\text{valid}, fee)$
- Script verification: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies \forall tx \in b.transactions :$ all scripts verify successfully
- Coinbase fee: $\text{ConnectBlock}(b, us, height) = \text{valid} \implies$ coinbase output $\leq$ fees + subsidy
- Result type: $\text{ConnectBlock}(b, us, height) \in \{(\text{valid}, \mathcal{US}), (\text{invalid}, \mathcal{US})\}$
- Deterministic: $\text{ConnectBlock}(b_1, us_1, height_1) = \text{ConnectBlock}(b_2, us_2, height_2) \iff b_1 = b_2 \land us_1 = us_2 \land height_1 = height_2$
- UTXO set growth: $\text{ConnectBlock}(b, us, height) = (\text{valid}, us') \implies |us'| = |us| - \sum_{tx \in b.transactions, \neg \text{IsCoinbase}(tx)} |tx.inputs| + \sum_{tx \in b.transactions} |tx.outputs|$

For block $b = (h, txs)$ with UTXO set $us$ at height $height$:

#### 5.3.1 Transaction Application Equivalence

**Theorem 5.3.1** (ApplyTransaction Equivalence): The functions `apply_transaction` and `apply_transaction_with_id` produce identical results:

$$\forall tx \in \mathcal{TX}, us \in \mathcal{US}, h \in \mathbb{N}:$$
$$\text{ApplyTransaction}(tx, us, h) = \text{ApplyTransactionWithId}(tx, \text{CalculateTxId}(tx), us, h)$$

*Proof*: Both functions apply identical UTXO set transformations. The sole difference is the source of the transaction identifier: $\text{ApplyTransaction}$ computes $\text{CalculateTxId}(tx)$ internally, while $\text{ApplyTransactionWithId}$ accepts it as argument. The outputs are identical by structural induction on the transaction application steps.

**Corollary 5.3.1.1**: Transaction application is deterministic and side-effect-free, regardless of which function is used.

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
- Undo entries match inputs: $\text{ApplyTransaction}(tx, us) = (us', ul) \implies |ul| = |tx.inputs|$ (undo log has one entry per input)
- Coinbase undo: $\text{IsCoinbase}(tx) = \text{true} \implies \text{ApplyTransaction}(tx, us) = (us', \emptyset)$ (coinbase has no undo entries)
- UTXO consistency: $\text{ApplyTransaction}(tx, us) = (us', ul) \implies$ UTXO set $us'$ reflects transaction $tx$ applied to $us$
- Spent inputs removed: $\text{ApplyTransaction}(tx, us) = (us', ul) \land \neg \text{IsCoinbase}(tx) \implies \forall i \in tx.inputs : i.prevout \notin us'$ (spent inputs removed)
- Outputs added: $\text{ApplyTransaction}(tx, us) = (us', ul) \implies \forall i \in [0, |tx.outputs|) : (tx.id, i) \in us'$ (all outputs added)
- UTXO set size: $\text{ApplyTransaction}(tx, us) = (us', ul) \land \neg \text{IsCoinbase}(tx) \implies |us'| = |us| - |tx.inputs| + |tx.outputs|$
- Coinbase UTXO set size: $\text{ApplyTransaction}(tx, us) = (us', ul) \land \text{IsCoinbase}(tx) \implies |us'| = |us| + |tx.outputs|$
- Deterministic: $\text{ApplyTransaction}(tx_1, us_1) = \text{ApplyTransaction}(tx_2, us_2) \iff tx_1 = tx_2 \land us_1 = us_2$
- Idempotency with undo: $\text{DisconnectBlock}(b, ul, \text{ConnectBlock}(b, us, h)) = us$ where $ul$ is undo log from ConnectBlock

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
- Deactivation height: $\text{BIP30Check}(b, us, h, n) = \text{valid} \implies h > H_{30\_deact}(n)$ (after deactivation, always valid)
- Duplicate coinbase prevention: $\text{BIP30Check}(b, us, h, n) = \text{invalid} \implies$ duplicate coinbase transaction detected
- Validation correctness: $\text{BIP30Check}(b, us, h, n)$ prevents duplicate coinbase transactions before deactivation height

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
- $\text{CoinbaseTxids}(us)$ is the set of all coinbase transaction IDs that have created UTXOs in $us$.

**Deactivation**: BIP30 was disabled after block 91,722 (mainnet) to allow duplicate coinbases in blocks 91,842 and 91,880 (historical bug, grandfathered exception).

**Mathematical Property**: BIP30 ensures coinbase transaction uniqueness before deactivation:

$$\forall b_1, b_2 \in \mathcal{B}, b_1 \neq b_2, h \leq H_{30\_deact}(n) : \text{IsCoinbase}(tx_1) \land \text{IsCoinbase}(tx_2) \implies \text{txid}(tx_1) \neq \text{txid}(tx_2)$$

**Theorem 5.4.1** (BIP30 Uniqueness): BIP30 prevents duplicate coinbase transactions before deactivation height.

*Proof*: By construction, if a coinbase transaction $tx$ at height $h \leq H_{30\_deact}(n)$ has $\text{txid}(tx) \in \text{CoinbaseTxids}(us)$, then $\text{BIP30Check}(b, us, h, n) = \text{invalid}$, preventing the block from being accepted. Since coinbase transactions create new UTXOs, their transaction IDs are recorded in the UTXO set, ensuring uniqueness across all blocks before deactivation.

**Activation**: Block 0 (always active until deactivation)  
**Deactivation Heights**:
- Mainnet: Block 91,722
- Testnet: Block 0 (never enforced)
- Regtest: Block 0 (never enforced)

---

#### 5.4.2 BIP34: Block Height in Coinbase

**BIP34Check**: $\mathcal{B} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
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
- $\text{ExtractHeight}(tx)$ extracts the block height from coinbase scriptSig using CScriptNum encoding

**Height Encoding**: The block height is encoded in the coinbase scriptSig as a script number:

$$\text{EncodeHeight}(h) = \text{CScriptNum}(h)$$

Where $\text{CScriptNum}$ encodes the height as a variable-length integer in the script format.

**Mathematical Property**: BIP34 ensures coinbase height consistency:

$$\forall b = (h, txs) \in \mathcal{B}, h \geq H_{34} : \text{IsCoinbase}(tx) \implies \text{ExtractHeight}(tx) = h$$

**Theorem 5.4.2** (BIP34 Height Consistency): BIP34 ensures that coinbase transactions encode the correct block height.

*Proof*: For any block $b$ at height $h \geq H_{34}$, if the coinbase transaction $tx$ does not encode height $h$ in its scriptSig, then $\text{BIP34Check}(b, h) = \text{invalid}$, preventing block acceptance. This ensures that all blocks after activation height have consistent height encoding.

**Activation Heights**:
- Mainnet: Block 227,931
- Testnet: Block 21,111
- Regtest: Block 0 (always active)

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
- $\text{IsStrictDER}(sig)$ verifies that $sig$ is strictly DER-encoded according to [X.690](https://www.itu.int/rec/T-REC-X.690/) ASN.1 encoding rules

**Strict DER Requirements**:
1. **Sequence Structure**: $sig$ must be a valid DER-encoded SEQUENCE
2. **Integer Encoding**: Both $r$ and $s$ values must be strictly DER-encoded integers
3. **No Leading Zeros**: Integers must not have leading zero bytes (except for negative numbers)
4. **Minimal Length**: Encoding must use minimal length representation

**Mathematical Property**: BIP66 enforces strict DER signature encoding:

$$\forall sig \in \mathbb{S}, h \geq H_{66} : \text{BIP66Check}(sig, h) = \text{valid} \implies \text{IsStrictDER}(sig)$$

**Theorem 5.4.3** (BIP66 Strict DER Enforcement): BIP66 ensures all signatures after activation height are strictly DER-encoded.

*Proof*: For any signature $sig$ at height $h \geq H_{66}$, if $\neg \text{IsStrictDER}(sig)$, then $\text{BIP66Check}(sig, h) = \text{invalid}$, causing script validation to fail. This ensures that all signatures after activation conform to strict DER encoding, preventing signature malleability.

**Activation Heights**:
- Mainnet: Block 363,725
- Testnet: Block 330,776
- Regtest: Block 0 (always active)

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

**Activation Heights**:
- Mainnet: Various (BIP34: 227,931; BIP66: 363,725; BIP65: 388,381)
- Testnet: Various
- Regtest: Block 0 (always active)

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
- $\text{ContainsMultisig}(scriptPubkey)$ checks if $scriptPubkey$ contains OP_CHECKMULTISIG (0xae)
- $\text{IsNullDummy}(scriptSig)$ verifies that the dummy element (extra stack element consumed by OP_CHECKMULTISIG) is empty (OP_0)

**DecodeCScriptNum**: $\mathbb{S} \rightarrow \mathbb{Z}$

**Properties**:
- Empty byte array: $|bytes| = 0 \implies \text{DecodeCScriptNum}(bytes) = 0$ (empty array decodes to 0)
- Minimal encoding: $\text{DecodeCScriptNum}(bytes)$ interprets bytes as minimal little-endian signed integer
- Range: $\text{DecodeCScriptNum}(bytes) \in \mathbb{Z}$ (can be negative or positive)

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

**Theorem 5.4.5.1** (OP_CHECKMULTISIG CScriptNum Requirement): OP_CHECKMULTISIG must use CScriptNum decoding for $m$ and $n$ values.

$$\forall stack \in \mathcal{ST}: \text{OP_CHECKMULTISIG}(stack) \text{ uses } m = \text{DecodeCScriptNum}(stack[|stack|-2]) \land n = \text{DecodeCScriptNum}(stack[|stack|-1])$$

*Proof*: From the definition of $\text{DecodeCScriptNum}$, OP_CHECKMULTISIG parameters use CScriptNum decoding. This allows empty byte arrays to be interpreted as 0, which is required for certain edge cases (e.g., block 299,917). Raw byte parsing would reject empty arrays, but CScriptNum correctly decodes them to 0.

**Activation Heights**:
- Mainnet: Block 481,824 (SegWit activation)
- Testnet: Block 834,624
- Regtest: Block 0 (always active)

---

#### 5.4.6 BIP119: OP_CHECKTEMPLATEVERIFY (CTV)

**BIP119Check**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{H} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Template hash validation: $\text{BIP119Check}(tx, i, h) = \text{valid} \iff \text{TemplateHash}(tx, i) = h$
- Input index requirement: $\text{BIP119Check}(tx, i, h)$ requires $i < |tx.inputs|$ (valid input index)
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
   - Script length (varint): $\text{VarInt}(|out.\text{scriptPubkey}|)$
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
- Zero locktime rejection: $\text{BIP65Check}(tx, i, lt, h) = \text{invalid} \iff tx.\text{lockTime} = 0$ (zero locktime always invalid)
- Type consistency: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$ (types must match)
- Locktime ordering: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \leq lt$ (transaction locktime must be <= stack locktime)
- Input index requirement: $\text{BIP65Check}(tx, i, lt, h)$ requires $i < |tx.\text{inputs}|$ (valid input index)
- Deterministic: $\text{BIP65Check}(tx_1, i_1, lt_1, h_1) = \text{BIP65Check}(tx_2, i_2, lt_2, h_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land lt_1 = lt_2 \land h_1 = h_2$
- Result type: $\text{BIP65Check}(tx, i, lt, h) \in \{\text{valid}, \text{invalid}\}$

For transaction $tx$, input index $i$, locktime value $lt$, and block header $h$:

$$\text{BIP65Check}(tx, i, lt, h) = \begin{cases}
\text{invalid} & \text{if } tx.\text{lockTime} = 0 \\
\text{invalid} & \text{if } \text{LocktimeType}(tx.\text{lockTime}) \neq \text{LocktimeType}(lt) \\
\text{invalid} & \text{if } tx.\text{lockTime} > lt \\
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

**Theorem 5.4.7.4** (CLTV Zero Locktime Rejection): CLTV always fails when transaction locktime is zero:

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: tx.\text{lockTime} = 0 \implies \text{BIP65Check}(tx, i, lt, h) = \text{invalid}$$

*Proof*: By construction, if $tx.\text{lockTime} = 0$, the check immediately returns $\text{invalid}$ regardless of the stack locktime value. This is proven by blvm-spec-lock formal verification.

**Activation Heights**:
- Mainnet: Block 388,381
- Testnet: Block 371,337
- Regtest: Block 0 (always active)

---

#### 5.4.8 BIP348: OP_CHECKSIGFROMSTACK (CSFS)

**BIP348Check**: $\mathbb{S} \times \mathbb{S} \times \mathbb{S} \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- Tapscript-only: $\text{BIP348Check}(msg, pk, sig, h) = \text{valid} \implies \text{SigVersion} = \text{Tapscript}$ (only available in Tapscript)
- Zero pubkey rejection: $|pk| = 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{invalid}$ (zero-length pubkey always fails)
- Empty signature handling: $|sig| = 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{valid} \land \text{StackPush}(\emptyset)$ (empty sig pushes empty vector)
- Valid signature: $\text{BIP348Check}(msg, pk, sig, h) = \text{valid} \land |sig| > 0 \implies \text{VerifySchnorr}(msg, pk, sig) = \text{true} \land \text{StackPush}([0x01])$
- Invalid signature: $\text{BIP348Check}(msg, pk, sig, h) = \text{invalid} \land |sig| > 0 \implies \text{VerifySchnorr}(msg, pk, sig) = \text{false}$
- Unknown pubkey type: $|pk| \neq 32 \land |pk| > 0 \implies \text{BIP348Check}(msg, pk, sig, h) = \text{valid}$ (unknown types succeed)
- Deterministic: $\text{BIP348Check}(msg_1, pk_1, sig_1, h_1) = \text{BIP348Check}(msg_2, pk_2, sig_2, h_2) \iff msg_1 = msg_2 \land pk_1 = pk_2 \land sig_1 = sig_2 \land h_1 = h_2$

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
- Zero locktime rejection: $\text{BIP65Check}(tx, i, lt, h) = \text{invalid} \iff tx.\text{lockTime} = 0$ (zero locktime always invalid)
- Type consistency: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies \text{LocktimeType}(tx.\text{lockTime}) = \text{LocktimeType}(lt)$ (types must match)
- Locktime ordering: $\text{BIP65Check}(tx, i, lt, h) = \text{valid} \implies tx.\text{lockTime} \leq lt$ (transaction locktime must be <= stack locktime)
- Input index requirement: $\text{BIP65Check}(tx, i, lt, h)$ requires $i < |tx.\text{inputs}|$ (valid input index)
- Deterministic: $\text{BIP65Check}(tx_1, i_1, lt_1, h_1) = \text{BIP65Check}(tx_2, i_2, lt_2, h_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land lt_1 = lt_2 \land h_1 = h_2$
- Result type: $\text{BIP65Check}(tx, i, lt, h) \in \{\text{valid}, \text{invalid}\}$

For transaction $tx$, input index $i$, locktime value $lt$, and block header $h$:

$$\text{BIP65Check}(tx, i, lt, h) = \begin{cases}
\text{invalid} & \text{if } tx.\text{lockTime} = 0 \\
\text{invalid} & \text{if } \text{LocktimeType}(tx.\text{lockTime}) \neq \text{LocktimeType}(lt) \\
\text{invalid} & \text{if } tx.\text{lockTime} > lt \\
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

**Theorem 5.4.7.4** (CLTV Zero Locktime Rejection): CLTV always fails when transaction locktime is zero:

$$\forall tx \in \mathcal{TX}, lt \in \mathbb{N}_{32}: tx.\text{lockTime} = 0 \implies \text{BIP65Check}(tx, i, lt, h) = \text{invalid}$$

*Proof*: By construction, if $tx.\text{lockTime} = 0$, the check immediately returns $\text{invalid}$ regardless of the stack locktime value. This is proven by blvm-spec-lock formal verification.

**Activation Heights**:
- Mainnet: Block 388,381
- Testnet: Block 371,337
- Regtest: Block 0 (always active)

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
- Value extraction: $\text{ExtractSequenceLocktimeValue}(seq) = seq \land 0x0000ffff$ (bits 0-15)
- Value range: $0 \leq \text{ExtractSequenceLocktimeValue}(seq) \leq 65535$ for all $seq \in \mathbb{N}_{32}$
- Bit masking: $\text{ExtractSequenceLocktimeValue}(seq)$ extracts lower 16 bits

$$\text{ExtractSequenceLocktimeValue}(seq) = seq \land 0x0000ffff$$

**ExtractSequenceTypeFlag**: $\mathbb{N}_{32} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Type flag extraction: $\text{ExtractSequenceTypeFlag}(seq) = \text{true} \iff (seq \land 0x00400000) \neq 0$
- Boolean result: $\text{ExtractSequenceTypeFlag}(seq) \in \{\text{true}, \text{false}\}$
- Bit 22: $\text{ExtractSequenceTypeFlag}(seq)$ extracts bit 22 (type flag)

$$\text{ExtractSequenceTypeFlag}(seq) = (seq \land 0x00400000) \neq 0$$

**IsSequenceDisabled**: $\mathbb{N}_{32} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Disabled flag extraction: $\text{IsSequenceDisabled}(seq) = \text{true} \iff (seq \land 0x80000000) \neq 0$
- Boolean result: $\text{IsSequenceDisabled}(seq) \in \{\text{true}, \text{false}\}$
- Bit 31: $\text{IsSequenceDisabled}(seq)$ extracts bit 31 (disable flag)

$$\text{IsSequenceDisabled}(seq) = (seq \land 0x80000000) \neq 0$$

**GetMedianTimePast**: $[\mathcal{H}] \rightarrow \mathbb{N}$

**Properties**:
- Median calculation: $\text{GetMedianTimePast}(headers) = \text{median}(\{h.\text{timestamp} : h \in \text{last\_11}(headers)\})$ (median of last 11 block timestamps)
- Empty input: $\text{GetMedianTimePast}([]) = 0$ (empty headers return 0)
- Bounds: $\text{GetMedianTimePast}(headers) \geq \min(\{h.\text{timestamp} : h \in headers\}) \land \text{GetMedianTimePast}(headers) \leq \max(\{h.\text{timestamp} : h \in headers\})$ (median within timestamp range)
- Last 11 blocks: $\text{GetMedianTimePast}(headers)$ uses at most the last 11 block headers (BIP113 requirement)
- Deterministic: $\text{GetMedianTimePast}(h_1) = \text{GetMedianTimePast}(h_2) \iff h_1 = h_2$
- Codomain: $\text{GetMedianTimePast}(headers) \in \mathbb{N}$

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
- Heights match inputs: $\text{CalculateSequenceLocks}(tx, f, ph, rh) = (min\_h, min\_t) \implies |ph| = |tx.inputs|$ (heights must match input count)
- Lock calculation: $\text{CalculateSequenceLocks}(tx, f, ph, rh)$ calculates minimum height and time locks from sequence numbers
- Negative locks: $\text{CalculateSequenceLocks}(tx, f, ph, rh) = (min\_h, min\_t) \implies min\_h \geq -1 \land min\_t \geq -1$ (locks can be -1 if disabled)

For transaction $tx$, flags $f$, previous heights $ph \in [\mathbb{N}]$, and recent headers $rh \in [\mathcal{H}]^?$:

$$\text{CalculateSequenceLocks}(tx, f, ph, rh) = (\text{min\_height}, \text{min\_time})$$

Where:
- BIP68 is only enforced if $tx.\text{version} \geq 2$ and $(f \land 0x01) \neq 0$
- For each input $i \in tx.\text{inputs}$:
  - If $\text{IsSequenceDisabled}(i.\text{sequence})$: skip input
  - If $\text{ExtractSequenceTypeFlag}(i.\text{sequence})$ (time-based):
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
- Lock evaluation: $\text{EvaluateSequenceLocks}(height, time, (min\_h, min\_t)) = \text{true} \iff (min\_h < 0 \lor height > min\_h) \land (min\_t < 0 \lor time > min\_t)$
- Boolean result: $\text{EvaluateSequenceLocks}(height, time, (min\_h, min\_t)) \in \{\text{true}, \text{false}\}$
- Disabled locks: $\text{EvaluateSequenceLocks}(height, time, (-1, -1)) = \text{true}$ (disabled locks always pass)

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
- Non-negative: $\text{GetBlockSubsidy}(h) \geq 0$ for all $h \in \mathbb{N}$
- Upper bound: $\text{GetBlockSubsidy}(h) \leq \text{INITIAL\_SUBSIDY}$ for all $h \in \mathbb{N}$
- Genesis block: $h = 0 \implies \text{GetBlockSubsidy}(h) = \text{INITIAL\_SUBSIDY}$
- After 64 halvings: $h \geq \text{HALVING\_INTERVAL} \times 64 \implies \text{GetBlockSubsidy}(h) = 0$
- Halving schedule: For $h < \text{HALVING\_INTERVAL} \times 64$, $\text{GetBlockSubsidy}(h) = \text{INITIAL\_SUBSIDY} \gg \lfloor h / \text{HALVING\_INTERVAL} \rfloor$
- First halving boundary: $h = \text{HALVING\_INTERVAL} \implies \text{GetBlockSubsidy}(h) = \text{INITIAL\_SUBSIDY} / 2$
- Second halving boundary: $h = \text{HALVING\_INTERVAL} \times 2 \implies \text{GetBlockSubsidy}(h) = \text{INITIAL\_SUBSIDY} / 4$
- Before 64 halvings: $h < \text{HALVING\_INTERVAL} \times 64 \implies \text{GetBlockSubsidy}(h) > 0$
- Deterministic: $\text{GetBlockSubsidy}(h_1) = \text{GetBlockSubsidy}(h_2) \iff h_1 = h_2$ (same height → same subsidy)
- Monotonic decreasing: For $h_1 < h_2 < \text{HALVING\_INTERVAL} \times 64$ within same halving period, $\text{GetBlockSubsidy}(h_1) = \text{GetBlockSubsidy}(h_2)$

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
- Non-negativity: $\text{GetBlockSubsidy}(h) \geq 0$ for all $h \in \mathbb{N}$
- Upper bound: $\text{GetBlockSubsidy}(h) \leq 50 \times C$ for all $h \in \mathbb{N}$
- Genesis block: $\text{GetBlockSubsidy}(0) = 50 \times C$
- After 64 halvings: $\text{GetBlockSubsidy}(h) = 0$ for all $h \geq 64 \times H$
- First halving: $\text{GetBlockSubsidy}(H) = 25 \times C$
- Second halving: $\text{GetBlockSubsidy}(2 \times H) = 12.5 \times C$
- Non-zero before 64 halvings: $\text{GetBlockSubsidy}(h) > 0$ for all $h < 64 \times H$

**Theorem 6.1.1** (Halving Schedule Correctness): The block subsidy halves every 210,000 blocks:

$$\forall h \in \mathbb{N}, h < 64 \times H: \text{GetBlockSubsidy}(h + H) = \frac{\text{GetBlockSubsidy}(h)}{2}$$

Where $H = 210,000$ is the halving interval.

*Proof*: By construction, $\text{GetBlockSubsidy}(h) = 50 \times C \times 2^{-\lfloor h/H \rfloor}$. For $h + H$, we have $\lfloor (h+H)/H \rfloor = \lfloor h/H \rfloor + 1$, so $\text{GetBlockSubsidy}(h + H) = 50 \times C \times 2^{-(\lfloor h/H \rfloor + 1)} = \frac{50 \times C \times 2^{-\lfloor h/H \rfloor}}{2} = \frac{\text{GetBlockSubsidy}(h)}{2}$. This is proven by blvm-spec-lock formal verification.

### 6.2 Total Supply

**TotalSupply**: $\mathbb{N} \rightarrow \mathbb{Z}$

**Properties**:
- Non-negativity: $\text{TotalSupply}(h) \geq 0$ for all $h \in \mathbb{N}$
- Supply limit: $\text{TotalSupply}(h) \leq \text{MAX\_MONEY}$ for all $h \in \mathbb{N}$ (critical security invariant)
- Genesis block: $\text{TotalSupply}(0) = 50 \times C = \text{INITIAL\_SUBSIDY}$
- Monotonicity: $\text{TotalSupply}(h_1) \leq \text{TotalSupply}(h_2)$ for all $h_1 \leq h_2$ (monotonically increasing)
- Supply increase: For $h_2 > h_1$, $\text{TotalSupply}(h_2) = \text{TotalSupply}(h_1) + \sum_{i=h_1+1}^{h_2} \text{GetBlockSubsidy}(i)$
- Supply convergence: $\lim_{h \to \infty} \text{TotalSupply}(h) = 21 \times 10^6 \times C$ (converges to 21M BTC)
- After 64 halvings: For $h \geq \text{HALVING\_INTERVAL} \times 64$, $\text{TotalSupply}(h) = \text{TotalSupply}(\text{HALVING\_INTERVAL} \times 64)$ (constant after halvings stop)
- Deterministic: $\text{TotalSupply}(h_1) = \text{TotalSupply}(h_2) \iff h_1 = h_2$ (same height → same supply)
- Supply increase bounded: $\text{TotalSupply}(h+1) - \text{TotalSupply}(h) = \text{GetBlockSubsidy}(h+1) \leq \text{INITIAL\_SUBSIDY}$

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
- Validation correctness: $\text{ValidateSupplyLimit}(h) = \text{valid} \iff \text{TotalSupply}(h) \leq \text{MAX\_MONEY}$
- Supply limit invariant: $\text{ValidateSupplyLimit}(h) = \text{valid}$ for all $h \in \mathbb{N}$ (critical security property)
- Boolean result: $\text{ValidateSupplyLimit}(h) \in \{\text{valid}, \text{invalid}\}$
- Deterministic: $\text{ValidateSupplyLimit}(h_1) = \text{ValidateSupplyLimit}(h_2) \iff \text{TotalSupply}(h_1) \leq \text{MAX\_MONEY} \iff \text{TotalSupply}(h_2) \leq \text{MAX\_MONEY}$
- Always valid: Since $\text{TotalSupply}(h) \leq \text{MAX\_MONEY}$ for all $h$, $\text{ValidateSupplyLimit}(h) = \text{valid}$ for all $h$

**Theorem 6.3.1** (Supply Limit Correctness): The supply limit validation is correct:

$$\forall h \in \mathbb{N}: \text{ValidateSupplyLimit}(h) = \text{valid} \iff \text{TotalSupply}(h) \leq \text{MAX\_MONEY}$$

*Proof*: By construction, the validation function directly checks the condition. This is proven by blvm-spec-lock formal verification.

### 6.4 Coinbase Detection

**IsCoinbase**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

A transaction $tx = (v, ins, outs, lt)$ is a coinbase transaction if and only if:

$$\text{IsCoinbase}(tx) = \begin{cases}
\text{true} & \text{if } |ins| = 1 \land ins[0].\text{prevout}.\text{hash} = 0^{32} \land ins[0].\text{prevout}.\text{index} = 2^{32} - 1 \\
\text{false} & \text{otherwise}
\end{cases}$$

Where:
- $0^{32}$ is the 32-byte zero hash (all zeros)
- $2^{32} - 1$ is the maximum 32-bit unsigned integer (0xFFFFFFFF)

**Properties**:
- Definition correctness: $\text{IsCoinbase}(tx) = \text{true} \iff |tx.\text{inputs}| = 1 \land tx.\text{inputs}[0].\text{prevout}.\text{hash} = 0^{32} \land tx.\text{inputs}[0].\text{prevout}.\text{index} = 2^{32} - 1$
- Input count: $\text{IsCoinbase}(tx) = \text{true} \implies |tx.\text{inputs}| = 1$ (coinbase has exactly one input)
- Zero hash: $\text{IsCoinbase}(tx) = \text{true} \implies tx.\text{inputs}[0].\text{prevout}.\text{hash} = 0^{32}$ (null hash)
- Max index: $\text{IsCoinbase}(tx) = \text{true} \implies tx.\text{inputs}[0].\text{prevout}.\text{index} = 2^{32} - 1$ (0xFFFFFFFF)
- Boolean result: $\text{IsCoinbase}(tx) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{IsCoinbase}(tx_1) = \text{IsCoinbase}(tx_2) \iff tx_1 = tx_2$ (same transaction → same result)
- Coinbase uniqueness: In any valid block $b$, exactly one transaction satisfies $\text{IsCoinbase}(tx) = \text{true}$
- Coinbase position: In valid blocks, coinbase is always the first transaction: $\text{IsCoinbase}(b.transactions[0]) = \text{true}$
- ScriptSig length: $\text{IsCoinbase}(tx) = \text{true} \land \text{CheckTransaction}(tx) = \text{valid} \implies 2 \leq |tx.inputs[0].scriptSig| \leq 100$

**Theorem 6.4.1** (Coinbase Uniqueness): Each block contains exactly one coinbase transaction:

$$\forall b = (h, txs) \in \mathcal{B}: \sum_{tx \in txs} \text{IsCoinbase}(tx) = 1$$

*Proof*: By Bitcoin consensus rules, each block must have exactly one coinbase transaction as its first transaction. This is proven by blvm-spec-lock formal verification.

### 6.5 Fee Market

**Transaction Fee**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{Z}$

**Properties**:
- Fee formula: $\text{Fee}(tx, us) = \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} - \sum_{o \in tx.\text{outputs}} o.\text{value}$
- Coinbase fee: $\text{IsCoinbase}(tx) = \text{true} \implies \text{Fee}(tx, us) = 0$
- Non-negative fee: $\text{Fee}(tx, us) \geq 0$ for valid transactions (inputs ≥ outputs)
- Value conservation: $\text{Fee}(tx, us) \geq 0 \implies \sum_{i \in tx.\text{inputs}} us(i.\text{prevout}).\text{value} = \sum_{o \in tx.\text{outputs}} o.\text{value} + \text{Fee}(tx, us)$
- Deterministic: $\text{Fee}(tx_1, us_1) = \text{Fee}(tx_2, us_2) \iff tx_1 = tx_2 \land us_1 = us_2$

$$\text{Fee}(tx, us) = \sum_{i \in tx.inputs} us(i.prevout).value - \sum_{o \in tx.outputs} o.value$$

**Fee Rate**: $\mathcal{TX} \times \mathcal{US} \rightarrow \mathbb{Q}$

**Properties**:
- Fee rate formula: $\text{FeeRate}(tx, us) = \frac{\text{Fee}(tx, us)}{\text{Weight}(tx)}$
- Non-negative rate: $\text{FeeRate}(tx, us) \geq 0$ for valid transactions
- Zero fee rate: $\text{IsCoinbase}(tx) = \text{true} \implies \text{FeeRate}(tx, us) = 0$
- Deterministic: $\text{FeeRate}(tx_1, us_1) = \text{FeeRate}(tx_2, us_2) \iff tx_1 = tx_2 \land us_1 = us_2$

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
- Positive bits: $\text{ExpandTarget}(bits)$ requires $bits > 0$ (bits must be positive)
- Target expansion: $\text{ExpandTarget}(bits)$ expands compact difficulty representation to full 256-bit target
- Formula correctness: $\text{ExpandTarget}(bits) = \text{mantissa} \times 2^{8 \times (\text{exponent} - 3)}$ where exponent and mantissa extracted from bits

$$\text{ExpandTarget}(bits) = \text{mantissa} \times 2^{8 \times (\text{exponent} - 3)}$$

Where:
- $\text{exponent} = (bits \gg 24) \land 0xff$
- $\text{mantissa} = bits \land 0x007fffff$ (23-bit mantissa; bit `0x00800000` of the compact word lies outside this field)

- **Domain (compact exponent):** Let $e = \text{exponent}$ and $m = \text{mantissa}$. $\text{ExpandTarget}(bits)$ is defined only when $e \in \{3,4,\ldots,32\}$; for $e \notin \{3,\ldots,32\}$, the compact encoding is outside the PoW-valid domain (consensus rejects such headers). For $e \in \{3,\ldots,32\}$ and $m = 0$, $\text{ExpandTarget}(bits) = 0 \in \mathbb{U}_{256}$.

*Proof*: This function converts the compact difficulty representation (used in block headers) to a full 256-bit target value. The encoding is one exponent byte ($e$) together with a 32-bit compact word whose low 23 bits are $m$; bit `0x00800000` of that word is not part of $m$. This is proven by blvm-spec-lock formal verification.

**GetNextWorkRequired**: $\mathcal{H} \times \mathcal{H}^* \times \text{Network} \rightarrow \mathbb{N}$

**Properties**:
- Minimum headers: $\text{GetNextWorkRequired}(h, prev, n)$ requires $|prev| \geq 2$ for adjustment (otherwise returns initial difficulty)
- Difficulty bounds: $\text{GetNextWorkRequired}(h, prev, n) \leq \text{maxTarget}$ (difficulty never exceeds maximum)
- Positive difficulty: $\text{GetNextWorkRequired}(h, prev, n) > 0$ (difficulty is always positive)
- Deterministic: $\text{GetNextWorkRequired}(h_1, prev_1, n) = \text{GetNextWorkRequired}(h_2, prev_2, n) \iff h_1 = h_2 \land prev_1 = prev_2 \land n \text{ same}$
- Time-based adjustment: $\text{GetNextWorkRequired}(h, prev, n)$ adjusts difficulty based on time span between blocks
- BIP94 base: when $\text{EnforceBIP94}(n)$, bits base from $prev_{\text{first}}$; otherwise from $prev_{\text{last}}$

Let $prev_{\text{last}}$ denote the last block of the difficulty period and $prev_{\text{first}}$ the first. Let $T_{\text{expected}} = 14 \times 24 \times 60 \times 60$ (2 weeks in seconds). The timespan and bits base use only the completed period; the new block $h$ does not affect the result (timewarp safety).

$$\text{timeSpan} = \text{ClampTime}(prev_{\text{last}}.\text{time} - prev_{\text{first}}.\text{time}), \quad \text{ClampTime}(t) \coloneqq \max(T_{\text{expected}}/4, \min(4 T_{\text{expected}}, t))$$

Let $\text{bitsBase}(prev, n) \coloneqq prev_{\text{first}}.\text{bits}$ if $\text{EnforceBIP94}(n)$, else $prev_{\text{last}}.\text{bits}$.

Let $b = \text{bitsBase}(prev, n)$, $T = \text{ExpandTarget}(b)$, and $\tau = \text{timeSpan}$. Let $\pi : \mathbb{U}_{256} \to \mathbb{N}$ embed targets as unsigned integers. Define the **partial** product $T \otimes \tau \in \mathbb{U}_{256}$ to exist iff $\pi(T) \cdot \tau < 2^{256}$, in which case $T \otimes \tau$ is the unique element of $\mathbb{U}_{256}$ with $\pi(T \otimes \tau) = \pi(T) \cdot \tau$; otherwise $T \otimes \tau$ is undefined.

Let $T_{\mathrm{adj}} \coloneqq \left\lfloor \pi(T \otimes \tau) / T_{\text{expected}} \right\rfloor$ when $T \otimes \tau$ is defined. Let $c \coloneqq \text{Compress}(T_{\mathrm{adj}})$ be the compact $n$Bits encoding of the full 256-bit target $T_{\mathrm{adj}}$, using the usual compact encoding (including mantissa normalization: while the provisional significand has bit `0x00800000` set, shift it right by one byte and increase the exponent size field accordingly until it fits the 23-bit mantissa). Let $\text{MAX\_TARGET} \in \mathbb{N}$ denote the compact encoding of the network’s maximum target (minimum difficulty ceiling).

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
- PoW correctness: $\text{CheckProofOfWork}(h) = \text{true} \iff \text{SHA256}(\text{SHA256}(h)) < \text{ExpandTarget}(h.bits)$
- Hash comparison: $\text{CheckProofOfWork}(h)$ compares double-SHA256 hash against expanded target
- Boolean result: $\text{CheckProofOfWork}(h) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{CheckProofOfWork}(h_1) = \text{CheckProofOfWork}(h_2) \iff h_1 = h_2$ (same header → same result)
- Target requirement: $\text{CheckProofOfWork}(h)$ requires valid target expansion (bits must be valid)
- Hash length: $\text{SHA256}(\text{SHA256}(h))$ produces 32-byte hash for comparison

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

*Proof*: From [Theorem 6.2.3](#theorem-623-supply-convergence), we have:
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

**Property** (SegWit Transaction Serialization Round-Trip): SegWit transaction serialization and deserialization are inverse operations, where $\mathcal{W}$ denotes witness stack (see Section 11.1):

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
- Deterministic: $\text{ComputeMerkleRoot}(H) = \text{ComputeMerkleRoot}(H)$ for all $H$
- Single element: $|H| = 1 \implies \text{ComputeMerkleRoot}(H) = H[0]$
- Collision resistance: $\text{ComputeMerkleRoot}(H_1) = \text{ComputeMerkleRoot}(H_2) \implies H_1 = H_2$ (assuming SHA-256 collision resistance)

**Definition** (Bitcoin standard, double SHA-256):
1. Let $L_0 = H$ (leaf level).
2. While $|L_i| > 1$:
   - **Odd-duplicate rule**: If $|L_i|$ is odd, append $L_i[|L_i|-1]$ to $L_i$.
   - **CVE-2012-2459**: If any pair $(L_i[2j], L_i[2j+1])$ has $L_i[2j] = L_i[2j+1]$, the block is invalid (mutation detected).
   - **Pair-and-hash**: $L_{i+1}[j] = \text{SHA256d}(L_i[2j] \| L_i[2j+1])$ for $j \in [0, |L_i|/2)$.
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
- Acceptance correctness: $\text{AcceptToMemoryPool}(tx, us) = \text{accepted} \implies \text{CheckTransaction}(tx) = \text{valid} \land \neg \text{IsCoinbase}(tx)$
- Coinbase rejection: $\text{IsCoinbase}(tx) = \text{true} \implies \text{AcceptToMemoryPool}(tx, us) = \text{rejected}$
- Result type: $\text{AcceptToMemoryPool}(tx, us) \in \{\text{accepted}, \text{rejected}\}$

A transaction $tx$ is accepted to the mempool if and only if:

1. **Basic Validation**: $tx$ passes [CheckTransaction](#51-transaction-validation)
2. **Non-Coinbase**: $\neg \text{IsCoinBase}(tx)$
3. **Standard Transaction**: $\text{IsStandardTx}(tx)$ (see [Standard Transaction Rules](#standard-transaction-rules))
4. **Size Limits**: $|\text{Serialize}(tx)| \geq 65$ bytes (minimum non-witness size)
5. **Finality**: $\text{CheckFinalTxAtTip}(tx)$ (see [Transaction Finality](#transaction-finality))
6. **Fee Requirements**: $\text{FeeRate}(tx) \geq \text{minRelayFeeRate}$
7. **SigOps Limit**: $\text{SigOpsCount}(tx) \leq \text{MAX\_STANDARD\_TX\_SIGOPS\_COST}$

### 9.2 Standard Transaction Rules

**IsStandardTx**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Standard version: $\text{IsStandardTx}(tx) = \text{true} \implies tx.version \in \{1, 2\}$ (version must be 1 or 2)
- Standard scripts: $\text{IsStandardTx}(tx) = \text{true} \implies$ all outputs use standard script types (P2PKH, P2SH, P2WPKH, P2WSH, P2TR)
- Boolean result: $\text{IsStandardTx}(tx) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{IsStandardTx}(tx_1) = \text{IsStandardTx}(tx_2) \iff tx_1 = tx_2$ (same transaction → same result)
- Standard transaction subset: $\text{IsStandardTx}(tx) = \text{true} \implies \text{CheckTransaction}(tx) = \text{valid}$ (standard implies valid)
- Non-standard rejection: $\text{IsStandardTx}(tx) = \text{false} \implies$ transaction may be rejected by mempool

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
- RBF requirement: $\text{ReplacementChecks}(tx_1, tx_2) = \text{true} \implies \exists i \in tx_1.inputs : i.sequence < \text{SEQUENCE\_FINAL}$ (RBF signaling required)
- Fee bump requirement: $\text{ReplacementChecks}(tx_1, tx_2) = \text{true} \implies \text{FeeRate}(tx_2) > \text{FeeRate}(tx_1)$ (higher fee rate required)
- Boolean result: $\text{ReplacementChecks}(tx_1, tx_2) \in \{\text{true}, \text{false}\}$
- Deterministic: $\text{ReplacementChecks}(tx_{1a}, tx_{2a}) = \text{ReplacementChecks}(tx_{1b}, tx_{2b}) \iff tx_{1a} = tx_{1b} \land tx_{2a} = tx_{2b}$
- Conflict requirement: $\text{ReplacementChecks}(tx_1, tx_2) = \text{true} \implies$ $tx_1$ and $tx_2$ must conflict (share inputs)
- Same transaction ID: $\text{ReplacementChecks}(tx_1, tx_2) = \text{true} \implies tx_1.id \neq tx_2.id$ (different transactions)

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
- Deterministic: Same inputs yield same parse result

**CalculateChecksum**: $\mathbb{S} \rightarrow [0,1]^{32}$ (first 4 bytes of double SHA256)

**Properties**:
- Checksum length: $|\text{CalculateChecksum}(payload)| = 4$
- Deterministic: $\text{CalculateChecksum}(p_1) = \text{CalculateChecksum}(p_2) \iff p_1 = p_2$

**Theorem 10.1.1** (Message Size Bounds): Valid messages satisfy $24 \leq |data| \leq L_{\max}$.

**Theorem 10.1.2** (Checksum Rejection): $\text{checksum} \neq \text{CalculateChecksum}(\text{payload}) \implies \text{ParseMessage}(data) = \text{error}$

**Implementation Invariants**:
1. **Checksum length**: $|\text{CalculateChecksum}(payload)| = 4$
2. **Payload bounds**: $\text{payload\_length} \leq L_{\max} - 24$

### 10.2.1 Handshake Invariants

**HandleVersionReceived**: On receipt of `version` message, node must send `verack` only after processing. VerAck is never sent before Version.

**Properties**:
- Version-before-VerAck: $\text{VerAckSent} \implies \text{VersionReceived}$ (ordering rule)
- No premature VerAck: VerAck must not be sent before Version is received and processed

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

**Witness Data**: $\mathcal{W} = \mathbb{S}^*$ (stack of witness elements)

**Witness Merkle (BIP141)**: The commitment uses the **witness transaction id (wtxid)** merkle tree (not a hash of raw witness stacks). Let $\text{wtxid}(tx)$ be the 32-byte hash defined in [BIP141](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki): coinbase wtxid is fixed to $0^{32}$; for other transactions, if no witness data is present, $\text{wtxid}(tx) = \text{txid}(tx)$ (legacy serialization); if witness data is present, $\text{wtxid}(tx) = \text{SHA256d}(\text{SerializeWithWitness}(tx))$.

$$\text{WitnessRoot} = \text{ComputeMerkleRoot}(\{\text{wtxid}(tx_i) : i \in [0, |block.transactions|)\})$$

**Witness commitment output (BIP141)**: The 32-byte value in the coinbase OP_RETURN is $\text{SHA256d}(\text{WitnessRoot} \,\|\, \text{WitnessReservedValue})$, where $\text{WitnessReservedValue}$ is the 32-byte item in the coinbase input’s witness stack (default $0^{32}$ if absent), not the raw $\text{WitnessRoot}$ alone.

**Weight Calculation** (BIP141):  
$$\text{Weight}(tx) = 3 \times |\text{Serialize}(tx \setminus witness)| + |\text{Serialize}(tx)|$$

#### 11.1.1 Weight and Size Calculations

**CalculateTransactionWeight**: $\mathcal{TX} \times \mathcal{W}^? \rightarrow \mathbb{N}$

**Properties**:
- Weight formula: $\text{CalculateTransactionWeight}(tx, w) = 3 \times \text{BaseSize}(tx) + \text{TotalSize}(tx, w)$ (BIP141)
- Non-negativity: $\text{CalculateTransactionWeight}(tx, w) \geq 0$ for all valid transactions
- Minimum weight: $\text{CalculateTransactionWeight}(tx, w) \geq 4$ (at least 4 bytes base size)
- Weight bounds: $\text{CalculateTransactionWeight}(tx, w) \leq W_{\text{max\_tx\_weight}}$ for valid transactions
- Base size component: $\text{CalculateTransactionWeight}(tx, w) \geq 3 \times \text{BaseSize}(tx)$ (base size is always included)
- Total size component: $\text{CalculateTransactionWeight}(tx, w) \geq \text{TotalSize}(tx, w)$ (total size is always included)
- Deterministic: $\text{CalculateTransactionWeight}(tx_1, w_1) = \text{CalculateTransactionWeight}(tx_2, w_2) \iff tx_1 = tx_2 \land w_1 = w_2$
- Witness impact: $\text{CalculateTransactionWeight}(tx, \text{Some}(w)) \geq \text{CalculateTransactionWeight}(tx, \text{None})$ (witness increases weight)

For transaction $tx$ and witness $w$:

$$\text{CalculateTransactionWeight}(tx, w) = 3 \times \text{BaseSize}(tx) + \text{TotalSize}(tx, w)$$

Where:
- $\text{BaseSize}(tx) = |\text{Serialize}(tx \setminus witness)|$ (transaction size without witness data)
- $\text{TotalSize}(tx, w) = |\text{Serialize}(tx)|$ (transaction size with witness data)

**Properties**:
- Weight formula: $\text{CalculateTransactionWeight}(tx, w) = 3 \times \text{BaseSize}(tx) + \text{TotalSize}(tx, w)$ (BIP141)
- Weight positivity: $\text{CalculateTransactionWeight}(tx, w) > 0$ for all valid transactions
- Minimum weight: $\text{CalculateTransactionWeight}(tx, w) \geq 4$ (at least 4 bytes base size)
- Weight bounds: $\text{CalculateTransactionWeight}(tx, w) \leq M_{\text{max\_tx\_weight}}$ for valid transactions
- Base size component: $\text{CalculateTransactionWeight}(tx, w) \geq 3 \times \text{BaseSize}(tx)$ (base size is always included)
- Total size component: $\text{CalculateTransactionWeight}(tx, w) \geq \text{TotalSize}(tx, w)$ (total size is always included)
- Deterministic: $\text{CalculateTransactionWeight}(tx_1, w_1) = \text{CalculateTransactionWeight}(tx_2, w_2) \iff tx_1 = tx_2 \land w_1 = w_2$
- Witness impact: $\text{CalculateTransactionWeight}(tx, \text{Some}(w)) \geq \text{CalculateTransactionWeight}(tx, \text{None})$ (witness increases weight)
- Non-negativity: $\text{CalculateTransactionWeight}(tx, w) \geq 0$ for all valid transactions

**WeightToVSize**: $\mathbb{N} \rightarrow \mathbb{N}$

**Properties**:
- Ceiling division: $\text{WeightToVSize}(w) = \lceil w / 4 \rceil = (w + 3) / 4$
- Lower bound: $\text{WeightToVSize}(w) \geq w / 4$ for all $w \in \mathbb{N}$
- Upper bound: $\text{WeightToVSize}(w) \leq (w / 4) + 1$ for all $w \in \mathbb{N}$
- Zero weight: $\text{WeightToVSize}(0) = 0$
- Exact division: $w \bmod 4 = 0 \implies \text{WeightToVSize}(w) = w / 4$

For weight $w$:

$$\text{WeightToVSize}(w) = \lceil w / 4 \rceil$$

Implemented as: $\text{WeightToVSize}(w) = (w + 3) / 4$ (integer ceiling division).

**CalculateBlockWeight**: $\mathcal{B} \times \mathcal{W}^* \rightarrow \mathbb{N}$

**Properties**:
- Weight positivity: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) > 0$ for all valid blocks
- Minimum weight: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) \geq |b.transactions| \times 4$ (minimum weight per transaction)
- Block limit: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) \leq W_{\text{max}}$ for valid blocks
- Sum property: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) = \sum_{i=1}^{|b.transactions|} \text{CalculateTransactionWeight}(b.transactions[i], w_i)$
- Deterministic: $\text{CalculateBlockWeight}(b_1, w_{1a}, \ldots) = \text{CalculateBlockWeight}(b_2, w_{2a}, \ldots) \iff b_1 = b_2 \land w_{1a} = w_{2a} \land \ldots$
- Witness count: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n)$ requires $|w_1, \ldots, w_n| = |b.transactions|$ (witnesses match transaction count)
- Monotonicity: Adding transactions increases weight: $|b_1.transactions| < |b_2.transactions| \implies \text{CalculateBlockWeight}(b_1, \ldots) < \text{CalculateBlockWeight}(b_2, \ldots)$

For block $b$ and witnesses $w_1, \ldots, w_n$:

$$\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) = \sum_{i=1}^{|b.\text{transactions}|} \text{CalculateTransactionWeight}(b.\text{transactions}[i], w_i)$$

**Block Weight Limit**: For block $b$:

$$\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) \leq W_{max}$$

Where $W_{max} = 4,000,000$ (MAX_BLOCK_WEIGHT).

#### 11.1.2 Witness Structure Validation

**ValidateSegWitWitnessStructure**: $\mathcal{W} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Element size bounds: $\text{ValidateSegWitWitnessStructure}(w) = \text{true} \iff \forall e \in w : |e| \leq 520$
- Empty witness: $\text{ValidateSegWitWitnessStructure}(\emptyset) = \text{true}$ (empty witness is valid)
- Structure validation: $\text{ValidateSegWitWitnessStructure}(w) = \text{true} \implies$ all witness elements respect size limits

For witness $w$:

$$\text{ValidateSegWitWitnessStructure}(w) = \forall e \in w : |e| \leq 520$$

Where 520 is MAX_SCRIPT_ELEMENT_SIZE (maximum witness element size per BIP141).

**IsWitnessEmpty**: $\mathcal{W} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Empty definition: $\text{IsWitnessEmpty}(w) = \text{true} \iff (|w| = 0) \lor (\forall e \in w : |e| = 0)$
- Boolean result: $\text{IsWitnessEmpty}(w) \in \{\text{true}, \text{false}\}$
- Empty witness: $\text{IsWitnessEmpty}(\emptyset) = \text{true}$

For witness $w$:

$$\text{IsWitnessEmpty}(w) = (|w| = 0) \lor (\forall e \in w : |e| = 0)$$

#### 11.1.3 Witness Program Extraction

**ExtractWitnessVersion**: $\mathbb{S} \rightarrow \{\text{None}, \text{SegWitV0}, \text{TaprootV1}\}$

**Properties**:
- Version range: $\text{ExtractWitnessVersion}(s) \neq \text{None} \implies |s| \geq 2 \land (s[0] = 0x00 \lor s[0] = 0x51)$
- Valid version: $\text{ExtractWitnessVersion}(s) = \text{SegWitV0} \implies s[0] = 0x00 \land |s| \geq 2$
- Taproot version: $\text{ExtractWitnessVersion}(s) = \text{TaprootV1} \implies s[0] = 0x51 \land |s| \geq 2$

For script $s$:

$$\text{ExtractWitnessVersion}(s) = \begin{cases}
\text{SegWitV0} & \text{if } |s| \geq 2 \land s[0] = 0x00 \\
\text{TaprootV1} & \text{if } |s| \geq 2 \land s[0] = 0x51 \\
\text{None} & \text{otherwise}
\end{cases}$$

**ExtractWitnessProgram**: $\mathbb{S} \times \{\text{SegWitV0}, \text{TaprootV1}\} \rightarrow \mathbb{S}^?$

**Properties**:
- Program extraction: $\text{ExtractWitnessProgram}(s, v) = \text{Some}(p) \implies |s| \geq 3$ (minimum script length)
- SegWit program: $\text{ExtractWitnessProgram}(s, \text{SegWitV0}) = \text{Some}(p) \implies s[1]] \in \{0x14, 0x20\} \land |s| \geq 3$
- Taproot program: $\text{ExtractWitnessProgram}(s, \text{TaprootV1}) = \text{Some}(p) \implies s[1] = 0x20 \land |s| \geq 3$

For script $s$ and version $v$:

$$\text{ExtractWitnessProgram}(s, v) = \begin{cases}
s[2..|s|] & \text{if } v = \text{SegWitV0} \land s[1] \in \{0x14, 0x20\} \\
s[2..|s|] & \text{if } v = \text{TaprootV1} \land s[1] = 0x20 \\
\text{None} & \text{otherwise}
\end{cases}$$

**ValidateWitnessProgramLength**: $\mathbb{S} \times \{\text{SegWitV0}, \text{TaprootV1}\} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Valid program length: $\text{ValidateWitnessProgramLength}(p, v) = \text{true} \implies |p| > 0$
- SegWit length: $\text{ValidateWitnessProgramLength}(p, \text{SegWitV0}) = \text{true} \iff |p| = 20 \lor |p| = 32$
- Taproot length: $\text{ValidateWitnessProgramLength}(p, \text{TaprootV1}) = \text{true} \iff |p| = 32$

For program $p$ and version $v$:

$$\text{ValidateWitnessProgramLength}(p, v) = \begin{cases}
|p| = 20 \lor |p| = 32 & \text{if } v = \text{SegWitV0} \\
|p| = 32 & \text{if } v = \text{TaprootV1} \\
\text{false} & \text{otherwise}
\end{cases}$$

#### 11.1.4 Witness Merkle Root

**ComputeWitnessMerkleRoot**: $\mathcal{B} \times \mathcal{W}^* \rightarrow \mathbb{H}$

**Definition** (BIP141 wtxid tree): For each transaction index $i$, define the leaf hash $L_i$:

- $L_0 = 0^{32}$ (coinbase wtxid is fixed to zero).
- For $i > 0$: let $w^{(i)}$ be the witness data for transaction $i$ (per-input stacks). If no witness element is non-empty, $L_i = \text{txid}(b.\text{transactions}[i])$ using **legacy** serialization (no witness). Otherwise $L_i = \text{SHA256d}(\text{SerializeWithWitness}(b.\text{transactions}[i], w^{(i)}))$.

$$\text{ComputeWitnessMerkleRoot}(b, w_1, \ldots, w_n) = \text{ComputeMerkleRoot}(\{L_0, L_1, \ldots, L_{|b.\text{transactions}|-1}\})$$

**Properties**:
- Root length: the result is a 32-byte hash.
- Block requirement: $|b.transactions| > 0$.
- **CVE-2012-2459**: $\text{ComputeMerkleRoot}$ must apply the odd-duplicate and duplicate-pair rejection rules in §8.4.1 (ComputeMerkleRoot).

#### 11.1.5 Witness Commitment Validation

**ValidateWitnessCommitment**: $\mathcal{TX} \times \mathbb{H} \times \mathcal{W}^* \rightarrow \{\text{true}, \text{false}\}$

**Inputs**: coinbase transaction $tx$, computed witness merkle root $r$, and the coinbase transaction’s witness stacks (to obtain the **witness reserved value**).

Let $n \in \{0,1\}^{256}$ be the 32-byte witness reserved value: the first push of the first witness stack of the coinbase input, or $0^{32}$ if missing or not exactly 32 bytes.

Let $c = \text{SHA256d}(r \,\|\, n)$ (64-byte preimage). A valid witness commitment output stores $c$ (not $r$ alone).

**OP_RETURN format** (BIP141): `OP_RETURN` `0x24` `0xaa21a9ed` $\|\, c$ (total push 36 bytes after opcode: 4-byte magic + 32-byte $c$).

**Properties**:
- Coinbase requirement: only defined for $\text{IsCoinbase}(tx)$.
- If no commitment output exists, validation passes for pre-SegWit-style coinbases; if a commitment output exists, its 32-byte payload must equal $c$.

$$\text{ValidateWitnessCommitment}(tx, r, w_{cb}) = \text{true} \iff \neg \exists \text{ commitment output} \lor \exists o \in tx.\text{outputs} : \text{ExtractCommitment}(o.\text{scriptPubkey}) = c$$

Where $\text{ExtractCommitment}(spk)$ returns the 32-byte hash after the BIP141 magic prefix when $spk$ matches the standard witness commitment pattern; otherwise undefined.

#### 11.1.6 SegWit Transaction Detection

**IsSegWitTransaction**: $\mathcal{TX} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Output detection: $\text{IsSegWitTransaction}(tx) = \text{true} \iff \exists o \in tx.outputs : \text{IsSegWitOutput}(o.scriptPubkey)$
- Boolean result: $\text{IsSegWitTransaction}(tx) \in \{\text{true}, \text{false}\}$
- Witness presence: $\text{IsSegWitTransaction}(tx) = \text{true} \implies$ transaction may have witness data

For transaction $tx$:

$$\text{IsSegWitTransaction}(tx) = \exists o \in tx.\text{outputs} : \text{IsSegWitOutput}(o.\text{scriptPubkey})$$

Where $\text{IsSegWitOutput}(spk) = (|spk| \in \{22, 34\}) \land (spk[0] = 0x00) \land ((spk[1] = 0x14) \lor (spk[1] = 0x20))$

#### 11.1.7 Block Validation

**ValidateSegWitBlock**: $\mathcal{B} \times \mathcal{W}^* \times \mathbb{N} \rightarrow \{\text{valid}, \text{invalid}\}$

(Parameters: block $b$, per-transaction witness data $w_1,\ldots,w_n$, maximum block weight $W_{\text{max}}$.)

**Properties**:
- Let $r = \text{ComputeWitnessMerkleRoot}(b, w_1, \ldots, w_n)$ as in §11.1.4.
- Witness commitment (when present) must satisfy §11.1.5 for the coinbase $b.\text{transactions}[0]$, root $r$, and coinbase witness stacks $w_1$.
- Block weight: $\text{CalculateBlockWeight}(b, w_1, \ldots, w_n) \leq W_{\text{max}}$.

$$\text{ValidateSegWitBlock}(b, w_1, \ldots, w_n, W_{\text{max}}) = \begin{cases}
\text{valid} & \text{if } \text{CalculateBlockWeight}(\ldots) \leq W_{\text{max}} \land \text{ValidateWitnessCommitment}(b.\text{transactions}[0], r, w_1) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

(If no witness commitment output exists in the coinbase, §11.1.5 treats validation as satisfied for pre-SegWit coinbase layouts; implementations gate full SegWit rules on deployment context.)

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

**Theorem 11.1.1** (Nested SegWit Validation): Nested SegWit transactions validate the witness program hash in the P2SH redeem script, then execute witness validation.

*Proof*: By construction, nested SegWit transactions first validate that the redeem script hash matches the P2SH scriptPubKey. Then, the witness program (20 or 32 bytes) is extracted from the redeem script, and witness validation proceeds as for direct SegWit transactions. For P2WSH-in-P2SH, the witness script is the last witness element and must hash to the 32-byte program.

**Activation**: Block 481,824 (mainnet) - Same as SegWit activation

#### 11.1.9 BIP143 Witness Sighash (ComputeWitnessSignatureHash)

**ComputeWitnessSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathbb{S} \times \mathbb{Z} \times \mathbb{N}_{8} \rightarrow \mathbb{H}$

Computes the signature hash for SegWit (P2WPKH, P2WSH) inputs per BIP 143. Replaces legacy sighash with a committed structure that excludes scriptSig and binds the amount.

**Preimage structure** (BIP 143 byte layout):
$$\text{Preimage} = \text{nVersion}_{32} \| \text{hashPrevouts}_{256} \| \text{hashSequence}_{256} \| \text{outpoint}_{288} \| \text{scriptCode} \| \text{amount}_{64} \| \text{nSequence}_{32} \| \text{hashOutputs}_{256} \| \text{nLockTime}_{32} \| \text{sighashType}_{32}$$

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
- Hash length: $|\text{ComputeWitnessSignatureHash}(\ldots)| = 32$
- Deterministic: Same inputs yield same hash
- Amount binding: Signature commits to UTXO value (replay protection across outputs)

**Theorem 11.1.2** (BIP143 Sighash Determinism): For fixed $(tx, i, scriptCode, amount, type)$, $\text{ComputeWitnessSignatureHash}$ is uniquely determined.

*Proof*: Preimage is deterministic from inputs; SHA256d is deterministic. Thus the hash is unique.

### 11.2 Taproot

**Taproot Output**: P2TR script `OP_1 <32-byte-hash>`

**P2TR Script Format**: $\text{P2TR} = [0x51, 0x20, h_{32}]$ where $h_{32} \in \{0,1\}^{256}$

**P2TR Detection**: $\text{IsP2TR}(spk) = (|spk| = 34) \land (spk[0] = 0x51) \land (spk[1] = 0x20)$

**Empty ScriptSig Requirement**: For Taproot transactions, scriptSig must be empty:

$$\forall tx \in \mathcal{TX}, i \in \mathbb{N} : \text{IsP2TR}(tx.\text{outputs}[j].\text{scriptPubkey}) \land tx.\text{inputs}[i].\text{prevout} = (txid, j) \implies tx.\text{inputs}[i].\text{scriptSig} = \emptyset$$

**Key Aggregation**: 
$$\text{OutputKey} = \text{InternalPubKey} + \text{TaprootTweak}(\text{MerkleRoot}) \times G$$

**Script Path**: Alternative spending path using merkle proof

#### 11.2.1 Taproot Script Validation

**ValidateTaprootScript**: $\mathbb{S} \rightarrow \{\text{true}, \text{false}\}$

For script $s$:

$$\text{ValidateTaprootScript}(s) = (|s| = 34) \land (s[0] = 0x51) \land (s[1] = 0x20)$$

**Properties**:
- Length validation: $\text{ValidateTaprootScript}(s) = \text{true} \iff |s| = 34$
- Format correctness: $\text{ValidateTaprootScript}(s) = \text{true} \implies s[0] = 0x51 \land s[1] = 0x20$
- Invalid length: $|s| \neq 34 \implies \text{ValidateTaprootScript}(s) = \text{false}$

**ExtractTaprootOutputKey**: $\mathbb{S} \rightarrow \{[0,1]^{256}\}^?$

**Properties**:
- Key extraction: $\text{ExtractTaprootOutputKey}(s) = \text{Some}(k) \implies \text{ValidateTaprootScript}(s) = \text{true}$
- Key length: $\text{ExtractTaprootOutputKey}(s) = \text{Some}(k) \implies |k| = 32$ (32-byte public key)
- Script validation: $\text{ExtractTaprootOutputKey}(s) = \text{Some}(k) \implies |s| = 34 \land s[0] = 0x51 \land s[1] = 0x20$

For script $s$:

$$\text{ExtractTaprootOutputKey}(s) = \begin{cases}
s[2..34] & \text{if } \text{ValidateTaprootScript}(s) \\
\text{None} & \text{otherwise}
\end{cases}$$

**IsTaprootOutput**: $\mathcal{T} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Output detection: $\text{IsTaprootOutput}(o) = \text{true} \iff \text{ValidateTaprootScript}(o.scriptPubkey) = \text{true}$
- Boolean result: $\text{IsTaprootOutput}(o) \in \{\text{true}, \text{false}\}$
- Script validation: $\text{IsTaprootOutput}(o) = \text{true} \implies |o.scriptPubkey| = 34 \land o.scriptPubkey[0] = 0x51$

For transaction output $o$:

$$\text{IsTaprootOutput}(o) = \text{ValidateTaprootScript}(o.\text{scriptPubkey})$$

#### 11.2.2 Taproot Key Operations

**ComputeTaprootTweak**: $[0,1]^{256} \times \mathbb{H} \rightarrow [0,1]^{256}$

**Properties**:
- Tweak length: $\text{ComputeTaprootTweak}(pk, root) = t \implies |t| = 32$ (32-byte tweak)
- Deterministic: $\text{ComputeTaprootTweak}(pk_1, root_1) = \text{ComputeTaprootTweak}(pk_2, root_2) \iff pk_1 = pk_2 \land root_1 = root_2$
- Hash property: $\text{ComputeTaprootTweak}(pk, root)$ uses tagged hash for domain separation

For internal public key $pk$ and merkle root $root$:

$$\text{ComputeTaprootTweak}(pk, root) = \text{TaggedHash}(\text{"TapTweak"}, pk, root)$$

Where $\text{TaggedHash}$ is BIP340 tagged hash function.

**ValidateTaprootKeyAggregation**: $[0,1]^{256} \times [0,1]^{256} \times \mathbb{H} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Key aggregation correctness: $\text{ValidateTaprootKeyAggregation}(pk, out, root) = \text{true} \iff out = pk + \text{ComputeTaprootTweak}(pk, root) \times G$
- Boolean result: $\text{ValidateTaprootKeyAggregation}(pk, out, root) \in \{\text{true}, \text{false}\}$
- Elliptic curve operation: $\text{ValidateTaprootKeyAggregation}(pk, out, root)$ validates elliptic curve point addition

For internal public key $pk$, output key $out$, and merkle root $root$:

$$\text{ValidateTaprootKeyAggregation}(pk, out, root) = (out = pk + \text{ComputeTaprootTweak}(pk, root) \times G)$$

#### 11.2.3 Taproot Script Path

**ValidateTaprootScriptPath**: $\mathbb{S} \times [\mathbb{H}]^* \times [0,1]^{256} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Merkle proof validation: $\text{ValidateTaprootScriptPath}(s, proof, root) = \text{true} \iff \text{ComputeScriptMerkleRoot}(s, proof, v) = root$
- Boolean result: $\text{ValidateTaprootScriptPath}(s, proof, root) \in \{\text{true}, \text{false}\}$
- Script path correctness: $\text{ValidateTaprootScriptPath}(s, proof, root)$ validates script is in Taproot merkle tree

For script $s$, merkle proof $proof$, and expected merkle root $root$:

$$\text{ValidateTaprootScriptPath}(s, proof, root) = \begin{cases}
\text{true} & \text{if } \text{ComputeScriptMerkleRoot}(s, proof, v) = root \\
\text{false} & \text{otherwise}
\end{cases}$$

where $v$ is the leaf version (default $\texttt{0xc0}$ for tapscript per BIP 341).

**ComputeScriptMerkleRoot**: $\mathbb{S} \times [\mathbb{H}]^* \times \mathbb{N}_{8} \rightarrow \mathbb{H}$

Computes the Taproot script merkle root from a leaf script and merkle proof using BIP 341 TapLeaf and TapBranch tagged hashes.

**TapLeaf Hash** (BIP 341):
$$\text{TapLeafHash}(v, s) = \text{TaggedHash}(\texttt{"TapLeaf"}, v \| \text{CompactSize}(|s|) \| s)$$

where $v \in \{0,\ldots,255\}$ is the leaf version, $s \in \mathbb{S}$ is the script, and $\text{CompactSize}$ encodes the script length per Bitcoin varint.

**TapBranch Hash** (BIP 341):
$$\text{TapBranchHash}(h_L, h_R) = \text{TaggedHash}(\texttt{"TapBranch"}, h_L \| h_R)$$

where $h_L, h_R \in \mathbb{H}$ are 32-byte hashes. For sibling ordering: $(h_{\text{left}}, h_{\text{right}}) = (\min(h_{\text{current}}, h_{\text{proof}}), \max(h_{\text{current}}, h_{\text{proof}}))$ (lexicographic order).

**Definition** (iterative, BIP 341):

$$h_0 = \text{TapLeafHash}(v, s)$$

For $j = 0, \ldots, |proof|-1$:
$$(h_L, h_R) = (\min(h_j, proof[j]), \max(h_j, proof[j])) \quad \text{(lexicographic order)}$$
$$h_{j+1} = \text{TapBranchHash}(h_L, h_R)$$

$$\text{ComputeScriptMerkleRoot}(s, proof, v) = h_{|proof|}$$

**Properties**:
- Hash length: $\text{ComputeScriptMerkleRoot}(s, proof, v) = h \implies |h| = 32$
- Deterministic: Same $(s, proof, v)$ yields same root
- Merkle consistency: $\text{ValidateTaprootScriptPath}(s, proof, \text{ComputeScriptMerkleRoot}(s, proof, v)) = \text{true}$

**Theorem 11.2.2** (Script Merkle Root Uniqueness): For fixed script $s$, proof $proof$, and leaf version $v$, $\text{ComputeScriptMerkleRoot}(s, proof, v)$ is uniquely determined.

*Proof*: TapLeafHash and TapBranchHash are deterministic cryptographic hash functions. The iterative construction processes each proof element in order; sibling ordering is fixed by lexicographic comparison. Thus the computation is deterministic and produces a unique 32-byte root.

#### 11.2.4 Taproot Witness Structure

**ValidateTaprootWitnessStructure**: $\mathcal{W} \times \{\text{true}, \text{false}\} \rightarrow \{\text{true}, \text{false}\}$

**Properties**:
- Key path structure: $\text{ValidateTaprootWitnessStructure}(w, \text{false}) = \text{true} \iff |w| = 1 \land |w[0]| = 64$ (single 64-byte signature)
- Script path structure: $\text{ValidateTaprootWitnessStructure}(w, \text{true}) = \text{true} \iff |w| \geq 2 \land |w[|w|-1]| \geq 33 \land (|w[|w|-1]| - 33) \bmod 32 = 0$
- Boolean result: $\text{ValidateTaprootWitnessStructure}(w, is\_script) \in \{\text{true}, \text{false}\}$

For witness $w$ and script path flag $is\_script$:

$$\text{ValidateTaprootWitnessStructure}(w, is\_script) = \begin{cases}
|w| = 1 \land |w[0]| = 64 & \text{if } \neg is\_script \text{ (key path)} \\
|w| \geq 2 \land |w[|w|-1]| \geq 33 \land (|w[|w|-1]| - 33) \bmod 32 = 0 & \text{if } is\_script \text{ (script path)}
\end{cases}$$

#### 11.2.5 Taproot Transaction Validation

**ValidateTaprootTransaction**: $\mathcal{TX} \times \mathcal{W}^? \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- ScriptSig empty: $\text{ValidateTaprootTransaction}(tx, w) = \text{valid} \implies \forall i \in tx.inputs : \text{IsP2TR}(tx.outputs[j].scriptPubkey) \implies i.scriptSig = \emptyset$
- Witness structure: $\text{ValidateTaprootTransaction}(tx, w) = \text{valid} \implies \text{ValidateTaprootWitnessStructure}(w, \text{IsScriptPath}(w)) = \text{true}$
- Validation correctness: $\text{ValidateTaprootTransaction}(tx, w)$ validates all Taproot-specific rules

For transaction $tx$ and witness $w$:

$$\text{ValidateTaprootTransaction}(tx, w) = \begin{cases}
\text{valid} & \text{if } \forall i \in tx.\text{inputs} : \text{IsP2TR}(tx.\text{outputs}[j].\text{scriptPubkey}) \implies i.\text{scriptSig} = \emptyset \land \text{ValidateTaprootWitnessStructure}(w, \text{IsScriptPath}(w)) \\
\text{invalid} & \text{otherwise}
\end{cases}$$

#### 11.2.6 Taproot Signature Hash

**ComputeTaprootSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \mathbb{N}_{32} \times \mathbb{H}^? \rightarrow \mathbb{H}$

**Properties**:
- Hash length: $\text{ComputeTaprootSignatureHash}(tx, i, us, type, leaf) = h \implies |h| = 32$ (32-byte hash)
- Deterministic: $\text{ComputeTaprootSignatureHash}(tx_1, i_1, us_1, type_1, leaf_1) = \text{ComputeTaprootSignatureHash}(tx_2, i_2, us_2, type_2, leaf_2) \iff tx_1 = tx_2 \land i_1 = i_2 \land us_1 = us_2 \land type_1 = type_2 \land leaf_1 = leaf_2$
- Tagged hash: $\text{ComputeTaprootSignatureHash}(tx, i, us, type, leaf)$ uses BIP340 tagged hash for domain separation

For transaction $tx$, input index $i$, UTXO set $us$, sighash type $type$, and leaf hash $leaf$:

$$\text{ComputeTaprootSignatureHash}(tx, i, us, type, leaf) = \text{TaggedHash}(\text{"TapSighash"}, tx, i, us(i.\text{prevout}), type, leaf)$$

#### 11.2.7 Tapscript Signature Hash (BIP 342)

**ComputeTapscriptSignatureHash**: $\mathcal{TX} \times \mathbb{N} \times \mathcal{US} \times \mathbb{S} \times \mathbb{N}_{8} \times \mathbb{N}_{32} \times \mathbb{N}_{8} \rightarrow \mathbb{H}$

Computes the signature hash for tapscript (script-path) spending. Same base SigMsg structure as key-path (11.2.6), with an extension field $ext$ that binds the signature to the specific tapscript and OP_CODESEPARATOR position.

**Extension field** (BIP 342):
$$ext = \text{codesep\_pos}_{32} \| \text{key\_version}_{8} \| \text{tapleaf\_hash}_{256}$$

where:
- $\text{codesep\_pos}_{32}$: 4-byte little-endian encoding of the last OP_CODESEPARATOR position (0 if none executed)
- $\text{key\_version}_{8}$: 1 byte, value $0x00$ for current tapscript
- $\text{tapleaf\_hash}_{256}$: 32-byte $\text{TapLeafHash}(v, s)$ of the executing tapscript

**Definition**:
$$\text{SigMsgBase}(tx, i, us, type) = \text{version} \| \text{inputs} \| \text{outputs} \| \text{locktime} \| type \| i \| \text{value}_i \| \text{scriptPubKey}_i$$

$$\text{ComputeTapscriptSignatureHash}(tx, i, us, s, v, \text{codesep}, type) = \text{TaggedHash}(\texttt{"TapSighash"}, 0x00 \| \text{SigMsgBase}(tx, i, us, type) \| ext)$$

where $ext = \text{LE}_{32}(\text{codesep}) \| 0x00 \| \text{TapLeafHash}(v, s)$.

**Properties**:
- Hash length: $\text{ComputeTapscriptSignatureHash}(\ldots) = h \implies |h| = 32$
- Deterministic: Same inputs yield same hash
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

**CountTapscriptSigOps**: $\mathbb{S} \rightarrow \mathbb{N}$; counts CHECKSIG-family opcodes in a tapscript per **BIP 342** (used for the **per-tapscript sigops budget** during Tapscript execution / validation weight). This count is **not** added to the **legacy block** $\text{GetTransactionSigOpCost}$ witness term ($\text{CountWitnessSigOps}$ is witness-v0-only for that cost; see §5.2.2).

Parse $s$ sequentially. For each byte: if it is a push opcode (0x01–0x4b, or 0x4c/0x4d/0x4e with length bytes), skip the payload; otherwise it is an opcode byte. Count opcode bytes in $\{0xac, 0xad, 0xba\}$:

$$\text{CountTapscriptSigOps}(s) = \sum_{\text{opcode positions } i} \mathbf{1}[s[i] \in \{0xac, 0xad, 0xba\}]$$

where $0xac = \text{OP\_CHECKSIG}$, $0xad = \text{OP\_CHECKSIGVERIFY}$, $0xba = \text{OP\_CHECKSIGADD}$. Bytes inside push-data payloads are not counted (they are data, not opcodes).

**Properties**:
- Bounds: $\text{CountTapscriptSigOps}(s) \leq |s|$ (each opcode byte counts at most once)
- No CHECKMULTISIG: Tapscript disables OP_CHECKMULTISIG, OP_CHECKMULTISIGVERIFY; only CHECKSIG-family opcodes count

**Activation**: Block 709,632 (mainnet)


### 11.4 UTXO Commitments

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
- Merkle root correctness: $\text{GenerateCommitment}(us, bh, h).\text{merkle\_root} = \text{BuildMerkleTree}(us)$ (merkle root commits to entire UTXO set)
- Height consistency: $\text{GenerateCommitment}(us, bh, h).\text{block\_height} = h$ (height matches input)
- UTXO count: $\text{GenerateCommitment}(us, bh, h).\text{utxo\_count} = |us|$ (count matches UTXO set size)
- Total supply: $\text{GenerateCommitment}(us, bh, h).\text{total\_supply} = \sum_{u \in us} u.\text{value}$ (total supply equals sum of UTXO values)
- Block hash: $\text{GenerateCommitment}(us, bh, h).\text{block\_hash} = bh$ (block hash matches input)
- Deterministic: $\text{GenerateCommitment}(us_1, bh_1, h_1) = \text{GenerateCommitment}(us_2, bh_2, h_2) \iff us_1 = us_2 \land bh_1 = bh_2 \land h_1 = h_2$
- Merkle root length: $\text{GenerateCommitment}(us, bh, h).\text{merkle\_root}$ is 32 bytes (SHA256 hash)
- Supply consistency: $\text{GenerateCommitment}(us, bh, h).\text{total\_supply} \leq \text{MAX\_MONEY}$ (supply respects maximum)

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
- Consensus existence: $\text{FindConsensus}(cs, t) = \text{Some}(c) \implies \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t$ (consensus requires threshold agreement)
- Threshold requirement: $\text{FindConsensus}(cs, t) = \text{Some}(c) \implies$ at least $\lceil |cs| \times t \rceil$ commitments match $c$ (integer threshold)
- No consensus: $\text{FindConsensus}(cs, t) = \text{None} \implies \nexists c \in cs: \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t$ (no commitment meets threshold)
- Minimum peers: $\text{FindConsensus}(cs, t)$ requires $|cs| \geq \text{min\_peers}$ (enough peers for consensus)
- Deterministic: $\text{FindConsensus}(cs_1, t_1) = \text{FindConsensus}(cs_2, t_2) \iff cs_1 = cs_2 \land t_1 = t_2$
- Result type: $\text{FindConsensus}(cs, t) \in \{\text{Some}(\mathcal{UC}), \text{None}\}$
- Threshold range: $\text{FindConsensus}(cs, t)$ requires $t \in [0, 1]$ (threshold must be valid probability)

For commitments $cs \in [\mathcal{UC}]$ and threshold $t \in [0,1]$:

$$\text{FindConsensus}(cs, t) = \begin{cases}
c & \text{if } \exists c \in cs: \frac{|\{c' \in cs : c' = c\}|}{|cs|} \geq t \\
\text{None} & \text{otherwise}
\end{cases}$$

**VerifyConsensusCommitment**: $\mathcal{UC} \times [\mathcal{H}] \rightarrow \{\text{valid}, \text{invalid}\}$

**Properties**:
- PoW verification: $\text{VerifyConsensusCommitment}(uc, hs) = \text{valid} \implies \text{VerifyPoW}(uc.\text{block\_hash}, hs) = \text{true}$ (PoW must be valid)
- Header chain: $\text{VerifyConsensusCommitment}(uc, hs) = \text{valid} \implies uc.\text{block\_hash} \in hs$ (block hash in header chain)
- Commitment validity: $\text{VerifyConsensusCommitment}(uc, hs) = \text{valid} \implies$ commitment $uc$ is cryptographically valid
- Supply verification: $\text{VerifyConsensusCommitment}(uc, hs) = \text{valid} \implies \text{VerifySupply}(uc.\text{total\_supply}, uc.\text{block\_height}) = \text{true}$
- Result type: $\text{VerifyConsensusCommitment}(uc, hs) \in \{\text{valid}, \text{invalid}\}$
- Deterministic: $\text{VerifyConsensusCommitment}(uc_1, hs_1) = \text{VerifyConsensusCommitment}(uc_2, hs_2) \iff uc_1 = uc_2 \land hs_1 = hs_2$
- Non-empty headers: $\text{VerifyConsensusCommitment}(uc, hs)$ requires $|hs| > 0$ (header chain must not be empty)

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

**Property**: $\text{ConnectBlock}(b, us, h) = \text{valid} \land \text{SignetChallenge}(n) \neq \emptyset \implies \text{CheckSignetBlockSolution}(b, n) = \text{valid}$

## 12. Mining Protocol

### 12.2 Coinbase Transaction

**Coinbase Transaction**: Special transaction with no inputs that creates new bitcoins

**CreateCoinbaseTransaction**: $\mathbb{N} \times \mathbb{Z} \times \mathbb{H} \times \mathbb{S} \rightarrow \mathcal{TX}$

Constructs a valid coinbase transaction for block at height $h$ with total fees $fees$, witness commitment hash $witness\_commitment$, and optional extra data $extra\_data$.

**Properties**:
- Single input: $\text{CreateCoinbaseTransaction}(h, fees, wc, ed)$ has exactly one input with $prevout = \text{null}$
- Output value: $\text{CreateCoinbaseTransaction}(h, fees, wc, ed).\text{outputs}[0].\text{value} = \text{GetBlockSubsidy}(h) + fees$
- LockTime: $\text{CreateCoinbaseTransaction}(h, fees, wc, ed).\text{lockTime} = h - 1$
- Height encoding: $scriptSig$ encodes block height per BIP34
- Deterministic: Same inputs yield same transaction

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

**PROTOCOL.md** states consensus rules mainly as mathematical predicates, types, and state transitions (Sections 2–12 and cross-referenced clauses). This section adds consensus-critical material not covered by those predicates alone: **engineering invariants** in §13.3.1–§13.3.4 (checked arithmetic on amounts and fees, canonical serialization and decoding, exact resource-limit boundaries, and deterministic rejection of malformed data), each of which must align with observable mainnet behavior; and **cross-module integration properties** in §13.3.5. Implementations must satisfy this section as strictly as the rest of the specification so nodes do not diverge.

#### 13.3.1 Integer Arithmetic Overflow/Underflow

**Critical Requirement**: All monetary value arithmetic must use checked operations to prevent overflow/underflow.

**Edge Cases**:
1. **Value Summation**: Input/output value summation can overflow `i64::MAX` when combining many large UTXOs
2. **Fee Calculation**: `total_in - total_out` can underflow or overflow near boundaries
3. **Coinbase Value**: `subsidy + fees` can exceed `MAX_MONEY` if not checked
4. **Fee Accumulation**: Summing fees across block transactions can overflow

**Implementation**: Use `checked_add()` and `checked_sub()` for all value arithmetic. Satoshi-denominated amounts must follow the same overflow and range rules as the live network (typically a signed 64-bit money type with `MAX_MONEY` bounds).

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

**Theorem 13.3.5.2** (Locktime/Script Integration): Locktime validation integrates correctly with script execution:

$$\forall tx \in \mathcal{TX}, script \in \mathcal{SC}, lt \in \mathbb{N}_{32}:$$
$$\text{ExecuteScript}(script, tx, lt) \text{ uses consistent locktime validation}$$

*Proof*: Script execution uses the same locktime validation functions as standalone locktime checks, ensuring consistency between script-level and transaction-level locktime validation. This is proven by blvm-spec-lock formal verification.

**Theorem 13.3.5.3** (Economic/Block Integration): Economic rules integrate correctly with block validation:

$$\forall b \in \mathcal{B}, h \in \mathbb{N}:$$
$$\text{ConnectBlock}(b, us, h) \text{ enforces economic invariants (subsidy, fees, supply limits)}$$

*Proof*: Block connection validates economic rules (subsidy calculation, fee validation, supply limits) as part of the block validation process, ensuring economic correctness is maintained. This is proven by blvm-spec-lock formal verification.

