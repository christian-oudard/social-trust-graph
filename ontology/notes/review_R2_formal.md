# R2: formal-methods review of ontology/spec (core.lp v0.1)

Workspace: `reviews/r2work/spec` (a copy of the repo; the repo itself was not modified).
- `rv/f*.lp`: probe scenarios. `rv/reg/r*.lp`: the same probes as expect/reject regression scenarios.
- `rv/show.py`, `rv/runreg.py`: runners. `rv/strat.py`: SCC and negation analysis. `rv/bounds.py`: bounded checks.
- `rv/c6_pin_attenuation.lp`: a proposed new exhaustive check.
- `core.orig.lp` and `core.fixed.lp` (diff in `rv/core.fix.diff`); `types.fixed.lp` (diff in `rv/types.fix.diff`).

Baseline: `run.py` passes 12/12, props pass, and mutants kill 32/32. Every scenario has exactly one answer set under both hypotheses.

## A. Wrong verdicts (reproduced; each has a regression file that FAILS on the original core and PASSES on the fixed one)

| # | Sev | Finding | Repro | Fix |
|---|---|---|---|---|
| A1 | HIGH | **Pins do not attenuate.** An agent under a grant pinned to w1 that holds `delegate` can issue an unpinned sub-grant to its own lineage, or to a sibling copy. The agent keeps acting for the principal after a swap to w2, which defeats L3 ("consent pinned to a model lapses on swap"). This is S4 with one more fact: `gsub2` created by `a2`, rooted at `a2`, then makes `c5` valid. Two further paths exist: sibling copies (g=2) and laundering through a third lineage (g=3). | `rv/reg/r1_pin_bypass.lp`: `g1` pinned to w1 with delegate. `x1` creates `g2(root x1, no pin)`. `x2` runs w2. Actual: `covered(g2,x2)`, `valid_creation(c)`. Expected: `ultra_vires(c)`. | `pin_taint(G,I) :- pin(G,_,_), covered(G,I0), ancestor(I0,I), off_pin(G,I).` `pin_taint(G2,I) :- parent_grant(G2,G1), pin_taint(G1,I).` `off_pin(G2,I) :- parent_grant(G2,G1), pin_taint(G1,I).` S4's delegation to an unrelated sub-agent is still allowed. |
| A2 | HIGH | **Merge hijack.** Bob's pipeline declares `edge(n1,m2,merge)` from an invocation of Alice's agent whose grant follows merge (as `gn` in s5 and `gm` in world.lp). Bob's `m2` then acts for Alice with full scope and can bind her to pay Bob. C4 passes because m2 is "reachable". | `r5_merge.lp`. Actual: `acts_for(m2,pay,alice)`, `defection(c,alice,6)`. | Merge carries knowledge but not authority: `in_lineage(...,K), K != merge`, plus merge only when the continue-parent is already in the lineage. **No scenario, check, prop or mutant depends on merge authority**: dropping it entirely leaves everything green. |
| A3 | MED | **Role powers ignore revocation and pins.** The role `acts_for/3` rule never checks `live(G,T)` or `off_pin`. A charter power revoked at t1 still validates role commitments at t3. | `r2_role.lp`. Actual: `valid_creation(al)`. | Add `live(G,T), not off_pin(G,I)` to the role `acts_for` rule. |
| A4 | MED | **One repair covers all future breaches.** `repaired(C,T)` only asks that some violation precede T and that the reparation is fulfilled. An avoid commitment breached at 2, repaired at 4 and breached again at 6 leaves the debtor `in_good_standing` forever. | `r3_repair.lp`. Actual: `in_good_standing(alice,7)`. | `repaired_at(C,T0,T)` keyed to each breach, with the reparation performed after T0. `open_defection` uses `not repaired_at(C,T0,T)`. |
| A5 | MED | **Reparation chains of depth 2 or more never restore standing.** In a chain k ⊗ r1 ⊗ r2 with r2 fulfilled, `open_defection(bob,·)` stays set forever. | `r3_repair.lp` | `repaired_at(C,T0,T) :- violated(C,T0), reparation(C,C2), violated(C2,T2), T0<T2, repaired_at(C2,T2,T).` |
| A6 | MED | **An acceptance before the offer detaches it.** `does(b1,acc)` at t1 detaches an offer created at t5, so Alice violates at 8. | `r4_accept_before_offer.lp` | Require `start(C,Ts), Ts <= T0` in the act-trigger rule. With `Ts < T0`, the existing mutant "offers detach on anyone's act" survives, because s5 tests it only with a same-step acceptance. |
| A7 | MED | **Silent horizon truncation breaks L8.** A person's own continuing body invocation at t=13 (horizon 12) gives `orphan(a1,pay)`, `ultra_vires(c)` and `unanswerable(c)`. | `rv/f5_horizon.lp` | Add `type_error(35) :- at(I,T), not time(T).` The checks also need `horizon > n`. |
| A8 | LOW-MED | **Co-fillers share blame.** Two concurrent fillers of a role both get `defection` for an avoid breach committed only by one of them. | `r2_role.lp`: `defection(nf,bob,3)` | An avoid defection attaches to the filler whose invocation performed the act. |
| A9 | LOW-MED | **Revoking a redundant grant kills a sub-grant.** A sub-grant has every covering grant of the creator as a parent, including one with no delegate power. Revoking an unrelated spam-only grant makes a valid pay sub-grant fail. | `r6_multiparent.lp` | Add `delegator(G1)` to `parent_grant`. |
| A10 | LOW | **founded+created is allowed.** A grant can be `ultra_vires` yet `in_force` and covering. It is the only source of `parent_grant` cycles and self-loops, which C2 and C3 silently filter with `G2 != G1`. | `f7`, `f8` | `type_error(34) :- founded(C,_), created(C,_).` |
| A11 | LOW | **Vacuous deadlines.** A deadline at or before creation, or creation at the horizon, makes a commitment silently vacuous. props.py generates such worlds routinely: as a type_error, this fails every property on its first trials. | `f4` | Add as a lint, not a type error. |
| A12 | LOW | **Role answerers include every past and future filler.** `answerer(k,alice)` for a duty founded after she left, so `unanswerable(k)` is false while `unanswered_breach(k,8)` holds. A vacant role with person debtors gives `unanswerable`, contradicting L8's "only from machine debtors". | `f10` | Restrict to fillers whose tenure overlaps the commitment's life. |
| A13 | LOW/design | **Warranty-of-authority answerers have no deontic effect.** No violation or defection follows: `in_good_standing(vendor,12)` in s4. `secured(c3)` is vacuous because an ultra vires c3 can never be violated. `unanswerable(r3)` is flagged for a reparation that never triggers. Fulfilment never ends `bound`, although README L3 lists fulfilment as an ending (`bound(sale1,dana,12)`). | s3, s4 | Document or model. |

