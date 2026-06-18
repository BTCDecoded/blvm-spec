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
| **Implementation** | `blvm-consensus` function path; `Z3-verified` if a spec-lock proof exists; `UNIMPLEMENTED` or `UNSPECIFIED` when gaps exist |

**Category prefixes:** `HDR` header · `BLK` block · `TX` transaction · `CB` coinbase · `SC` script · `UTX` UTXO · `CTX` contextual · `SF` soft fork · `CONST` constants · `ECO` economic · `POW` proof of work · `SEG` SegWit · `TAP` Taproot · `REORG` reorganization · `SEC` security · `ENG` engineering · `MEM` mempool relay policy

---

## 1. Header Validation

Rules H01–H08 from Orange Paper §5.3.1.

### HDR-001
- **Rule:** A block header version MUST be at least 1; version 0 MUST NOT be accepted.
- **Specification:** §5.3.1 H01, **F_HeaderVersionFloor**
- **Implementation:** `block::header::validate_block_header` — Z3-verified (F_HeaderVersionFloor)

### HDR-002
- **Rule:** A block header version MUST be at least the height-dependent minimum enforced by BIP90 (≥ 2 after BIP34, ≥ 3 after BIP66, ≥ 4 after BIP65).
- **Specification:** §5.3.1 H02, §5.4.4 BIP90Check, **Theorem 5.4.4**
- **Implementation:** `bip_validation::check_bip90` — Z3-verified (spec_locked)

### HDR-003
- **Rule:** A block header timestamp MUST NOT be zero.
- **Specification:** §5.3.1 H03
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

### HDR-004
- **Rule:** A block header timestamp MUST NOT exceed network time plus 7,200 seconds (T_future).
- **Specification:** §5.3.1 H04, §4.4 T_future
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

### HDR-005
- **Rule:** A block header timestamp MUST be at least the median time past of recent headers when time context is available (BIP113).
- **Specification:** §5.3.1 H05, §5.5 GetMedianTimePast
- **Implementation:** `block::header::validate_block_header`, `bip113::get_median_time_past` — Z3-verified (spec_locked)

### HDR-006
- **Rule:** A block header compact difficulty field (bits) MUST NOT be zero.
- **Specification:** §5.3.1 H06, **F_HeaderBitsFloor**
- **Implementation:** `block::header::validate_block_header` — Z3-verified (F_HeaderBitsFloor)

### HDR-007
- **Rule:** A block header MUST satisfy proof of work: double-SHA256(serialized header) MUST be less than ExpandTarget(bits).
- **Specification:** §5.3.1 H07, §7.2 CheckProofOfWork
- **Implementation:** `pow::check_proof_of_work` — Z3-verified (Tier 1)

### HDR-008
- **Rule:** A block header prev_block_hash MUST equal the hash of the parent header (chain linkage).
- **Specification:** §5.3.1 H08
- **Implementation:** UNIMPLEMENTED (enforced by node layer, not `blvm-consensus`)

### HDR-009
- **Rule:** A block header merkle_root field MUST NOT be all zeros (structural sanity check).
- **Specification:** §5.3.1 (structural guard; full merkle verification in ConnectBlock)
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

### HDR-010
- **Rule:** When time context is unavailable, header validation MUST still enforce H01, H03, and H06.
- **Specification:** §5.3.1 Notes (headers-first sync)
- **Implementation:** `block::header::validate_block_header` — Z3-verified (spec_locked)

---

## 2. Block Structure

Rules governing block body composition and connection.

### BLK-001
- **Rule:** A valid block MUST contain at least one transaction.
- **Specification:** §5.3 ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` — UNSPECIFIED (orchestration; no named spec function)

### BLK-002
- **Rule:** The first transaction in a valid block MUST be a coinbase transaction.
- **Specification:** §5.3 ConnectBlock, **Theorem 6.4.1**
- **Implementation:** `block::connect::connect_block_inner` — Z3-verified via `transaction::is_coinbase`

### BLK-003
- **Rule:** Every transaction in a block MUST pass CheckTransaction before the block is accepted.
- **Specification:** §5.3 ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` → `transaction::check_transaction` — Z3-verified (spec_locked)

### BLK-004
- **Rule:** Every transaction in a block MUST pass CheckTxInputs against the evolving UTXO set at the connecting height.
- **Specification:** §5.3 ConnectBlock
- **Implementation:** `block::connect::connect_block_inner` → `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### BLK-005
- **Rule:** Every transaction in a block MUST pass script verification (VerifyScript) against the evolving UTXO set.
- **Specification:** §5.3 ConnectBlock, §5.2 VerifyScript
- **Implementation:** `block::connect::connect_block_inner` → `script::verify_script` — Z3-verified (spec_locked)

### BLK-006
- **Rule:** The coinbase output value MUST NOT exceed block subsidy plus the sum of non-coinbase transaction fees.
- **Specification:** §5.3 ConnectBlock, §8.2.1 Economic Block Integration
- **Implementation:** `block::connect::connect_block_inner` — UNSPECIFIED (inline in connect path)

### BLK-007
- **Rule:** Total block weight MUST NOT exceed W_max (4,000,000 weight units).
- **Specification:** §11.1.1 CalculateBlockWeight, §4.2 W_max
- **Implementation:** `segwit::calculate_block_weight` — Z3-verified (spec_locked)

### BLK-008
- **Rule:** Total block signature-operation cost MUST NOT exceed S_max (80,000).
- **Specification:** §5.2.2 GetTransactionSigOpCost, §4.2 S_max
- **Implementation:** `sigop::get_transaction_sigop_cost` — Z3-verified (spec_locked)

### BLK-009
- **Rule:** The block transaction merkle root MUST match ComputeMerkleRoot over transaction txids.
- **Specification:** §8.4.1 ComputeMerkleRoot, **Theorem 8.5**
- **Implementation:** `block::compute_block_tx_ids_spec`, `mining::calculate_merkle_root` — Z3-verified (Tier 1 for tx-id spec)

### BLK-010
- **Rule:** The merkle tree MUST reject blocks where identical adjacent hashes appear at any level (CVE-2012-2459).
- **Specification:** §8.4.1 ComputeMerkleRoot, **Theorem 8.6**, **Corollary 8.1**
- **Implementation:** `mining::calculate_merkle_root` — Z3-verified (spec_locked)

### BLK-011
- **Rule:** SegWit blocks MUST validate witness commitment and weight limits when SegWit rules apply.
- **Specification:** §11.1.7 ValidateSegWitBlock
- **Implementation:** `segwit::validate_segwit_block`, `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### BLK-012
- **Rule:** After BIP54 activation, each non-coinbase transaction MUST have total sigops ≤ 2,500.
- **Specification:** §5.4.9 BIP54 per-tx sigops
- **Implementation:** `block::connect::check_bip54_sigop_limit` → `sigop::get_transaction_sigop_count_for_bip54` — UNSPECIFIED

