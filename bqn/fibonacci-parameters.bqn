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
# fibonacci-parameters.bqn
# Production BQN: Carrier Demodulation & Fibonacci Amplitude/Phase LS Fit
# Depends on array-core primitives (inlined for standalone use).
# Status: Specification scaffold; execution not asserted.
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

# --- Source-preserved core ---
ZeroCrossings ← { (1 ⊸ ⌽ ≠ ⊢) × 𝕩 }
GetNodeSpacingRatios ← { zc ← ZeroCrossings 𝕩 ⋄ (1 ⌽ ⊢) ÷ ⊢ ⊸ (-) ⟜ zc }
BuildDesignMatrix ← {
  t ← 𝕩
  c ← { 2 × π × 𝕩 × t } ¨ F_FIB
  cos_cols ← cos ¨ c ⋄ sin_cols ← sin ¨ c
  ∾˘ cos_cols ∾ sin_cols
}
SolveLeastSquares ← {
  A ← 𝕨 ⋄ b ← 𝕩 ⋄ At ← ⍉ A
  inv ← {⌹ 𝕩} (At +.× A)
  inv +.× (At +.× b)
}
ExtractFibonacciParams ← {
  x ← 𝕨 SolveLeastSquares 𝕩
  u ← N_FIB ↑ x ⋄ v ← N_FIB ↓ x
  a ← √ (u⋆2) + (v⋆2)
  theta ← (-v) ⋆ u
  a ∾ theta
}
CheckResiduals ← {
  predicted ← 𝕩 ⋄ actual ← 𝕨
  res ← actual - predicted
  (+/ res⋆2) ÷ (+/ actual⋆2)
}

# --- Validation ---
IsValidSignal ← { (1 == =𝕩) ∧ (0 < ≠𝕩) }
IsValidTimeBase ← { (1 == =𝕩) ∧ (≠𝕩 = ≠𝕨) }
ValidateInputs ← {
  sig ← 𝕨 ⋄ t ← 𝕩
  ∧´ ⟨ IsValidSignal sig, IsValidTimeBase ⟨sig, t⟩, N_FIB = ≠F_FIB ⟩
}

# --- Production design matrix ---
BuildDesignMatrixProd ← {
  t ← 𝕩 ⋄ n ← ≠t
  cols ← ⥊ {f←𝕩 ⋄ (cos 2×π×f×t) ∾ (sin 2×π×f×t)} ¨ F_FIB
  n‿(2×N_FIB) ⥊ cols
}
BuildDesignMatrixCols ← {
  t ← 𝕩
  cosPart ← > {cos 2 × π × 𝕩 × t} ¨ F_FIB
  sinPart ← > {sin 2 × π × 𝕩 × t} ¨ F_FIB
  cosPart ∾˘ sinPart
}

# --- Robust LS & diagnostics ---
SafeSolveLS ← {
  A ← 𝕨 ⋄ b ← 𝕩
  AtA ← (⍉A) +.× A
  d ← 1 ⊏ AtA
  condProxy ← (⌈´|d) ÷ (1⌈⌊´|d)
  inv ← {⌹ 𝕩} AtA
  x ← inv +.× ((⍉A) +.× b)
  ⟨x, condProxy⟩
}
ResidualVector ← { A ← 𝕨 ⋄ b ← 𝕩 ⋄ x ← ⊑ A SafeSolveLS b ⋄ b - A +.× x }
ResidualNorm ← { A ← 𝕨 ⋄ b ← 𝕩 ⋄ r ← A ResidualVector b ⋄ √ +/ r⋆2 }
RelativeResidual ← {
  A ← 𝕨 ⋄ b ← 𝕩
  rn ← A ResidualNorm b ⋄ bn ← √ +/ b⋆2
  rn ÷ 1⌈bn
}
ClassifyResidual ← {
  r ← 𝕩
  { r < RESIDUAL_WARN ? "OK" ; r < RESIDUAL_FAIL ? "WARN" ; "FAIL" }
}

ExtractAmplitudes ← { x ← 𝕩 ⋄ u ← N_FIB ↑ x ⋄ v ← N_FIB ↓ x ⋄ √ (u⋆2) + (v⋆2) }
ExtractPhases ← { x ← 𝕩 ⋄ u ← N_FIB ↑ x ⋄ v ← N_FIB ↓ x ⋄ (-v) ⋆ u }
ExtractParamsProd ← {
  A ← 𝕨 ⋄ b ← 𝕩
  x‿cond ← A SafeSolveLS b
  amps ← ExtractAmplitudes x
  phases ← ExtractPhases x
  relRes ← A RelativeResidual b
  ⟨amps, phases, relRes, cond, x⟩
}

