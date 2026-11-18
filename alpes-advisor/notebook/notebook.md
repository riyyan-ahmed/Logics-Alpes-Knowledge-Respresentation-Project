# Notebook (one page)

Pair: …   Instance: small

## Numerical answers
| Question | Answer |
|---|---|
| Q1.1 / Q1.2 | |
| Q2.1 – Q2.2 | (E2), Skolem f(m): ¬Massif(m) ∨ Summit(f(m)); ¬Massif(m) ∨ InMassif(f(m),m); ¬Massif(m) ∨ High(f(m)).<br>(c): ¬Commune(c) ∨ ¬Dep(d₁) ∨ ¬Dep(d₂) ∨ ¬L(c,d₁) ∨ ¬L(c,d₂) ∨ d₁=d₂.<br>Unif. 1: mgu {x↦h(a), z↦a}.<br>Unif. 2: impossible, occurs check y = g(y). |
| Q2.3 (resolvent measurements) | n = 10 / 12 / 14, cap 100 000 (✓ = □ found).<br>Provable L(aiguille_croche,ara): naive cap/cap/cap; sos 25 199✓/cap/cap; unit 354✓/470✓/602✓.<br>Refute L(megeve,savoie): naive cap/cap/cap; sos 377✓/589✓/849✓; unit 248✓/346✓/460✓.<br>Not provable L(les_houches,haute_savoie): naive cap; sos cap; unit saturates at 842/1 298/1 818, no □. |
| Q2.4 – Q2.5 | Q2.4: unit best on all goals (facts are units, clauses shrink each step; KB is Horn so unit resolution is complete). SOS good on the 2-step refutation, explodes breadth-first on the 5-step proof. Naive resolves KB×KB first, hits the cap everywhere. Not provable: no □; unit saturates (= proof it is not entailed), naive/sos stop at the cap (inconclusive). Not provable ≠ false (missing data).<br>Q2.5: clauses = F + n(n−1)(n−2) + communes·d(d−1)/2 ≈ n³ (736 / 1 338 / 2 204). Whole small (28): 19 696. Medium (501): ≈ 1.25·10⁸ (~17 GB). Grounding transitivity is cubic, so propositional resolution does not scale; first-order unification / Prolog / ASP needed. |
| Q3.1 | |
| Q3.2 (findall / setof / count) | |
| Q3.3 | |
| Q3.4 (not snowy resorts, resorts without altitude) | |
| Q3.5 | |
| Q4.1 (k = 2 and 3: value, number of stays) | |
| Q4.2 | |
| Q4.3 – Q4.4 (medium: without "distinct communes"; k = 3, time, stays) | |
| Q4.5 (brave / cautious, with an exception) | |
| Q4.6 | |

## Comparison
| | Propositional resolution | Prolog | ASP |
|---|---|---|---|
| Expressiveness | | | |
| Missing information | | | |
| Termination | | | |
| Explainability | | | |

## First-order axioms (list or diagram)
