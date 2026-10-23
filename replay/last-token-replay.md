# Recursive Last-Token Replay

User-specified execution discipline, kept separate from the original mathematical definitions.

For each step:
1. Read the exact previous terminal token and stored complete state.
2. Replay the recorded transition from that state and terminal token.
3. Compare the replayed next state and terminal token with the recorded values exactly.
4. On mismatch, stop and record failure; do not substitute a statistically similar state.
5. On match, use the resulting last token as input to the next recursive iteration.
6. Stop on explicitly supplied depth limit or detected repeated complete state.

The supplied specification does not define the byte-level token encoder, transition serialization, or replay seed. These remain unspecified rather than guessed. No correlations are introduced.
