# BLVM Consensus — Intentional Deviations from Bitcoin Core

This document records every place where `blvm-consensus` deliberately differs from
Bitcoin Core's behaviour, along with the rationale and the formal-verification status
of each deviation.

All deviations are **intentional** and have been reviewed for consensus-safety.
Nothing here implies a consensus *incompatibility* with Bitcoin Core — every item
either is a representation choice that produces identical consensus results, or is an
explicitly documented extension / policy decision.

---

## D-01 — Signed `Integer` type for economic values

| Field | Detail |
|---|---|
| Bitcoin Core | `int64_t` for amounts, subsidies, fees (implicit non-negativity enforced by assertion) |
| BLVM | `Integer` (alias for `i64`) with explicit `#[ensures(result >= 0)]` postconditions |
| Files | `economic.rs`, `lib.rs` |
| Status | Formally verified: `get_block_subsidy` and `total_supply` carry `ensures(result >= 0)` proven by blvm-spec-lock / Z3 |

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
| Status | Formally verified: non-negativity proven by blvm-spec-lock / Z3 |

**Rationale:** Explicit `Result` makes the overflow / invalid-input failure mode
part of the function's API contract instead of a runtime panic.  The postcondition
`ensures(result >= 0)` is a semantic proof: fees can never be negative when inputs
cover outputs.

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

## Maintenance

When adding a new intentional deviation:

1. Add a new `D-NN` entry to this file.
2. If it can be formally captured, add an `#[ensures]` or `#[axiom]` annotation.
3. Reference this file's ID in the code comment near the deviation.
4. Update `END_TO_END_PROOF_PLAN.md` if the deviation affects coverage metrics.
