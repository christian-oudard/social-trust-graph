# R1 — Foundations review (philosophy of action / formal ontology)

Scope: `ontology/README.md`, `spec/core.lp`, `spec/types.lp`, `spec/scenarios/*.lp`, `spec/checks/c5*`, `checks/lib/world.lp`.
No repository files were modified. Claims marked **[run]** were confirmed by running clingo 5.8 on probe files in
`scratchpad/probes/` (these load `core.lp` and `types.lp` unchanged).

Severity: **critical** means the thesis or a law is false as stated, or the brief is not met. **major** means a
central mechanism is wrong or missing. **minor** means a local defect.

---

## A. Identity-for-commitment: "attribution via grants"

### A1. [critical] Identity is not removed. It moves into the `continue` label and into founding.
Attribution is `covered(G,I)`, which is reachability from `root(G,_)` along edges the grant `follows`. So the whole
diachronic-identity question becomes two base facts that nobody attributes:

* **(a) which edge is `continue` and which is `copy`**, and
* **(b) who may write `founded(G,_)` with `root(G,I)`**.

Erin's case in s3 shows (a). `e2` and `e3` both come from `e1`, run the same `s1`, and exist at the same time `t2`.
The only difference is the edge label. That label alone makes `e3` a "stranger" whose promises are ultra vires. This
is Nozick's closest-continuer theory with the closeness relation stipulated. Nothing derives the label: not the
content, not the time, not who holds the process handle. `types.lp` rule 15 ("at most one continuation") builds in
Parfit/Shoemaker's non-branching clause. For a symmetric fork (a VM snapshot restored twice), the ontology forces an
arbitrary choice that decides who is bound. The thesis says "Is this the same agent? has no determinate answer, so
the ontology does not ask it". It does ask it. It just asks it of the recorder, one edge at a time.

