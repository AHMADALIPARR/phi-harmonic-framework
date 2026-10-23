-- Copyright (C) 2026 AHMAD ALI PARR
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------
-- ManifoldCollapse.agda
-- Production φ-Harmonic Manifold Collapse Module
--
-- Source-preserved core: Binary, pinch, Manifold, foldManifold,
-- survivesSimulation. Extended with density tracking, wavelength
-- invariants, branch pruning, simulation traces, and proof-oriented
-- helpers suitable for integration with Alloy branch checking and
-- BQN residual analysis.
--
-- Status: Specification scaffold with production structure.
-- No empirical verification is asserted by this module alone.
------------------------------------------------------------------------

module ManifoldCollapse where

open import Agda.Builtin.Nat
open import Agda.Builtin.Bool
open import Agda.Builtin.Equality
open import Agda.Builtin.List
open import Agda.Builtin.String
open import Agda.Builtin.Unit

------------------------------------------------------------------------
-- §1  Core Binary Domain (source-preserved)
------------------------------------------------------------------------

data Binary : Set where
  zero : Binary
  one  : Binary

pinch : Binary → Binary → Binary
pinch zero zero = zero
pinch _    _    = one

binaryToBool : Binary → Bool
binaryToBool zero = false
binaryToBool one  = true

boolToBinary : Bool → Binary
boolToBinary false = zero
boolToBinary true  = one

bnot : Binary → Binary
bnot zero = one
bnot one  = zero

band : Binary → Binary → Binary
band zero _ = zero
band one  b = b

bor : Binary → Binary → Binary
bor one  _ = one
bor zero b = b

bxor : Binary → Binary → Binary
bxor zero b = b
bxor one  b = bnot b

------------------------------------------------------------------------
-- §2  Manifold Datatype (source-preserved + extensions)
------------------------------------------------------------------------

data Manifold (A : Set) : Set where
  Node   : A → Manifold A
  Branch : Manifold A → Manifold A → Manifold A

leaf : {A : Set} → A → Manifold A
leaf = Node

fork : {A : Set} → Manifold A → Manifold A → Manifold A
fork = Branch

depth : {A : Set} → Manifold A → Nat
depth (Node _)     = 0
depth (Branch l r) = suc (max (depth l) (depth r))
  where
    max : Nat → Nat → Nat
    max zero    n       = n
    max m       zero    = m
    max (suc m) (suc n) = suc (max m n)

nodeCount : {A : Set} → Manifold A → Nat
nodeCount (Node _)     = 1
nodeCount (Branch l r) = nodeCount l + nodeCount r

branchCount : {A : Set} → Manifold A → Nat
branchCount (Node _)     = 0
branchCount (Branch l r) = suc (branchCount l + branchCount r)

leftHeavy : {A : Set} → Manifold A → Bool
leftHeavy (Node _) = false
leftHeavy (Branch l r) = nodeCount l > nodeCount r
  where
    _>_ : Nat → Nat → Bool
    zero  > _     = false
    suc _ > zero  = true
    suc m > suc n = m > n

------------------------------------------------------------------------
-- §3  Fold / Catamorphism (source-preserved)
------------------------------------------------------------------------

foldManifold : {A B : Set} → (A → B → B) → B → Manifold A → B
foldManifold f acc (Node x)     = f x acc
foldManifold f acc (Branch l r) =
  foldManifold f (foldManifold f acc l) r

mapManifold : {A B : Set} → (A → B) → Manifold A → Manifold B
mapManifold g (Node x)     = Node (g x)
mapManifold g (Branch l r) = Branch (mapManifold g l) (mapManifold g r)

collectLeaves : {A : Set} → Manifold A → List A
collectLeaves (Node x)     = x ∷ []
collectLeaves (Branch l r) = collectLeaves l ++ collectLeaves r
  where
    _++_ : {A : Set} → List A → List A → List A
    []       ++ ys = ys
    (x ∷ xs) ++ ys = x ∷ (xs ++ ys)

foldManifoldIdx : {A B : Set} → (Nat → A → B → B) → B → Manifold A → B
foldManifoldIdx f acc m = go 0 acc m
  where
    go : Nat → B → Manifold A → B
    go i acc (Node x)     = f i x acc
    go i acc (Branch l r) =
      let acc' = go i acc l
      in  go (suc i) acc' r

