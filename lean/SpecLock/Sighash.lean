import SpecLock.Attr

namespace SpecLock

/-- Low five bits of the sighash byte. `byte % 32` is `byte &&& 31`. -/
@[spec_lock "PROTOCOL.md#Formula:F_SighashBase"]
def sighashBase (byte : Nat) : Nat :=
  byte % 32

theorem sighashBase_low_bits (byte : Nat) : sighashBase byte = byte % 32 := by
  rfl

end SpecLock
