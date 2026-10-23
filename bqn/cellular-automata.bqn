# Copyright (C) 2026 AHMAD ALI PARR
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# ============================================================================
# cellular-automata.bqn
# Production BQN Module: Recursive Invariant Extraction from
# Cellular Automata Payload
#
# Source-preserved core: PHI, ATOMIC_KEYS, F_FIB, EvolveCAState,
# BuildCAResponseMatrix, ExtractRecursiveInvariant.
#
# Extended with multi-step evolution, invariant time-series,
# atomic-key masking, residual diagnostics, and batch pipelines.
# Status: Specification scaffold with production structure.
# ============================================================================

PHI ← 1.618033988749895
ATOMIC_KEYS ← 1 6 7 8
F_FIB ← 4 7 11 18 29 47
CARRIER_HZ ← 46.9787
MAX_DENSITY ← 64
RESIDUAL_WARN ← 0.15
RESIDUAL_FAIL ← 0.35
N_FIB ← ≠F_FIB
π ← 3.141592653589793

EvolveCAState ← {
  neighbor_sum ← (1 ⌽ + ¯1 ⌽ ⊢) 𝕩
  rule_mask ← (neighbor_sum = 3) ∨ (𝕩 ∧ (neighbor_sum = 2))
  rule_mask
}
BuildCAResponseMatrix ← {
  ca_trajectory ← 𝕩
  t ← ÷ 𝕉 ↕ ≢ ca_trajectory
  c ← { 2 × π × 𝕩 × t } ¨ F_FIB
  cos_cols ← cos ¨ c ⋄ sin_cols ← sin ¨ c
  ∾˘ cos_cols ∾ sin_cols
}
ExtractRecursiveInvariant ← {
  A ← 𝕨 BuildCAResponseMatrix 𝕩
  At ← ⍉ A ⋄ inv ← {⌹ 𝕩} (At +.× A)
  x_star ← inv +.× (At +.× 𝕩)
  predicted ← A +.× x_star ⋄ residual ← 𝕩 - predicted
  invariant ← (+/ residual⋆2) ÷ (+/ 𝕩⋆2)
  invariant
}

EvolveN ← {
  n ← 𝕨 ⋄ state ← 𝕩
  { n ≤ 0 ? state ; (n-1) EvolveN EvolveCAState state }
}
Trajectory ← {
  nSteps ← 𝕨 ⋄ init ← 𝕩
  states ← ⟨init⟩ ⋄ cur ← init
  { 𝕩 > 0 ? cur ↩ EvolveCAState cur ⋄ states ↩ states ∾ ⟨cur⟩ ⋄ 𝕩-1 ; states } nSteps
  states
}
DensityCA ← { (+/ 𝕩) ÷ 1⌈≠𝕩 }
AliveCount ← { +/ 𝕩 }

BuildCAResponseMatrixProd ← {
  traj ← 𝕩
  {
    1 = =traj ?
      t ← ↕ ≠traj
      cosPart ← > {cos 2 × π × 𝕩 × t ÷ ≠t} ¨ F_FIB
      sinPart ← > {sin 2 × π × 𝕩 × t ÷ ≠t} ¨ F_FIB
      cosPart ∾˘ sinPart ;
    n ← 0 ⊑ ≢ traj ⋄ t ← ↕ n
    cosPart ← > {cos 2 × π × 𝕩 × t ÷ n} ¨ F_FIB
    sinPart ← > {sin 2 × π × 𝕩 × t ÷ n} ¨ F_FIB
    cosPart ∾˘ sinPart
  }
}

SafeInvariant ← {
  A ← 𝕨 ⋄ y ← 𝕩 ⋄ At ← ⍉ A ⋄ AtA ← At +.× A
  inv ← {⌹ 𝕩} AtA ⋄ x_star ← inv +.× (At +.× y)
  predicted ← A +.× x_star ⋄ residual ← y - predicted
  num ← +/ residual⋆2 ⋄ den ← +/ y⋆2 ⋄ num ÷ 1⌈den
}
ExtractInvariantProd ← {
  y ← 𝕩 ⋄ A ← BuildCAResponseMatrixProd y ⋄ inv ← A SafeInvariant y
  status ← { inv < RESIDUAL_WARN ? "OK" ; inv < RESIDUAL_FAIL ? "WARN" ; "FAIL" }
  ⟨inv, status⟩
}
InvariantSeries ← {
  traj ← 𝕩 ⋄ densSeries ← DensityCA ¨ traj ⋄ ExtractInvariantProd densSeries
}

MaskAtomicKeys ← {
  state ← 𝕩 ⋄ keys ← ATOMIC_KEYS - 1
  mask ← 0 ¨ state
  mask ↩ {keys ∊ 𝕩 ? 1 ; 0} ¨ ↕ ≠state
  state × mask
}
EvolveMasked ← { state ← 𝕩 ⋄ EvolveCAState MaskAtomicKeys state }

ProcessCABatch ← {
  inits ← 𝕩 ⋄ nSteps ← 𝕨
  { traj ← nSteps Trajectory 𝕩 ⋄ InvariantSeries traj } ¨ inits
}
AggregateInvariants ← { results ← 𝕩 ⋄ { ⊑ 𝕩 } ¨ results }

CAStable ← { state ← 𝕩 ⋄ d ← DensityCA state ⋄ (d ≥ 0) ∧ (d < 1) }
TrajectoryStable ← { traj ← 𝕩 ⋄ ∧´ CAStable ¨ traj }
DensityPeriodProxy ← {
  dens ← DensityCA ¨ 𝕩 ⋄ start ← ⊑ dens
  idx ← 1 ↓ / (| dens - start) < 0.05
  { 0 = ≠idx ? ≠dens ; ⊑ idx }
}

DefaultCAConfig ← {
  phi ⇐ PHI ⋄ atomicKeys ⇐ ATOMIC_KEYS ⋄ fib ⇐ F_FIB
  residualWarn ⇐ RESIDUAL_WARN ⋄ residualFail ⇐ RESIDUAL_FAIL ⋄ maxDensity ⇐ MAX_DENSITY
}

RunCAInvariant ← {
  init ← 𝕨 ⋄ nSteps ← 𝕩
  traj ← nSteps Trajectory init
  inv‿status ← InvariantSeries traj
  stable ← TrajectoryStable traj
  period ← DensityPeriodProxy traj
  ⟨inv, status, stable, period⟩
}
RunCAWithKeys ← {
  init ← 𝕨 ⋄ nSteps ← 𝕩 ⋄ masked ← MaskAtomicKeys init
  masked RunCAInvariant nSteps
}

FormatCAResult ← {
  inv‿status‿stable‿period ← 𝕩
  ∾⟨ "invariant=", •Repr inv, " status=", status, " stable=", •Repr stable, " periodProxy=", •Repr period ⟩
}

RandomState ← { n ← 𝕩 ⋄ { •rand.Range 2 } ¨ ↕ n }
SelfTestEvolve ← { s ← RandomState 32 ⋄ s2 ← EvolveCAState s ⋄ ≠s2 }
SelfTestTrajectory ← { s ← RandomState 16 ⋄ traj ← 5 Trajectory s ⋄ ≠traj }
SelfTestInvariant ← { s ← RandomState 24 ⋄ result ← s RunCAInvariant 8 ⋄ ⊑ result }

# Primary API: RunCAInvariant, RunCAWithKeys, ExtractInvariantProd, Trajectory
# Source-preserved: EvolveCAState, BuildCAResponseMatrix, ExtractRecursiveInvariant
# End of cellular-automata.bqn
