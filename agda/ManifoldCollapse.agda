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
