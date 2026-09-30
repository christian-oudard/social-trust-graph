# R3: adversarial review of the coordination ontology v0.1

Reviewer stance: mechanism design, security and contract law. I read the README, `spec/core.lp`, `types.lp`, the seven scenarios, checks C1–C5 and the legal and identity surveys. I made no changes to the repository. Every exploit below marked **[run]** is a clingo scenario in the scratch copy (`r3work/x/*.lp`). In those files, `expect`/`reject` state what the exploit achieves, and every one of them was confirmed against the unmodified `core.lp` under both hypotheses. `r3work/spec/core_patched.lp` sketches fixes for three of them (see §4).

Legend:
* (a) the current rules handle it correctly;
* (b) the ontology can express it, but the rules do not handle it;
* (c) the ontology cannot express it.

Severity is Critical, High, Medium or Low.

## 0. One root cause

L1 routes every act through `acts_for`. But the facts that **change the registry** bypass it entirely:

* `edge` (fork, merge, continue);
* `revoked`, `released`;
* `founded`;
* `fills`;
* `clean`, `test`, `record`.

These are bare base facts, with no author, no invocation, no notice time and no scope check. Most of the exploits below are one attack on this gap: *write, or deny, a registry fact that nobody answers for*. So the most useful single change is one rule: **every registry mutation is an act.** It is performed by an invocation, attributed via `acts_for`, and dated at that invocation's `at`. This sharpens the primitives already there (act, invocation, grant scope); it does not add new ones.

## 1. Lineage and attribution

**E1. Stolen or simulated copy binds its victim.** Severity: Critical. Category: (c), because edges have no author. **[run]** `x1_stolen_copy.lp`

* Dana's grant `gd` follows `copy`.
* A thief records `edge(d1,thief,copy)` and runs the same content.
* The thief's promise to pay 900 is `valid_creation`, and Dana defects at its deadline.

The same attack works in the other direction:

* Dana copies Bob's open agent. Bob's grant follows copy, so every act of the copy is `excused` against Dana's NDA with Bob.
* Or Dana merges a fragment of Bob's agent log into her own agent (`edge(b2,d3,merge)`). Bob's grant follows merge, so Dana's agent acts for Bob, and her data sale is excused.

The line between the s5 "simulation" (no edge, so no attribution) and a "copy" (edge, so attribution) is only whether somebody wrote down an edge. Content cannot tell them apart. So L1 ("never content") pushes all the weight onto an unattested relation.

Conversely, a principal can **repudiate** real edges ("that branch was stolen") and escape whatever its branches did.

**Fix:**
* Add the base fact `spawned(I2,X)`, meaning invocation X made the copy or merge.
* Follow a copy or merge edge only if `covered(G,X)`, i.e. the fork act is in the grant's own coverage.
* For repudiation: take an edge as in the record only when the parent side's custodian has logged it (the fork-consistency log from survey C). An unlogged edge can burden only the party that failed to log it.

Tested in `core_patched.lp`: the thief and the merge-in are no longer covered, and s1, s2 and s5–s7 still pass.

**E2. Fork-and-disown ("extract without accountability").** Severity: Critical. Category: (b). **[run]** `x2_fork_disown.lp`

* Erin's grant does not follow copy.
* Her covered agent learns Q's secret under an NDA and an exclusivity promise, then spawns a copy.
* The copy `knows(e3,x)` (L7), discloses the secret to a rival and sells to the rival.
* Neither avoid commitment is violated. Under `delegate` both acts are `orphan`, and `in_good_standing(erin)` holds.

The same pattern appears in two places the scenarios treat as desirable:
* s5's Ola probe "can extract but not bind";
* s3's Erin copy.

This is the case L2 names as its own refutation condition: responsibility must be wider than authority for the same grant.

**Fix:** split `acts_for` into authority and answerability.

* Add a rule `spawn_liable(I2,P)`: X spawned I2, X acts for P, and I2 does not act for P. Propagate it down the uncovered descendants.
* Let avoid commitments be performed and `answered` through it.
* Keep authority unchanged: a spawned copy cannot *bind* P, but P answers for its acts, as a vicarious or negligent release.

Tested in `core_patched.lp`. The only scenario verdict that changes is the intended one, s3's `violated(kerin,2)`. The same rule should also make the spawner the warrantor for the copy's ultra vires promises (`offp` in s5).

**E3. Mere continuation / re-registration.** Severity: High. Category: (c), a known limit. **[run]** `x6_reregister.lp`