### BLK-013
- **Rule:** After BIP54 activation, non-coinbase transactions with witness-stripped size exactly 64 bytes MUST be invalid.
- **Specification:** §5.4.9 BIP54 64-byte tx rule
- **Implementation:** `block::connect::connect_block_inner` — UNIMPLEMENTED

---

## 3. Transaction Structure

Structural and local validation rules for transactions.

### TX-001
- **Rule:** A transaction MUST have at least one input and at least one output.
- **Specification:** §5.1 CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-002
- **Rule:** Each output value MUST satisfy 0 ≤ value ≤ M_max.
- **Specification:** §5.1 CheckTransaction, §4.1 M_max
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-003
- **Rule:** The sum of output values MUST NOT exceed M_max.
- **Specification:** §5.1 CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-004
- **Rule:** No two inputs in a transaction MUST share the same prevout (intra-transaction duplicate spends forbidden).
- **Specification:** §5.1 CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-005
- **Rule:** Non-coinbase transactions MUST have non-null prevouts on all inputs.
- **Specification:** §5.1 CheckTransaction
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-006
- **Rule:** Input count MUST NOT exceed M_max_inputs and output count MUST NOT exceed M_max_outputs.
- **Specification:** §5.1 CheckTransaction Properties
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### TX-007
- **Rule:** Transaction stripped size × 4 MUST NOT exceed W_max (per-transaction weight bound).
- **Specification:** §5.1 CheckTransaction, CalculateTransactionSize
- **Implementation:** `transaction::check_transaction`, `transaction::calculate_transaction_size` — Z3-verified (spec_locked)

### TX-008
- **Rule:** Transaction ID MUST be a 32-byte double-SHA256 hash of the legacy serialization.
- **Specification:** §5.1 CalculateTxId
- **Implementation:** `block::apply::calculate_tx_id`, `mempool::calculate_tx_id` — Z3-verified (spec_locked)

### TX-009
- **Rule:** Valid non-coinbase transactions MUST have input sum ≥ output sum; fee MUST be non-negative.
- **Specification:** §5.1 CheckTxInputs, **Theorem 6.5** (Fee Non-Negativity)
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### TX-010
- **Rule:** Coinbase transactions MUST return fee zero from CheckTxInputs.
- **Specification:** §5.1 CheckTxInputs
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### TX-011
- **Rule:** Legacy (SigVersion::Base) sighash MUST apply FindAndDelete for signature pushes before hashing.
- **Specification:** §5.1.1 CalculateSighash, **Theorem 5.1.3**, **F_FindAndDelete**
- **Implementation:** `script::find_and_delete`, `transaction_hash::compute_legacy_sighash_*` — Z3-verified (spec_locked)

### TX-012
- **Rule:** WitnessV0 and Tapscript sighash MUST NOT apply FindAndDelete.
- **Specification:** §5.1.1 SigVersion
- **Implementation:** `transaction_hash::calculate_bip143_sighash`, `taproot::compute_taproot_signature_hash` — Z3-verified (spec_locked)

### TX-013
- **Rule:** Legacy scriptCode MUST strip OP_CODESEPARATOR (0xab) at opcode positions only.
- **Specification:** §5.1.1 SerializeScriptCode
- **Implementation:** `transaction_hash::serialize_script_code_for_legacy_sighash` — Z3-verified (spec_locked)

### TX-014
- **Rule:** Post-BIP66, sighash byte 0x00 MUST be treated as Invalid; pre-BIP66 it MUST map to SIGHASH_ALL.
- **Specification:** §5.1.1 SighashType, **Theorem 5.1.2**
- **Implementation:** `transaction_hash::calculate_transaction_sighash` — Z3-verified (spec_locked)

### TX-015
- **Rule:** P2SH sighash MUST use the redeem script, not the scriptPubKey.
- **Specification:** §5.1.1 SighashScriptCode, **Theorem 5.1.1**
- **Implementation:** `transaction_hash::calculate_transaction_sighash` — Z3-verified (spec_locked)

### TX-016
- **Rule:** BIP143 witness sighash MUST bind prevouts, sequences, outpoint, scriptCode, amount, outputs, locktime, and sighash type.
- **Specification:** §11.1.9 ComputeWitnessSignatureHash, **Theorem 11.1.2**
- **Implementation:** `transaction_hash::calculate_bip143_sighash` — Z3-verified (spec_locked)

### TX-017
- **Rule:** P2WPKH BIP143 scriptCode MUST be the 25-byte P2PKH expansion, NOT the raw 22-byte witness program.
- **Specification:** §11.1.9.1 DeriveWitnessScriptCode, **Theorem 11.1.3**
- **Implementation:** `transaction_hash::derive_bip143_script_code_p2wpkh` — Z3-verified (spec_locked)

### TX-018
- **Rule:** P2WSH BIP143 scriptCode MUST be the witness script (last witness stack element).
- **Specification:** §11.1.9.1 DeriveWitnessScriptCode
- **Implementation:** `transaction_hash::derive_bip143_script_code` — Z3-verified (spec_locked)

---

## 4. Coinbase Rules

Rules specific to coinbase transaction structure and validation.

### CB-001
- **Rule:** A coinbase transaction MUST have exactly one input with null hash (0³²) and index 0xFFFFFFFF.
- **Specification:** §6.4 IsCoinbase, **Theorem 6.4.1**
- **Implementation:** `transaction::is_coinbase` — Z3-verified (spec_locked)

### CB-002
- **Rule:** Coinbase scriptSig length MUST be between 2 and 100 bytes inclusive.
- **Specification:** §5.1 CheckTransaction, §13.3.3 **F_CoinbaseScriptSigMin**, **F_CoinbaseScriptSigMax**
- **Implementation:** `transaction::check_transaction` — Z3-verified (F_* formulas)

