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
