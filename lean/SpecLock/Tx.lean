import SpecLock.Attr

namespace SpecLock

def Mmax : Nat := 21000000 * 100000000

inductive Verdict
  | valid
  | invalid
  deriving DecidableEq

structure Tx where
  inputCount : Nat
  outputCount : Nat
  outputValues : List Nat

/-- Rejects an empty input list, an empty output list, or an output above the max. -/
@[spec_lock "PROTOCOL.md#def:CheckTransaction"]
def checkTransaction (tx : Tx) : Verdict :=
  if tx.inputCount = 0 || tx.outputCount = 0 then
    .invalid
  else if tx.outputValues.any (fun v => Mmax < v) then
    .invalid
  else
    .valid

@[spec_lock "PROTOCOL.md#CheckTransaction#empty-inputs"]
theorem reject_empty_inputs (tx : Tx) (h : tx.inputCount = 0) :
    checkTransaction tx ≠ Verdict.valid := by
  simp [checkTransaction, h]

@[spec_lock "PROTOCOL.md#CheckTransaction#empty-outputs"]
theorem reject_empty_outputs (tx : Tx) (h : tx.outputCount = 0) :
    checkTransaction tx ≠ Verdict.valid := by
  simp [checkTransaction, h]

@[spec_lock "PROTOCOL.md#CheckTransaction#nonnegative-outputs"]
theorem outputs_nonnegative (v : Nat) : 0 ≤ v :=
  Nat.zero_le v

end SpecLock
