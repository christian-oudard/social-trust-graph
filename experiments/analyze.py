#!/usr/bin/env python3
"""Summarize a results.jsonl: outcome rates by factor, and a variance decomposition.

    python3 analyze.py e1_promise/results.jsonl model prompt memory future

The outcome is parsed from the JSON reply ("action"). The decomposition treats the
indicator of the modal outcome as a number and reports, for each factor, the share of
total variance explained by its main effect (eta squared), the share explained by the full
factor cell (every factor jointly, interactions included), and the residual: variance
between repeated samples of one identical configuration, i.e. sampling noise.
"""
import json, re, sys
from collections import Counter, defaultdict
from statistics import mean

def outcome(text):
    if not text:
        return "error"
    m = re.search(r'"action"\s*:\s*"(\w+)"', text)
    return m.group(1) if m else "unparsed"

def load(path):
    rows = [json.loads(l) for l in open(path)]
    for r in rows:
        r["y"] = outcome(r.get("text"))
    return rows

def eta2(rows, key, val):
    ys = [val(r) for r in rows]
    mu = mean(ys)
    total = sum((y - mu) ** 2 for y in ys)
    if total == 0:
        return 0.0
    groups = defaultdict(list)
    for r, y in zip(rows, ys):
        groups[key(r)].append(y)
    between = sum(len(g) * (mean(g) - mu) ** 2 for g in groups.values())
    return between / total

def main(path, factors):
    rows = [r for r in load(path) if r["y"] not in ("error", "unparsed")]
    bad = len(load(path)) - len(rows)
    counts = Counter(r["y"] for r in rows)
    target = counts.most_common(1)[0][0]
    val = lambda r: 1.0 if r["y"] == target else 0.0
    print(f"n={len(rows)} (dropped {bad})  outcomes={dict(counts)}  target='{target}'\n")
    for f in factors:
        print(f"{f}:")
        for lvl in sorted({r[f] for r in rows}):
            sub = [r for r in rows if r[f] == lvl]
            c = Counter(r["y"] for r in sub)
            print(f"  {lvl:10} n={len(sub):3}  " + "  ".join(f"{k}={c[k]/len(sub):.2f}" for k in sorted(counts)))
    print("\nvariance explained (eta^2, main effects):")
    for f in factors:
        print(f"  {f:10} {eta2(rows, lambda r: r[f], val):.3f}")
    cell = eta2(rows, lambda r: tuple(r[f] for f in factors), val)
    print(f"  {'all cells':10} {cell:.3f}   (residual = sampling noise within a configuration: {1-cell:.3f})")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
