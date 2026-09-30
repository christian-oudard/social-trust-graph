# Review B: v0.2 checked against the brief

Scope: /home/user/social-trust-graph/ontology (README.md, spec/, rust/, notes/), at HEAD dc6d9ae. I did not modify the repository. Everything below that says "ran" was executed. Probe files are in the scratchpad (`s2rb.lp`, `api.lp`, `ns.lp`).

Runs:
- `run.py`: 15/15 pass (11 scenarios x 3 hypotheses, plus checks C1, C3, C4 and C5), about 1 s.
- `props.py 200 1`: P1 to P4 pass.
- `mutants.py`: **62/62** killed.
- `cargo build --release` then `crosscheck.py --random 100`: 333 comparisons, all equal.

## Most important gaps, in order

1. **Identity is dissolved rather than defined.**
   - What the README says: "Is this the same agent? … the ontology does not ask it" (README:15). The word "identity" appears nowhere else in the README.
   - What the ontology actually has is a working criterion:
     - a principal is a registry key;
     - "acting as P" means lineage reachability under a recognized or created power (core.lp:127-163);
     - `continuation_of` is a successor rule (core.lp:293).
   - What is missing: that criterion is never stated as *the* answer to "what does identity mean". The README also never admits that identity comes back in through two unchecked record facts: the `continue` versus `copy` label, and `recognized` roots. Review R1 already pointed this out (notes/review_R1_foundations.md:14,35).
   - Machine-principal identity is entirely whatever root the adjudicator recognizes. In s3:75, one principal `m` is rooted at three unrelated lineages.
   - Fix: add a one-line **Identity** row to §3, e.g. "identity := principal (registry key) + the lineage closure its powers follow; 'same agent' is replaced by acts_for". Also say where identity is still presupposed: the edge labels and recognition.

2. **The human versus machine drift contrast is only partly captured, and not checked.**
   - Continuous versus discrete: present. Human change is an opaque slot, and assurance about opaque content must expire (types.lp:47, s7). Machine change consists of derived swap, rewrite and rollback events (core.lp:57-68).
   - **Mortality**: absent. There is no end-of-principal. Only `fills` end times exist.
   - **Reputation**: present only implicitly, as `open_defection`, `in_good_standing` and `continuation_of`. It is never framed as the thing that bounds human drift.
   - **Continuity**: the only rule is "at most one continue edge" (types.lp:21).
   - **Context contamination**: the `context` slot is declared (types.lp:303) but used in **zero** scenarios. `induced` (core.lp:178) covers injection by the creditor only. L4's "contaminated context" (README:182) is exercised only with an edited *prompt* (x3).
   - **"Externally caused" is modelled backwards.** A swap or rewrite is an act of the agent's *own* parent invocation (core.lp:73-76). I ran s1: `orphan(a2,swapping)` and `orphan(a1,rewriting)` hold under every hypothesis. The flagship drift events belong to nobody.
   - I added "Alice promises Bob not to swap" to s1. It is **not violated** by the s1 swap under any hypothesis. So README:77-78 ("'do not swap without notice' is an ordinary avoid commitment") holds only if the swapper's invocation is already covered with swap scope. The vendor or trainer who actually retrains cannot be named as the actor.
   - Copies diverging: met (s3, the fork law, P4).

3. **"Must not survive" really means "dormant", and it revives.**
   - I ran s2 with a rollback to w1 appended. Bob's w1-pinned consent `cb` stays `live` throughout: `covered(cb,a5)` and `excused(nb,a5)` both come back.
   - README:166 says the consent "lapses on swap", and this is inaccurate. Nothing ever ends because of content (by design, L3/C3).
   - No commitment that should not survive a *memory rewrite* is shown. Every pin in s2 is on weights.

4. **"Person is the core unit" is weakly reflected.**
   - Persons and orgs are symmetric: orgs get all four capacities primitively (core.lp:45-46). No rule requires authority to bottom out in a person.
   - "A person is one opaque self slot" (README:70) is not enforced. I ran `api.lp`: a `kind(zed,person)` running observable weights can be copied with no type error.
   - Conversely, types.lp:22 ("opaque content cannot be copied") makes forking an **API-model session** a type error, because README:71 says API weights are opaque. My probe gave `type_error(22)`. `same_as_ancestor` also excludes any opaque invocation, so an API agent's memory rollback is never detected.
   - So in the formalism, "person" versus "machine" is carried by opacity, and opacity gets both of them wrong.

5. **Accuracy slips in the README** (spot-checks below):
   - it says 61 mutants, but there are 62;
   - "every rule is mutation-tested" cannot be right, since there are 62 mutants against 144 rules;
   - the exhaustive checks are "every world", but `world.lp` generates no warranties, `feeds`, `induced`, `recorded`, pin/4 envelopes or exclusive objects. So C3's warranty-expiry clause is vacuous;
   - "Alloy … no path to code" (README:331) contradicts the survey's own "o, manual; clean struct/set mapping" (survey_B_tools.md:189);
   - notes/v0.2_changes.md:48 cites a "check C6" that does not exist.

