# F3: formal-methods review, round 3 (core.lp v0.3)

**Snapshot.** The review covers v0.3, commit f44b42b, copied at 16:38 UTC. The repository was not modified. While this review ran, HEAD moved to v0.4 (b686a5d, 17:08). Every repro was re-run on b686a5d; the "v0.4" column records the result.

**Workspace.** All paths are under `reviews3/`.

| Path | Contents |
|---|---|
| `formal_work/rv3/{g,h}*.lp` | One probe per finding, as expect/reject scenarios |
| `formal_work/rv3/probe.py FILE HYP CORE preds…` | Evaluates a single probe |
| `formal_work/rv3/xc.py FILES` | Diffs clingo against Rust |
| `formal_work/rv3/bounds.py DIR n g k h checks…` | Runs checks at chosen bounds |
| `formal_work/rv3/strat.py` | Lists SCCs that contain negative edges |
| `formal_work/rv3/cex.py` | Dumps a counterexample world |
| `formal_work/spec/checks/c6..c9*.lp` | New independent exhaustive checks |
| `formal_work/rv3/fix.diff` | The fix: core, types, Rust, mutants and C3 |
| `fixed_tree2/` | The complete fixed tree, with `x7_*` regressions (15 files) |

**Baseline.** `./check.sh` passes: 17/17, props, 199/199 mutants, and 399 comparisons equal.

**With the fix (`fixed_tree2`).** `./check.sh` passes:

* 36/36 scenarios and checks, including c6 to c9 and the x7 regressions;
* props;
* 222/222 mutants, with 12 new R3 mutants;
* 504 comparisons equal, and `crosscheck --witness 10` gives 324 equal.

## A. Wrong verdicts

