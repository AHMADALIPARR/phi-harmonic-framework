-- Copyright (C) 2026 AHMAD ALI PARR
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

module ManifoldCollapse where

data Binary : Set where
  zero : Binary
  one  : Binary

pinch : Binary → Binary → Binary
pinch zero zero = zero
pinch _ _     = one

data Manifold (A : Set) : Set where
  Node   : A → Manifold A
  Branch : Manifold A → Manifold A → Manifold A

foldManifold : {A B : Set} → (A → B → B) → B → Manifold A → B
foldManifold f acc (Node x)      = f x acc
foldManifold f acc (Branch l r)  = foldManifold f (foldManifold f acc l) r

survivesSimulation : Manifold Binary → Binary
survivesSimulation m = foldManifold pinch one m