6. **The README is not short: 3,147 words.** Proposed cuts to about 1,500 words are in §C below.

7. **The prior-art justification in the README is thin, although the notes are complete.**
   - README §7 names ADICO and Alloy.
   - It never names TLA+ or event calculus, and says "defeasible" nowhere. It never says that `live`/`ended_by` *is* event-calculus inertia hosted in ASP.
   - The survey (survey_B:199-233) recommended **Alloy** as the spec of record, with ASP only "if defeasibility turns out to be central". The README should cite that flip condition explicitly and say why it was met.

## A. Compliance table

| # | Brief requirement | Verdict | Evidence | Gap |
|---|---|---|---|---|
| 1 | Basic ontology for coordination problems, human and machine | met | README §1-2; core.lp:9-32 | Leans heavily on commitments; "coordination" beyond the commons coordinator (s6) is thin |
| 2 | Pipeline, not self: weights, prompt, scaffold, memory, session, lineage vary independently | met | slot vocabulary types.lp:302-303; edge/3 core.lp:26; README:64-78 | "Session" is not a slot. It is implicit in the invocation or context |
| 3 | Copy / rollback / merge / replace representable | partial | edge kinds; `rollback` core.lp:68; s1, s3, s5 | API-model copies are ill-typed (types.lp:22); opaque rollbacks are invisible |
| 4 | Human drift: continuous, slow, bounded by mortality, continuity, reputation | partial | opaque slot, expiring warranties (types.lp:47, s7); `in_good_standing` core.lp:297 | Mortality is absent. Reputation is not tied to drift. Nothing is checked beyond s7 |
| 5 | Machine drift: discrete, externally caused (retrain, swap, prompt/memory edit, context contamination) | partial | swap/rewrite core.lp:57-60; x3 prompt edit; `induced` | The cause is attributed to the agent's own parent invocation (orphan in s1). The `context` slot is unused. Third-party contamination is unmodelled |
| 6 | Copies diverge | met | s3; fork law L5; P4; `overcommitted` core.lp:211 | none |
| 7 | State clearly what **identity** means | partial | README:15-20; acts_for core.lp:162; continuation_of core.lp:293 | No explicit definition. Presupposed identity in `continue`/`recognized` is not acknowledged |
| 8 | State what **commitment** means | met | README:50-62; core.lp modes | none |
| 9 | Agreements bind as values drift | met | L3; C3; s1 (NDA binds after rewrite, swap and rollback) | Values themselves are unrepresented (only content hashes). This is disclosed at README:345 |
| 10 | Ontology plus vocabulary, not protocol or implementation | partial | README:3 | The Rust port is an implementation of the evaluator; see §D |
| 11 | Name and define primitives with precise relations | met | README §2-3; core.lp | About 40 base relations sit behind "five sorts" |
| 12 | Candidate terms addressed (principal … repair) | met | README §3 table; every term has a status | "invariant: dropped" is defensible |
| 13 | Formal language that converts easily to code | met | core.lp; Rust port with 333/333 equal | none |
| 14 | Survey ADICO | met | survey_A §1; README:302 | none |
| 15 | Survey deontic logic | partial | survey_A §2 (Hohfeld), §4 (Governatori), CTD at :42 | No standard deontic logic, STIT or dynamic deontic entry |
| 16 | Survey defeasible logic | met (notes) / unmet (README) | survey_A §4; survey_B:134 | Not named in the README |
| 17 | Survey event calculus | met (notes) / unmet (README) | survey_B §5; survey_A §3.4 | The README omits it and does not note that `live` is EC inertia |
| 18 | Survey Alloy | met | survey_B §1; README:331 | "no path to code" overstates |
| 19 | Survey TLA+ | met (notes) / unmet (README) | survey_B §2 | Absent from the README |
| 20 | Survey Datalog | met | survey_B §3; README:320-330 | none |
| 21 | Pick the best fit and justify | partial | README:320-332 | The survey's own recommendation was Alloy; the flip condition is not cited |
| 22 | Justify invented notation | met | README:333 "No notation was invented"; gaps at README:312-319, survey_A §7 | The gaps are asserted. No encoding attempt in Symboleo or InstAL is shown failing |
| 23 | Test: commitment survives swap **or** memory rewrite | met | s1 (README:260); run.py pass | none |
| 24 | Test: commitment that must not survive | partial | s2 | It is dormant, not ended, and revives on rollback (ran). There is no memory-rewrite case |
| 25 | Test: divergence of two forks of one lineage | met | s3 | none |
| 26 | Test: human delegates narrow scope to a machine | met | s4 (cap, pin, cascade) | none |
| 27 | Test: fork + simulate counterparty + parallel negotiation sharing learning | met | s5 | "Many" means two forks; that is acceptable |
| 28 | Person is the core unit | partial | persons/orgs fixed, machines hypothetical (core.lp:45-47); P1 | Org is equal to person. Person opacity is not enforced. No rule grounds authority in persons |
| 29 | Machines as bearers of commitments | met | kind machine; `hyp` bundles; s3, s4, s6 | none |
| 30 | Party versus delegate represented explicitly, not assumed | met | core.lp:41-48; run.py runs every scenario under 3 hypotheses | Strong point |
| 31 | Coordinator is a role, not a party | met | types.lp:309 type_error 4; s6 | none |
| 32 | No protocol syntax until a proof of concept exists | met | no message or wire syntax anywhere | none |
| 33 | Coalesce downward; few primitives | partial | v0.2 dropped evidence, substrate, invariant (notes/v0.2_changes.md) | Added permit, warrant, act sort, recognized, induced, recorded, feeds, appointer, security. The relation count grew |
| 34 | Falsifiable claims | met | laws L1-L10 tagged; mutants 62/62; checks with non-vacuity | C3 and C5 reuse the core's own relations (`parent_grant`, `unanswerable`), which is partly circular (R2 flagged this) |
| 35 | Every addition replaces or sharpens | partial | v0.2 dispositions table | Several additions are pure accretion (security, appointer, recorded) |
| 36 | Short document plus machine-checkable spec | partial | spec is machine-checkable (ran) | README is 3,147 words |

