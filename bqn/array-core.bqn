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
# ★ Shared BQN Array Foundation for the φ-Harmonic Framework
#
# Rank-polymorphic helpers, φ-scaled geometry, spectral primitives,
# residual algebra, and pipeline combinators used by:
#   fibonacci-parameters.bqn · inverse-solver.bqn · cellular-automata.bqn
#
# Status: Specification scaffold. Execution not asserted.
# ============================================================================

PHI          ← 1.618033988749895
PHI_INV      ← ÷PHI
PHI_SQ       ← PHI⋆2
CARRIER_HZ   ← 46.9787
F_FIB        ← 4 7 11 18 29 47
ATOMIC_KEYS  ← 1 6 7 8
MAX_DENSITY  ← 64
N_FIB        ← ≠F_FIB
N_COLS       ← 2×N_FIB
π            ← 3.141592653589793
τ            ← 2×π
RESIDUAL_WARN← 0.15
RESIDUAL_FAIL← 0.35
SPECTRAL_FLOOR←1e-6

Rank      ← =
Shape     ← ≢
Len       ← ≠
IsScalar  ← 0=Rank
IsVector  ← 1=Rank
IsMatrix  ← 2=Rank
NRows     ← {0⊑≢𝕩}
NCols     ← {1⊑≢𝕩}
EnsureVec ← {IsVector 𝕩 ? 𝕩 ; ⥊𝕩}
Lead      ← {IsScalar 𝕩 ? 1 ; ⊑≢𝕩}
Tally     ← ×´≢

Sum       ← +´
Prod      ← ×´
Mean      ← {(+´𝕩)÷1⌈≠𝕩}
Variance  ← {m←Mean 𝕩 ⋄ Mean (𝕩-m)⋆2}
StdDev    ← √Variance
RMS       ← {√Mean 𝕩⋆2}
Norm2     ← √(+´⋆2)
NormInf   ← ⌈´|
Normalize ← {n←Norm2 𝕩 ⋄ 𝕩÷1⌈n}
CumSum    ← +`
CumProd   ← ×`
Diffs     ← 1⊸↓-¯1⊸↓

Windows ← { w←𝕨 ⋄ x←𝕩 ⋄ n←≠x ⋄ {𝕩+↕w}¨↕(1+n-w) }
NeighborSum ← {(1⌽𝕩)+(¯1⌽𝕩)}
Box3 ← {(¯1⌽𝕩)+𝕩+(1⌽𝕩)}÷3

Sign ← ×
ZeroCrossings ← { s←Sign 𝕩 ⋄ (1⊸⌽≠⊢)s }
ZeroCrossingIndices ← /∘ZeroCrossings
NodeSpacings ← { idx←ZeroCrossingIndices 𝕩 ⋄ 1↓idx-»idx }
MeanNodeSpacing ← { sp←NodeSpacings 𝕩 ⋄ (+´sp)÷1⌈≠sp }
SpacingRatiosVsPhi ← (NodeSpacings÷PHI)

CosBank ← { F←𝕨 ⋄ t←𝕩 ⋄ >{cos τ×𝕩×t}¨F }
SinBank ← { F←𝕨 ⋄ t←𝕩 ⋄ >{sin τ×𝕩×t}¨F }
DesignMatrix ← { F←𝕨 ⋄ t←𝕩 ⋄ (F CosBank t)∾˘(F SinBank t) }
FibDesign ← F_FIB⊸DesignMatrix

CarrierTone ← { fs←𝕨 ⋄ n←𝕩 ⋄ t←(↕n)÷fs ⋄ sin τ×CARRIER_HZ×t }
SidebandMix ← { fs←𝕨 ⋄ n←𝕩 ⋄ t←(↕n)÷fs ⋄ +˝>{sin τ×𝕩×t}¨F_FIB }
PhiSynth ← { fs←𝕨 ⋄ n←𝕩 ⋄ (1.0×fs CarrierTone n)+0.3×fs SidebandMix n }

SolveLS ← { A←𝕨 ⋄ b←𝕩 ⋄ At←⍉A ⋄ (⌹At+.×A)+.×At+.×b }
Residual ← { A←𝕨 ⋄ b←𝕩 ⋄ x←A SolveLS b ⋄ b-A+.×x }
RelResidual ← { A←𝕨 ⋄ b←𝕩 ⋄ r←A Residual b ⋄ (Norm2 r)÷1⌈Norm2 b }
Amplitudes ← { x←𝕩 ⋄ u←N_FIB↑x ⋄ v←N_FIB↓x ⋄ √(u⋆2)+v⋆2 }
Phases ← { x←𝕩 ⋄ u←N_FIB↑x ⋄ v←N_FIB↓x ⋄ (-v)⋆u }
ClassifyRes ← { r←𝕩 ⋄ r<RESIDUAL_WARN?"OK";r<RESIDUAL_FAIL?"WARN";"FAIL" }

MeanRows ← (+˝÷≠)
Frob ← √(+´⥊⋆2)
FibSeq ← { n←𝕩 ⋄ {𝕩<2?↕𝕩;{𝕨∾(+´¯2↑𝕨)}´(↕n-2)∾<0‿1} }
FibRatios ← { f←FibSeq 𝕩 ⋄ 1↓f÷»f }
PhiPowers ← {PHI⋆↕𝕩}
GoldenAngle ← τ×PHI_INV

SelfTestDesign ← { t←↕128 ⋄ A←FibDesign t ⋄ ⟨NRows A, NCols A, N_COLS⟩ }
SelfTestPhiSynth ← { sig←128 PhiSynth 256 ⋄ A←FibDesign ↕256 ⋄ A RelResidual sig }
SelfTestFibApproach ← { r←FibRatios 16 ⋄ |PHI-¯1⊑r }

# Shared by all BQN modules. End of array-core.bqn
