#!/usr/bin/env python3
"""Mutation testing: every deliberate break of core.lp must be caught by some test.

Two layers:
  deletion   every statement of core.lp is deleted in turn (automatic)
  semantic   hand-written changes of meaning that no deletion expresses (off-by-one time
             guards, widened scopes, rules that apply too broadly)
A mutant is killed when the scenarios/checks (run.py) or the properties (props.py) fail.
A surviving deletion means a statement no test depends on: either test it or delete it.

    python3 mutants.py               all mutants, in parallel
    python3 mutants.py semantic      only the hand-written ones
"""
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

HERE = Path(__file__).parent

# statements whose deletion is not a meaningful mutant (the time domain itself)
KEEP = ("#const", "time(0..horizon)")

SEMANTIC = [
    ("release takes effect at once", "time(T), T > T0, creditor(C,Q), acts_for(I,releasing,Q),",
     "time(T), T >= T0, creditor(C,Q), acts_for(I,releasing,Q),"),
    ("live at creation step", "valid_creation(C), time(T), T > T0,", "valid_creation(C), time(T), T >= T0,"),
    ("same-step reparation", "violated(C0,T0), T0 < T.", "violated(C0,T0), T0 <= T."),
    ("acceptance before offer", "start(C,Ts), Ts <= T0.", "start(C,Ts)."),
    ("conditional grants cover early", "at(I,T), detached(G,T).", "at(I,T), live(G,T)."),
    ("copies always followed", "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), eff_follows(G,K).",
     "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,_)."),
    ("followed kinds widen", "eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), eff_follows(G1,K).",
     "eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1)."),
    ("any 'all' grant is a root", "parent_grant(G2,G1), recognized(G1,_), allows(G1,all,_).",
     "parent_grant(G2,G1), allows(G1,all,_)."),
    ("attenuation widens", "scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.",
     "scope(G2,N,Cap):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1."),
    ("amountless acts pass caps", "within(G,A) :- scope(G,N,0), act_name(A,N), not has_amount(A).",
     "within(G,A) :- scope(G,N,_), act_name(A,N), not has_amount(A)."),
    ("citation ignored", "parent_grant(G2,G1) :- candidate_parent(G2,G1), not cites(G2).",
     "parent_grant(G2,G1) :- candidate_parent(G2,G1)."),
    ("attribution by content", "", "acts_for(I,P) :- runs(I,S), runs(I0,S), acts_for(I0,P), I != I0."),
    ("permits empower", "acts_for(I,P)   :- covered(G,I), grant(G), not security(G), debtor(G,P).",
     "acts_for(I,P)   :- covered(G,I), not security(G), debtor(G,P)."),
    ("securities answer", "acts_for(I,P)   :- covered(G,I), grant(G), not security(G), debtor(G,P).",
     "acts_for(I,P)   :- covered(G,I), grant(G), debtor(G,P)."),
    ("securities create", "acts_for(I,A,P) :- covered(G,I), grant(G), not security(G), debtor(G,P), within(G,A).",
     "acts_for(I,A,P) :- covered(G,I), grant(G), debtor(G,P), within(G,A)."),
    ("powers excuse", "", "excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), acts_for(I,A,Q)."),
    ("answerability scoped", "conduct_of(I,A,P) :- answers_for(I,P), does(I,A).",
     "conduct_of(I,A,P) :- acts_for(I,A,P), does(I,A).\nconduct_of(I,A,P) :- resp_only(I,P), does(I,A)."),
    ("feeds into owned invocations spawn", "spawn(I1,I2) :- feeds(I1,I2), not owned(I2).", "spawn(I1,I2) :- feeds(I1,I2)."),
    ("responsibility spreads along feeds", "", "resp_only(I2,P) :- resp_only(I1,P), feeds(I1,I2), not acts_for(I2,P)."),
    ("role ignores holder's authority", "holder(R,P,T), at(I,T), acts_for(I,A,P),", "holder(R,P,T), at(I,T), acts_for(I,P),"),
    ("role powers ignore revocation", "                   detached(G,T), not off_pin(G,I).", "                   not off_pin(G,I)."),
    ("holders need not owe", "time(T), T > T0, T < T2, capacity(P,owe).", "time(T), T > T0, T < T2."),
    ("machines always stand", "standing(P) :- capacity(P,owe).", "standing(P) :- capacity(P,owe).\nstanding(P) :- kind(P,machine)."),
    ("actor can claim", "bundle(actor,owe).", "bundle(actor,owe). bundle(actor,claim)."),
    ("self-steering vitiates", "vitiated(I) :- induced(I,Q), not acts_for(I,Q).", "vitiated(I) :- induced(I,_)."),
    ("dual agent releases", "debtor(C,P), not acts_for(I,P), not vitiated(I).", "debtor(C,P), not vitiated(I)."),
    ("securities revocable", "not security(G),\n                 not vitiated(I).", "\n                 not vitiated(I)."),
    ("securities cascade", "start(G2,T0), T > T0, not security(G2).", "start(G2,T0), T > T0."),
    ("securities inherit pins", "eff_off_pin(G1,I), not security(G2).", "eff_off_pin(G1,I)."),
    ("securities outlive repair", "repaired(C,_,T1), time(T), T > T1.", "repaired(C,_,T1), time(T), T > T1, #false."),
    ("induced performance excused", "excused(C,I) :- mode(C,avoid), creditor(C,Q), induced(I,Q), invocation(I).",
     "excused(C,I) :- creditor(C,Q), induced(I,Q), invocation(I), commitment(C)."),
    ("warranty ranges over debtor", "does(I,A), at(I,T), on_pin(W,I), not excused(W,I).",
     "does(I,A), at(I,T), on_pin(W,I), not excused(W,I), debtor(W,E), acts_for(I,E)."),
    ("steered warranty breach counts", "does(I,A), at(I,T), on_pin(W,I), not excused(W,I).", "does(I,A), at(I,T), on_pin(W,I)."),
    ("errands are custody", "custodian(I,P) :- covered(G,I), grant(G), recognized(G,_), debtor(G,P).",
     "custodian(I,P) :- covered(G,I), grant(G), debtor(G,P)."),
    ("succession retroactive", "open_defection(P1,T), T >= T2.", "open_defection(P1,T)."),
    ("self-assurance", "                not answers_for(I,E).", "                invocation(I)."),
    ("exposure only on conduct", "bound(C,P,T0), T0 <= T, answers_for(I,P), at(I,T0),",
     "bound(C,P,T0), T0 <= T, answers_for(I,P), content(C,A), does(I,A), at(I,T0),"),
    ("co-holders share blame", "holder(R,P,T), performs(C,I,T), acts_for(I,P).", "holder(R,P,T)."),
    ("one repair covers all", "performs(C2,_,Tp), T0 <= Tp, Tp <= T, time(T).", "performs(C2,_,Tp), Tp <= T, time(T)."),
    ("fresh copies inherit", "root(G,I2), ancestor(I1,I2),", "root(G,I2), runs(I2,S), runs(I1,S), I1 != I2,"),
    ("external change is the parent's", "changer(I1,I2) :- edge(I1,I2,_), not external(I2).", "changer(I1,I2) :- edge(I1,I2,_)."),
    ("resolutive act out of range", "T > T0, in_range(C,I).", "T > T0."),
]