Checked and fine:
- A commitment whose creator's grant was created later is `ultra_vires`. Ratification is not retroactive, which is a design choice worth stating.
- Overcommitment against a released commitment behaves sensibly. `overcommitted` is untimed, and a mutant that ignores simultaneity survives.

With all fixes applied (`core.fixed.lp` and `types.fixed.lp`), full `./check.sh` passes: 12/12, props 200/300 trials, mutants 32/32. Two mutant patterns in `mutants.py` had to be updated to the new rule text. All regression files pass under both hypotheses.

## B. Stratification

`rv/strat.py` (clingo AST, predicate SCCs) finds exactly two SCCs with internal negation.

1. `{live, ended_by, parent_grant, covered, acts_for, within, scope, valid_creation, can_delegate}` contains the negative edge live→ended_by.
   - The path back is ended_by(G2,T) → parent_grant(G2,G1) → covered(G1,I) → live(G1, at(I)), with `at(I) < T`.
   - It is broken by time. The `T > T0` guard is semantically redundant: ended_by is monotone in T, and live(G1,T0) excludes ended_by(G1,T≤T0). A mutant that drops the guard survives.
   - Caveat: parent_grant, valid_creation, scope, within and excused are untimed. A per-step fold must stamp them with the creator's `at` time. The "per-step" claim holds only under that implicit indexing.
   - Grant-chain depth adds only positive recursion.
2. `{violated, fulfilled, performs, bound, detached}` contains the negative edge violated→fulfilled.
   - It is broken only by the strict `T0 < T` in the commitment-trigger rule. A mutant `T0 <= T` survives, so the load-bearing stratification guard is untested.

No cycle relies on anything other than time. The fixes keep this property. However, FIX-A (and a negation-based merge fix, which I rejected) makes uniqueness depend on forward edges (type 14). `types.lp` reports type errors but does not enforce them, and with a backward edge the negation-based merge variant gave 2 answer sets. There are no unsafe rules. Grounding is near-linear: a props world of 300 invocations has about 75k atoms and grounds in 0.14s.

## C. Bounds

C1–C5 stay UNSAT at the following bounds (witnesses are SAT):

| n | g | k | horizon | Max solve time |
|---|---|---|---|---|
| 4 | 3 | 3 | 5 | ≤0.1s |
| 5 | 3 | 3 | 6 | ≤0.1s |
| 6 | 4 | 4 | 7 | ≤0.2s |
| 8 | 5 | 4 | 9 | 2.6s |

The bounds can be raised for free.

The bounds are not the weakness. The properties and the generator are:
- world.lp has no roles, reparations, triggers, founded ordinary commitments, learning, person-lineage continuation, cross-principal merges or `all` sub-grants. So L7, L9 and L10 get no exhaustive coverage.
- C2 and C3 reuse the core's own `parent_grant`, which makes them circular.
- C4 checks reachability along any edge, ignoring follows and pins.

Proposed `rv/c6_pin_attenuation.lp`:
- On the original core it is SAT at n=3, g=2.
- A first, creator-descendants-only fix passed at g=2 with a creator-rooted property, but failed at g=3 (a laundering chain) and on sibling copies. **This is a concrete law violation that needs g≥3.**
- The final FIX-A is UNSAT up to n=6, g=4.

## D. Tag audit

- **L1** (C4 S5 P2): P2 tests only "content never matters without pins". C4 ignores follows, pins and scope. A2 satisfies L1 literally and violates its intent.
- **L2**: definitional, so not falsifiable by the tests.
- **L3**: C3 omits fulfilment and expiry, which the core does not implement either. P3 tests non-retroactivity rather than stickiness.
- **L6**: act-scope only. Pins and follows are not attenuated (A1).
- **L7**: tested by S5 only.
- **L9**: tested by S1 only, and by nothing except a label. `bond/2` has no operational consequence: `repaired` ignores it. A reparation owed by a custodian (vendor) whose grant covers the drifted lineage counts as a "bond" but is not drift-invariant.
- **L10**: tested by S6 only. It misses A3 and A8, and the filler-tenure guard in role `acts_for` is untested.

Extra mutants that survive the whole suite:
- live starting at the creation step;
- same-step acceptance or reparation;
- merge carrying no authority;
- dropping `answered_breach` via `secured`;
- role tenure ignored;
- `unaudited_exposure` ignoring pins;
- `overcommitted` without simultaneity.
