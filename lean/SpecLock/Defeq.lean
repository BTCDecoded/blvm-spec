import SpecLock.Subsidy

namespace SpecLock

/-- The emitted 6.1.2 statement is the locked theorem, by definitional equality. -/
example : ∀ (h : Nat), h ≥ (33 * H) → (getBlockSubsidy h = 0) :=
  subsidy_zero_from_epoch_33

/-- Emitted case: floor(h / H) ≥ 64 gives 0. -/
example : ∀ (h : Nat), ((h / H) ≥ 64) → (getBlockSubsidy h = 0) := by
  intro h hk
  simp [getBlockSubsidy, hk]

/-- Emitted case: otherwise the value is floor division by a power of two. -/
example : ∀ (h : Nat), (¬ ((h / H) ≥ 64)) → (getBlockSubsidy h = (initialSubsidy / (2 ^ (h / H)))) := by
  intro h hk
  simp [getBlockSubsidy, hk]

/-- Emitted exhaustiveness: the two arms cover every height. -/
example : ∀ (h : Nat), ((h / H) ≥ 64 ∨ (¬ ((h / H) ≥ 64))) := by
  intro h
  exact Classical.em ((h / H) ≥ 64)

/-- Emitted disjointness: the arms do not overlap. -/
example : ∀ (h : Nat), (¬ (((h / H) ≥ 64) ∧ (¬ ((h / H) ≥ 64)))) := by
  intro h hp
  exact hp.2 hp.1

end SpecLock