**Fix (sharpen, don't add):** drop the `continue`/`copy` distinction as a primitive. Make all non-merge edges `succ`.
Let a grant follow `succ` either **exclusively** or **inclusively**. A grant that follows exclusively covers a fork
only if exactly one successor is on-pin and in the lineage, and it lapses on symmetric fission. The fork then becomes
an observable event: out-degree greater than 1. No label is needed. Otherwise, state openly that `continue` is a
*custodial* fact (who holds the running process) and require it to be attested like `record`.

### A2. [critical] Founding is an unauthored sovereign act. The regress of grants ends there, and it is where identity lives.
* `in_force(C) :- founded(C,_)` needs no author, no validity check, and no consent from the debtor.
* s2's `nb` ("by law"), s1's surety bond `bnd` (the insurer never acts to incur it), and s6's charter are all founded
  from nothing.
* In s3, `gm` gives the machine `m` root authority over *two different people's* agent lineages (`d1`, `e1`), and it
  survives the re-weighting at `d5`.
* So, under the party hypothesis, "m" is neither the weights nor a lineage. It is whatever set of lineages the
  founder listed. That is identity by fiat.
* README §8 admits "Founding is axiomatic". But this is not a limit at the edge. It is the ground of every
  attribution. A person's identity is `root(ga,alice0)` closed under `continue`, which the recorder asserts.

**Fix (coalesce):** remove `founded` as a separate way of starting a commitment. Every commitment is `created` by an
invocation. The regress ends in one explicit, per-adjudicator base relation `recognizes(Adj, G)`, a Hartian rule of
recognition. With it:

* law becomes a role whose recognized grant creates `nb`;
* the surety's bond becomes created by an `ins` invocation;
* the charter becomes created by an appointing principal.

This removes a special case and makes the hidden primitive (the adjudicator) a named one. That is the honest price.

### A3. [major] Keys come back through the record. L1 is true only inside the adjudicator's model.
L1 says "not ... possession of a key". But `root(G,I)`, `edge`, and `runs` are "the adjudicator's accepted record"
(§8). In any real system, the only evidence that an invocation lies on a lineage *is* a signature or attestation,
that is, key possession. So L1 holds by construction: attribution = lineage = record. Its empirical claim moves
wholesale into how the record is established. That part is unmodelled, and it is exactly where impersonation and
key theft happen.

**Fix:** make `edge`/`runs`/`does` evidence-backed, the way `record(E,I)` already is. See B3, which coalesces the two.

### A4. [major] Registry mutations are not acts. "Only creditor release ends a commitment" (L3) is not enforced.
* `released(C,T)` is a bare fact. Nothing checks that the creditor, or anyone acting for the creditor, released it.
* The same holds for `revoked(G,T)` (grantor) and `fills(P,R,T1,T2)` (the appointer, who does not exist).
* So a compromised pipeline, or anyone who can write to the registry, discharges obligations with no attributable
  act.
* L3's "no change to the pipeline can discharge" therefore holds only because the pipeline is assumed never to write
  `released`.

**Fix (coalesce):** release, revoke, appoint, and remove are act names: `does(I,A)`, `act_name(A,release)`,
`act_target(A,C)`. They take effect iff `acts_for(I,A,creditor)` (or grantor, or appointer). This reuses `acts_for`
and deletes three unattributed base relations.

---

## B. Are the six sorts minimal? Hidden primitives

### B1. [major] Acts are a seventh sort, and a type/token muddle.
* Acts carry six attribute relations (`act_name`, `act_amount`, `act_obj`, `exclusive`, `act_info`, `act_target`).
  Objects and information items (`X` in `learns`/`knows`) form an eighth sort.
* One constant `A` is both the *content* of a commitment (a type) and the thing an invocation `does` (a token). In
  s3, `x1` and `x2` are two tokens of "deliver item". A branch that delivers `x1` cannot fulfil `sale2`, even to the
  same buyer.
* Time, slots (a hard-coded enum: `weights`/`memory`/`self` are named in the rules), and the adjudicator are further
  unacknowledged primitives.

**Fix:** declare `act` as a sort (act type = name + parameters). Performance is `does(I,A')` where `A'` instantiates
`A`. Say "seven sorts plus time" rather than claiming six.

### B2. [minor] `substrate` can be eliminated.
It exists only to name content for `runs` and `test`. Replace it with `part(I,Slot,H)` on invocations, and with
`test(E,Slot,H)` for evidence. Rollback becomes "every slot equals an ancestor's slots". One sort goes.

### B3. [major] `evidence` should merge into `commitment`. This makes L4 an instance of L3.
* A test is a claim by a tester that content fixed on some slots refrains from `N`. That is a **pinned avoid
  warranty whose debtor is the tester**.
* `horizon` is its expiry. `supports` is exactly `not off_pin`.
* A sanitization attestation is a pinned warranty that the content does not carry `X`.
* A record is a warranty of completeness.

Collapsing the sort does three things:

* it makes assurance accountable (a wrong eval is a breach by the evaluator, with reparation);
* it removes the duplicate slot-matching machinery (`slot_mismatch` vs `pin_ok`);
* it turns L4 into a corollary of L3's pin semantics instead of a separate law.

### B4. [major] Orgs are given bodies. Role and org are mis-sorted.
* s1 gives the insurer `body_ins` with slot `self`. So `types.lp` rule 100 forbids an org from forking. Yet the
  README cites company divisions (Dir. 2017/1132).
* Orgs never act except through filled roles and agents. An org is closer to a *role-structure* than to a person.
* Meanwhile roles are debtors, creditors, and grantors, and have `acts_for` — principals in every respect except
  `type_error 101`.

**Fix:** an org is a principal with **no body lineage**. Its only root authority comes through roles it recognizes.
Org merger and division then become principal-level `succ` relations (needed anyway: see C4). This also answers
successor liability, the "mere continuation" problem in §8.

---

## C. The human as the "degenerate case"

### C1. [critical, bug] Persons forget everything instantly. [run]
* The opaque slot has one constant hash that never changes. So `seen_before(body_hana, T)` holds for any learning
  time after `t0`. `scrubbed/2` then fires on every later person-invocation.
* Probe: Hana `learns(h1,x)`, then `with(h2,q)`, and owes `r` "don't disclose x to q". Result: `knows(h2,x)` is
  **not** derived, `scrubbed(h2,x)` **is** derived, and no violation follows.
* L7's own gloss ("people cannot unlearn") is contradicted by the core.
* The same failure hits any machine whose learning is not reflected in a changed memory hash (in-context/session
  state).

**Fix:** scrubbing must be defined relative to the lineage, not to global "seen before": the invocation's content
must equal that of an *ancestor* that did not know `X`. For `self`, rule scrubbing out, or give each body invocation
a fresh unobservable hash (see C2).

### C2. [critical, bug] A character reference for Hana assures every other person. [run]
All bodies share the hash `opaque`, so `slot_mismatch` never fires between persons. Probe: a test of `body_hana`
yields `assured(kb,b0)` for Bob's promise. "Opaque" was meant to mean *unobservable*. It was encoded as *identical*.

**Fix:** give every body its own hash (`part(body_x,self,h_x)`). Better, per C3, let the hash be unknown per
invocation.

### C3. [major] "No observable change events" is false for humans, so the degenerate case is mis-specified.
* Amnesia, stroke, intoxication, and dementia are observable, recordable changes that law treats as changing
  capacity and assurance.
* The model can only decay assurance by clock. It cannot void a test on a diagnosed event.
* Split-brain (callosotomy) is fission without copying. It is unrepresentable: two `continue` edges violate rule 15,
  and `copy` violates rule 100.

**Fix:** humans are not "one opaque slot". They are **slots whose change events are only sometimes observed**.
Allow `changed(I1,I2,self)` as an attested event. Then `horizon` is simply the prior on unobserved change. Machine
tests need the same thing (see L4 below), so this unifies rather than adds.

### C4. [major] Vitiating conditions are missing. Coercion, fraud, and prompt injection are one gap.
* `acts_for` looks only at lineage, pin, and scope. It never looks at the *conditions of the act*.
* A person under duress, or deceived, is bound. An agent that is prompt-injected by the counterparty into a
  within-scope sale binds its principal.
* Duress, fraud, and incapacity are the human instances. Adversarial inputs are the machine instance.
* This is the most important security case for machine delegates, and the ontology has no place for it. `with(I,Q)`
  and `learns` are inputs but never affect attribution.

**Fix (one default exception, which ASP handles natively):** `acts_for(...)` holds unless `vitiated(I,A)`.
`vitiated` is derived from input provenance: a `merge` edge, or a `with(I,Q)` input, from an invocation acting for
the act's counterparty that the grant does not `follow`. This reuses edges and grants rather than adding a sort.

---

## D. Party vs delegate: held open, or prejudged?

### D1. [critical] Under "delegate", machines are still full deontic subjects. Only liability is switched. [run]
`hyp(machine_party)` feeds only `standing`, and `standing` feeds only `answerer`, `answered`, and `answered_breach`.
Under the delegate hypothesis a machine principal still:

* **founds root authority**: `acts_for(d1, x1, m)` holds with no hypothesis set;
* **incurs commitments and defects**: `defection(pub,mc,6)` holds under both answers;
* **acts as creditor**: it can excuse and trigger, because `excused` and `detached` never test standing;
* **grants** authority to others.

That is the *party* view with judgment-proofness added, not the delegate view. On a genuine delegate view, a machine
cannot be a debtor, creditor, or grantor at all. Its acts are its deployer's or no one's. L8 ("standing changes who
answers, never what binds") is true only because the switch was wired to nothing else. The question is prejudged in
favour of machine agency.

**Fix:** let the switch gate being `principal`-eligible for `kind(machine)`, meaning being a debtor, creditor, or
grantor. Then under delegate, `gm`/`gag`/`gsm` are ill-sorted and the scenarios must say whose acts those are. If
L8 still holds after that change, it is a real result.

### D2. [major] The §6 trichotomy is an artifact of having no appointer.
§6 offers three options: accept unanswered breaches, give machines standing, or forbid uncustodied lineages. The
fourth, standard option is **deployer/appointer liability**: whoever put `mc` into office, or started `sub1`,
answers. It cannot be expressed, because `fills` and `founded` have no author (A2, A4). Once appointment is an act,
the s6 and s4 cases are answered under the delegate hypothesis and the "open question" shrinks a lot. That would be a
sharper result.

### D3. [minor] Standing is global, binary, and keyed on kind.
* It is all machines or none.
* "Person has standing" is an axiom, so minors, wards, and the incapacitated (whose contracts are voidable) are
  unrepresentable.
* Limited standing (can hold assets but not rights) is also unrepresentable.

**Fix:** make `standing(P)` a per-principal recognized fact (`recognizes`, per A2). The only law is `kind(person)` →
standing *by default*. This is simpler and falsifiable.

---

## E. Laws: substantive or definitional?

| Law | Verdict | Hidden real claim | How it could be shown wrong / counterexample |
|---|---|---|---|
| **L1** | Definitional (`acts_for` *is* lineage coverage) | Lineage-scoped grants are the right attribution practice | **Apparent authority** (R3d Agency §2.03): after revocation, the unnotified hotel is protected. The core says ultra vires. **Ratification** (§4.01): no way to adopt an act after the fact, because grants live only forward. Both are routine law. [major] |
| **L2** | Substantive, and **false** as encoded | Authority = responsibility | Consent is encoded as a power grant. In s2, Bob's consent makes the processor's act *Bob's own act*. [run] `imputed(bob, alice_trade_secret)` and `answered(bob0, unsafe)` hold after `learns(a2, alice_trade_secret)`. Hohfeld separates privilege from power, and the ontology merges them. **Fix (coalesce):** permission = an anticipatory, scoped release by the creditor. Reuse the grant's scope fields (root/follows/pin/allows) on `released` instead of on a power. Also note that `acts_for/2` (used for imputation, assurance, and role coverage) ignores scope entirely. [critical] |
| **L3** | Definitional for content (`ended_by` never mentions `runs`) | A registry external to pipelines is practical, and pins capture all legitimate content-sensitivity | Incapacity and frustration are content- or condition-sensitive endings imposed ex post, not pre-declared pins. Unattributed `released` (A4) breaks "only creditor release". |
| **L4** | Definitional (`supports` = slot agreement) | Behaviour is a function of fixed slots, and machine content does not decay | s1 asserts `assured(nda,a2)` for the pipeline that has *just forgotten the NDA*. The test fixed only weights and prompt, so the memory change that caused the breach is by definition irrelevant. Sampling, tool environments, and input distribution shift make same-content behaviour vary. "Rollback restores assurance" fails when the world changed. Machine tests also need a horizon. The human/machine asymmetry is stipulated. [major] |
| **L5** | Definitional given `performs` over `acts_for` | A principal's covered copies are its hands, so an achieve is done once | Per-instance duties ("each instance must log its actions") and capacity limits (§8, no aggregation) do not fit "once by any branch". Mild. |
| **L6** | Claimed as an algebra, but only **caps** attenuate | Sub-grants cannot exceed parents | **Pin laundering** [run]: on w1, `a2` (under `gal`, pinned to w1, follows only `continue`) creates `gl` rooted at the *post-swap* `a3`, with `follows copy` and no pin. Then `covered(gl,a5)` holds for a w2 copy, and its promise `c` is `valid_creation`, binding Alice. `root`, `follows`, and `pin` are not intersected with the parent. The cascade fires on revocation but not on pin lapse. [critical for L3/L6] **Fix:** attenuation must intersect all four scope dimensions: the sub-root must be inside the parent's lineage, `follows` ⊆ parent's, pins are inherited, and `ended_by` includes the parent going off-pin. |
| **L7** | Definitional, and **broken for humans** (C1) | Information follows lineage unless content is scrubbed | See C1. |
| **L8** | Definitional (standing is wired only to answerers, D1) | The party question doesn't affect bindingness | Becomes testable only after the D1 fix. "A person's own acts are always answered" is the axiom `standing(P) :- kind(P,person)`. |
| **L9** | Definitional (`bond` = reparation debtor ≠ defector) | Third-party enforcement is drift-invariant | The surety's payment needs a future act of *its* lineage (`ins1` must `pay_ins`), which can drift too. Drift-invariance needs **pre-performance**: collateral or escrow the creditor can take. That is a **power granted to the creditor**, exercised by the creditor, so it reuses `mode power` and nothing new is needed. Parfit's nobleman gives his wife a power; he does not get her to promise. |
| **L10** | Definitional | Offices can bind successors whatever the kind of holder | **Vacancy**: a duty falling due with no filler is violated with no defector. **Handover at t = deadline − ε**: the successor bears the predecessor's neglect. Appointment and removal powers, the central coordinator question, are absent (D2). Also, the role path of `acts_for` has no root and no pin, which contradicts core.lp line 49: "there is no other source of attribution". |

---

## F. Value drift

### F1. [major] Values are not represented. Only obligations and assurance are.
* The brief asks that agreements "bind as values drift".
* The ontology's answer is that obligations are principal-keyed, so drift cannot discharge them. That answers
  *pipeline* drift for a *human* principal only.
* It says nothing about the **principal's** values drifting:
  * the delegator changes their mind without revoking, so the agent executes stale intent;
  * a machine principal (party hypothesis) is re-weighted, and its root grant follows `continue` through any swap.

That last point is itself a strong, unargued identity claim: the machine party persists through total value change
unless its founder pinned it.

### F2. [major] Irrevocable powers are inexpressible, and they are *the* mechanism for binding a future self.
* L3 lets every grant be ended by "grantor revocation", and `revoked` is unattributed (A4).
* A Ulysses contract, a power coupled with an interest, or the nobleman's wife's power all need a grant that the
  future, drifted grantor *cannot* revoke.

**Fix:** revocation is an act (A4), and a grant may be created with its revoking power withheld from the grantor's
lineage and assigned to a third party. This reuses the grant structure.

### F3. [major] Charter = a set of act-type commitments is too thin.
* Fiduciary charters are *standards* ("act in members' best interest", care, loyalty). They rank permitted acts and
  cannot be listed as `avoid(favor)`.
* A coordinator's charter is mostly this kind of discretion-guiding value.

**Fix (no new sort):** a standard-based commitment is one whose conformance is not derived but *adjudicated*. Its
content is `judged(RoleJ, standard)`, and violation is an act of a designated judging role. This uses the existing
role and act machinery and makes value-conformance an explicit, attributable judgement rather than a missing one.

---

## Ranked summary

1. **C1/C2 (bugs):** the constant `opaque` hash makes persons forget instantly and share each other's assurance.
2. **L6 pin laundering:** attenuation covers only caps, so pins and `follows` can be escaped by self-sub-delegation.
3. **L2 via consent:** encoding permission as a power makes consenters answerable for, and imputed with, the
   processor's conduct.
4. **A1/A2:** identity returns through the `continue` label and unauthored `founded`. Name a rule of recognition and
   make founding a `created` act.
5. **D1/D2:** the delegate hypothesis still treats machines as debtors, creditors, and grantors. The open question is
   prejudged, and deployer liability is missing.
6. **A4:** release, revoke, and fill are unattributed, so L3 is unenforced. Make them acts.
7. **C4:** there are no vitiating conditions (duress/fraud ≈ prompt injection).
8. **F1–F3:** values, irrevocability, and standards-based charters are absent.
9. **B:** acts are a hidden sort. `substrate` can go, and `evidence` → pinned warranty (L4 becomes a case of L3).
   Orgs should have no body.