## B. README claims spot-checked (13)

| Claim (README line) | Result |
|---|---|
| ~140 Datalog rules (5) | TRUE: 144 rules with `:-` |
| Rust port cross-checked (7, 328-330) | TRUE: 333 comparisons equal. "Line-by-line" is loose: 160 ascent rules plus `_h` history relations |
| 61 mutants, all caught; "every rule" (122) | FALSE / overstated: 62 mutants, 144 rules |
| Exhaustive world "with roles, triggers, reparations, learning, merges, all three hypotheses" (117-119) | TRUE as listed, but it omits warranties, feeds, induced and envelopes |
| Scenarios run under all 3 bundles (272) | TRUE (run.py:43) |
| core.lp has no choice rules or aggregates (320) | TRUE |
| Consent pinned to a model "lapses on swap" (166) | MISLEADING: it stays `live` and re-covers after rollback (ran) |
| "Do not swap without notice" is an ordinary avoid (77-78) | ONLY IF the swapper is in scope. It is not violated in s1 (ran) |
| Coordinator is a role (48) | TRUE (type_error 4) |
| Persons never revert, so never forget (213) | TRUE (s7 `knows(h2,xs)`) |
| An API model's weights are opaque (71) | TRUE, but this makes API forks type errors (ran) |
| Answerers only grow delegate→actor→party (227) | TRUE (P1 200 trials) |
| Fresh instantiation does not inherit defections (163) | TRUE (mutant "fresh copies inherit" killed) |
| Alloy has "no path to code" (331) | CONTRADICTED by survey_B:189 |

## C. Compressibility

Word counts by section: §1 200, §2 432, §3 287, **§4 1,008**, §5 396, §6 162, §7 334, §8 180, §9 50.

Cuts, to reach about 1,500 words:
- **§4**: make each law one sentence plus its tags, and move the sub-bullets to core.lp comments. This saves about 600.
- **§5**: keep a single column of one-clause outcomes. The scenario headers already say the rest. This saves about 250.
- **§7**: keep one paragraph: reused ideas, the gap, why ASP beat Alloy/TLA+/EC. Move the legal list to notes. This saves about 200.
- **§3**: merge into §2 (substrate, invariant and evidence are already defined in §2). This saves about 150.
- **Header**: drop the Rust bullet. This saves 20.
- **Add** about 80 words: an Identity definition and the human/machine drift contrast (mortality, reputation, context).

## D. Is the Rust port an "implementation" or "protocol syntax"?

- **Against (it violates the brief):**
  - The brief says "not a protocol or an implementation" this month.
  - A 543-line executable engine with a JSON input format is an implementation. It doubles the surface that every change must keep in sync.
  - Its JSON fact schema is a proto-interchange format.
  - It was built twice (v0.1 and v0.2), which is effort that the brief's "coalesce" discipline would have spent elsewhere.
- **For (it is acceptable):**
  - The brief *requires* a language "that converts easily into code". The port is the evidence for that claim.
  - It adds no semantics and is used only as a differential oracle (crosscheck.py).
  - It contains no message formats, roles in an exchange, or wire syntax, so it is not *protocol syntax*.
- **Verdict:** not protocol syntax; technically an implementation. It is acceptable if it is labelled as conversion evidence and kept out of the README's headline.