def statements(text):
    """Split an ASP program into statements (a period not part of '..', followed by space)."""
    body = "\n".join(line.split("%")[0] for line in text.splitlines())
    parts = re.split(r"(?<!\.)\.(?!\.)(?=\s)", body)
    return [p.strip() for p in parts if p.strip()]


def killed(mutated):
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        shutil.copytree(HERE, d, dirs_exist_ok=True, ignore=shutil.ignore_patterns("__pycache__"))
        (d / "core.lp").write_text(mutated)
        for cmd in ([sys.executable, "run.py"], [sys.executable, "props.py", "40", "7"]):
            if subprocess.run(cmd, cwd=d, capture_output=True).returncode != 0:
                return True
    return False


def job(item):
    name, mutated = item
    return name, killed(mutated)


def main(argv):
    core = (HERE / "core.lp").read_text()
    jobs = []
    for name, old, new in SEMANTIC:
        if old and old not in core:
            print(f"?? semantic mutant '{name}': pattern not found")
            return 1
        jobs.append((f"semantic: {name}", core.replace(old, new, 1) if old else core + "\n" + new + "\n"))
    if "semantic" not in argv:
        stmts = statements(core)
        for i, st in enumerate(stmts):
            if st.startswith(KEEP):
                continue
            rest = stmts[:i] + stmts[i + 1:]
            jobs.append((f"delete: {' '.join(st.split())[:90]}", ".\n".join(rest) + ".\n"))
    survivors = []
    with ProcessPoolExecutor() as pool:
        for name, k in pool.map(job, jobs):
            if not k:
                survivors.append(name)
                print("SURVIVED", name, flush=True)
    print(f"{len(jobs) - len(survivors)}/{len(jobs)} mutants killed")
    return 1 if survivors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
