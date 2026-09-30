# A coordination ontology for human and machine parties

Status: v0.2, an ontology and vocabulary. No protocol.

* The machine-checkable specification is `spec/core.lp`: about 140 Datalog rules, runnable
  with clingo.
* A line-by-line Rust port is in `rust/`, cross-checked against it.
* v0.1 went through four adversarial reviews. What changed and why is in
  `notes/v0.2_changes.md`.

## 1. Thesis

In the LLM era the thing that acts is a pipeline. Each part (weights, prompt, scaffold,
memory, session, fork lineage) can be copied, rolled back, merged or replaced on its own.
"Is this the same agent?" then has no determinate answer, so the ontology does not ask
it. It asks instead:

> **Does this invocation act for this principal, for this act?**

That question has a determinate answer, given by a chain of acts that are each in scope.
Everything else follows from keeping two things apart:

* **Obligations are keyed by principal.** They live in a registry, not in the pipeline,
  and only acts in scope change the registry. So no change to the pipeline can discharge
  them.
* **Authority and assurance are keyed by content.** They attach to what is running,
  through explicit pins and warranties. So a change to the pipeline can void them, and
  sometimes must.

Value drift therefore threatens *assurance*, never *obligation*. Enforcement survives
drift only when it does not depend on the drifting pipeline's future cooperation.

The human case is the degenerate one:

* one opaque content slot;
* no copies;
* no observable change events.

So for a human, assurance can only expire.

## 2. Primitives

Five sorts. Everything else is a relation between them or is derived.

| Sort | What it is | Human | Machine |
|---|---|---|---|
| **principal** | That to which acts and commitments are attributed; `kind` is person, org or machine | a person | an org, or a model insofar as it has capacities (§6) |
| **role** | A position with a charter, held by principals over time | an office | same; *coordinator* is a role |
| **invocation** | One sampling step: *which* (its place in the lineage DAG), *when*, *what content* it ran, *what acts* it did | a moment of a life | one model request and response; tool calls are its acts |
| **commitment** | Directed deontic unit `C(debtor, creditor, trigger, content)` | promise, duty, mandate, consent, reference | same |
| **act** | The domain vocabulary: name, amount, object, information, target | | |

A commitment has one of five **modes**:

