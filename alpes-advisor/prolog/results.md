# Part 3: Prolog results (small instance)

Run from the `alpes-advisor/` folder:

    swipl data/small/facts.pl prolog/rules.pl

## Q3.1: summits_in_department and high_resorts

### summits_in_department(D, L)

    ?- summits_in_department(haute_savoie, L).
    L = [aiguille_croche, arete_de_tricot, montagne_d_anterne, tete_de_la_cicle].

    ?- summits_in_department(savoie, L).
    L = [aiguille_croche, chard_du_beurre, montagne_d_outray, tete_de_la_cicle].

- 4 summits in each department.
- aiguille_croche and tete_de_la_cicle appear in **both**, because a summit can lie in several communes:
  - tete_de_la_cicle is in hauteluce (savoie) and les_contamines_montjoie (haute_savoie);
  - aiguille_croche is in hauteluce (savoie) and in megeve, les_contamines_montjoie and saint_gervais_les_bains (haute_savoie).
- aiguille_croche is reached through 3 communes of haute_savoie, but appears only once in the list, because setof removes duplicates (and sorts).

### high_resorts(Threshold, L)

    ?- high_resorts(1500, L).
    L = [flaine, les_saisies].

    ?- high_resorts(2000, L).
    L = [].

Known altitudes of the 5 resorts:

| Resort | Altitude | ≥ 1500? | ≥ 2000? |
|---|---|---|---|
| flaine | 1600 | yes | no |
| les_saisies | 1650 | yes | no |
| plaine_joux | 1360 | no | no |
| domaine_de_praz_sur_arly | unknown | not listed | not listed |
| saint_nicolas_de_veroce | unknown | not listed | not listed |

- At 2000 m no resort qualifies, so findall returns the empty list `[]` (it does not fail).
- The 2 resorts with no altitude fact are never listed: an unknown altitude cannot be compared with the threshold.

## Q3.2: findall / setof / count, and highest_summit

Communes with a resort: hauteluce (les_saisies), passy (flaine, plaine_joux), praz_sur_arly (domaine_de_praz_sur_arly), saint_gervais_les_bains (saint_nicolas_de_veroce).

`commune_without_resort_near_resort(C)` succeeds once **per neighbouring commune with a resort**:

| C | Neighbours with a resort | Answers |
|---|---|---|
| combloux | saint_gervais_les_bains | 1 |
| demi_quartier | saint_gervais_les_bains | 1 |
| domancy | passy, saint_gervais_les_bains | 2 |
| la_giettaz | praz_sur_arly | 1 |
| les_contamines_montjoie | hauteluce, saint_gervais_les_bains | 2 |
| les_houches | passy, saint_gervais_les_bains | 2 |
| megeve | hauteluce, praz_sur_arly, saint_gervais_les_bains | 3 |
| sallanches | passy | 1 |

    ?- findall(C, commune_without_resort_near_resort(C), L), length(L, N).            N = 13
    ?- setof(C, commune_without_resort_near_resort(C), L), length(L, N).              N = 8
    ?- aggregate_all(count, commune_without_resort_near_resort(C), N).                N = 13

- findall and count keep every answer, duplicates included (13).
- setof sorts and removes duplicates (8 distinct communes, the real answer).
- When the goal has no solution, setof (and bagof) **fails**, whereas findall returns `[]` and aggregate_all(count) returns 0.

`highest_summit(C, S, A)` uses `aggregate_all(max(A1, S1), Goal, max(A, S))` (maximum with a witness):

    ?- highest_summit(saint_gervais_les_bains, S, A).   S = arete_de_tricot, A = 3221.
    ?- highest_summit(megeve, S, A).                    S = aiguille_croche, A = 2487.   (2472 and 2487 recorded: max keeps 2487)
    ?- highest_summit(combloux, S, A).                  false.

When the commune has no summit with a known altitude, aggregate_all(max, …) **fails** (7 communes out of 12: combloux, demi_quartier, domancy, la_giettaz, les_houches, praz_sur_arly, sallanches).

## Q3.3: communes_within, reachable_naive, reachable

    ?- communes_within(megeve, 1, L).   7 communes
    ?- communes_within(megeve, 2, L).   11 communes
    ?- communes_within(megeve, 3, L).   11 communes (all the other communes are already reached)

- `reachable_naive/2` **does not terminate** when asked for all answers (stopped by a 3 s time limit). The neighbour graph has cycles (megeve → combloux → megeve → …) and Prolog's depth-first search follows them forever, returning the same communes again and again.
- `reachable/2` with `:- table reachable/2.` terminates: tabling memorises the calls and answers already found, so cycles are detected and each answer is returned once (12 communes from megeve, megeve itself included).
- `reaches/3` terminates because of the bound N, which decreases at each step; it explores at most N steps.

## Q3.4: not_snowy and missing altitudes

    ?- findall(R, not_snowy(R), L).               [domaine_de_praz_sur_arly, plaine_joux, saint_nicolas_de_veroce]   3 resorts
    ?- findall(R, resort_without_altitude(R), L). [domaine_de_praz_sur_arly, saint_nicolas_de_veroce]                2 resorts

- Only plaine_joux (1360 m) is really below the threshold; the 2 others are "not snowy" only because their altitude is unknown.
- Test: adding `altitude(domaine_de_praz_sur_arly, 1600).` makes it snowy; not_snowy then returns 2 resorts.
- So adding a fact **removed** a conclusion: negation as failure is **non-monotonic**. `\+ snowy(R)` means "snowy(R) cannot be proved", not "R is not snowy" (closed-world assumption: unknown is treated as false).

## Q3.5: inconsistencies

| Predicate | Result on small |
|---|---|
| two_altitudes(X) | aiguille_croche (2472 and 2487) |
| asymmetric_neighbour(A, B) | combloux → sallanches (no neighbour(sallanches, combloux)) |
| commune_without_department(C) | les_houches |
| summit_without_massif(S) | none: every summit has an in_massif fact |

"This summit belongs to no massif" is debatable: Prolog only says that no `in_massif` fact is **recorded**. The data is incomplete, so a missing fact can mean "unknown", not "false" (closed-world assumption again). On medium, 4 summits have no massif fact.

## Q3.6 = Q1.1 and Q1.2 (checked with Prolog on small)

LocatedIn is read as the recorded `located_in/2` facts, Neighbour as `neighbour/2`.

| Formula | Satisfied? | Witness (Prolog query) |
|---|---|---|
| (a) transitivity | no | located_in(aiguille_croche, hauteluce), located_in(hauteluce, savoie), but no located_in(aiguille_croche, savoie) (26 such triples). It holds for `inside/2`, which is the closure. |
| (b) symmetry | no | neighbour(combloux, sallanches) without neighbour(sallanches, combloux) |
| (c) at most one department | yes | no commune is located in two departments |
| (d) every summit in a commune | no | plateau_des_saix and signal_de_bisanne have no commune |
| (E1) every commune in a department | no | les_houches (commune_without_department) |
| (E2) every massif has a summit > 2400 m | no | massif_du_faucigny and massif_du_giffre (montagne_d_anterne is 2000 m) |
| (E3) commune without resort next to a commune with one | yes | e.g. megeve, next to saint_gervais_les_bains |
| (E4) no resort in a commune without department | yes | les_houches has no resort |

Q1.2: (E1) is false, refuted by the commune les_houches, which has no `located_in(les_houches, D)` with D a department.
