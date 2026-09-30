# F: formal-methods review, round 2 (core.lp v0.2)

Workspace: `reviews2/formal_work/spec`. The repository was not modified.

Note: the repo core.lp was rewritten to v0.3 (16:21 UTC) while this review ran; all findings are against the v0.2 snapshot copied at the start.

| Path | Contents |
|---|---|
| `rv/f*.lp` | Probes, one per finding |
| `scenarios/x5*.lp` | The same probes as expect/reject regressions. Each one fails on v0.2 and passes on the fix |
| `rv/core.orig.lp` | The v0.2 core as reviewed |
| `rv/core.fix.diff`, `rv/types.fix.diff` | The fix, against the core and the types |
| `rv/main.fix.diff` | The matching change to the Rust port |
| `rv/mutants.fix.diff` | Mutant patterns updated to the new rule text, plus 15 new mutants |
| `rv/probe.py FILE preds…` | Shows the chosen atoms and diffs clingo against Rust on one file |
| `rv/bounds.py n g k h [core] [checks]` | Runs the checks at raised bounds |
| `rv/mut2.py` | 30 extra mutants of the v0.2 rules |
| `rv/strat.py` | Predicate SCCs that contain a negative edge |

**Baseline:** `./check.sh` passes: 15/15 scenarios and checks, props, 61/61 mutants, and 333 crosscheck comparisons.

**With every fix applied:** `./check.sh` passes: 28/28, props, 76/76 mutants, and 372 crosscheck comparisons, all equal (see `rv/check_fixed.log`).

## A. Wrong verdicts (all reproduced; clingo and Rust agree unless noted)

