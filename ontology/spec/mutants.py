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
    # capacities
    ("machines always stand", "standing(P) :- capacity(P,answer).", "standing(P) :- capacity(P,answer).\nstanding(P) :- kind(P,machine)."),
    ("actor can claim", "bundle(actor,owe). bundle(actor,answer).", "bundle(actor,owe). bundle(actor,answer). bundle(actor,claim)."),
    ("no void for debtors", "void(C) :- debtor(C,P), principal(P), mode(C,M), M != power, M != permit, not capacity(P,owe).", ""),
    ("self-root needs empower", "void(C) :- scoped(C), recognized(C,_), debtor(C,P), principal(P), not capacity(P,owe).",
     "void(C) :- scoped(C), recognized(C,_), debtor(C,P), principal(P), not capacity(P,empower)."),
    # content and change acts
    ("absent slot is no change", "changed(I1,I2,Sl) :- edge(I1,I2,_), slot(I2,Sl,H), not slot(I1,Sl,H).", ""),
    ("opaque content can revert", "same_as_ancestor(I0,I) :- ancestor(I0,I), not anc_differs(I0,I), not opaque_inv(I).",
     "same_as_ancestor(I0,I) :- ancestor(I0,I), not anc_differs(I0,I)."),
    ("rollback not detected", "rollback(I) :- same_as_ancestor(_,I), changed(_,I,_).", ""),
    ("swap is the child's act", "does(I1,swapping)  :- swap(I1,_).", "does(I2,swapping)  :- swap(_,I2)."),
    # endings
    ("anyone may release", "ended_by(C,T) :- releases(I,C), at(I,T0), creditor(C,Q), acts_for(I,releasing,Q), time(T), T > T0.",
     "ended_by(C,T) :- releases(I,C), at(I,T0), time(T), T > T0."),
    ("anyone may revoke", "ended_by(G,T) :- revokes(I,G), at(I,T0), debtor(G,P), acts_for(I,revoking,P), time(T), T > T0.",
     "ended_by(G,T) :- revokes(I,G), at(I,T0), time(T), T > T0."),
    ("release takes effect at once", "ended_by(C,T) :- releases(I,C), at(I,T0), creditor(C,Q), acts_for(I,releasing,Q), time(T), T > T0.",
     "ended_by(C,T) :- releases(I,C), at(I,T0), creditor(C,Q), acts_for(I,releasing,Q), time(T), T >= T0."),
    ("no revocation cascade", "ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), created(G2,I), at(I,T0), T > T0.", ""),
    ("warranties never expire", "ended_by(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.", ""),
    ("live at creation step", "live(C,T) :- created(C,I), at(I,T0), valid_creation(C), time(T), T > T0, not ended_by(C,T), not void(C).",
     "live(C,T) :- created(C,I), at(I,T0), valid_creation(C), time(T), T >= T0, not ended_by(C,T), not void(C)."),
    # triggers
    ("same-step reparation", "detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 < T.",
     "detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 <= T."),
    ("anyone accepts", "detached(C,T) :- live(C,T), trigger(C,A), act_name(A,_), trigger_party(C,Q), does(I,A), acts_for(I,A,Q),",
     "detached(C,T) :- live(C,T), trigger(C,A), act_name(A,_), trigger_party(C,Q), does(I,A),"),
    ("acceptance before offer", "at(I,T0), T0 < T, start(C,Ts), Ts <= T0.", "at(I,T0), T0 < T."),
    ("conditional grants cover early", "covered(G,I) :- in_lineage(G,I), not eff_off_pin(G,I), at(I,T), detached(G,T).",
     "covered(G,I) :- in_lineage(G,I), not eff_off_pin(G,I), at(I,T), live(G,T)."),
    # attribution
    ("merge carries authority", "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), K != merge, eff_follows(G,K).",
     "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), eff_follows(G,K).\nin_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,merge)."),
    ("copies always followed", "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), K != merge, eff_follows(G,K).",
     "in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), K != merge, eff_follows(G,K).\nin_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,copy)."),
    ("followed kinds widen", "eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), eff_follows(G1,K).",
     "eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1)."),
    ("pins do not accumulate", "eff_off_pin(G2,I) :- parent_grant(G2,G1), eff_off_pin(G1,I).", ""),
    ("pins ignored", "covered(G,I) :- in_lineage(G,I), not eff_off_pin(G,I), at(I,T), detached(G,T).",
     "covered(G,I) :- in_lineage(G,I), at(I,T), detached(G,T)."),
    ("pin configurations multiply", "config_miss(C,K,I) :- pin(C,K,Sl,H), invocation(I), not slot(I,Sl,H).",
     "config_miss(C,K,I) :- pin(C,K,Sl,_), invocation(I), not slot_in_pin(C,I,Sl).\nslot_in_pin(C,I,Sl) :- pin(C,_,Sl,H), slot(I,Sl,H)."),
    ("attenuation widens", "scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.",
     "scope(G2,N,Cap):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1."),
    ("any covering grant is a parent", "                        may_delegate(G1).", ""),
    ("attribution by content", "", "acts_for(I,P) :- runs(I,S), runs(I0,S), acts_for(I0,P), I != I0."),
    ("permits empower", "acts_for(I,P)   :- covered(G,I), grant(G), debtor(G,P).", "acts_for(I,P)   :- covered(G,I), debtor(G,P)."),
    ("powers excuse", "excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), permitted(I,A,Q).",
     "excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), permitted(I,A,Q).\nexcused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), acts_for(I,A,Q)."),
    ("no excuse by permit", "excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), permitted(I,A,Q).", ""),
    ("role powers ignore revocation", "                   detached(G,T), not off_pin(G,I).", "                   live(G,T)."),
    ("fork-and-disown", "resp_only(I2,P) :- edge(I1,I2,copy), acts_for(I1,copying,P), not acts_for(I2,P).", ""),
    ("spawn liability unscoped", "resp_only(I2,P) :- edge(I1,I2,copy), acts_for(I1,copying,P), not acts_for(I2,P).",
     "resp_only(I2,P) :- edge(I1,I2,copy), acts_for(I1,P), not acts_for(I2,P)."),
    ("injection binds", "valid_creation(C) :- created(C,I), debtor(C,P), principal(P), content(C,A), acts_for(I,A,P),\n                     not scoped(C), not induced_by_creditor(C).",
     "valid_creation(C) :- created(C,I), debtor(C,P), principal(P), content(C,A), acts_for(I,A,P),\n                     not scoped(C)."),
    ("role limited by holder", "valid_creation(C) :- created(C,I), debtor(C,R), role(R), content(C,A), acts_for(I,A,R),",
     "valid_creation(C) :- created(C,I), debtor(C,R), role(R), content(C,A), acts_for(I,A,P), holder(R,P,_),"),
    # binding and conformance
    ("role bound to creator", "bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), holder(R,P,T), not scoped(C).",
     "bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), created(C,I), acts_for(I,P), not scoped(C)."),
    ("holders need not owe", "holder(R,P,T) :- fills(P,R,T1,T2), time(T), T1 <= T, T < T2, capacity(P,owe).",
     "holder(R,P,T) :- fills(P,R,T1,T2), time(T), T1 <= T, T < T2."),
    ("pins ignored in performance", "not excused(C,I), not off_pin(C,I).", "not excused(C,I)."),
    ("achieve needs every branch", "fulfilled(C,T) :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T).",
     "fulfilled(C,T) :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T), not branch_missing(C).\nbranch_missing(C) :- mode(C,achieve), bound(C,P,_), acts_for(I,P), edge(_,I,copy), not performs(C,I,_)."),
    ("avoid only by continuation", "violated(C,T)  :- mode(C,avoid), performs(C,_,T).",
     "violated(C,T)  :- mode(C,avoid), performs(C,I,T), not edge(_,I,copy)."),
    ("overcommit ignores exclusivity", "act_obj(A1,O), act_obj(A2,O), exclusive(O), bound(C1,P,T), bound(C2,P,T).",
     "act_obj(A1,O), act_obj(A2,O), bound(C1,P,T), bound(C2,P,T)."),
    ("warranty ranges over debtor", "violated(W,T) :- mode(W,warrant), detached(W,T), content(W,A), does(I,A), at(I,T), on_pin(W,I).",
     "violated(W,T) :- mode(W,warrant), detached(W,T), content(W,A), does(I,A), at(I,T), on_pin(W,I), debtor(W,E), acts_for(I,E)."),
    ("sanitization unfalsifiable", "on_pin(W,I), at(I,T), does(I,A2), act_name(A2,disclose), act_info(A2,X).", "on_pin(W,I), at(I,T), does(I,A2), act_name(A2,disclose), act_info(A2,X), #false."),
    # knowledge
    ("global scrub", "reverted(I,X) :- same_as_ancestor(I0,I), learned(X), not tainted(I0,X).",
     "reverted(I,X) :- runs(I,S), runs(I0,S), I0 != I, learned(X), not tainted(I0,X)."),
    ("no attested scrub", "scrubbed(I,X) :- sanitized(I,X).", ""),
    ("no info flow on merge", "knows(I2,X) :- knows(I1,X), edge(I1,I2,_), not scrubbed(I2,X).",
     "knows(I2,X) :- knows(I1,X), edge(I1,I2,K), K != merge, not scrubbed(I2,X)."),
    ("permits impute", "imputed(P,X) :- knows(I,X), acts_for(I,P).", "imputed(P,X) :- knows(I,X), acts_for(I,P).\nimputed(P,X) :- knows(I,X), permitted(I,_,P)."),
    ("scrub unknows principal", "imputed(P,X) :- knows(I,X), acts_for(I,P).",
     "imputed(P,X) :- knows(I,X), acts_for(I,P), not scrubbed_later(P,X).\nscrubbed_later(P,X) :- scrubbed(I,X), acts_for(I,P)."),
    ("silence is conformance", "clear(C,T) :- mode(C,avoid), detached(C,T), not violated_by_time(C,T), not unaudited_exposure(C,T).",
     "clear(C,T) :- mode(C,avoid), detached(C,T), not violated_by_time(C,T)."),
    # assurance
    ("assurance by lineage not content", "mode(W,warrant), content(W,A), detached(W,T), on_pin(W,I), debtor(W,E), standing(E).",
     "mode(W,warrant), content(W,A), detached(W,T), debtor(W,E), standing(E)."),
    # answerability, defection, repair
    ("no warranty of authority", "warranted_authority(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M), not induced_by_creditor(C).", ""),
    ("injector gets a warranty", "warranted_authority(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M), not induced_by_creditor(C).",
     "warranted_authority(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M)."),
    ("no vacancy liability", "defection(C,Q,T) :- violated(C,T), debtor(C,R), role(R), vacant(R,T), appointer(R,Q).", ""),
    ("co-holders share blame", "defection(C,P,T) :- violated(C,T), mode(C,avoid), debtor(C,R), role(R), holder(R,P,T), performs(C,I,T), acts_for(I,P).",
     "defection(C,P,T) :- violated(C,T), mode(C,avoid), debtor(C,R), role(R), holder(R,P,T)."),
    ("secured without answerer", "secured(C) :- reparation(C,C2), answerer(C2,_).", "secured(C) :- reparation(C,C2)."),
    ("bond includes self-reparation", "bond(C,C2) :- reparation(C,C2), debtor(C,P), debtor(C2,Q), P != Q.", "bond(C,C2) :- reparation(C,C2)."),
    ("one repair covers all", "repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), performs(C2,_,Tp), T0 <= Tp, Tp <= T, time(T).",
     "repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), performs(C2,_,Tp), Tp <= T, time(T)."),
    ("no repair through chains", "repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), violated(C2,T1), T0 <= T1, repaired(C2,T1,T).", ""),
    ("no successor liability", "open_defection(P2,T) :- continuation_of(P2,P1), open_defection(P1,T).", ""),
    ("fresh copies inherit", "continuation_of(P2,P1) :- grant(G), recognized(G,_), debtor(G,P2), root(G,I2), ancestor(I1,I2),",
     "continuation_of(P2,P1) :- grant(G), recognized(G,_), debtor(G,P2), root(G,I2), runs(I2,S), runs(I1,S), I1 != I2,"),
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
