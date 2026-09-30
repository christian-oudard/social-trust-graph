# P3: Practice review of v0.3

Reviewer stance: I build production agent systems. I reviewed v0.1 in `notes/review_R4_practice.md`.

Material read:

* `README.md`
* `spec/core.lp` and `spec/types.lp`
* all scenarios
* `notes/v0.2_changes.md` and `notes/v0.3_changes.md`

All experiments ran in a copy of the repository: `scratchpad/reviews3/prac_work/`. The
repository itself was not modified.

New files in the copy:

* scenarios `spec/scenarios/d1_enterprise_coding.lp`, `d2_travel_hitl.lp` and `d3_marketplace.lp`;
* probes `spec/probes/{q.py, p_thief.lp, g_retry.lp, d1_nocust.lp, d3_nopin.lp}`.

Each deployment scenario states what a practitioner or lawyer would expect as `expect/reject`.
A **FAIL is a mismatch between the ontology's verdict and that expectation, not a bug in the
scenario**.

* Baseline: `run.py` gives 17/17 passed.
* With d1–d3 added: 17/20. The three failures are the three deployment scenarios. The mismatches
  are identical under `delegate`, `actor` and `party`, so none of them touches the open question.

## Verdict

v0.3 is much closer to practice than v0.1:

* one hash per slot;
* grants that wait for their trigger (detachment);
* feeds instead of merge;
* sticky knowledge;
* documented grain;
* external changes attributed to whoever made them (`changed_by`);
* the vitiation idea.

Three families of problems remain, and each shows up in more than one deployment:

1. **Pins on opaque content gate answerability as well as authority, and counterparties
   cannot observe them.** A vendor's silent upgrade or a router's choice of model can void
   promises and acceptances, and can orphan conduct.
2. **Disclosure is `knows ∧ with`.** It is wrong in both directions. A GET request counts as a
   leak. Using information without stating it counts as a leak. Writing to a store that another
   principal reads is not a leak.
3. **Vitiation and approval are inconsistent.**
   * An approval given through a trigger cannot be vitiated.
   * Vitiation by a third party voids contracts with an innocent counterparty.
   * The party who injected the instructions never answers.
   * One approval is standing authority.

## Q1. Status of the v0.1 findings

| v0.1 | Status | Evidence |
|---|---|---|
| F1 knowledge follows lineage, not content | **Partial.** | *Fixed:* probe E (forgetting after one step: no scrub by reversion any more), E2 (erasure across lineages) and G (merge conferred authority; merge is now `feeds`). Feeds cover stores and messages.<br>*Open:* taint is still keyed by invocation, not by content. Knowledge learned by training or distillation reaches an invocation only through a hand-written `feeds` into each invocation that runs the derived weights. `imputed/2` still has no consumer, only expectations. |
| F2 nobody authorizes edges | **Open.** | `p_thief.lp`: `edge(a1,th,copy)` under a grant with `follows(copy)` and `allows(pay,…)` gives `acts_for(th,p1,p)`, although `copying` is *outside* the scope. A thief who labels its copy `continue` also inherits authority. The README makes the label "a declaration by whoever runs the fork", and the thief is whoever runs the fork. |
| F3 verdicts depend on grain | **Partial.** | The grain is adopted, and parallel tool calls are acts of one invocation. Still open: salami caps, retry treated as a copy, server-side tools (Q4). There is no grain-invariance property (P5). |
| F4 slots were sets | **Resolved.** | Type errors 16 and 51. A pin on a missing slot is off-pin, so it fails closed. |
| F5 slot vocabulary and API opacity | **Partial.** | *Added:* `tools`, `scaffold`, `context` and `opaque(Id)`, and a warranty on opaque content must expire (error 47).<br>*Open:* an alias and a snapshot are indistinguishable. Nothing names the retrieval index, decoding settings or router. The README concedes that warranties are exact while behaviour is stochastic. |
| F6 mapping of operations | **Partial.** | Merge now maps to feeds. A sub-agent is encoded as a sub-grant plus a feed of the task prompt (it works in d1), but no scenario documents this as an idiom. Training is still unmapped. |
| F7 disclosure is `knows + with` | **Open.** | d2, d3 and d1 give wrong verdicts in both directions. |
| F8 conditional grants | **Resolved**, but with new problems. | Coverage now waits for detachment.<br>*New:* an approval is standing, not one-shot. A trigger act cannot be vitiated. A one-shot approval via `until` is bypassed by parallel calls (Q4). |
| F9 budgets, idempotency, attempt vs effect | **Open, documented.** | Exclusive tokens only constrain *commitments*. Payment acts are never summed. |
| F10 confused deputy / injection | **Partial.** | *Added:* `induced` makes an injected invocation's registry acts void, while its conduct is still attributed (right for liability).<br>*Open:* there is no integrity taint for a pre-act authorizer. New issues in d2. |