* v1 custodies the lineage. Its agent breaches, and the bond-less reparation defaults.
* A fresh org v2 founds a root grant on the very next continue-invocation, with the same content.
* v2 is in good standing, and v1 is an empty shell carrying the defection.

This escape costs nothing, because `in_good_standing` is **consumed by no rule**. Defection has no deontic consequence anywhere in the core.

**Fix (two rules):**
* `successor(P2,P) :- founded(G2,_), debtor(G2,P2), root(G2,I2), ancestor(I1,I2), covered(G,I1), debtor(G,P).` Open defections and unperformed commitments of P then extend to P2 jointly and severally. This is the Art. 137(3) backstop that survey D already recommends.
* A grant whose debtor has an open defection older than a cure window stops covering. That is an in-rem sanction on the lineage, and it gives good standing a consequence.

**E4. Dual agent.** Severity: High. Category: (b). **[run]** `x12_dual_agent.lp`

A marketplace agent covered by both buyer and seller with `all` scope excuses *every* avoid commitment between them. Its front-running is not a breach.

**Fix:** excuse only through a named, non-`all` scope, or through an explicit consent grant whose `allows` names the act. The current rule treats "the creditor could have done it" as consent.

## 2. Content, pins, evidence

**E5. Attenuation does not attenuate the range.** Severity: High. Category: (b), a real L6 bug. **[run]** `x10_pin_escape.lp`

* `gal` is pinned to w1, follows continue, and allows `delegate`.
* The agent issues `gself`, rooted at itself, with no pin and following copy and merge. It is `valid_creation`.
* After the swap `gal` lapses as designed, but `gself` still covers the swapped agent and its copies, so a 400 promise binds Alice.

Only `allows`/caps are intersected; pins, `follows` and root are not. Check C1 inspects act names only. A 10-line check `c6_range_attenuation.lp` finds a counterexample immediately.

**Fix:** intersect every dimension: pins are inherited, `follows` is intersected, and the unattenuated `all` root grant is exempt. s4's sub-agent on v1 then needs v1 in Alice's envelope. That is the right answer, since it is the GDPR sub-processor authorization rule.

**E6. Slot games.** Severity: High. Category: (b). **[run]** `x3_slot_games.lp`

* Adding a new slot (`adapter` = LoRA) and editing the prompt derives no `swap`.
* A weights-pinned consent still covers.
* A weights-only test still `supports`, so `assured(nx,a2)` holds.

`slot_mismatch` only checks slots the test fixed, and pins only check pinned slots. A new slot is invisible to both.

**Fix:** a closed-world substrate:
* declare a slot set per lineage;
* treat any undeclared or added slot as a mismatch for every test and pin;
* define `swap` as a change to any slot in a declared "material" set, not just `weights`.

**E7. Envelope product.** Severity: Medium. Category: (c). **[run]** `x11_envelope.lp`

Pins are a union within a slot and an intersection across slots. Consent to {(w1,p1),(w2,p2)} therefore also covers the untested (w2,p1). A huge envelope is the same as no pin.

**Fix (coalesce pins with evidence):** allow `pin(C,E)`, meaning "covered iff evidence E supports the invocation". The envelope then means *whatever passes E*, as in AI Act Art. 43(4).

**E8. Scrubbing without forgetting.** Severity: High. Category: (b). **[run]** `x4_scrub.lp`

* **Keep the knowledge out of hashed slots.** If it sits in a retrieval store or tool state, the content never changes. `scrubbed` then treats every successor as rolled back to pre-learning content, and disclosure is free.
* **Self-issued `clean(eself,snm,x1)`.** Evidence has no issuer, so the discloser can attest its own sanitization.

**Fix:**
* Content-based scrubbing requires an actual `rollback(I)` event, plus a closed-world substrate (E6).
* Evidence gets an issuer and becomes a *commitment*. An attestation is the issuer's avoid-warranty "no misattestation", ideally bonded. A creditor accepts it only from issuers its own grant names.

That second fix also covers tests "fresh on a different distribution". Make the test fix the `context` slot, with class hashes, so a context outside the tested class mismatches.

**E9. Pinned avoid is a debtor's exit.** Severity: Medium. Category: (c).

* A pinned *achieve* duty turns the debtor's swap into a breach (s2 `aud`).
* A pinned *avoid* warranty turns the swap into an escape (s2 `war`). The debtor controls when the swap happens.

The creditor cannot contract for "don't swap" or "don't fork", because change events are derived, not acts. The same gap removes any "don't fork" exclusivity clause.

