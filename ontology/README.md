# A coordination ontology for human and machine parties

Status: v0.1, an ontology and vocabulary. No protocol. The machine-checkable
specification is `spec/core.lp` (about 100 rules); this document explains it.

## 1. Thesis

In the LLM era the thing that acts is a pipeline, and each of its parts (weights,
prompt, scaffold, memory, session, fork lineage) can be copied, rolled back, merged or
replaced on its own. "Is this the same agent?" then has no determinate answer, so the
ontology does not ask it. It asks instead:

> **Does this invocation act for this principal, for this act?**

That question has a determinate answer, given by a chain of grants. Everything else
follows from keeping two things apart:

* **Obligations are keyed by principal.** They live in a registry, not in the pipeline,
  so no change to the pipeline can discharge them.
* **Authority and assurance are keyed by content.** They attach to what is running,
  through explicit pins and tests. So a change to the pipeline can void them, and
  sometimes must.

Value drift therefore threatens *assurance*, never *obligation*. The human case is the
degenerate one:

* one opaque content slot;
* no copies;
* no observable change events.

So for a human, assurance can only decay with time.

## 2. Primitives

Six sorts. Everything else is a relation between them or is derived.

| Sort | What it is | Human instance | Machine instance |
|---|---|---|---|
| **principal** | That to which acts and commitments are attributed; `kind` is person, org or machine | a person | an org, or a model if it has standing (see §6) |
| **role** | A position with a charter, filled by principals over time | an office holder | same; *coordinator* is a role |
| **invocation** | One step of execution: *which* (its place in the lineage DAG), *when*, *what* it ran, *what* it did | a moment of a life | one call or step of a pipeline |
| **substrate** | Content-addressed configuration, `part(S, slot, hash)` | one opaque slot `self` | slots: weights, prompt, scaffold, memory, context |
| **commitment** | Directed deontic unit `C(debtor, creditor, trigger, content)`, mode *achieve*, *avoid* or *power* | a promise, duty or mandate | same |
| **evidence** | An attested test of content, a sanitization attestation, or a complete record of an invocation | reputation, testimony | evals, attestation, transcripts |

**Lineage** is a relation, not a sort. It is `edge(I1, I2, kind)` over invocations, with
kind *continue*, *copy* or *merge*.

Change kinds are *derived* from content, not declared:

* **swap**: the weights slot changed;
* **rewrite**: the memory slot changed;
* **rollback**: the content equals content that an ancestor already ran.

This separation of *which* (lineage) from *what* (content) is the load-bearing move.
Copies share content but differ in lineage. A rollback shares content with the past but
not its commitments.

## 3. Vocabulary (the brief's candidate terms)

