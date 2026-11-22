% Default rule: a resort is snowy if a known altitude reaches the threshold,
% unless there is a known exception (exception/1). Unknown altitude: snow is possible, never certain.
% Run:  clingo data/small/facts.lp asp/params.lp asp/default.lp 0 --enum-mode=brave
%       clingo data/small/facts.lp asp/params.lp asp/default.lp 0 --enum-mode=cautious
#defined exception/1. % avoids a warning if no exception is given

% Example of exception (Q4.5): uncomment to test.
% exception(flaine).

% has_altitude(R): at least one altitude is known for R.
has_altitude(R) :- resort(R), altitude(R, _).

% Default: known altitude >= threshold, and no exception => snowy.
% "not exception(R)" is default negation: true as long as exception(R) cannot be derived.
snowy(R) :- resort(R), threshold(T), altitude(R, A), A >= T, not exception(R).

% Unknown altitude: snow is POSSIBLE. The choice rule gives two kinds of answer sets,
% one with snowy(R) and one without, so snowy(R) is brave but never cautious.
{ snowy(R) } :- resort(R), not has_altitude(R), not exception(R).

#show snowy/1.