* **achieve**: do the act by a deadline.
* **avoid**: never do the act.
* **power**: the grantor becomes answerable for, and bound by, what covered invocations
  do within scope (Hohfeld's power/liability).
* **permit**: the grantor excuses covered acts, and nothing more (Hohfeld's privilege).
* **warrant**: the attester answers if *any* invocation running the pinned content does
  the act. Evals, references and sanitization claims are warranties. Evidence is not a
  separate sort; it is a promise someone can be held to.

**Content** is a map from slot to hash per invocation, `slot(I, Slot, H)`.

* Slots come from a closed vocabulary: weights, prompt, scaffold, tools, memory, context,
  and self.
* Each slot holds one hash. Layered parts, such as a base model plus a LoRA adapter, are
  hashed together.
* An opaque hash `opaque(Id)` is unobservable. A person is one opaque `self` slot. An API
  model's weights are opaque.
* A named "substrate" is only input sugar.

**Lineage** is `edge(I1, I2, K)` with kind *continue*, *copy* or *merge*.

* Swap, rewrite and rollback are derived from content.
* Making any change is an act of the parent invocation. So "do not swap without notice"
  is an ordinary avoid commitment.

**Every change to the registry is an act**, effective only in scope and only from the
next step:

* creating a commitment;
* releasing one (by the creditor's side);
* revoking a power or permit (by the grantor's side);
* copying;
* merging;
* changing content.

What is not an act is **recognized**: `recognized(C, T)` is the adjudicator's explicit
rule of recognition. It covers principals' root authority, duties imposed by law, and
charters.

## 3. Vocabulary (the brief's candidate terms)

| Term | Status | Definition |
|---|---|---|
| principal, role, invocation, commitment | primitive | §2 |
| substrate | derived | Content map of an invocation (§2) |
| lineage | relation | `edge/3` over invocations; derived change kinds |
| delegation scope | derived | The fields of a power or permit: `root`, `follows` (edge kinds crossed), `pin` (sets of content configurations), `allows` (act names with caps). Caveats accumulate down chains of sub-grants |
| charter | derived | The commitments whose debtor is a role, including the role's powers |
| invariant | dropped | An *avoid* commitment is a maintained invariant. What must stay fixed across change is a pin |
| evidence | derived | A warranty: a commitment by the attester, ranging over pinned content |
| conformance | derived | *fulfilled*, *violated*, and *clear* (every exposed invocation has a complete record kept by someone who can answer). Predictively, *assured* means a live warranty covers the invocation |
| defection | derived | A breach attributed to a principal: the debtor; for a role, the performing holder (for acts) or every holder (for omissions); during a vacancy, the appointer; for a false claim of authority, whoever answers for the claimant |
| repair | derived | Performance of a reparation after a particular breach, through chains (Governatori's ⊗) |
| bond, collateral | derived | Reparation owed by someone other than the defector; or a power over the defector's performance, held by the creditor and given as security (irrevocable) |
| custody / operator | derived | Holding an unattenuated power over a lineage |
| standing | derived | Capacity to answer, one of four Hohfeldian capacities (§6) |

## 4. Laws

Each law is stated so that it could be shown wrong. The tag says what currently tests it:

* `S` or `X` is a scenario or a regression from review;
* `C` is an exhaustive bounded check (every world up to 3 machine invocations, 2
  instruments and 2 commitments, with roles, triggers, reparations, learning, merges and
  all three hypotheses);
* `P` is a metamorphic property over random larger worlds.

Every rule is mutation-tested: 61 deliberate breaks of the core, all caught.

**L1. Attribution needs lineage, never content.** An act is P's only if it is performed
by an invocation that meets all of these conditions:

* it is reachable from a live power of P, along continue and copy edges the power
  follows;
* it satisfies the power's pins;
* the act is within scope.

What does not count:

* identical content (a simulation, a stolen copy);
* a merge edge (merges carry knowledge, never authority);
* a permit.

Theft is content without lineage, so the thief binds nobody but itself.
`C4 S5 X1 P2`

**L2. Authority is scoped. Responsibility follows authorized acts, including copying.**

* A promise binds P only within P's scope.
* Making a copy is an act. Whoever's scope covered it answers for the copy's conduct and
  for any claim of authority the copy makes. The copy gains no authority from this.
* A promise induced by its own creditor (fraud, duress, prompt injection) is void, and
  gives that creditor nothing.

*v0.1 stated "responsibility = authority". The red team refuted it with fork-and-disown:
a copy made in scope, but not followed by any grant, escaped every duty.*
`S3 S5 X1 X2`

**L3. Burdens are sticky, privileges are personal.**

* No substrate change ends a commitment in force: swap, rewrite, rollback, fork or
  merge.
* Only these end one:
  * the creditor's release;
  * the grantor's revocation of a power or permit (never of a power given as security);
  * a cascade from a revoked ancestor grant;
  * a warranty's expiry.
* A principal recognized over a *continuation* of a defaulting lineage inherits its open
  defections. A fresh instantiation of the same weights does not.
* Content enters deontics **only** through pins. A pin is a set of approved
  configurations. So:
  * a consent pinned to a model lapses on swap;
  * a version warranty stops covering the new version;
  * a performer-specific duty (Restatement (Second) of Contracts §318) cannot be
    discharged by the replacement;
  * an envelope of tested configurations survives changes within it, and not untested
    mixes.

`C3 P2 P3 S1 S2 X2 X3`

**L4. Drift threatens assurance, not obligation.**

* An invocation is assured against an act iff some live warranty on its content covers
  it, and the attester can answer.
* So a swap voids assurance, and a rollback *restores* it while keeping every obligation
  incurred since.
* A warranty that leaves a slot unpinned claims robustness to every value of that slot.
  If an edited prompt, or a contaminated context, produces the act, the attester has
  defected.
* Warranties about opaque content (references for people, API models) must expire.

`S1 S7 X3`

**L5. Fork law.** Forking multiplies the ways to break a promise, not the promises.

* An *achieve* commitment is discharged once, by any branch the debtor answers for.
* An *avoid* commitment is broken by any such branch.
* Divergent branches can over-commit an exclusive object.
* A rollback retracts nothing: an offer made before a rollback can still be accepted.
* Only the offeree's side can accept an offer, and only after it exists.

`S3 S5 P4`

**L6. Delegation is an attenuation algebra in every dimension.**

* Down a chain of sub-grants, caps take the minimum, followed edge kinds intersect, and
  pins accumulate.
* Only a power that may delegate is a parent.
* Revoking a grant revokes everything below it.

An agent cannot launder its own pin through a sub-grant to itself, a copy, or a third
lineage. `C1 S4 X4`

**L7. Information flows along every lineage edge and every feed.**

* It is cut only in two ways: by reverting to the observable content of an ancestor that
  preceded all learning of it, or by a live sanitization warranty (whose attester
  answers if a leak is observed).
* Persons never revert, so they never forget.
* Knowledge imputed to a principal is never cut.
* Consenting to processing imputes nothing to the consenter.
* Shared learning across parallel negotiations is a disclosure unless it is sanitized.

`S2 S5 S7 X3`

**L8. The machine question is a bundle, and settling it never changes obligations
between persons and orgs.**

* Whether machines are parties is represented as which of four capacities they have:
  owe, claim, empower, answer.
* Commitments whose parties are persons or orgs, made through their own grants, are
  identical under every answer.
* Answerers only grow from `delegate` to `actor` to `party`.
* Unanswered commitments arise only in three places:
  * from machine debtors;
  * from conduct of machine invocations that no principal with standing answers for;
  * from offices with no answerable holder and no appointer.

`P1 C5 S3 S4 S6`

**L9. Drift-invariant enforcement is a power held by the creditor.**

* A self-reparation needs the drifted pipeline to perform.
* A bond needs a third party to perform, and that party can drift too.
* **Collateral** is a power over the debtor's performance, held in the creditor's own
  lineage and triggered by the breach. It needs nobody else's future act. Given as
  security, it is irrevocable, even by the grantor changing their mind.

This is Parfit's Russian nobleman, whose wife holds the power over his future self.
`S1`

**L10. Offices outlive holders.**

* Role commitments bind whoever holds the office when performance is due.
* An act's breach belongs to its performer. An omission belongs to every holder. A
  breach during a vacancy belongs to the appointer.
* Role powers limit what can be promised in the role's name.
* A holder who promises beyond them warrants authority they lack.

`S6 X4`

## 5. Required test cases (all in `spec/scenarios/`)

| Case | File | Outcome |
|---|---|---|
| Survives a model swap and a memory rewrite | `s1` | An NDA made by Alice's agent binds Alice after the agent forgets it and is re-weighted. The later sale is her breach. The evaluator's warranty loses assurance at the swap and restores it at rollback. Collateral lets Bob execute her reparation himself, even after she tries to revoke it |
| Must not survive | `s2` | Bob's permit pinned to w1 excuses processing until the swap; then the same act is Alice's breach. Also covered: a version warranty (lapses), a performer-specific duty (can't be performed by w2), and a two-configuration envelope (survives the tested swap, not an untested mix) |
| Divergence of two forks | `s3` | Both of Dana's branches act for her. A pre-fork prohibition is broken by one branch and a pre-fork duty discharged by the other. The divergent sales over-commit. Erin's copy can't bind her, but she answers for it. Fay's narrow grant covers neither, so her copy is nobody's unless the model can bear duties |
| Human delegates narrow scope to a machine | `s4` | The cap holds against over-promising and against a sub-grant that asks for more. The w1 pin binds every sub-agent and defeats a self-issued laundering grant. Revocation is Alice's act and cascades. The operator warrants its agent's false authority. An unoperated model's promises are answered only if models can answer |
| Fork, simulate, parallel negotiation with shared learning | `s5` | Naive Nia over-commits and leaks Q1's secret through a merge. Her simulation of Q1 binds Q1 to nothing, and yields assurance only because she warrants it. Her rollback leaves the first offer binding. Q2's prompt injection voids its own windfall. Partitioned Ola avoids both failures and answers for its probe |
| Coordinator role | `s6` | Office held person → machine → two persons. Duties follow the office; breaches stay with performers. A vacancy is the board's. A promise *to* a model binds only if models can hold claims |
| Human baseline | `s7` | Unique opaque content; references expire; persons don't forget; audit records count only if their keeper can answer |
| Review regressions | `x1`–`x4` | Theft, manufactured consent, merge hijack, self-release, dual agent, fork-and-disown, re-registration, slot games, laundered sanitization, role revocation, per-breach repair, parenthood |

## 6. The open question, held open

Whether a machine is a party or only a delegate is `hyp(H)`, a Hohfeldian **capacity
bundle**. Every scenario runs under all three bundles.

| H | Machines can | Reading |
|---|---|---|
| `delegate` | nothing: they cannot owe, claim, empower or answer | current law (Restatement (Third) of Agency §1.04 cmt. e: tools) |
| `actor` | owe and answer | "duties without rights" (O'Keefe et al., *Law-Following AI*) |
| `party` | owe, claim, empower and answer | contracting AI (Salib & Goldstein); personhood as a bundle (Leibo et al.) |

The question matters only where no person or org stands behind the machine (L8):

* a model nobody operates (`s4`);
* a copy outside every human grant (`s3`);
* a machine in office (`s6`);
* a promise made *to* a model (`s6`).

That is a sharper form of "are AIs persons?". It asks which of these breaches we are
prepared to leave unanswered, and which capacities would close them.

## 7. Why this notation (prior art)

Surveys with verification tags are in `notes/survey_*.md`.

* **Reused:**
  * Singh's commitment `C(x, y, r, u)` and its lifecycle;
  * Hohfeld's incidents, as the five modes and the four capacities;
  * Governatori's reparation chains;
  * Symboleo's liable/performer/right-holder split, which is our debtor, invocation and
    creditor;
  * caveat accumulation from macaroons, UCAN and Biscuit;
  * PROV's lineage;
  * Crawford and Ostrom's ADICO, which maps onto debtor, mode, content, trigger and
    reparation;
  * BSPL/Cupid's view that norm state is a query over an event log;
  * agency and contract law for the criteria:
    * delegability when the performer is material (§318);
    * warranty of authority;
    * powers given as security (§3.12);
    * successor liability;
    * sub-processor authorization under GDPR Art. 28(2);
    * pre-declared change envelopes under the AI Act, Art. 43(4).
* **The gap filled:** no surveyed framework says what happens to an obligation when its
  bearer is forked or its internals are swapped. Our additions are:
  * lineage-scoped powers;
  * pins as the only link from content to deontics;
  * warranties as evidence;
  * the fork law;
  * copy responsibility;
  * capacities as a switch with a monotonicity law.
* **Language: Answer Set Programming (clingo), restricted in `core.lp` to Datalog with
  negation.**
  * Default reasoning is central. A commitment holds unless ended, an act is a breach
    unless excused, and a power covers unless off-pin.
  * One file serves both as a rule engine on concrete records and, through choice rules,
    as a bounded model finder for counterexamples.
  * The core is *time-stratified*. Every negative cycle passes through an earlier step:
    registry acts take effect at the next step, and reparations detach after the breach.
    So it runs as a per-step fold in a stratified Rust Datalog engine (`ascent`). The
    port matches clingo on every scenario and on 100 random worlds, under every
    hypothesis.
  * Alloy 6 was the close second: better types, weaker defaults, no path to code. Types
    are recovered in `types.lp`, which reports ill-sorted facts as errors.
* **No notation was invented.**

## 8. Known limits

* **The record is trusted.** The core is a function from an accepted record to verdicts.
  It now pins down *what* must be attested:
  * edges are acts of their parent, and theft has no edge;
  * content hashes;
  * acts;
  * complete records.

  Who attests them, and disagreement between observers, are outside it.
* **Standards and values.** Charters are sets of act-type commitments. "Act with loyalty"
  or "use reasonable care" needs a judging role, which is not modelled. A principal's own
  change of mind is handled only as far as release, revocation and securities go.
* **Quantities.** Caps are per act. Budgets can be expressed as exclusive tokens, but
  aggregates are not in the fragment.
* **Statistics.** Warranties are exact claims, but real models are stochastic. A warranty
  should carry a rate and a sample size.
* **Collectibility.** Answerability is not solvency. Collateral is the collectible form.
* **Notice.** Registry acts take effect at the next step for everyone. General
  authorization with notice and objection (GDPR Art. 28(2)) is not modelled.
* **Bounds.** The checks refute but never prove.

## 9. Running

```sh
pip install clingo                  # 5.8
cd spec
python3 run.py                      # scenarios under all three hypotheses + exhaustive checks
python3 props.py 200 1              # metamorphic properties
python3 mutants.py                  # mutation score
python3 crosscheck.py --random 100  # Rust port vs clingo (build ../rust first)
./check.sh                          # all of the above
```