------------------------------------------------------------------------
-- §4  Survival Predicate (source-preserved core)
------------------------------------------------------------------------

survivesSimulation : Manifold Binary → Binary
survivesSimulation m = foldManifold pinch one m

survives : Manifold Binary → Bool
survives m = binaryToBool (survivesSimulation m)

allZero : Manifold Binary → Bool
allZero (Node zero)  = true
allZero (Node one)   = false
allZero (Branch l r) = allZero l ∧ allZero r
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false

allOne : Manifold Binary → Bool
allOne (Node one)   = true
allOne (Node zero)  = false
allOne (Branch l r) = allOne l ∧ allOne r
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false

------------------------------------------------------------------------
-- §5  Density & Wavelength Tracking
------------------------------------------------------------------------

density : Manifold Binary → Nat
density (Node zero)  = 0
density (Node one)   = 1
density (Branch l r) = density l + density r

densitySafe : Manifold Binary → Bool
densitySafe m = density m < 64
  where
    _<_ : Nat → Nat → Bool
    _     < zero  = false
    zero  < suc _ = true
    suc m < suc n = m < n

wavelength : {A : Set} → Manifold A → Nat
wavelength m = suc (depth m)

wavelengthPositive : {A : Set} → (m : Manifold A) → Bool
wavelengthPositive m = wavelength m > 0
  where
    _>_ : Nat → Nat → Bool
    zero  > _     = false
    suc _ > zero  = true
    suc m > suc n = m > n

stableInvariant : Manifold Binary → Bool
stableInvariant m =
  wavelengthPositive m ∧ densitySafe m
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false

------------------------------------------------------------------------
-- §6  Branch Pruning & Stabilisation
------------------------------------------------------------------------

pruneZero : Manifold Binary → Manifold Binary
pruneZero (Node x) = Node x
pruneZero (Branch l r) with allZero l | allZero r
... | true  | true  = Node zero
... | true  | false = pruneZero r
... | false | true  = pruneZero l
... | false | false = Branch (pruneZero l) (pruneZero r)

stabilise : Nat → Manifold Binary → Manifold Binary
stabilise zero    m = m
stabilise (suc n) m =
  let m' = pruneZero m
  in  stabilise n m'

simulateStep : Manifold Binary → Manifold Binary
simulateStep m with survivesSimulation m
... | zero = Node zero
... | one  = m

simulateN : Nat → Manifold Binary → Manifold Binary
simulateN zero    m = m
simulateN (suc n) m = simulateN n (simulateStep m)

------------------------------------------------------------------------
-- §7  Simulation Trace
------------------------------------------------------------------------

data TraceEntry : Set where
  step : Nat → Binary → Nat → TraceEntry

record SimulationTrace : Set where
  field
    entries  : List TraceEntry
    final    : Manifold Binary
    survived : Binary

emptyTrace : SimulationTrace
emptyTrace = record
  { entries  = []
  ; final    = Node one
  ; survived = one
  }

runSimulation : Nat → Manifold Binary → SimulationTrace
runSimulation maxSteps m = go maxSteps 0 m []
  where
    go : Nat → Nat → Manifold Binary → List TraceEntry → SimulationTrace
    go zero    idx current acc = record
      { entries  = acc
      ; final    = current
      ; survived = survivesSimulation current
      }
    go (suc n) idx current acc =
      let s    = survivesSimulation current
          d    = density current
          e    = step idx s d
          next = simulateStep current
      in  go n (suc idx) next (e ∷ acc)

------------------------------------------------------------------------
-- §8  Manifold Builders
------------------------------------------------------------------------

singletonOne : Manifold Binary
singletonOne = Node one

singletonZero : Manifold Binary
singletonZero = Node zero

fullTree : Nat → Manifold Binary
fullTree zero    = Node one
fullTree (suc n) = Branch (fullTree n) (fullTree n)

spine : Nat → Manifold Binary
spine zero    = Node zero
spine (suc n) = Branch (Node one) (spine n)

fromList : List Binary → Manifold Binary
fromList []       = Node zero
fromList (x ∷ []) = Node x
fromList (x ∷ xs) = Branch (Node x) (fromList xs)