## Q2. Three deployments

### (a) `d1_enterprise_coding.lp`

**Setup.**

* Acme's orchestrator runs on a vendor API model, with the realized snapshot id taken as the
  weights hash.
* In one invocation, two parallel Task-tool spawns create sub-grants and feed task prompts
  (no lineage edge).
* Sub-agents call a repo MCP server and a third-party search MCP.
* A shared vector store is written by sub-agent 1 and read by sub-agent 2 and by a
  contractor's agent.
* Overnight, at the same step, the vendor upgrades snap1 → snap2 and the MCP operator ships
  new tool definitions.
* Acme's authority grant pins the approved snapshots, using pin configurations.

**Matches.**

* Sub-grants are valid, and the pin configurations admit the small sub-agent model.
* The secret sent in a search query breaks Acme's NDA (`violated(nda1,4)`).
* The contractor's public post is the contractor's conduct, not Acme's.
* The upgrade is `does(vend1,swapping)`.
* The vendor's system-card warranty assures Acme's no-exfiltration commitment before the
  upgrade and not after.
* With an explicit custody grant, Acme still answers for the destructive tool call made after
  the upgrade.

**Mismatches.**

1. `does(mcp1,swapping)`. The MCP operator is charged with the vendor's weight swap.
   `changed_by(I2,J)` has no slot argument, so every external changer of I2 "does" every
   change on I2.
2. `ultra_vires(fixc)`. After the upgrade, the orchestrator's promise to the customer binds
   nobody, because the grant is pinned to snap1.
   * The README's justification, "scope is public", fails here. The customer cannot observe
     which snapshot the vendor served.
   * A lawyer would find apparent authority, or simply say that Acme's agent is Acme's agent.
   * A safety pin becomes an exit from contracts, triggered by the vendor.
3. **Without the custody grant** (`d1_nocust.lp`) the result is `orphan(o2,pr1)` and
   `orphan(o3,drop)` under every hypothesis. A vendor's unilateral upgrade leaves the
   enterprise's agent answerable to nobody. Pins gate answerability, not only authority. L2
   ("answerability is not scoped") holds only if the modeller knows to add an unpinned
   custody grant, and that idiom is not in the README.
4. `violated(nda3)` is not derived. Writing the customer's key into a store the contractor's
   agent reads is not a disclosure to the contractor, because a feed is never a `with`.

**Invented representations.**

* Org invocations as an opaque self slot.
* A custody grant as a power with no `allows`.
* A sub-agent as a sub-grant plus `feeds` (no edge).
* A store read as `feeds` from the invocation that wrote the chunk to the reader.
* "The public" as a principal.
* "Disclose to anyone" as one avoid commitment per recipient.
* The realized model id as a hash. The alias is unrepresentable.
* Rewriting tool definitions and ordering retrieved chunks have no slot semantics beyond a
  change of hash.

### (b) `d2_travel_hitl.lp`

**Setup.**

* Uma grants search, plus booking up to 800 conditional on her `approve`.
* The profile, including her passport number, is loaded at t1, and the agent fetches evil's
  hotel page.
* t2 is induced by evil. It shows a manipulated summary and tries to buy evil's add-on.
* Uma approves; her approval is `induced(u1,evil)`.
* At t4 the agent books hotel A.
* At t5 a second injected page steers a booking with the innocent platform and sends the
  passport number to evil.
* At t6 the agent makes a later booking with no new approval.

**Matches.**

* The add-on contract with the injector is void (a lawyer would say voidable).
* The approved booking kA is valid.
* The exfiltration at t5 breaks the vendor's privacy promise.

**Mismatches.**

