# BLVM Bitcoin Consensus Specification

**Version 1.0**  
**Status:** Draft protocol specification (RFC-style register)  
**Source of truth for mathematics:** [THE_ORANGE_PAPER.md](THE_ORANGE_PAPER.md) → [PROTOCOL.md](PROTOCOL.md)  
**Reference implementation:** [blvm-consensus](https://github.com/BTCDecoded/blvm-consensus)

---

## Introduction

This document is the BLVM Bitcoin Consensus Specification: a structured, numbered register of every Bitcoin consensus rule, invariant, and theorem covered by the Orange Paper and implemented in `blvm-consensus`. Each entry states what **must** hold on the network using RFC 2119 language (MUST, MUST NOT, SHALL, SHALL NOT). It is **implementation-agnostic** — it describes required outcomes, not how any node achieves them. The Orange Paper ([PROTOCOL.md](PROTOCOL.md)) provides the formal mathematical foundation (functions, theorems, and `F_*` formula witnesses) for each rule; `blvm-consensus` is the reference Rust implementation bound via `#[spec_locked]` annotations and Z3 verification through `blvm-spec-lock`.

**Rule entry format:**

| Field | Description |
|-------|-------------|
| **ID** | Stable identifier: category prefix + sequence number (e.g. `HDR-001`) |
| **Rule** | Single-sentence invariant in MUST/MUST NOT language |
| **Specification** | Orange Paper section and theorem/formula reference |
| **Implementation** | Function path and crate; `Z3-verified` if a spec-lock proof exists |
| **Enforcement** | `consensus` (`blvm-consensus`), `chain` (`blvm-node` / chain index), or `both` |

Use **UNIMPLEMENTED** only when no crate enforces the rule yet. Use **UNSPECIFIED** when code exists but Orange Paper lacks a named function. Rules enforced outside `blvm-consensus` by design (e.g. parent hash linkage) are **not** UNIMPLEMENTED — cite the chain-layer function and set **Enforcement: chain**.

**Category prefixes:** `HDR` header · `BLK` block · `TX` transaction · `CB` coinbase · `SC` script · `UTX` UTXO · `CTX` contextual · `SF` soft fork · `CONST` constants · `ECO` economic · `POW` proof of work · `SEG` SegWit · `TAP` Taproot · `REORG` reorganization · `SEC` security · `ENG` engineering · `MEM` mempool relay policy

---

## 1. Header Validation

Rules H01–H08 from Orange Paper [§5.3.1](PROTOCOL.md#531-header-validation).

### HDR-001
- **Rule:** A block header version MUST be at least 1; version 0 MUST NOT be accepted.
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H01, **F_HeaderVersionFloor**. Unconditional; enforced even without `TimeContext` (§5.3.1 Notes).
- **Implementation:** `block::header::validate_block_header` — Z3-verified (F_HeaderVersionFloor)

### HDR-002
- **Rule:** A block header version MUST be at least the height-dependent minimum enforced by BIP90 (≥ 2 after BIP34, ≥ 3 after BIP66, ≥ 4 after BIP65).
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H02, [§5.4.4](PROTOCOL.md#544-bip90-block-version-enforcement) BIP90Check, **Theorem 5.4.4**
- **Implementation:** `bip_validation::check_bip90` — Z3-verified (spec_locked)

### HDR-003
- **Rule:** A block header timestamp MUST NOT be zero.
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H03. Unconditional; enforced even without `TimeContext` (§5.3.1 Notes).
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

### HDR-004
- **Rule:** A block header timestamp MUST NOT exceed network time plus 7,200 seconds (T_future).
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H04, [§4.4](PROTOCOL.md#44-difficulty-constants) T_future. Requires `TimeContext`; not enforced during headers-first sync (§5.3.1 Notes).
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

### HDR-005
- **Rule:** A block header timestamp MUST be at least the median time past of recent headers when time context is available (BIP113).
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H05, [§5.5](PROTOCOL.md#55-sequence-locks-bip68) GetMedianTimePast. Requires `TimeContext`; not enforced during headers-first sync (§5.3.1 Notes).
- **Implementation:** `block::header::validate_block_header`, `bip113::get_median_time_past` — Z3-verified (spec_locked)

### HDR-006
- **Rule:** A block header compact difficulty field (bits) MUST NOT be zero.
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H06, **F_HeaderBitsFloor**. Unconditional; enforced even without `TimeContext` (§5.3.1 Notes).
- **Implementation:** `block::header::validate_block_header` — Z3-verified (F_HeaderBitsFloor)

### HDR-007
- **Rule:** A block header MUST satisfy proof of work: double-SHA256(serialized header) MUST be less than ExpandTarget(bits).
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H07, [§7.2](PROTOCOL.md#72-block-validation) CheckProofOfWork
- **Implementation:** `pow::check_proof_of_work` — Z3-verified (Tier 1)

### HDR-008
- **Rule:** A block header prev_block_hash MUST equal the hash of the parent header (chain linkage).
- **Specification:** [§5.3.1](PROTOCOL.md#531-header-validation) H08
- **Implementation:** `block::validate_prev_block_hash`, `block::block_header_hash` — spec_locked [§5.3.1](PROTOCOL.md#531-header-validation)
- **Enforcement:** both — pure predicate in `blvm-consensus`; `blvm-node` calls it (or equivalent check) on sync/submitblock/IBD before `connect_block`

---

## 2. Block Structure

Rules governing block body composition and connection.

### BLK-001
- **Rule:** A valid block MUST contain at least one transaction.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` ([§5.3.3](PROTOCOL.md#533-connectblock-pipeline) pipeline) — documented orchestration

### BLK-002
- **Rule:** The first transaction in a valid block MUST be a coinbase transaction.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock, **Theorem 6.4.1**
- **Implementation:** `block::connect::connect_block_inner` — Z3-verified via `transaction::is_coinbase`

### BLK-003
- **Rule:** Every transaction in a block MUST pass CheckTransaction before the block is accepted.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` → `transaction::check_transaction` — Z3-verified (spec_locked)

### BLK-004
- **Rule:** Every transaction in a block MUST pass CheckTxInputs against the evolving UTXO set at the connecting height.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` → `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### BLK-005
- **Rule:** Every transaction in a block MUST pass script verification (VerifyScript) against the evolving UTXO set.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock, [§5.2](PROTOCOL.md#52-script-execution) VerifyScript
- **Implementation:** `block::connect::connect_block_inner` → `script::verify_script` — Z3-verified (spec_locked)

### BLK-006
- **Rule:** The coinbase output value MUST NOT exceed block subsidy plus the sum of non-coinbase transaction fees.
- **Specification:** [§5.3](PROTOCOL.md#53-block-validation) ConnectBlock, [§8.2.1](PROTOCOL.md#821-integration-properties) Economic Block Integration
- **Implementation:** `economic::check_coinbase_subsidy` — spec_locked [§5.3](PROTOCOL.md#53-block-validation)

### BLK-007
- **Rule:** Total block weight MUST NOT exceed W_max (4,000,000 weight units).
- **Specification:** [§11.1.1](PROTOCOL.md#1111-weight-and-size-calculations) CalculateBlockWeight, [§4.2](PROTOCOL.md#42-block-constants) W_max
- **Implementation:** `segwit::calculate_block_weight` — Z3-verified (spec_locked)

### BLK-008
- **Rule:** Total block signature-operation cost MUST NOT exceed S_max (80,000).
- **Specification:** [§5.2.2](PROTOCOL.md#522-signature-operation-counting) GetTransactionSigOpCost, [§4.2](PROTOCOL.md#42-block-constants) S_max
- **Implementation:** `sigop::get_transaction_sigop_cost` — Z3-verified (spec_locked)

### BLK-009
- **Rule:** The block transaction merkle root MUST match ComputeMerkleRoot over transaction txids.
- **Specification:** [§8.4.1](PROTOCOL.md#841-computemerkleroot) ComputeMerkleRoot, **Theorem 8.5**
- **Implementation:** `block::compute_block_tx_ids_spec`, `mining::calculate_merkle_root` — Z3-verified (Tier 1 for tx-id spec)

### BLK-010
- **Rule:** The merkle tree MUST reject blocks where identical adjacent hashes appear at any level (CVE-2012-2459).
- **Specification:** [§8.4.1](PROTOCOL.md#841-computemerkleroot) ComputeMerkleRoot, **Theorem 8.6**, **Corollary 8.1**
- **Implementation:** `mining::calculate_merkle_root` — Z3-verified (spec_locked)

### BLK-011
- **Rule:** SegWit blocks MUST validate witness commitment and weight limits when SegWit rules apply.
- **Specification:** [§11.1.7](PROTOCOL.md#1117-block-validation) ValidateSegWitBlock
- **Implementation:** `segwit::validate_segwit_block`, `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### BLK-012
- **Rule:** After BIP54 activation, each non-coinbase transaction MUST have total sigops ≤ 2,500.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) BIP54 per-tx sigops
- **Implementation:** `bip_validation::check_bip54_sigop_limit` — spec_locked [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup)

### BLK-013
- **Rule:** After BIP54 activation, non-coinbase transactions with witness-stripped size exactly 64 bytes MUST be invalid.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) BIP54 64-byte tx rule
- **Implementation:** `bip_validation::check_bip54_tx_stripped_size` — spec_locked [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup)

### BLK-014
- **Rule:** After BIP54 activation, at difficulty period boundaries block timestamps MUST satisfy timewarp mitigation rules.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) BIP54TimewarpCheck
- **Implementation:** `bip_validation::check_bip54_timewarp` — spec_locked [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup)

---

## 3. Transaction Structure

Structural and local validation rules for transactions.

### TX-001
- **Rule:** A transaction MUST have at least one input and at least one output.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-002
- **Rule:** Each output value MUST satisfy 0 ≤ value ≤ M_max.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction, [§4.1](PROTOCOL.md#41-monetary-constants) M_max
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-003
- **Rule:** The sum of output values MUST NOT exceed M_max.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-004
- **Rule:** No two inputs in a transaction MUST share the same prevout (intra-transaction duplicate spends forbidden).
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-005
- **Rule:** Non-coinbase transactions MUST have non-null prevouts on all inputs.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-006
- **Rule:** Input count MUST NOT exceed M_max_inputs and output count MUST NOT exceed M_max_outputs.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction Properties
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-007
- **Rule:** Transaction stripped size × 4 MUST NOT exceed W_max (per-transaction weight bound).
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction, CalculateTransactionSize
- **Implementation:** `transaction::check_transaction`, `transaction::calculate_transaction_size` — Z3-verified (spec_locked)

### TX-008
- **Rule:** Transaction ID MUST be a 32-byte double-SHA256 hash of the legacy serialization.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CalculateTxId
- **Implementation:** `block::apply::calculate_tx_id`, `mempool::calculate_tx_id` — Z3-verified (spec_locked)

### TX-009
- **Rule:** Valid non-coinbase transactions MUST have input sum ≥ output sum; fee MUST be non-negative.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTxInputs, **Theorem 6.5** (Fee Non-Negativity)
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### TX-010
- **Rule:** Coinbase transactions MUST return fee zero from CheckTxInputs.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTxInputs
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### TX-011
- **Rule:** Legacy (SigVersion::Base) sighash MUST apply FindAndDelete for signature pushes before hashing.
- **Specification:** [§5.1.1](PROTOCOL.md#511-transaction-sighash-calculation) CalculateSighash, **Theorem 5.1.3**, **F_FindAndDelete**
- **Implementation:** `script::find_and_delete`, `transaction_hash::compute_legacy_sighash_*` — Z3-verified (spec_locked)

### TX-012
- **Rule:** WitnessV0 and Tapscript sighash MUST NOT apply FindAndDelete.
- **Specification:** [§5.1.1](PROTOCOL.md#511-transaction-sighash-calculation) SigVersion
- **Implementation:** `transaction_hash::calculate_bip143_sighash`, `taproot::compute_taproot_signature_hash` — Z3-verified (spec_locked)

### TX-013
- **Rule:** Legacy scriptCode MUST strip OP_CODESEPARATOR (0xab) at opcode positions only.
- **Specification:** [§5.1.1](PROTOCOL.md#511-transaction-sighash-calculation) SerializeScriptCode
- **Implementation:** `transaction_hash::serialize_script_code_for_legacy_sighash` — Z3-verified (spec_locked)

### TX-014
- **Rule:** Post-BIP66, sighash byte 0x00 MUST be treated as Invalid; pre-BIP66 it MUST map to SIGHASH_ALL.
- **Specification:** [§5.1.1](PROTOCOL.md#511-transaction-sighash-calculation) SighashType, **Theorem 5.1.2**
- **Implementation:** `transaction_hash::calculate_transaction_sighash` — Z3-verified (spec_locked)

### TX-015
- **Rule:** P2SH sighash MUST use the redeem script, not the scriptPubKey.
- **Specification:** [§5.1.1](PROTOCOL.md#511-transaction-sighash-calculation) SighashScriptCode, **Theorem 5.1.1**
- **Implementation:** `transaction_hash::calculate_transaction_sighash` — Z3-verified (spec_locked)

### TX-016
- **Rule:** BIP143 witness sighash MUST bind prevouts, sequences, outpoint, scriptCode, amount, outputs, locktime, and sighash type.
- **Specification:** [§11.1.9](PROTOCOL.md#1119-bip143-witness-sighash-computewitnesssignaturehash) ComputeWitnessSignatureHash, **Theorem 11.1.2**
- **Implementation:** `transaction_hash::calculate_bip143_sighash` — Z3-verified (spec_locked)

### TX-017
- **Rule:** P2WPKH BIP143 scriptCode MUST be the 25-byte P2PKH expansion, NOT the raw 22-byte witness program.
- **Specification:** [§11.1.9.1](PROTOCOL.md#11191-derivewitnessscriptcode-bip143-scriptcode) DeriveWitnessScriptCode, **Theorem 11.1.3**
- **Implementation:** `transaction_hash::derive_bip143_script_code_p2wpkh` — Z3-verified (spec_locked)

### TX-018
- **Rule:** P2WSH BIP143 scriptCode MUST be the witness script (last witness stack element).
- **Specification:** [§11.1.9.1](PROTOCOL.md#11191-derivewitnessscriptcode-bip143-scriptcode) DeriveWitnessScriptCode
- **Implementation:** `transaction_hash::derive_bip143_script_code` — Z3-verified (spec_locked)

---

## 4. Coinbase Rules

Rules specific to coinbase transaction structure and validation.

### CB-001
- **Rule:** A coinbase transaction MUST have exactly one input with null hash (0³²) and index 0xFFFFFFFF.
- **Specification:** [§6.4](PROTOCOL.md#64-coinbase-detection) IsCoinbase, **Theorem 6.4.1**
- **Implementation:** `transaction::is_coinbase` — Z3-verified (spec_locked)

### CB-002
- **Rule:** Coinbase scriptSig length MUST be between 2 and 100 bytes inclusive.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTransaction, [§13.3.3](PROTOCOL.md#1333-resource-limit-enforcement) **F_CoinbaseScriptSigMin**, **F_CoinbaseScriptSigMax**
- **Implementation:** `transaction::check_transaction` — Z3-verified (F_* formulas)

### CB-003
- **Rule:** After BIP34 activation, coinbase scriptSig MUST encode the block height.
- **Specification:** [§5.4.2](PROTOCOL.md#542-bip34-block-height-in-coinbase) BIP34Check, **Theorem 5.4.2**
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (spec_locked)

### CB-004
- **Rule:** Before BIP34 activation, height-in-coinbase check MUST pass regardless of scriptSig content.
- **Specification:** [§5.4.2](PROTOCOL.md#542-bip34-block-height-in-coinbase) **F_BIP34PreActivationPass**
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (F_BIP34PreActivationPass)

### CB-005
- **Rule:** Before BIP30 deactivation (mainnet h ≤ 91,722), coinbase txid MUST NOT already exist in the UTXO set.
- **Specification:** [§5.4.1](PROTOCOL.md#541-bip30-duplicate-coinbase-prevention) BIP30Check, **Theorem 5.4.1**
- **Implementation:** `bip_validation::check_bip30` — Z3-verified (spec_locked)

### CB-006
- **Rule:** After BIP30 deactivation, duplicate-coinbase check MUST always pass.
- **Specification:** [§5.4.1](PROTOCOL.md#541-bip30-duplicate-coinbase-prevention) **F_BIP30DeactivationPass**
- **Implementation:** `bip_validation::check_bip30` — Z3-verified (F_BIP30DeactivationPass)

### CB-007
- **Rule:** After BIP54 activation, coinbase lockTime MUST equal height − 13 and first input sequence MUST NOT be 0xFFFFFFFF.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) CheckBip54Coinbase
- **Implementation:** `bip_validation::check_bip54_coinbase` — Z3-verified (spec_locked)

### CB-008
- **Rule:** Coinbase outputs MUST NOT be spendable until COINBASE_MATURITY (100) blocks after creation.
- **Specification:** [§4.2](PROTOCOL.md#42-block-constants) R (coinbase maturity constant)
- **Implementation:** `transaction::check_coinbase_maturity` — spec_locked [§5.1](PROTOCOL.md#51-transaction-validation)

### CB-009
- **Rule:** SegWit coinbase MUST include a valid witness commitment output when witness data is present.
- **Specification:** [§11.1.5](PROTOCOL.md#1115-witness-commitment-validation) ValidateWitnessCommitment
- **Implementation:** `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### CB-010
- **Rule:** Coinbase witness merkle leaf MUST be fixed to 0³².
- **Specification:** [§11.1.4](PROTOCOL.md#1114-witness-merkle-root) ComputeWitnessMerkleRoot
- **Implementation:** `segwit::compute_witness_merkle_root` — Z3-verified (spec_locked)

---

## 5. Script Validation

Script execution, flags, and signature-operation counting.

### SC-001
- **Rule:** Script execution MUST succeed only when it terminates with exactly one stack item that evaluates to true.
- **Specification:** [§5.2](PROTOCOL.md#52-script-execution) EvalScript
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-002
- **Rule:** Script execution MUST fail if combined main and alt stack size exceeds L_stack (1,000).
- **Specification:** [§5.2](PROTOCOL.md#52-script-execution) EvalScript, [§4.3](PROTOCOL.md#43-script-constants) L_stack, [§13.3.3](PROTOCOL.md#1333-resource-limit-enforcement) **F_StackSizeSafe**
- **Implementation:** `script::eval_script` — Z3-verified (F_StackSizeSafe)

### SC-003
- **Rule:** Base and WitnessV0 scripts MUST NOT exceed L_script (10,000) bytes or L_ops (201) non-push opcodes.
- **Specification:** [§5.2](PROTOCOL.md#52-script-execution) EvalScript, [§8.3](PROTOCOL.md#83-cryptographic-security) ScriptSecure, **Theorem 8.4**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-004
- **Rule:** Individual stack and witness elements MUST NOT exceed L_element (520) bytes.
- **Specification:** [§4.3](PROTOCOL.md#43-script-constants) L_element, [§11.1.2](PROTOCOL.md#1112-witness-structure-validation) ValidateSegWitWitnessStructure
- **Implementation:** `witness::validate_segwit_witness_structure` — Z3-verified (spec_locked)

### SC-005
- **Rule:** When SCRIPT_VERIFY_P2SH is active and scriptPubKey is P2SH, scriptSig MUST pass push-only validation before execution.
- **Specification:** [§5.2](PROTOCOL.md#52-script-execution) VerifyScript, [§5.2.1](PROTOCOL.md#521-p2sh-push-only-validation) P2SHPushOnlyCheck, **Theorem 5.2.1**
- **Implementation:** `script::verify_script`, `script::p2sh_push_only_check` — Z3-verified (spec_locked)

### SC-006
- **Rule:** P2SH scriptPubKey MUST be exactly 23 bytes: OP_HASH160 PUSH20 … OP_EQUAL.
- **Specification:** [§5.2.1](PROTOCOL.md#521-p2sh-push-only-validation) IsP2SH
- **Implementation:** `sigop::is_pay_to_script_hash` — Z3-verified (spec_locked)

### SC-007
- **Rule:** OP_CHECKSIG/CHECKSIGVERIFY MUST count as 1 sigop; CHECKMULTISIG counts n (accurate) or 20 (legacy inaccurate).
- **Specification:** [§5.2.2](PROTOCOL.md#522-signature-operation-counting) CountSigOpsInScript
- **Implementation:** `sigop::count_sigops_in_script` — Z3-verified (spec_locked)

### SC-008
- **Rule:** Coinbase transactions MUST contribute zero P2SH sigops.
- **Specification:** [§5.2.2](PROTOCOL.md#522-signature-operation-counting) GetP2SHSigOpCount
- **Implementation:** `sigop::get_p2sh_sigop_count` — Z3-verified (spec_locked)

### SC-009
- **Rule:** Witness v0 sigops MUST be counted; Taproot (v1) MUST contribute zero to CountWitnessSigOps.
- **Specification:** [§5.2.2](PROTOCOL.md#522-signature-operation-counting) CountWitnessSigOps, [§11.2.8](PROTOCOL.md#1128-tapscript-opcodes-and-sigop-counting-bip-342)
- **Implementation:** `sigop::count_witness_sigops`, `sigop::count_tapscript_sigops` — Z3-verified (spec_locked)

### SC-010
- **Rule:** Tapscript sigop budget MUST count opcodes 0xac, 0xad, 0xba only at opcode positions (not inside pushes).
- **Specification:** [§11.2.8](PROTOCOL.md#1128-tapscript-opcodes-and-sigop-counting-bip-342) CountTapscriptSigOps
- **Implementation:** `sigop::count_tapscript_sigops` — Z3-verified (spec_locked)

### SC-011
- **Rule:** OP_CHECKMULTISIG dummy stack element MUST be empty (OP_0) after BIP147 activation.
- **Specification:** [§5.4.5](PROTOCOL.md#545-bip147-nulldummy-enforcement) BIP147Check, **Theorem 5.4.5**
- **Implementation:** `bip_validation::check_bip147` — Z3-verified (spec_locked)

### SC-012
- **Rule:** After BIP66 activation, ECDSA signatures MUST be strictly DER-encoded.
- **Specification:** [§5.4.3](PROTOCOL.md#543-bip66-strict-der-signature-validation) BIP66Check, **Theorem 5.4.3**
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (spec_locked)

### SC-013
- **Rule:** OP_VER MUST fail only when fExec=true; in false conditional branches it MUST be skipped without failure.
- **Specification:** [§5.2.4](PROTOCOL.md#524-conditional-opcode-execution) **Theorem 5.2.3**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-014
- **Rule:** Under SCRIPT_VERIFY_MINIMALIF, IF/NOTIF condition bytes MUST be minimal: empty is valid; length > 1 is invalid.
- **Specification:** [§5.2.4](PROTOCOL.md#524-conditional-opcode-execution) IsMinimalIfCondition, **F_MinimalIfEmptyTrue**, **F_MinimalIfLongFalse**
- **Implementation:** `script::control_flow::is_minimal_if_condition` — Z3-verified (F_* formulas)

### SC-015
- **Rule:** Script verification flags MUST be monotone in height (never removed once activated).
- **Specification:** [§5.2.5](PROTOCOL.md#525-script-verification-flags) CalculateScriptFlags
- **Implementation:** `block::script_cache::calculate_script_flags_for_block` — Z3-verified (spec_locked)

### SC-016
- **Rule:** When a block hash is in ScriptFlagExceptions, override flags MUST be used instead of CalculateScriptFlags.
- **Specification:** [§5.2.6](PROTOCOL.md#526-script-flag-exceptions) ScriptFlagExceptions, GetBlockScriptFlags
- **Implementation:** `block::script_cache::get_block_script_flags` — Z3-verified (spec_locked)

### SC-017
- **Rule:** SCRIPT_VERIFY_WITNESS MUST activate only when the transaction has non-empty input witness or IsSegWitTransaction.
- **Specification:** [§5.2.5](PROTOCOL.md#525-script-verification-flags) CalculateScriptFlags
- **Implementation:** `block::script_cache::tx_has_nonempty_input_witness` — Z3-verified (spec_locked)

### SC-018
- **Rule:** OP_CHECKLOCKTIMEVERIFY (BIP65) MUST reject when locktime types mismatch; MUST require tx.lockTime ≥ stack value when types match.
- **Specification:** [§5.4.7](PROTOCOL.md#547-bip65-op_checklocktimeverify-cltv) BIP65Check, **Theorem 5.4.7.3–5.4.7.4**, **F_BIP65Passes**, **F_BIP65Rejects***
- **Implementation:** `locktime::check_bip65` — Z3-verified (F_* formulas)

### SC-019
- **Rule:** Locktime values below 500,000,000 MUST be block-height type; values ≥ 500,000,000 MUST be timestamp type.
- **Specification:** [§5.4.7](PROTOCOL.md#547-bip65-op_checklocktimeverify-cltv) GetLocktimeType, [§13.3.5](PROTOCOL.md#1335-integration-proofs) **F_LocktimeTypeIsHeight**, **F_LocktimeTypeIsTimestamp**
- **Implementation:** `locktime::get_locktime_type` — Z3-verified (F_* formulas)

### SC-020
- **Rule:** OP_CHECKSIGFROMSTACK (BIP348) MUST execute only in Tapscript; zero-length pubkey MUST fail; empty sig MUST succeed.
- **Specification:** [§5.4.8](PROTOCOL.md#548-bip348-op_checksigfromstack-csfs) BIP348Check, **Theorem 5.4.8.2–5.4.8.5**, **F_CSFS***
- **Implementation:** `bip348::verify_signature_from_stack` — Z3-verified (F_* formulas)

### SC-021
- **Rule:** OP_CHECKTEMPLATEVERIFY (BIP119) MUST succeed iff TemplateHash(tx,i) equals the stack hash (when deployed).
- **Specification:** [§5.4.6](PROTOCOL.md#546-bip119-op_checktemplateverify-ctv) BIP119Check, **Theorem 5.4.6.1–5.4.6.4**
- **Implementation:** `bip119::validate_template_hash` — Z3-verified (spec_locked; feature-gated)

### SC-022
- **Rule:** CScriptNum decoding for OP_CHECKMULTISIG m and n MUST treat empty bytes as zero.
- **Specification:** [§5.4.5.1](PROTOCOL.md#545-bip147-nulldummy-enforcement) **Theorem 5.4.5.1**, DecodeCScriptNum
- **Implementation:** `script::script_num_decode` — Z3-verified (spec_locked)

---

## 6. UTXO Rules

UTXO set transitions and invariants.

### UTX-001
- **Rule:** Non-coinbase ApplyTransaction MUST remove all spent prevouts and add all new outputs.
- **Specification:** [§5.3.2](PROTOCOL.md#532-transaction-application-equivalence) ApplyTransaction
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### UTX-002
- **Rule:** Coinbase ApplyTransaction MUST only add outputs (no inputs removed).
- **Specification:** [§5.3.2](PROTOCOL.md#532-transaction-application-equivalence) ApplyTransaction
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### UTX-003
- **Rule:** ApplyTransaction and ApplyTransactionWithId MUST produce identical UTXO results.
- **Specification:** [§5.3.2](PROTOCOL.md#532-transaction-application-equivalence) **Theorem 5.3.2**
- **Implementation:** `block::apply::apply_transaction`, `block::apply::apply_transaction_with_id` — Z3-verified (spec_locked)

### UTX-004
- **Rule:** ApplyUndo after ConnectBlock MUST restore the prior UTXO set (disconnect idempotency).
- **Specification:** [§5.3.2](PROTOCOL.md#532-transaction-application-equivalence), [§8.2.1](PROTOCOL.md#821-integration-properties) ConnectBlock-DisconnectBlock Idempotency
- **Implementation:** `reorganization::disconnect_block` — Z3-verified (spec_locked)

### UTX-005
- **Rule:** The sum of all UTXO values MUST equal total money supply at every height.
- **Specification:** [§8.1](PROTOCOL.md#81-economic-security) **Theorem 8.1** (UTXO Set Invariant)
- **Implementation:** `economic::verify_utxo_supply` — spec_locked [§8.1](PROTOCOL.md#81-economic-security)

### UTX-006
- **Rule:** Valid non-coinbase transactions MUST conserve value: input sum ≥ output sum.
- **Specification:** [§8.1](PROTOCOL.md#81-economic-security) Conservation of Value
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### UTX-007
- **Rule:** Spent prevouts MUST exist in the UTXO set before a non-coinbase transaction is accepted.
- **Specification:** [§5.1](PROTOCOL.md#51-transaction-validation) CheckTxInputs
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

---

## 7. Contextual Validation

Height-dependent, time-dependent, and sequence-lock rules.

### CTX-001
- **Rule:** Sequence lock bit 31 set (0x80000000) MUST disable relative locktime for that input.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) IsSequenceDisabled, **F_SequenceDisabledWhenBit31Set**
- **Implementation:** `locktime::is_sequence_disabled` — Z3-verified (F_* formulas)

### CTX-002
- **Rule:** Sequence lock bit 22 set (0x00400000) MUST mean time-based lock; clear MUST mean height-based.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) ExtractSequenceTypeFlag, **F_SequenceTypeTimeWhenBit22Set**, **F_SequenceTypeHeightWhenBit22Clear**
- **Implementation:** `locktime::extract_sequence_type_flag` — Z3-verified (F_* formulas)

### CTX-003
- **Rule:** Extracted sequence locktime value MUST be in [0, 65535] (lower 16 bits).
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) **F_SequenceLockTimeMask**
- **Implementation:** `locktime::extract_sequence_locktime_value` — Z3-verified (F_* formulas)

### CTX-004
- **Rule:** Sequence locks MUST only be enforced when tx.version ≥ 2 and CSV script flag (0x400) is active.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) CalculateSequenceLocks
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (spec_locked)

### CTX-005
- **Rule:** Time-based sequence locks MUST use value × 512 seconds added to coin MTP − 1.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) CalculateSequenceLocks, **F_SequenceTimeEncoding**
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (F_* formulas)

### CTX-006
- **Rule:** Height-based sequence locks MUST use coin height + value − 1.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) CalculateSequenceLocks
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (spec_locked)

### CTX-007
- **Rule:** EvaluateSequenceLocks MUST return true iff block height > min_height (when set) AND block time > min_time (when set).
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) EvaluateSequenceLocks, **F_EvalSeqLocks***, **Theorem 5.5.2**
- **Implementation:** `sequence_locks::evaluate_sequence_locks` — Z3-verified (F_* formulas)

### CTX-008
- **Rule:** Median time past MUST be the median of the last up-to-11 block timestamps (BIP113).
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68) GetMedianTimePast
- **Implementation:** `bip113::get_median_time_past` — Z3-verified (spec_locked)

### CTX-009
- **Rule:** Mempool admission MUST require absolute and relative locktimes satisfied at chain tip.
- **Specification:** [§9.1.1](PROTOCOL.md#911-transaction-finality) CheckFinalTxAtTip
- **Implementation:** `mempool::is_final_tx` — Z3-verified (spec_locked)

### CTX-010
- **Rule:** Difficulty retarget timespan MUST be clamped to [T_expected/4, 4×T_expected] (factor-of-4 bound).
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) GetNextWorkRequired, **Theorem 7.1**
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

### CTX-011
- **Rule:** When EnforceBIP94(n), first block of new difficulty period MUST have time ≥ prev.time − 600.
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) BIP94 Timestamp Rule
- **Implementation:** `pow::get_next_work_required` — Z3-verified (spec_locked)

### CTX-012
- **Rule:** All monetary arithmetic MUST use checked add/sub to prevent overflow/underflow.
- **Specification:** [§13.3.1](PROTOCOL.md#1331-integer-arithmetic-overflowunderflow), **F_FeeArithmeticNonNeg**, **F_FeeArithmeticBounded**
- **Implementation:** `transaction::check_transaction`, `economic::calculate_fee` — Z3-verified (F_* formulas)

---

## 8. Activation Height Tables

Canonical activation and deactivation heights for this register (**not** Orange Paper [§8 Security Properties](PROTOCOL.md#8-security-properties)). Source: `blvm-primitives` constants (`BIP*_ACTIVATION_*`), `blvm-consensus::activation::ForkActivationTable`, Orange Paper [§5.4](PROTOCOL.md#54-bip-validation-rules) and [§5.2.5](PROTOCOL.md#525-script-verification-flags). Heights are **inclusive** (rule active when `height >= activation`, except BIP30 deactivation below).

### Table 1 — Soft fork activation heights

| Fork | BIP | Mainnet | Testnet | Regtest | Signet | Enforced by |
|------|-----|---------|---------|---------|--------|-------------|
| P2SH | 16 | 173,805 | 0 | 0 | 0 | `CalculateScriptFlags` / `ForkId::Bip16` |
| Height in coinbase | 34 | 227,931 | 21,111 | 0 | 1 | `BIP34Check`, `BIP90Check` (min version 2) |
| Strict DER | 66 | 363,725 | 330,776 | 0 | 1 | `BIP66Check`, `BIP90Check` (min version 3) |
| CLTV | 65 | 388,381 | 581,885 | 0 | 1 | `BIP65Check`, `BIP90Check` (min version 4) |
| CSV + sequence locks | 68/112 | 419,328 | 770,112 | 0 | 1 | `CalculateSequenceLocks`, `CalculateScriptFlags` |
| Median time past | 113 | 419,328 | 770,112 | 0 | 1 | `GetMedianTimePast` (header timestamp floor) |
| SegWit v0 | 141 | 481,824 | 834,624 | 0 | 1 | `ValidateSegWitBlock`, witness flags |
| NULLDUMMY | 147 | 481,824 | 834,624 | 0 | 1 | `BIP147Check` |
| Taproot | 341/342 | 709,632 | 2,011,968 | 0 | 1 | Taproot validation, `TaprootActivationHeight` |
| CTV | 119 | — (disabled) | — (disabled) | 0 | — (disabled) | `BIP119Check` (feature-gated; `u64::MAX` = never) |
| CSFS | 348 | — (disabled) | — (disabled) | 0 | — (disabled) | `BIP348Check` (feature-gated) |
| Consensus cleanup | 54 | — (disabled) | — (disabled) | configurable | — (disabled) | `IsBip54ActiveAt`, version bits |

**Notes:**
- SegWit and BIP147 share mainnet height 481,824 (same deployment).
- BIP68 and BIP112 share activation height; CSV script flag and sequence-lock enforcement activate together.
- CTV/CSFS/BIP54 default to inactive on mainnet/testnet (`activation height = u64::MAX` or 0 = disabled per fork table builder).
- Regtest: most forks active from height 0; BIP65 uses height 0 in `ForkActivationTable` (immediate).
- Signet: most soft forks active from height 1 (`ForkActivationTable`); Taproot activation helper returns 1; BIP54/CTV/CSFS default inactive (`u64::MAX`).

### Table 2 — BIP90 minimum block version (HDR-002)

| Condition (height h) | Minimum version |
|----------------------|-----------------|
| h < BIP34 activation | 1 |
| BIP34 ≤ h < BIP66 | 2 |
| BIP66 ≤ h < BIP65 | 3 |
| h ≥ BIP65 activation | 4 |

Versions retired after activation (informative): BIP34 retires 0,1; BIP66 retires 2; BIP65 retires 3.

### Table 3 — BIP30 deactivation and grandfathered blocks

| Network | Deactivation height | Effect |
|---------|---------------------|--------|
| Mainnet | 91,722 | BIP30 duplicate-coinbase check **inactive** when h > 91,722 |
| Testnet | 0 | BIP30 never enforced |
| Regtest | 0 | BIP30 never enforced |

**Grandfathered duplicate coinbases** (mainnet; allowed because BIP30 was deactivated before these blocks):

| Height | Block hash |
|--------|------------|
| 91,842 | `00000000000a4d0a398161ffc163c503763b1f4360639393e0e4c8e300e0caec` |
| 91,880 | `00000000000743f190a18c5577a3c2d2a1f610ae9601ac046a38084ccb7cd721` |

Enforced by `bip_validation::check_bip30` (consensus) using `ForkId::Bip30` (active when `height <= deactivation`).

### Table 4 — Consensus script verification flags at activation (mainnet)

| Flag | Value | Activation height | Always-on after activation? |
|------|-------|-------------------|----------------------------|
| SCRIPT_VERIFY_P2SH | 0x01 | 173,805 | Yes (all txs) |
| SCRIPT_VERIFY_DERSIG | 0x04 | 363,725 | Yes (consensus block validation) |
| SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY | 0x200 | 388,381 | Yes |
| SCRIPT_VERIFY_CHECKSEQUENCEVERIFY | 0x400 | 419,328 | Yes |
| SCRIPT_VERIFY_WITNESS | 0x800 | 481,824 | Per-tx (witness present or SegWit output) |
| SCRIPT_VERIFY_NULLDUMMY | 0x10 | 481,824 | Yes |
| SCRIPT_VERIFY_WITNESS_PUBKEYTYPE | 0x8000 | 709,632 | Per-tx (P2TR output in tx) |

Source: [§5.2.5](PROTOCOL.md#525-script-verification-flags) `CalculateScriptFlags`; implemented in `block::script_cache`.

---

## 9. Soft Fork Activation

BIP activation rule entries (refer to **[§8 of this register](#8-activation-height-tables)** for activation height tables). Individual SF-* rules state the MUST invariant; Table 1 is the canonical height register.

### SF-001
- **Rule:** SCRIPT_VERIFY_P2SH MUST activate at mainnet height 173,805.
- **Specification:** [§5.2.5](PROTOCOL.md#525-script-verification-flags) CalculateScriptFlags (BIP16)
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-002
- **Rule:** BIP34 (height in coinbase) MUST activate at mainnet height 227,931.
- **Specification:** [§5.4.2](PROTOCOL.md#542-bip34-block-height-in-coinbase) BIP34Check
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (spec_locked)

### SF-003
- **Rule:** BIP66 (strict DER) MUST activate at mainnet height 363,725.
- **Specification:** [§5.4.3](PROTOCOL.md#543-bip66-strict-der-signature-validation) BIP66Check
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (spec_locked)

### SF-004
- **Rule:** BIP65 (CLTV) MUST activate at mainnet height 388,381.
- **Specification:** [§5.4.7](PROTOCOL.md#547-bip65-op_checklocktimeverify-cltv) BIP65Check, [§5.2.5](PROTOCOL.md#525-script-verification-flags)
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-005
- **Rule:** BIP68/112 (CSV) MUST activate at mainnet height 419,328.
- **Specification:** [§5.5](PROTOCOL.md#55-sequence-locks-bip68), [§5.2.5](PROTOCOL.md#525-script-verification-flags)
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-006
- **Rule:** SegWit (BIP141/143/147) MUST activate at mainnet height 481,824.
- **Specification:** [§11.1](PROTOCOL.md#111-segregated-witness-segwit), [§5.4.5](PROTOCOL.md#545-bip147-nulldummy-enforcement) BIP147Check
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-007
- **Rule:** Taproot (BIP341/342) MUST activate at mainnet height 709,632.
- **Specification:** [§11.2](PROTOCOL.md#112-taproot) **F_TaprootActivationMainnet**
- **Implementation:** `activation::taproot_activation_height` — Z3-verified (F_TaprootActivationMainnet)

### SF-008
- **Rule:** Taproot MUST activate at testnet height 2,011,968, regtest height 0, and signet height 1.
- **Specification:** [§11.2](PROTOCOL.md#112-taproot) **F_TaprootActivationTestnet**, **F_TaprootActivationRegtest**; signet uses height 1 per `ForkActivationTable`
- **Implementation:** `activation::taproot_activation_height` — Z3-verified (F_* formulas)

### SF-009
- **Rule:** BIP54 version-bits signal MUST use bit 15 with start time 0.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) **F_Bip54SignalBit**, **F_Bip54StartTimeZero**
- **Implementation:** `version_bits::bip54_deployment_for_network` — Z3-verified (F_* formulas)

### SF-010
- **Rule:** IsBip54ActiveAt MUST return true at and after the configured activation threshold height.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) **F_BIP54ActivationThreshold**, IsBip54ActiveAt
- **Implementation:** `bip_validation::is_bip54_active_at` — Z3-verified (F_* formulas)

### SF-011
- **Rule:** Before BIP66 activation, DER check MUST pass for any signature.
- **Specification:** [§5.4.3](PROTOCOL.md#543-bip66-strict-der-signature-validation) **F_BIP66PreActivationPass**
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (F_BIP66PreActivationPass)

### SF-012
- **Rule:** Before BIP90 activation, version check MUST pass for any version ≥ 1.
- **Specification:** [§5.4.4](PROTOCOL.md#544-bip90-block-version-enforcement) **F_BIP90PreActivationPass**
- **Implementation:** `bip_validation::check_bip90` — Z3-verified (F_BIP90PreActivationPass)

### SF-013
- **Rule:** Before BIP147 activation, null-dummy check MUST pass regardless.
- **Specification:** [§5.4.5](PROTOCOL.md#545-bip147-nulldummy-enforcement) **F_BIP147PreActivationPass**
- **Implementation:** `bip_validation::check_bip147` — Z3-verified (F_BIP147PreActivationPass)

### SF-014
- **Rule:** All BIP rules MUST be enforced consistently after their activation heights.
- **Specification:** [§5.4](PROTOCOL.md#54-bip-validation-rules) **Corollary 5.4.1**
- **Implementation:** `block::connect::connect_block_inner` ([§5.3.3](PROTOCOL.md#533-connectblock-pipeline) pipeline + Corollary 5.4.1)

### SF-015
- **Rule:** BIP54 activation height MUST be discoverable from version-bits lock-in on the header chain.
- **Specification:** [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup) ActivationHeightFromVersionBits
- **Implementation:** `version_bits::activation_height_from_headers` — spec_locked [§5.4.9](PROTOCOL.md#549-bip54-consensus-cleanup)

---

## 10. Consensus Constants

Numeric limits referenced by consensus rules (Orange Paper [§4](PROTOCOL.md#4-consensus-constants)).

### CONST-001
- **Rule:** All monetary amounts MUST be denominated in satoshis; C = 10⁸ satoshis per BTC.
- **Specification:** [§4.1](PROTOCOL.md#41-monetary-constants) C
- **Implementation:** `blvm_primitives::constants::C` — Z3-verified (via economic functions)

### CONST-002
- **Rule:** No output or total output sum MUST exceed M_max = 21×10⁶×C.
- **Specification:** [§4.1](PROTOCOL.md#41-monetary-constants) M_max
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### CONST-003
- **Rule:** Block subsidy MUST halve every H = 210,000 blocks.
- **Specification:** [§4.1](PROTOCOL.md#41-monetary-constants) H
- **Implementation:** `economic::get_block_subsidy` — Z3-verified (Tier 1)

### CONST-004
- **Rule:** Block total weight MUST NOT exceed W_max = 4,000,000.
- **Specification:** [§4.2](PROTOCOL.md#42-block-constants) W_max
- **Implementation:** `segwit::calculate_block_weight` — Z3-verified (spec_locked)

### CONST-005
- **Rule:** Block total sigop cost MUST NOT exceed S_max = 80,000.
- **Specification:** [§4.2](PROTOCOL.md#42-block-constants) S_max
- **Implementation:** `sigop::get_transaction_sigop_cost` — Z3-verified (spec_locked)

### CONST-006
- **Rule:** Coinbase outputs MUST NOT be spendable until R = 100 blocks after creation.
- **Specification:** [§4.2](PROTOCOL.md#42-block-constants) R
- **Implementation:** `transaction::check_coinbase_maturity` — spec_locked [§5.1](PROTOCOL.md#51-transaction-validation)

### CONST-007
- **Rule:** Scripts MUST respect L_script = 10,000, L_stack = 1,000, L_ops = 201, L_element = 520.
- **Specification:** [§4.3](PROTOCOL.md#43-script-constants)
- **Implementation:** `script::eval_script`, `witness::validate_segwit_witness_structure` — Z3-verified (spec_locked)

### CONST-008
- **Rule:** Difficulty MUST adjust every D_interval = 2,016 blocks with target inter-block time T_block = 600 seconds.
- **Specification:** [§4.4](PROTOCOL.md#44-difficulty-constants)
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

---

## 11. Economic Model

Subsidy, supply, and fee rules (Orange Paper [§6](PROTOCOL.md#6-economic-model)).

### ECO-001
- **Rule:** Block subsidy MUST be 50×C×2^(−⌊h/H⌋) for h < 64×H; MUST be 0 for h ≥ 64×H.
- **Specification:** [§6.1](PROTOCOL.md#61-block-subsidy) GetBlockSubsidy, **Theorem 6.1.1**, **F_SubsidyZeroAfter64**, **F_SubsidyPiecewise**
- **Implementation:** `economic::get_block_subsidy` — Z3-verified (Tier 1 + F_* formulas)

### ECO-002
- **Rule:** TotalSupply(h) MUST equal the sum of GetBlockSubsidy(i) for i = 0..h.
- **Specification:** [§6.2](PROTOCOL.md#62-total-supply) TotalSupply
- **Implementation:** `economic::total_supply` — Z3-verified (spec_locked)

### ECO-003
- **Rule:** TotalSupply MUST NOT exceed MAX_MONEY (21M BTC) at any height.
- **Specification:** [§6.2](PROTOCOL.md#62-total-supply) **Theorem 6.2.2**, **F_TotalSupplyBound**
- **Implementation:** `economic::total_supply`, `economic::validate_supply_limit` — Z3-verified (F_* formulas)

### ECO-004
- **Rule:** TotalSupply MUST be monotonically non-decreasing in height.
- **Specification:** [§6.2](PROTOCOL.md#62-total-supply) **Theorem 6.2.1**, **F_TotalSupplyNonNeg**
- **Implementation:** `economic::total_supply` — Z3-verified (F_* formulas)

### ECO-005
- **Rule:** ValidateSupplyLimit(h) MUST pass iff TotalSupply(h) ≤ MAX_MONEY.
- **Specification:** [§6.3](PROTOCOL.md#63-supply-limit-validation) **Theorem 6.3.1**
- **Implementation:** `economic::validate_supply_limit` — Z3-verified (spec_locked)

### ECO-006
- **Rule:** Valid transaction fees MUST be ≥ 0 (inputs ≥ outputs).
- **Specification:** [§6.5](PROTOCOL.md#65-fee-market) CalculateFee, **F_FeeNonNeg**, **Theorem 6.5**
- **Implementation:** `economic::calculate_fee` — Z3-verified (F_* formulas)

---

## 12. Proof of Work

Difficulty encoding and validation (Orange Paper [§7](PROTOCOL.md#7-proof-of-work)).

### POW-001
- **Rule:** Compact difficulty bits MUST be > 0 for valid target expansion.
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) **F_ExpandTargetDomain**
- **Implementation:** `pow::expand_target` — Z3-verified (Tier 1)

### POW-002
- **Rule:** Valid compact exponent MUST be in {3,…,32}; zero mantissa MUST expand to zero target.
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) **F_ExpandTargetZeroMantissa**, **F_ExpandTargetNonZeroMantissa**, **Theorem 7.1.1**
- **Implementation:** `pow::expand_target` — Z3-verified (F_* formulas)

### POW-003
- **Rule:** GetNextWorkRequired result MUST be > 0 and ≤ MAX_TARGET.
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) **Theorem 7.1.2**
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

### POW-004
- **Rule:** CompressTarget MUST be the inverse of ExpandTarget for valid compact encodings.
- **Specification:** [§7.1](PROTOCOL.md#71-difficulty-adjustment) GetNextWorkRequired (Compress step)
- **Implementation:** `pow::compress_target` — Z3-verified (Tier 1 + spec_locked)

### POW-005
- **Rule:** CheckProofOfWork MUST be deterministic for fixed header input.
- **Specification:** [§8.5](PROTOCOL.md#85-deterministic-properties) **Theorem 8.5.1**
- **Implementation:** `pow::check_proof_of_work` — Z3-verified (Tier 1)

---

## 13. SegWit

Segregated witness rules (Orange Paper [§11.1](PROTOCOL.md#111-segregated-witness-segwit)).

### SEG-001
- **Rule:** Transaction weight MUST equal 3 × baseSize + totalSize (BIP141).
- **Specification:** [§11.1.1](PROTOCOL.md#1111-weight-and-size-calculations) CalculateTransactionWeight
- **Implementation:** `segwit::calculate_transaction_weight`, `witness::calculate_transaction_weight_segwit` — Z3-verified (spec_locked)

### SEG-002
- **Rule:** Virtual size MUST satisfy weight/4 ≤ vsize ≤ weight/4 + 1.
- **Specification:** [§11.1.1](PROTOCOL.md#1111-weight-and-size-calculations) **F_WeightToVSizeFloor**, **F_WeightToVSizeCeiling**
- **Implementation:** `witness::weight_to_vsize` — Z3-verified (F_* formulas)

### SEG-003
- **Rule:** SegWit v0 witness programs MUST be 20 or 32 bytes; invalid lengths MUST be rejected.
- **Specification:** [§11.1.3](PROTOCOL.md#1113-witness-program-extraction) **F_WitnessProgramLength20Valid**, **F_WitnessProgramLength32Valid**, **F_WitnessProgramLengthInvalid**
- **Implementation:** `witness::validate_witness_program_length` — Z3-verified (F_* formulas)

### SEG-004
- **Rule:** A SegWit transaction MUST have at least one v0 output (22 or 34 bytes, OP_0 PUSH20/PUSH32).
- **Specification:** [§11.1.6](PROTOCOL.md#1116-segwit-transaction-detection) IsSegWitTransaction
- **Implementation:** `segwit::is_segwit_transaction` — Z3-verified (spec_locked)

### SEG-005
- **Rule:** Witness commitment MUST be SHA256d(WitnessRoot ∥ witness_reserved_value), not root alone.
- **Specification:** [§11.1.5](PROTOCOL.md#1115-witness-commitment-validation) ValidateWitnessCommitment
- **Implementation:** `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### SEG-006
- **Rule:** Nested P2WPKH/P2WSH-in-P2SH MUST use SigVersion WitnessV0 and BIP143 sighash.
- **Specification:** [§11.1.8](PROTOCOL.md#1118-nested-segwit-p2wsh-in-p2sh-p2wpkh-in-p2sh) **Theorem 11.1.2**
- **Implementation:** `script::verify_script` — Z3-verified (spec_locked)

### SEG-007
- **Rule:** Empty witness stack (|w| = 0) MUST be considered empty by IsWitnessEmpty.
- **Specification:** [§11.1.2](PROTOCOL.md#1112-witness-structure-validation) **F_WitnessEmptyByLength**
- **Implementation:** `witness::is_witness_empty` — Z3-verified (F_* formulas)

---

## 14. Taproot

Taproot spending rules (Orange Paper [§11.2](PROTOCOL.md#112-taproot)).

### TAP-001
- **Rule:** P2TR scriptPubKey MUST be 34 bytes: OP_1 (0x51) PUSH32 (0x20) + 32-byte x-only key.
- **Specification:** [§11.2.1](PROTOCOL.md#1121-taproot-script-validation) ValidateTaprootScript, **F_TaprootOutputScriptLengthInvalid**
- **Implementation:** `taproot::validate_taproot_script`, `taproot::is_taproot_output` — Z3-verified (F_* formulas)

### TAP-002
- **Rule:** Inputs spending P2TR outputs MUST have empty scriptSig.
- **Specification:** [§11.2](PROTOCOL.md#112-taproot) **Theorem 11.2.1**
- **Implementation:** `taproot::validate_taproot_transaction` — Z3-verified (spec_locked)

### TAP-003
- **Rule:** Output key MUST equal internal_key + TapTweak(merkle_root) × G.
- **Specification:** [§11.2.2](PROTOCOL.md#1122-taproot-key-operations) ValidateTaprootKeyAggregation
- **Implementation:** `taproot::validate_taproot_key_aggregation` — Z3-verified (spec_locked)

### TAP-004
- **Rule:** Script-path spend MUST prove the script is in the Taproot merkle tree via TapLeaf/TapBranch hashes.
- **Specification:** [§11.2.3](PROTOCOL.md#1123-taproot-script-path) ValidateTaprootScriptPath, **Theorem 11.2.2**
- **Implementation:** `taproot::validate_taproot_script_path`, `taproot::parse_taproot_script_path_witness`, `taproot::compute_script_merkle_root` — Z3-verified (spec_locked)

### TAP-005
- **Rule:** Key-path witness MUST have 1 element of 64 or 65 bytes; 65-byte form MUST NOT end with explicit 0x00 sighash byte.
- **Specification:** [§11.2.4](PROTOCOL.md#1124-taproot-witness-structure) ValidateTaprootWitnessStructure
- **Implementation:** `witness::validate_taproot_witness_structure` — Z3-verified (spec_locked)

### TAP-006
- **Rule:** Optional annex (last element starting with 0x50) MUST be stripped before path validation and sighash.
- **Specification:** [§11.2.4](PROTOCOL.md#1124-taproot-witness-structure) StripTaprootAnnex
- **Implementation:** `taproot::strip_taproot_annex` — Z3-verified (spec_locked)

### TAP-007
- **Rule:** Key-path sighash MUST use TaggedHash("TapSighash", SigMsg) with optional annex hash.
- **Specification:** [§11.2.6](PROTOCOL.md#1126-taproot-signature-hash) ComputeTaprootSignatureHash
- **Implementation:** `taproot::compute_taproot_signature_hash` — Z3-verified (spec_locked)

### TAP-008
- **Rule:** Script-path sighash MUST bind tapleaf hash, codeseparator position, and key version.
- **Specification:** [§11.2.7](PROTOCOL.md#1127-tapscript-signature-hash-bip-342) ComputeTapscriptSignatureHash, **Theorem 11.2.3**
- **Implementation:** `taproot::compute_tapscript_signature_hash` — Z3-verified (spec_locked)

### TAP-009
- **Rule:** OP_CHECKMULTISIG and OP_CHECKMULTISIGVERIFY MUST be disabled in tapscript.
- **Specification:** [§11.2.8](PROTOCOL.md#1128-tapscript-opcodes-and-sigop-counting-bip-342) Tapscript Opcodes
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

---

## 15. Chain Reorganization

Reorg and chain-work rules (Orange Paper [§11.3](ARCHITECTURE.md#113-chain-reorganization), ARCHITECTURE.md).

### REORG-001
- **Rule:** ShouldReorganize MUST return true only when the candidate chain has strictly greater cumulative work.
- **Specification:** [§11.3](ARCHITECTURE.md#113-chain-reorganization) ShouldReorganize
- **Implementation:** `reorganization::should_reorganize` — Z3-verified (Tier 1)

### REORG-002
- **Rule:** CalculateChainWork MUST sum ExpandTarget(header.bits) over the chain segment.
- **Specification:** [§11.3](ARCHITECTURE.md#113-chain-reorganization) CalculateChainWork
- **Implementation:** `reorganization::calculate_chain_work` — Z3-verified (Tier 1)

### REORG-003
- **Rule:** DisconnectBlock with undo log MUST perfectly invert ConnectBlock.
- **Specification:** [§11.3.1](ARCHITECTURE.md#1131-undo-log-pattern) DisconnectBlock, [§8.2.1](PROTOCOL.md#821-integration-properties) Idempotency Property
- **Implementation:** `reorganization::disconnect_block` — Z3-verified (spec_locked)

### REORG-004
- **Rule:** ReorganizeChain MUST disconnect blocks back to common ancestor then connect new chain blocks in order.
- **Specification:** [§11.3](ARCHITECTURE.md#113-chain-reorganization) ReorganizeChain
- **Implementation:** `reorganization::reorganize_chain` — Z3-verified (spec_locked)

### SIG-001
- **Rule:** On signet, the coinbase witness commitment MUST satisfy the network challenge script (BIP325).
- **Specification:** [§11.5](PROTOCOL.md#115-signet-bip325) CheckSignetBlockSolution
- **Implementation:** `signet::check_signet_block_solution` — spec_locked [§11.5](PROTOCOL.md#115-signet-bip325); wired in `connect_block_inner` when `Network::Signet`

---

## 16. Security Properties

Cross-cutting security invariants (Orange Paper [§8](PROTOCOL.md#8-security-properties)).

### SEC-001
- **Rule:** ComputeMerkleRoot MUST be deterministic for fixed input hash list.
- **Specification:** [§8.4.1](PROTOCOL.md#841-computemerkleroot) **F_MerkleRootDeterminism**, **Theorem 8.4.1**
- **Implementation:** `mining::calculate_merkle_root` — Z3-verified (spec_locked)

### SEC-002
- **Rule:** ConnectBlock MUST be deterministic for fixed block, UTXO set, and height.
- **Specification:** [§8.5](PROTOCOL.md#85-deterministic-properties) **Theorem 8.5.3**
- **Implementation:** `block::connect_block` — Z3-verified (spec_locked)

### SEC-003
- **Rule:** ApplyTransaction MUST be deterministic and side-effect-free.
- **Specification:** [§8.5](PROTOCOL.md#85-deterministic-properties) **Theorem 8.5.2**, [§5.3.2](PROTOCOL.md#532-transaction-application-equivalence) **Corollary 5.3.2.1**
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### SEC-004
- **Rule:** Total supply MUST converge to exactly 21 million BTC.
- **Specification:** [§8.1](PROTOCOL.md#81-economic-security) **Theorem 8.2**, [§6.2](PROTOCOL.md#62-total-supply) **Theorem 6.2.3**
- **Implementation:** `economic::total_supply` — Z3-verified (spec_locked)

### SEC-005
- **Rule:** Script execution MUST be bounded in time and space O(L_ops).
- **Specification:** [§8.3](PROTOCOL.md#83-cryptographic-security) **Theorem 8.4**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

---

## 17. Engineering Invariants

Implementation safety properties (Orange Paper [§13.3](PROTOCOL.md#133-engineering-invariants)).

### ENG-001
- **Rule:** Serialize/deserialize MUST be inverse operations for transactions, SegWit transactions, and headers.
- **Specification:** [§13.3.2](PROTOCOL.md#1332-serializationdeserialization-correctness) **Theorem 13.3.2.1–13.3.2.2**, [§8.2.2](PROTOCOL.md#822-round-trip-properties) Round-Trip Properties
- **Implementation:** `blvm_primitives::serialization::*` — Z3-verified (property tests; blvm-primitives)

### ENG-002
- **Rule:** Malformed or truncated wire data MUST be rejected deterministically.
- **Specification:** [§13.3.4](PROTOCOL.md#1334-parser-determinism) Parser Determinism
- **Implementation:** `blvm_primitives::serialization::*` — Z3-verified (property tests)

### ENG-003
- **Rule:** Locktime type boundary at 500,000,000 MUST be consistent for CLTV and CSV.
- **Specification:** [§13.3.5](PROTOCOL.md#1335-integration-proofs) **Theorem 13.3.5.1**
- **Implementation:** `locktime::get_locktime_type` — Z3-verified (F_* formulas)

### ENG-004
- **Rule:** ConnectBlock MUST enforce subsidy, fees, and supply-limit economic invariants together.
- **Specification:** [§13.3.5](PROTOCOL.md#1335-integration-proofs) **Theorem 13.3.5.3**
- **Implementation:** `block::connect::connect_block_inner` + `economic::check_coinbase_subsidy` + `economic::verify_utxo_supply` ([§5.3.3](PROTOCOL.md#533-connectblock-pipeline))

---

## 18. Mempool Relay Policy

Relay and mempool rules (Orange Paper [§9](PROTOCOL.md#9-mempool-protocol)). These are **not block consensus** but are specified in the Orange Paper.

### MEM-001
- **Rule:** Coinbase transactions MUST NOT be accepted to the mempool.
- **Specification:** [§9.1](PROTOCOL.md#91-mempool-validation) AcceptToMemoryPool
- **Implementation:** `mempool::accept_to_memory_pool` — Z3-verified (spec_locked)

### MEM-002
- **Rule:** Mempool transactions MUST pass CheckTransaction and IsStandardTx.
- **Specification:** [§9.1](PROTOCOL.md#91-mempool-validation), [§9.2](PROTOCOL.md#92-standard-transaction-rules) IsStandardTx
- **Implementation:** `mempool::accept_to_memory_pool`, `mempool::is_standard_tx` — Z3-verified (spec_locked)

### MEM-003
- **Rule:** Non-witness serialized size MUST be ≥ 65 bytes for mempool acceptance.
- **Specification:** [§9.1](PROTOCOL.md#91-mempool-validation) AcceptToMemoryPool
- **Implementation:** `mempool::accept_to_memory_pool` — Z3-verified (spec_locked)

### MEM-004
- **Rule:** RBF replacement MUST require conflicting prevouts, higher fee rate, and RBF signaling (nSequence < SEQUENCE_FINAL).
- **Specification:** [§9.3](PROTOCOL.md#93-replace-by-fee-rbf) ReplacementChecks, [§8.2.1](PROTOCOL.md#821-integration-properties) RBF Conflict Requirement
- **Implementation:** `mempool::replacement_checks` — Z3-verified (spec_locked)

---

## 19. Gaps Register

No open gaps as of 2026-06-18.

### Implemented outside `blvm-consensus` (not gaps)

| Specification | Location |
|---------------|----------|
| [§10.1.1](PROTOCOL.md#1011-message-header-parsing) ParseMessage / CalculateChecksum | `blvm-protocol::node_tcp` (`spec_locked` 10.1.1); `blvm-node::network::protocol` (feature `protocol-verification`) |
| [§10.2.1](PROTOCOL.md#1021-handshake-invariants) Handshake ordering | `blvm-node::network::wire_dispatch` |

### Feature-gated (documented, not UNIMPLEMENTED)

| Specification | Location |
|---------------|----------|
| [§11.4](PROTOCOL.md#114-utxo-commitments) UTXO commitments | `blvm-protocol::utxo_commitments` — `GenerateCommitment`, `find_consensus`, `VerifyConsensusCommitment` (`spec_locked` 11.4); feature `utxo-commitments` |

### Closed (gap-closure pass)

HDR-008 node wiring; UTX-005 `VerifyUtxoSupply`; BIP54 BLK-012–014; ConnectBlock [§5.3.3](PROTOCOL.md#533-connectblock-pipeline); overlay ≡ ApplyTransaction (`tests/overlay_apply_equivalence.rs`); script fast-path ≡ VerifyScript (`tests/script_fast_path_equivalence.rs`); Signet SIG-001 (`signet::check_signet_block_solution`).

---

## Document Statistics

| Metric | Count |
|--------|------:|
| **Total rules** | **161** |
| **With Orange Paper backing** | **161** |
| **UNIMPLEMENTED gaps (all crates)** | **0** |
| **UNSPECIFIED / partial** | **0** |
| **Activation height tables** | **4** ([§8 of this register](#8-activation-height-tables)) |

**Tier 1 Z3 functions:** `get_block_subsidy`, `expand_target`, `compress_target`, `check_proof_of_work`, `get_next_work_required`, `compute_block_tx_ids_spec`, `calculate_chain_work`, `should_reorganize`

**F_* formula witnesses (Z3):** 59 functions in `spec_witnesses.rs` covering subsidy, fees, headers, BIP pre-activation passes, CLTV, CSV, SegWit, Taproot activation, and engineering invariants.

---

*This register is derived from [PROTOCOL.md](PROTOCOL.md) v1.0 and `blvm-consensus` as of the workspace checkout. HTML rendering will be derived from this document.*
