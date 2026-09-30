# R4: Practice review. Does the ontology fit real LLM systems?

Reviewer stance: someone who builds production agent systems (multi-agent orchestration, MCP tool use,
long-running agents with memory stores, RAG, fine-tuning, prompt caching, model routing, sub-agents,
sandboxed execution, model rollouts).

Scope read: `README.md`, `spec/core.lp`, `spec/types.lp`, `spec/scenarios/s1..s7`. Claims marked
**[probe]** were checked by running small fact sets against the unmodified `core.lp` and `types.lp`
with clingo 5.8.2. The probe script is in `scratchpad/probes/p1.py`, outside the repository.

## Verdict

The **authority half** (grants, attenuation, pins, the registry keyed by principal, the fork law)
maps well onto capability systems. It already works as a pre-act authorizer, because
`acts_for(I,A,P)` does not depend on `does`. That half is implementable, and Biscuit/UCAN plus
signed, hash-chained invocation records cover most of it.

The **knowledge half** (L7) and the **substrate model** do not yet fit practice. Four things go
wrong:

1. Knowledge rides on *lineage* ("which"), but in real systems information moves by *content
   derivation* ("what"): stores, prompts, transcripts, training data.
2. Substrates are hash *sets* per slot, which fails open.
3. Nothing says who may assert an `edge`.
4. Verdicts depend on the grain of "invocation".

Each can be fixed by *removing* or *merging* things, not by adding.

## Findings

### F1. Critical: knowledge flows along lineage, but in practice it flows along content derivation

L7 puts knowledge on `edge/3`. The README's own load-bearing move is to keep *which* (lineage) apart
from *what* (content). L7 breaks that move, and it fails in both directions.

**Fail-open cases, where real flows are invisible to `knows`:**

* A shared vector DB or memory service read by two lineages.
* A sub-agent spawned with a task prompt. s4 models the spawn as a fresh root with no edge.
* Fine-tuning or distillation on a peer's transcripts.
* Operator log review.

None of these is an edge, so `knows` never crosses them.

* **[probe E]** A learner whose next `continue` step runs the *same* substrate forgets at once:
  `learns(a1,sec)`, then `edge(a1,a2,continue)`, and `runs(a2,s)` equals `runs(a1,s)`.
  The core derives `scrubbed(a2,sec)`, and `knows(a2,sec)` is not derived. The cause is that the
  scrub-by-rollback rule accepts any content seen before the learning, and no scenario ever
  populates the `context` slot. So in the normal case, where the learning sits in the context
  window and weights, prompt and memory are unchanged, the knowledge is dropped after one step.
* **[probe E2]** `seen_before` is global rather than per lineage. If an *unrelated* lineage ran the
  same content earlier, that scrubs a different lineage's knowledge.

**Fail-closed or wrong-authority cases:**

* **[probe G]** Modelling memory sync as `merge` from another principal's agent makes the receiver
  `acts_for` both principals, if the other principal's grant follows merge. Sharing information
  then confers authority.

**Proposed change (coalescing).**

* Make taint *content-keyed*. Knowledge attaches to hashes: `taints(H,X)` and
  `derived(H2,H1)`, where derivation covers write, summarize, index, train and distill.
  Then `knows(I,X) :- runs(I,S), part(S,_,H), tainted(H,X)`.
* Scrubbing becomes "running content with no tainted hash". The rollback rule and `clean/3` then
  collapse into a single rule.
* Lineage edges carry authority only.
* This also drops `merge` as an information mechanism. Merge stays only as an authority join, and
  could even become "continue with two parents".
* `imputed/2` currently has no consumer. Either use it, for instance in a principal-level
  disclosure, or drop it.

### F2. Critical: nobody is required to assert an edge, so copying is possession of a key

L1 says possession of a key is not attribution, yet `edge` is a bare fact.

* **[probe H]** `edge(a1,thief,copy)` under a grant that follows copy gives
  `acts_for(thief,_,p)` for every act.
* In practice, anyone holding the exported context, or the open weights plus a transcript,
  can "copy". A copy also carries any bearer token held in its state.
* The reverse also holds. `follows(copy)=no` is unenforceable unless counterparties can check
  lineage proofs.