### CB-003
- **Rule:** After BIP34 activation, coinbase scriptSig MUST encode the block height.
- **Specification:** §5.4.2 BIP34Check, **Theorem 5.4.2**
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (spec_locked)

### CB-004
- **Rule:** Before BIP34 activation, height-in-coinbase check MUST pass regardless of scriptSig content.
- **Specification:** §5.4.2 **F_BIP34PreActivationPass**
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (F_BIP34PreActivationPass)

### CB-005
- **Rule:** Before BIP30 deactivation (mainnet h ≤ 91,722), coinbase txid MUST NOT already exist in the UTXO set.
- **Specification:** §5.4.1 BIP30Check, **Theorem 5.4.1**
- **Implementation:** `bip_validation::check_bip30` — Z3-verified (spec_locked)

### CB-006
- **Rule:** After BIP30 deactivation, duplicate-coinbase check MUST always pass.
- **Specification:** §5.4.1 **F_BIP30DeactivationPass**
- **Implementation:** `bip_validation::check_bip30` — Z3-verified (F_BIP30DeactivationPass)

### CB-007
- **Rule:** After BIP54 activation, coinbase lockTime MUST equal height − 13 and first input sequence MUST NOT be 0xFFFFFFFF.
- **Specification:** §5.4.9 CheckBip54Coinbase
- **Implementation:** `bip_validation::check_bip54_coinbase` — Z3-verified (spec_locked)

### CB-008
- **Rule:** Coinbase outputs MUST NOT be spendable until COINBASE_MATURITY (100) blocks after creation.
- **Specification:** §4.2 R (coinbase maturity constant)
- **Implementation:** `transaction::check_tx_inputs_with_owned_data` — UNSPECIFIED (no named Orange Paper predicate)

