#!/usr/bin/env python3
"""Cross-check the Rust (ascent) port against clingo on every scenario, both hypotheses.

For each scenario the base facts are exported to JSON, evaluated by ../rust, and the
derived atoms are compared with clingo's answer set on every relation the port emits.
Pass `--random N` to also compare on N random worlds from props.py.
"""
import json
import random
import subprocess
import sys
from pathlib import Path
import clingo

HERE = Path(__file__).parent
BIN = HERE.parent / "rust" / "target" / "release" / "coord-ontology"


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
    rust = subprocess.run([str(BIN)] + (["party"] if hyp else []), input=js,
                          capture_output=True, text=True, check=True).stdout.split()
    names = {a.split("(")[0] for a in rust}
    ref = atoms_of(clingo_files, extra + ("hyp(machine_party)." if hyp else ""))
    ref = {str(a) for a in ref if a.name in names}
    rust = set(rust)
    if ref == rust:
        return True
    print(f"{label} [{'party' if hyp else 'delegate'}] MISMATCH")
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
        for hyp in (False, True):
            ok &= compare(p.stem, js, core + [p], "", hyp)
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
            for hyp in (False, True):
                ok &= compare(f"random{t}", js, core, facts, hyp)
                n += 1
    print(f"{n} comparisons, {'all equal' if ok else 'MISMATCHES'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
