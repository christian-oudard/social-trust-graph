# M: Minimality review of v0.2 (core.lp at dc6d9ae)

Method: I worked in a copy (`reviews2/min_work`), never in the repo. Harness: `exp.py` / `combo.py` / `e*.py`.
"Passes" means `run.py` gives 15/15, `props.py 200 1` passes all four properties, and the mutants are rerun where the text allows it.
The Rust crosscheck was not run. Every change below needs the matching line deletions in `rust/src/main.rs`.

## 0. Headline: "every rule is mutation-tested" is false

The README says every rule is mutation-tested. `delsweep.py` deletes each of the 151 statements in core.lp one at a time. **21 deletions go undetected** (run.py + props 60):

| line | rule | claim left untested |
|---|---|---|
| 57, 64, 65 | one half of `changed` / `anc_differs` | slot removal (a half-symmetric-difference) |
| 73, 74, 77, 78 | `does(_,copying/merging/releasing/revoking)` | "don't copy without notice is an ordinary avoid"; nothing reads these `does` atoms, because `acts_for(I,copying,P)` never needs `does` |
| 94 | `void` for a created scoped instrument without `empower` | a machine granting under `actor` |
| 114 | `trigger_party` for scoped instruments | human-in-the-loop approval (v0.2 finding 13) |
| 121 | `start(C,T) :- recognized(C,T)` | recognized offers |
| 153 | `scope` when Cap <= Cap1 | a *narrower* sub-grant acting |
| 173 | transitive `resp_only` | responsibility down the copy's own lineage |
| 206 | `excused` by `induced` | **the fix committed today (dc6d9ae) has no regression test** |
| 225-228, 231 | `learned`, `tainted`, `reverted`, `scrubbed :- reverted` | L7's "forgetting by rollback" is never tested positively |
| 235 | `knows` via `feeds` | v0.2 finding 21, a pure accretion |
| 243 | `violated_by_time` | an audited violator is not clear |
| 261 | `answerer` = role holder | masked by the appointer |
| 285 | `answered_breach` via `secured` | untested |

Each one either gets a test or gets cut. Several of them are cut below.

## 1. Tried and passing: zero tested behaviour lost

Ranked by primitives removed per behaviour lost.

1. **E6. Delete the `merge` edge kind and use `feeds(I1,I2)`.**
   * A merge was already "knowledge, never authority". That is exactly what `feeds` is.
   * Removes: an edge kind, the `K != merge` guard, type_error 54, and the "merge carries authority" failure mode, which becomes structurally impossible.
   * It also makes `feeds` tested. The "no info flow on feeds" mutant is killed.
   * Side effect, untested either way: merges are no longer ancestors. So a lineage that merely received a merge no longer counts as a continuation, and `resp_only` stops flowing over merges. Arguably this is sharper.
2. **E1. Cut the capacities from 4 to 2** (`owe`, which absorbs answer, and `claim`, which absorbs empower). Also `standing` := `capacity(P,owe)`.
   * Under the three hypotheses, owe ≡ answer and claim ≡ empower *extensionally*. The bundle is a 3-point chain, so two of the four capacities are unfalsifiable names.
   * Keep four only if a fourth hypothesis separates them (for example, owe without answer).
   * Merging the `void` rules (E11) also passes: `void(C) :- debtor(C,P), principal(P), not capacity(P,owe).` plus the claim rule for created instruments. This drops the `M != power, M != permit` guard and one rule.
3. **E2. Derive `reparation` from `trigger`:** `reparation(C,C2) :- trigger(C2,C), commitment(C), not scoped(C2).`
   * Removes a base relation and type_error 45.
   * With every `reparation` fact stripped from the scenarios, the world generator and the props, everything still passes. A contrary-to-duty is just a breach trigger.
4. **E3. Drop forgetting by reversion** (5 rules and type_error 23). Afterwards `opaque_inv` is dead in core; only types.lp uses it.
   * This *sharpens* L3. Reversion was the one place where content equality entered deontics outside a pin.
   * New L7: only a sanitization warranty cuts knowledge. "Persons never forget" becomes true of everyone, and forgetting has to be warranted, so someone answers for it. That is consistent with "evidence is a warranty".
