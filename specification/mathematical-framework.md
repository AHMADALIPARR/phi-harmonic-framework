# Corrected Mathematical Framework (source-preserved)

- Spatial wavenumber: k = 2π/φ; wavelength: λ = φ. Zero crossings spaced φ/2; identical maxima spaced φ.
- Analytic signal: z(t) = E(t) + i H[E](t).
- Wick rotation: t → −iτ; exp(i(kr − ωφ t)) → exp(ikr − ωφ τ).
- Carrier: fc = ωφ/(2π) ≈ 46.9787 Hz.
- Sidebands: fc ± fj; fj ∈ {4, 7, 11, 18, 29, 47} Hz.
- Quadratures: uj = aj cos θj, vj = −aj sin θj.
- Design matrix: A ∈ R^(N×12), columns cos(2πfj t), sin(2πfj t).
- Least squares: x* = (AᵀA)⁻¹Aᵀb.
- Recovery: aj = sqrt(uj²+vj²), θj = atan2(−vj, uj).
- Recursive projection residual: ||b − Ax*||² / ||b||².
- Atomic keys: {1,6,7,8} (H,C,N,O).

These are the supplied model's definitions and assertions, not independently verified empirical findings.