| # | Sev | Finding | Repro | Minimal fix |
|---|---|---|---|---|
| F1 | HIGH | **A message is not knowledge.** `reverted` holds whenever the recipient's content equals an untainted ancestor, and `tainted` ignores feeds. So a stateless agent (same content on every call) never knows what it is sent. Nia's q2 negotiator is fed q1's secret and talks to q2: no disclosure, no breach. L7 ("flows along every feed") fails. **No scenario, check or prop uses `feeds`**, and the mutant that deletes the feed rule survives. | `x5g_feed` (f8). Actual: no `knows(i2,x)`, no `violated(conf,2)` | A feed is not cut on arrival: `knows(I2,X) :- knows(I1,X), feeds(I1,I2).` Taint is static: `tainted(I,X) :- feeds(F,I), tainted(F,X).` and `tainted(I2,X) :- tainted(I1,X), edge(I1,I2,_).` This also stops a live sanitization warranty from erasing messages as they arrive. |
| F2 | HIGH | **Responsibility flows through a third party's merge.** `resp_only` propagates along *any* edge. Bob's own agent merges from Erin's in-scope copy and sells, and this becomes Erin's breach (`defection(excl,erin,3)`). A promise Bob's agent makes to Bob in Erin's name also makes Erin warrant its authority (`f2b`). | `x5a_merge` | `resp_only(I2,P) :- resp_only(I1,P), edge(I1,I2,K), K != merge.` |
| F3 | MED | **A merge makes its source "swap".** `swap` and `rewrite` are defined over any edge, so a merge declared at t3 by Bob makes Erin's e1 swap at t1. That is a retroactive breach of Erin's "no swap" promise. | `x5b_merge_swap` | Add `edge(I1,I2,K), K != merge` to `swap` and `rewrite` |
| F4 | HIGH | **Fork-and-disown is back.** The guard `not acts_for(I2,P)` means that giving the in-scope copy any token grant (for example `allows(post)`) removes all responsibility. Erin's copy leaks and sells, both acts are orphans, and Erin stays in good standing. | `x5i_disown` | Drop the guard from both `resp_only` rules. Nothing else changes: the mutant that drops it survived v0.2's own tests. |
| F5 | MED | **An office holder's narrow agent exercises the whole charter.** The role rule needs only `acts_for(I,P)`, so a `post`-only agent of the treasurer binds her (through the office) to pay 900. This is an L2 scope escape. | `x5f_role_scope` | Require `acts_for(I,A,P)` in the role `acts_for` rule |
| F6 | MED | **Paying on request counts as not paying.** `excused(C,I) :- creditor(C,Q), induced(I,Q)` also blocks `performs` for *achieve*. When the creditor prompts the debtor's agent to pay, the payment does not count, and the debtor defects. | `x5c_induced` | Restrict the rule to `mode(C,M), M != achieve` |
| F7 | MED | **A warranty's own creditor can falsify it by injection.** `excused(wlab,a1)` is derived, but the warranty's `violated` rules ignore `excused`, so the attester defects. The same injection gives L2 "nothing" for promises. | `x5d_induced_warranty` | Add `not excused(W,I)` to both warranty `violated` rules |
| F8 | MED | **A security dies in the cascade.** The grantor cannot revoke the security itself, but can revoke the grant it was issued under (in s1, her own root `ga`). The cascade then ends `gcol` at t6, and Bob's execution fails. | `x5e_security_cascade` | Add `not security(G2)` to the cascade rule |
| F9 | MED | **A security outlives its purpose.** After the reparation is paid, the collateral stays detached and irrevocable forever: Bob executes Alice's payment again at t9 and t11. | `x5m_security_ends` (f15) | `detached(C,T) :- …, violated(C0,T0), T0 < T, not repaired(C0,T0,T-1).` This is time-stratified through T-1 |
| F10 | MED | **An errand becomes a succession.** `continuation_of` uses `acts_for(I1,P1)` under *any* power. A vendor's model that once ran a customer's one-off booking errand inherits every open defection of that customer once the vendor's root is recognized downstream. | `x5l_errand_not_succession` | Require the ancestor to be covered by a *recognized* grant of P1: `own_lineage(I,P) :- covered(G,I), grant(G), recognized(G,_), debtor(G,P).` |
| F11 | MED, **crosscheck disagrees** | **Successor liability is untimed.** v2 is out of good standing at t2, before the lineage was v1's and before v2 existed. Rust says `in_good_standing(v2,2)`. | `x5h_succession` | `succeeds(P2,P1,T2)` carries `at(I2,T2)`, with `open_defection(P2,T) :- succeeds(P2,P1,T2), T2 <= T, …` |
| F12 | MED, **crosscheck disagrees** | **Double creation.** `created(c,m1)` (invalid, t1) plus `created(c,a5)` (valid, t5) makes c live from t2 in clingo: Alice breaches at t3 a promise she makes only at t5. Rust makes it live from t6. No type error catches this. | `rv/f9_double_create.lp` | `type_error(56) :- created(C,I1), created(C,I2), I1 != I2.` |
| F13 | MED | **L6 is false at g=3.** C1 finds a counterexample at n=3, g=3, k=2 in 0.1 s. A sub-grant made by an invocation covered by two delegating grants takes the *union* of their caps, names and followed kinds, but the *intersection* of their pins and revocations. | `x5k_two_parents`: caps 2 and 3 give `valid_creation(c3)`. Also `rv/bounds.py 3 3 2 5` | Every ancestor's caveats hold: `anc_grant` closure, `eff_follows(G,K) :- follows(G,K), not follow_blocked(G,K)`, and `within(G,A) :- within0(G,A), not cap_blocked(G,A)`. It is time-stratified because ancestors are created earlier. In Rust it uses `scope_h`. After the fix C1 is UNSAT up to n=8, g=5, k=4 (17 s) |
| F14 | LOW-MED | **Office warranties are nobody's.** A warranty owed by a held office is falsified, and the result is `unanswered_breach`, while `answerer(w,al)` holds. | `x5j_office_warranty` | Add `defection(C,P,T) :- violated(C,T), mode(C,warrant), debtor(C,R), role(R), holder(R,P,T).` |
| F15 | LOW-MED (design) | **Warranting requires authority to do the warranted act.** `valid_creation` needs `acts_for(I,ex,lab)`, so an evaluator scoped to `attest` cannot warrant "w1 never exfiltrates". Its warranty is `ultra_vires`, and nothing answers for it. | `rv/f12_warranty_scope.lp` | Proposed, not applied: a separate `valid_creation` for `mode warrant`, scoped by an act `warranting` |
| F16 | LOW | **Other small issues** | See list below | See list below |