altTree : Nat → Binary → Manifold Binary
altTree zero    b = Node b
altTree (suc n) b = Branch (Node b) (altTree n (bnot b))

------------------------------------------------------------------------
-- §9  Invariant Bundle (Alloy-aligned)
------------------------------------------------------------------------

record ManifoldInvariants : Set where
  field
    wlPositive   : Bool
    densInRange  : Bool
    nodePositive : Bool
    survivedFlag : Binary

computeInvariants : Manifold Binary → ManifoldInvariants
computeInvariants m = record
  { wlPositive   = wavelengthPositive m
  ; densInRange  = densitySafe m
  ; nodePositive = nodeCount m > 0
  ; survivedFlag = survivesSimulation m
  }
  where
    _>_ : Nat → Nat → Bool
    zero  > _     = false
    suc _ > zero  = true
    suc m > suc n = m > n

invariantsHold : Manifold Binary → Bool
invariantsHold m =
  let inv = computeInvariants m
  in  ManifoldInvariants.wlPositive inv
    ∧ ManifoldInvariants.densInRange inv
    ∧ ManifoldInvariants.nodePositive inv
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false

------------------------------------------------------------------------
-- §10  Equality & Decision Procedures
------------------------------------------------------------------------

binaryEq : Binary → Binary → Bool
binaryEq zero zero = true
binaryEq one  one  = true
binaryEq _    _    = false

manifoldEq : Manifold Binary → Manifold Binary → Bool
manifoldEq (Node a)     (Node b)       = binaryEq a b
manifoldEq (Branch l r) (Branch l' r') =
  manifoldEq l l' ∧ manifoldEq r r'
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false
manifoldEq _ _ = false

------------------------------------------------------------------------
-- §11  φ-Harmonic Constants (reference)
------------------------------------------------------------------------

φ-approx-num : Nat
φ-approx-num = 1618

φ-approx-den : Nat
φ-approx-den = 1000

carrier-hz-approx : Nat
carrier-hz-approx = 47

fib-sidebands : List Nat
fib-sidebands = 4 ∷ 7 ∷ 11 ∷ 18 ∷ 29 ∷ 47 ∷ []

atomic-keys : List Nat
atomic-keys = 1 ∷ 6 ∷ 7 ∷ 8 ∷ []

------------------------------------------------------------------------
-- §12  Production Logging Hooks
------------------------------------------------------------------------

module Labels where
  survival-ok  : String
  survival-ok  = "SURVIVAL_OK"
  survival-fail : String
  survival-fail = "SURVIVAL_FAIL"
  density-warn : String
  density-warn = "DENSITY_OUT_OF_RANGE"
  wl-warn : String
  wl-warn = "WAVELENGTH_NON_POSITIVE"

diagnose : Manifold Binary → String
diagnose m with survives m | densitySafe m | wavelengthPositive m
... | true  | true  | true  = Labels.survival-ok
... | false | _     | _     = Labels.survival-fail
... | _     | false | _     = Labels.density-warn
... | _     | _     | false = Labels.wl-warn

------------------------------------------------------------------------
-- §13  Batch / Multi-Manifold Operations
------------------------------------------------------------------------

allSurvive : List (Manifold Binary) → Bool
allSurvive []       = true
allSurvive (m ∷ ms) = survives m ∧ allSurvive ms
  where
    _∧_ : Bool → Bool → Bool
    true  ∧ b = b
    false ∧ _ = false

totalDensity : List (Manifold Binary) → Nat
totalDensity []       = 0
totalDensity (m ∷ ms) = density m + totalDensity ms

filterSurviving : List (Manifold Binary) → List (Manifold Binary)
filterSurviving [] = []
filterSurviving (m ∷ ms) with survives m
... | true  = m ∷ filterSurviving ms
... | false = filterSurviving ms

------------------------------------------------------------------------
-- §14  Export Surface
------------------------------------------------------------------------
-- Primary API: survivesSimulation, density, wavelength, invariantsHold,
-- runSimulation, pruneZero, stabilise, stableInvariant
-- Source-preserved definitions unchanged in semantics.

-- End of ManifoldCollapse.agda