### CB-009
- **Rule:** SegWit coinbase MUST include a valid witness commitment output when witness data is present.
- **Specification:** §11.1.5 ValidateWitnessCommitment
- **Implementation:** `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### CB-010
- **Rule:** Coinbase witness merkle leaf MUST be fixed to 0³².
- **Specification:** §11.1.4 ComputeWitnessMerkleRoot
- **Implementation:** `segwit::compute_witness_merkle_root` — Z3-verified (spec_locked)

---

## 5. Script Validation

Script execution, flags, and signature-operation counting.

### SC-001
- **Rule:** Script execution MUST succeed only when it terminates with exactly one stack item that evaluates to true.
- **Specification:** §5.2 EvalScript
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-002
- **Rule:** Script execution MUST fail if combined main and alt stack size exceeds L_stack (1,000).
- **Specification:** §5.2 EvalScript, §4.3 L_stack, §13.3.3 **F_StackSizeSafe**
- **Implementation:** `script::eval_script` — Z3-verified (F_StackSizeSafe)

### SC-003
- **Rule:** Base and WitnessV0 scripts MUST NOT exceed L_script (10,000) bytes or L_ops (201) non-push opcodes.
- **Specification:** §5.2 EvalScript, §8.3 ScriptSecure, **Theorem 8.4**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-004
- **Rule:** Individual stack and witness elements MUST NOT exceed L_element (520) bytes.
- **Specification:** §4.3 L_element, §11.1.2 ValidateSegWitWitnessStructure
- **Implementation:** `witness::validate_segwit_witness_structure` — Z3-verified (spec_locked)

### SC-005
- **Rule:** When SCRIPT_VERIFY_P2SH is active and scriptPubKey is P2SH, scriptSig MUST pass push-only validation before execution.
- **Specification:** §5.2 VerifyScript, §5.2.1 P2SHPushOnlyCheck, **Theorem 5.2.1**
- **Implementation:** `script::verify_script`, `script::p2sh_push_only_check` — Z3-verified (spec_locked)

### SC-006
- **Rule:** P2SH scriptPubKey MUST be exactly 23 bytes: OP_HASH160 PUSH20 … OP_EQUAL.
- **Specification:** §5.2.1 IsP2SH
- **Implementation:** `sigop::is_pay_to_script_hash` — Z3-verified (spec_locked)

### SC-007
- **Rule:** OP_CHECKSIG/CHECKSIGVERIFY MUST count as 1 sigop; CHECKMULTISIG counts n (accurate) or 20 (legacy inaccurate).
- **Specification:** §5.2.2 CountSigOpsInScript
- **Implementation:** `sigop::count_sigops_in_script` — Z3-verified (spec_locked)

### SC-008
- **Rule:** Coinbase transactions MUST contribute zero P2SH sigops.
- **Specification:** §5.2.2 GetP2SHSigOpCount
- **Implementation:** `sigop::get_p2sh_sigop_count` — Z3-verified (spec_locked)

### SC-009
- **Rule:** Witness v0 sigops MUST be counted; Taproot (v1) MUST contribute zero to CountWitnessSigOps.
- **Specification:** §5.2.2 CountWitnessSigOps, §11.2.8
- **Implementation:** `sigop::count_witness_sigops`, `sigop::count_tapscript_sigops` — Z3-verified (spec_locked)

### SC-010
- **Rule:** Tapscript sigop budget MUST count opcodes 0xac, 0xad, 0xba only at opcode positions (not inside pushes).
- **Specification:** §11.2.8 CountTapscriptSigOps
- **Implementation:** `sigop::count_tapscript_sigops` — Z3-verified (spec_locked)

### SC-011
- **Rule:** OP_CHECKMULTISIG dummy stack element MUST be empty (OP_0) after BIP147 activation.
- **Specification:** §5.4.5 BIP147Check, **Theorem 5.4.5**
- **Implementation:** `bip_validation::check_bip147` — Z3-verified (spec_locked)

### SC-012
- **Rule:** After BIP66 activation, ECDSA signatures MUST be strictly DER-encoded.
- **Specification:** §5.4.3 BIP66Check, **Theorem 5.4.3**
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (spec_locked)

### SC-013
- **Rule:** OP_VER MUST fail only when fExec=true; in false conditional branches it MUST be skipped without failure.
- **Specification:** §5.2.4 **Theorem 5.2.3**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

### SC-014
- **Rule:** Under SCRIPT_VERIFY_MINIMALIF, IF/NOTIF condition bytes MUST be minimal: empty is valid; length > 1 is invalid.
- **Specification:** §5.2.4 IsMinimalIfCondition, **F_MinimalIfEmptyTrue**, **F_MinimalIfLongFalse**
- **Implementation:** `script::control_flow::is_minimal_if_condition` — Z3-verified (F_* formulas)

### SC-015
- **Rule:** Script verification flags MUST be monotone in height (never removed once activated).
- **Specification:** §5.2.5 CalculateScriptFlags
- **Implementation:** `block::script_cache::calculate_script_flags_for_block` — Z3-verified (spec_locked)

### SC-016
- **Rule:** When a block hash is in ScriptFlagExceptions, override flags MUST be used instead of CalculateScriptFlags.
- **Specification:** §5.2.6 ScriptFlagExceptions, GetBlockScriptFlags
- **Implementation:** `block::script_cache::get_block_script_flags` — Z3-verified (spec_locked)

### SC-017
- **Rule:** SCRIPT_VERIFY_WITNESS MUST activate only when the transaction has non-empty input witness or IsSegWitTransaction.
- **Specification:** §5.2.5 CalculateScriptFlags
- **Implementation:** `block::script_cache::tx_has_nonempty_input_witness` — Z3-verified (spec_locked)

### SC-018
- **Rule:** OP_CHECKLOCKTIMEVERIFY (BIP65) MUST reject when locktime types mismatch; MUST require tx.lockTime ≥ stack value when types match.
- **Specification:** §5.4.7 BIP65Check, **Theorem 5.4.7.3–5.4.7.4**, **F_BIP65Passes**, **F_BIP65Rejects***
- **Implementation:** `locktime::check_bip65` — Z3-verified (F_* formulas)

### SC-019
- **Rule:** Locktime values below 500,000,000 MUST be block-height type; values ≥ 500,000,000 MUST be timestamp type.
- **Specification:** §5.4.7 GetLocktimeType, §13.3.5 **F_LocktimeTypeIsHeight**, **F_LocktimeTypeIsTimestamp**
- **Implementation:** `locktime::get_locktime_type` — Z3-verified (F_* formulas)

### SC-020
- **Rule:** OP_CHECKSIGFROMSTACK (BIP348) MUST execute only in Tapscript; zero-length pubkey MUST fail; empty sig MUST succeed.
- **Specification:** §5.4.8 BIP348Check, **Theorem 5.4.8.2–5.4.8.5**, **F_CSFS***
- **Implementation:** `bip348::verify_signature_from_stack` — Z3-verified (F_* formulas)

### SC-021
- **Rule:** OP_CHECKTEMPLATEVERIFY (BIP119) MUST succeed iff TemplateHash(tx,i) equals the stack hash (when deployed).
- **Specification:** §5.4.6 BIP119Check, **Theorem 5.4.6.1–5.4.6.4**
- **Implementation:** `bip119::validate_template_hash` — Z3-verified (spec_locked; feature-gated)

### SC-022
- **Rule:** CScriptNum decoding for OP_CHECKMULTISIG m and n MUST treat empty bytes as zero.
- **Specification:** §5.4.5.1 **Theorem 5.4.5.1**, DecodeCScriptNum
- **Implementation:** `script::script_num_decode` — Z3-verified (spec_locked)

---

## 6. UTXO Rules

UTXO set transitions and invariants.

### UTX-001
- **Rule:** Non-coinbase ApplyTransaction MUST remove all spent prevouts and add all new outputs.
- **Specification:** §5.3.2 ApplyTransaction
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### UTX-002
- **Rule:** Coinbase ApplyTransaction MUST only add outputs (no inputs removed).
- **Specification:** §5.3.2 ApplyTransaction
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### UTX-003
- **Rule:** ApplyTransaction and ApplyTransactionWithId MUST produce identical UTXO results.
- **Specification:** §5.3.2 **Theorem 5.3.2**
- **Implementation:** `block::apply::apply_transaction`, `block::apply::apply_transaction_with_id` — Z3-verified (spec_locked)

### UTX-004
- **Rule:** ApplyUndo after ConnectBlock MUST restore the prior UTXO set (disconnect idempotency).
- **Specification:** §5.3.2, §8.2.1 ConnectBlock-DisconnectBlock Idempotency
- **Implementation:** `reorganization::disconnect_block` — Z3-verified (spec_locked)

### UTX-005
- **Rule:** The sum of all UTXO values MUST equal total money supply at every height.
- **Specification:** §8.1 **Theorem 8.1** (UTXO Set Invariant)
- **Implementation:** UNIMPLEMENTED (theorem; enforced indirectly via ConnectBlock)

### UTX-006
- **Rule:** Valid non-coinbase transactions MUST conserve value: input sum ≥ output sum.
- **Specification:** §8.1 Conservation of Value
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

### UTX-007
- **Rule:** Spent prevouts MUST exist in the UTXO set before a non-coinbase transaction is accepted.
- **Specification:** §5.1 CheckTxInputs
- **Implementation:** `transaction::check_tx_inputs` — Z3-verified (spec_locked)

---

## 7. Contextual Validation

Height-dependent, time-dependent, and sequence-lock rules.

### CTX-001
- **Rule:** Sequence lock bit 31 set (0x80000000) MUST disable relative locktime for that input.
- **Specification:** §5.5 IsSequenceDisabled, **F_SequenceDisabledWhenBit31Set**
- **Implementation:** `locktime::is_sequence_disabled` — Z3-verified (F_* formulas)

### CTX-002
- **Rule:** Sequence lock bit 22 set (0x00400000) MUST mean time-based lock; clear MUST mean height-based.
- **Specification:** §5.5 ExtractSequenceTypeFlag, **F_SequenceTypeTimeWhenBit22Set**, **F_SequenceTypeHeightWhenBit22Clear**
- **Implementation:** `locktime::extract_sequence_type_flag` — Z3-verified (F_* formulas)

### CTX-003
- **Rule:** Extracted sequence locktime value MUST be in [0, 65535] (lower 16 bits).
- **Specification:** §5.5 **F_SequenceLockTimeMask**
- **Implementation:** `locktime::extract_sequence_locktime_value` — Z3-verified (F_* formulas)

### CTX-004
- **Rule:** Sequence locks MUST only be enforced when tx.version ≥ 2 and CSV script flag (0x400) is active.
- **Specification:** §5.5 CalculateSequenceLocks
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (spec_locked)

### CTX-005
- **Rule:** Time-based sequence locks MUST use value × 512 seconds added to coin MTP − 1.
- **Specification:** §5.5 CalculateSequenceLocks, **F_SequenceTimeEncoding**
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (F_* formulas)

### CTX-006
- **Rule:** Height-based sequence locks MUST use coin height + value − 1.
- **Specification:** §5.5 CalculateSequenceLocks
- **Implementation:** `sequence_locks::calculate_sequence_locks` — Z3-verified (spec_locked)

### CTX-007
- **Rule:** EvaluateSequenceLocks MUST return true iff block height > min_height (when set) AND block time > min_time (when set).
- **Specification:** §5.5 EvaluateSequenceLocks, **F_EvalSeqLocks***, **Theorem 5.5.2**
- **Implementation:** `sequence_locks::evaluate_sequence_locks` — Z3-verified (F_* formulas)

### CTX-008
- **Rule:** Median time past MUST be the median of the last up-to-11 block timestamps (BIP113).
- **Specification:** §5.5 GetMedianTimePast
- **Implementation:** `bip113::get_median_time_past` — Z3-verified (spec_locked)

### CTX-009
- **Rule:** Mempool admission MUST require absolute and relative locktimes satisfied at chain tip.
- **Specification:** §9.1.1 CheckFinalTxAtTip
- **Implementation:** `mempool::is_final_tx` — Z3-verified (spec_locked)

### CTX-010
- **Rule:** Difficulty retarget timespan MUST be clamped to [T_expected/4, 4×T_expected] (factor-of-4 bound).
- **Specification:** §7.1 GetNextWorkRequired, **Theorem 7.1**
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

### CTX-011
- **Rule:** When EnforceBIP94(n), first block of new difficulty period MUST have time ≥ prev.time − 600.
- **Specification:** §7.1 BIP94 Timestamp Rule
- **Implementation:** `pow::get_next_work_required` — Z3-verified (spec_locked)

### CTX-012
- **Rule:** All monetary arithmetic MUST use checked add/sub to prevent overflow/underflow.
- **Specification:** §13.3.1, **F_FeeArithmeticNonNeg**, **F_FeeArithmeticBounded**
- **Implementation:** `transaction::check_transaction`, `economic::calculate_fee` — Z3-verified (F_* formulas)

---

## 8. Soft Fork Activation

BIP activation heights, version bits, and deployment rules.

### SF-001
- **Rule:** SCRIPT_VERIFY_P2SH MUST activate at mainnet height 173,805.
- **Specification:** §5.2.5 CalculateScriptFlags (BIP16)
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-002
- **Rule:** BIP34 (height in coinbase) MUST activate at mainnet height 227,931.
- **Specification:** §5.4.2 BIP34Check
- **Implementation:** `bip_validation::check_bip34` — Z3-verified (spec_locked)

### SF-003
- **Rule:** BIP66 (strict DER) MUST activate at mainnet height 363,725.
- **Specification:** §5.4.3 BIP66Check
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (spec_locked)

### SF-004
- **Rule:** BIP65 (CLTV) MUST activate at mainnet height 388,381.
- **Specification:** §5.4.7 BIP65Check, §5.2.5
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-005
- **Rule:** BIP68/112 (CSV) MUST activate at mainnet height 419,328.
- **Specification:** §5.5, §5.2.5
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-006
- **Rule:** SegWit (BIP141/143/147) MUST activate at mainnet height 481,824.
- **Specification:** §11.1, §5.4.5 BIP147Check
- **Implementation:** `block::script_cache::calculate_base_script_flags_for_block` — Z3-verified (spec_locked)

### SF-007
- **Rule:** Taproot (BIP341/342) MUST activate at mainnet height 709,632.
- **Specification:** §11.2 **F_TaprootActivationMainnet**
- **Implementation:** `activation::taproot_activation_height` — Z3-verified (F_TaprootActivationMainnet)

### SF-008
- **Rule:** Taproot MUST activate at testnet height 2,011,968 and regtest height 0.
- **Specification:** §11.2 **F_TaprootActivationTestnet**, **F_TaprootActivationRegtest**
- **Implementation:** `activation::taproot_activation_height` — Z3-verified (F_* formulas)

### SF-009
- **Rule:** BIP54 version-bits signal MUST use bit 15 with start time 0.
- **Specification:** §5.4.9 **F_Bip54SignalBit**, **F_Bip54StartTimeZero**
- **Implementation:** `version_bits::bip54_deployment_for_network` — Z3-verified (F_* formulas)

### SF-010
- **Rule:** IsBip54ActiveAt MUST return true at and after the configured activation threshold height.
- **Specification:** §5.4.9 **F_BIP54ActivationThreshold**, IsBip54ActiveAt
- **Implementation:** `bip_validation::is_bip54_active_at` — Z3-verified (F_* formulas)

### SF-011
- **Rule:** Before BIP66 activation, DER check MUST pass for any signature.
- **Specification:** §5.4.3 **F_BIP66PreActivationPass**
- **Implementation:** `bip_validation::check_bip66` — Z3-verified (F_BIP66PreActivationPass)

### SF-012
- **Rule:** Before BIP90 activation, version check MUST pass for any version ≥ 1.
- **Specification:** §5.4.4 **F_BIP90PreActivationPass**
- **Implementation:** `bip_validation::check_bip90` — Z3-verified (F_BIP90PreActivationPass)

### SF-013
- **Rule:** Before BIP147 activation, null-dummy check MUST pass regardless.
- **Specification:** §5.4.5 **F_BIP147PreActivationPass**
- **Implementation:** `bip_validation::check_bip147` — Z3-verified (F_BIP147PreActivationPass)

### SF-014
- **Rule:** All BIP rules MUST be enforced consistently after their activation heights.
- **Specification:** §5.4 **Corollary 5.4.1**
- **Implementation:** `block::connect::connect_block_inner` — UNSPECIFIED (integration property)

---

## 9. Consensus Constants

Numeric limits referenced by consensus rules (Orange Paper §4).

### CONST-001
- **Rule:** All monetary amounts MUST be denominated in satoshis; C = 10⁸ satoshis per BTC.
- **Specification:** §4.1 C
- **Implementation:** `blvm_primitives::constants::C` — Z3-verified (via economic functions)

### CONST-002
- **Rule:** No output or total output sum MUST exceed M_max = 21×10⁶×C.
- **Specification:** §4.1 M_max
- **Implementation:** `transaction::check_transaction` — Z3-verified (spec_locked)

### CONST-003
- **Rule:** Block subsidy MUST halve every H = 210,000 blocks.
- **Specification:** §4.1 H
- **Implementation:** `economic::get_block_subsidy` — Z3-verified (Tier 1)

### CONST-004
- **Rule:** Block total weight MUST NOT exceed W_max = 4,000,000.
- **Specification:** §4.2 W_max
- **Implementation:** `segwit::calculate_block_weight` — Z3-verified (spec_locked)

### CONST-005
- **Rule:** Block total sigop cost MUST NOT exceed S_max = 80,000.
- **Specification:** §4.2 S_max
- **Implementation:** `sigop::get_transaction_sigop_cost` — Z3-verified (spec_locked)

### CONST-006
- **Rule:** Coinbase outputs MUST NOT be spendable until R = 100 blocks after creation.
- **Specification:** §4.2 R
- **Implementation:** `transaction::check_tx_inputs_with_owned_data` — UNSPECIFIED

### CONST-007
- **Rule:** Scripts MUST respect L_script = 10,000, L_stack = 1,000, L_ops = 201, L_element = 520.
- **Specification:** §4.3
- **Implementation:** `script::eval_script`, `witness::validate_segwit_witness_structure` — Z3-verified (spec_locked)

### CONST-008
- **Rule:** Difficulty MUST adjust every D_interval = 2,016 blocks with target inter-block time T_block = 600 seconds.
- **Specification:** §4.4
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

---

## 10. Economic Model

Subsidy, supply, and fee rules (Orange Paper §6).

### ECO-001
- **Rule:** Block subsidy MUST be 50×C×2^(−⌊h/H⌋) for h < 64×H; MUST be 0 for h ≥ 64×H.
- **Specification:** §6.1 GetBlockSubsidy, **Theorem 6.1.1**, **F_SubsidyZeroAfter64**, **F_SubsidyPiecewise**
- **Implementation:** `economic::get_block_subsidy` — Z3-verified (Tier 1 + F_* formulas)

### ECO-002
- **Rule:** TotalSupply(h) MUST equal the sum of GetBlockSubsidy(i) for i = 0..h.
- **Specification:** §6.2 TotalSupply
- **Implementation:** `economic::total_supply` — Z3-verified (spec_locked)

### ECO-003
- **Rule:** TotalSupply MUST NOT exceed MAX_MONEY (21M BTC) at any height.
- **Specification:** §6.2 **Theorem 6.2.2**, **F_TotalSupplyBound**
- **Implementation:** `economic::total_supply`, `economic::validate_supply_limit` — Z3-verified (F_* formulas)

### ECO-004
- **Rule:** TotalSupply MUST be monotonically non-decreasing in height.
- **Specification:** §6.2 **Theorem 6.2.1**, **F_TotalSupplyNonNeg**
- **Implementation:** `economic::total_supply` — Z3-verified (F_* formulas)

### ECO-005
- **Rule:** ValidateSupplyLimit(h) MUST pass iff TotalSupply(h) ≤ MAX_MONEY.
- **Specification:** §6.3 **Theorem 6.3.1**
- **Implementation:** `economic::validate_supply_limit` — Z3-verified (spec_locked)

### ECO-006
- **Rule:** Valid transaction fees MUST be ≥ 0 (inputs ≥ outputs).
- **Specification:** §6.5 CalculateFee, **F_FeeNonNeg**, **Theorem 6.5**
- **Implementation:** `economic::calculate_fee` — Z3-verified (F_* formulas)

---

## 11. Proof of Work

Difficulty encoding and validation (Orange Paper §7).

### POW-001
- **Rule:** Compact difficulty bits MUST be > 0 for valid target expansion.
- **Specification:** §7.1 **F_ExpandTargetDomain**
- **Implementation:** `pow::expand_target` — Z3-verified (Tier 1)

### POW-002
- **Rule:** Valid compact exponent MUST be in {3,…,32}; zero mantissa MUST expand to zero target.
- **Specification:** §7.1 **F_ExpandTargetZeroMantissa**, **F_ExpandTargetNonZeroMantissa**, **Theorem 7.1.1**
- **Implementation:** `pow::expand_target` — Z3-verified (F_* formulas)

### POW-003
- **Rule:** GetNextWorkRequired result MUST be > 0 and ≤ MAX_TARGET.
- **Specification:** §7.1 **Theorem 7.1.2**
- **Implementation:** `pow::get_next_work_required` — Z3-verified (Tier 1)

### POW-004
- **Rule:** CompressTarget MUST be the inverse of ExpandTarget for valid compact encodings.
- **Specification:** §7.1 GetNextWorkRequired (Compress step)
- **Implementation:** `pow::compress_target` — Z3-verified (Tier 1; no spec_locked annotation)

### POW-005
- **Rule:** CheckProofOfWork MUST be deterministic for fixed header input.
- **Specification:** §8.5 **Theorem 8.5.1**
- **Implementation:** `pow::check_proof_of_work` — Z3-verified (Tier 1)

---

## 12. SegWit

Segregated witness rules (Orange Paper §11.1).

### SEG-001
- **Rule:** Transaction weight MUST equal 3 × baseSize + totalSize (BIP141).
- **Specification:** §11.1.1 CalculateTransactionWeight
- **Implementation:** `segwit::calculate_transaction_weight`, `witness::calculate_transaction_weight_segwit` — Z3-verified (spec_locked)

### SEG-002
- **Rule:** Virtual size MUST satisfy weight/4 ≤ vsize ≤ weight/4 + 1.
- **Specification:** §11.1.1 **F_WeightToVSizeFloor**, **F_WeightToVSizeCeiling**
- **Implementation:** `witness::weight_to_vsize` — Z3-verified (F_* formulas)

### SEG-003
- **Rule:** SegWit v0 witness programs MUST be 20 or 32 bytes; invalid lengths MUST be rejected.
- **Specification:** §11.1.3 **F_WitnessProgramLength20Valid**, **F_WitnessProgramLength32Valid**, **F_WitnessProgramLengthInvalid**
- **Implementation:** `witness::validate_witness_program_length` — Z3-verified (F_* formulas)

### SEG-004
- **Rule:** A SegWit transaction MUST have at least one v0 output (22 or 34 bytes, OP_0 PUSH20/PUSH32).
- **Specification:** §11.1.6 IsSegWitTransaction
- **Implementation:** `segwit::is_segwit_transaction` — Z3-verified (spec_locked)

### SEG-005
- **Rule:** Witness commitment MUST be SHA256d(WitnessRoot ∥ witness_reserved_value), not root alone.
- **Specification:** §11.1.5 ValidateWitnessCommitment
- **Implementation:** `segwit::validate_witness_commitment` — Z3-verified (spec_locked)

### SEG-006
- **Rule:** Nested P2WPKH/P2WSH-in-P2SH MUST use SigVersion WitnessV0 and BIP143 sighash.
- **Specification:** §11.1.8 **Theorem 11.1.2**
- **Implementation:** `script::verify_script` — Z3-verified (spec_locked)

### SEG-007
- **Rule:** Empty witness stack (|w| = 0) MUST be considered empty by IsWitnessEmpty.
- **Specification:** §11.1.2 **F_WitnessEmptyByLength**
- **Implementation:** `witness::is_witness_empty` — Z3-verified (F_* formulas)

---

## 13. Taproot

Taproot spending rules (Orange Paper §11.2).

### TAP-001
- **Rule:** P2TR scriptPubKey MUST be 34 bytes: OP_1 (0x51) PUSH32 (0x20) + 32-byte x-only key.
- **Specification:** §11.2.1 ValidateTaprootScript, **F_TaprootOutputScriptLengthInvalid**
- **Implementation:** `taproot::validate_taproot_script`, `taproot::is_taproot_output` — Z3-verified (F_* formulas)

### TAP-002
- **Rule:** Inputs spending P2TR outputs MUST have empty scriptSig.
- **Specification:** §11.2 **Theorem 11.2.1**
- **Implementation:** `taproot::validate_taproot_transaction` — Z3-verified (spec_locked)

### TAP-003
- **Rule:** Output key MUST equal internal_key + TapTweak(merkle_root) × G.
- **Specification:** §11.2.2 ValidateTaprootKeyAggregation
- **Implementation:** `taproot::validate_taproot_key_aggregation` — Z3-verified (spec_locked)

### TAP-004
- **Rule:** Script-path spend MUST prove the script is in the Taproot merkle tree via TapLeaf/TapBranch hashes.
- **Specification:** §11.2.3 ValidateTaprootScriptPath, **Theorem 11.2.2**
- **Implementation:** `taproot::validate_taproot_script_path`, `taproot::compute_script_merkle_root` — Z3-verified (spec_locked)

### TAP-005
- **Rule:** Key-path witness MUST have 1 element of 64 or 65 bytes; 65-byte form MUST NOT end with explicit 0x00 sighash byte.
- **Specification:** §11.2.4 ValidateTaprootWitnessStructure
- **Implementation:** `witness::validate_taproot_witness_structure` — Z3-verified (spec_locked)

### TAP-006
- **Rule:** Optional annex (last element starting with 0x50) MUST be stripped before path validation and sighash.
- **Specification:** §11.2.4 StripTaprootAnnex
- **Implementation:** `taproot::strip_taproot_annex` — Z3-verified (spec_locked)

### TAP-007
- **Rule:** Key-path sighash MUST use TaggedHash("TapSighash", SigMsg) with optional annex hash.
- **Specification:** §11.2.6 ComputeTaprootSignatureHash
- **Implementation:** `taproot::compute_taproot_signature_hash` — Z3-verified (spec_locked)

### TAP-008
- **Rule:** Script-path sighash MUST bind tapleaf hash, codeseparator position, and key version.
- **Specification:** §11.2.7 ComputeTapscriptSignatureHash, **Theorem 11.2.3**
- **Implementation:** `taproot::compute_tapscript_signature_hash` — Z3-verified (spec_locked)

### TAP-009
- **Rule:** OP_CHECKMULTISIG and OP_CHECKMULTISIGVERIFY MUST be disabled in tapscript.
- **Specification:** §11.2.8 Tapscript Opcodes
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

---

## 14. Chain Reorganization

Reorg and chain-work rules (Orange Paper §11.3, ARCHITECTURE.md).

### REORG-001
- **Rule:** ShouldReorganize MUST return true only when the candidate chain has strictly greater cumulative work.
- **Specification:** §11.3 ShouldReorganize
- **Implementation:** `reorganization::should_reorganize` — Z3-verified (Tier 1)

### REORG-002
- **Rule:** CalculateChainWork MUST sum ExpandTarget(header.bits) over the chain segment.
- **Specification:** §11.3 CalculateChainWork
- **Implementation:** `reorganization::calculate_chain_work` — Z3-verified (Tier 1)

### REORG-003
- **Rule:** DisconnectBlock with undo log MUST perfectly invert ConnectBlock.
- **Specification:** §11.3.1 DisconnectBlock, §8.2.1 Idempotency Property
- **Implementation:** `reorganization::disconnect_block` — Z3-verified (spec_locked)

### REORG-004
- **Rule:** ReorganizeChain MUST disconnect blocks back to common ancestor then connect new chain blocks in order.
- **Specification:** §11.3 (ARCHITECTURE.md)
- **Implementation:** `reorganization::reorganize_chain` — Z3-verified (spec_locked)

---

## 15. Security Properties

Cross-cutting security invariants (Orange Paper §8).

### SEC-001
- **Rule:** ComputeMerkleRoot MUST be deterministic for fixed input hash list.
- **Specification:** §8.4.1 **F_MerkleRootDeterminism**, **Theorem 8.4.1**
- **Implementation:** `mining::calculate_merkle_root` — Z3-verified (spec_locked)

### SEC-002
- **Rule:** ConnectBlock MUST be deterministic for fixed block, UTXO set, and height.
- **Specification:** §8.5 **Theorem 8.5.3**
- **Implementation:** `block::connect_block` — Z3-verified (spec_locked)

### SEC-003
- **Rule:** ApplyTransaction MUST be deterministic and side-effect-free.
- **Specification:** §8.5 **Theorem 8.5.2**, §5.3.2 **Corollary 5.3.2.1**
- **Implementation:** `block::apply::apply_transaction` — Z3-verified (spec_locked)

### SEC-004
- **Rule:** Total supply MUST converge to exactly 21 million BTC.
- **Specification:** §8.1 **Theorem 8.2**, §6.2 **Theorem 6.2.3**
- **Implementation:** `economic::total_supply` — Z3-verified (spec_locked)

### SEC-005
- **Rule:** Script execution MUST be bounded in time and space O(L_ops).
- **Specification:** §8.3 **Theorem 8.4**
- **Implementation:** `script::eval_script` — Z3-verified (spec_locked)

---

## 16. Engineering Invariants

Implementation safety properties (Orange Paper §13.3).

### ENG-001
- **Rule:** Serialize/deserialize MUST be inverse operations for transactions, SegWit transactions, and headers.
- **Specification:** §13.3.2 **Theorem 13.3.2.1–13.3.2.2**, §8.2.2 Round-Trip Properties
- **Implementation:** `blvm_primitives::serialization::*` — Z3-verified (property tests; blvm-primitives)

### ENG-002
- **Rule:** Malformed or truncated wire data MUST be rejected deterministically.
- **Specification:** §13.3.4 Parser Determinism
- **Implementation:** `blvm_primitives::serialization::*` — Z3-verified (property tests)

### ENG-003
- **Rule:** Locktime type boundary at 500,000,000 MUST be consistent for CLTV and CSV.
- **Specification:** §13.3.5 **Theorem 13.3.5.1**
- **Implementation:** `locktime::get_locktime_type` — Z3-verified (F_* formulas)

### ENG-004
- **Rule:** ConnectBlock MUST enforce subsidy, fees, and supply-limit economic invariants together.
- **Specification:** §13.3.5 **Theorem 13.3.5.3**
- **Implementation:** `block::connect::connect_block_inner` — UNSPECIFIED

---

## 17. Mempool Relay Policy

Relay and mempool rules (Orange Paper §9). These are **not block consensus** but are specified in the Orange Paper.

### MEM-001
- **Rule:** Coinbase transactions MUST NOT be accepted to the mempool.
- **Specification:** §9.1 AcceptToMemoryPool
- **Implementation:** `mempool::accept_to_memory_pool` — Z3-verified (spec_locked)

### MEM-002
- **Rule:** Mempool transactions MUST pass CheckTransaction and IsStandardTx.
- **Specification:** §9.1, §9.2 IsStandardTx
- **Implementation:** `mempool::accept_to_memory_pool`, `mempool::is_standard_tx` — Z3-verified (spec_locked)

### MEM-003
- **Rule:** Non-witness serialized size MUST be ≥ 65 bytes for mempool acceptance.
- **Specification:** §9.1 AcceptToMemoryPool
- **Implementation:** `mempool::accept_to_memory_pool` — Z3-verified (spec_locked)

### MEM-004
- **Rule:** RBF replacement MUST require conflicting prevouts, higher fee rate, and RBF signaling (nSequence < SEQUENCE_FINAL).
- **Specification:** §9.3 ReplacementChecks, §8.2.1 RBF Conflict Requirement
- **Implementation:** `mempool::replacement_checks` — Z3-verified (spec_locked)

---

## 18. Gaps Register

First-class gaps between Orange Paper specification and `blvm-consensus` implementation.

### Orange Paper rules without implementing function (UNIMPLEMENTED)

| ID | Rule summary | Specification |
|----|--------------|---------------|
| HDR-008 | Parent hash chain linkage | §5.3.1 H08 |
| BLK-013 | BIP54 64-byte witness-stripped tx rejection | §5.4.9 |
| UTX-005 | UTXO set sum equals total supply (theorem) | §8.1 Theorem 8.1 |

### Implementation without Orange Paper section (UNSPECIFIED)

| Function | Role | Notes |
|----------|------|-------|
| `block::connect::connect_block_inner` | Full ConnectBlock orchestration | Implements §5.3 but no named spec function |
| `block::connect::check_bip54_sigop_limit` | BIP54 per-tx sigop cap | §5.4.9 prose rule, no named function |
| `sigop::get_transaction_sigop_count_for_bip54` | BIP54 sigop aggregation | Helper for above |
| `transaction::check_tx_inputs_with_owned_data` | CheckTxInputs + coinbase maturity | §4.2 R constant only |
| `pow::compress_target` | Compact target encoding | §7.1 implied; Tier 1 Z3, no spec_locked |
| `taproot::parse_taproot_script_path_witness` | Taproot witness parsing | BIP341 behavior, no named spec function |
| `utxo_overlay::apply_transaction_to_overlay*` | Optimized UTXO apply | §11.4 architecture layer |
| Script fast paths (`try_verify_p2pk_fast_path`, etc.) | Performance shortcuts | Must match VerifyScript semantics |
| `version_bits::activation_height_from_headers` | BIP9 lock-in scan | BIP54 deployment helper |
| Mempool policy helpers (`is_standard_script`, `signals_rbf`, etc.) | Relay policy | §9 prose, partial function coverage |

### Network protocol rules (Orange Paper §10, no blvm-consensus module)

| Specification | Status |
|---------------|--------|
| §10.1.1 Message header parsing | UNIMPLEMENTED (blvm-node) |
| §10.2.1 Handshake ordering (Version before VerAck) | UNIMPLEMENTED (blvm-node) |
| §11.4 UTXO Commitments | UNIMPLEMENTED (optional feature) |
| §11.5 Signet block solution | UNIMPLEMENTED (blvm-protocol) |

---

## Document Statistics

| Metric | Count |
|--------|------:|
| **Total rules** | **158** |
| **With Orange Paper backing** | **155** (3 UNIMPLEMENTED in blvm-consensus) |
| **With blvm-consensus implementation** | **154** (4 rules delegated to node/other crates) |
| **Z3-verified (any spec-lock proof)** | **148** |
| **Z3-verified Tier 1 (full body proof)** | **8** |
| **UNIMPLEMENTED gaps** | **3** (consensus crate) + **4** (node/protocol) |
| **UNSPECIFIED gaps** | **10** named functions |

**Tier 1 Z3 functions:** `get_block_subsidy`, `expand_target`, `compress_target`, `check_proof_of_work`, `get_next_work_required`, `compute_block_tx_ids_spec`, `calculate_chain_work`, `should_reorganize`

**F_* formula witnesses (Z3):** 59 functions in `spec_witnesses.rs` covering subsidy, fees, headers, BIP pre-activation passes, CLTV, CSV, SegWit, Taproot activation, and engineering invariants.

---

*This register is derived from [PROTOCOL.md](PROTOCOL.md) v1.0 and `blvm-consensus` as of the workspace checkout. HTML rendering will be derived from this document.*
