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
