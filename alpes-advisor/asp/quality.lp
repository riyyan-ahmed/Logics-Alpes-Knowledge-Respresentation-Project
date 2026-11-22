% Detection of inconsistencies: inconsistency(two_altitudes,S), inconsistency(commune_without_department,C),
% inconsistency(asymmetric_neighbour,A,B), inconsistency(summit_without_massif,S).
% Run:  clingo data/small/facts.lp asp/quality.lp

% Two different altitude facts for the same entity (summit or resort).
inconsistency(two_altitudes, S) :- altitude(S, A1), altitude(S, A2), A1 != A2.

% A commune located in no department.
has_department(C) :- commune(C), located_in(C, D), department(D).
inconsistency(commune_without_department, C) :- commune(C), not has_department(C).

% neighbour(A, B) is recorded but neighbour(B, A) is not.
inconsistency(asymmetric_neighbour, A, B) :- neighbour(A, B), not neighbour(B, A).

% A summit with no in_massif fact.
has_massif(S) :- summit(S), in_massif(S, _).
inconsistency(summit_without_massif, S) :- summit(S), not has_massif(S).

% WARNING: there are two inconsistency predicates, use the two "show" directives
#show inconsistency/2.
#show inconsistency/3.
