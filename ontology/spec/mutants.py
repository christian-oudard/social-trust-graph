#!/usr/bin/env python3
"""Mutation testing: every deliberate break of core.lp must be caught by some test.

A surviving mutant means a rule is not pinned down by any scenario, check or property,
so the claim it implements is asserted but not tested.
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).parent

# (name, old text, new text). Empty old text means append new text.
MUTANTS = [
    ("attenuation widens", "scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.",
     "scope(G2,N,Cap):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1."),
    ("no revocation cascade", "ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), created(G2,I), at(I,T0), T > T0.", ""),
    ("pins ignored", "covered(G,I) :- in_lineage(G,I), not off_pin(G,I), at(I,T), live(G,T).",
     "covered(G,I) :- in_lineage(G,I), at(I,T), live(G,T)."),
    ("pins ignored in performance", "acts_for(I,A,P), not excused(C,I),\n                   not off_pin(C,I).",
     "acts_for(I,A,P), not excused(C,I)."),
    ("pin needs all hashes", "pin_ok(C,I,Slot) :- pin(C,Slot,H), runs(I,S), part(S,Slot,H).",
     "pin_ok(C,I,Slot) :- pin(C,Slot,_), invocation(I), runs(I,S), part(S,Slot,H), pin(C,Slot,H), not pin_miss(C,I,Slot).\npin_miss(C,I,Slot) :- pin(C,Slot,H), runs(I,S), not part(S,Slot,H)."),
    ("copies always followed", "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), follows(G,K).",
     "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), follows(G,K).\nin_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,copy)."),
    ("attribution by content", "", "acts_for(I,P) :- runs(I,S), runs(I0,S), acts_for(I0,P), I != I0."),
    ("swap discharges", "", "ended_by(C,T) :- commitment(C), swap(I1,I2), at(I2,T0), time(T), T >= T0."),
    ("rewrite discharges", "", "ended_by(C,T) :- commitment(C), rewrite(I1,I2), at(I2,T0), time(T), T >= T0."),
    ("achieve needs every branch", "fulfilled(C,T)  :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T).",
     "fulfilled(C,T)  :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T), not branch_missing(C).\nbranch_missing(C) :- mode(C,achieve), bound(C,P,_), acts_for(I,P), edge(_,I,copy), not performs(C,I,_)."),
    ("avoid only by continuation", "violated(C,T)   :- mode(C,avoid), performs(C,_,T).",
     "violated(C,T)   :- mode(C,avoid), performs(C,I,T), not edge(_,I,copy)."),
    ("no excuse by creditor", "excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), acts_for(I,A,Q).", ""),
    ("role bound to creator", "bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), fills(P,R,T1,T2), T1 <= T, T < T2.",
     "bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), created(C,I), acts_for(I,P)."),
    ("role limited by filler", "valid_creation(C) :- created(C,I), debtor(C,R), role(R), content(C,A), acts_for(I,A,R), not grant(C).",
     "valid_creation(C) :- created(C,I), debtor(C,R), role(R), content(C,A), acts_for(I,A,P), fills(P,R,_,_), not grant(C)."),
    ("standing changes binding", "bound(C,P,T) :- detached(C,T), debtor(C,P), principal(P).",
     "bound(C,P,T) :- detached(C,T), debtor(C,P), principal(P), standing(P)."),
    ("machines always stand", "standing(P) :- kind(P,machine), hyp(machine_party).", "standing(P) :- kind(P,machine)."),
    ("no warranty of authority", "answerer(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M), standing(M), debtor(C,P), M != P.", ""),
    ("secured without answerer", "secured(C) :- reparation(C,C2), answerer(C2,_).",
     "secured(C) :- reparation(C,C2)."),
    ("bond includes self-reparation", "bond(C,C2) :- reparation(C,C2), debtor(C,P), debtor(C2,Q), P != Q.",
     "bond(C,C2) :- reparation(C,C2)."),
    ("no repair", "repaired(C,T) :- violated(C,T0), T0 <= T, reparation(C,C2), fulfilled(C2,T).", ""),
    ("reparation always detached", "detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 < T.   % strictly later: time-stratified",
     "detached(C,T) :- live(C,T), trigger(C,C0)."),
    ("no info flow on merge", "knows(I2,X) :- knows(I1,X), edge(I1,I2,_), not scrubbed(I2,X).",
     "knows(I2,X) :- knows(I1,X), edge(I1,I2,K), K != merge, not scrubbed(I2,X)."),
    ("no attested scrub", "scrubbed(I,X) :- runs(I,S), clean(_,S,X).", ""),
    ("assurance by lineage not content", "supports(E,I,N) :- refrains(E,N), invocation(I), runs(I,S), test(E,_,_), not slot_mismatch(E,S),",
     "supports(E,I,N) :- refrains(E,N), invocation(I), runs(I,S), test(E,_,_), runs(I0,S0), test(E,S0,_), ancestor(I0,I),"),
    ("no human decay", "fresh(E,T) :- issued(E,T0), horizon(E,H), time(T), T >= T0, T < T0 + H.",
     "fresh(E,T) :- issued(E,T0), horizon(E,H), time(T), T >= T0."),
    ("absent slot is match", "slot_mismatch(E,S) :- test(E,S0,Slot), part(S0,Slot,H), substrate(S), not part(S,Slot,H).",
     "slot_mismatch(E,S) :- test(E,S0,Slot), part(S0,Slot,H), part(S,Slot,H2), H != H2."),
    ("overcommit ignores exclusivity", "act_obj(A1,O), act_obj(A2,O), exclusive(O), bound(C1,P,T), bound(C2,P,T).",
     "act_obj(A1,O), act_obj(A2,O), bound(C1,P,T), bound(C2,P,T)."),
    ("rollback not detected", "rollback(I) :- runs(I,S), ancestor(I0,I), runs(I0,S), edge(I1,I,_), runs(I1,S1), S1 != S.", ""),
]


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True).returncode == 0


def main():
    core = (HERE / "core.lp").read_text()
    survivors = []
    for name, old, new in MUTANTS:
        if old and old not in core:
            print(f"?? {name}: pattern not found")
            survivors.append(name)
            continue
        mutated = core.replace(old, new) if old else core + "\n" + new + "\n"
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            shutil.copytree(HERE, d, dirs_exist_ok=True,
                            ignore=shutil.ignore_patterns("__pycache__", "target"))
            (d / "core.lp").write_text(mutated)
            killed = (not run([sys.executable, "run.py"], d)) or (not run([sys.executable, "props.py", "60", "7"], d))
        print(f"{'killed ' if killed else 'SURVIVED'} {name}")
        if not killed:
            survivors.append(name)
    print(f"{len(MUTANTS) - len(survivors)}/{len(MUTANTS)} mutants killed")
    return 1 if survivors else 0


if __name__ == "__main__":
    sys.exit(main())
