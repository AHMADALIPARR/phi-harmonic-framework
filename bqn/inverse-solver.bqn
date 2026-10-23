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
# inverse-solver.bqn
# Production BQN Inverse Solver Module
#
# Source-preserved core: ZeroCrossings, GetNodeSpacingRatios,
# AnalyzeSpectrum, CheckResiduals.
# Assumes F is a 2D matrix [Spatial_Points × Time_Steps].
#
# Extended with spectrum peak picking, carrier isolation, residual
# maps, spatial coherence checks, and pipeline orchestration.
# Status: Specification scaffold with production structure.
# ============================================================================

PHI ← 1.618033988749895
CARRIER_HZ ← 46.9787
F_FIB ← 4 7 11 18 29 47
ATOMIC_KEYS ← 1 6 7 8
MAX_DENSITY ← 64
SPECTRAL_FLOOR ← 1e-6
PEAK_PROMINENCE ← 0.2
π ← 3.141592653589793

ZeroCrossings ← { s ← × 𝕩 ⋄ (1 ⊸ ⌽ ≠ ⊢) s }
GetNodeSpacingRatios ← { zc ← ZeroCrossings 𝕩 ⋄ (1 ⌽ ⊢) ÷ ⊢ ⊸ (-) ⟜ zc }
AnalyzeSpectrum ← {
  fft ← +∘(× ⊸ ↕ × ○ -⟜÷ ∘ 𝕩)
  fc_idx ← ⌊ CARRIER_HZ × (≢ 𝕩)
  fc_idx ⊏ fft 𝕩
}
CheckResiduals ← {
  predicted ← 𝕩 ⋄ actual ← 𝕨
  residual ← actual - predicted
  (+/ 𝕩⋆2) ÷ (+/ residual⋆2)
}

SpatialPoints ← { 0 ⊑ ≢ 𝕩 }
TimeSteps ← { 1 ⊑ ≢ 𝕩 }
ValidateField ← { F ← 𝕩 ⋄ (2 = =F) ∧ (0 < SpatialPoints F) ∧ (0 < TimeSteps F) }
MeanOverTime ← { (+˝ ⍉ 𝕩) ÷ TimeSteps 𝕩 }
MeanOverSpace ← { (+˝ 𝕩) ÷ SpatialPoints 𝕩 }

ZeroCrossings2D ← { F ← 𝕩 ⋄ { ZeroCrossings 𝕩 } ˘ F }
NodeSpacingMap ← { F ← 𝕩 ⋄ { GetNodeSpacingRatios 𝕩 } ˘ F }
MeanSpacingPerRow ← { ratios ← NodeSpacingMap 𝕩 ⋄ { (+/𝕩) ÷ 1⌈≠𝕩 } ¨ ratios }

DFTMag ← {
  x ← 𝕩 ⋄ n ← ≠x ⋄ k ← ↕ n
  mags ← {
    kk ← 𝕩
    re ← +/ x × cos 2×π×kk×k÷n
    im ← +/ x × sin 2×π×kk×k÷n
    √ (re⋆2) + (im⋆2)
  } ¨ k
  mags
}
SpectrumPerRow ← { F ← 𝕩 ⋄ { DFTMag 𝕩 } ˘ F }
CarrierBin ← { n ← 𝕩 ⋄ ⌊ CARRIER_HZ × n ÷ 1 }
IsolateCarrier ← {
  F ← 𝕩 ⋄ specs ← SpectrumPerRow F ⋄ n ← TimeSteps F ⋄ cbin ← CarrierBin n
  { cbin ⊑ 𝕩 } ¨ specs
}
PeakBins ← { mag ← 𝕩 ⋄ thr ← PEAK_PROMINENCE × ⌈´ mag ⋄ / mag ≥ thr }
SidebandPresence ← {
  mag ← 𝕩 ⋄ n ← ≠mag ⋄ peaks ← PeakBins mag ⋄ cbin ← CarrierBin n
  expected ← ⥊ {cbin + 𝕩} ¨ (-F_FIB) ∾ F_FIB
  expected ← expected /˜ (expected ≥ 0) ∧ (expected < n)
  ∧´ {∨´ (| peaks - 𝕩) ≤ 1} ¨ expected
}

