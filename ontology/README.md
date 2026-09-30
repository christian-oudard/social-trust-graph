# A coordination ontology for human and machine parties

v0.4. This is an ontology and a vocabulary, not a protocol.

* The specification is `spec/core.lp`: about 175 Datalog rules, run with clingo.
* `rust/` is a rule-for-rule port, cross-checked against it. It exists as evidence that
  the notation converts to code.
* Three rounds of adversarial review shaped it. See `notes/v0.*_changes.md` and
  `notes/review*`.

## 1. Thesis

What acts is a pipeline whose parts can each be copied, rolled back, fed or replaced. So
we do not ask "is this the same agent?". We ask two narrower questions: **who runs this
invocation**, and **does it act for this principal, for this act?**

* **Obligations are keyed by principal.** Only acts in scope change the registry, so no
  change to a pipeline discharges them.
* **Authority and assurance are keyed by content**, through pins and warranties, so a
  change to a pipeline can void them.
* **Answerability is keyed by operation.** Whoever runs an invocation answers for it,
  whatever its content or scope.

Value drift therefore threatens assurance, never obligation. Enforcement survives drift
only if it does not need the drifted pipeline's cooperation.

## 2. Identity, defined

"Same agent?" fuses three questions. Each normative question consults exactly one of
them.

| Question | Relation | Decides |
|---|---|---|
| Same content? (*what*) | `slot` equality on pinned slots | authority under pins, assurance |
| Same lineage? (*which*) | `edge` (continue, copy) | how authority and operation propagate |
| Same party? (*whose*) | `op(I, P)`; `acts_for(I, A, P)` | answerability; obligation and authority |

For a person the three coincide: one opaque content slot, one lineage that cannot fork,
one principal. So intuition treats identity as one thing. For a pipeline they come
apart:

* a copy shares content and lineage, but is run by whoever made it;
* a simulation shares content only;
* a swapped agent shares lineage and party, but not content.

A principal's identity is **recognized, not discovered**. A machine principal is
whatever its recognized root declares: which lineage, which edge kinds it follows, which
content it pins. The criteria are public and relied on, never inferred from similarity.
The `continue`/`copy` label is such a declaration, made by whoever runs the fork.

## 3. Primitives

There are **four sorts** plus an act vocabulary:

* **principal**, of kind person, org or machine;
* **role**, a position with a charter, held by appointment (a coordinator is a role);
* **invocation**, one sampling step: its place in the lineage, its time, its content, its
  operator and its acts (tool calls are acts);
* **commitment** `C(debtor, creditor, trigger, content)`.

A commitment has one of five modes:

| Mode | Meaning |
|---|---|
| achieve | do the act by a deadline |
| avoid | never do the act |
| power | covered invocations act *for* the grantor within scope, and the grantor answers for those acts (Hohfeld: power/liability) |
| permit | covered acts are excused towards the grantor, and nothing more (privilege) |
| warrant | the attester answers if *any* invocation running the pinned content does the act. Evals, references and sanitization claims are modelled as warranties |

For power and permit the debtor is the grantor, as in Symboleo's P(creditor, debtor).

**Content** is `slot(I, Slot, H)`, one hash per slot from a closed vocabulary (weights
with adapters, prompt, scaffold, tools, memory, context, self). `opaque(Id)` is
unobservable: a person is one opaque self slot, and so is an API model's weights.

**Lineage** is `edge(I1, I2, continue|copy)`. `feeds(I1, I2)` carries knowledge, never
authority or answerability. Swap and rewrite are derived from content.

**Operation** is `op(I, P)`, recorded by `operator(I, P)`. By default a person runs their
own body, a grantor runs the parentless root of its power, operation passes down continue
edges, and a copy is run by whoever made it.

**Every registry change is an act**, effective only in scope and from the next step:
create, release (the creditor's side), revoke (the grantor's side), appoint, copy, and
change content (by the parent, or by whoever `changed_by` names; opaque content has no
default maker).

An invocation is **steered** by someone who does not run it but induced it (fraud,
duress, prompt injection) or changed its content. It cannot change the registry in
favour of a party that steered it, and the steerer answers for its conduct. What is not
an act is `recognized`: valid under the adjudicator's rule of recognition (Hart), not
created by any act in the record.

The brief's other terms are derived:

