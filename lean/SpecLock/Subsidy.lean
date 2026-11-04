import SpecLock.Attr

namespace SpecLock

@[spec_lock "PROTOCOL.md#const:H"]
def H : Nat := 210000

@[spec_lock "PROTOCOL.md#const:C"]
def C : Nat := 100000000

@[spec_lock "PROTOCOL.md#const:initialSubsidy"]
def initialSubsidy : Nat := 50 * C

/-- Floor division by a power of two. The paper's shift is the same value. -/
@[spec_lock "PROTOCOL.md#def:GetBlockSubsidy"]
def getBlockSubsidy (h : Nat) : Nat :=
  let k := h / H
  if k ≥ 64 then 0 else initialSubsidy / (2 ^ k)

theorem getBlockSubsidy_eq_div (h : Nat) :
    getBlockSubsidy h =
      (let k := h / H; if k ≥ 64 then 0 else initialSubsidy / (2 ^ k)) := by
  rfl

theorem getBlockSubsidy_shift_bridge (h : Nat) :
    getBlockSubsidy h =
      (let k := h / H; if k ≥ 64 then 0 else initialSubsidy >>> k) := by
  simp only [getBlockSubsidy]
  by_cases hk : h / H ≥ 64
  · simp [hk]
  · simp [hk, Nat.shiftRight_eq_div_pow]

theorem div_antitone_denom (a c d : Nat) (hcd : c ≤ d) (hc : 0 < c) : a / d ≤ a / c := by
  rw [Nat.le_div_iff_mul_le hc]
  exact Nat.le_trans (Nat.mul_le_mul_left (a / d) hcd) (Nat.div_mul_le_self a d)

@[spec_lock "PROTOCOL.md#Theorem:6.1.2"]
theorem subsidy_zero_from_epoch_33 (h : Nat) (hh : 33 * H ≤ h) : getBlockSubsidy h = 0 := by
  have hH : 0 < H := by decide
  have hdiv : (33 * H) / H = 33 := by
    rw [Nat.mul_comm]
    exact Nat.mul_div_cancel_left 33 hH
  have hk : 33 ≤ h / H := by
    have step := Nat.div_le_div_right (c := H) hh
    rwa [hdiv] at step
  have hpow : initialSubsidy < 2 ^ (h / H) := by
    have base : initialSubsidy < 2 ^ 33 := by decide
    exact Nat.lt_of_lt_of_le base (Nat.pow_le_pow_right (by decide : 0 < 2) hk)
  change (if h / H ≥ 64 then 0 else initialSubsidy / 2 ^ (h / H)) = 0
  split
  · rfl
  · exact Nat.div_eq_of_lt hpow

@[spec_lock "PROTOCOL.md#Theorem:6.1.1"]
theorem subsidy_epoch_edge (k : Nat) (hk : k < 32) :
    getBlockSubsidy (k * H + H) = getBlockSubsidy (k * H) / 2 := by
  have hH : 0 < H := by decide
  have hdiv1 : (k * H + H) / H = k + 1 := by
    have : k * H + H = H * (k + 1) := by
      rw [Nat.mul_comm k H, Nat.mul_succ]
    rw [this]
    exact Nat.mul_div_cancel_left (k + 1) hH
  have hdiv0 : (k * H) / H = k := by
    rw [Nat.mul_comm]
    exact Nat.mul_div_cancel_left k hH
  have hk64 : k < 64 := Nat.lt_trans hk (by decide : 32 < 64)
  have hk1 : k + 1 < 64 := Nat.lt_of_le_of_lt (Nat.succ_le_of_lt hk) (by decide : 32 < 64)
  simp only [getBlockSubsidy, hdiv1, hdiv0]
  simp [Nat.not_le.mpr hk64, Nat.not_le.mpr hk1]
  rw [Nat.div_div_eq_div_mul, Nat.pow_succ, Nat.mul_comm]

theorem subsidy_antitone (h1 h2 : Nat) (h : h1 ≤ h2) : getBlockSubsidy h2 ≤ getBlockSubsidy h1 := by
  simp only [getBlockSubsidy]
  by_cases h2z : h2 / H ≥ 64
  · simp [h2z]
  · have h1le : h1 / H ≤ h2 / H := Nat.div_le_div_right (c := H) h
    have h1z : ¬ h1 / H ≥ 64 := by
      intro h1big
      exact h2z (Nat.le_trans h1big h1le)
    simp [h2z, h1z]
    exact div_antitone_denom initialSubsidy (2 ^ (h1 / H)) (2 ^ (h2 / H))
      (Nat.pow_le_pow_right (by decide : 0 < 2) h1le)
      (Nat.pow_pos (by decide : 0 < 2))

end SpecLock
