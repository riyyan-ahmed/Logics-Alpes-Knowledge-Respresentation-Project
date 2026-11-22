# Notebook (one page)

Pair: …   Instance: small

## Numerical answers
| Question | Answer |
|---|---|
| Q1.1 / Q1.2 | Q1.1 (checked in Prolog, LocatedIn = located_in facts): satisfied: (c), (E3) (megeve), (E4). Not satisfied: (a) (aiguille_croche→hauteluce→savoie, no direct fact; holds for inside/2), (b) (combloux→sallanches only), (d) (plateau_des_saix, signal_de_bisanne: no commune), (E1) (les_houches), (E2) (faucigny, giffre: no summit > 2400 m).<br>Q1.2: (E1) is false: commune les_houches has no located_in to a department. |
| Q2.1 – Q2.2 | (E2), Skolem f(m): ¬Massif(m) ∨ Summit(f(m)); ¬Massif(m) ∨ InMassif(f(m),m); ¬Massif(m) ∨ High(f(m)).<br>(c): ¬Commune(c) ∨ ¬Dep(d₁) ∨ ¬Dep(d₂) ∨ ¬L(c,d₁) ∨ ¬L(c,d₂) ∨ d₁=d₂.<br>Unif. 1: mgu {x↦h(a), z↦a}.<br>Unif. 2: impossible, occurs check y = g(y). |
| Q2.3 (resolvent measurements) | n = 10 / 12 / 14, cap 100 000 (✓ = □ found).<br>Provable L(aiguille_croche,ara): naive cap/cap/cap; sos 25 199✓/cap/cap; unit 354✓/470✓/602✓.<br>Refute L(megeve,savoie): naive cap/cap/cap; sos 377✓/589✓/849✓; unit 248✓/346✓/460✓.<br>Not provable L(les_houches,haute_savoie): naive cap; sos cap; unit saturates at 842/1 298/1 818, no □. |
| Q2.4 – Q2.5 | Q2.4: unit best on all goals (facts are units, clauses shrink each step; KB is Horn so unit resolution is complete). SOS good on the 2-step refutation, explodes breadth-first on the 5-step proof. Naive resolves KB×KB first, hits the cap everywhere. Not provable: no □; unit saturates (= proof it is not entailed), naive/sos stop at the cap (inconclusive). Not provable ≠ false (missing data).<br>Q2.5: clauses = F + n(n−1)(n−2) + communes·d(d−1)/2 ≈ n³ (736 / 1 338 / 2 204). Whole small (28): 19 696. Medium (501): ≈ 1.25·10⁸ (~17 GB). Grounding transitivity is cubic, so propositional resolution does not scale; first-order unification / Prolog / ASP needed. |
| Q3.1 | summits_in_department: haute_savoie = [aiguille_croche, arete_de_tricot, montagne_d_anterne, tete_de_la_cicle]; savoie = [aiguille_croche, chard_du_beurre, montagne_d_outray, tete_de_la_cicle] (aiguille_croche and tete_de_la_cicle lie in communes of both departments; setof lists each once).<br>high_resorts(1500) = [flaine, les_saisies]; high_resorts(2000) = [] (max known altitude 1650). The 2 resorts with unknown altitude are never listed. |
| Q3.2 (findall / setof / count) | findall 13 / setof 8 / count 13: a commune is returned once per neighbour with a resort (megeve 3×, domancy, les_contamines, les_houches 2×); setof removes duplicates. No solution: setof fails, findall gives [], count gives 0.<br>highest_summit via aggregate_all(max(A,S), …, max(A,S)): saint_gervais → arete_de_tricot 3221; megeve → aiguille_croche 2487. No summit with known altitude (e.g. combloux): max fails. |
| Q3.3 | communes_within(megeve, N): 7 / 11 / 11 for N = 1 / 2 / 3. reachable_naive does not terminate (cycles in the neighbour graph, depth-first search loops). Tabled reachable terminates (12 answers, each once); reaches/3 terminates thanks to the decreasing bound N. |
| Q3.4 (not snowy resorts, resorts without altitude) | not_snowy: 3 (domaine_de_praz_sur_arly, plaine_joux, saint_nicolas_de_veroce); without altitude: 2 (domaine_de_praz_sur_arly, saint_nicolas_de_veroce). Adding altitude(domaine_de_praz_sur_arly, 1600) makes it snowy → not_snowy = 2. Adding a fact removed a conclusion: negation as failure is non-monotonic (unknown treated as false, closed world). |
| Q3.5 | two_altitudes: aiguille_croche (2472, 2487); asymmetric_neighbour: combloux → sallanches; commune_without_department: les_houches; summit_without_massif: none (4 on medium). "No massif" is debatable: it only means no fact recorded; with incomplete data, unknown ≠ false. |
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