5. **E5. Sanitization becomes a plain warranty with content `disclose X`.**
   * Deletes the special `carry` violation rule (219) and the `carry` act convention. The general warranty rule already fires on an observed leak.
   * Caveat: the warranty is now per (info, target).
6. **E7. Delete the four dead `does(registry-act)` rules.** Keep swapping and rewriting, which are tested. Alternatively, test the claim.
7. **E4. `security(G) :- collateral(_,G)`.**
   * Restatement §3.12 wants the power held by the interest-holder, which is the creditor.
   * With E11 the `security` name goes too, and ended_by uses `not collateral(_,G)`. The only cost is the relabelled expectation `security(gcol)`.
   * `bond` and `collateral` are otherwise pure labels: nothing downstream reads them.

**Combined E1–E7:**

* 15/15 scenarios pass. All props pass at 200 trials.
* core goes from 151 to 142 statements. Removed: 1 base relation (`reparation`), 1 edge kind, 2 capacities, the `carry` convention, and 3 type_errors.
* Original mutants: 54 of 62 are killed. The other 8 are 6 whose pattern is gone and 2 now vacuous: "opaque content can revert" and "no info flow on merge".
* 9 adapted mutants: 7 are killed. 2 survive, and both are equivalent under the current tests:
  * a self-held security;
  * a scoped reparation.

## 2. Tried and not free

* **E10. `recorded` as a warranty** (clear := no violation and every exposure assured). It flips `clear(kh,1)`, because a character reference now counts as an audit, and it breaks `unassured(km,k2)`. That is two expectations lost. It is a real design choice, not a free cut. It would, however, remove the last evidence-like base relation.
* **E8. Strict attenuation**, where an over-asking sub-grant gets nothing instead of being clipped. It loses 4 expectations in s4, so clipping is tested. Rule 153, the narrowing case, is not.

## 3. Structural, untried

* **`act` is not a sort.** No core rule mentions `act/1`; it is a parameter vocabulary. Say "four sorts plus a vocabulary".
* **Roles.** `fills(P,R,T1,T2)` is still an unauthored, backdatable base fact. That contradicts the v0.2 unifying claim, since the notes list role appointments as one of the gaps. The proposal:
  * an appointment is the appointer's act creating a power with debtor R, rooted in the holder's lineage;
  * `holder` becomes derived;
  * the special role `acts_for/3` rule (lines 165-166) collapses into the general one.
  * This removes a base relation and a rule, and closes a stated gap.
* **`with(I,Q)`** could be `feeds(I,J)` with `acts_for(J,Q)`: disclosure is knowledge reaching Q. That removes a base relation but needs scenario rewrites.
* **`rollback`, `same_as_ancestor` and `anc_differs`.** After E3 these five rules serve only as a label, used by 2 expectations and the C3 witness.
* **Keep** power/permit and avoid/warrant as they are. The mutants distinguish them ("permits empower", "powers excuse", "warranty ranges over debtor"). Merging them into flags only renames them and saves no rules. The avoid/warrant split *is* the thesis: principal-keyed versus content-keyed.
* **Keep** the `acts_for/2` / `acts_for/3` / `conduct_of` split. Each is read with a different negation.

## 4. v0.2 accretions that replaced nothing

| Accretion | Status | Resolution |
|---|---|---|
| `feeds` | untested | resolved by E6 |
| HITL `trigger_party` | untested | |
| `empower` | untested and extensionally redundant | resolved by E1 |
| `induced` excuse | untested | |
| `does(copying/…)` | dead | resolved by E7 |
| `security` alongside `collateral` | | resolved by E4 |
| `act` as a fifth sort | a documentation inflation | |

The legitimate replacements are:

* warrant replaced evidence/test/clean;
* recognized replaced founded;
* releases and revokes replaced released and revoked;
* permit took over the excusing that powers used to do.
