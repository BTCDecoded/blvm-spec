# Verified Formulas Sidecar

This file registers `F_*` formula IDs whose content is a **type-level tautology** —
provable from the Rust type alone, without any mathematical body. They live here
(not in `PROTOCOL.md`) to keep the Orange Paper free of boilerplate.

**Editorial rule**: Add an ID here when the formula just records the return type
of a function (`result \in \{\text{true},\text{false}\}` for `bool`, `result \geq 0`
for `Natural`/`u64`). Add to `PROTOCOL.md` when the formula encodes a genuine
mathematical property of the function's *behaviour*.

---

## 13.6 Boolean-Valued Function Results

**Shared body** — all IDs in this section carry:

$$result \in \{\text{true}, \text{false}\}$$

This is a type-level axiom: every Rust `bool`-returning function always produces
either `true` or `false`. No proof obligation beyond the return type.

**Formula** (**F_CheckTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_SighashBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_ScriptExecBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_P2SHBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_ScriptFlagExceptBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_ConnectBlockBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_HeaderValidationBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_ApplyTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP66BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP90BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP147BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_CTVTemplateBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_CTVScriptBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP65BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP348BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP54BoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_SequenceTypeFlagBit**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_SequenceDisabledBit**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_IsCoinbaseBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_CheckPoWBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_MempoolAcceptBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_FinalTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_IsStandardTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_RBFChecksBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_IsWitnessEmptyBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_WitnessProgramBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_WitnessMerkleBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_WitnessCommitmentBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_IsSegWitTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_SegWitBlockBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BIP143SighashBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootScriptBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootOutputBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootKeyAggBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootScriptPathBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootWitnessStructBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootTxBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TaprootSighashBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_TapscriptSighashBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_CreateCoinbaseBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

**Formula** (**F_BlockTemplateBoolResult**):
$$result \in \{\text{true}, \text{false}\}$$

---

## 13.7 Non-Negative Natural Number Results

**Shared body** — all IDs in this section carry:

$$result \geq 0$$

This is a type-level axiom: Rust's `u64`, `u32`, and `usize` types are unsigned;
no negative value is representable.

**Formula** (**F_TxSizeNonNeg**):
$$result \geq 0$$

**Formula** (**F_SigOpCountNonNeg**):
$$result \geq 0$$

**Formula** (**F_ScriptFlagsNonNeg**):
$$result \geq 0$$

**Formula** (**F_DifficultyNonNeg**):
$$result \geq 0$$

**Formula** (**F_WitnessSigOpNonNeg**):
$$result \geq 0$$

**Formula** (**F_WeightNonNeg**):
$$result \geq 0$$

**Formula** (**F_VsizeNonNeg**):
$$result \geq 0$$

**Formula** (**F_TapscriptSigOpNonNeg**):
$$result \geq 0$$