FieldRelativeResidual ← {
  pred ← 𝕨 ⋄ actual ← 𝕩 ⋄ diff ← actual - pred
  num ← +/⥊ diff⋆2 ⋄ den ← +/⥊ actual⋆2 ⋄ num ÷ 1⌈den
}
ResidualMap ← { pred ← 𝕨 ⋄ actual ← 𝕩 ⋄ actual - pred }
RowResidualEnergy ← { pred ← 𝕨 ⋄ actual ← 𝕩 ⋄ d ← ResidualMap ⟨pred, actual⟩ ⋄ +˝ d⋆2 }

SpatialCoherence ← {
  F ← 𝕩 ⋄ meanTs ← MeanOverSpace F
  {
    r ← 𝕩
    num ← +/ (r - ¨mean r) × (meanTs - ¨mean meanTs)
    den ← (√ +/ (r - ¨mean r)⋆2) × (√ +/ (meanTs - ¨mean meanTs)⋆2)
    num ÷ 1⌈den
  } ˘ F
}
MeanCoherence ← { (+/ SpatialCoherence 𝕩) ÷ SpatialPoints 𝕩 }

InverseStep ← {
  F ← 𝕩
  {
    ¬ ValidateField F ? ⟨"INVALID_FIELD", @, @⟩ ;
    carrierStr ← IsolateCarrier F
    pred ← (SpatialPoints F) / ≍ MeanOverTime F
    relRes ← pred FieldRelativeResidual F
    ⟨"OK", relRes, carrierStr⟩
  }
}
RunInverseSolver ← {
  F ← 𝕩
  status‿relRes‿carrier ← InverseStep F
  coh ← MeanCoherence F
  ⟨status, relRes, carrier, coh⟩
}

DensityProxy ← { energies ← +˝ 𝕩⋆2 ⋄ +/ energies > SPECTRAL_FLOOR }
WavelengthProxy ← {
  ratios ← MeanSpacingPerRow 𝕩 ⋄ meanR ← (+/ratios) ÷ 1⌈≠ratios
  { meanR > 0 ? meanR ; TimeSteps 𝕩 }
}
StableField ← {
  F ← 𝕩 ⋄ d ← DensityProxy F ⋄ w ← WavelengthProxy F
  (d ≥ 0) ∧ (d < MAX_DENSITY) ∧ (w > 0)
}

ProcessFieldBatch ← { fields ← 𝕩 ⋄ { RunInverseSolver 𝕩 } ¨ fields }
AggregateResiduals ← { results ← 𝕩 ⋄ { 1 ⊑ 𝕩 } ¨ results }

DefaultInverseConfig ← {
  carrier ⇐ CARRIER_HZ ⋄ fib ⇐ F_FIB ⋄ peakProminence ⇐ PEAK_PROMINENCE
  spectralFloor ⇐ SPECTRAL_FLOOR ⋄ maxDensity ⇐ MAX_DENSITY
}

FormatInverseResult ← {
  status‿relRes‿carrier‿coh ← 𝕩
  ∾⟨ "status=", status, " relRes=", •Repr relRes, " coherence=", •Repr coh ⟩
}

SyntheticField ← {
  nSpace ← 𝕨 ⋄ nTime ← 𝕩 ⋄ t ← ↕ nTime
  base ← sin 2 × π × CARRIER_HZ × t ÷ nTime
  > { base + 0.1 × sin 2 × π × (4+𝕩) × t ÷ nTime } ¨ ↕ nSpace
}
SelfTestValidate ← { F ← 8 SyntheticField 64 ⋄ ValidateField F }
SelfTestInverse ← { F ← 4 SyntheticField 32 ⋄ RunInverseSolver F }

# Primary API: RunInverseSolver, InverseStep, FieldRelativeResidual, IsolateCarrier
# Source-preserved: ZeroCrossings, GetNodeSpacingRatios, AnalyzeSpectrum, CheckResiduals
# End of inverse-solver.bqn
