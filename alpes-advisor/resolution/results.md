# Part 2: implementation results (Q2.3 – Q2.5)

Q2.1 and Q2.2 (by hand) and the refutation proof are in `hand_proofs.md`.

## How the measurements were made

All commands run from the `alpes-advisor/` folder, exactly as in the statement.

1. Generate the knowledge bases:

       python resolution/kb.py data/small/facts.pl 10
       python resolution/kb.py data/small/facts.pl 12
       python resolution/kb.py data/small/facts.pl 14

   | n | Clauses | Facts (F) | Transitivity (T) | Uniqueness (U) | Atoms |
   |---|---|---|---|---|---|
   | 10 | 736 | 11 | 720 | 5 | 90 |
   | 12 | 1 338 | 13 | 1 320 | 5 | 132 |
   | 14 | 2 204 | 15 | 2 184 | 5 | 182 |

2. Run the prover on three goals, for each strategy (`naive`, `sos`, `unit`) and each n:

   | Kind of goal | Command | What it means |
   |---|---|---|
   | Provable | `prove "LocatedIn(aiguille_croche,auvergne_rhone_alpes)"` | adds ¬goal; facts + transitivity give a contradiction |
   | False statement to refute | `refute "LocatedIn(megeve,savoie)"` | adds the statement; Megève is in Haute-Savoie, and uniqueness forbids a second department |
   | Not provable | `prove "LocatedIn(les_houches,haute_savoie)"` | les_houches has no department in the data: no proof exists |

   Example: `python resolution/resolution.py extract_10.txt prove "LocatedIn(aiguille_croche,auvergne_rhone_alpes)" unit`

   The cap is 100 000 resolvents. The given clause is chosen first-in first-out (breadth-first).

## Q2.3: number of resolvents generated

✓ = empty clause derived. "cap" = stopped at 100 000 without finding the empty clause. "sat." = saturation: no new clause can be produced, so the search stops without the empty clause.

| Goal | Strategy | n = 10 | n = 12 | n = 14 |
|---|---|---|---|---|
| Provable | naive | cap | cap | cap |
| | sos | 25 199 ✓ | cap | cap |
| | unit | **354 ✓** | **470 ✓** | **602 ✓** |
| Refute | naive | cap | cap | cap |
| | sos | 377 ✓ | 589 ✓ | 849 ✓ |
| | unit | **248 ✓** | **346 ✓** | **460 ✓** |
| Not provable | naive | cap | cap | cap |
| | sos | cap | cap | cap |
| | unit | 842 (sat.) | 1 298 (sat.) | 1 818 (sat.) |

All runs take less than 0.15 s each. The cost is in the number of clauses, not the time per clause.

## Q2.4: which strategy is most efficient, and why?

**Unit resolution is the most efficient on all three kinds of goal.**
- The facts are unit clauses. Each resolution with a unit removes one literal, so clauses get shorter at every step, and the search behaves like forward chaining along the summit → commune → department → region chain.
- Pairs of two long transitivity clauses are never resolved, which removes most of the useless work.
- Every clause in this KB has at most one positive literal (Horn clauses: facts, transitivity, uniqueness, and the goal). For Horn clauses unit resolution is refutation-complete, so it misses no proof.

**SOS works well when the proof is short, and badly when it is long.**
- Refute goal: the proof is 2 steps (L(megeve,savoie) + uniqueness → ¬L(megeve,haute_savoie), then + the fact → □), so SOS finds it quickly (377 to 849).
- Provable goal: the proof is 5 steps deep. With breadth-first selection, the goal clause ¬L(aiguille_croche,ara) matches every transitivity clause whose conclusion is L(aiguille_croche,ara) (one for each middle entity y), and each new clause matches many more. The number of clauses multiplies at every level (n = 10: 8 → 134 → 1 829 → 21 984 resolvents at levels 1 to 4, □ at level 5): 25 199 in total at n = 10, and over the cap from n = 12 (level 4 alone already makes 50 332).
- SOS stays focused on the goal, but it does not make clauses shorter. A "shortest clause first" selection would help a lot (optional in the statement).

**Naive is the worst.** It resolves knowledge-base clauses with each other (transitivity × transitivity) before it even reaches the goal clause, which is last in the queue. It hits the cap on every goal; even with a cap of 3 000 000 it did not find the proof at n = 10.

**Goal that is not provable (les_houches):**
- No strategy derives the empty clause, which is the correct outcome: no `located_in(les_houches, …)` fact exists.
- Unit resolution saturates (842 / 1 298 / 1 818 resolvents) and stops by itself. Because unit resolution is complete for Horn clauses, this saturation proves that the goal does **not** follow from the KB.
- Naive and SOS keep generating clauses until the cap. Stopping at the cap tells us nothing: we cannot distinguish "not provable" from "would need more time".
- "Not provable" does not mean "false": the KB simply does not know les_houches's department (missing information).

## Q2.5: number of initial clauses as a function of n

For an extract of n entities with c communes and d departments:

    clauses(n) = F + n(n − 1)(n − 2) + c · d(d − 1)/2

- F = located_in facts with both ends in the extract (grows roughly like n).
- n(n − 1)(n − 2) = transitivity, one clause per ordered triple of distinct entities: **cubic, it dominates**.
- c · d(d − 1)/2 = uniqueness, one clause per commune and per pair of departments.
- The number of atoms is n(n − 1) (one LocatedIn(x,y) per ordered pair).

Measured: 736 (n = 10), 1 338 (n = 12), 2 204 (n = 14), all ≈ n³.

**Extrapolation:**

| Instance | Entities n | Communes | Departments | F | T = n(n−1)(n−2) | U | Total clauses | Atoms n(n−1) |
|---|---|---|---|---|---|---|---|---|
| whole small | 28 | 12 | 2 | 28 | 19 656 | 12 | **19 696** | 756 |
| medium | 501 | 279 | 1 | 612 | 124 999 500 | 0 | **≈ 1.25 × 10⁸** | 250 500 |

At about 135 bytes per clause, the medium file alone would weigh about 17 GB. (On medium U = 0, because it contains a single department.) kb.py itself can build at most 22 entities on small.

**Conclusion:** the propositional approach does not scale for this problem. Grounding the single first-order transitivity axiom creates n³ clauses, almost all of them about triples that make no sense (e.g. a region inside a summit). Even on 14 entities the naive search already explodes. First-order resolution keeps one transitivity clause and uses unification instead. Prolog (goal-directed search) and ASP (smart grounding) only build what the query needs, which is what Parts 3 and 4 do.
