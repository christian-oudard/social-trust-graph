# A coordination ontology for human and machine parties

v0.3. This is an ontology and a vocabulary, not a protocol.

* The specification is `spec/core.lp`: about 150 Datalog rules, run with clingo.
* `rust/` is a rule-for-rule port, cross-checked against it. It exists as evidence that
  the notation converts to code.
* Two rounds of adversarial review shaped it. See `notes/v0.2_changes.md`,
  `notes/v0.3_changes.md` and `notes/review*`.

## 1. Thesis

What acts is a pipeline whose parts can each be copied, rolled back, fed or replaced. So
we do not ask "is this the same agent?". We ask: **does this invocation act for this
principal, for this act?** A chain of acts, each one in scope, answers that.

* **Obligations are keyed by principal.** They live in a registry, and only acts in
  scope change the registry. So no change to a pipeline discharges them.
* **Authority and assurance are keyed by content.** They attach to what runs, through
  pins and warranties. So a change to a pipeline can void them.

Value drift therefore threatens assurance, never obligation. Enforcement survives drift
only if it does not need the drifted pipeline's cooperation.

## 2. Identity, defined

"Same agent?" fuses three questions. Each normative question consults exactly one of
them.

| Question | Relation | Decides |
|---|---|---|
| Same content? (*what*) | `slot` equality on pinned slots | authority under pins, assurance |
| Same lineage? (*which*) | `edge` (continue, copy) | how authority and answerability propagate; succession |
| Same party, for this act? (*whose*) | `acts_for(I, A, P)` | obligation, authority, answerability |

For a person the three coincide: one opaque content slot, one lineage that cannot fork,
one principal. So intuition treats identity as one thing. For a pipeline they come
apart:

* a copy shares content and lineage, but not necessarily the party;
* a simulation shares content only;
* a swapped agent shares lineage and party, but not content.

A principal's identity is **recognized, not discovered**. A person is recognized by law.
A machine principal is whatever its recognized root says: which lineage, which edge kinds
it follows, which content it pins. Machine identity criteria are therefore declared,
public, and relied on. They are never inferred from similarity. The `continue`/`copy`
label is such a declaration, made by whoever runs the fork.

## 3. Primitives

There are **four sorts** plus an act vocabulary:

* **principal**, of kind person, org or machine;
* **role**, a position with a charter, held by appointment (a coordinator is a role);
* **invocation**, one sampling step: its place in the lineage, its time, its content and
  its acts (tool calls are acts);
* **commitment** `C(debtor, creditor, trigger, content)`.

A commitment has one of five modes:

| Mode | Meaning |
|---|---|
| achieve | do the act by a deadline |
| avoid | never do the act |
| power | covered invocations act *for* the grantor: authority within scope, answerability for all their conduct (Hohfeld: power/liability) |
| permit | covered acts are excused towards the grantor, and nothing more (privilege) |
| warrant | the attester answers if *any* invocation running the pinned content does the act. Evals, references and sanitization claims are warranties; evidence is a promise someone can be held to |

**Content** is `slot(I, Slot, H)`, one hash per slot from a closed vocabulary (weights
with adapters, prompt, scaffold, tools, memory, context, self). `opaque(Id)` is
unobservable: a person is one opaque self slot, and so is an API model's weights.

**Lineage** is `edge(I1, I2, continue|copy)`. `feeds(I1, I2)` carries knowledge, never
authority. Swap and rewrite are derived from content.

**Every registry change is an act.** It is attributed like any act, effective only in
scope, and takes effect from the next step. The registry acts are:

