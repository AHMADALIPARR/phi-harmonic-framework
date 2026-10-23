# Datalog modules — φ-Harmonic spectral stack

Raw Datalog modules for carrier / sideband / confidence analysis.

## Load order

| # | File | Role |
|---|------|------|
| 0 | [`00-facts.dl`](00-facts.dl) | Peaks, fib offsets, atomic keys, thresholds |
| 1 | [`01-carrier.dl`](01-carrier.dl) | Carrier candidates (strict / soft / per-channel) |
| 2 | [`02-sidebands.dl`](02-sidebands.dl) | Upper/lower sidebands, triplets |
| 3 | [`03-phi-system.dl`](03-phi-system.dl) | φ-harmonic system + confidence tiers |
| 4 | [`04-atomic-export.dl`](04-atomic-export.dl) | Atomic keys + export views for hosts |
| 5 | [`05-integrity.dl`](05-integrity.dl) | Consensus, integrity, peak classes |
| ★ | [`spectral-rules.dl`](spectral-rules.dl) | Unified compatibility module (all-in-one) |

## Notes

- Source-preserved predicates: `observed_peak/2`, `fib_freq/1`, `candidate_carrier/1`, `sideband_triplet/3`, `phi_harmonic_system/2`.
- Arithmetic (`is/2`, `>=`, `findall`) assumes a Prolog-compatible engine; pure Datalog hosts should materialise range/count facts.
- Do not claim verification unless the engine has been run and results recorded.
- AGPL-3.0 — see repository `LICENSE`.