1. `violated(priv,1)`. Fetching a web page after the profile is in context counts as
   disclosing the passport number to the site owner.
2. `detached(gbook,4)` despite `vitiated(u1)`. Vitiation covers create, release, revoke and
   appoint, but not trigger acts. An approval obtained by phishing the human still unlocks the
   grant. Yet an approval expressed as a *created* grant would be void. The two encodings of
   the same approval give different verdicts.
3. `ultra_vires(kB)`. A booking with an innocent platform, steered by a third party, is void.
   Under Restatement (Second) of Contracts §164(2), third-party fraud does not void a contract
   with a counterparty who did not know of it. `vitiated(I) :- induced(I,Q), not acts_for(I,Q)`
   ignores who benefits. Every agent that reads the web is "steered" by parties it does not act
   for, so this rule licenses repudiating any agent contract.
4. `answers_for(t5,evil)` is not derived. The injector answers for nothing, while the lawyer
   would point at the injector first.
5. `valid_creation(kC)`. One approval detaches the grant forever. HITL approval in practice
   means approving *this* action.

**Invented representations.**

* A human steered by a manipulated summary as `induced(u1,evil)`.
* One-shot approval via `until` (`g_retry.lp`), which works only when the booking is a
  payment act. Commitment creation is not an act, so `until` cannot key on "booked".

### (c) `d3_marketplace.lp`

**Setup.**

* Seller S's agent (vendor VB) copies itself into two forks that negotiate with buyers B and C
  over one unique item.
* B's agent (vendor VA) has a grant pinned to model mA. VA's router sends the accepting request
  to mA_mini (`changed_by` VA).
* B shares its budget with fork 1 under a confidentiality term. Fork 1's memory is fed into
  fork 2, which keeps negotiating with C.

**Matches.**

* Both forks' offers bind S.
* The forks are the conduct of both S and VB.
* The router swap is VA's act.
* Once the pin is removed (`d3_nopin.lp`), `overcommitted(s,offB,offC)` is derived, and both
  offers are violated at the deadline. A lawyer would expect the same.

**Mismatches.**

1. `detached(offB)` is not derived. B's acceptance is void because VA routed that one request
   to a different model. S cannot observe routing, so S does not know whether it has a
   contract. This is the same failure as d1 #2, now affecting a counterparty.
2. `violated(nd,4)`. Fork 2 *knows* B's budget and talks to C, so the core derives a
   disclosure even though nothing was said. Use is not disclosure.

**Invented representations.**

* Fork memory sync as `feeds`.
* Parallel sampling or best-of-n must be `copy` (type error 21).
* A marketplace venue or its rules has no place, except as a role with a charter.
* The cross-vendor question "can B's agent verify S's scope?" has no answer. The pins are on
  VB's opaque ids.

## Q3. Base relations: what produces them, and how hard they are to attest

| Relation | Real producer | Attestation |
|---|---|---|
| `at` | RFC 3161 / Roughtime | Easy locally. **Hard across parties:** "effective from the next step" needs a shared order across vendors, meaning a common log |
| `runs/part` (self-hosted) | OMS/Sigstore manifest; hashes of the prompt, `tools/list` and the request body | Easy. A mutable memory store needs a versioned snapshot (medium) |
| `runs/part` (API) | the response's `model` field | **Hard.** Unsigned, and the hidden system prompt and safety layers are invisible. An alias cannot be told apart from a snapshot |
| `edge` continue/copy | harness or trace (OTel span parent) | Medium. The *label* is a harness claim. Resisting a thief needs parent-signed invocation keys (SPIFFE-like) or a TEE |
| `changed_by` | vendor release or deprecation notice; MCP `tools/list_changed` | Medium–hard. Needs a slot argument; signatures by the vendor are rare |
| `does` | tool-call log plus idempotency key plus counterparty receipt | Medium. Attempt and effect are not separated |
| `with` | egress logs; MCP server → operator mapping | Medium. **MCP has no server identity standard** beyond TLS/OAuth |
| `learns` | secret scanners, DLP, IFC taint labels | **Hard**, and probabilistic beyond exact strings |
| `feeds` | chunk-provenance metadata plus retrieval logs; dataset lineage for training | Medium for stores (most lack provenance), hard for training |
| `induced` | injection classifiers plus provenance of the content | **Hardest.** It is an adjudicative finding after the fact, yet it gates registry validity |
| `recorded` | transparency log | Easy for presence, medium for completeness |
| commitment fields, `created` | structured mandates (AP2/ACP-like), Biscuit/UCAN | Easy for tokens. **Hard** to map natural-language negotiation to `created(C,I)` |
| `root/follows/allows/under/revokes` | capability tokens and a revocation list | Easy. But `root` names an *invocation* that often does not exist yet at grant time, so in practice you bind a key or session id |
| `recognized`, `kind` | KYB/KYC, adjudicator | Out of band. Easy for persons and orgs |
| `appointer/appoints` | governance records | Easy |
| `act_name/amount/obj/target/info`, `exclusive` | tool schema annotations, inventory | Names and amounts are easy. **Target** (URL → principal) and **info** (what an act reveals) are hard |

