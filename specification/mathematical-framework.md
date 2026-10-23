<!--
Copyright (C) 2026 AHMAD ALI PARR

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
-->

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
