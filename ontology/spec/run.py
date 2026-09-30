#!/usr/bin/env python3
"""Run every scenario against core.lp under each answer to the party-vs-delegate question.

Scenario files state expectations as facts over atoms:
    expect(A).            A must be derived under every hypothesis
    reject(A).            A must not be derived under any hypothesis
    expect(H, A) / reject(H, A)   same, only under hypothesis H in {delegate, actor, party}
Each run must have exactly one answer set (the core is deterministic).

Check files (checks/*.lp) search for counterexamples with choice rules. A check passes
when it is UNSAT (no counterexample within bounds), after a non-vacuity run (the same
generator without the violation constraint) is SAT.
"""
import sys
from pathlib import Path
import clingo

HERE = Path(__file__).parent
CORE = HERE / "core.lp"
TYPES = HERE / "types.lp"
CHECK_CONSTS = ("horizon=7", "n=5", "g=3", "k=3")
HYPS = {"delegate": "hyp(delegate).", "actor": "hyp(actor).", "party": "hyp(party)."}


def solve(files, extra="", consts=(), limit=2):
    ctl = clingo.Control(["--warn=none", f"--models={limit}", *[f"-c{c}" for c in consts]])
    ctl.configuration.solve.project = "no"
    for f in files:
        ctl.load(str(f))
    ctl.add("base", [], extra)
    ctl.ground([("base", [])])
    models = []
    with ctl.solve(yield_=True) as h:
        for m in h:
            models.append(m.symbols(atoms=True))
    return models


def run_scenario(path):
    ok = True
    for hyp, fact in HYPS.items():
        models = solve([CORE, TYPES, path], fact)
        if len(models) != 1:
            print(f"  [{hyp}] expected 1 answer set, got {len(models)}")
            ok = False
            continue
        atoms = {str(a) for a in models[0]}
        for a in models[0]:
            if a.name == "type_error":
                print(f"  [{hyp}] TYPE     {a.arguments[1].string}")
                ok = False
        for a in models[0]:
            if a.name not in ("expect", "reject"):
                continue
            if len(a.arguments) == 2 and a.arguments[0].name != hyp:
                continue
            target = str(a.arguments[-1])
            present = target in atoms
            if a.name == "expect" and not present:
                print(f"  [{hyp}] MISSING  {target}")
                ok = False
            if a.name == "reject" and present:
                print(f"  [{hyp}] UNWANTED {target}")
                ok = False
    return ok


def run_check(path):
    files = [CORE, TYPES, path]
    witness = solve(files, "witness_mode.", consts=CHECK_CONSTS, limit=1)
    if not witness:
        print("  vacuous: generator admits no world")
        return False
    cex = solve(files, "", consts=CHECK_CONSTS, limit=1)
    if cex:
        shown = sorted(str(a) for a in cex[0] if a.name.startswith(("cx", "gen_")))
        print("  COUNTEREXAMPLE:", " ".join(shown))
        return False
    return True


def main(argv):
    only = argv[1:]
    results = []
    for kind, fn in (("scenarios", run_scenario), ("checks", run_check)):
        for p in sorted((HERE / kind).glob("*.lp")):
            if only and not any(o in p.name for o in only):
                continue
            print(f"{kind[:-1]:9} {p.stem}")
            ok = fn(p)
            results.append(ok)
            print("          " + ("pass" if ok else "FAIL"))
    print(f"{sum(results)}/{len(results)} passed")
    return 0 if all(results) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
