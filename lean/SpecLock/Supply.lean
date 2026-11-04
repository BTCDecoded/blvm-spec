import SpecLock.Attr
import SpecLock.Subsidy

namespace SpecLock

def maxMoney : Nat := 21 * 10 ^ 6 * C

/-- Sum of `getBlockSubsidy` over `0 ..< n`. -/
def sumBelow : Nat → Nat
  | 0 => 0
  | n + 1 => sumBelow n + getBlockSubsidy n

/-- Sum of the per-epoch subsidy for epochs `0 ..< n`. -/
def epochSum : Nat → Nat
  | 0 => 0
  | n + 1 => epochSum n + initialSubsidy / (2 ^ n)

@[spec_lock "PROTOCOL.md#def:TotalSupply"]
def totalSupply : Nat → Nat
  | 0 => getBlockSubsidy 0
  | h + 1 => totalSupply h + getBlockSubsidy (h + 1)

theorem totalSupply_eq_sum (h : Nat) : totalSupply h = sumBelow (h + 1) := by
  induction h with
  | zero => rfl
  | succ h ih =>
      rw [totalSupply, ih, sumBelow]
      rfl

theorem subsidy_in_epoch (k i : Nat) (hi : i < H) (hk : k < 64) :
    getBlockSubsidy (k * H + i) = initialSubsidy / 2 ^ k := by
  have hH : 0 < H := by decide
  have hdiv : (k * H + i) / H = k := by
    have : k * H + i = i + H * k := by
      rw [Nat.mul_comm k H, Nat.add_comm]
    rw [this, Nat.add_mul_div_left i k hH]
    have : i / H = 0 := Nat.div_eq_of_lt hi
    simp [this]
  simp only [getBlockSubsidy, hdiv]
  simp [Nat.not_le.mpr hk]

theorem sumBelow_add (start count v : Nat)
    (h : ∀ i, i < count → getBlockSubsidy (start + i) = v) :
    sumBelow (start + count) = sumBelow start + count * v := by
  induction count with
  | zero => simp [Nat.add_zero, Nat.zero_mul]
  | succ count ih =>
      rw [Nat.add_succ, sumBelow]
      rw [ih (fun i hi => h i (Nat.lt_succ_of_lt hi))]
      rw [h count (Nat.lt_succ_self count)]
      rw [Nat.add_assoc, ← Nat.succ_mul]

theorem sumBelow_epochs (n : Nat) (hn : n ≤ 33) : sumBelow (n * H) = H * epochSum n := by
  induction n with
  | zero => simp [sumBelow, epochSum]
  | succ n ih =>
      have hn33 : n < 33 := Nat.lt_of_succ_le hn
      have hn64 : n < 64 := Nat.lt_trans hn33 (by decide : 33 < 64)
      rw [Nat.succ_mul]
      rw [sumBelow_add (n * H) H (initialSubsidy / 2 ^ n)
        (fun i hi => subsidy_in_epoch n i hi hn64)]
      rw [ih (Nat.le_of_succ_le hn), epochSum, ← Nat.mul_add]

theorem issued_supply_value : H * epochSum 33 = 2099999997690000 := by
  decide

@[spec_lock "PROTOCOL.md#Theorem:6.2.1"]
theorem totalSupply_mono (h1 h2 : Nat) (h : h1 ≤ h2) : totalSupply h1 ≤ totalSupply h2 := by
  induction h2 with
  | zero =>
      cases Nat.eq_zero_of_le_zero h
      exact Nat.le_refl _
  | succ h2 ih =>
      rcases Nat.eq_or_lt_of_le h with heq | hlt
      · cases heq
        exact Nat.le_refl _
      · exact Nat.le_trans (ih (Nat.le_of_lt_succ hlt)) (Nat.le_add_right _ _)

theorem subsidy_zero_past (h : Nat) (hh : 33 * H ≤ h) : getBlockSubsidy h = 0 :=
  subsidy_zero_from_epoch_33 h hh

theorem supply_constant (h : Nat) (hh : 33 * H ≤ h) : totalSupply h = totalSupply (33 * H) := by
  induction h with
  | zero =>
      have : 33 * H = 0 := Nat.eq_zero_of_le_zero hh
      have ne : 33 * H ≠ 0 := by decide
      exact absurd this ne
  | succ h ih =>
      by_cases hbase : h < 33 * H
      case pos =>
        have heq : h + 1 = 33 * H := Nat.le_antisymm (Nat.succ_le_of_lt hbase) hh
        rw [heq]
      case neg =>
        have hge : 33 * H ≤ h := Nat.le_of_not_lt hbase
        rw [totalSupply, ih hge, subsidy_zero_past (h + 1) hh, Nat.add_zero]

@[spec_lock "PROTOCOL.md#Theorem:6.2.3"]
theorem totalSupply_exact : totalSupply (33 * H) = 2099999997690000 := by
  have hzero : getBlockSubsidy (33 * H) = 0 :=
    subsidy_zero_past (33 * H) (Nat.le_refl _)
  rw [totalSupply_eq_sum, sumBelow, hzero, Nat.add_zero]
  rw [sumBelow_epochs 33 (Nat.le_refl _), issued_supply_value]

@[spec_lock "PROTOCOL.md#Theorem:6.2.2"]
theorem totalSupply_le_max (h : Nat) : totalSupply h ≤ maxMoney := by
  have cap : totalSupply (33 * H) ≤ maxMoney := by
    rw [totalSupply_exact]
    decide
  by_cases hh : h ≤ 33 * H
  · exact Nat.le_trans (totalSupply_mono h (33 * H) hh) cap
  · have hge : 33 * H ≤ h := Nat.le_of_not_le hh
    rw [supply_constant h hge]
    exact cap

/-- The real-valued series is not the issued supply. The report keeps this
    sentence as `spec_disputed`; the emission is not rewritten to the integer. -/
theorem real_series_ne_issued : H * initialSubsidy * 2 ≠ totalSupply (33 * H) := by
  rw [totalSupply_exact]
  decide

end SpecLock
