# Part 2: resolution by hand

Notation: L = LocatedIn. Variables: x, y, z, m, c, d₁, d₂. Constant: a. Function symbols: f, g, h.

## Exercise 1: clausal forms (Q2.1)

Method: (1) remove → using A → B ≡ ¬A ∨ B; (2) Skolemise each ∃; (3) drop the ∀; (4) distribute ∨ over ∧ and split the conjunction into clauses.

### (E2) Every massif contains at least one summit higher than 2 400 m

    ∀m (Massif(m) → ∃s (Summit(s) ∧ InMassif(s,m) ∧ High(s)))

1. Remove →:

       ∀m (¬Massif(m) ∨ ∃s (Summit(s) ∧ InMassif(s,m) ∧ High(s)))

2. Skolemise: ∃s is inside ∀m, so s depends on m. Replace s with a new function symbol f(m) ("the high summit of massif m"):

       ∀m (¬Massif(m) ∨ (Summit(f(m)) ∧ InMassif(f(m),m) ∧ High(f(m))))

3. Drop ∀m.

4. Distribute ¬A ∨ (B ∧ C ∧ D) ≡ (¬A ∨ B) ∧ (¬A ∨ C) ∧ (¬A ∨ D):

       (¬Massif(m) ∨ Summit(f(m))) ∧ (¬Massif(m) ∨ InMassif(f(m),m)) ∧ (¬Massif(m) ∨ High(f(m)))

**Clausal form of (E2): 3 clauses**

    C1: ¬Massif(m) ∨ Summit(f(m))
    C2: ¬Massif(m) ∨ InMassif(f(m), m)
    C3: ¬Massif(m) ∨ High(f(m))

### (c) A commune lies in at most one department

    ∀c ∀d₁ ∀d₂ (Commune(c) ∧ Department(d₁) ∧ Department(d₂) ∧ L(c,d₁) ∧ L(c,d₂) → d₁ = d₂)

1. Remove →, then De Morgan: ¬(A ∧ B ∧ …) ≡ ¬A ∨ ¬B ∨ …

       ∀c ∀d₁ ∀d₂ (¬Commune(c) ∨ ¬Department(d₁) ∨ ¬Department(d₂) ∨ ¬L(c,d₁) ∨ ¬L(c,d₂) ∨ d₁ = d₂)

2. No ∃: nothing to Skolemise.

3. Drop the ∀. The formula is already a single disjunction.

**Clausal form of (c): 1 clause**

    C4: ¬Commune(c) ∨ ¬Department(d₁) ∨ ¬Department(d₂) ∨ ¬L(c,d₁) ∨ ¬L(c,d₂) ∨ d₁ = d₂

## Exercise 2: unification (Q2.2)

Method: compare the two atoms argument by argument, solve each equation, and apply each substitution found to the remaining equations. A variable cannot be bound to a term that contains it (occurs check).

### Pair 1: Neighbour(x, g(a)) and Neighbour(h(z), g(z))

Same predicate, same arity. Equations: { x = h(z), g(a) = g(z) }

| Step | Equation | Action | Substitution so far |
|---|---|---|---|
| 1 | x = h(z) | bind x | { x ↦ h(z) } |
| 2 | g(a) = g(z) | same symbol g → decompose: a = z | |
| 3 | z = a | bind z, apply to x | { x ↦ h(a), z ↦ a } |

Check: both atoms become **Neighbour(h(a), g(a))**.

**Result: unifiable, mgu σ = { x ↦ h(a), z ↦ a }.**

### Pair 2: LocatedIn(f(x), y) and LocatedIn(f(a), g(y))

Same predicate, same arity. Equations: { f(x) = f(a), y = g(y) }

| Step | Equation | Action | Substitution so far |
|---|---|---|---|
| 1 | f(x) = f(a) | same symbol f → decompose: x = a | { x ↦ a } |
| 2 | y = g(y) | y occurs in g(y) → **occurs check fails** | **failure** |

No term can equal itself wrapped inside g: y = g(y) = g(g(y)) = … never ends.

**Result: not unifiable (occurs check on y = g(y)).**

## Exercise 3: proof by refutation

Goal: the summit **arête de Tricot** lies in the region **Auvergne-Rhône-Alpes**.

Abbreviations: atr = arete_de_tricot, sg = saint_gervais_les_bains, hs = haute_savoie, ara = auvergne_rhone_alpes, L = LocatedIn.

Chain in the data (small instance): `located_in(arete_de_tricot, saint_gervais_les_bains)`, `located_in(saint_gervais_les_bains, haute_savoie)`, `located_in(haute_savoie, auvergne_rhone_alpes)`.

Method: add the negation of the goal to the useful clauses, then resolve until the empty clause □ appears. Variables are renamed apart each time the transitivity clause is reused.

### Useful clauses

| # | Clause | Origin |
|---|---|---|
| 1 | L(atr, sg) | fact |
| 2 | L(sg, hs) | fact |
| 3 | L(hs, ara) | fact |
| 4 | ¬L(x, y) ∨ ¬L(y, z) ∨ L(x, z) | axiom (a), transitivity |
| 5 | ¬L(atr, ara) | negation of the goal |

### Resolution steps

| Step | Resolved clauses | Unifier | Resolvent |
|---|---|---|---|
| 6 | 5 and 4 (on L(x,z)) | {x ↦ atr, z ↦ ara} | ¬L(atr, y) ∨ ¬L(y, ara) |
| 7 | 6 and 1 (on L(atr,y)) | {y ↦ sg} | ¬L(sg, ara) |
| 8 | 7 and 4′ = ¬L(x′,y′) ∨ ¬L(y′,z′) ∨ L(x′,z′) (on L(x′,z′)) | {x′ ↦ sg, z′ ↦ ara} | ¬L(sg, y′) ∨ ¬L(y′, ara) |
| 9 | 8 and 2 (on L(sg,y′)) | {y′ ↦ hs} | ¬L(hs, ara) |
| 10 | 9 and 3 | {} | **□** |

The empty clause is derived, so {1, 2, 3, 4} ∪ {¬L(atr, ara)} is unsatisfiable. Hence **L(arete_de_tricot, auvergne_rhone_alpes)** is a logical consequence of the facts and transitivity.
