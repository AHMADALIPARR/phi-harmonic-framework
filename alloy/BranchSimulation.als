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

// ============================================================================
// BranchSimulation.als
// Production φ-Harmonic Alloy Relational Model
//
// Source-preserved core: State, Branch, StableInvariant,
// BranchSimulationSurvival. Extended with reachability helpers,
// multi-branch traces, density/wavelength bounds, transition
// well-formedness, and verification commands.
//
// Status: Specification scaffold with production structure.
// No empirical verification is asserted by this model alone.
// ============================================================================

sig State {
  label: lone Int
}

sig Branch {
  transitions: set Branch,
  manifoldDensity: Int,
  wavelength: Int,
  carrierHz: lone Int,
  sidebandMask: set Int,
  alive: one BoolFlag,
  parent: lone Branch
}

abstract sig BoolFlag {}
one sig True, False extends BoolFlag {}

one sig FibSidebands {
  values: set Int
} {
  values = 4 + 7 + 11 + 18 + 29 + 47
}

pred StableInvariant (b: Branch) {
  b.wavelength > 0
  b.manifoldDensity >= 0
  b.manifoldDensity < 64
}

pred StrictStableInvariant (b: Branch) {
  StableInvariant[b]
  b.alive = True
  some b.carrierHz implies (b.carrierHz >= 46 and b.carrierHz <= 48)
}

pred DensityInRange (b: Branch) {
  b.manifoldDensity >= 0
  b.manifoldDensity < 64
}

pred WavelengthPositive (b: Branch) {
  b.wavelength > 0
}

pred CarrierNearPhi (b: Branch) {
  some b.carrierHz
  b.carrierHz >= 46
  b.carrierHz <= 48
}

pred successor (a, b: Branch) {
  b in a.transitions
}

fun reachableFrom [b: Branch] : set Branch {
  b.*transitions
}

pred reachable (src, dst: Branch) {
  dst in reachableFrom[src]
}

pred mutuallyReachable (a, b: Branch) {
  reachable[a, b] and reachable[b, a]
}

pred acyclic (b: Branch) {
  b not in b.^transitions
}

pred hasCycle (b: Branch) {
  b in b.^transitions
}

pred TransitionWF (b: Branch) {
  (b in b.transitions) implies b.manifoldDensity = 0
  all s: b.transitions | DensityInRange[s] and WavelengthPositive[s]
}

pred GlobalTransitionWF {
  all b: Branch | TransitionWF[b]
}

pred ParentConsistent (b: Branch) {
  some b.parent implies b in b.parent.transitions
}

pred ValidSidebandMask (b: Branch) {
  b.sidebandMask in FibSidebands.values
}

pred HasMinimumSidebands (b: Branch) {
  #b.sidebandMask >= 3
}

pred PhiHarmonicBranch (b: Branch) {
  CarrierNearPhi[b]
  HasMinimumSidebands[b]
  StableInvariant[b]
}

pred Survives (b: Branch) {
  b.alive = True
  StableInvariant[b]
}

pred Collapsed (b: Branch) {
  b.alive = False
  b.manifoldDensity = 0
}

pred SimulationStep (pre, post: Branch) {
  post.manifoldDensity <= pre.manifoldDensity
  post.wavelength > 0
  (pre.alive = False) implies (post.alive = False)
}

pred MultiStepSimulation (trace: seq Branch) {
  all i: trace.inds - trace.lastIdx |
    SimulationStep[trace[i], trace[i.add[1]]]
}

assert BranchSimulationSurvival {
  all b: Branch | reachable[b, b] implies StableInvariant[b]
}

assert StrictBranchSurvival {
  all b: Branch |
    (b.alive = True and some b.transitions) implies StrictStableInvariant[b]
}

assert NoNegativeDensity {
  all b: Branch | b.manifoldDensity >= 0
}

assert WavelengthAlwaysPositive {
  all b: Branch | b.wavelength > 0
}

assert SidebandsSubsetOfFib {
  all b: Branch | b.sidebandMask in FibSidebands.values
}

assert AcyclicWhenAlive {
  all b: Branch | (b.alive = True) implies acyclic[b]
}

assert DensityBoundedBy64 {
  all b: Branch | b.manifoldDensity < 64
}

fact DensityNonNegative {
  all b: Branch | b.manifoldDensity >= 0
}

fact WavelengthAtLeastOne {
  all b: Branch | b.wavelength >= 1
}

fact TransitionsPointToBranches {
  all b: Branch | b.transitions in Branch
}

fact ParentChildAgreement {
  all b: Branch | ParentConsistent[b]
}

fact BranchBudget {
  #Branch <= 12
}

pred EmptyWorld {
  no Branch
}

pred SingleStableBranch {
  one Branch
  all b: Branch | StableInvariant[b] and b.alive = True
}

pred TwoBranchChain {
  #Branch = 2
  some disj a, b: Branch |
    a.transitions = b and no b.transitions
    and StableInvariant[a] and StableInvariant[b]
}

pred CyclicDanger {
  some b: Branch | hasCycle[b]
}

pred PhiHarmonicSystem {
  some b: Branch | PhiHarmonicBranch[b]
  all b: Branch | ValidSidebandMask[b]
}

pred HighDensityWarning {
  some b: Branch | b.manifoldDensity >= 60 and b.manifoldDensity < 64
}

check BranchSimulationSurvival for 6 but exactly 5 Branch, 5 Int
check StrictBranchSurvival for 8 but 6 Branch, 8 Int
check NoNegativeDensity for 8
check WavelengthAlwaysPositive for 8
check SidebandsSubsetOfFib for 6
check AcyclicWhenAlive for 8 but 6 Branch
check DensityBoundedBy64 for 8

run EmptyWorld for 3
run SingleStableBranch for 4
run TwoBranchChain for 5
run PhiHarmonicSystem for 6 but 4 Branch, 8 Int
run HighDensityWarning for 5
run CyclicDanger for 6 but 4 Branch

pred ImpossibleDensity {
  some b: Branch | b.manifoldDensity < 0
}
run ImpossibleDensity for 5 expect 0

sig Trace {
  steps: seq Branch
}

pred ValidTrace (t: Trace) {
  #t.steps >= 1
  MultiStepSimulation[t.steps]
  all b: elems[t.steps] | StableInvariant[b]
}

pred TraceEndsCollapsed (t: Trace) {
  ValidTrace[t]
  Collapsed[t.steps.last]
}

pred TracePreservesPhi (t: Trace) {
  ValidTrace[t]
  all b: elems[t.steps] | PhiHarmonicBranch[b]
}

run ValidTrace for 5 but 3 Branch, 3 Trace, 4 seq
run TraceEndsCollapsed for 5 but 3 Branch, 2 Trace, 4 seq

fun densityOf [b: Branch] : Int {
  b.manifoldDensity
}

fun wavelengthOf [b: Branch] : Int {
  b.wavelength
}

fun liveBranches : set Branch {
  { b: Branch | b.alive = True }
}

fun collapsedBranches : set Branch {
  { b: Branch | Collapsed[b] }
}

fun phiHarmonicBranches : set Branch {
  { b: Branch | PhiHarmonicBranch[b] }
}

// Integration: Agda survivesSimulation ↔ Survives/Collapsed
// BQN residuals ↔ StableInvariant bounds
// Datalog phi_harmonic_system ↔ PhiHarmonicBranch
// End of BranchSimulation.als
