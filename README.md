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

<div align="center">

# φ · Harmonic Resonance Framework

### Inverse Engineering · Spectral Geometry · Source-Preserved Specification

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Status](https://img.shields.io/badge/status-specification%20scaffold-0a0a0a)](https://github.com/AHMADALIPARR/phi-harmonic-framework)
[![BQN ★](https://img.shields.io/badge/★_BQN-star%20of%20the%20repo-ff6b00)](https://mlochbaum.github.io/BQN/)
[![Agda](https://img.shields.io/badge/Agda-manifold-2ecc71)](https://agda.readthedocs.io/)
[![Alloy](https://img.shields.io/badge/Alloy-branches-9b59b6)](https://alloytools.org/)
[![Datalog](https://img.shields.io/badge/Datalog-spectral-e74c3c)](https://en.wikipedia.org/wiki/Datalog)

**Carrier ≈ 46.9787 Hz · Sidebands {4, 7, 11, 18, 29, 47} · φ = 1.618033988749895**

<br/>

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Golden_vs_Fibonacci_Spiral.svg/960px-Golden_vs_Fibonacci_Spiral.svg.png" alt="Golden ratio vs Fibonacci spiral" width="720"/>

*Golden spiral (blue) vs Fibonacci approximation (dashed) — the geometric signature behind the φ-harmonic model.*

</div>

---

## ★ BQN is the Star

This repository is built around **BQN** — the array language that carries the inverse engineering core.

| Module | Role | Guide |
|--------|------|-------|
| **[`bqn/array-core.bqn`](bqn/array-core.bqn)** | Shared foundation: rank, φ-geometry, spectral banks, least-squares | [Read the core →](bqn/array-core.bqn) |
| **[`bqn/fibonacci-parameters.bqn`](bqn/fibonacci-parameters.bqn)** | Carrier demodulation & Fibonacci amplitude/phase least-squares fit | [Read the fit pipeline →](bqn/fibonacci-parameters.bqn) |
| **[`bqn/inverse-solver.bqn`](bqn/inverse-solver.bqn)** | Field inverse: spectrum isolation, residual maps, spatial coherence | [Read the inverse solver →](bqn/inverse-solver.bqn) |
| **[`bqn/cellular-automata.bqn`](bqn/cellular-automata.bqn)** | Recursive invariant extraction from CA trajectories + atomic-key masking | [Read the CA engine →](bqn/cellular-automata.bqn) |

```bqn
PHI ← 1.618033988749895
F_FIB ← 4 7 11 18 29 47
CARRIER_HZ ← 46.9787
```

Run with any BQN runtime that supports the dialect used in the modules.  
See the [BQN language site](https://mlochbaum.github.io/BQN/) for installation and tutorials.

<div align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/FibonacciSpiral.svg/960px-FibonacciSpiral.svg.png" alt="Fibonacci spiral tiled squares" width="640"/>
<p><em>Fibonacci tiled squares — the discrete geometric array underlying sideband design.</em></p>
</div>

---

## Geometric Arrays & φ Signature

The mathematical framework treats space and spectrum through φ-scaled geometry:

| Symbol | Value | Meaning |
|--------|-------|---------|
| **φ** | 1.618033988749895 | Golden ratio |
| **f<sub>c</sub>** | ≈ 46.9787 Hz | Carrier frequency |
| **F<sub>FIB</sub>** | {4, 7, 11, 18, 29, 47} Hz | Fibonacci sidebands |
| **Atomic keys** | {1, 6, 7, 8} | H, C, N, O |

<div align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Golden_ratio_line2.svg/800px-Golden_ratio_line2.svg.png" alt="Golden ratio line segments a : b = (a+b) : a" width="560"/>
<p><em>φ definition: a/b = (a+b)/a</em></p>
</div>

Full equation set and recovery procedure:  
**[specification/mathematical-framework.md](specification/mathematical-framework.md)**

Execution rules (what must not be changed):  
**[specification/execution-contract.md](specification/execution-contract.md)**

---

## Repository Guides

### Core specification
- [Mathematical Framework](specification/mathematical-framework.md) — wavenumber, Wick rotation, design matrix, residual
- [Execution Contract](specification/execution-contract.md) — non-negotiable preservation rules

### BQN inverse stack (★ primary)
- [Array Core](bqn/array-core.bqn) — shared foundation
- [Fibonacci Parameters](bqn/fibonacci-parameters.bqn) — demodulation & LS fit
- [Inverse Solver](bqn/inverse-solver.bqn) — field → residual / carrier pipeline
- [Cellular Automata](bqn/cellular-automata.bqn) — trajectory invariants & atomic keys

### Formal companions
- [Agda — Manifold Collapse](agda/ManifoldCollapse.agda) — survival, density, wavelength invariants
- [Alloy — Branch Simulation](alloy/BranchSimulation.als) — reachable branches & stable invariants
- [Datalog — Spectral Rules](datalog/spectral-rules.dl) — carrier / sideband grep & confidence tiers

### Discipline & payload
- [Last-Token Replay](replay/last-token-replay.md) — exact state-transition replay
- [Atomic Keys Payload](payload/atomic-keys.dat) — `{1 6 7 8}`

### Tests (scaffolding)
- [`tests/spectral/`](tests/spectral/) · [`tests/inverse/`](tests/inverse/) · [`tests/cellular/`](tests/cellular/)  
- [`tests/verification/`](tests/verification/) · [`tests/replay/`](tests/replay/)

---

## Execution Order

1. Read the **[mathematical framework](specification/mathematical-framework.md)**.
2. Evaluate the **BQN** routines in [`bqn/`](bqn/) with an explicit BQN runtime. ★
3. Evaluate [`datalog/spectral-rules.dl`](datalog/spectral-rules.dl) in a compatible logic engine.
4. Supply CA frames + atomic keys to [`bqn/cellular-automata.bqn`](bqn/cellular-automata.bqn).
5. Check [`alloy/BranchSimulation.als`](alloy/BranchSimulation.als) and type-check [`agda/ManifoldCollapse.agda`](agda/ManifoldCollapse.agda).
6. Follow [`replay/last-token-replay.md`](replay/last-token-replay.md) for exact last-token recursive replay.

---

## Status

**Specification scaffold — not an executed or certified solver.**

Source blocks are retained as supplied (including placeholders and dialect-specific syntax).  
No empirical result, proof execution, or model validation is asserted by this repository alone.

No sample payload is presented as a real ExoMars or Chaffin dataset.  
The material is source-preserved without substitution or inferred molecular rules.

---

## License

**GNU Affero General Public License v3.0** — see [LICENSE](LICENSE).

If you run a modified version on a network server and allow others to interact with it, you must also make the corresponding source available (AGPL §13).

---

<div align="center">

**φ-Harmonic Resonance Framework**  
*BQN at the center · Geometry as constraint · Source as law*

[Repository](https://github.com/AHMADALIPARR/phi-harmonic-framework) · [BQN Language](https://mlochbaum.github.io/BQN/) · [AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0)

</div>
