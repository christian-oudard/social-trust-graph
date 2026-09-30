#!/usr/bin/env python3
"""Metamorphic property tests over random worlds larger than the exhaustive bounds.

Each property compares two evaluations of core.lp that should agree (or be ordered):
  P1 standing   the machine question never changes anything about commitments between
                persons and orgs made through persons' and orgs' grants; answerers only grow
                from delegate to actor to party
  P2 content    with no pins and no learning, re-sampling every invocation's substrate
                content changes nothing about attribution, binding or breach
  P3 history    appending a later invocation never retracts a past fact (no retroactivity)
  P4 fork law   adding a copy that breaks a prohibition creates a breach iff the debtor
                answers for the copy (a power covers it, or covered the original)
"""
import random
import sys
from pathlib import Path
import clingo

HERE = Path(__file__).parent
FILES = [HERE / "core.lp", HERE / "types.lp"]
WATCH = ("acts_for", "valid_creation", "bound", "violated", "defection", "live", "covered")


def good_world(rng, **kw):
    """A random world that is well-typed (e.g. no ambiguous, uncited delegation)."""
    while True:
        w = World(rng, **kw)
        try:
            evaluate(w.facts())
            return w
        except AssertionError:
            continue


def evaluate(facts, hyp="delegate"):
    ctl = clingo.Control(["--warn=none", "-c", "horizon=10"])
    for f in FILES:
        ctl.load(str(f))
    ctl.add("base", [], facts + f"hyp({hyp}).")
    ctl.ground([("base", [])])
    out = []
    ctl.solve(on_model=lambda m: out.append({str(a) for a in m.symbols(atoms=True)}))
    assert len(out) == 1, f"expected one model, got {len(out)}"
    errs = [a for a in out[0] if a.startswith("type_error")]
    assert not errs, errs
    return out[0]


def pick(atoms, names):
    return {a for a in atoms if a.split("(")[0] in names}


class World:
    """A random world: persons p,q, machine m, lineage over invocations i1..iN."""

    def __init__(self, rng, n=6, grants=3, commits=4, pins=True, learning=True):
        self.rng, self.n = rng, n
        self.lines, self.runs = [], {}
        L = self.lines.append
        for P, K in (("p", "person"), ("q", "person"), ("m", "machine")):
            L(f"principal({P}). kind({P},{K}).")
        for P in ("p", "q"):
            L(f"substrate(body_{P}). part(body_{P},self,opaque({P})). invocation({P}0). at({P}0,0). runs({P}0,body_{P}).")
            L(f"commitment(g{P}). mode(g{P},power). debtor(g{P},{P}). root(g{P},{P}0). follows(g{P},continue). allows(g{P},all,0). recognized(g{P},0).")
        # every machine step has its own memory, so learning always changes content;
        # only the weights vary between worlds (rollback is tested by scenarios and checks)
        for y in range(1, n + 2):
            for w in (1, 2):
                L(f"substrate(s{w}_{y}). part(s{w}_{y},weights,w{w}). part(s{w}_{y},memory,m{y}).")
        if rng.random() < 0.5:
            L("commitment(gm). mode(gm,power). debtor(gm,m). root(gm,i1). follows(gm,continue). follows(gm,copy). allows(gm,all,0). recognized(gm,0).")
        self.edges = []
        cont_used = set()
        for y in range(1, n + 1):
            L(f"invocation(i{y}). at(i{y},{y}).")
            self.runs[y] = f"s{rng.randint(1,2)}_{y}"
            if y > 1:
                for x in rng.sample(range(1, y), k=min(y - 1, rng.choice([1, 1, 2]))):
                    kind = rng.choice(["continue", "copy", "feed"])
                    if kind == "continue" and x in cont_used:
                        kind = "copy"
                    if kind == "continue":
                        cont_used.add(x)
                    self.edges.append((x, y, kind))
        for (x, y, kind) in self.edges:
            L(f"feeds(i{x},i{y})." if kind == "feed" else f"edge(i{x},i{y},{kind}).")
        for a in (1, 2, 3):
            L(f"act_name(a{a},pay). act_amount(a{a},{a}).")
        L("act_name(sp,spam).")
        creators = ["p0", "q0"] + [f"i{x}" for x in range(1, n + 1)]
        for g in range(1, grants + 1):
            P = rng.choice("pq")
            mode = "power" if rng.random() < 0.8 else "permit"
            L(f"commitment(d{g}). mode(d{g},{mode}). debtor(d{g},{P}). created(d{g},{rng.choice(creators)}). root(d{g},i{rng.randint(1,n)}).")
            for k in ("continue", "copy"):
                if rng.random() < 0.6:
                    L(f"follows(d{g},{k}).")
            L(f"allows(d{g},pay,{rng.randint(1,3)}).")
            if rng.random() < 0.5:
                L(f"allows(d{g},delegate,0).")
            if rng.random() < 0.4:
                L(f"allows(d{g},spam,0).")
            if pins and rng.random() < 0.4:
                L(f"pin(d{g},weights,w{rng.randint(1,2)}).")
            if rng.random() < 0.3:
                L(f"allows(d{g},copy,0).")
            if rng.random() < 0.2:
                L(f"revokes({rng.choice(creators)},d{g}).")
        for c in range(1, commits + 1):
            P = rng.choice("pq")
            Q = "q" if P == "p" else "p"
            mode = rng.choice(["achieve", "avoid"])
            L(f"commitment(c{c}). mode(c{c},{mode}). debtor(c{c},{P}). creditor(c{c},{Q}). "
              f"content(c{c},{rng.choice(['a1','a2','a3','sp'])}). created(c{c},{rng.choice(creators)}).")
            if mode == "achieve":
                L(f"deadline(c{c},{rng.randint(2,n)}).")
            if pins and rng.random() < 0.3:
                L(f"pin(c{c},weights,w{rng.randint(1,2)}).")
            if rng.random() < 0.3:
                L(f"commitment(r{c}). mode(r{c},achieve). debtor(r{c},{rng.choice([P, 'm'])}). creditor(r{c},{Q}). "
                  f"content(r{c},a1). trigger(r{c},c{c}). deadline(r{c},{n}). recognized(r{c},0).")
            if rng.random() < 0.2:
                L(f"releases({rng.choice(creators)},c{c}).")
        for x in range(1, n + 1):
            if rng.random() < 0.5:
                L(f"does(i{x},{rng.choice(['a1','a2','a3','sp'])}).")
        if learning and rng.random() < 0.5:
            L("act_name(dx,disclose). act_info(dx,x). act_target(dx,q). learns(i1,x).")
            for x in range(1, n + 1):
                if rng.random() < 0.3:
                    L(f"with(i{x},q).")

    def facts(self, runs=None):
        runs = runs or self.runs
        return "\n".join(self.lines + [f"runs(i{y},{s})." for y, s in runs.items()])


