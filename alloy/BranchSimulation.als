// Copyright (C) 2026 AHMAD ALI PARR
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Alloy Relational Model — source-preserved
sig State {}
sig Branch {
    transitions: set Branch,
    manifoldDensity: Int,
    wavelength: Int
}
pred StableInvariant (b: Branch) {
    b.wavelength > 0
    b.manifoldDensity >= 0
    b.manifoldDensity < 64
}
assert BranchSimulationSurvival {
    all b: Branch | reachable[b, b] implies StableInvariant[b]
}
check BranchSimulationSurvival for 6 but exactly 5 Branch, 5 Int
