import SpecLock.Attr

namespace SpecLock

/-- Block height when the locktime is below 500000000, and a timestamp otherwise.
`true` is a block height. `false` is a timestamp. -/
@[spec_lock "PROTOCOL.md#def:LocktimeType"]
def LocktimeType (lt : Nat) : Bool :=
  decide (lt < 500000000)

@[spec_lock "PROTOCOL.md#Theorem:5.4.7.2"]
theorem locktime_type_determination (lt : Nat) :
    (lt < 500000000 → LocktimeType lt = true) ∧
      (¬ lt < 500000000 → LocktimeType lt = false) := by
  constructor
  · intro h
    simp [LocktimeType, h]
  · intro h
    simp [LocktimeType, h]

end SpecLock