def human_only(atoms):
    """Atoms about commitments whose debtor and creditor are persons or orgs."""
    cs = {a[len("commitment("):-1] for a in atoms if a.startswith("commitment(")}
    machine = {a.split(",")[0][len("kind("):] for a in atoms if a.startswith("kind(") and a.endswith(",machine)")}
    ok = set()
    for c in cs:
        parties = {a.split(",")[1].rstrip(")") for a in atoms
                   if a.startswith((f"debtor({c},", f"creditor({c},"))}
        if not parties & machine:
            ok.add(c)
    return {a for a in pick(atoms, ("valid_creation", "bound", "violated", "defection", "live"))
            if a.split("(")[1].split(",")[0].rstrip(")") in ok
            and not (a.startswith("defection(") and a.split(",")[1] in machine)}


def p1_standing(rng):
    w = good_world(rng)
    d, a, p = (evaluate(w.facts(), h) for h in ("delegate", "actor", "party"))
    assert human_only(d) == human_only(a) == human_only(p), "the machine question changed a human-only commitment"
    ans = lambda x: {t for t in pick(x, ("answerer",)) if t.split("(")[1].split(",")[0] in
                     {s.split("(")[1].split(",")[0] for s in human_only(x)}}
    assert ans(d) <= ans(a) <= ans(p), "answerers shrank as machines gained capacities"


def p2_content(rng):
    w = good_world(rng, pins=False, learning=False)
    other = {y: f"s{rng.randint(1,2)}_{y}" for y in w.runs}
    a, b = evaluate(w.facts()), evaluate(w.facts(other))
    assert pick(a, WATCH) == pick(b, WATCH), "content changed attribution or binding without pins"


def p3_history(rng):
    w = good_world(rng)
    before = evaluate(w.facts())
    n = w.n + 1
    w.lines.append(f"invocation(i{n}). at(i{n},{n}). edge(i{rng.randint(1,w.n)},i{n},copy).")
    w.runs[n] = f"s1_{n}"
    after = evaluate(w.facts())
    past = lambda atoms: {a for a in pick(atoms, ("violated", "defection", "fulfilled", "bound", "live"))
                          if int(a.rstrip(")").split(",")[-1]) < n}
    assert past(before) <= past(after), f"history retracted: {sorted(past(before) - past(after))[:5]}"


def p4_fork_law(rng):
    w = good_world(rng, pins=False, learning=False)
    # a prohibition on q by p, broken only by a fresh copy of i1
    n = w.n + 1
    # grants that allow 'spam' make the copy's act attributable in about half the worlds
    w.lines.append("commitment(kz). mode(kz,avoid). debtor(kz,p). creditor(kz,q). content(kz,sp). recognized(kz,0).")
    if rng.random() < 0.5:   # half the time p covers the original, so answers for its copy
        follow = " follows(dz,copy)." if rng.random() < 0.5 else ""
        w.lines.append(f"commitment(dz). mode(dz,power). debtor(dz,p). created(dz,p0). root(dz,i1). allows(dz,spam,0). under(dz,gp).{follow}")
    w.lines.append(f"invocation(i{n}). at(i{n},{n}). edge(i1,i{n},copy). does(i{n},sp).")
    w.runs[n] = w.runs[1].split("_")[0] + f"_{n}"
    atoms = evaluate(w.facts())
    answered_by_p = f"answers_for(i{n},p)" in atoms and f"excused(kz,i{n})" not in atoms
    assert (f"violated(kz,{n})" in atoms) == answered_by_p, "fork law: breach iff p answers for the copy"
    return answered_by_p


PROPS = [p1_standing, p2_content, p3_history, p4_fork_law]
NONVACUOUS = {p4_fork_law}

if __name__ == "__main__":
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    failed = 0
    for prop in PROPS:
        rng = random.Random(seed)
        hits = 0
        for t in range(trials):
            try:
                hits += bool(prop(rng))
            except AssertionError as e:
                print(f"{prop.__name__} trial {t}: {e}")
                failed += 1
                break
        else:
            if prop in NONVACUOUS and not (trials // 10 <= hits <= trials - trials // 10):
                print(f"{prop.__name__}: one-sided, antecedent held in {hits}/{trials} trials")
                failed += 1
                continue
            print(f"{prop.__name__:12} {trials} trials pass" + (f" ({hits} non-trivial)" if prop in NONVACUOUS else ""))
    sys.exit(1 if failed else 0)
