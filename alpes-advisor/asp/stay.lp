% Stay: k steps (resorts), distinct massifs, distinct communes, #maximize.
% Atoms: step(S,M); only stay(S) is displayed (#project, #show).
% Run:  clingo data/small/facts.lp asp/params.lp asp/stay.lp 0 --opt-mode=optN

% ---------------------------------------------------------------------------
% 1. Derived relations (same meaning as in prolog/rules.pl)
% ---------------------------------------------------------------------------

% resort_commune(R, C): resort R lies in commune C (a resort may lie in several communes).
resort_commune(R, C) :- resort(R), located_in(R, C), commune(C).

% resort_massif(R, M): R is in massif M because a summit of one of R's communes is in M.
resort_massif(R, M) :- resort_commune(R, C), located_in(S, C), summit(S), in_massif(S, M).

% value(R, H): H = altitude of the highest summit of the commune(s) of resort R.
% #max over an empty set gives #inf, so value/2 is only defined when such a summit exists
% (has_value/1). A resort with no summit of known altitude simply adds nothing to the score.
has_value(R) :- resort_commune(R, C), located_in(S, C), summit(S), altitude(S, _).
value(R, H) :- has_value(R),
               H = #max { A, S : resort_commune(R, C), located_in(S, C), summit(S), altitude(S, A) }.

% ---------------------------------------------------------------------------
% 2. Choice: exactly k resorts, and one massif per chosen resort
% ---------------------------------------------------------------------------

% Choose exactly k resorts among those that have a massif.
{ stay(S) : resort_massif(S, _) } = k.

% Each chosen resort gets exactly one of its massifs: atom step(S, M).
1 { step(S, M) : resort_massif(S, M) } 1 :- stay(S).

% ---------------------------------------------------------------------------
% 3. Constraints (forbidden situations)
% ---------------------------------------------------------------------------

% Two different steps cannot have the same massif.
:- step(S1, M), step(S2, M), S1 < S2.

% Two different steps cannot share a commune.
:- stay(S1), stay(S2), S1 < S2, resort_commune(S1, C), resort_commune(S2, C).

% ---------------------------------------------------------------------------
% 4. Optimisation: maximise the sum of the values of the steps
% ---------------------------------------------------------------------------

% The tuple (H, S) makes each step count separately, even when two steps have the same H.
#maximize { H, S : stay(S), value(S, H) }.

% ---------------------------------------------------------------------------
% 5. Output: only the chosen resorts
% ---------------------------------------------------------------------------

% Projection: two answer sets with the same stay/1 atoms (but a different step/2 choice)
% count as ONE stay.
#project stay/1.
#show stay/1.
