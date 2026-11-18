# Part 1: first-order logic

## 1. Axioms
- (a) Transitivity of LocatedIn:
- (a) ∀x∀y∀z (LocatedIn(x,y) ∧ LocatedIn(y,z) → LocatedIn(x,z))

- (b) Symmetry of Neighbour:
- (b) ∀x∀y (Neighbour(x,y) → Neighbour(y,x))

- (c) A commune lies in at most one department:
- (c) ∀c∀d₁∀d₂ (Commune(c) ∧ Department(d₁) ∧ Department(d₂) ∧ LocatedIn(c,d₁) ∧ LocatedIn(c,d₂) → d₁ = d₂)

- (d) Every summit lies in at least one commune:
- (d) ∀s (Summit(s) → ∃c (Commune(c) ∧ LocatedIn(s,c)))

## 2. Formalisations
- (E1): ∀c (Commune(c) → ∃d (Department(d) ∧ LocatedIn(c,d)))
- (E2): ∀m (Massif(m) → ∃s (Summit(s) ∧ InMassif(s,m) ∧ High(s)))
- (E3): ∃c∃c’ (Commune(c) ∧ ¬∃r (Resort(r) ∧ LocatedIn(r,c)) ∧ Commune(c’) ∧ ∃r’ (Resort(r’) ∧ LocatedIn(r’,c’)) ∧ Neighbour(c,c’))
- (E4): ¬∃r∃c (Resort(r) ∧ Commune(c) ∧ LocatedIn(r,c) ∧ ¬∃d (Department(d) ∧ LocatedIn(c,d)))

## 3. Models of {transitivity, I, S}
(Show that every model is infinite; give an infinite model; does the instance satisfy S?)

Every model of {T, I, S} is infinite. Take any a₀. By (S) we get a chain a₀, a₁, a₂, … with LocatedIn(aᵢ, aᵢ₊₁). By (T), LocatedIn(aᵢ, aⱼ) for all i < j. If aᵢ = aⱼ with i < j, then LocatedIn(aᵢ, aᵢ), contradicting (I). So all aᵢ are distinct and the domain is infinite.

Infinite model: domain ℕ, LocatedIn(x,y) ⇔ x < y.

The instance does not satisfy (S): auvergne_rhone_alpes (and every massif) has no located_in fact, so ∃y LocatedIn(auvergne_rhone_alpes, y) is false. This is expected: the instance is finite, and no finite model can satisfy {T, I, S}.
