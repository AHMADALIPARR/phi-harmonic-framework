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
# array-core.bqn
# Shared BQN foundation for the φ-Harmonic inverse stack
#
# Rank helpers, φ-geometry constants, Fibonacci spectral banks,
# design-matrix builders, and least-squares primitives used by
# fibonacci-parameters, inverse-solver, and cellular-automata.
#
# Status: Specification scaffold with production structure.
# Execution not asserted.
# ============================================================================

PHI ← 1.618033988749895
F_FIB ← 4 7 11 18 29 47
CARRIER_HZ ← 46.9787
ATOMIC_KEYS ← 1 6 7 8
MAX_DENSITY ← 64
RESIDUAL_WARN ← 0.15
RESIDUAL_FAIL ← 0.35
N_FIB ← ≠F_FIB
N_COLS ← 2 × N_FIB
π ← 3.141592653589793

# Rank / shape
Rank ← =
IsVec ← 1= =
IsMat ← 2= =
NRows ← {0⊑≢𝕩}
NCols ← {1⊑≢𝕩}
EnsureVec ← {1= =𝕩 ? 𝕩 ; ⥊𝕩}

# φ geometry helpers
PhiPowers ← { PHI⋆↕𝕩 }
FibApprox ← { ⌊0.5+ PHI⋆𝕩 }
WavelengthFromK ← { 2×π÷𝕩 }
KFromPhi ← { 2×π÷PHI }

# Spectral bank
SidebandOffsets ← (-F_FIB)∾F_FIB
CarrierBin ← { ⌊CARRIER_HZ×𝕩÷1 }
FibBins ← {
  n←𝕩 ⋄ c←CarrierBin n
  expected ← ⥊{c+𝕩}¨SidebandOffsets
  expected /˜ (expected≥0) ∧ (expected<n)
}

# Design matrix (time base t)
CosSinCols ← {
  t←𝕩
  cosPart ← >{cos 2×π×𝕩×t}¨F_FIB
  sinPart ← >{sin 2×π×𝕩×t}¨F_FIB
  cosPart∾˘sinPart
}
DesignFromLength ← {
  n←𝕩 ⋄ t←↕n ⋄ CosSinCols t
}

# Least squares
SafeSolveLS ← {
  A←𝕨 ⋄ b←𝕩
  AtA ← (⍉A)+.×A
  d ← 1⊏AtA
  condProxy ← (⌈´|d)÷(1⌈⌊´|d)
  inv ← {⌹𝕩} AtA
  x ← inv+.×((⍉A)+.×b)
  ⟨x,condProxy⟩
}
RelativeResidual ← {
  A←𝕨 ⋄ b←𝕩
  x←⊑A SafeSolveLS b
  r←b-A+.×x
  (√+/r⋆2)÷(1⌈√+/b⋆2)
}
ClassifyResidual ← {
  r←𝕩
  {r<RESIDUAL_WARN?"OK"; r<RESIDUAL_FAIL?"WARN"; "FAIL"}
}

# Amplitudes / phases from coefficient vector
ExtractAmps ← {
  x←𝕩 ⋄ u←N_FIB↑x ⋄ v←N_FIB↓x ⋄ √(u⋆2)+(v⋆2)
}
ExtractPhases ← {
  x←𝕩 ⋄ u←N_FIB↑x ⋄ v←N_FIB↓x ⋄ (-v)⋆u
}

# Residual thresholds config
DefaultCoreConfig ← {
  phi⇐PHI ⋄ fib⇐F_FIB ⋄ carrier⇐CARRIER_HZ
  residualWarn⇐RESIDUAL_WARN ⋄ residualFail⇐RESIDUAL_FAIL
  maxDensity⇐MAX_DENSITY ⋄ atomicKeys⇐ATOMIC_KEYS
}

# Zero crossings (shared)
ZeroCrossings ← {(1⊸⌽≠⊢)×𝕩}
ZeroCrossingIndices ← {/ZeroCrossings 𝕩}
NodeSpacings ← {idx←ZeroCrossingIndices 𝕩 ⋄ 1↓idx-»idx}
MeanNodeSpacing ← {sp←NodeSpacings 𝕩 ⋄ (+/sp)÷1⌈≠sp}

# Export surface for other modules
#   PHI, F_FIB, CARRIER_HZ, ATOMIC_KEYS, N_FIB, N_COLS
#   CosSinCols, DesignFromLength, SafeSolveLS, RelativeResidual
#   ExtractAmps, ExtractPhases, ClassifyResidual, DefaultCoreConfig
#   ZeroCrossings, NodeSpacings, MeanNodeSpacing

# End of array-core.bqn