**Proposed change.**

* Make edge creation an *act* of the parent (`does(I1, spawn(I2,K))`) under `within`, so that
  forking is scoped like everything else. This lets `follows/2` fold into scope names
  (`allows(G,fork_copy,_)`).
* Implement edges as parent-signed records: each invocation gets an ephemeral key certified by
  its parent's key, SPIFFE/SVID style. Where the "no uncovered copy" claim matters, seal the key
  in a TEE.

### F3. High: verdicts depend on grain

These are two reasonable grains giving different verdicts on the same run.

* **Parallel tool calls [probe A/A'].** Type error 15 forbids two `continue` children. So at
  tool-call grain, the second parallel call must be a `copy`. Under the default grant
  (`follows(continue)` only) it becomes `orphan(t2,y)`. At turn grain the same call is covered.
* **Salami caps [probe B].** A pay of 900 fails a 500 cap. Two pays of 450 in two tool calls both
  pass. So caps are per act, and act boundaries are a choice of grain.
* **Disclosure ordering.** `knows ∧ with` ignores order inside an invocation. At turn grain, an
  orchestrator that talks to Q2 and *later* learns X from Q1 has "disclosed". At step grain it has
  not.
* **Streaming and tokens.** Context changes every token. If `context` is a slot, `rollback` and
  the rollback scrub essentially never fire, except for exact checkpoint restore. If it is not a
  slot, you get probe E.

**Proposed grain.**

* An invocation is **one sampling request/response**: full input in, one assistant message out.
  This is the unit that is signed, logged, cached and traced (OTel GenAI spans).
* Tool calls, including parallel ones, are *acts* of that invocation.
* Tool results enter the *next* invocation's context via `continue`.
* A sub-agent is a new root created by a `spawn` act (see F2).
* Tokens are never invocations.
* Make `context` a mandatory slot.
* Add a metamorphic property P5 (grain invariance). Coarsening a `continue` chain whose non-context
  slots agree must preserve `acts_for`, `violated`, `overcommitted` and `knows`. Today it fails
  the first three cases above.

### F4. High: slots are sets, so pins and tests fail open

* `part(S,Slot,H)` is multi-valued.
* **[probe C]** A substrate with `weights ∋ {w1, lora_evil}` satisfies `pin(g,weights,w1)`, and a
  weights test on w1 still `supports` it.
* **[probe D]** A test whose tested substrate has *no* hash in the tested slot (an API model) has
  no `slot_mismatch` for any substrate, so it supports everything.

**Proposed change.**

* Make a slot functional: exactly one hash per slot, with a type error otherwise. Use a Merkle
  composite for anything layered: weights = H(base, adapters, quantization, merge recipe).
* Make a missing tested slot a mismatch.
* A pin set remains the change envelope.

### F5. High: the slot list is incomplete, and API content is not observable

These change behaviour today but are invisible to it:

* tool definitions and MCP server identities and versions;
* the retrieval corpus or index version;
* decoding parameters and seed;
* the router, and the model it actually chose;
* the provider's hidden system prompt and safety layers;
* external memory stores (by snapshot).

**Proposed change.** Do not add sorts. Replace the fixed five slots with a path-named manifest
(`weights/…`, `decoding`, `tools/…`, `retrieval`, `prompt`, `scaffold`, `memory/…`, `context`) and
functional hashes.

**API models.** Treat an API model as *partially opaque*: `part(S,weights,opaque(provider,snapshot_id))`.

* A pin on a dated snapshot ID is only as strong as the provider's attestation. A pin on an alias
  such as "-latest" should be a type error.
* Require every test over an opaque part to carry a `horizon`.
* This merges the API case with the existing human rule: the person is the fully opaque limit, and
  a self-hosted model is fully transparent.
* Routers: record the realized model per request, which providers return. Pin the realized
  weights, not the router.

**Nondeterminism.** Batching and floating-point effects mean that the same content can yield
different acts. `refrains` should carry a rate and a sample size. "Rollback restores assurance"
and "simulation gives valid assurance" (s5) hold only statistically.

### F6. Medium: mapping real operations to edges

| Operation | Current fit | Proposal |
|---|---|---|
| Continuing a conversation turn | `continue` | ok |
| Branching or regenerating from an earlier message | `copy` from the older invocation | ok |
| Compaction or summarization | `continue` with a context change (not a rewrite) | a derived context hash, taint carried (F1) |
| Checkpoint restore | `continue` → `rollback` | ok for authority. It is **not** a scrub unless the sandbox, stores and caches are also restored |
| Framework fork (LangGraph Send, parallel branches) | `copy` | ok, but see F3 for parallel tool calls |
| Sub-agent with a fresh prompt | no edge (s4) | `spawn` act (F2) and derivation of its prompt (F1) |
| Memory store sync | `merge`, which confers authority (probe G) | derivation, not lineage |
| Fine-tuning on a peer's transcripts | nothing fits: a merge would confer authority | derivation of new weights. Their next use is a swap |
| Distillation | not a copy: no invocation is shared | derivation. Authority does not transfer |

### F7. Medium: `knows + interacts = discloses` is too conservative, yet not safe

* Every tool call to a third-party MCP server after learning anything becomes "disclosure".
* A multi-party coordinator discloses everything to everyone.
* Meanwhile shared stores leak silently (F1).

**Proposed change.** Key disclosure on the *outbound message content*: `sends(I,Q,H)` with a
tainted H, plus the existing `clean/3` applied to an egress filter hash. This reuses the machinery
and adds no new concept.

**Prompt caches.** They are knowledge-neutral under exact-prefix keying, which is fine. The only
real exposure is cross-tenant timing side channels, and that is out of scope.

### F8. Medium: conditional grants are ignored, so human approval is not expressible

* **[probe F]** A grant with `trigger(gh,approve)` covers before any approval, because `covered`
  uses `live` rather than `detached`.
* Fix: use `detached` for grants. Human-in-the-loop approval then becomes a conditional grant
  triggered by the human's approve act.
* Also allow `allows(G,A_id,_)` for one-shot, per-act approval.
* Escalation is then already expressible: an `orphan` or `ultra_vires` check becomes a pre-act
  query, and the answer "no" routes to a covered principal.

### F9. Medium: budgets, idempotency, attempt versus effect

* **Budgets.** Rate limits and spend budgets need sums per grant per window, which the README
  already lists as a known limit. Ascent supports lattices and aggregates. Express a budget as the
  existing exclusive-resource constraint generalized to quantities, rather than as a new concept.
* **Idempotency.** Make act IDs the idempotency keys: `does(I1,A)` and `does(I2,A)` then count as
  one effect.
* **Attempt versus effect.** Separate an emitted tool call from an effect acknowledged by the
  counterparty's receipt. Timeouts and retries are the common case.

### F10. Low: confused deputy and prompt injection

* `acts_for` ignores *whose instructions* drove an act. Under L2, the principal answers for
  everything an injection makes the agent do in scope.
* That may be the right answer for liability, but a production authorizer needs integrity taint.
* The fix is the same content-derivation machinery as F1, with integrity labels, CaMeL/FIDES
  style. No new sort is needed.

## Engineering primitive for each base relation, and how hard it is to attest

| Relation | Primitive | Difficulty |
|---|---|---|
| `runs`, `part` (self-hosted) | model signing (Sigstore/OMS), manifest hash, TEE quote | easy |
| `runs`, `part` (API) | provider-signed response with snapshot ID (mostly unsigned today) | hard |
| `edge` | parent-signed invocation record, hash-chained | medium; sealing needs a TEE |
| `at` | RFC 3161 or Roughtime timestamps | easy |
| `does`, `with` | signed transcripts plus counterparty receipts | medium |
| `record` (completeness) | append-only transparency log with gap detection | medium |
| grants, `allows`, `revoked`, attenuation | Biscuit/UCAN plus a revocation list | easy (propagation latency is the limit on the revocation rule) |
| `learns` | taint labelling (IFC) | hard |
| `clean` | deterministic redaction filter with a hashed filter | feasible for text, **unattestable for weights**, since unlearning cannot be verified. Restrict it to text slots |
| `test`, `refrains` | signed eval over a manifest hash | easy to sign, statistically weak |
| `fills` | role registry | easy |
