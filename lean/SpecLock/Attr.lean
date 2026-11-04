import Lean

open Lean

syntax (name := specLock) "spec_lock" str : attr

/-- The lock id is stored on the declaration so the closure can read it from the environment. -/
initialize specLockAttr : ParametricAttribute String ←
  registerParametricAttribute {
    name := `specLock
    descr := "Orange Paper sentence this declaration locks"
    getParam := fun _ stx => do
      let `(attr| spec_lock $s:str) := stx
        | throwError "spec_lock expects one string"
      return s.getString
  }
