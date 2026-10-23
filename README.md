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

# φ-Harmonic Resonance Specification & Inverse Engineering Framework

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Status: Scaffold](https://img.shields.io/badge/status-specification%20scaffold-blue)](https://github.com/AHMADALIPARR/phi-harmonic-framework)
[![BQN](https://img.shields.io/badge/BQN-inverse%20routines-orange)](https://mlochbaum.github.io/BQN/)
[![Agda](https://img.shields.io/badge/Agda-manifold%20collapse-green)](https://agda.readthedocs.io/)
[![Alloy](https://img.shields.io/badge/Alloy-branch%20simulation-purple)](https://alloytools.org/)
[![Datalog](https://img.shields.io/badge/Datalog-spectral%20rules-red)](https://en.wikipedia.org/wiki/Datalog)

Source-preserving framework for the supplied φ-harmonic black-box model, BQN inverse routines, Datalog spectral grep, cellular automata invariant extraction, Alloy branch checking, Agda manifold collapse, and recursive last-token replay.

## Status

**Specification scaffold; not an executed or certified solver.**  
Source blocks are retained as supplied, including placeholders and dialect-specific syntax.  
No empirical result, proof execution, or model validation is asserted.

## Repository Layout

```
phi-harmonic-framework/
├── README.md
├── LICENSE
├── agda/
│   └── ManifoldCollapse.agda          # Manifold collapse type theory
├── alloy/
│   └── BranchSimulation.als           # Branch survival invariant model
├── bqn/
│   ├── cellular-automata.bqn          # Recursive CA invariant extraction
│   ├── fibonacci-parameters.bqn        # Carrier demodulation & LS fit
│   └── inverse-solver.bqn             # Inverse spectral solver
├── datalog/
│   └── spectral-rules.dl              # Spectral grep / sideband rules
├── payload/
│   └── atomic-keys.dat                # Atomic keys {1,6,7,8}
├── replay/
│   └── last-token-replay.md           # Exact last-token replay discipline
├── specification/
│   ├── execution-contract.md          # Non-negotiable execution rules
│   └── mathematical-framework.md      # Source-preserved equations
└── tests/
    ├── cellular/
    ├── inverse/
    ├── replay/
    ├── spectral/
    └── verification/
```

## Execution Order

1. Read `specification/mathematical-framework.md`.
2. Evaluate the original BQN routines in `bqn/` using an explicitly chosen BQN runtime.
3. Evaluate `datalog/spectral-rules.dl` in a compatible logic engine.
4. Supply actual cellular automata frames and atomic keys to `bqn/cellular-automata.bqn`.
5. Evaluate `alloy/BranchSimulation.als` and type-check `agda/ManifoldCollapse.agda`.
6. Follow `replay/last-token-replay.md` for the requested last-token recursive replay, without changing the mathematical model.

## Key Constants (source-preserved)

| Symbol | Value | Meaning |
|--------|-------|---------|
| φ      | 1.618033988749895 | Golden ratio |
| f_c    | ≈ 46.9787 Hz | Carrier frequency |
| F_FIB  | {4, 7, 11, 18, 29, 47} Hz | Fibonacci sidebands |
| Atomic keys | {1, 6, 7, 8} | H, C, N, O |

## Disclaimer

No sample payload is presented as a real ExoMars or Chaffin dataset.  
This repository intentionally preserves the original source material without substitution, inference, or claimed verification.

## License

This project is licensed under the **GNU Affero General Public License v3.0** (AGPL-3.0).

You can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the [LICENSE](LICENSE) file for the full text.

**Important AGPL notice:** If you run a modified version of this software on a network server and allow others to interact with it, you must also make the corresponding source code available to those users (see section 13 of the AGPL).
