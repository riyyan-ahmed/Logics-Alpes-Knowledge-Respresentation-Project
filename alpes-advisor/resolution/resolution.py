#!/usr/bin/env python3
"""Skeleton: propositional resolution prover.

Usage: python resolution/resolution.py extract_10.txt prove "LocatedIn(mont_charvin_q3321741,auvergne_rhone_alpes)" sos
       python resolution/resolution.py extract_10.txt refute "LocatedIn(manigod,savoie)" unit
Modes:      prove X  -> the clause -X is added (refutation)   |   refute X -> the clause X is added
Strategies to implement: naive | sos | unit
A clause is a frozenset of integers (atom i > 0, negative literal = -i). The empty clause is frozenset().
"""
import sys, time


def load(path):
    """PROVIDED: reads the clause file. Returns (list of clauses, dict atom -> integer)."""
    atoms, kb = {}, []
    for line in open(path, encoding="utf-8"):
        if line.startswith("#"):
            continue
        c = set()
        for l in line.split("#")[0].split():
            i = atoms.setdefault(l.lstrip("-"), len(atoms) + 1)
            c.add(-i if l.startswith("-") else i)
        kb.append(frozenset(c))
    return kb, atoms


def is_tautology(clause):
    """True if the clause contains a literal and its negation (e.g. {2, -2}).
    Such a clause is always true, so it is useless for finding a contradiction."""
    return any(-lit in clause for lit in clause)


def resolve(c1, c2):
    """Return the list of resolvents of c1 and c2 (each one a frozenset).

    For every literal l of c1 whose opposite -l is in c2, we cancel the pair (l, -l)
    and merge what is left of the two clauses:  (c1 - {l}) | (c2 - {-l}).

      resolve({1, 2}, {-1, 3})   -> [frozenset({2, 3})]   normal resolvent
      resolve({3}, {-3})         -> [frozenset()]         empty clause = contradiction
      resolve({1, 2}, {3, 4})    -> []                    nothing to cancel
      resolve({1, 2}, {-1, -2})  -> []                    both resolvents are tautologies
    """
    resolvents = []
    for lit in c1:
        # complementary pair found
        if -lit in c2:                       
            # remove the pair, merge the rest            
            r = (c1 - {lit}) | (c2 - {-lit})  
            # discard {x, -x, ...}           
            if not is_tautology(r):                      
                resolvents.append(frozenset(r))
    return resolvents


def allowed(strategy, given, other):
    """Strategy filter: may the pair (given, other) be passed to resolve()?
    - naive: every pair is allowed.
    - sos:   always True here, because in prove() the 'given' clause of the SOS strategy
             is always taken from the set of support (see below).
    - unit:  at least one of the two clauses must be a unit clause (exactly one literal)."""
    if strategy == "unit":
        return len(given) == 1 or len(other) == 1
    return True


def prove(kb, goal, strategy, cap=100_000):
    """Refutation prover. Returns (found, n):
       found = True if the empty clause was derived (KB + goal is contradictory),
       n     = number of resolvents generated (every non-tautological clause returned by resolve).

    Algorithm ("given clause" loop):
      - 'processed' : clauses already used; every pair (given, processed) is tried once.
      - 'todo'      : clauses waiting to be picked (a FIFO queue, so it is a breadth-first search).
      At each round we take the first clause of 'todo' (the given clause), resolve it with every
      processed clause it is allowed to pair with, put the NEW resolvents at the end of 'todo',
      then move the given clause into 'processed'.
      Because each clause is picked once and resolved with all earlier ones, every pair of
      clauses is considered exactly once.

    The three strategies only change WHICH pairs are tried:
      - naive: start with todo = KB + goal. Every pair of clauses is resolved.
      - sos  : processed starts as the KB, todo (= the set of support) starts as the goal.
               Only clauses of the support are ever picked, and every resolvent joins the
               support. So each resolution has at least one parent in the support, and two KB
               clauses are never resolved together.
      - unit : start with todo = KB + goal, but a pair is resolved only if one clause is a unit.

    Stops when: the empty clause appears (True), 'todo' is empty = saturation, nothing new
    can be produced (False), or n reaches cap (False).
    """
    if strategy not in ("naive", "sos", "unit"):
        raise ValueError(f"unknown strategy: {strategy} (use naive, sos or unit)")

    kb = [frozenset(c) for c in kb]
    goal = [frozenset(c) for c in goal]

    # The goal itself may already be the empty clause (not the case in practice, but be safe).
    if any(len(c) == 0 for c in kb + goal):
        return True, 0

    # every clause we already have: never add a clause twice
    seen = set(kb) | set(goal)        

    # Index: literal -> processed clauses containing it. To resolve 'given' we only need the
    # processed clauses that contain the opposite of one of its literals, so we look them up
    # here instead of scanning all processed clauses (same result, much faster).
    index = {}

    def add_processed(clause):
        for lit in clause:
            index.setdefault(lit, []).append(clause)

    if strategy == "sos":
        for c in kb:                  # the KB is "usable" but outside the set of support
            add_processed(c)
        todo = list(goal)             # the set of support starts with the (negated) goal
    else:
        todo = list(kb) + list(goal)  # naive and unit: everything starts in the queue

    n = 0                             # number of resolvents generated
    head = 0                          # position of the next given clause in 'todo' (FIFO)

    while head < len(todo):
        given = todo[head]
        head += 1

        # Processed clauses that share a complementary literal with 'given'
        # (a list without duplicates, in a fixed order so the runs are reproducible).
        partners, partner_set = [], set()
        for lit in given:
            for other in index.get(-lit, []):
                if other not in partner_set:
                    partner_set.add(other)
                    partners.append(other)

        for other in partners:
            if not allowed(strategy, given, other):
                continue
            for r in resolve(given, other):
                n += 1
                if len(r) == 0:       # empty clause: contradiction found, the goal is proved
                    return True, n
                if r not in seen:     # keep only clauses never seen before (termination)
                    seen.add(r)
                    todo.append(r)    # for sos, this is "add the resolvent to the support"
                if n >= cap:          # generation limit reached: give up
                    return False, n

        add_processed(given)          # from now on, later clauses can be resolved with it

    return False, n                   # saturation: no new clause can be produced


if __name__ == "__main__":
    file, mode, atom, strat = sys.argv[1:5]
    kb, atoms = load(file)
    if (atom not in atoms) :
        sys.exit(f"The goal {atom} is not an atom of the provided KB")
    i = atoms[atom]
    goal = [frozenset([-i if mode == "prove" else i])]
    t0 = time.time()
    found, gen = prove(kb, goal, strat)
    print(f"{strat}: {'empty clause' if found else 'no contradiction'} | resolvents generated: {gen} | {time.time()-t0:.2f}s")