# --- Zero-crossing extended ---
ZeroCrossingIndices ← { zc ← ZeroCrossings 𝕩 ⋄ / zc }
NodeSpacings ← { idx ← ZeroCrossingIndices 𝕩 ⋄ 1 ↓ idx - » idx }
MeanNodeSpacing ← { sp ← NodeSpacings 𝕩 ⋄ (+/sp) ÷ 1⌈≠sp }
SpacingRatiosVsPhi ← { sp ← NodeSpacings 𝕩 ⋄ sp ÷ PHI }

# --- Sliding / windowed fits ---
SlidingFit ← {
  sig ← 𝕨 ⋄ win ← 𝕩
  n ← ≠sig ⋄ starts ← ↕(1⌈n-win+1)
  {
    s ← 𝕩 ⋄ chunk ← win ↑ s ↓ sig
    t ← ↕ win
    A ← BuildDesignMatrixProd t
    ExtractParamsProd A‿chunk
  } ¨ starts
}

# --- Energy capture ---
EnergyCapture ← {
  amps ← 𝕩
  total ← +/ amps⋆2
  frac ← (amps⋆2) ÷ 1⌈total
  ⟨total, frac⟩
}

# --- Batch / multi-channel ---
ProcessChannel ← { sig ← 𝕨 ⋄ t ← 𝕩 ⋄ A ← BuildDesignMatrixProd t ⋄ ExtractParamsProd A‿sig }
ProcessBatch ← { signals ← 𝕨 ⋄ t ← 𝕩 ⋄ {𝕩 ProcessChannel t} ¨ signals }
AggregateAmplitudes ← { results ← 𝕩 ⋄ > {⊑ 𝕩} ¨ results }

# --- Diagnose ---
DiagnoseFit ← {
  amps‿phases‿relRes‿cond‿x ← 𝕩
  status ← ClassifyResidual relRes
  energy‿frac ← EnergyCapture amps
  ⟨status, relRes, cond, energy, frac, amps, phases⟩
}

# --- Config ---
DefaultConfig ← {
  phi ⇐ PHI ⋄ fib ⇐ F_FIB ⋄ carrier ⇐ CARRIER_HZ
  residualWarn ⇐ RESIDUAL_WARN ⋄ residualFail ⇐ RESIDUAL_FAIL ⋄ maxDensity ⇐ MAX_DENSITY
}
WithResidualThresholds ← {
  cfg ← 𝕨 ⋄ warn‿fail ← 𝕩
  cfg ⇐ residualWarn ⇐ warn ⋄ cfg ⇐ residualFail ⇐ fail ⋄ cfg
}

FormatParams ← {
  amps‿phases‿relRes‿cond‿x ← 𝕩
  ∾⟨ "amps=", •Repr amps, " phases=", •Repr phases, " relRes=", •Repr relRes, " status=", ClassifyResidual relRes ⟩
}
ReportChannel ← { label ← 𝕨 ⋄ result ← 𝕩 ⋄ ∾⟨ label, ": ", FormatParams result ⟩ }

RunFibonacciFit ← {
  sig ← 𝕨 ⋄ t ← 𝕩
  {
    ¬ ValidateInputs ⟨sig, t⟩ ? ⟨"INVALID_INPUT", @, @, @, @⟩ ;
    A ← BuildDesignMatrixProd t ⋄ ExtractParamsProd A‿sig
  }
}
RunWithConfig ← { cfg ← 𝕨 ⋄ sig‿t ← 𝕩 ⋄ sig RunFibonacciFit t }
RunAndDiagnose ← {
  sig ← 𝕨 ⋄ t ← 𝕩
  result ← sig RunFibonacciFit t
  { "INVALID_INPUT" ≡ ⊑result ? result ; DiagnoseFit result }
}

# --- Self-test scaffolding ---
SyntheticTone ← { f ← 𝕨 ⋄ t ← 𝕩 ⋄ sin 2 × π × f × t }
SyntheticMix ← { t ← 𝕩 ⋄ +˝ > {SyntheticTone 𝕩‿t} ¨ F_FIB }
SelfTestDesignMatrix ← { t ← ↕ 128 ⋄ A ← BuildDesignMatrixProd t ⋄ ⟨≠A, 1⊑≢A, N_COLS⟩ }
SelfTestResidualZero ← { t ← ↕ 64 ⋄ sig ← SyntheticMix t ⋄ A ← BuildDesignMatrixProd t ⋄ A RelativeResidual sig }

# Primary API: RunFibonacciFit, RunAndDiagnose, ExtractParamsProd, SlidingFit, ProcessBatch
# Source-preserved: ZeroCrossings, GetNodeSpacingRatios, BuildDesignMatrix, SolveLeastSquares,
#   ExtractFibonacciParams, CheckResiduals
# End of fibonacci-parameters.bqn (expanded)
