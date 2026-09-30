# A. Normative grammars and commitment ontologies: prior-art survey

Scope: normative grammars, commitment ontologies, deontic/contract logics, normative MAS
frameworks, and legal DSLs. The question throughout is what can be reused for an ontology of
human and machine (LLM-agent) coordination in which machine parties can be forked, rolled back,
model-swapped or memory-rewritten.

Verification legend:
- **[V-text]**: I extracted and read the primary text (PDF or source) in this session.
- **[V-meta]**: bibliographic facts or abstract confirmed through publisher, index or search metadata, but I did not read the full text.
- **[RECALLED]**: from background knowledge, consistent with the sources I saw, but not checked against primary text in this session.
- **UNVERIFIED**: could not confirm.

Caution: the WebFetch summarizer made up content twice during this survey. It claimed that
BSPL "supports dynamic substitution of agents within roles", and it expanded BSPL as "Business
Process Specification Language". The primary text supports neither claim. Every claim marked
[V-text] below was checked against text I extracted myself.

---

## 0. Cross-cutting findings (read this first)

1. **Every framework surveyed assumes that the bearer of a norm is an atomic, persistent,
   uniquely identified individual.** Commitments, obligations and role-bindings are indexed by
   an agent or party identifier. None of them has a notion of the bearer being *copied*.
   Identity is a primitive, never a derived or contested fact.
2. **Most frameworks are deliberately opaque about agent internals.** Autonomy is a design
   principle: BSPL says "No agent's private business logic is relevant" [V-text], and Singh 2013
   says each participant "applies its internal policies" [V-text]. As a result, a model swap or a
   memory rewrite is *invisible* to the normative layer. Commitments simply persist. This gives
   continuity for free, but it also means no framework can condition a norm on the substrate or
   on internal state.
3. **The most useful single idea for our purposes is Symboleo's 2020 split of a legal position's
   bearer into three relations: `rightHolder`, `liable` and `performer`.** Each relation can be
   independently shared or transferred [V-text]. This is the closest existing machinery for
   separating "who answers for it" (a principal) from "who executes it" (an invocation or
   substrate).
4. **Hohfeldian power is distinct from permission, and every serious framework preserves that
   distinction.** Singh 2013 and InstAL both keep power apart from permission, so a
   delegate's act can be *valid* (it counts) and still be a *violation* (it was prohibited).
   This is the right semantics for "a delegate exceeded its scope" [V-text for Singh 2013].
5. **Repair has a well-developed formal treatment.** It appears as contrary-to-duty / reparation
   chains: Governatori's `⊗`, L4's `HENCE/LEST`, Symboleo's violation-triggered obligations and
   powers, and IG's "Or else" with vertical nesting. None of these covers *bonds* (staked
   collateral) or repair *across a lineage change*.
6. **Attenuated delegation exists only in weak form.** Singh's `delegate` swaps the entire
   debtor. Symboleo's `subcontract` shares *performance* of a subset of obligations "with
   constraints" but keeps liability with the original party [V-text]. No surveyed framework has
   a monotone-attenuation calculus of the kind capability systems have, where a delegate's
   scope must be ⊆ the delegator's scope.
7. **"Party vs delegate: undetermined" cannot be expressed natively anywhere.** The closest
   hooks are Symboleo's `Unassign` contract state (a role with no bound party) and defeasible
   logic, which can hold conflicting status conclusions without explosion. IG 2.0 constitutive
   statements can *define* what counts as a party, but they cannot hold that status open.

---

## 1. Crawford & Ostrom (1995) "A Grammar of Institutions" (ADICO), and IG 2.0

**Sources**
- Crawford, S. E. S. & Ostrom, E. (1995). A Grammar of Institutions. *American Political Science Review* 89(3): 582–600. [V-meta] (Components as restated in Frantz & Siddiki 2021, [V-text] below.)
- Frantz, C. K. & Siddiki, S. (2021). Institutional Grammar 2.0: A specification for encoding and analyzing institutional design. *Public Administration* 99: 222–247. PDF: https://par.nsf.gov/servlets/purl/10284679 [V-text]
- Frantz & Siddiki, *Institutional Grammar 2.0 Codebook*, arXiv:2008.08937 (v5, revised Oct 2024). https://arxiv.org/abs/2008.08937 [V-meta]
- Book: Frantz & Siddiki (2022), *Institutional Grammar: Foundations and Applications for Institutional Analysis*, Palgrave/Springer. https://link.springer.com/book/10.1007/978-3-030-86372-2 [V-meta]
- nADICO: Frantz, Purvis, Nowostawski, Savarimuthu (2013), "nADICO: a nested grammar of institutions" (cited in IG 2.0) [V-text citation]
- Schlüter & Theesfeld (2010), "The grammar of institutions: the challenge of distinguishing between strategies, norms, and rules", *Rationality and Society* [V-meta]

**Core primitives (ADICO)** [V-text, quoted from IG 2.0 §2]
- **A**ttribute: to whom the statement applies.
- **D**eontic: the prescriptive operator (required, allowed or forbidden: may / must / must not).
- a**I**m: the activity linked to the Attribute.
- **C**ondition: temporal, spatial or procedural parameters for when, where and how.
- **O**r else: the payoff for non-fulfillment. This is the sanction.

**Statement types**
- **Strategy** = A + I + C.
- **Norm** = A + D + I + C.
- **Rule** = all five components (ADICO).

The rule/norm distinction therefore rests on whether a sanction is *institutionally specified*.
Schlüter & Theesfeld (2010) argue that this line is hard to draw in practice.

**IG 2.0 changes** [V-text]
- Three *levels of expressiveness*: IG Core, IG Extended (component-level nesting) and IG Logico (logical disambiguation, role annotation, institutional-function annotation).
- Regulative components are refined:
  - Attributes and Objects are split into identifiers and properties.
  - Object becomes **Direct Object** (B_dir) and **Indirect Object** (B_ind).
  - Condition is split into **Activation Condition** (C_ac, when the statement applies) and **Execution Constraint** (C_ex, which qualifies the action).
  - **Or else** becomes *vertical nesting* (nADICO): the consequence is itself a full institutional statement, e.g. "or else certifier (A) will (D) revoke (I) certification (B_dir) from farmer (B_ind)".