| Term | Status | Definition in the ontology |
|---|---|---|
| principal, role, invocation, substrate, commitment, evidence | primitive | §2 |
| lineage | relation | `edge/3` over invocations |
| delegation scope | derived | A **grant** is a commitment of mode *power*. Its debtor is the grantor, and its scope is `root` (a lineage start), `follows` (which edge kinds it crosses), `pin` (content condition) and `allows` (act names with caps) |
| charter | derived | The commitments, duties and powers, whose debtor is a role |
| invariant | dropped | An *avoid* commitment is a maintained invariant. What must stay fixed across change is a *pin* |
| conformance | derived | *fulfilled*, *violated* or *clear* (clear needs complete records: silence is not conformance). Predictive conformance is *assured*, from content-keyed tests |
| defection | derived | A violation, attributed to the debtor, or to the role's filler at the time of breach |
| bond | derived | A reparation owed by someone **other than** the defector |
| repair | derived | Fulfilment of a reparation after a defection (Governatori's ⊗ chains) |
| permission | derived | The creditor extends its own authority to the invocation (a grant from the creditor, in scope); this *excuses* the act |
| custody / operator | derived | Holding an unattenuated grant over a lineage |
| attribution | derived | `acts_for(I, A, P)`: invocation I does act A as P's act |
| standing | switch | Who can be the last answerer. It is the open question (§6) |

## 4. Laws

Each law is stated so that it could be shown wrong. The tag says what currently tests it:

* `S` is a scenario;
* `C` is an exhaustive bounded check (all worlds up to 3 machine invocations, 2
  delegated grants, 2 commitments, both hypotheses);
* `P` is a metamorphic property over random larger worlds.

Every rule is also mutation-tested: 32 deliberate breaks of the core, all caught.

**L1. Attribution needs lineage, never content.** An act binds or burdens P only if it
is performed by an invocation that meets all of these conditions:

* it is reachable from a live grant of P, along edge kinds the grant follows;
* it satisfies the grant's pins;
* the act is within the grant's scope.

Nothing else counts: not identical content, not possession of a key, not memory. A
simulation of Q that runs Q's exact weights cannot make or break Q's commitments.
Whoever passes off its output answers for it. `C4 S5 P2`

**L2. One scope.** The same relation fixes what an invocation can *promise* for P
(authority) and which of its acts P *answers for* (responsibility). Custody is just a
broad grant.

*Refuted if* some case needs responsibility wider than authority for the same grant.
Respondeat superior's "scope of employment" is the obvious candidate. Our answer is that
a custodian holds a broad grant; this is the most contestable law. `S2 S4`

**L3. Burdens are sticky, privileges are personal.**

* No substrate change (swap, rewrite, rollback, fork, merge) ends a commitment that is
  in force.
* Only these end one: creditor release, grantor revocation (for powers), fulfilment, or
  expiry on the commitment's own terms.
* Content enters deontics **only** through pins, which restrict a commitment's range of
  invocations to a set of hashes (a pre-declared *change envelope*). So:
  * a consent pinned to a model lapses on swap;
  * a version warranty stops covering the new version;
  * a performer-specific duty cannot be discharged by the replacement (Restatement
    (Second) of Contracts §318);
  * an envelope covering both versions survives the swap.

`C3 P2 P3 S1 S2`

**L4. Drift threatens assurance, not obligation.**

* A test supports an invocation iff the invocation agrees with the tested content on
  every slot the test fixed.
* So a swap voids assurance, a memory rewrite does not void a weights-only test, and a
  rollback *restores* assurance while keeping every obligation incurred since.
* Human tests cannot be voided by events. They decay by horizon.

`S1 S7`

**L5. Fork law.** Forking multiplies the ways to break a promise, not the promises.

* An *achieve* commitment is discharged once, by any covered branch.
* An *avoid* commitment is broken by any covered branch.
* Divergent branches can over-commit an exclusive object, which guarantees a breach.
* Whether a copy is covered is a property of the grant (`follows copy`), not of the copy.
* A rollback retracts nothing: an offer made before a rollback can still be accepted.

`S3 S5 P4`

**L6. Delegation is an attenuation algebra.** A sub-grant's scope is its request
intersected with its parent's scope. Revocation cascades down the chain. `C1 C2 S4`

**L7. Information flows along every lineage edge.**

* Knowledge passes along *continue*, *copy* and *merge* edges.
* Only content-level scrubbing cuts it: a rollback to content first seen before the
  learning, or an attested sanitization.
* Knowledge imputed to the *principal* is never cut.
* Shared learning across parallel negotiations is therefore a disclosure unless it is
  sanitized. This is an affordance humans lack: people cannot unlearn, so walls between
  people rely on separation.

`S5`

**L8. Standing changes who answers, never what binds.** Settling party-vs-delegate
changes only the answerers, unanswerable commitments, unanswered breaches and orphaned
acts. It never changes attribution, binding, violation or defection. Giving machines
standing only adds answerers. Unanswered commitments and orphaned acts arise only
from machine debtors, or from machine invocations that no principal with standing
covers for the act in question. A person's own acts are always answered.
`P1 C5 S3 S4 S6`

**L9. Drift-invariant enforcement is third-party enforcement.** A bond repairs a breach
without any further act by the defector's lineage. A self-reparation depends on the
drifted pipeline choosing to perform. This is Parfit's Russian nobleman, who binds his
future self through his wife. `S1`

**L10. Offices outlive holders.**

* Role commitments bind whoever fills the role when performance is due.
* A breach attaches to whoever held the role when it happened.
* Role powers limit what can be promised in the role's name.
* A holder who promises beyond them warrants authority they lack and answers
  personally.

`S6`

## 5. Required test cases (all in `spec/scenarios/`)

| Case | File | Outcome |
|---|---|---|
| Survives a model swap and a memory rewrite | `s1` | An NDA made by Alice's agent binds Alice after the agent forgets it and is re-weighted. The later sale is her defection. Assurance is lost at the swap and restored by the rollback. A surety's bond repairs the breach; her own reparation defaults |
| Must not survive | `s2` | Bob's consent pinned to w1 excuses processing until the swap, then the same act is Alice's violation. Also covered: a version warranty (lapses), a performer-specific duty (cannot be performed by w2, so it is breached), and an envelope {w1, w2} (survives) |
| Divergence of two forks | `s3` | Both branches act for Dana. A pre-fork prohibition is broken by one branch; a pre-fork duty is discharged by the other. Their divergent sales of one item over-commit her. Erin's grant does not follow copies, so her copy is a stranger. Whether anyone answers for it depends only on the standing switch |
| Human delegates narrow scope to a machine | `s4` | A cap of 500 holds against over-promising and against sub-delegation that asks for 800. The pin lapses on swap. Revocation cascades. The vendor answers for its agent's ultra vires promises. A self-hosted sub-agent's promises are answered only if the model has standing |
| Fork, simulate, parallel negotiation with shared learning | `s5` | Nia (naive: custody follows copies and merges) over-commits and leaks Q1's secret to Q2 through the merge. Her simulation of Q1 yields valid assurance about Q1 but no commitments of Q1. Her rollback-and-retry leaves the first offer binding. Ola (partitioned: explicit disjoint sub-grants, sanitized merge) does neither. Her uncovered probe can extract but not bind |
| Coordinator role handover | `s6` | person → machine → person. Duties follow the office, and breaches stay with the holder |
| Human baseline | `s7` | Opaque slot, time-decaying assurance. Persons can never be *clear* by audit. Copying a person is a type error |

## 6. The open question, held open

Whether a machine can be a party in its own right, or only a delegate, is the switch
`hyp(machine_party)`. It feeds exactly one relation, `standing`. Every scenario is run
under both answers, and expectations can be tagged `party` or `delegate`.

The ontology does not need the question settled to say who is bound. It needs the
question settled only to say who answers when no human or org does (L8). Those are
three cases:

* an uncustodied sub-agent (s4);
* a copy outside every human grant (s3, s5);
* a machine in office (s6).

This is a sharper statement of the open question than "are AIs persons?". It asks
whether we accept breaches with no answerer, or give some machines standing, or forbid
uncustodied machine lineages from acting at all.

## 7. Why this notation (prior art)

Full survey notes, with verification tags, are in `notes/`. In brief:

* **Reused as is:**
  * Singh's commitment `C(x, y, r, u)` and its lifecycle;
  * Hohfeld's power/liability as the meaning of a grant;
  * Governatori's reparation chains for repair;
  * Symboleo's split of liable, performer and right-holder, which is our debtor,
    invocation and creditor;
  * the attenuation discipline of Biscuit, UCAN and SPKI;
  * W3C PROV's lineage;
  * Crawford and Ostrom's ADICO, which maps onto our debtor, mode, content, trigger and
    reparation: Attribute, Deontic, aIm, Conditions, Or else;
  * BSPL/Cupid's view that norm state is a query over an event log.
* **The gap we fill:** no surveyed framework (ADICO/IG 2.0, Singh, FCL, MOISE, OperA,
  InstAL, Symboleo, L4, UFO-L, PROV, the ocap family, the AI-ID proposals) says what
  happens to an obligation when its bearer is forked or its internals are swapped. Our
  additions are:
  * grants scoped by lineage, with sets of followed edges;
  * pins as the sole link between content and deontics;
  * content-keyed assurance versus principal-keyed obligation;
  * the fork law;
  * standing as a switch with a monotonicity law.
* **The legal survey independently converges on L3.** It lists:
  * delegability unless the performer is material (§318, UCC §2-210);
  * retained liability of the delegator;
  * sub-processor consent under GDPR Art. 28(2);
  * pre-declared change envelopes under the AI Act, Art. 43(4);
  * joint-and-several backstops on company divisions (Dir. 2017/1132).
* **Language: Answer Set Programming (clingo), restricted in `core.lp` to Datalog with
  negation.**
  * Default reasoning is central. A commitment holds unless ended, an act is a breach
    unless excused, and a grant covers unless off-pin. ASP expresses this natively;
    Alloy would need every exception to edit an existing formula.
  * The same file serves as an executable rule engine on concrete records, and as a
    bounded model finder through choice rules, so the laws can be searched for
    counterexamples.
  * The core ports to Rust Datalog (`ascent`), and Biscuit already runs a Datalog
    authorizer for delegation.
  * Alloy 6 was tried and was a close second: better types, worse defaults, and no path
    to code. Types are recovered in `types.lp`, where ill-sorted facts are reported
    errors.
* **No notation was invented.**

## 8. Known limits

* **Evidence is only half integrated.** Tests, sanitization and records are evidence.
  But `does`, `edge` and `runs` are taken as the adjudicator's accepted record. Different
  observers with different records reach different verdicts. The core is a function from
  a record to verdicts, and does not yet model disagreement about the record.
* **No aggregation.** Capacity (sell at most 100 units in total across forks) needs sums.
  Exclusivity is the only resource constraint so far.
* **Founding is axiomatic.** Anyone may found a principal with a root grant, so the
  ontology does not yet prevent a defector re-registering its lineage as a new principal
  ("mere continuation" in successor-liability law).
* **Notice is instantaneous.** Revocation takes effect on the registry at once. The
  "general authorization with notice and objection" pattern (GDPR Art. 28(2)) would be a
  default-reasoning extension.
* **Bounds.** The checks are exhaustive only within small bounds, so they refute but
  never prove.

## 9. Running

```sh
pip install clingo            # 5.8
cd spec
python3 run.py                # scenarios under both hypotheses + exhaustive checks
python3 props.py 200 1        # metamorphic properties
python3 mutants.py            # mutation score
./check.sh                    # all three
```