| # | Sev | Finding (repro) | Expected / actual | Fix (tested) | v0.4 |
|---|---|---|---|---|---|
| R1 | HIGH | **Vitiation is defeated by a self-granted root.** A power's root can be any invocation, so Bob roots a spam-only grant at Alice's agent a1 and then injects it. a1 "acts for" Bob, so it is not vitiated, and it validly promises Bob 900 in Alice's name (`g1_selfroot_vitiation`). | Expected: `vitiated(a1)`. Actual: `valid_creation(c)`, `defection(c,alice,5)` | `vitiated(I) :- induced(I,Q), acts_for(I,P), P != Q.` Residual: a stranger's root at Alice's agent can now void Alice's self-steered acts. A per-principal `vitiated_for(I,X)` is cleaner | Fixed: shared roots need `operator` (type 67) |
| R2 | HIGH (L8) | **The same hole is hypothesis-dependent.** Machine m injects Alice's agent. Under party, m can create a grant rooted at a1 (actor cannot), so Alice's promise to Bob binds only under party. P1 never generates `induced` (`g2_l8_machine_inject`). | L8 requires the same result under every hyp. Actual: `defection(c,alice,5)` under party only | R1 | Changed, not fixed: v0.4 voids only acts that favour the steerer, so an accomplice steerer (m, Carol) makes Alice's promise to Bob bind under **every** hyp |
| R3 | HIGH (L2) | **Swap-and-disown, continue-and-disown.** Answerability passes along copy edges but not continue edges. Two cases: (1) Alice's pinned agent swaps itself (her own act) and the w2 continuation sells: `orphan`, and Alice stays in good standing (`h4`). (2) A grant that follows only `copy` sheds its root's plain continuation (`h4c`). The copy variant is caught. | Expected: `answers_for(a2,alice)`, `violated(nda,2)`. Actual: nobody answers | `spawn(I1,I2) :- edge(I1,I2,continue), not external(I2), not owned(I2).` | Fixed (operator follows continue) |
| R4 | MED | **An injected copy is the victim's.** Copying is a registry act, but `vitiated` never guards `spawn`. Bob injects a1 into copying itself to b1, and Alice answers for all of b1's conduct (`g3`). | Expected: b1 is Bob's. Actual: `defection(nda,alice,3)` | `spawn(...copy), not vitiated(I1)` and `resp_only(I2,Q) :- edge(I1,I2,copy), vitiated(I1), induced(I1,Q), not acts_for(I2,Q).` | **Still present**: op passes to the copy via its changer |
| R5 | MED | **`until` misses external drift.** The swap is `does(J,swapping)` by the changer J, and `in_range` tests J rather than the swapped lineage. So "consent until the model is swapped" survives a vendor retrain (`changed_by`), which is the canonical drift case in the README §5 table (`g4`). | Expected: `ended_by(cb,4)`, `violated(nb,5)`. Actual: permitted forever | `content_act(I1,I2,swapping) :- swap(I1,I2).` (and `rewriting`), plus an `ended_by` rule over `content_act` and `external(I2)`, in range at I1 | **Still present** |
| R6 | MED | **`until` never fires for offices.** `in_range` needs `answers_for(I,R)`, which never holds for a role. Role powers have no root, so `in_lineage` fails too (`g7`). | Expected: `ended_by(nt,3)`. Actual: `violated(nt,5)`, `defection(nt,alice,5)` | `in_range(C,I) :- not scoped(C), debtor(C,R), role(R), holder(R,P,T), at(I,T), answers_for(I,P).` | **Still present** |
| R7 | MED (L10, L8) | **An office breach by the holder's copy is nobody's.** The avoid-defection rule for roles needs `acts_for(I,P)`, but performs uses `answers_for`. The result is `unanswered_breach` with a person holder (`h3`). C5 is blind to this: its "unanswerable" holds by definition for person debtors. | Expected: `defection(nt,alice,3)`. Actual: `unanswered_breach(nt,3)` | Replace `acts_for(I,P)` with `answers_for(I,P)` in that rule | **Still present** |
| R8 | MED (L7) | **Sanitization ignores the target.** A lab warranty "w1 never discloses x to **Carol**" cuts all knowledge of x. The model's derived disclosure to Bob vanishes, so Alice's NDA with Bob is never breached and nobody answers. When the leak is recorded, the NDA breaks but the warranty does not, so "its attester answers for a leak" is false (`g8`, `g8b`). | Expected: `violated(nda,2)`. Actual: nothing | `sanitized ... not partial(W,X)`, with `partial(W,X)`: W's content does not cover every disclosure act of X | **Still present** |
| R9 | MED (L9) | **A security answers for everything.** `conduct_of` via `secures` makes the holder's in-scope acts the grantor's. With scope `all`, Bob spamming breaches Alice's promise to Carol, and Bob selling makes Alice breach the NDA it secures (`g5`). | Expected: performance only. Actual: `defection(nosp,alice,4)` | Drop that `conduct_of` rule. Add `performs(C,I,T) :- mode(C,achieve), bound(C,P,T), content(C,A), does(I,A), at(I,T), secures(I,A,P), not off_pin(C,I).` | Fixed |
| R10 | MED (L9) | **A security is dead on arrival** if an earlier breach was repaired before it was given. `ended_by` fires on any `repaired(C,_,T1)` (`g6`). | Expected: `covered(gcol,bob7)`. Actual: `ended_by(gcol,3..)` | `repaired(C,T0,T1), start(G,Ts), not repaired(C,T0,Ts)` | Fixed (dormant between breaches) |
| R11 | MED, **crosscheck disagrees** | **Succession reads the future.** Recognition at t0 over a root at t5, with a custodied ancestor at t3: clingo gives `open_defection(m,1..2)`, before that lineage exists. This is a P3 (history) violation. Rust says `in_good_standing(m,1)` (`h1`). | Timed from max(recognition, root) | A `succ_at(G,T)` helper with two rules | Fixed (edge-based succession) |
| R12 | LOW-MED | **A stale citation is a *type* error.** Type error 62 is dynamic: citing a proof revoked before creation fails the world instead of making it `ultra_vires`. The generators then prune every such world (`:- type_error`). Making 62 static uncovers a **C1 counterexample** at 7/4/4/9: a mis-cited grant is valid with no parent, so it has no scope and inherits no follows or pins (`h7`). | Expected: `ultra_vires`. Actual: ill-typed | Make type 62 static (same-debtor power), plus `bad_cite(G) :- under(G,G1), not candidate_parent(G,G1).` in `valid_creation` | **Still present** |
| R13 | LOW, **crosscheck disagrees** | **`until` has no start guard**, unlike act triggers. Rust evaluates `in_lineage` before the parent is known and emits `ended_by(g2,3..5)`. Semantically, an until act before creation kills the commitment on arrival (`h2`). | Only acts after the start count | `start(C,Ts), Ts <= T0` in both until rules | **Mismatch still present** |
| R14 | LOW, **crosscheck disagrees** | **Rust `in_range` misses the horizon step.** Only `answers_for_h` is emitted (`h6`). | | `in_range_out` in Rust | Fixed |
| R15 | LOW | **A changer can act after the change.** `changed_by(I2,J)` accepts J after I2, so a t9 vendor act breaches a no-swap duty through a swap at t2 (`g9`). | | `type_error(64) :- changed_by(I2,J), at(I2,T2), at(J,TJ), TJ >= T2.` | **Still present** |
| R16 | MED (design) | **Messaging a party makes you answer for it forever.** One feed into a recognized machine party m (`owned` ignores machine principals) makes Alice answer for all of m's future lineage, under actor and party too, where m answers itself (`h5`). | | Not applied. `owned` could use `standing`, which trades against L8 bullet 1 | Fixed |

## B. Time-stratification

v0.3 has one SCC of 34 predicates with 14 negative edges. These are new since v0.2:

* `ended_by→acts_for`, `ended_by→vitiated`, `holder→vitiated`
* `valid_creation→vitiated`, `vitiated→acts_for`
* `spawn→owned`, `resp_only→acts_for`

Each is broken by time: the acting invocation is strictly earlier (T > T0), or the dependency is on the same invocation, which is fixed before its effects start at T+1. The only relation that reads the future is `continuation_of` (R11).

The fix adds these negative edges, all static or earlier:

* `spawn→vitiated` (I1 is earlier)
* `ended_by→repaired` (Ts < T)
* `sanitized→partial` (static)
* `valid_creation→bad_cite→candidate_parent` (at the creation step)

## C. Laws against the new checks (original core, n5 g3 k3 h7, each condition run alone)

| Law | Check | Result |
|---|---|---|
| L2 | c6 | copy law holds. **CEX**: self-change disown (R3), steered creation (R1), unanswered breach (R7) |
| L7 | c7 | flow holds. **CEX**: hidden leak (R8) |
| L9 | c8 | **CEX**: killed security (R10), overreach (R9) |
| L10 | c9 | role powers hold. **CEX**: no defector (R7), until (R6) |

At raised bounds on the original core, C1, C3, C4 and C5 are UNSAT at 6/4/4/8 and 8/5/4/10 (≤33 s). On the fix, all 8 checks are UNSAT at 7/4/4/9.

Weaknesses of the existing checks:

* C3 restates `ended_by` rule for rule, so it cannot catch R5, R6 or R10.
* C5 is near-tautological.
* Type-error pruning hides R12.