- **Constitutive statements** are new. Their components are:
  - **Constituted Entity** (the definiendum, Searle's "Y");
  - **Constituting Properties** (the definiens, roughly Searle's "X");
  - **Constitutive Function** (the link between them);
  - **Modal** (a general modal operator rather than a deontic);
  - Activation Condition and Execution Constraint;
  - Or else.

  Constitutive statements "define, modify, or otherwise ascribe attributes or characteristics
  to individual entities", including roles and "endowment of authority (e.g., specification
  of institutional/declarative power)". They can be *meta-constitutive*, specifying a policy's
  own initiation, termination, substitution or amendment. IG 2.0 also supports hybrid and
  polymorphic statements.

**Formal semantics**
- None as such. IG is a *coding scheme* for policy text.
- IG Logico moves toward logical disambiguation but does not give a model theory.
- The strategy/norm/rule taxonomy is syntactic.

**Tooling**
- IG-Parser for IG Script, and the GitHub org "InstitutionalGrammar" (e.g. IG-Inception-Layers: https://github.com/InstitutionalGrammar/IG-Inception-Layers) [V-meta]. I did not check whether it runs today (UNVERIFIED).
- The tooling is annotation-oriented, not for checking.

**What it can't express**
- (a) Forking: no. The Attribute is a type-level description of an actor class ("certified organic farmers"), which is actually convenient: forks of a qualifying agent would match the Attribute. But the grammar has no notion of an obligation *instance* being bound to one individual, so it cannot say which copy owes what.
- (b) Internals replaced: no concept of internals. Attribute *properties* could encode "running model X", so an Activation Condition could refer to it. That is a coding convention, not semantics.
- (c) Attenuated delegation: no delegation construct. Constitutive statements can grant authority (power), but nothing enforces that the granted scope ⊆ the granter's scope.
- (d) Undetermined party/delegate status: constitutive statements *define* the conditions under which something counts as a party. There is no representation of the status being undetermined or contested.

**Reuse**
- The **constitutive vs regulative** split maps well onto *charter* (constitutive: what roles exist, who counts as what, who has power) vs *commitment/invariant* (regulative).
- **Activation Condition vs Execution Constraint** is a useful distinction.
- **Or-else as a nested statement** is repair-as-a-norm.

---

## 2. Hohfeld's jural relations

**Sources**
- Hohfeld, W. N. (1913). "Some Fundamental Legal Conceptions as Applied in Judicial Reasoning." *Yale Law Journal* 23: 16. [V-meta, via Symboleo references] There is also the 1917 sequel and the 1919 posthumous book.
- Wenar, "Rights", *Stanford Encyclopedia of Philosophy*: https://plato.stanford.edu/entries/rights/ [V-text]

**Primitives** [V-text, SEP]
- First order:
  - **Privilege** (liberty): A has a privilege to φ iff A has no duty not to φ.
  - **Claim**: A has a claim that B φ iff B has a duty to A to φ.
- Second order:
  - **Power**: A has a power iff A can alter her own or another's Hohfeldian incidents.
  - **Immunity**: B has an immunity iff A lacks the ability to alter B's incidents.

| Incident | Correlative (other party) | Opposite (same party) |
|---|---|---|
| Claim (right) | Duty | No-claim (no-right) |
| Privilege | No-claim | Duty |
| Power | Liability | Disability |
| Immunity | Disability | Liability |

**Why power/liability matters for delegation**
- Delegation is an *exercise of a power*. The delegator changes the normative positions of the delegate, and often of third parties: the delegate gains a power to bind the principal, and the third party becomes liable to having its relations with the principal changed by the delegate.
- The principal is in a position of *liability* to the delegate. The delegate's acts can change the principal's duties. This is exactly the risk in machine delegation: a forked agent that still holds a delegated power can bind the principal.
- *Immunity/disability* is how you state a scope limit: "the delegate is disabled from altering X; the principal is immune from the delegate as to X".
- Revocation of a delegation is itself a power, held by the principal over the delegation relation.
- **Power ≠ privilege**: one can have the power to do something (the act is effective) while having a duty not to exercise it. Singh 2013 makes this explicit (see §3.5). Jones & Sergot (1996), "A formal characterisation of institutionalised power", *Logic Journal of the IGPL* 4(3): 427–443 [V-meta via Symboleo references], formalize power via "counts-as".

**Formal semantics**
- Hohfeld gives none.
- Later formalizations include Kanger–Lindahl theory of normative positions, Jones & Sergot's counts-as, Sergot's work on normative positions, and UFO-L (§6.4) [RECALLED].

**Tooling**: none as such.

**What it can't express**
- (a) Forking: relations are strictly *dyadic between two persons*. A fork produces a third person with no relations, or else ambiguous duplicates. Hohfeld offers no inheritance rule.
- (b) Internals replaced: persons are opaque. There is no issue for Hohfeld, and also no expressiveness.
- (c) Attenuated delegation: *expressible in principle* as power-to-create-powers plus disabilities, but there is no calculus that checks the attenuation.
- (d) Undetermined status: no.

**Reuse**
- Adopt the eight incidents, or at minimum **duty/claim, privilege, power/liability, immunity/disability**, as the vocabulary for *delegation scope*.
- A delegation scope is a bundle of powers plus disabilities.
- Keep power and permission as separate axes.

---

## 3. Munindar Singh and colleagues: commitments, protocols, norms

### 3.1 Singh (1999) "An ontology for commitments in multiagent systems"

- *Artificial Intelligence and Law* 7: 97–113. https://link.springer.com/article/10.1023/A:1008319631231 [V-meta]
- The abstract confirms the following [V-meta]:
  - Commitments are social and directed, in the Hohfeldian tradition.
  - Multiagent systems are viewed as **"spheres of commitment" (SoComs)**, which provide the context for operations.
  - Key operations are identified.
  - The paper distinguishes explicit from implicit commitments.
  - Obligations, taboos, conventions and pledges are captured as kinds of commitments.
- The 1999 form was `C(x, y, G, p)`: debtor x, creditor y, context group G, and condition p. [RECALLED; not checked against full text.]
- Operations: **create, discharge, cancel, release, delegate, assign**. [V-meta (search index of the abstract/related work); matches Singh's slides, §3.2]

### 3.2 Modern commitment form, operations, lifecycle

- The form is **`C(debtor, creditor, antecedent, consequent)`**: if the antecedent holds, the debtor will bring about the consequent. [V-text: Singh, NCSU SOC course slides Fall 2019, https://www.csc2.ncsu.edu/faculty/mpsingh/local/SOC/f19/slides/commitments.pdf]
- Operations, quoted from the slides [V-text]:
  - `create(C(d,c,p,q))` establishes the commitment.
  - `detach(C(d,c,p,q))` turns it into a base (unconditional) commitment.
  - `discharge` satisfies it.
  - `cancel` cancels it (by the debtor).
  - `release` releases the debtor (by the creditor).
  - **`delegate(z, C(d,c,p,q))` replaces d by z as the debtor. "d remains ultimately responsible (in our work)."**
  - **`assign(w, C(d,c,p,q))` replaces c by w as the creditor.**
- Lifecycle for achievement commitments [V-text slides]:
  - Active states: Conditional, and Detached (after the antecedent).
  - Outcomes: Satisfied (consequent holds), Violated (detached and never discharged), Expired (antecedent never holds).
  - Cancel and release lead to termination.
- Maintenance commitments add a Sustained state. The full state set is {Null, Conditional, Expired, Detached, Sustain(B), Terminated, Satisfied, Violated}. This comes from Telang, Singh & Yorke-Smith (2021), "Maintenance of Social Commitments in Multiagent Systems", *AAAI-21*: https://cdn.aaai.org/ojs/17355/17355-13-20849-1-2-20210518.pdf [V-text]
  - That paper defines commitment **strength** as a partial order, with **closure properties**: if a commitment is Conditional, Satisfied or Expired, so is every weaker one; if it is Detached, Sustained, Violated or Terminated, so is every stronger one [V-text].
  - Strength is the closest thing in this literature to a formal "attenuation" ordering, but it orders commitments, not delegated authority.
  - The achievement-commitment lifecycle and goal coupling are in Telang, Singh & Yorke-Smith (2019), "A Coupled Operational Semantics for Goals and Commitments", *JAIR* 65: 31–85. https://jair.org/index.php/jair/article/view/11494 [V-meta]
- Nested commitments are allowed, e.g. `C(Seller, Buyer, pay, C(Shipper, Buyer, T, deliverGoods))` [V-text slides].
- Messages are given meaning by commitment operations, e.g. `Offer` means `create`, `Reject` means `release`, and `Deliver` means `declare` [V-text slides].

### 3.3 Chopra & Singh: alignment, delegation and assignment

- Chopra & Singh (2009), "Multiagent commitment alignment", *AAMAS 2009* [V-meta]. https://eprints.lancs.ac.uk/id/eprint/61311/
  - Gives semantics of commitment operations, including the three-party operations delegate and assign.
  - Specifies messaging patterns that implement them, and weak constraints under which debtor and creditor stay *aligned*, i.e. agree on the commitment's state, in an asynchronous setting.
  - Generalized version: "Generalized commitment alignment", 2015 [V-meta].
- **Relevance**: alignment is the problem that arises when a debtor is forked or rolled back. The creditor's view of the commitment state and the debtor's view diverge. Alignment theory assumes that divergence comes from message delay, not from identity splits or state rollbacks. This is a direct gap. Rollback is essentially "the debtor forgot messages it had sent".
- Cupid (Chopra & Singh) computes commitment states as queries over event stores. Singh's slides title it "Cupid: Unifying Accountability and Traceability — computing states of norms over event stores" [V-text slide title]. Venue: AAAI 2015 [RECALLED].
  - This is the right architecture for *evidence*: the norm state is a function of an append-only event log.

### 3.4 Yolum & Singh (2002): commitments in the event calculus

- "Flexible protocol specification and execution: applying event calculus planning using commitments", *AAMAS 2002*, pp. 527–534. https://dl.acm.org/doi/10.1145/544862.544867 [V-meta]
- Formalizes commitments and their operations in a variant of the event calculus. An event-calculus planner then finds flexible execution paths [V-meta].
- The conditional-commitment notation `CC(x,y,p,q)` is [RECALLED].
- Descendants: Chesani, Mello, Montali & Torroni (2013), "Representing and monitoring social commitments using the event calculus", *JAAMAS* 27(1): 85–130 [V-meta via Symboleo references].

### 3.5 Singh (2013) "Norms as a basis for governing sociotechnical systems"

- *ACM TIST* 5(1). https://dl.acm.org/doi/10.1145/2542182.2542203 [V-meta]
- Extended abstract, IJCAI 2015: https://www.ijcai.org/Proceedings/15/Papers/597.pdf [V-text]
- **Org model**: an STS maps to an **Org**, whose members are **principals** who play **roles**.
  - Principals may be individuals or Orgs, recursively and well-founded.
  - A principal can be a member of several Orgs.
  - Every Org has a distinguished **self role**, played by the Org itself, which adjudicates and sanctions.
  - Each role has a **façade** with three parts:
    - **Qualification**: an eligibility prerequisite for playing the role;
    - **Privilege**: a liberty accorded to the role player;
    - **Liability**: a demand imposed on the role player.
- **Norm schema**: each norm has a subject, an object, a **context** (the Org), an antecedent and a consequent. Subject ≠ object.
- **Five norm types** [V-text]:
  - **Commitment**: the subject (debtor) commits to the object (creditor) to bring about the consequent if the antecedent holds.
  - **Authorization**: the object permits the subject to bring about the consequent when the antecedent holds.
  - **Prohibition**: the object forbids the subject from bringing about the consequent when the antecedent holds.
  - **Sanction**: the object would sanction the subject by bringing about the consequent when the antecedent holds.
  - **Power**: "The object empowers the subject to bring about the consequent by bringing about the antecedent." Power is related to Hohfeld and to Jones & Sergot's counts-as. **"A principal may be empowered to do something while being prohibited from exercising that power"**. In the example, a sysadmin's unapproved account creation *succeeds* but is illicit, and can be revoked and sanctioned.
- Commitment, prohibition and sanction are *liabilities* of the subject. Authorization and power are *privileges*. Each is the dual for the object.
- **Design pattern**:
  - Authorizations apply to *regimented* interactions, which never occur unless authorized.
  - Prohibitions apply to *regulated* interactions, which can occur and invite sanctions.
  - This regimentation-vs-regulation split is central to machine agents. Tool-call gating is regimentation; after-the-fact audit is regulation.
- Norms can reference each other's states (satisfied, violated), which gives reciprocal commitments and sanctions-for-violations. "Coherence" is described as "a relaxed notion of correctness that accommodates restoring a 'good' state after a violation" [V-text]. This is a *repair* notion.

### 3.6 BSPL (Blindingly Simple Protocol Language)

- Singh (2011), "Information-driven interaction-oriented programming: BSPL, the blindingly simple protocol language", *AAMAS 2011*, pp. 491–498. PDF: https://www.csc2.ncsu.edu/faculty/mpsingh/papers/mas/AAMAS-11-IBIOP.pdf [V-text]
- Semantics and verification: Singh (2012), "Semantics and Verification of Information-Based Protocols", *AAMAS 2012*: https://www.csc2.ncsu.edu/faculty/mpsingh/papers/mas/AAMAS-12-BSPL.pdf [V-meta]
- **Principles** [V-text]:
  - *Information orientation*: a protocol = roles + parameters + messages.
  - *Explicit causality*: "there are no hidden flows of causality because there are no hidden flows of information".
  - *No state*: no global state repository; social state is exactly the parameter bindings exchanged. "No agent's private business logic is relevant."
  - Structure is separated from meaning; meaning is commitments, layered on top.
- **Constructs** [V-text]:
  - `protocol Name { role R+ parameter P+ ... }`.
  - Parameters are adorned `⌜in⌝`, `⌜out⌝` or `⌜nil⌝`, and can be marked `key`. Keys identify enactments: "at most one enactment instance may occur per key binding" (uniqueness).
  - Composition is by reference.
  - "a role corresponds to an executing agent whereas a parameter corresponds to a data item."
- **Tooling (runs today)** [V: last commit on git clone]:
  - `gitlab.com/masr/bspl`: last commit 2026-09-21.
  - PyPI `bspl` 1.1.0.
  - Mirror `github.com/shcv/bspl`: last commit 2025-07.
  - Programming models: Kiko (Christie, Singh, Chopra) https://www.lancaster.ac.uk/staff/chopraak/pdfs/Kiko.pdf [V-meta].
  - **Ahoy: LLMs Enacting Multiagent Interaction Protocols** (Joshi, Singh, Chopra, arXiv:2606.05390, June 2026) has LLM agents enact BSPL protocols [V-meta]. According to the summarizer, it does *not* address identity persistence, replacement or forking [UNVERIFIED in primary text].
- **Relevance**:
  - BSPL's information-based view is the best fit for *invocation*: an enactment is identified by its key bindings, and all causality is visible in messages.
  - The "no hidden state" principle means that *rollback of an agent cannot un-send messages*. Protocol state is in the messages, not in agent memory. This is a strong design argument: **anchor commitments in the message/evidence log, never in agent memory.**
  - Gap: if a forked or rolled-back agent re-emits a message with the same key bindings, BSPL treats that as a uniqueness violation or duplicate. This is actually a useful *detector* of fork misbehaviour. But BSPL has no concept of *which* agent instance is legitimately bound to a role.

### 3.7 Protos (requirements as commitments)

- Chopra, Dalpiaz, Aydemir, Giorgini, Mylopoulos & Singh (2014), "Protos: Foundations for Engineering Innovative Sociotechnical Systems", *RE'14*, pp. 53–62. PDF: https://www.lancaster.ac.uk/staff/chopraak/pdfs/protos-2014.pdf [V-text]
- **Primitives** [V-text]:
  - Proposition, Stakeholder, **Team** (one or more stakeholders; subteam relation ⊑);
  - **Commitment** ⊆ T × T × P × P (debtor team, creditor team, antecedent, consequent);
  - **Refinement** on propositions;
  - Conflict;
  - **Requirement** R(τ, π);
  - **Onus** O(τ, π), an assumption that a team takes on the onus of ensuring π.
- Design proceeds by refinement steps that expand the specification and assumption sets until the requirements are accommodated.
- **Relevance**:
  - *Teams as debtors* (a set of stakeholders acting as a unit) is the closest analogue to "a lineage of forks jointly owes C".
  - *Onus* is a lightweight "who bears it" assumption, distinct from commitment.

**Singh cluster: what it can't express**
- (a) Forking: commitments name one debtor. `delegate` moves the whole commitment; it does not duplicate it. Protos teams allow collective debtors but are static design-time entities. Nothing says whether a fork inherits, shares or has no share in a commitment.
- (b) Internals replaced: by principle, internals are irrelevant, so the commitment persists. Singh 2013's *Qualification* is the only hook, and it is stated as a prerequisite to *playing* a role. Continuous re-qualification after a model swap is not modelled [RECALLED; not seen in text].
- (c) Attenuated delegation: `delegate` is all-or-nothing on a single commitment, with the original debtor "ultimately responsible". Scope attenuation would require delegating a *weaker* commitment, and the strength ordering (Telang et al. 2021) could define "weaker". But Singh defines no operator of the form "delegate a weaker version and retain the residual".
- (d) Undetermined status: no. A principal plays a role or it does not. Role adoption is itself a governed interaction, but its state is binary.

---

## 4. Governatori: Formal Contract Logic / defeasible deontic logic

**Sources**
- Governatori (2005), "Representing business contracts in RuleML", *Int. J. Cooperative Information Systems* 14(2–3): 181–216 [V-meta].
- Governatori & Rotolo (2006), "Logic of Violations: A Gentzen System for Reasoning with Contrary-To-Duty Obligations", *Australasian Journal of Logic* 4: 193–215 [V-meta].
- Governatori & Milosevic (2006), "A formal analysis of a business contract language", *IJCIS* 15(4) [V-meta].
- **Governatori, Milosevic & Sadiq (2006), "Compliance checking between business processes and business contracts", *EDOC 2006*, pp. 221–232**, doi:10.1109/EDOC.2006.22. PDF: https://deontik.com/assets/pdf/MilosevicEDOC06.pdf [V-text]

**Core primitives** [V-text, EDOC 2006 §III]
- Propositional letters (state), event symbols with the complex-event operators `;` (sequence), ∧ and ∨.
- Deontic operators O (obligation) and P (permission), *relativized to a subject* (O_S, P_S for Supplier; O_P for Purchaser). FCL builds on "Deontic Logic with Directed Obligations".
- The non-boolean connective **⊗** is the contrary-to-duty (reparation) operator:
  - `O_s A ⊗ O_s B ⊗ O_s C` means the primary obligation is A; if A is violated, s must do B; if B also fails, s must do C.
  - A permission may appear only at the *end* of a chain, because a permission cannot be violated.
- Rules have the form `r: A1,…,An ⊣ C`, where C is an ⊗-expression. Rules are defeasible, with a superiority relation.
- Normal forms (NFCL) make implicit conditions explicit and detect loopholes, deadlocks and inconsistencies.
- Elsewhere, [V-meta via search]: "the subject of the primary obligation and the subject of its reparation can be different". Reparation can therefore shift to another party, e.g. a guarantor.

**Contrary-to-duty and the Chisholm paradox**
- Chisholm (1963), "Contrary-to-duty imperatives and deontic logic", *Analysis* 24: 33–36 [V-meta via IEP: https://iep.utm.edu/contrary-to-duty-paradox/].
- Four intuitively consistent sentences:
  1. You ought to keep your promise.
  2. It ought to be that if you keep your promise, you do not apologise.
  3. If you do not keep your promise, you ought to apologise.
  4. You do not keep your promise.
- In Standard Deontic Logic these derive O(apologise) ∧ O(¬apologise), which violates axiom D.
- FCL's ⊗ builds the primary/reparation structure into the connective, and so avoids this [V-meta].

**Formal semantics**
- Proof theory for defeasible logic extended with deontic modalities and ⊗ (Governatori & Rotolo 2006).
- Possible-worlds semantics for DDL: Governatori, Rotolo & Calardo (2012), "Possible World Semantics for Defeasible Deontic Logic", *DEON 2012* [V-meta].

**Tooling**
- **SPINdle**: an open-source Java defeasible logic reasoner (Lam & Governatori 2009) with modal extensions. SourceForge: https://sourceforge.net/projects/spindlereasoner/ ; a community Rust port at https://github.com/anuna-research/spindle-rust [V-meta]. I did not verify that it runs today (UNVERIFIED).
- **Regorous**: a business-process compliance checker using PCL (Process Compliance Logic, a successor of FCL) on SPINdle. ICAIL 2013 demo: https://dl.acm.org/doi/10.1145/2514601.2514638 [V-meta]. It is a CSIRO/Data61 tool. The CSIRO tools page https://research.csiro.au/bpli/tools/ returned **HTTP 410 Gone**, so availability is UNVERIFIED and likely not publicly maintained.
- **Turnip**: a modern DDL implementation by Governatori, used e.g. for the Australian spent-conviction scheme [V-meta]. Public availability is UNVERIFIED.
- An **ASP implementation of DDL** was published in *KI – Künstliche Intelligenz* (2024): https://link.springer.com/article/10.1007/s13218-024-00854-9 [V-meta].
- **Houdini (unchained)**: a defeasible-logic reasoner, CEUR Vol-3354 [V-meta].
- LegalRuleML is an OASIS XML serialization that carries FCL-style constructs [RECALLED].

**What it can't express**
- (a) Forking: operators are indexed by a subject constant. There is no treatment of the subject splitting.
- (b) Internals replaced: opaque, so not expressible.
- (c) Attenuated delegation: no delegation construct. Permissions are unary modalities, and there is no power operator in basic FCL. Later DDL work adds constitutive rules and counts-as [RECALLED].
- (d) Undetermined status: **defeasible logic is the only surveyed formalism natively suited to contested classification.** Competing defeasible rules can conclude `party(x)` and `delegate(x)`. Without a superiority relation neither is concluded (ambiguity blocking), and the status stays open, with no explosion. This is a real reuse candidate.

**Reuse**
- The **⊗ reparation chain** is the reference semantics for *repair*.
- **Defeasible rules with superiority** are useful for *contested status* and for *charter override* (lex superior/specialis).

---

## 5. Normative MAS frameworks with roles

### 5.1 MOISE / Moise+ / JaCaMo

**Sources**
- Hübner, Sichman & Boissier. Site: https://moise.sourceforge.net/ [V-meta]
- Repo: https://github.com/moise-lang/moise, last commit **2025-07-18** [V: git clone]
- Lecture: Boissier, "Organisation – JaCaMo", https://www.emse.fr/~boissier/enseignement/defiia/up9-19/pdf/9-lecture-organisation-jacamo.pdf [V-text]
- JaCaMo: Boissier et al. (2013), "Multi-agent oriented programming with JaCaMo", *Science of Computer Programming* [V-meta]

**Primitives**
- **Structural specification**: roles, groups, links, compatibilities and cardinalities.
- **Functional specification**: social schemes, goals and **missions** (sets of goals).
- **Normative specification**: norms that link roles to missions, as obligations or permissions [V-meta].
- At runtime, via the ORA4MAS artifacts GroupBoard and SchemeBoard [V-text]:
  - GroupBoard has observable property `player: list of play(agent, role, group)` and operations `adoptRole(role)` and `leaveRole(role)`.
  - SchemeBoard has `commitments: list of commitment(agent, mission, scheme)`, operations `commitMission` and `leaveMission`, and active `obligation(agt, norm, goal, deadline)` and `permission(agt, norm, goal, deadline)` facts.
  - Moise specifications are translated into **NPL (Normative Programming Language)**, which generates `oblCreated`, `oblFulfilled`, `oblUnfulfilled`, `oblInactive` and `normFailure` signals.
  - Example NPL norm: `norm n1: plays(A,writer,G) -> obligation(A,n1,plays(A,editor,G), ...)`.

**Role vs role-player**
- Clean at the specification level: the role is type-level, and `play(agent, role, group)` is a runtime fact.
- **But obligations are instantiated per agent**: `obligation(agt, ...)`. When an agent leaves a role, obligations created for it become inactive or unfulfilled for *that agent*. A newly adopting agent gets fresh obligations from the norms.
- There is **no handover of in-flight obligations**, and no liability survives departure. Whether `leaveRole`/`leaveMission` is blocked while goals are pending is UNVERIFIED; I recall that Moise+ restricts leaving missions in some conditions.

**Tooling**: runs today. It is part of the JaCaMo (Jason + CArtAgO + Moise) distribution.

**Replacement**
- Replacement = `leaveRole` by A, then `adoptRole` by B.
- B is bound only by *future* norm activations. A's pending obligations become orphaned, or unfulfilled for A.
- A model swap *inside* A is invisible, because the agent identifier is unchanged.

### 5.2 OperA / OperettA (Dignum)

**Sources**
- V. Dignum (2004), PhD thesis, "A Model for Organizational Interaction: Based on Agents, Founded in Logic", Utrecht: https://dspace.library.uu.nl/bitstream/handle/1874/890/full.pdf [V-meta]
- Dignum & Aldewereld, "OperettA: Organization-Oriented Development Environment", CEUR Vol-627: https://ceur-ws.org/Vol-627/lads_2.pdf [V-text]

**Primitives** [V-text]
- **Organizational Model (OM)**: roles, objectives, norms, and interaction structure (scenes and scene scripts).
- **Social Model (SM)**: "maps organizational roles to agents and describes agreements concerning the role enactment ... in **social contracts**."
- **Interaction Model (IM)**: "role-enacting agents" agree on **interaction contracts**.

**Role vs role-player**
- This is the most explicit separation among the MAS frameworks. The *binding of an agent to a role is itself a contract*, the social contract, with its own negotiated terms.
- It is formalized in the temporal deontic logic LCR (Logic for Contract Representation) in the thesis [RECALLED].

**Tooling**: OperettA was an Eclipse-based environment around 2010. Current availability is UNVERIFIED and it is likely unmaintained.

**Replacement**
- Replacing an agent means ending one social contract and forming another.
- Interaction contracts were made *between role-enacting agents*, so they do not transfer automatically. The thesis's treatment of renegotiation on replacement is UNVERIFIED.

**Reuse**: "role enactment as a contract" maps directly to our *bond*/*charter* between a principal and a role.

### 5.3 Electronic Institutions (IIIA-CSIC)

**Sources**
- Esteva, Rodríguez-Aguilar, Rosell & Arcos (2004), "AMELI: An Agent-based Middleware for Electronic Institutions", *AAMAS 2004* [V-meta; PDF server returned 503].
- ISLANDER editor, AAMAS 2002: https://dl.acm.org/doi/10.1145/545056.545069 [V-meta]

**Primitives** [V-meta]
- A **dialogical framework** (ontology, roles, illocutions).
- **Scenes**: multi-role conversation protocols.
- A **performative structure**: a network of scenes connected by transitions, which also governs role flow, i.e. which roles may move to which scenes.
- **Normative rules**: obligations incurred by uttering illocutions.

**Role vs role-player; handling replacement**
- AMELI assigns **one governor per external agent**. External agents communicate only with their governor, and the governor regiments their behaviour [V-meta].
- Each agent enters with a role, and role changes follow the performative structure.
- This is *full regimentation*: an agent cannot do what the institution does not allow.
- Replacement mid-scene is not supported as a primitive. Any obligations would be attached to the agent identifier [RECALLED].

**Tooling**: EIDE (ISLANDER, AMELI, SIMDEI) was Java, from the 2000s. Current availability is UNVERIFIED and it is likely unmaintained.

**Reuse**: the **governor** pattern, a per-agent institutional proxy, is precisely the "harness that mediates an LLM agent's tool calls" pattern. It shows that regimentation can be applied per invocation.

### 5.4 InstAL (Institutional Action Language)

**Sources**
- Cliffe, De Vos & Padget (2006), "Answer set programming for representing and reasoning about virtual institutions", *CLIMA VII* [V-meta].
- Cliffe, De Vos & Padget (2007), "Specifying and Reasoning About Multiple Institutions", *COIN* [V-meta].
- Padget, ElDeen Elakehal, Li & De Vos (2016), "InstAL: An Institutional Action Language", in *Social Coordination Frameworks for Social Technical Systems*, Springer: https://link.springer.com/chapter/10.1007/978-3-319-33570-4_6 [V-meta]
- Related: Li, Balke, De Vos, Padget, Satoh (2013/2017), multi-level governance compliance, *JAAMAS*: https://link.springer.com/article/10.1007/s10458-017-9363-y [V-meta]

**Primitives** [V-meta]
- **Exogenous (external) events** vs **institutional events**. External events *generate* institutional ones: a counts-as relation, conditional on the event being empowered.
- Fluents are **initiated/terminated** by institutional events, in event-calculus style.
- Distinguished fluents:
  - `pow(e)`: event e is empowered and so has institutional effect;
  - `perm(e)`: e is permitted;
  - **`obl(e, d, v)`**: e must occur before deadline event d, or violation event v is generated.
- Violation events: a non-permitted event, or a missed deadline.
- Multiple interacting institutions are linked by **bridge institutions** (cross-generation, cross-initiation).

**Formal semantics**
- A set-theoretic model with a formal translation to AnsProlog (ASP). The answer sets are institutional traces [V-meta].

**Tooling**
- Earlier releases were at http://www.cs.bath.ac.uk/instal (per the paper), running on clingo.
- **I could not find a current public repository**: GitHub topic searches and guessed repo names failed. Current availability is UNVERIFIED.

**Role vs role-player**
- There is no first-class role. Agents appear as typed arguments of events (e.g. `pay(Agent, …)`).
- **Obligations are undirected**: `obl` has no creditor, and the bearer is implicit in the event's arguments.

**Handling replacement**: none as a primitive. It would be encoded manually through events that transfer fluents.

**Reuse**
- The **pow/perm/obl triad** with *explicit violation events* is a clean, minimal, machine-checkable core.
- The **bridge institution** idea (norms spanning two normative systems) maps to cross-charter coordination.
- ASP gives a simple route to a machine-checkable spec: enumerate traces and check invariants.

**MAS frameworks: what they can't express**
- (a) Forking: none. Identity is the agent identifier, so a fork is a new agent with no obligations. Or, if the fork keeps the identifier (a common LLM deployment reality), the frameworks silently conflate two instances. BSPL-style key uniqueness is the only detector.
- (b) Internals replaced: invisible in all of them. OperA's social contract *could* include qualification terms, and Moise role compatibility constraints are about roles, not substrates.
- (c) Attenuated delegation: absent. Moise has no delegation. EI and InstAL could encode `pow` grants, with no attenuation check.
- (d) Undetermined status: absent.

---

## 6. Legal DSLs and legal core ontologies

### 6.1 Symboleo (checked carefully)

**Sources**
- Sharifi, Parvizimosaed, Amyot, Logrippo & Mylopoulos (2020), "Symboleo: Towards a Specification Language for Legal Contracts", *IEEE RE 2020*, pp. 364–369. https://ieeexplore.ieee.org/document/9218159/ ; PDF https://cyberjustice.openum.ca/files/sites/102/1.-Symboleo-Towards-a-Specification-Language-for-Legal-Contracts.pdf [V-text]
- **Parvizimosaed, Sharifi, Amyot, Logrippo & Mylopoulos (2020), "Subcontracting, Assignment, and Substitution for Legal Contracts in Symboleo", *ER 2020* (LNCS), https://link.springer.com/chapter/10.1007/978-3-030-62522-1_20 ; PDF https://www.site.uottawa.ca/~luigi/papers/20_ER.pdf** [V-text]
- Parvizimosaed, Roveri, Rasti, Amyot, Logrippo, Mylopoulos, et al. (2022), "Specification and analysis of legal contracts with Symboleo", *Software and Systems Modeling* 21(6): 2395–2427. https://link.springer.com/article/10.1007/s10270-022-01053-6 [V-meta; paywalled]
- Parvizimosaed, Roveri, Rasti, Anda, Alfuhaid, Amyot, Logrippo & Mylopoulos (2024), "SymboleoPC: checking properties of legal contracts", *SoSyM*. https://link.springer.com/article/10.1007/s10270-024-01180-2 [V-meta]
- Symboleo2SC generates Hyperledger Fabric smart contracts [V-meta].

**Ontology** [V-text, RE 2020]
- Symboleo refines **UFO-L**. The concepts are:
  - **Contract**: "a collection of obligations and powers between two or more roles, which are assigned to parties during execution";
  - **Asset**;
  - **Legal Position**: exactly two kinds, obligation and power;
  - **Obligation**: "legal duty of a debtor towards a creditor to bring about a certain legal situation (consequent) when another legal situation (antecedent) holds". Obligations can be *surviving* (outlive the contract) and are instantiated by a **trigger**;
  - **Legal Situation**: a situation that holds over an interval;
  - **Event**: instantaneous, with pre- and post-state situations;
  - **Power**: "the right of a party to create, change, suspend or extinguish legal positions", with a trigger and an antecedent;
  - **Role**: "characterized by collections of obligations and powers";
  - **Party**: "a legal agent ... who owns assets and who is assigned roles in contracts".

**Syntax** [V-text]
- `Oid: [trigger →] O(debtor, creditor, antecedent, consequent)` and `Pid: [trigger →] P(creditor, debtor, antecedent, consequent)`.
- The debtor and creditor are **roles**, bound to parties at instantiation.
- This is Singh's commitment form lifted to roles, plus a power.
- Power consequents use `suspends(o)`, `resumes(o)`, `terminates(o | self)`, `discharge`, and also trigger new obligations (CTD).
- Constraints include `NOT(isEqual(buyer, seller))` and `CannotBeAssigned(o)`.

**Lifecycles** [V-text, RE 2020 text and the SymboleoPC nuXmv library]
- Contract: `{not_created, form, inEffect, suspension, unassign, sTermination, unsTermination}`.
  - **`unassign`** is entered when a party is revoked ("the assigner withdraws") and is left when a new party is assigned.
  - Suspending the contract suspends all of its obligations and powers.
- Obligation: `{not_created, create, inEffect, suspension, discharge, fulfillment, violation, unsTermination}`. "Discharge" here means *cancelled because the antecedent expired*, which corresponds to Singh's *expired*.
- Power: `{not_created, create, inEffect, suspension, sTermination, unsTermination}`.

**Formal semantics**
- 27 axioms over statecharts, using event-calculus and Allen-style predicates: `e within s`, `occurs(s,T)`, `initiates(e,s)`, `terminates(e,s)`, `happens(e,t)`, `holdsAt(s,t)`.
- They were first prototyped in Prolog (a compliance checker).

**Execution-time operations** [V-text, ER 2020, the key paper for us]
- The ontology gains three relations between Party and Legal Position: **`rightHolder(x,p)`, `liable(x,p)` and `performer(x,p)`**.
- On activation [V-text, Axioms 1–4]:
  - the debtor-bound party becomes liable for and performer of the obligation;
  - the creditor-bound party becomes rightHolder;
  - for a power, the creditor is rightHolder and performer, and the debtor is liable.
- Six primitive operations: **`shareR/shareL/shareP(x, p)`** add a party as rightHolder, liable or performer; **`transferR/transferL/transferP(x, p_old, p_new)`** move the relation.
- Derived legal operations:
  - **Assignment of rights**: `assignR({x1..xn}, p_old, p_new)` = transferR on each.
  - **Contractual party substitution**: `substituteC(c, r, p_old, p_new)` requires *the consent of all original parties and of p_new*. It rebinds role r to p_new and transfers R, L and P on all active positions [Axiom 8].
  - **Subcontracting**: `subcontract({o1..om} to {{c1,pa1},…} with {constr1..constrn})` *shares performance* of the listed obligations with subcontractors through subcontracts, under constraints. Successful termination of a subcontract brings about the consequent of the delegated obligation. The paper then discusses what violation or suspension of a subcontract does to the original [V-text, partially read].
  - The intro also names delegation and novation. Only assignment, substitution and subcontracting are formalized in that paper [V-text].
- In the SymboleoPC nuXmv library [V: repo file `SymboleoPC-library.nuXmv`]:
  - the `Party` module has independent `l_state` (liable), `r_state` (rightHolder) and `p_state` (performer) with add/remove inputs;
  - it has the **invariant `!(_is_rightHolder & _is_liable)`**: a party cannot be both creditor-side and debtor-side of the same position.

**Tooling**
- GitHub org https://github.com/Smart-Contract-Modelling-uOttawa, with repos Symboleo-IDE, SymboleoPC, Symboleo2SC-SymboleoPC-Combined, Symboleo-Compliance-Checker, SymboleoAC-Web.
- Last commits: SymboleoPC **2024-10-08** and Symboleo-IDE **2024-10-10** [V: git clone].
- The toolchain is Xtext/Eclipse → nuXmv (LTL/CTL), plus Prolog compliance checking and Hyperledger Fabric code generation.
- "Runs today" is plausible but UNVERIFIED. It needs Eclipse/Xtext and nuXmv, which is free for non-commercial use.

**What it can't express**
- (a) Forking:
  - **Partially expressible, and the best available.** A fork could be modelled as `shareP(x, fork)` (the fork is also a performer) and/or `shareL(x, fork)` (joint liability), leaving the original rightHolder unchanged.
  - But there is **no operation that duplicates a party**, and no rule about which positions a fork inherits by default.
  - Liability splitting (joint vs several) is not modelled; "sharing" liability is just set membership.
- (b) Internals replaced: invisible. The party is an opaque legal agent. The closest approximation is contract-level `suspension` plus re-`assign`. That is heavy, and the substitution axiom requires consent of all parties, which is actually a nice model of "model swap requires counterparty consent".
- (c) Attenuated delegation:
  - **Closest existing construct.** Subcontracting delegates *performance of a chosen subset of obligations* under *constraints*, while *liability stays with the original party*. That is delegation with retained responsibility, as in Singh's "d remains ultimately responsible".
  - What's missing is any check that the delegate's powers are ⊆ the delegator's. Powers are only share/transfer. There is no "weaker power", and no constraint language over scope.
- (d) Undetermined status:
  - The **`unassign`** state (role temporarily unbound) is the only formal representation in the survey of "no party currently holds this role".
  - But it cannot say "x holds the role *either* as party *or* as performer-for-someone-else; not yet determined".
  - Also, the `performer` vs `liable` split does let you say "x is performer but not liable", which is *delegate-like* status, as opposed to "x is liable", which is *party-like* status. The *question* could be phrased as uncertainty over which of those relations holds. Symboleo itself has no uncertainty.

**Reuse**: see the summary. Adopt the R/L/P split, the lifecycle state sets, `unassign`, surviving obligations, and consent-gated substitution.

### 6.2 Catala

**Sources**
- Merigoux, Chataing & Protzenko (2021), "Catala: A Programming Language for the Law", *PACMPL* 5 (ICFP), https://dl.acm.org/doi/10.1145/3473582 ; arXiv:2103.03198 [V-text abstract]
- Repo: https://github.com/CatalaLang/catala, last commit **2026-09-30** [V: git clone]; actively maintained.

**Primitives**
- Scopes, which are function-like units with input/output variables.
- Literate programming interleaved with statute text.
- Exceptions and priorities based on **prioritized default logic** (the "default calculus") [RECALLED; the paper's core].
- The compiler's core steps are proven correct in F* [V-text abstract].

**Target**
- Computational statutes: tax and benefits, "algorithms in disguise". **No deontic modalities, no parties, no obligations, no time-indexed violation.**

**What it can't express**
- (a)–(d): out of scope entirely. Catala computes entitlements; it does not track commitments between parties.
- The default-logic exception mechanism is a clean way to write *charter overrides*, e.g. a general rule plus specific exceptions.

### 6.3 L4 (Legalese / SMU CCLAW)

**Sources**
- Docs: https://legalese.com/l4/concepts/legal-modeling/regulative-rules [V-text via summarizer]
- Repos: https://github.com/legalese/l4-ide, last commit **2026-09-30**; https://github.com/smucclaw/dsl, last commit 2025-06 [V: git clone].

**Primitives**
- Regulative rules: `PARTY p MUST|MAY|SHANT action WITHIN deadline HENCE <next> LEST <next>`, with `PROVIDED` guards.
- `FULFILLED` and `BREACH BY p [BECAUSE …]` are terminal outcomes.
- `RAND`/`ROR` compose obligations conjunctively or disjunctively.
- **HENCE/LEST is a reparation-chain / contract-automaton structure.** It is operationally equivalent to ⊗-chains with deadlines.
- Rules are evaluated over event traces `(party, action, timestamp)`, with outcomes FULFILLED, BREACH or a residual obligation [V-text via summarizer].
- New in Sept 2026 [V-meta via PR pages]:
  - a **blame set**: a breach can name *every* party that failed; `BREACH BY` accepts a list (PR #411, merged 2026-09-16);
  - quantified obligations `EVERY Tenant t IN tenants WHOSE …` over a "cast", with "anchored WITHIN" relative to lifecycle events such as `THE JOIN` (PR #505, 2026-09-28).

**Formal semantics**: operational, via trace evaluation. There is a `#TRACE` simulator and a state-graph visualizer. I did not verify whether there is a model-checking backend (UNVERIFIED).

**Tooling**: runs today and is actively developed (IDE and VS Code extension).

**What it can't express**
- (a) Forking: `EVERY … IN cast` with a JOIN anchor can quantify over a *dynamic population* of parties, e.g. forks joining. The blame set can name multiple failing parties. Together these are the nearest thing to "all members of a lineage owe C; breach blames the failing instances". Identity-splitting semantics, however, are absent.
- (b) Internals replaced: no.
- (c) Attenuated delegation: no delegation construct was found in the docs (per summarizer; UNVERIFIED in full).
- (d) Undetermined status: no.

### 6.4 UFO-L (Griffo, Almeida, Guizzardi)

**Sources**
- Griffo, Almeida & Guizzardi (2015), "Towards a Legal Core Ontology based on Alexy's Theory of Fundamental Rights", *MWAIL@ICAIL 2015* [V-meta].
- Griffo, Almeida & Guizzardi (2018), "Conceptual Modeling of Legal Relations", *ER 2018*, https://link.springer.com/chapter/10.1007/978-3-030-00847-5_14 [V-meta].
- Griffo, Almeida, Lima, Sales & Guizzardi, "Legal powers, subjections, disabilities, and immunities: Ontological analysis and modeling patterns", *Data & Knowledge Engineering* 148, 102219 (2023) [V-meta via citation].
- Project page: https://nemo.inf.ufes.br/en/projetos/ufo-l/ [V-meta]
- Secondary summary: Blums & Weigand, "Applying UFO-L Legal Core Ontology to Bridge Legal and Accounting Domains", CEUR Vol-4129 [V-text].

**Primitives** [V-text, secondary]
- UFO-L uses UFO's theory of *relators*, which are reified relationships composed of *modes*. It defines **four legal relators of correlative legal positions between two legal agents**:
  - (Claim-)Right ↔ Duty;
  - Permission ↔ No-Right;
  - **Power ↔ Subjection**: to create, change or extinguish a legal position via institutional actions;
  - Disability ↔ Immunity.
- Built on Alexy (rights to actions/omissions) and Hohfeld.
- Via UFO, **roles are anti-rigid types** played by rigid kinds, and relators are *founded* on events, e.g. contract signing [RECALLED from UFO/OntoUML].

**Formal semantics**: OntoUML/UFO axiomatization, which is first-order. Checking is by OntoUML tooling such as Alloy-based simulation [RECALLED]. I did not verify a maintained UFO-L model artifact (UNVERIFIED). gUFO (the OWL implementation of UFO) exists [RECALLED].

**What it can't express**
- (a) Forking: UFO identity principles come from rigid *kinds*, and each individual has exactly one kind with its identity principle. Fission is a known hard case in UFO-style ontologies. There is no treatment.
- (b) Internals replaced: UFO has *modes* and *qualities* that can change while the bearer persists. This is the right *ontological* slot: a model/weights/memory would be a mode of the agent. But UFO-L does not tie legal positions to such modes.
- (c) Attenuated delegation: Power↔Subjection is expressible, but there is no attenuation calculus.
- (d) Undetermined status: no.

**Reuse**
- **Relator** (a reified relation whose existence depends on its relata and on a founding event) is the right metamodel for *commitment*, *bond* and *delegation*: each is a relator founded on an invocation or event.
- **Anti-rigid role vs rigid kind** is the right metamodel for role vs principal.

---

## 7. Mapping to our candidate primitives

| Our primitive | Best prior art | Notes / gap |
|---|---|---|
| principal | Singh 2013 *principal* (individual or Org, recursive); Symboleo *Party*; UFO rigid kind | None handles fission or merger of principals |
| role | Moise role / Singh role façade (qualification, privilege, liability) / Symboleo Role | Reuse the façade triple; "qualification" is the hook for substrate requirements |
| charter | IG 2.0 **constitutive** statements; Singh Org spec plus self role; OperA OM | Charter = constitutive rules plus the powers to amend them (meta-constitutive) |
| delegation scope | Hohfeld power/immunity/disability; Symboleo subcontract `with constraints`; Singh `delegate` | **No attenuation calculus anywhere** |
| commitment | Singh `C(debtor, creditor, antecedent, consequent)` plus lifecycle; Symboleo O(…) over roles | Reuse as-is; add the R/L/P split |
| substrate | none | **Gap.** Only UFO modes and Singh "qualification" gesture at it |
| lineage | none (Protos *teams*, L4 `EVERY … IN cast`/JOIN are weak analogues) | **Gap** |
| invocation | BSPL enactment (key-identified); EI scene execution; AMELI governor per agent | BSPL key uniqueness detects duplicate forks |
| invariant | Symboleo constraints plus LTL/CTL (nuXmv); Moise norms; Singh commitment closure properties | Reuse the LTL/CTL style |
| evidence | InstAL/EC event traces; Cupid (norm state = query over event store); BSPL "no state beyond messages" | **Anchor norm state in an append-only log, never in agent memory**, so rollback cannot erase commitments |
| conformance | Chopra–Singh commitment *alignment*; Regorous compliance checking; Symboleo compliance checker | Alignment assumes delay, not rollback/fork |
| bond | IG "Or else"; Singh *sanction*; Symboleo assets/pre-conditions; OperA social contract | No stake/collateral primitive |
| defection | violation (Singh V state; InstAL violation events; Symboleo violation; L4 BREACH/blame set) | Reuse |
| repair | Governatori ⊗; L4 HENCE/LEST; Symboleo violation-triggered O/P (CTD); Singh "coherence" | Reuse ⊗/LEST semantics |

---

## 8. Consolidated URL list

- Crawford & Ostrom 1995 (APSR): cited via https://dlc.dlib.indiana.edu/dlc/bitstream/handle/10535/762/Schlueter_108502.pdf and the IG 2.0 paper
- IG 2.0 paper: https://par.nsf.gov/servlets/purl/10284679
- IG 2.0 codebook: https://arxiv.org/abs/2008.08937
- IG book: https://link.springer.com/book/10.1007/978-3-030-86372-2
- SEP Rights (Hohfeld): https://plato.stanford.edu/entries/rights/
- Singh 1999: https://link.springer.com/article/10.1023/A:1008319631231
- Singh SOC slides (commitment operations): https://www.csc2.ncsu.edu/faculty/mpsingh/local/SOC/f19/slides/commitments.pdf
- Telang, Singh, Yorke-Smith AAAI-21: https://cdn.aaai.org/ojs/17355/17355-13-20849-1-2-20210518.pdf
- Telang, Singh, Yorke-Smith JAIR 2019: https://jair.org/index.php/jair/article/view/11494
- Chopra & Singh 2009 alignment: https://eprints.lancs.ac.uk/id/eprint/61311/
- Yolum & Singh 2002: https://dl.acm.org/doi/10.1145/544862.544867
- Singh 2013 TIST: https://dl.acm.org/doi/10.1145/2542182.2542203 ; IJCAI-15 abstract: https://www.ijcai.org/Proceedings/15/Papers/597.pdf
- BSPL 2011: https://www.csc2.ncsu.edu/faculty/mpsingh/papers/mas/AAMAS-11-IBIOP.pdf ; 2012: https://www.csc2.ncsu.edu/faculty/mpsingh/papers/mas/AAMAS-12-BSPL.pdf
- BSPL code: https://gitlab.com/masr/bspl ; https://github.com/shcv/bspl
- Kiko: https://www.lancaster.ac.uk/staff/chopraak/pdfs/Kiko.pdf
- Ahoy (LLMs + BSPL, 2026): https://arxiv.org/html/2606.05390
- Protos: https://www.lancaster.ac.uk/staff/chopraak/pdfs/protos-2014.pdf
- Governatori, Milosevic, Sadiq EDOC 2006 (FCL, ⊗): https://deontik.com/assets/pdf/MilosevicEDOC06.pdf
- Governatori RuleML 2005: https://www.researchgate.net/publication/37617796_Representing_Business_Contracts_in_RuleML
- Chisholm CTD (IEP): https://iep.utm.edu/contrary-to-duty-paradox/
- SPINdle: https://sourceforge.net/projects/spindlereasoner/ ; https://github.com/anuna-research/spindle-rust
- Regorous: https://dl.acm.org/doi/10.1145/2514601.2514638
- DDL in ASP (2024): https://link.springer.com/article/10.1007/s13218-024-00854-9
- Moise: https://moise.sourceforge.net/ ; https://github.com/moise-lang/moise ; lecture https://www.emse.fr/~boissier/enseignement/defiia/up9-19/pdf/9-lecture-organisation-jacamo.pdf
- OperA thesis: https://dspace.library.uu.nl/bitstream/handle/1874/890/full.pdf ; OperettA: https://ceur-ws.org/Vol-627/lads_2.pdf
- AMELI: https://www.iiia.csic.es/~jar/papers/2004/031_estevam_AMELI.pdf ; ISLANDER: https://dl.acm.org/doi/10.1145/545056.545069
- InstAL: https://link.springer.com/chapter/10.1007/978-3-319-33570-4_6 ; multi-level governance: https://link.springer.com/article/10.1007/s10458-017-9363-y
- Symboleo RE 2020: https://cyberjustice.openum.ca/files/sites/102/1.-Symboleo-Towards-a-Specification-Language-for-Legal-Contracts.pdf
- Symboleo ER 2020 (subcontracting/assignment/substitution): https://www.site.uottawa.ca/~luigi/papers/20_ER.pdf
- Symboleo SoSyM 2022: https://link.springer.com/article/10.1007/s10270-022-01053-6
- SymboleoPC SoSyM 2024: https://link.springer.com/article/10.1007/s10270-024-01180-2
- Symboleo code: https://github.com/Smart-Contract-Modelling-uOttawa
- Catala: https://arxiv.org/abs/2103.03198 ; https://github.com/CatalaLang/catala
- L4: https://legalese.com/l4/concepts/legal-modeling/regulative-rules ; https://github.com/legalese/l4-ide
- UFO-L: https://nemo.inf.ufes.br/en/projetos/ufo-l/ ; ER 2018: https://link.springer.com/chapter/10.1007/978-3-030-00847-5_14 ; application: https://ceur-ws.org/Vol-4129/paper2.pdf