* create;
* release (by the creditor's side);
* revoke (by the grantor's side);
* appoint;
* copy;
* change content (by the parent, or by whoever `changed_by` names).

An invocation steered by someone it does not act for (`induced`: fraud, duress, prompt
injection) cannot change the registry. What is not an act is `recognized`: the
adjudicator's explicit rule of recognition.

The brief's other terms are derived:

* **delegation scope**: `root`, `follows`, `pin` and `allows`, attenuated along `under`
  citations;
* **charter**: the commitments of a role;
* **invariant**: an avoid commitment, or a pin;
* **evidence**: a warranty;
* **conformance**: fulfilled, violated, or *clear* (every exposed step recorded), with
  *assured* as its predictive form;
* **defection**: a breach attributed to the debtor, the performing holder, or a vacancy's
  appointer;
* **repair**: performance of a reparation, counted per breach;
* **bond**: a reparation owed by a third party;
* **collateral**: a *security*, a power over the debtor's performance held by the
  creditor.

## 4. Laws

Every law can be shown wrong. Tags say what tests it:

* `S` or `X` is a scenario or regression;
* `C` is an exhaustive check over all worlds within bounds;
* `P` is a property on random worlds.

The whole core is mutation-tested. Every statement is deleted in turn, and 42 semantic
mutants are added; all 199 are caught.

**L1. Attribution needs lineage, never content.**

* An act is P's only through a live power of P that reaches the invocation along
  followed edges, with its pins met.
* Identical content (a simulation, a theft), a feed, or a permit never attributes an act.

`C4 S5 X1`

**L2. Authority is scoped; answerability is not.**

* A promise binds P only within scope.
* P answers for all conduct of the invocations it covers. That includes their copies,
  and anything they feed into invocations no person or org acts for.
* An out-of-scope promise binds nobody, because scope is public.

`S3 S4 S5 X5 P4`

**L3. Burdens are sticky, privileges are personal.**

* No change of content or lineage ends a commitment.
* Only these end one: release, revocation (never of a security), cascade, expiry, a
  repaired breach (for a security), and `until`.
* A pin makes a privilege dormant off-pin; `until` ends it.
* A continuation of a custodied lineage inherits open defections.

`C3 P2 P3 S1 S2 X2`

**L4. Drift threatens assurance, not obligation.**

* Assured means a live warranty covers the content, and its attester can answer and does
  not answer for the invocation.
* An unpinned slot is a claim of robustness, so prompt edits or context contamination
  that produce the act falsify it.
* Warranties on opaque content must expire.

`S1 S7 X3 X6`

**L5. Fork law.**

* An *achieve* commitment is discharged once, by any branch the debtor answers for.
* An *avoid* commitment is broken by any such branch.
* Divergent branches over-commit exclusive objects.
* A rollback retracts nothing.

`S3 S5 P4`

**L6. Delegation attenuates.** Down cited chains, caps take the minimum, followed kinds
intersect, and pins accumulate. Revocation cascades. `C1 S4 X4 X5`

**L7. Knowledge flows along every edge and feed.**

* Only a live sanitization warranty cuts it, and its attester answers for a leak.
* Imputed knowledge sticks.
* Consent imputes nothing.

`S2 S5 S7 X3`

**L8. The machine question never changes obligations between persons and orgs.**

* Answerers only grow from `delegate` to `actor` to `party`.
* Unanswered commitments come only from machine debtors.
* Unanswered acts come only from lineages no person or org covers.

`P1 C5 S3 S4 S6`

**L9. Drift-invariant enforcement is a power the creditor holds.**

* A self-reparation needs the drifted pipeline, and a bond needs a third party, who can
  drift too.
* A *security* needs neither. The grantor cannot revoke it, and it ends once the breach
  is repaired. This is Parfit's Russian nobleman.

`S1 X5 X6`

**L10. Offices outlive holders.**

* Duties bind the holder when performance is due.
* An act's breach is its performer's; an omission is every holder's; a vacancy is the
  appointer's.
* Role powers need the holder's own authority.

`S6 X4 X6`

## 5. Drift, mapped

| Brief | Represented as |
|---|---|
| retraining, model swap | change of `weights`, the act of whoever made it (`changed_by`) |
| prompt or memory edit, context contamination | change of `prompt` / `memory` / `context`; unpinned warranties are falsified by the act it causes |
| copies diverge | fork law; answerability passes to copies |
| human drift is continuous | one opaque slot, no observable events, so references expire |
| bounded by continuity | persons cannot be copied (type error) |
| bounded by reputation | `in_good_standing`, which passes to continuations; references are warranties |
| bounded by mortality | a lineage that ends: its commitments remain (not modelled further) |

## 6. Test cases (`spec/scenarios/`)

| Case | File | Shows |
|---|---|---|
| Survives swap and memory rewrite | `s1` | NDA binds after forgetting and a vendor re-weight; the vendor's no-swap promise breaks; collateral repairs despite Alice's revocation |
| Must not survive | `s2` | pinned consent is dormant after a swap; `until` terminates it; version warranty; performer-specific duty; envelopes |
| Divergent forks | `s3` | both branches bind Dana; copies are their copier's; a wild instance is answered for only if models can owe |
| Narrow delegation | `s4` | caps and pins bind every sub-agent; pin laundering fails; revocation cascades |
| Fork, simulate, negotiate in parallel | `s5` | naive leak and over-commitment vs partition; simulations bind nobody; rollback keeps offers; injection voids |
| Coordinator | `s6` | office by appointment, person → machine → persons; vacancy is the board's |
| Human baseline, regressions | `s7`, `x1`–`x6` | |

## 7. The open question

Machines' capacities are `hyp(H)`, and every scenario runs under all three bundles:

| H | Machines can | Reading |
|---|---|---|
| `delegate` | nothing | tools (Restatement (Third) of Agency §1.04 cmt e) |
| `actor` | owe | duties without rights (O'Keefe et al.) |
| `party` | owe and claim | contracting AI (Salib & Goldstein); personhood as a bundle (Leibo et al.) |

The answer matters only where no person or org stands behind a machine: a wild instance,
a machine in office, a model's own promise, or a promise made to a model.

**The person is the core unit** in three ways:

* persons have every capacity unconditionally;
* their identity needs no declared criterion;
* every open question is stated as what happens where no person answers.

## 8. Prior art and notation

Surveys are in `notes/survey_*`.

* **Notation.** The core is event-calculus inertia (a commitment holds unless an act ends
  it) in Answer Set Programming. Its defaults do the work of defeasible deontic logic.
  * Alloy 6 was the close second: the tools survey recommended it unless defaults proved
    central, which they did.
  * TLA+ lacks defaults.
  * The Datalog fragment is time-stratified and ports line-for-line to Rust.
* **Reused.**
  * Singh's commitments.
  * Hohfeld's incidents, as the modes and capacities.
  * Governatori's reparation chains.
  * Symboleo's split of liable, performer and right-holder.
  * Macaroon, UCAN and Biscuit attenuation.
  * PROV lineage.
  * ADICO, which maps onto debtor, mode, content, trigger and reparation.
  * Agency and contract law.
* **The gap filled.** No surveyed framework handles forked or swapped bearers.
* **No notation was invented.**

## 9. Limits

* The record is trusted. The core says *what* must be attested; *who* attests it is
  outside the core.
* Standards such as "reasonable care" need a judging role.
* Budgets need aggregates; exclusive tokens are the workaround.
* Warranties are exact, but models are stochastic.
* Answerability is not solvency.
* Notice is instant. Reliance on a revoked scope during registry lag is where L2's
  no-warranty rule would fail.
* Succession detection is limited to recognized roots over a continuing lineage.
* Checks are bounded.

```sh
pip install clingo && cd spec && ./check.sh   # scenarios, checks, properties, mutants, Rust cross-check
```
