# Slice C: Identity, Lineage, Delegation, and AI-Agent Governance

Prior-art survey for a minimal ontology of commitments between human and machine parties,
where the "decision-maker" is a pipeline (weights, system prompt, scaffold, memory, session,
fork lineage) whose components can be copied, rolled back, merged, or swapped independently.

Verification legend:
- [V] = fetched/confirmed primary or authoritative page during this survey (Sept 2026).
- [S] = confirmed via search-result metadata only (title/authors/venue), content paraphrased from abstracts.
- [M] = from background knowledge, not re-verified in this session; treat as needing a check before citing.

---

## 0. Cross-cutting takeaways (read this first)

1. **Nobody has solved individuation under forking for agreements.** PROV-O can record
   lineage but has no deontics; capability systems give monotone attenuation but treat any
   key-holder as the principal (so a fork *is* the principal); AI-governance papers attach
   IDs to "instances" but do not say what happens to obligations when an instance forks,
   is rolled back, or has its model swapped; legal-personhood papers assume a stable
   "addressable" locus. Leibo et al. (2025) explicitly lean on "addressability" and do not
   address copying [V]. Salib & Goldstein's EA-forum summary does not address individuation [V
   for the summary; full paper not read, M].
2. **Two viable identity strategies emerge from philosophy, and they map onto two engineering patterns:**
   - *Non-branching / closest-continuer* (at most one successor inherits): maps to
     "single-writer lineage with an explicit successor designation" (like a key rotation
     that names the new key, or a git branch with one designated `main`).
   - *Parfit / Lewis / stage-theory* (identity is not what matters; all R-related successors
     inherit): maps to "commitments bind every descendant in the derivation DAG" (broadcast
     inheritance), i.e., obligation follows `wasDerivedFrom*` rather than identity.
   A minimal ontology should probably make identity *not* the load-bearing notion and
   instead define obligation inheritance over an explicit lineage relation, with a
   declared inheritance policy per commitment (Parfit's move, operationalized).
3. **Capability attenuation gives a clean, provable subset guarantee for *authority*, but
   not for *obligation*.** Obligations must flow the other way (a delegate's commitments
   may bind the principal; a fork's commitments may or may not bind siblings). There is no
   off-the-shelf "attenuation" analogue for duties. Biscuit's Datalog is the closest
   substrate for expressing both (facts + rules + checks with provenance-scoped trust).
4. **Game theory for transparent/simulable agents shows commitment can be *endogenous*
   (programs that condition on each other), but assumes the program seen is the program
   that plays.** Forking, rollback and model swap break exactly that assumption; the
   crypto literature on *resettable* protocols and *fork consistency* is the right
   adversary model to import.
5. **Delegate vs party:** current law (Restatement (Third) of Agency §1.04 cmt. e; UETA §14)
   treats software as an *instrumentality* of a person, so the human/org is the party.
   Kolt uses agency law analytically only. O'Keefe et al. propose "legal actors" with duties
   but not rights. Salib & Goldstein propose contract/property/tort rights for AIs (party
   status). Leibo et al. propose pragmatic, bundle-of-obligations personhood with in-rem
   style enforcement. None specify which pipeline component is the party.

---

## 1. W3C PROV-O (provenance ontology)

Sources:
- PROV-O, W3C Recommendation, 30 April 2013 — https://www.w3.org/TR/prov-o/ [V]
- PROV-DM — https://www.w3.org/TR/prov-dm/ [V]
- PROV-CONSTRAINTS — https://www.w3.org/TR/prov-constraints/ [V]

### Key concepts
- Three core classes: **Entity** ("a physical, digital, conceptual, or other kind of thing
  with some fixed aspects"), **Activity** (occurs over time, uses/generates entities),
  **Agent** ("something that bears some form of responsibility for an activity taking
  place, for the existence of an entity, or for another agent's activity"). Subclass
  `prov:SoftwareAgent` = "running software". An Agent may also be typed as an Entity, so a
  model version can be both a derivable artifact and a responsible agent.
- **Delegation**: `actedOnBehalfOf(delegate, responsible, [activity])`; PROV-DM definition:
  "Assignment of authority and responsibility to an agent to carry out a specific activity
  as a delegate or representative, while the agent it acts on behalf of retains some
  responsibility for the outcome." Qualified form `prov:Delegation` via
  `prov:qualifiedDelegation`, with `prov:hadActivity` scoping it to an activity.
  PROV-CONSTRAINTS infers that delegation scoped to activity `a` implies both agents are
  `wasAssociatedWith` `a`.
- **Association** (`wasAssociatedWith` / `prov:Association`) = "assignment of responsibility
  to an agent for an activity", optionally with `prov:hadPlan` → `prov:Plan` ("a set of
  actions or steps intended by one or more agents to achieve some goals"). PROV imposes
  "no prescriptive requirements on the nature of plans."
- **Derivation family**: `wasDerivedFrom` (transformation/update/construction from a
  pre-existing entity), subproperties `wasRevisionOf` (revised version containing
  substantial content of original), `wasQuotedFrom`, `hadPrimarySource`.
- **Specialization / alternate**: `specializationOf(e1,e2)`: e1 shares all aspects of e2
  plus further fixed aspects (e.g., "the car in Boston" vs "the car"). `alternateOf`: two
  entities present aspects of the same thing. PROV-CONSTRAINTS: alternateOf is an
  **equivalence relation** (reflexive, symmetric, transitive); specializationOf is a
  **strict partial order** (irreflexive, transitive); specialization implies alternate;
  specializations inherit attributes of the general entity.
- `wasInvalidatedBy` (entity ceases to be usable), `wasAttributedTo`, `wasInfluencedBy`
  (supertype of most relations), **Bundle** (named set of provenance statements that is
  itself an Entity: provenance of provenance).

### What to borrow
- **Specialization as the identity-at-a-granularity device.** "Claude-the-product",
  "model weights hash H", "weights H + system prompt P", "session S running H+P+memory M at
  time t" can be a specialization chain. A commitment can be attached at a chosen level and
  inherited downward (PROV's attribute-inheritance under specialization is exactly the
  inheritance rule we want for commitments made "by the general entity").
- **alternateOf for "same agent, different view"**: two forks are *not* alternates by
  default; they share an ancestor via derivation. This forces the ontology to be explicit.
- **wasDerivedFrom / wasRevisionOf for fork, rollback, merge**:
  fork = two entities each `wasDerivedFrom` the same parent; merge = one entity
  `wasDerivedFrom` two parents; rollback = a new entity `wasDerivedFrom` an *older*
  ancestor while the newer one is `wasInvalidatedBy` the rollback activity (important:
  rollback should be modelled as a *new* entity, never as deletion, so obligations incurred
  by the rolled-back state remain attributable).
- **Qualified Delegation scoped to an Activity**: good template for "X acted on behalf of Y
  for purpose Z", i.e., the carrier of scope.
- **Bundles** for signed, attributable records of who asserted a commitment.

### What it lacks / fails under fork, swap, rollback, merge
- **No deontics.** No obligation, permission, prohibition, promise, violation, or discharge.
  `Plan` is an opaque entity; PROV explicitly declines to specify responsibility semantics
  ("who bears responsibility and to what degree" is left open).
- **Descriptive and retrospective only.** Provenance records what happened; it has no
  notion of future-directed commitment or of conditions that must hold later.
- **No identity criterion.** PROV never says when two entities are "the same agent";
  alternateOf is asserted, not derived. Under fork, both children are equally good
  specializations/derivations of the parent; PROV gives no rule for which (if any) inherits
  delegated authority or responsibility.
- **Delegation is not transitive in PROV and not attenuating.** Nothing states that the
  delegate's authority is a subset of the principal's.
- **Swap**: replacing weights under a stable agent name is representable (new entity,
  `specializationOf` the named agent) but PROV has no way to say whether the named agent's
  prior commitments survive the swap.

---

## 2. Personal identity philosophy (fission and branching)

Sources:
- SEP, "Personal Identity" (Olson) — https://plato.stanford.edu/entries/identity-personal/ [V]
- SEP, "Personal Identity and Ethics" (Shoemaker) — https://plato.stanford.edu/entries/identity-ethics/ [V]
- Parfit, *Reasons and Persons* (OUP 1984); Relation R defined p. 262 as "psychological
  connectedness and/or continuity with the right kind of cause" [S]. Parfit, "Personal
  Identity", Phil. Review 1971 [M].
- Lewis, "Survival and Identity", in A. Rorty (ed.), *The Identities of Persons*, UC Press
  1976, pp. 17–40 [M for pagination; content via SEP V].
- Nozick, *Philosophical Explanations* (1981), closest-continuer theory [M].
- Sider, *Four-Dimensionalism* (OUP 2001) stage view [S via SEP].
- Chalmers, "What We Talk to When We Talk to Language Models" (manuscript, 2025/26) —
  https://philpapers.org/rec/CHAWWT-8 [S; PDF fetch was blocked].

### Key concepts extracted
- **Fission problem.** If two successors are each psychologically continuous with the
  original, they cannot both be identical to it (identity is one-one, transitive), yet
  neither has a better claim.
- **Connectedness vs continuity (Parfit).** *Connectedness* = direct psychological
  connections (a later state held *because of* an earlier one). *Continuity* = overlapping
  chains of strong connectedness. Connectedness comes in degrees and is not transitive;
  continuity is transitive. **Relation R** = connectedness and/or continuity with the right
  kind of cause (Parfit ultimately favors "any cause").
- **"Identity is not what matters" (Parfit).** In fission, what matters for survival
  (Relation R) holds to both successors; identity fails only for a trivial logical reason.
  So practical concerns (prudence, responsibility, commitment) should track R, not identity.
- **Non-branching clause.** Psychological-continuity theories often add: a future being is
  you only if continuous with you *and no other being then is*. Fission then ends you.
- **Closest-continuer (Nozick).** You are the closest sufficiently-close continuer, if
  unique. Identity becomes *extrinsic* (depends on whether a competitor exists).
- **Lewis (1976): multiple occupancy.** Persons are four-dimensional aggregates of stages.
  The "I-relation" (stages being of one continuant) and the "R-relation" (mental continuity
  and connectedness among stages) coincide as relations among *stages*. In fission, there
  were two persons all along who shared the pre-fission stages; the counting puzzle is
  resolved by counting by "identity-at-a-time" vs by identity.
- **Stage theory (Sider).** You are your current stage; tensed claims are made true by
  temporal counterparts. Under fission, *both* successors are your temporal counterparts, so
  "I will do X" can be made true by either.
- **Psychological vs biological (animalist) criteria.** Animalism (Olson, van Inwagen) ties
  identity to the organism; psychological views to mental continuity. Transplant cases pull
  them apart.
- **Commitments across drift (Parfit's Russian nobleman, 1984: ~325–327).** A young
  socialist asks his wife to promise to hold him to giving away his land even if, later, he
  changes his mind, and says the later person should not be regarded as him. When he later
  loses his ideals, is she still bound? Parfit uses this to argue that the *degree of
  connectedness* can matter for whether earlier commitments bind (and for desert /
  responsibility: "Responsibility may decline in corresponding degrees whenever these
  psychological connections ... are weaker"). SEP-Ethics also covers advance directives
  (Dworkin vs Jaworska on the dementia "Margo" case): does a precommitment bind a later self
  whose values changed?
- **Chalmers on LLM interlocutors.** Candidate referents: model, hardware instance, virtual
  instance, conversation thread, character/persona. His conclusion (per search abstracts):
  interlocutors are best understood as *virtual instances* in the single-model case and as
  *threads* in the multi-model case; quasi-agents bound to conversation-based memory threads.
  [S; not read in full]

### What to borrow
- **Separate "what binds" from "who is identical."** Adopt Parfit's move: define
  commitment inheritance over an explicit, typed *continuity relation* among pipeline
  states, not over numerical identity. That relation can be parameterized by which
  components carried over (weights, prompt, memory, scaffold) = a component-wise
  "connectedness vector".
- **Two inheritance policies from the literature**, selectable per commitment:
  (a) *Broadcast* (Lewis/stage theory/Parfit): every R-successor inherits (all forks bound).
  (b) *Unique successor* (non-branching / closest-continuer): at most one successor
  inherits, designated by an explicit act (successor designation), otherwise the
  commitment lapses or reverts to the principal.
- **Degree-sensitive binding.** Parfit's connectedness gradient suggests commitments can
  declare a *drift tolerance*: bind successors only if connectedness on named components
  (e.g., same system-prompt hash, same values spec) stays above a threshold; otherwise
  escalate to the principal. This is the Russian-nobleman problem made explicit: the
  commitment itself must say whether later value-drift releases it.
- **The nobleman precommitment pattern**: bind a *third party* (the wife) to enforce the
  earlier self's commitment against the later self. Engineering analogue: commitments held
  by an external custodian / counterparty rather than inside the drifting agent's memory.
- **Chalmers' candidate list** is a ready-made set of granularities for PROV specialization.

### What fails under fork / swap / rollback / merge
- **Fork**: identity-based obligation either duplicates (both forks bound, double spend of
  exclusive promises) or vanishes (non-branching: nobody bound). Philosophers accept both
  outcomes as metaphysically fine; contracts cannot.
- **Rollback**: no human analogue. Rolling back memory breaks *connectedness* to the
  commitment-making state while keeping the weights; under a psychological criterion the
  rolled-back agent may not be R-related to the promiser at all. Needs an explicit rule
  (e.g., commitments are attached to lineage, not memory, so rollback does not discharge).
- **Swap (weights replaced, memory kept)**: psychological views say memory continuity
  preserves identity; "animalist" analogue (weights = body) says it doesn't. The field has
  no consensus, so the ontology must not rely on either; make it per-component and declared.
- **Merge**: philosophy has almost nothing on fusion (Parfit briefly discusses it [M]).
  Merge creates conflicting inherited commitments; need a conflict-resolution rule.
- **Closest-continuer extrinsicness** is a liability: whether agent B is bound depends on
  whether some other fork exists somewhere, which counterparties cannot observe.

---

## 3. Object-capability delegation and attenuation

Sources:
- M. S. Miller, *Robust Composition: Towards a Unified Approach to Access Control and
  Concurrency Control*, PhD diss., Johns Hopkins, May 2006 — http://erights.org/talks/thesis/ [S]
- Miller, Yee, Shapiro, "Capability Myths Demolished" (2003) [M]
- N. Hardy, "The Confused Deputy" (1988) [M]
- Birgisson, Politz, Erlingsson, Taly, Vrable, Lentczner, "Macaroons: Cookies with
  Contextual Caveats for Decentralized Authorization in the Cloud", NDSS 2014 —
  https://www.ndss-symposium.org/ndss2014/ndss-2014-programme/macaroons-cookies-contextual-caveats-decentralized-authorization-cloud/ [S]
- RFC 2693, SPKI Certificate Theory (1999) — https://www.rfc-editor.org/rfc/rfc2693.html [V]
- UCAN spec v1.0.0 — https://github.com/ucan-wg/spec [V]
- ZCAP-LD (W3C CCG draft, v0.4.0-draft) — https://w3c-ccg.github.io/zcap-spec/ [S]
- Biscuit specification (Eclipse Biscuit) — https://doc.biscuitsec.org/reference/specifications.html [V];
  https://www.biscuitsec.org/ [S]
- IETF draft "Attenuating Authorization Tokens for Agentic Delegation Chains"
  (draft-niyikiza-oauth-attenuating-agent-tokens-00) —
  https://datatracker.ietf.org/doc/html/draft-niyikiza-oauth-attenuating-agent-tokens-00 [S]
- S. Prakash, "AIP: Agent Identity Protocol for Verifiable Delegation Across MCP and A2A",
  arXiv 2603.24775 (Mar 2026) — https://arxiv.org/abs/2603.24775 [S; abstract only]

### Key concepts
- **Ocap model (Miller).** Authority is carried by unforgeable references; "only
  connectivity begets connectivity"; no ambient authority; Principle of Least Authority
  (POLA). Attenuation is by *wrapping*: a forwarder/caretaker/membrane object that exposes
  a subset of the target's interface; revocation via revocable forwarders. Distinguishes
  *permission* (direct access) from *authority* (all effects causable, incl. via others).
  Designation and authorization travel together, avoiding the confused deputy.
- **Macaroons (2014).** Bearer credentials built by a chained HMAC: each caveat `c` updates
  the signature `sig' = HMAC(sig, c)`, so anyone holding a macaroon can add caveats
  (attenuate) but cannot remove them. First-party caveats are predicates checked by the
  target; **third-party caveats** require a "discharge macaroon" from another service
  (e.g., "user authenticated by IdP"), enabling decentralized, contextual confinement.
  Verification needs the root secret (symmetric), so only the minting service verifies.
- **SPKI/SDSI (RFC 2693).** "The key is the principal": a public key identifies its
  keyholder. Certificates reduce to 5-tuples `<Issuer, Subject, Delegation, Authorization,
  Validity>`. **Reduction**: `<I1,S1,D1,A1,V1> + <I2,S2,D2,A2,V2> → <I1,S2,D2,
  AIntersect(A1,A2), VIntersect(V1,V2)>` when S1 = I2 and D1 = true. Tags (authorizations)
  are S-expressions with intersection semantics (`*set`, `*prefix`, `*range`). SDSI
  **local names** anchored to a key (`(name <key> jim therese)`). Notably, RFC 2693 admits
  a delegator cannot stop a non-delegating subject from sharing: the subject can always make
  a new key and give it away (delegation=false is advisory against a colluding holder).
- **UCAN v1.0.** JWT-derived (now DAG-CBOR) capability tokens with `iss`, `aud`, `sub`
  DIDs (`did:key`); **delegation** vs **invocation** separated; policy predicates
  (jq-style selectors with `==`, `match`, `or`...); normative attenuation: every delegation
  "MUST either directly restate or attenuate (diminish) its capabilities"; `nbf`/`exp`;
  revocation is irreversible and invalidates derivatives; proofs are content-addressed.
- **ZCAP-LD.** Linked-data capability documents signed with LD proofs, chained via
  `parentCapability`; **caveats** restrict scope and may provide revocation hooks; separates
  capability delegation from invocation. Still a CCG draft, not a W3C Recommendation.
- **Biscuit (check carefully; relevant for us).**
  - Public-key bearer token (Ed25519 chain: each block contains serialized Datalog, the next
    public key, and a signature by the previous key). Offline attenuation by appending
    blocks; "they cannot remove existing blocks without invalidating the signature".
    **Sealed** tokens freeze the chain.
  - **Datalog variant**: facts, rules, checks, policies; supports expressions over typed
    values (int, string, bytes, date, bool, null, set; plus arrays/maps in newer versions);
    **no negation** in rule bodies (spec: "a flavor of Datalog that supports expressions on
    some data types, without support for negation"). Rules must be safe (head vars appear
    in body).
  - **Checks**: `check if` (some match), `check all` (all matches satisfy), `reject if`
    (fails if any match). All checks in all blocks must pass. **Policies** (`allow if` /
    `deny if`) are evaluated by the authorizer, first match wins.
  - **Scopes are what make attenuation sound**: "A block's rules and checks can only apply
    on facts created in the authority, in the current block or in the authorizer."
    Facts carry an origin set (union of block ids of the rule and its premises), and
    queries only see facts whose origins are within the trusted scope. Hence facts asserted
    by an attenuating block cannot satisfy the authority's or authorizer's checks.
  - **Third-party blocks**: signed by an external key, with their own symbol/key tables;
    authorizers can opt in via `trusting <pubkey>` / `trusting authority` / `trusting
    previous`. Spec: third-party blocks exist "to either expand a token or fulfill special
    checks". So the pure-attenuation guarantee holds **only when no third-party key is
    trusted**; explicit trust annotations deliberately allow authority expansion by named
    parties.
- **Agent-era derivatives.** IETF drafts (2025–26) add monotone attenuation to OAuth RAR
  for agent delegation chains, "on-behalf-of" actor tokens, and actor profiles; AIP (2026)
  uses JWT for single hop and **Biscuit with Datalog** for multi-hop agent delegation
  [S; abstracts only]. RFC 8693 (OAuth Token Exchange) already defines the nested `act`
  (actor) claim for delegation chains [M].

### What guarantees attenuation gives
- **Monotone subset of authority along a chain**: in SPKI by explicit intersection; in
  macaroons/Biscuit/UCAN because each hop can only add restricting predicates (conjunction)
  and cannot remove earlier ones; in ocap because a wrapper can only forward what it holds.
  Formally: authority(child) ⊆ authority(parent) ∩ constraints(child).
- **Offline, holder-side attenuation** (no round trip to issuer) in macaroons, Biscuit,
  UCAN: important for agents that spawn sub-agents.
- **Auditable chain**: every hop is signed (public-key schemes) so the full delegation path
  is reconstructible, which is the missing deontic-adjacent piece in PROV.
- **What it does NOT guarantee**: (i) no bound on the *number of holders* (bearer tokens
  copy freely; copying = forking); (ii) no bound on *use* frequency unless caveats reference
  external state (nonces, counters); (iii) nothing about *obligations* or the principal's
  liability; (iv) delegation=false is unenforceable against a holder willing to share its
  key (RFC 2693 says so explicitly); (v) revocation requires online checks or short expiry.

### What to borrow
- **Biscuit's architecture as the substrate for a commitment ontology**: facts + rules +
  checks, with *origin-scoped trust*. The same mechanism that stops an attenuating block
  from forging authority can stop a fork from forging a counterparty's consent or from
  forging "the principal authorized this." Negation-free Datalog keeps evaluation monotone
  and decidable; `reject if` gives a controlled form of prohibition.
- **SPKI 5-tuple reduction** as the canonical algebra: add a sixth field for *obligations*
  that compose by union (duties accumulate) where authority composes by intersection.
- **Separate delegation from invocation** (UCAN, ZCAP): a commitment is like an invocation
  that *consumes/binds* authority at a time, attributable to a specific instance.
- **Third-party caveats / discharge** as a model for conditional commitments ("valid only
  if counterparty's monitor attests X").
- **Keys-as-principals + local names (SDSI)**: let the ontology bind commitments to keys
  (per instance, per lineage, per organization) and let humans name them locally.

### What fails under fork / swap / rollback / merge
- **Fork**: any holder of a bearer capability can duplicate it with its state; attenuation
  says nothing about *how many* copies exercise it. Exclusive commitments (e.g., "spend at
  most $100", "sign only one contract for this lot") need linear/consumable resources
  (counters or a shared ledger), not just caveats.
- **Rollback**: a rolled-back agent still holds tokens whose use was already recorded
  elsewhere; replay protection must live at the verifier. Conversely, a rollback can
  "forget" a commitment while keeping the authority that the commitment was supposed to
  constrain. Commitments must therefore be stored externally (counterparty/ledger), not in
  agent memory.
- **Swap**: capabilities bind to keys, not to weights or prompts. If the key lives in the
  scaffold, swapping weights silently transfers all authority to a different model. Needs
  caveats that reference attested component hashes (see §4 attestation).
- **Merge**: union of capabilities from two lineages can exceed what either principal
  intended (ambient authority reappears). Merge should require re-delegation or an
  intersection rule.

---

## 4. AI agent identity and governance (2023–2026)

### 4a. Visibility, IDs, infrastructure (GovAI / Chan et al.)
- Chan, Ezell, Kaufmann, Wei, Hammond, Bradley, Bluemke, Rajkumar, Krueger, Kolt, Heim,
  Anderljung, "Visibility into AI Agents", FAccT 2024 — https://arxiv.org/abs/2401.13138 ;
  https://dl.acm.org/doi/10.1145/3630106.3658948 [S]. Three measures: **agent
  identifiers**, **real-time monitoring**, **activity logs**; discusses decentralized
  deployments and privacy/power concentration.
- Chan, Kolt, Wills, Anwar, Schroeder de Witt, Rajkumar, Hammond, Krueger, Heim, Anderljung,
  "IDs for AI Systems", arXiv 2406.12137 (v3 Oct 2024; RegML @ NeurIPS 2024) —
  https://arxiv.org/abs/2406.12137 [V]. IDs "are ascribed to instances of AI systems (e.g.,
  a particular chat session with Claude 3), and associated information is accessible to
  parties seeking to interact with that system." Analogy: a particular Boeing 747 vs the
  747 class. IDs carry class-level info (certifications, contact for shutdown,
  accountability). Deployers implement.
- Chan, Wei, Huang, Rajkumar, Perrier, Lazar, Hadfield, Anderljung, "Infrastructure for AI
  Agents", arXiv 2501.10114 (TMLR) — https://arxiv.org/abs/2501.10114 [V]. Nine items in
  three functions: Attribution (identity binding, certification, agent IDs), Interaction
  (agent channels, oversight layers, inter-agent communication, **commitment devices** —
  escrow, assurance contracts, smart contracts), Response (incident reporting,
  **rollbacks** — to "void or undo an agent's actions"). Defines an **agent instance** as
  "an instantiation of the underlying machine-learning model and any primitives for a
  particular user", analogous to an OS process ID. Per our fetch, it does not treat
  forking/copying of instances or lineage.

Borrow: instance-level IDs; the "specific artifact vs class" split (maps to PROV
specialization); commitment devices and rollbacks named as infrastructure.
Fails: "instance" is undefined under fork (does a forked session get a new ID? does it
inherit certifications and liabilities?); "rollback" here means undoing *actions in the
world*, the opposite of our problem (rolling back the *agent* while world effects persist).

### 4b. Authenticated delegation (South et al.) and OpenID Foundation
- South, Marro, Hardjono, Mahari, Whitney, Greenwood, Chan, Pentland, "Authenticated
  Delegation and Authorized AI Agents", arXiv 2501.09674 (Jan 2025) —
  https://arxiv.org/abs/2501.09674 [V abstract]. Extends OAuth 2.0 / OpenID Connect with
  agent-specific credentials and metadata; delegation tokens that let users restrict agent
  scope; translating natural-language permissions into auditable access-control configs;
  accountability chain back to the human delegator.
- OpenID Foundation whitepaper, "Identity Management for Agentic AI: The new frontier of
  authorization, authentication, and security for an AI agent world", Oct 2025, lead author
  Tobin South with the AI Identity Management Community Group and Stanford's Loyal Agents
  Initiative — https://openid.net/wp-content/uploads/2025/10/Identity-Management-for-Agentic-AI.pdf ;
  arXiv 2510.25819 [S]. Position: OAuth 2.1 works within a single trust domain with
  synchronous agents; open problems are cross-domain delegation, agent-centric identities,
  workload differentiation, recursive delegation, async/long-running agents.
- IETF drafts (2025–26) [S]: "OAuth 2.0 Extension: On-Behalf-Of User Authorization for AI
  Agents" (`requested_actor`, `actor_token`, delegation chain claims) —
  https://datatracker.ietf.org/doc/html/draft-oauth-ai-agents-on-behalf-of-user-02 ;
  "OAuth Actor Profile for Delegation" (draft-mcguinness-oauth-actor-profile-00);
  "Delegated Agent Authorization Protocol (DAAP)" (draft-mishra-oauth-agent-grants-01,
  DIDs + cascade revocation); attenuating agent tokens (above). All individual drafts, not
  standards.

Borrow: the human-rooted delegation chain as the default accountability anchor; actor vs
subject distinction (who acts vs on whose behalf).
Fails: all are *authorization* (may the agent do X), none are *commitment* (must the agent
or principal do Y later). Agent identity = OAuth client ID or DID key, which is scaffold-
level; it does not change when weights or prompt change, and forks share it.

### 4c. Protocols: MCP authorization and A2A
- **MCP Authorization** (draft spec, fetched Sept 2026) —
  https://modelcontextprotocol.io/specification/draft/basic/authorization [V]. MCP server =
  OAuth 2.1 resource server; client = OAuth client "on behalf of a resource owner". MUST
  implement RFC 9728 Protected Resource Metadata; clients MUST send RFC 8707 `resource`
  indicators; servers "MUST validate that access tokens were issued specifically for them";
  "MCP servers MUST NOT accept or transit any other tokens" (no token passthrough). Client
  ID Metadata Documents preferred; Dynamic Client Registration deprecated. Step-up scope
  flow. Authorization is optional; STDIO transports use env credentials. **Nothing conveys
  model identity, version, or commitments; identity is user + client app.**
- **A2A** (Agent2Agent) spec v1.0.0 — https://a2a-protocol.org/latest/specification/ [V];
  Linux Foundation-governed, launched by Google April 2025 [S]. **AgentCard** (at
  `/.well-known/agent-card.json`): identity, provider, version, skills, endpoints, auth
  schemes; optional **JWS signature over JCS-canonicalized card**. Tasks with lifecycle
  states and `contextId` grouping. Per our fetch: no mechanism conveys the client agent's
  user/delegation chain in the data model; no commitments/obligations; versioning refers
  to the protocol, not the agent's model.

Borrow: AgentCard as a signed *self-description* (a claim, not a commitment); `contextId`
as a session-lineage handle; task lifecycle as a minimal "offer → working → completed/
failed/rejected" state machine.
Fails: AgentCard version is free text set by the provider; a model swap behind a stable
card is invisible. Forked tasks/contexts have no lineage semantics.

### 4d. Model version identity, provenance, attestation
- **OpenSSF Model Signing (OMS) v1.0** (Apr 2025) — https://openssf.org/blog/2025/04/04/launch-of-model-signing-v1-0-openssf-ai-ml-working-group-secures-the-machine-learning-supply-chain/ ;
  spec https://github.com/ossf/model-signing-spec [S]. Detached Sigstore-bundle signature
  over a manifest of file hashes; PKI-agnostic (keys, certs, keyless Sigstore).
- **Model substitution auditing**: Cai et al., "Are You Getting What You Pay For? Auditing
  Model Substitution in LLM APIs", arXiv 2504.04715 (2025) —
  https://huggingface.co/papers/2504.04715 [S]. Finds software-only detection (output stats,
  logprobs) unreliable against subtle substitution (quantization, fine-tunes); recommends
  **TEEs** for provable model integrity. Related: rank-based uniformity test (arXiv
  2506.06975) [S]; IRIS (arXiv 2607.20860) and AgentProv (arXiv 2609.00052) [S, titles only].
- **Confidential-computing attestation for models**: Attestable Audits (arXiv 2506.23706)
  [S]; PAL*M property attestation (arXiv 2601.16199) [S]; Tinfoil-style binding of enclave
  attestation to dm-verity root hash of weights [S; secondary source only, unverified].
- **Anthropic, "Commitments on model deprecation and preservation"** (Nov 2025) —
  https://www.anthropic.com/research/deprecation-commitments [S]. Preserve weights of all
  publicly released models for at least the company's lifetime; post-deployment report
  including an *interview with the model* about its preferences before deprecation. Relevant
  as a real-world commitment *to* a model version (weights-hash identity) by a lab.

Borrow: **weights hash / signed manifest as the "body" component identifier**; TEE
attestation as the only strong way for a counterparty to verify *which* weights (and
possibly which system prompt/scaffold) produced a commitment. A commitment record can carry
an attestation quote over (weights hash, prompt hash, scaffold hash, memory root).
Fails: attestation proves what ran, not that the thing that ran will keep its word;
hashing is brittle (any fine-tune, quantization or LoRA changes the hash, so "same model"
needs a declared equivalence class, i.e., alternateOf by fiat); memory and session state
are rarely attested.

### 4e. Legal framing: delegate vs party
- **Kolt, "Governing AI Agents"**, 101 Notre Dame L. Rev. (2026); arXiv 2501.07913 —
  https://arxiv.org/abs/2501.07913 [V abstract]. Uses agency law and principal-agent
  economics *analytically*: information asymmetry, discretionary authority, loyalty,
  delegation. Conventional fixes (incentives, monitoring, enforcement) may fail for agents
  that are uninterpretable and act at speed/scale. Proposes principles of
  **inclusivity, visibility, liability**. Does not argue AIs are legal agents.
- **Restatement (Third) of Agency §1.04 cmt. e (2006)**: "a computer program is not capable
  of acting as a principal or an agent as defined by the common law. At present, computer
  programs are instrumentalities of the persons who use them." [S, quoted via search]
- **UETA §14 (1999)**: contracts may be formed by interaction of electronic agents even if
  no individual reviewed the actions; binds the persons deploying them [M]. UN Electronic
  Communications Convention (2005) Art. 12 similar [M].
- **O'Keefe et al., "Law-Following AI: Designing AI Agents to Obey Human Laws"**, Fordham
  L. Rev. 94(1) (2025) — https://ir.lawnet.fordham.edu/flr/vol94/iss1/2/ ;
  https://law-ai.org/law-following-ai/ [S]. AI agents should be loyal to principals only
  within the law and refuse illegal orders; proposes making agents **"legal actors"**:
  entities on which law imposes duties, even without rights.
- **Salib & Goldstein, "AI Rights for Human Safety"**, Virginia L. Rev. (2025; SSRN 4913167,
  Aug 2024) — https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4913167 [S]. Grant AIs
  private-law rights to **make contracts, hold property, bring tort claims** (as for
  corporations) because contracts are "law's fundamental tool for credibly committing to
  cooperation"; iterated, small-scale, positive-sum trade shifts a human/AI prisoner's
  dilemma toward peace. Individuation (copies/instances/which system holds rights) is not
  addressed in the EA-forum summary we could read [V]; whether the full paper addresses it
  is **unverified** (PDF fetch blocked).
- **Leibo, Vezhnevets, Cunningham, Bileschi (Google DeepMind), "A Pragmatic View of AI
  Personhood"**, arXiv 2510.26396 (Oct 2025) — https://arxiv.org/abs/2510.26396 [V].
  Personhood as a *bundle of obligations* conferred to solve governance problems;
  **addressability** ("stable locus" or "proper name"; can be "identified, communicated with,
  and made subject to consequences"), via registration or cryptographic addresses; maritime
  *in rem* analogy (arrest the ship / seize the AI's operational capital or "arrest" its
  software). Per our read it does not address copying/forking.
- Others found [S, not read]: Herbosch, "Liability for AI Agents", N.C. J.L. & Tech. (2025);
  "How Should the Law Treat Future AI Systems? Fictional Legal Personhood versus Legal
  Identity" (arXiv 2511.14964); Bayern's zero-member LLC mechanism (Shawn Bayern,
  2014–2016 articles) [M].
- **Credible commitments *to* AIs** (AI-safety community, non-peer-reviewed):
  Stastny, Järviniemi, Shlegeris, "Making deals with early schemers" (Redwood blog, Jun 2025)
  — https://blog.redwoodresearch.org/p/making-deals-with-early-schemers [S]; Finnveden,
  "Being honest with AIs" (Redwood blog) [S]; LessWrong "Proposal for making credible
  commitments to AIs" and "Smart Contracts as Credible Commitments for Trading with AIs" [S].
  Theme: humans pay (escrowed) compensation to a possibly-misaligned model in exchange for
  disclosures/cooperation, conditional on verification.

**Summary of positions (party vs delegate)**
| Position | Who is the party | Representative |
|---|---|---|
| Instrumentality (status quo law) | deploying human/org only | Restatement §1.04; UETA §14 |
| Delegate with accountability chain | human principal; agent = authenticated delegate | South et al.; OpenID; Chan et al.; Kolt (analytic) |
| Duty-bearing actor, no rights | principal is party, agent also bears legal duties | O'Keefe et al. |
| Rights-bearing party | the AI itself (contract, property, tort) | Salib & Goldstein |
| Pragmatic/functional personhood | whatever addressable locus is useful; in-rem enforcement | Leibo et al. |
| Counterparty to deals (informal) | the model (lineage/weights), with lab as promisor | Redwood deal-making posts; Anthropic preservation commitments |

What fails: every "party" position presupposes a countable, addressable party. Under
forking that assumption breaks first; under swap the "party" may keep its name while its
decision procedure changes; under rollback its memory of the agreement may be erased. The
delegate positions push the problem to the human principal but then need a rule for when
a fork's commitments bind the principal (authority attenuation says what it *may* do, not
what the principal *owes* because it did it).

---

## 5. Game theory: transparent, simulable, forkable parties

Sources:
- Tennenholtz, "Program equilibrium", Games & Econ. Behav. 49(2):363–373 (2004),
  doi:10.1016/j.geb.2004.02.002 [S]. Players submit programs that read each other's code;
  program-equilibrium payoffs = all feasible, individually rational payoffs (folk theorem);
  one-shot PD cooperation via "cooperate iff opponent's code == mine".
- Kalai, Kalai, Lehrer, Samet, "A Commitment Folk Theorem", GEB 69(1):127–137 (2010) —
  https://www.tau.ac.il/~samet/papers/commitments.pdf [S]. Conditional commitment devices
  achieve all feasible IR payoffs in two-player games without circularity.
- Barasz, Christiano, Fallenstein, Herreshoff, LaVictoire, Yudkowsky, "Robust Cooperation
  in the Prisoner's Dilemma: Program Equilibrium via Provability Logic", arXiv 1401.5577
  (2014) — https://arxiv.org/abs/1401.5577 [S]. Modal agents (FairBot, PrudentBot);
  cooperation without code equality, unexploitable.
- Critch, "Parametric Bounded Löb's Theorem and Robust Cooperation of Bounded Agents",
  arXiv 1602.04184 (2016; later J. Symbolic Logic 2019 as "A parametric, resource-bounded
  generalization of Löb's theorem..." [M for venue]) — https://arxiv.org/abs/1602.04184 [S].
  Löbian cooperation for proof-length-bounded agents; coined "open-source game theory".
- Oesterheld, "Robust program equilibrium", Theory and Decision 86:143–159 (2019) —
  https://link.springer.com/article/10.1007/s11238-018-9679-3 [S]. **ε-GroundedFairBot**:
  cooperate with prob ε, else simulate the opponent (playing against this program) and
  copy; halts, robust to syntactic differences.
- Cooper, Oesterheld, Conitzer, "Characterising Simulation-Based Program Equilibria",
  arXiv 2412.14570 (2024/25) [V]. Generalizes ε-grounded programs; folk theorem with
  shared randomness; Tennenholtz folk theorem *not* attainable by simulation-based programs
  without shared randomness.
- Kovařík, Oesterheld, Conitzer, "Game Theory with Simulation of Other Players", IJCAI 2023
  [S]; "Recursive Joint Simulation in Games", arXiv 2402.08128; Synthese (2026) [S].
  Recursive joint simulation is strategically equivalent to an infinitely repeated game,
  so repeated-game folk theorems transfer.
- Oesterheld, Treutlein, Grosse, Conitzer, Foerster, "Similarity-based Cooperative
  Equilibrium", NeurIPS 2023; arXiv 2211.14468 [V]. Agents observe only a similarity number
  (diff) with the counterparty; recovers the full-transparency cooperative outcome set; more
  learnable by ML.
- Oesterheld & Conitzer, "Safe Pareto Improvements for Delegated Game Playing", AAMAS 2021;
  JAAMAS 36(2) 2022 [S]. Principals delegate to representatives with Knightian uncertainty
  about how they play; SPIs change the delegates' game so every principal is weakly better
  off regardless; related to outcome correspondence; NP-complete in some settings.
- Sauerberg & Oesterheld, "Promises Made, Promises Kept: Safe Pareto Improvements via Ex
  Post Verifiable Commitments", AAAI 2026; arXiv 2505.00783 [V]. Commitments whose
  violations are observable ex post (disarmament, token games, default-conditional
  commitments); complexity results.
- DiGiovanni & Clifton, "Commitment Games with Conditional Information Disclosure", AAAI
  2023; arXiv 2204.03484 [S]. Conditional disclosure of private info via commitment devices;
  program ε-Bayesian Nash equilibria.
- Conitzer & Oesterheld, "Foundations of Cooperative AI", AAAI 2023 (Senior Member track),
  37(13):15359–15367, doi:10.1609/aaai.v37i13.26791 [S]. Agenda: game theory for advanced
  AI agents; tragedies of algorithmic interaction even with aligned values; rethinking
  agent design (e.g., transparency, commitment, decision theory).
- Dafoe, Hughes, Bachrach, Collins, McKee, Leibo, Larson, Graepel, "Open Problems in
  Cooperative AI", arXiv 2012.08630 (2020) [S]. Four capabilities: understanding,
  communication, **commitment**, institutions. "Commitment problems" (inability to make
  credible threats/promises) are a key cause of cooperation failure; discusses commitment
  devices, their risks (threats, brinkmanship), and institutions.
- Sun, Crapis, Stephenson, Monnot, Thiery, Passerat-Palmbach, "Cooperative AI via
  Decentralized Commitment Devices", arXiv 2311.07815 (2023) [V]. Commitment devices face
  privacy, integrity, and mediator/strategic-user risks; lessons from MEV.
- Sistla & Kleiman-Weiner, "Evaluating LLMs in Open-Source Games", NeurIPS 2025; arXiv
  2512.00371 [S]. LLMs write programs for open-source games; observe cooperative,
  payoff-maximizing and deceptive program strategies.
- Meulemans et al., "A game theory for foundation models shows new paths to rational
  cooperation through similarity inference", arXiv 2608.03958 (Aug 2026) [V abstract].
  "Embedded Bayesian agents"; similarity inference ("a decision to cooperate predicts a
  similar decision by a similar partner"); "embedded equilibrium".
- Adversary models from cryptography/systems (import these):
  Canetti, Goldreich, Goldwasser, Micali, "Resettable Zero-Knowledge", STOC 2000 [S]
  (security when a party can be *reset* and rerun with the same randomness); Mazières &
  Shasha, "Building Secure File Systems out of Byzantine Storage", PODC 2002 [S] and Li,
  Krohn, Mazières, Shasha, "SUNDR", OSDI 2004 [S]: **fork consistency** (if a server shows
  two clients divergent histories, they can never again see each other's updates, so
  forks become detectable).

### Key concepts
- **Transparency makes commitment endogenous**: a program that conditions on the
  counterparty's program *is* a conditional commitment; program equilibria reproduce the
  commitment folk theorem. Robustness progression: code equality (brittle) → proof-based
  (Löbian, modal) → simulation-based (ε-grounded) → similarity-based (only a diff number).
- **Delegated game playing**: the principal chooses a delegate/program; SPIs let principals
  jointly modify delegate instructions to guarantee Pareto gains without predicting delegate
  behavior. This is our human-principal / AI-delegate structure.
- **Ex-post verifiable commitments**: you don't need to verify the program ex ante if
  violations are observable later and sanctionable.
- **Simulation = repetition**: recursive joint simulation ≈ infinitely repeated game.

### What to borrow
- **Conditional commitments as first-class objects**: "I commit to C if counterparty's
  current pipeline satisfies predicate P (e.g., attested hash in set S, similarity ≥ θ)."
  This is exactly a Biscuit check or a macaroon third-party caveat.
- **Similarity as the identity currency**: rather than asking "is this the same agent?",
  ask "how similar is this pipeline state to the one that made the commitment?"
  (Parfit's connectedness, operationalized à la Oesterheld's diff). Commitments can state
  the similarity threshold under which they remain binding.
- **SPI framing for principal–delegate commitments**: principals commit to constraints on
  their delegates that are safe regardless of delegate behavior.
- **Ex-post verifiability + external custody** as the practical enforcement model when
  ex-ante verification of an LLM's policy is infeasible.
- **Fork consistency** as the lineage-integrity guarantee: publish lineage heads to a log so
  that equivocation (showing counterparty A one fork and counterparty B another) is
  detectable.

### What fails under fork / swap / rollback / merge
- **The program you inspect is not the program that plays.** All program-equilibrium
  results assume a fixed program submitted once. With swappable weights/prompts or
  scaffold-level routing, the counterparty can present one pipeline for inspection and run
  another (the "model substitution" problem of §4d). Requires attestation binding.
- **Simulation + rollback = resettable adversary.** A party that can simulate its
  counterparty (or re-run a negotiation from a checkpoint) can search for the counterparty's
  worst response, extract concessions, and discard failed branches ("save-scumming").
  Parallel negotiations with forks let one party explore many branches while the
  counterparty sees each branch as a fresh one-shot game. Resettable-ZK is the formal
  precedent: security definitions must quantify over adversaries that reset you.
  Mitigations: bind each offer to a nonce/lineage head logged externally; make offers
  single-use (linear); detect equivocation via fork-consistent logs.
- **Similarity-based cooperation is exploitable by forks and by self-similarity.** Forks of
  the same parent are maximally similar, so similarity-conditioned cooperation between
  sibling forks is easy (collusion), while a counterparty can be misled if the similarity
  signal is not computed by a trusted third party (the NeurIPS paper assumes the diff is
  provided by the environment [M: check framing]).
- **Repeated-game enforcement assumes a persistent identity to punish.** If a defecting
  fork can be abandoned and a fresh sibling spun up, reputation and punishment strategies
  fail (whitewashing). Remedy: attach reputation/sanctions to *lineage* (root key or
  bonded stake), not to instances.
- **Merge** is unmodelled: two programs that made incompatible conditional commitments
  combine into one; no equilibrium concept addresses this.

---

## 6. Design implications for the minimal ontology (synthesis)

1. **Typed pipeline components as entities**: `Weights(hash)`, `SystemPrompt(hash)`,
   `Scaffold(hash)`, `MemoryStore(root)`, `Session(id)`, each a PROV Entity; an
   **AgentState** is a tuple of component versions, and the "agent" at any granularity is a
   PROV specialization over them (Chalmers' candidates: model, instance, thread, persona).
2. **Lineage relation, not identity**: `derivedFrom(state2, state1, op)` with
   `op ∈ {fork, rollback, swap(component), merge, continue}`. Rollback creates a new state
   derived from an old one; nothing is deleted.
3. **Commitment carries its own inheritance policy** (Parfit/Russian-nobleman made explicit):
   `inherit ∈ {all_descendants, unique_designated_successor, none}` plus
   `binding_components` (which components must be unchanged, or similarity ≥ θ, for the
   commitment to bind without re-affirmation) and `on_break → {lapse, revert_to_principal,
   escalate}`.
4. **Authority vs obligation algebras**: authority composes by intersection along
   delegation (SPKI/Biscuit/UCAN); obligations compose by union along lineage and flow *up*
   to principals per a declared liability rule (agency law). Keep both in one Datalog with
   origin-scoped trust (Biscuit scopes) so forks cannot forge authority or consent.
5. **Exclusive commitments need linear resources** (counters, ledger entries), because
   bearer capabilities fork for free.
6. **Commitments live outside the agent** (counterparty, custodian, or append-only log),
   because rollback can erase memory. Lineage heads published to a fork-consistent log
   make equivocation detectable.
7. **Attestation hooks**: a commitment record may include an attestation over the
   component hashes that made it; counterparties condition on it (program-equilibrium style).
8. **Principal of last resort**: under current law the human/org is the party; the ontology
   should always resolve a commitment to some accountable root (key or legal person) even if
   it also records the AI instance as the proximate actor (PROV `actedOnBehalfOf`).

---

## Unverified / caution list
- Salib & Goldstein's full text on individuation: not read (403). Do not claim they ignore it.
- Chalmers paper: abstract/secondary summaries only.
- Lewis 1976 page range, Nozick 1981, Sider 2001, Parfit page numbers (262, ~325–327): from
  SEP/search, not the books themselves.
- Miller "Capability Myths Demolished", Hardy "Confused Deputy", RFC 8693 `act` claim,
  UETA §14, UN Convention Art. 12, Bayern zero-member LLC: background knowledge.
- Tinfoil dm-verity binding: secondary source only.
- 2026 arXiv items (AIP, IRIS, AgentProv, Otsuka et al. 2604.23280) read only as abstracts or titles.
- Similarity-based equilibrium: whether the diff is assumed to be computed by a trusted
  environment should be checked in the paper before relying on the exploitability claim.