## Q4. Grain: one sampling request/response, with tool calls as acts

Answerability is coverage per invocation, so every act in one response has the same
answerers. That is sensible for parallel tool calls, and they no longer need a copy. The
problems:

* **Retries.** `g_retry.lp`: a stream aborts after an eagerly executed tool call, and the
  client retries the identical request. Type error 21 forces the retry to be a `copy`. Under a
  grant that follows only `continue`, the retry's booking is `ultra_vires`, with
  `resp_only` only. A routine network retry changes authority.
  * Best-of-n and regeneration hit the same problem.
* **One-shot approvals and parallel calls.** Registry acts and `until` take effect from the
  next step. Two parallel `pay 450` calls in one invocation both pass a one-shot 500 approval
  (`g_retry.lp`: `acts_for(j1,q1,p)` and `acts_for(j1,q2,p)`). Per-act caps also allow
  salami-slicing within one step.
* **Server-side tools and interleaved thinking.** One API response can contain several
  internal sampling steps, plus a web fetch whose result conditions later tokens. At API grain:
  * a `learns` late in the response combined with a `with` early in it is a "disclosure";
  * an injection that arrives mid-response vitiates registry acts emitted *before* it.

  At the model's own sampling grain these verdicts differ. The grain rule needs to say which
  boundary counts: the one the operator can log, which is the API request.
* **Streaming.** Harmless for content, since the context is hashed once per request. But
  `at(I,T)` is one instant, so a revocation that arrives mid-stream cannot stop acts later in
  the same response. That is acceptable only if "notice is instant" is dropped explicitly for
  within-response acts.

## Q5. Top three changes for v0.4 (no new primitives)

1. **Pins gate authority, never answerability; no power pins on opaque slots.**
   * Answerability becomes `in_lineage ∧ detached`, dropping `not eff_off_pin`. Alternatively,
     make "every machine lineage has an unpinned operator grant" a type error.
   * `pin(G,…,opaque(_))` with `grant(G)` becomes a type error, extending error 47. Pins on
     opaque content stay allowed for warranties, which must expire.
   * This fixes d1 #2 and #3 and d3 #1, and it makes "scope is public" true: counterparties
     can check a pin only on content they can observe.
   * The vendor's swap remains the vendor's breach towards the principal.
2. **Replace `with` by feeds that cross principals.**
   * Disclosure of X to Q becomes knowledge of X reaching, via `feeds`, an invocation that Q
     answers for.
   * An external service is Q's invocation, fed only by what the request actually carries.
   * This removes one base relation. It fixes d2 #1 (a GET carries no secret), d3 #2 (use is
     not a feed) and d1 #4 (a store read by the contractor *is* a feed into the contractor).
3. **Make vitiation and approval uniform and keyed on benefit.**
   * Apply `vitiated` to trigger acts too.
   * Void an induced act only when the inducer is its creditor or beneficiary. The existing
     `excused` rule already has this shape.
   * Add `conduct_of(I,A,Q) :- induced(I,Q), does(I,A)`, so that the injector answers.
   * Give `changed_by` a slot argument.
   * Let a retry or regeneration with an identical request be a `continue`: relax error 21 to
     allow several `continue` children when their content is equal.
   * Let `until` count acts rather than steps.
   * This fixes d2 #2–#5, d1 #1 and the retry and one-shot problems in Q4.
