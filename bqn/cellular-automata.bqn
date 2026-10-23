# Complete BQN Module: Recursive Invariant Extraction from Cellular Automata Payload
# Source-preserved; execution not asserted
PHI ← 1.618033988749895
ATOMIC_KEYS ← 1 6 7 8
F_FIB ← 4 7 11 18 29 47
EvolveCAState ← {
  neighbor_sum ← (1 ⌽ + ¯1 ⌽ ⊢) 𝕩
  rule_mask ← (neighbor_sum = 3) or (𝕩 and (neighbor_sum = 2))
  rule_mask
}
BuildCAResponseMatrix ← {
  ca_trajectory ← 𝕩
  t ← ÷ 𝕉 ↕ ≢ ca_trajectory
  c ← { 2 × π × 𝕩 × t } ∘ p F_FIB
  cos_cols ← cos c
  sin_cols ← sin c
  cos_cols ∾ sin_cols
}
ExtractRecursiveInvariant ← {
  A ← 𝕨 BuildCAResponseMatrix 𝕩
  At ← ⍉ A
  inv ← {⌹ 𝕩} (At +.× A)
  x_star ← inv +.× (At +.× 𝕩)
  predicted ← A +.× x_star
  residual ← 𝕩 - predicted
  invariant ← (+/ residual⋆2) ÷ (+/ 𝕩⋆2)
  invariant
}
