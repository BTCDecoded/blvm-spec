# BLVM Consensus — Intentional Deviations from Bitcoin Core

This document records every place where `blvm-consensus` deliberately differs from
Bitcoin Core's behaviour, along with the rationale and the formal-verification status
of each deviation.

All deviations are **intentional** and have been reviewed for consensus-safety.
Nothing here implies a consensus *incompatibility* with Bitcoin Core on a block a
supported network can produce. D-09 through D-11 are unreachable on mainnet, testnet,
testnet4, signet, and regtest. D-11 is the spec-locked `get_next_work_required`:
it errors on an inverted period, and the body proof records that error. Connect
uses `retarget_bits`, which clamps.

---

## D-01 — Signed `Integer` type for economic values

| Field | Detail |
|---|---|
| Bitcoin Core | `int64_t` for amounts, subsidies, fees (implicit non-negativity enforced by assertion) |
| BLVM | `Integer` (alias for `i64`) with explicit `#[ensures(result >= 0)]` postconditions |
| Files | `economic.rs`, `lib.rs` |
| Status | Annotated and Z3-checked. `get_block_subsidy` (`#[spec_locked("6.1")]`) and `total_supply` (`#[spec_locked("6.2")]`) carry `ensures(result >= 0)`. Both are on the older 93-of-224 list. The body-proof pass is 13 functions and does not include these two ([VERIFICATION.md](https://github.com/BTCDecoded/blvm-consensus/blob/main/docs/VERIFICATION.md)). |

**Rationale:** The Orange Paper models economic quantities as integers
($\mathbb{Z}$) so that the type system does not silently hide underflow bugs.
Non-negativity is a proof obligation, not an implicit type guarantee.  `Natural` (u64)
is reserved for counts and lengths that are *by construction* non-negative.

---

## D-02 — Script integer range: 5-byte CScriptNum sentinel

| Field | Detail |
|---|---|
| Bitcoin Core | `CScriptNum` (up to 5 bytes, range ±549,755,813,887) |
| BLVM | `script_num_decode` returns `Integer` with `#[axiom(result >= -549755813887)]` |
| Files | `script/mod.rs` |
| Status | Axiom trusted; Bitcoin Core numeric range encoded as blvm-spec-lock axiom |

**Rationale:** The 5-byte CScriptNum bound is a consensus rule.  BLVM's translator
cannot automatically derive it from the bitwise decoding loop, so it is encoded as a
trusted `#[axiom]` rather than a verified postcondition.  The axiom matches the
Bitcoin Core value exactly (BIP-65 reference).

---

## D-03 — Sequence-lock sentinel: `(-1, -1)`

| Field | Detail |
|---|---|
| Bitcoin Core | `std::pair<int32_t, int32_t>` where `-1` means "no constraint" |
| BLVM | `calculate_sequence_locks` returns `(Integer, Integer)` with `#[axiom(result_0 >= -1)]`, `#[axiom(result_1 >= -1)]` |
| Files | `sequence_locks.rs` |
| Status | Axioms trusted; loop body not Z3-translatable |

**Rationale:** The sentinel value `-1` is a Bitcoin Core convention for "sequence
lock does not apply".  BLVM preserves the semantics exactly and encodes the lower
bound as a trusted axiom because the loop-and-conditionals body is beyond the current
Z3 translator's scope.

---

## D-04 — Witness sigops: only v0 counted

| Field | Detail |
|---|---|
| Bitcoin Core | `WitnessSigOps` counts only version-0 (P2WPKH, P2WSH); v1 (Taproot) returns 0 |
| BLVM | `witness_sigop_count` follows the same rule: Taproot returns 0 |
| Files | `sigop.rs` |
| Status | Documented alignment — no deviation |

**Rationale:** Taproot (BIP-341) introduced a new sigop accounting model (`annex`
size-based limits) that is distinct from the legacy sigop budget.  Both Bitcoin Core
and BLVM return 0 for v1 witness sigops and rely on the Taproot-specific checks
separately.

---

## D-05 — Single OP_RETURN per transaction (policy, not consensus)

| Field | Detail |
|---|---|
| Bitcoin Core | Policy rejects transactions with more than one OP_RETURN output |
| BLVM | `mempool.rs::is_standard_tx` rejects transactions with `> 1` OP_RETURN |
| Files | `mempool.rs` |
| Status | Policy rule — consensus accepts multiple OP_RETURN; policy does not |

**Rationale:** This is a *policy* rule enforced in the mempool, not a consensus rule.
Blocks can contain multiple OP_RETURN outputs and remain valid.  BLVM follows Bitcoin
Core's standard-transaction policy here.

---

## D-06 — Merkle root: always returns a value (no `mutated` output parameter)

| Field | Detail |
|---|---|
| Bitcoin Core | `ComputeMerkleRoot(leaves, &mutated)` returns root and sets `mutated` bool |
| BLVM | `compute_merkle_root` / `compute_merkle_root_always` return `Hash`; mutation detection is separate |
| Files | `mining.rs` |
| Status | Behavioural equivalence; mutation detection split into `has_duplicate_txids` |

**Rationale:** The Orange Paper separates concerns.  The root computation is
pure `Hash → Hash`; mutation detection (duplicate txids that could enable CVE-2012-2459
attacks) is a separate predicate.  Bitcoin Core's in/out parameter pattern is refactored
for clarity and testability.

---

## D-07 — `calculate_fee` returns `Result<Integer>` (not a plain integer)

| Field | Detail |
|---|---|
| Bitcoin Core | Fee is computed inline; overflow aborts / returns error via exception or assert |
| BLVM | `calculate_fee` returns `Result<Integer>` with `#[ensures(result >= 0)]` on the inner value |
| Files | `economic.rs` |
| Status | Annotated and Z3-checked. `calculate_fee` (`#[spec_locked("6.5")]`) carries `ensures(result >= 0)` and is on the older 93-of-224 list (6 / 6). It is not one of the 13 functions proved from the body ([VERIFICATION.md](https://github.com/BTCDecoded/blvm-consensus/blob/main/docs/VERIFICATION.md)). |

**Rationale:** Explicit `Result` makes the overflow / invalid-input failure mode
part of the function's API contract instead of a runtime panic.  The postcondition
`ensures(result >= 0)` states the contract the Z3 check targets: fees are never
negative when inputs cover outputs.

---

## D-08 — `Natural` / `Integer` type aliases as Orange Paper primitives

| Field | Detail |
|---|---|
| Bitcoin Core | Uses C++ primitive types (`int64_t`, `uint32_t`, etc.) directly |
| BLVM | Uses `Natural = u64` and `Integer = i64` as semantic type aliases |
| Files | `blvm-consensus/src/` (all files via re-export) |
| Status | Representation only; no consensus impact |

**Rationale:** Aligns Rust types with Orange Paper mathematics ($\mathbb{N}$ and
$\mathbb{Z}$).  Enables the Z3 translator to reason about signed vs unsigned bounds
without heuristics.

---

## D-09 — Compact exponents outside 3..=32

| Field | Detail |
|---|---|
| Bitcoin Core | `arith_uint256::SetCompact` assigns every encoding a value. An exponent below 3 shifts the mantissa right. A larger exponent is overflow only when the digits do not fit in 256 bits. |
| BLVM | `expand_target` returns an error when the exponent is outside 3..=32. `POW-002` and §7.1 state that domain. |
| Files | `pow.rs` |
| Status | Unreachable. A header's bits must equal the required bits, which are the compression of a real target. |

**Rationale:** The Orange Paper defines `ExpandTarget` only on that domain. Core has no rule about the exponent itself. No supported network produces an exponent outside it, so no block outcome differs.

---

## D-10 — Retarget product above 2^256

| Field | Detail |
|---|---|
| Bitcoin Core | `CalculateNextWorkRequired` multiplies with `arith_uint256`, which drops the high bits. |
| BLVM | `get_next_work_required` returns the previous bits when the product does not fit in 256 bits, as §7.1 states. `retarget_bits`, which `next_required_bits` and `connect_block` use, returns an error. |
| Files | `pow.rs` |
| Status | Unreachable. The product overflows only for a target above about 2^233.8 on a chain that retargets. Mainnet's limit is 2^224. Signet's limit falls short of the threshold. Regtest's limit is above it, and regtest does not retarget. |

**Rationale:** The named function follows the paper. The connect path fails closed instead of wrapping or returning the previous bits. Neither path is hit on a supported network.

---

## D-11 — Difficulty period whose last timestamp is earlier than its first

| Field | Detail |
|---|---|
| Bitcoin Core | Clamps the timespan to a quarter of the expected timespan. |
| BLVM | §7.1 `ClampTime` clamps. `retarget_bits` clamps. `get_next_work_required` returns an error before the clamp. |
| Files | `pow.rs` |
| Status | The connect path matches Core. The spec-locked `get_next_work_required` does not. Its body proof treats a reversed period as an error. |

**Rationale:** Connect uses `retarget_bits`. Changing the named function to clamp requires the same change in the work-adjustment proof, which currently requires the error.

---

## Maintenance

When adding a new intentional deviation:

1. Add a new `D-NN` entry to this file.
2. If it can be formally captured, add an `#[ensures]` or `#[axiom]` annotation.
3. Reference this file's ID in the code comment near the deviation.
4. If it affects formal verification, update the **Status** column and any related `#[ensures]` / `#[axiom]` annotations in code.