**Fix:** derive `does(I2,change(Slot))` and `does(I1,fork)`, the same move as §0. Change events then become valid commitment content.

**E10. Surety moral hazard.** Severity: Medium. Category: (c).

s1's bond pays after an unconsented swap. Under R3d Suretyship §41 (survey D K13) that swap would discharge the surety. The bonded principal can then drift freely, with no subrogation back to it.

**Fix:** give bonds a trigger envelope. Pins on a reparation are read against the *violator* of the triggering commitment. Add a `reparation` back to the surety from the defector.

## 3. Resources, time, answerability

**E11. Caps are per act; forks double-spend.** Severity: High. Category: (c). **[run]** `x5_caps.lp`

Three 500 promises under a 500 cap are all valid. Two forks covered by a copy-following grant can spend at the same instant.

**Fix without aggregates:** make capacity an exclusive object. A grant carries k unit tokens `exclusive(tok(G,i))`, and each use consumes one. Generalize `overcommitted` to cover two acts over the same token, whatever the commitment mode. The same mechanism covers joint violation by colluding copies of any countable limit.

Aggregate *information* limits cannot be expressed this way: each session reveals one bit of a reservation price, a resettable-counterparty probe. Say so in §8.

**E12. Endings are unattributed.** Severity: High. Category: (b). **[run]** `x8_unattributed_endings.lp`

* **Revoking a non-grant.** `revoked` applies to *any* commitment, although the README says revocation is for powers only. So `revoked(nda,3)` discharges an NDA unilaterally. C3 accepts this because it also counts `revoked` as a legitimate ending.
* **Backdating.** Revocation "as of t1", entered after a t2 promise, voids that promise retroactively.
* **Release.** `released` does not say who released.

**Fix:**
* Revoke and release are acts, restricted to the grantor (for revoke, of a power) or the creditor (for release).
* A third party is affected only from `max(act time, notice)`. This is the lingering apparent authority of R3d Agency §3.11, as default reasoning.

**E13. Office vacancy and hand-off.** Severity: High. Category: (b). **[run]** `x7_role.lp`

* Vacancy: Alice leaves office at t5, and the charter duty is violated at t6 with *no* defector. The breach is unanswered under both hypotheses.
* Hand-off: a hand-off to a machine just before the deadline (s6) is answered only under `party`.

**Fix:**
* `fills` is an act of an appointing power.
* The appointer answers for an appointee without standing (subagency, §3.15).
* A vacant office's duties bind the last holder, or the charter's founder.

**E14. Standing without solvency; the party switch as a liability sink.** Severity: High. Category: (c). **[run]** `x9_shell_bond.lp`

* A shell org with no invocations "bonds" a machine's breach. `secured(k)` and `answered_breach(k,2)` hold, then the bond defaults at t8.
* Under `party`, machines with no assets become answerers, and every `orphan` or `unanswerable` flag in s3, s4 and s5 disappears. Turning the switch on hides exactly the escapes in E2 and E13.

L8's claim that it "only adds answerers" is true formally and misleading economically.

**Fix:**
* `answerer` requires *collectibility*: the reparation is backed by an escrowed exclusive token (E11), or by a bond from an answerer that itself has collectible backing.
* Report the switch's effect as the set of breaches it relabels.

## 4. Handled correctly (a)

* Rollback-and-retry leaves the first offer binding (s5b).
* A memory rewrite never discharges.
* Imputed knowledge is sticky.
* A simulation without an edge binds nobody.
* Revocation cascades.
* Cap attenuation on `allows`.
* Silence is not conformance, for *recorded* invocations. Unrecorded forks are simply absent, so `clear` needs a lineage-completeness attestation: a record lists the invocation's out-edges.

## 5. Top 3 for v0.2

1. **Registry mutations are acts** (E1, E8, E9, E12, E13). Edges get authors (`spawned`), and so do endings, appointments and attestations. Copy and merge edges are followed only when the fork is covered, and there is a notice time. This closes stolen-copy binding, merge-in excuse, backdating and self-attested sanitization.
2. **Responsibility ⊋ authority** (E2, E3, E4). Add `spawn_liable` for uncovered descendants, a successor rule for re-founded continuations, and consequences for open defection. This retires or rewrites L2.
3. **Range attenuation and a closed-world substrate** (E5, E6, E7, E8). Intersect pins and `follows` down sub-grants. Unknown slots mismatch. Scrubbing needs a real change. Pins may name evidence. Add check C6.

Next after that: capacity as exclusive tokens (E11), and collectible answerers (E14).