The small issues in F16:

* An *avoid* reparation is "performed" by breaking it, which yields `repaired(nda,2,4)` (`rv/f14`). Proposed fix: a type error for non-achieve reparations.
* `security` does not require the power to sit in the creditor's lineage. Fix: use the `collateral` test.
* `warranted_authority(fake,bob)` is owed to the warrantor himself.
* Once sanitized, knowledge never returns after the warranty expires.

## B. Time-stratification

Before the fix, one SCC holds 7 negative edges (`rv/strat.py`). All of them are broken by time, provided each commitment is created at most once:

* `covered` → `eff_off_pin`
* `eff_follows` → `parent_grant`
* `knows` → `scrubbed`
* `live` → `ended_by`
* `performs` → `excused`
* `resp_only` → `acts_for`
* `violated` → `fulfilled`

Double creation (F12) is the only input found that breaks the implicit "untimed = stamped at creation" assumption. `continuation_of` (F11) is the only derived relation that reads the future.

The fix adds four negative edges and removes `resp_only` → `acts_for`. Each new edge is broken by time:

* `within` → `cap_blocked` and `eff_follows` → `follow_blocked`: the ancestor is older.
* `violated` → `excused`: `excused` is same-step, and nothing below it depends on `violated` at that step.
* `detached` → `repaired`: this reads T-1.

Crosscheck remains weak on v0.2 machinery. Random worlds never generate feeds, induced, roles, warranties, securities, pin/4, recorded or successions. Clingo also runs without `types.lp`, so ill-typed input (a same-step edge or feed) shows up as a mismatch rather than a type error. **Recommendations:** add `x5*` and the check witnesses to crosscheck, and assert that there is no `type_error`.

## C. Bounds (C3, C4, C5 on v0.2; C1 on the fix)

| n g k h | C1 (v0.2) | C1 (fix) | C3, C4, C5 (v0.2) |
|---|---|---|---|
| 3 2 2 5 | unsat | unsat | unsat |
| 3 3 2 5 | **CEX** | unsat | unsat |
| 4 3 3 6 | **CEX** | unsat | unsat |
| 6 5 4 8 | n/a | unsat 7 s | unsat |
| 8 5 4 9 | n/a | unsat 17 s | unsat ≤1.4 s |

`world.lp` never generates a warranty, a security (its triggers are acts only), a feed, `induced`, pin/4 or `recorded`. So L4, L7 and L9 have no exhaustive coverage at any bound.

## D. Tag audit

`rv/mut2.py` adds 30 mutants of the v0.2 rules. **17 survive** v0.2's `run.py` plus props:

* `no info flow on feed`
* `sanitize w/o detachment`
* `carry violation off pin`
* `no induced excuse`
* `resp_only one hop`
* `resp_only ignores own grant` (this is F4's fix)
* `security any debtor`
* `delegating needs only owe`: the `empower` capacity is untested
* `scoped trigger by creditor`: human-in-the-loop approval is untested
* `assurance w/o standing`
* `warranty expires at deadline`
* `act trigger same step`: the act-trigger stratification guard is untested
* `role pin ignored`
* `permit ignores creditor`: the dual-agent fix is untested
* `cascade guard dropped`: redundant
* `continuation ignores other principal`: an equivalent mutant

By law:

| Law | Tags | Gaps |
|---|---|---|
| L2 | S3 S5 X1 X2 | Refuted by F2, F4 and F5. No exhaustive check exists |
| L3 | | The security and succession clauses are refuted by F8–F11. C3 cannot see them |
| L4 | | "The attester can answer" is untested |
| L6 | C1 | C1 is sound but runs at bounds just below the counterexample |
| L7 | | Feeds and sanitization expiry are untested |
| L8 | | Capacity `empower` is untested |
| L9 | S1 | Tested by S1 only. F8, F9 |
| L10 | | Role pins are untested. F5, F14 |
