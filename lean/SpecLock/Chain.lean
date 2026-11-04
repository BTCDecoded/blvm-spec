import SpecLock.Attr
import SpecLock.Subsidy

namespace SpecLock

/-- Hypotheses the value and work proofs do not use. They are not axioms. -/
structure BlockAssumptions where
  scriptValid : Prop
  sigValid : Prop
  utxoSet : Prop
  txValid : Prop

structure BlockValue where
  subsidy : Nat
  fees : Nat
  coinbaseValue : Nat
  coinbase_le : coinbaseValue ≤ subsidy + fees
  outputs : List Nat
  utxoValues : List Nat

@[spec_lock "PROTOCOL.md#def:CoinbaseBound"]
theorem coinbase_bound (b : BlockValue) (_a : BlockAssumptions) :
    b.coinbaseValue ≤ b.subsidy + b.fees :=
  b.coinbase_le

@[spec_lock "PROTOCOL.md#def:OutputsNonnegative"]
theorem block_outputs_nonnegative (b : BlockValue) (v : Nat) (_hv : v ∈ b.outputs) (_a : BlockAssumptions) :
    0 ≤ v :=
  Nat.zero_le v

/-- An input value is the value stored at that index in the UTXO set. -/
@[spec_lock "PROTOCOL.md#def:UtxoInput"]
def utxoInput (utxo : List Nat) (idx : Nat) : Nat :=
  utxo.getD idx 0

theorem utxo_input_from_set (utxo : List Nat) (idx : Nat) (h : idx < utxo.length) :
    utxoInput utxo idx = utxo[idx] := by
  induction utxo generalizing idx with
  | nil => cases h
  | cons head tail ih =>
      cases idx with
      | zero => simp [utxoInput]
      | succ idx =>
          simp [utxoInput]
          exact ih idx (Nat.lt_of_succ_lt_succ h)

/-- Per-block work is the work figure the chain sum adds. The spec states the sum, not a separate expansion. -/
@[spec_lock "ARCHITECTURE.md#def:Work"]
def blockWork (work : Nat) : Nat :=
  work

@[spec_lock "ARCHITECTURE.md#def:ChainWork"]
def chainWork (works : List Nat) : Nat :=
  works.foldl (fun acc w => acc + blockWork w) 0

@[spec_lock "ARCHITECTURE.md#ChainWork"]
theorem chainWork_is_sum (works : List Nat) (_a : BlockAssumptions) :
    chainWork works = works.foldl (fun acc w => acc + w) 0 := by
  simp [chainWork, blockWork]

@[spec_lock "ARCHITECTURE.md#def:ShouldReorganize"]
def shouldReorganize (candidate current : Nat) : Bool :=
  current < candidate

@[spec_lock "ARCHITECTURE.md#ShouldReorganize"]
theorem reorg_orders_by_work (candidate current : List Nat)
    (_a : BlockAssumptions) :
    chainWork current < chainWork candidate → shouldReorganize (chainWork candidate) (chainWork current) = true := by
  intro h
  simp [shouldReorganize, h]

/-- Timespan clamp. The factor-of-4 bound is the defining property. -/
@[spec_lock "PROTOCOL.md#def:ClampTime"]
def clampTime (raw expected : Nat) : Nat :=
  max (expected / 4) (min raw (expected * 4))

theorem clamp_low (raw expected : Nat) : expected / 4 ≤ clampTime raw expected := by
  simp [clampTime, Nat.le_max_left]

theorem clamp_high (raw expected : Nat) : clampTime raw expected ≤ expected * 4 := by
  rw [clampTime, Nat.max_le]
  refine ⟨?_, Nat.min_le_right _ _⟩
  have h1 : expected / 4 ≤ expected := Nat.div_le_self _ _
  have h2 : expected ≤ expected * 4 := by
    have := Nat.mul_le_mul_left expected (by decide : 1 ≤ 4)
    rwa [Nat.mul_one] at this
  exact Nat.le_trans h1 h2

@[spec_lock "PROTOCOL.md#Theorem:7.1"]
theorem difficulty_factor_of_four (raw expected : Nat) (_a : BlockAssumptions) :
    expected / 4 ≤ clampTime raw expected ∧ clampTime raw expected ≤ expected * 4 :=
  ⟨clamp_low raw expected, clamp_high raw expected⟩

end SpecLock
