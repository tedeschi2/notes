import Mathlib.Data.Nat.Prime

namespace Intro 
/- 
We can declare variables of type Prop as 
-/
variable (p q : Prop) 

/-
Terms of type (p : Prop) are _proofs_ of the proposition p. 
We state a theorem to declare we want to produce a proof 
-/
theorem foo : p := sorry 

/-
Of course we cannot fill in this sorry. Not every proposition in 
that can be stated in Lean will have a proof. For example, 
-/ 
theorem crazy : ∀ (n : ℕ), Nat.Prime n := sorry 

def notGood : Prop := ∀ (n : ℕ), Nat.Prime n

theorem also_crazy : notGood := sorry

end Intro 
/- 
Under the rules of propositional and higher logics, there are 
a handful of ways to make new propositions, called _connectives_, 
and a handful to rules to produce new proofs from old ones, _rules 
of inference_. 
The connectives in propositional logic are 
- implication : p → q 
- conjunction : p ∧ q
- disjunction : p ∨ q 
- negation : ¬ p 
- bi-implication : p ↔ q 
Each takes an existing set of propositions and constructs a new one. 
They can be iterated, eg (p ↔ q) ∨ ¬ p → q. Note that parentheses 
are important for the order of application of the connectives. 
Each connective comes with rules for providing a proof, introduction 
rules, and using as a hypothesis, elimination rules. 
-/

/- 
Implication
Suppose we have (p q : Prop). What do we need to produce a proof of 
p → q? Well, whenever we have a proof of p, we need to construct 
a proof of q. In Lean, we can see the difference syntactically. 
-/

variable {p q r : Prop}

theorem imp (h : p) : q := sorry 

theorem imp' : p → q := sorry 

/-
The introduction rule says that give `imp` we can conclude `imp'`. 
In Lean, we can give a proof of `imp'` using `imp` and the 
tactics `intro` and `exact`. 
-/

example : p → q := by 
  intro h -- the goal is now q and we have (h : p) in the context
  exact imp h  -- tells Lean that `imp h` is _exactly_ the term we want

--intro allows us to assume some value and "see where it goes"
/-
The elimination rule says that give `f : p → q` and `h : p` we can 
conclude `q`. 
-/

example (h : p) (f : p → q) : q := by 
  apply f --takes the given state (goal is q) and if we apply f, "see what happens"
  exact h
 

example (h : p) : p := by
  exact h

example : p → p := by
  intro h
  exact h
/- 
In Lean, propositional implication is a function type. Application is 
elimination. The tactic `apply` allows us to replace a goal `β` with 
`α` if we have a term of type `α → β` in the context.
-/

/- 
Unlike implication, conjunction is defined separately in Lean. In Lean 
core, it is defined as. 
structure And (a b : Prop) : Prop where
  /-- `And.intro : a → b → a ∧ b` is the constructor for the And operation. -/
  intro ::
  /-- Extract the left conjunct from a conjunction. `h : a ∧ b` then
  `h.left`, also notated as `h.1`, is a proof of `a`. -/
  left : a
  /-- Extract the right conjunct from a conjunction. `h : a ∧ b` then
  `h.right`, also notated as `h.2`, is a proof of `b`. -/
  right : b
Built into its definition are its introduction `intro` and its two 
elimination rules `left` and `right`.
-/

example : (p ∧ q → r) → p → q → r := by
  intro h hp hq

  apply h
  apply And.intro
  · exact hp
  · exact hq

example : (p ∧ q) → p := by
  intro h
  exact h.left

example : (p ∧ q) ∧ r → p ∧ q ∧ r := by
  sorry

example (h : r → p) (h' : r → q) : r → p ∧ q := by
  intro h₃
  apply And.intro
  · exact h h₃
  · exact h' h₃

  

/- 
Disjunction is also its own type. 
`Or a b`, or `a ∨ b`, is the disjunction of propositions. There are two
constructors for `Or`, called `Or.inl : a → a ∨ b` and `Or.inr : b → a ∨ b`,
and you can use `match` or `cases` to destruct an `Or` assumption into the
two cases.
inductive Or (a b : Prop) : Prop where
  /-- `Or.inl` is "left injection" into an `Or`. If `h : a` then `Or.inl h : a ∨ b`. -/
  | inl (h : a) : Or a b
  /-- `Or.inr` is "right injection" into an `Or`. If `h : b` then `Or.inr h : a ∨ b`. -/
  | inr (h : b) : Or a b
Disjunction has two introduction rules, intro left or `inl` and intro right or `inr`. 
It's elimination rule is derived from the fact it is an inductive type. 
-/

example : (p → q) → (q → q ∨ r) := by
  intro _ h₁
  apply Or.inl h₁
   

example : (p ∨ q → r) → (p → r) → q → r := by
  intro h _ h₂
  apply h
  exact Or.inr h₂
  
example : p ∨ q → (p → r) → (q → r) → r := by
  intro h h₁ h₂
  match h with
  | .inl h => exact h₁ h
  | .inr h => exact h₂ h

/- 
Negatation relies on `False : Prop`. 
`False` is the empty proposition. Thus, it has no introduction rules.
It represents a contradiction. `False` elimination rule 
expresses the fact that anything follows from a contradiction.
This rule is sometimes called ex falso (short for ex falso sequitur quodlibet),
or the principle of explosion.
inductive False : Prop
-/
variable (crazy : Prop)

example (f : False) : crazy := by
  /-cases f -/
  exact f.elim 

/- 
There is a corresponding type `True : Prop` with a single constructor. 
`True.intro`. 
By definition in Lean, `¬ p` is _defined as_ `p → False`. 
-/

example : (p → q) → ¬ q → ¬ p := by
  intro f nq hp
  apply nq
  apply f
  exact hp


example : ¬ p ∨ ¬ q → ¬ (p ∧ q) := by
  intro h hpq
  apply Or.elim h
  · intro np
    exact np hpq.left
  · intro nq
    exact nq hpq.right


/-
Finally bi-implication or if-and-only-if looks a bit similar to `And` 
under the hood. 
If and only if, or logical bi-implication. `a ↔ b` means that `a` implies `b`
and vice versa.
structure Iff (a b : Prop) : Prop where
  /-- If `a → b` and `b → a` then `a` and `b` are equivalent. -/
  intro ::
  /-- Modus ponens for if and only if. If `a ↔ b` and `a`, then `b`. -/
  mp : a → b
  /-- Modus ponens for if and only if, reversed. If `a ↔ b` and `b`, then `a`. -/
  mpr : b → a
-/

example (h : p ↔ q) : (q → r) → p → r := by
  intro hqr hp
  have hq : q := h.mp hp
  exact hqr hq


example : ¬ (p ↔ ¬ p) := by
  intro h
  have : ¬ p := sorry
  apply this
  apply h.mpr
  exact this

example (h : ¬ ¬ p) : p := by
  have h' : p ∨ ¬ p := Classical.em p
  match h' with
  | .inl hp => exact hp
  | .inr np =>
    apply False.elim
    exact h np


example (h : p) : ¬ ¬ p := by
  intro np
  exact np h