| Term | Derived as |
|---|---|
| delegation scope | `root`, `follows`, `pin`, `allows`, attenuated along `under` citations |
| substrate | the content an invocation runs |
| charter | the commitments of a role |
| invariant | an avoid commitment, or a pin |
| evidence | a warranty |
| conformance | fulfilled, violated, or *clear* (every exposed step recorded); *assured* is its predictive form |
| defection | a breach attributed to the debtor, the performing holder, or a vacancy's appointer |
| repair | performance of a reparation, per breach |
| bond | a reparation owed by a third party |
| security | a power given as security (Restatement (Third) of Agency §3.12), held by the creditor, performing only the debtor's reparation |

## 4. Laws

Every law can be shown wrong. Tags name its tests: `S`/`X` scenarios, `C` exhaustive
checks within bounds, `P` properties on random worlds. Every statement of the core is
deleted in turn, and 50 semantic mutants are added; all 219 are caught.

**L1. Attribution needs lineage, never content.**

An act is P's only through a live power of P reaching the invocation along followed
edges, pins met. Identical content (a simulation, a theft), a feed or a permit never
attributes an act.

`C4 S5 X1`

**L2. Authority is scoped; answerability follows operation.**

* A promise binds P only within scope.
* P answers for all conduct of what P runs or steered, and for the acts P authorized
  (so a narrow grant to someone else's agent, only for those). Pins, revocation and
  `until` limit authority, never answerability. Copies are their maker's; feeds pass
  nothing.
* An out-of-scope promise binds nobody. This is a stipulation, not doctrine: the registry
  is deemed notice to all, as an agreed attribution procedure (cf. UNCITRAL MLAC Art
  7(1)), which positive law usually refuses (CA 2006 s.40; Directive 2017/1132 Art 9(2)).
  Hence powers pin only observable content.

`S3 S4 S5 X5 X7 C5 P4`

**L3. Burdens are sticky, privileges are personal.**

* No change of content or lineage ends a commitment. Only release, revocation (never of
  a security), cascade, expiry and `until` do; a security ends with what it secures.
* A pin makes a privilege dormant off-pin; `until` ends it.
* Whoever takes over operation of a lineage inherits its open defections, for good
  standing only.

`C3 P2 P3 S1 S2 X2`

**L4. Drift threatens assurance, not obligation.**

* Assured means a live warranty covers the content, by an attester who can answer and is
  not exposed for the invocation.
* An unpinned slot claims robustness: a prompt edit or contamination that produces the
  act falsifies it. Warranties on opaque content must expire.

`S1 S7 X3 X6`

**L5. Fork law.**

*Achieve* is discharged once, by any branch the debtor answers for; *avoid* is broken
by any such branch. Divergent branches over-commit exclusive objects. A rollback retracts
nothing.

`S3 S5 P4`

**L6. Delegation attenuates.** Down cited chains, caps take the minimum, followed kinds
intersect, and pins accumulate. Revocation cascades. `C1 S4 X4 X5`

**L7. Knowledge flows along every edge and feed.**

Only a live sanitization warranty cuts it, and its attester answers for a leak. What an
invocation knows is imputed to whoever runs it, and sticks. Consent imputes nothing.

`S2 S5 S7 X3 X7`

**L8. The machine question never changes obligations between persons and orgs.**

* Answerers only grow from `delegate` to `actor` to `party`.
* Unanswered commitments come only from machine debtors.
* Unanswered acts come only from invocations no person or org runs or authorized.

`P1 C5 S3 S4 S6`

**L9. Drift-invariant enforcement is a power the creditor holds.**

* A self-reparation needs the drifted pipeline; a bond needs a third party, who can drift.
* A *security* needs neither. The grantor cannot revoke it. It is dormant between
  breaches and ends with the obligation it secures (§3.13). Compare Parfit's Russian
  nobleman, who makes his gift self-executing and revocable only with another's consent.

`S1 X5 X6 X7`

**L10. Offices outlive holders.**

Duties bind the holder when performance is due. An act's breach is its performer's, an
omission every holder's, a vacancy the appointer's. Role powers need the holder's own
authority.

`S6 X4 X6`

**L11. Steering does not pay.**

A steered invocation's creation, release, revocation, trigger or appointment is void
when a steerer is party to it; a non-party's steering voids nothing. A creditor-induced
breach of a prohibition or warranty is excused; induced performance still counts.

`C3 S5 X5 X7`

## 5. Drift, mapped

| Brief | Represented as |
|---|---|
| retraining, model swap | change of `weights`, the act of whoever made it (`changed_by`), who thereby steers |
| prompt or memory edit, context contamination | change of `prompt` / `memory` / `context`; unpinned warranties are falsified by the act it causes |
| copies diverge | fork law; each copy is its maker's |
| human drift is continuous | one opaque slot, no observable events, so references expire |
| bounded by continuity | persons cannot be copied (type error) |
| bounded by reputation | `in_good_standing`, which passes to whoever takes over; references are warranties |
| bounded by mortality | a lineage that ends: its commitments remain (not modelled further) |

## 6. Test cases (`spec/scenarios/`)

| Case | File | Shows |
|---|---|---|
| Survives swap and memory rewrite | `s1` | NDA binds after forgetting and a vendor re-weight; the vendor's no-swap promise breaks; a security survives Alice's revocation and wakes again on a second breach |
| Must not survive | `s2` | pinned consent is dormant after a swap; `until` terminates it; version warranty; performer-specific duty; envelopes |
| Divergent forks | `s3` | both branches bind Dana; copies are their maker's; a wild instance is answered for only if models can owe |
| Narrow delegation | `s4` | caps and pins bind every sub-agent; pin laundering fails; revocation cascades |
| Fork, simulate, negotiate in parallel | `s5` | naive leak and over-commitment vs partition; simulations bind nobody; rollback keeps offers; injection voids |
| Coordinator | `s6` | office by appointment, person → machine → persons; vacancy is the board's |
| Human baseline, regressions | `s7`, `x1`–`x7` | |

## 7. The open question

Machines' capacities are `hyp(H)`, and every scenario runs under all three bundles
(after Leibo et al.'s unbundled personhood and Kurki's bundle theory):

| H | Machines can | Reading |
|---|---|---|
| `delegate` | nothing | "at present, computer programs are instrumentalities" (Restatement (Third) of Agency §1.04 cmt e) |
| `actor` | owe | duties without rights (O'Keefe et al.), plus the competence to bind oneself |
| `party` | owe and claim | contracting AI (Salib & Goldstein) |

The answer matters only where no person or org stands behind a machine: a wild instance,
a machine in office, a model's own promise, or a promise made to a model.

**The person is the core unit**: persons have every capacity unconditionally, their
identity needs no declared criterion, and every open question is stated as what happens
where no person answers.

## 8. Prior art and notation

Surveys are in `notes/survey_*`.

* **Notation.** The core is event-calculus inertia (a commitment holds unless an act ends
  it) in Answer Set Programming. Negation as failure covers the defeasible patterns this
  core needs (excuses, reparations); there is no superiority relation among norms.
  Alloy 6 was the close second, unless defaults proved central, which they did; TLA+
  lacks defaults. The fragment is time-stratified Datalog and ports line-for-line to Rust.
* **Drawn on.** Singh's commitments; Hohfeld's incidents, as the modes; Governatori's
  reparation chains; Symboleo's split of liable, performer and right-holder; Macaroon,
  Biscuit and UCAN attenuation, and ZCAP-LD's `parentCapability` for citation; PROV-style
  lineage (`edge` ≈ wasDerivedFrom).
  * ADICO / IG 2.0: Attribute → debtor, Deontic → mode, aIm → content, Conditions →
    trigger, deadline and `until`, Or else → reparation; the creditor is IG 2.0's indirect
    object. Powers are its constitutive statements.
  * Agency and contract law. Answerability follows the instrumentality view (§1.04 cmt e;
    MLAC Art 7), which is broader than vicarious liability.
* **The gap addressed.** No surveyed framework handles forked or swapped bearers.
* **No new logic was invented.** The vocabulary (pin, warrant, security, follows) is new.

Deliberate simplifications of law: steered acts are void rather than voidable (R2d
Contracts §§164, 175); dual-agent releases are void; imputation covers all knowledge, not
only what is material (R3d Agency §5.03); privileges are not assignable (unlike rights,
R2d §317).

## 9. Limits

* The record is trusted. The core says *what* must be attested; *who* attests it is
  outside the core. `induced` is the hardest: an adjudicator's finding that gates registry
  validity.
* Notice is instant. Reliance on a revoked scope during registry lag is where the L2
  stipulation departs furthest from law.
* Grain is the API request: a retry is a copy, and parallel calls in one step share a
  one-shot approval.
* Disclosure is `knows` plus `with`, which is crude in both directions.
* Standards such as "reasonable care" need a judging role.
* Budgets need aggregates; exclusive tokens are the workaround. A double pledge of a
  security is not detected.
* Warranties are exact, but models are stochastic.
* Answerability is not solvency. Under `actor` a machine can owe but hold nothing.
* Checks are bounded.

```sh
pip install clingo && cd spec && ./check.sh   # scenarios, checks, properties, mutants, Rust cross-check
```
