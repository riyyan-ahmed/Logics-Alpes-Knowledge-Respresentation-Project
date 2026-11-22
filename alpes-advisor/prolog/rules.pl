:- encoding(utf8).
:- use_module(library(aggregate)).
% Alpes Advisor, Part 3. Predicate names and arities are REQUIRED (see the statement).
% Loading:  swipl data/small/facts.pl prolog/rules.pl

% The facts (commune/1, located_in/2, neighbour/2, altitude/2, ...) live in facts.pl,
% which must be loaded first.

% ---------------------------------------------------------------------------
% Parameter
% ---------------------------------------------------------------------------

% threshold(T): a resort is snowy if one of its known altitudes is >= T metres.
threshold(1500).

% ---------------------------------------------------------------------------
% 1. Basic relations
% ---------------------------------------------------------------------------

% inside(X, Y): X lies in Y, directly or through several levels.
% Transitive closure of located_in/2:  summit -> commune -> department -> region.
inside(X, Y) :- located_in(X, Y).                     % one step
inside(X, Z) :- located_in(X, Y), inside(Y, Z).       % one step, then the rest

% adjacent(A, B): A and B are neighbours, whatever the direction recorded in the data.
% Symmetric version of neighbour/2. The second clause only adds the missing direction,
% so a pair recorded in both directions is not returned twice.
adjacent(A, B) :- neighbour(A, B).
adjacent(A, B) :- neighbour(B, A), \+ neighbour(A, B).

% resort_massif(R, M): resort R is in massif M, because a summit of R's commune is in M.
% setof removes duplicates (several summits of the same commune in the same massif).
resort_massif(R, M) :-
    resort(R),
    setof(M1, C^S^( located_in(R, C), commune(C),
                    located_in(S, C), summit(S),
                    in_massif(S, M1) ), Ms),
    member(M, Ms).

% ---------------------------------------------------------------------------
% 2. Collecting solutions: setof / findall / aggregate_all
% ---------------------------------------------------------------------------

% summits_in_department(D, L): L = sorted list, without duplicates, of the summits inside D.
% setof sorts and removes duplicates (a summit in two communes of D appears once).
% It fails if D has no summit.
summits_in_department(D, L) :-
    department(D),
    setof(S, (summit(S), inside(S, D)), L).

% high_resorts(Threshold, L): resorts with a KNOWN altitude >= Threshold.
% findall gives [] when there is none; sort/2 removes duplicates (two altitudes).
% A resort with no altitude fact is never in the list (unknown is not >= anything).
high_resorts(Threshold, L) :-
    findall(R, (resort(R), altitude(R, A), A >= Threshold), L0),
    sort(L0, L).

% commune_with_resort(C): at least one resort lies in commune C.
% once/1 stops after the first resort, so a commune with 2 resorts is returned once.
commune_with_resort(C) :-
    commune(C),
    once(( located_in(R, C), resort(R) )).

% commune_without_resort_near_resort(C): C has no resort, but an adjacent commune has one.
% C is returned once for EACH neighbouring commune with a resort (this is on purpose,
% see Q3.2: findall keeps these duplicates, setof removes them).
commune_without_resort_near_resort(C) :-
    commune(C),
    \+ commune_with_resort(C),
    adjacent(C, C2),
    commune_with_resort(C2).

% highest_summit(C, S, A): S is the highest summit of commune C, with altitude A.
% aggregate_all(max(Value, Witness), Goal, max(Max, Who)) keeps the summit that reaches the
% maximum. It FAILS when the commune has no summit with a known altitude.
highest_summit(C, S, A) :-
    commune(C),
    aggregate_all(max(A1, S1),
                  ( located_in(S1, C), summit(S1), altitude(S1, A1) ),
                  max(A, S)).

% ---------------------------------------------------------------------------
% 3. Recursion on the neighbour graph
% ---------------------------------------------------------------------------

% reaches(A, B, N): commune B is at most N steps away from commune A (via adjacent/2).
% Bounded recursion: N decreases at each step, so it always terminates.
reaches(A, A, N) :-                       % 0 steps: A reaches itself
    N >= 0,
    commune(A).
reaches(A, B, N) :-                       % one step to C, then at most N-1 steps from C
    N > 0,
    adjacent(A, C),
    N1 is N - 1,
    reaches(C, B, N1).

% communes_within(A, N, L): sorted list of the communes (other than A) at most N steps from A.
communes_within(A, N, L) :-
    commune(A),
    setof(B, (reaches(A, B, N), B \== A), L).

% reachable_naive(A, B): B can be reached from A in any number of steps.
% NO bound and NO tabling: the graph has cycles (A -> B -> A -> ...), so Prolog can loop
% forever. It finds answers, but asking for ALL of them never terminates.
reachable_naive(A, B) :- adjacent(A, B).
reachable_naive(A, B) :- adjacent(A, C), reachable_naive(C, B).

% reachable(A, B): same relation, with tabling.
% Tabling remembers the calls already seen and their answers, so cycles are detected and
% the computation terminates with every answer exactly once.
:- table reachable/2.
reachable(A, B) :- adjacent(A, B).
reachable(A, B) :- reachable(A, C), adjacent(C, B).

% ---------------------------------------------------------------------------
% 4. Missing information and negation as failure
% ---------------------------------------------------------------------------

% snowy(R): resort R has a KNOWN altitude >= threshold.
snowy(R) :-
    resort(R),
    threshold(T),
    once(( altitude(R, A), A >= T )).

% not_snowy(R): negation as failure. "Cannot prove snowy(R)" is read as "R is not snowy".
% A resort with UNKNOWN altitude is therefore declared not snowy (closed-world assumption).
not_snowy(R) :-
    resort(R),
    \+ snowy(R).

% resort_without_altitude(R): no altitude fact at all for resort R.
resort_without_altitude(R) :-
    resort(R),
    \+ altitude(R, _).

% summit_without_massif(S): no in_massif fact for summit S.
summit_without_massif(S) :-
    summit(S),
    \+ in_massif(S, _).

% ---------------------------------------------------------------------------
% 5. Detection of inconsistencies in the data
% ---------------------------------------------------------------------------

% two_altitudes(X): X (summit or resort) has at least two different altitude facts.
% distinct/2 returns each X once, even if it has 3 or more altitudes.
two_altitudes(X) :-
    distinct(X, ( altitude(X, A1), altitude(X, A2), A1 \== A2 )).

% asymmetric_neighbour(A, B): neighbour(A, B) is recorded, but neighbour(B, A) is not.
asymmetric_neighbour(A, B) :-
    neighbour(A, B),
    \+ neighbour(B, A).

% commune_without_department(C): commune C is inside no department.
commune_without_department(C) :-
    commune(C),
    \+ ( inside(C, D), department(D) ).
