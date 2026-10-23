# Complete BQN Module: Carrier Demodulation & Fibonacci Amplitude/Phase Least-Squares Fit
# Source-preserved; execution not asserted
PHI ← 1.618033988749895
F_FIB ← 4 7 11 18 29 47
ZeroCrossings ← { (1 ⊸ ⌽ ≠ ⊢) × 𝕩 }
GetNodeSpacingRatios ← { zc ← ZeroCrossings 𝕩 ⋄ (1 ⌽ ⊢) ÷ ⊢ ⊸ (-) ⟜ zc }
BuildDesignMatrix ← {
  t ← 𝕩
  c ← { 2 × π × 𝕩 × t } ∘ p 𝕩
  cos_cols ← cos c
  sin_cols ← sin c
  cos_cols ∾ sin_cols
}
SolveLeastSquares ← {
  A ← 𝕨
  b ← 𝕩
  At ← ⍉ A
  inv ← {⌹ 𝕩} (At +.× A)
  inv +.× (At +.× b)
}
ExtractFibonacciParams ← {
  x ← 𝕨 SolveLeastSquares 𝕩
  u ← 6 uparrow x
  v ← 6 downarrow x
  a ← √ (u⋆2) + (v⋆2)
  theta ← (-v) ⁕ u
  a ∾ theta
}
CheckResiduals ← {
  predicted ← 𝕩
  actual ← 𝕨
  res ← actual - predicted
  (+/ res⋆2) ÷ (+/ actual⋆2)
}
