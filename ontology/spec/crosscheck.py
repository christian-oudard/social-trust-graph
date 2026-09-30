#!/usr/bin/env python3
"""Cross-check the Rust (ascent) port against clingo on every scenario, every hypothesis.

For each world the base facts are exported to JSON, evaluated by ../rust, and the derived
atoms are compared with clingo's answer set (with types.lp, which must report no error) on
every relation the port emits. Worlds: every scenario; `--witness N` adds N witness worlds
from each exhaustive check (rich in roles, warranties, securities, feeds, injection);
`--random N` adds N random worlds from props.py.
"""
import json
import random
import subprocess
import sys
from pathlib import Path
import clingo

HERE = Path(__file__).parent
BIN = HERE.parent / "rust" / "target" / "release" / "coord-ontology"
HYPS = ("delegate", "actor", "party")


BASE = {"principal", "kind", "role", "invocation", "at", "runs", "part", "substrate", "edge", "changed_by",
        "does", "with", "learns", "feeds", "induced", "recorded", "act_name", "act_amount", "act_obj",
        "exclusive", "act_info", "act_target", "commitment", "debtor", "creditor", "mode", "content",
        "deadline", "pin", "trigger", "until", "created", "recognized", "releases", "revokes", "root",
        "follows", "allows", "under", "appointer", "appoints"}


def witness_worlds(check, k):
    """Up to k distinct base-fact sets from a check's non-vacuity witnesses."""
    ctl = clingo.Control(["--warn=none", f"--models={k}", "-c", "horizon=7", "-c", "n=4", "-c", "g=2", "-c", "k=2"])
    for f in (HERE / "core.lp", HERE / "types.lp", check):
        ctl.load(str(f))
    ctl.add("base", [], "witness_mode.")
    ctl.ground([("base", [])])
    worlds = []
    ctl.solve(on_model=lambda m: worlds.append(
        " ".join(f"{a}." for a in m.symbols(atoms=True) if a.name in BASE)))
    return worlds


def atoms_of(program_files, extra=""):
    ctl = clingo.Control(["--warn=none"])
    for f in program_files:
        ctl.load(str(f))
    ctl.add("base", [], extra)
    ctl.ground([("base", [])])
    out = []
    ctl.solve(on_model=lambda m: out.append(list(m.symbols(atoms=True))))
    assert len(out) == 1
    return out[0]


def export(facts_text=None, path=None):
    ctl = clingo.Control(["--warn=none"])
    if path:
        ctl.load(str(path))
    ctl.add("base", [], facts_text or "")
    ctl.ground([("base", [])])
    facts = []
    def arg(a):
        return a.number if a.type == clingo.SymbolType.Number else str(a)
    ctl.solve(on_model=lambda m: facts.extend(
        [a.name, [arg(x) for x in a.arguments]] for a in m.symbols(atoms=True)))
    return json.dumps({"horizon": 12, "facts": facts})


def compare(label, js, clingo_files, extra, hyp):
    rust = subprocess.run([str(BIN), hyp], input=js,
                          capture_output=True, text=True, check=True).stdout.split()
    names = {a.split("(")[0] for a in rust}
    ref = atoms_of(clingo_files + [HERE / "types.lp"], extra + f"hyp({hyp}).")
    errors = [str(a) for a in ref if a.name == "type_error"]
    if errors:
        print(f"{label} [{hyp}] ill-typed world: {errors[:2]}")
        return False
    ref = {str(a) for a in ref if a.name in names}
    rust = set(rust)
    if ref == rust:
        return True
    print(f"{label} [{hyp}] MISMATCH")
    for a in sorted(ref - rust)[:10]:
        print("   clingo only:", a)
    for a in sorted(rust - ref)[:10]:
        print("   rust only:  ", a)
    return False


def main(argv):
    core = [HERE / "core.lp"]
    ok = True
    n = 0
    for p in sorted((HERE / "scenarios").glob("*.lp")):
        js = export(path=p)
        for hyp in HYPS:
            ok &= compare(p.stem, js, core + [p], "", hyp)
            n += 1
    if "--witness" in argv:
        k = int(argv[argv.index("--witness") + 1])
        for c in sorted((HERE / "checks").glob("*.lp")):
            for j, facts in enumerate(witness_worlds(c, k)):
                js = export(facts_text=facts)
                for hyp in HYPS:
                    ok &= compare(f"{c.stem}#{j}", js, core, facts, hyp)
                    n += 1
    if "--random" in argv:
        sys.path.insert(0, str(HERE))
        from props import World
        k = int(argv[argv.index("--random") + 1])
        rng = random.Random(3)
        for t in range(k):
            w = World(rng)
            facts = w.facts()
            js = export(facts_text=facts)
            for hyp in HYPS:
                ok &= compare(f"random{t}", js, core, facts, hyp)
                n += 1
    print(f"{n} comparisons, {'all equal' if ok else 'MISMATCHES'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
