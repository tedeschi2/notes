/-
Quiz 2 Daniel Tedeschi
Complete the following proofs by filling in the correct tactic name.
-/

variable (p q r : Prop) 

example : (p → q) → (q → r) → p → r := by 
  intro f g h
  apply f g
  exact h


example (f : p → q) (h : p) : q := by 
  apply f
  exact h 


example : p → q → p := by
  intro h _
  exact h