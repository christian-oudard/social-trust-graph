# B. Formal tooling survey for a commitment ontology (human and LLM-agent parties)

Survey date: 2026-09-30. Environment used for hands-on checks: Ubuntu 24.04 container, OpenJDK 21.0.10, Python 3.11.15, cargo 1.94.1.

Legend: **[RUN]** = I executed it in this container and saw the result. **[SRC]** = read in the tool's own source or repo. **[WEB]** = confirmed on a publisher, registry or project page (URL given). **[UNVERIFIED]** = plausible, but I did not confirm it.

Hands-on test artifacts (scratchpad):
- `.../scratchpad/tools/commit.als`: Alloy 6 temporal model (agents, substrates, anchored commitments, a false and a true assertion)
- `.../scratchpad/tools/ec.lp`: clingo event-calculus model with choice rules used as a counterexample search
- `.../scratchpad/tools/tla/C.tla` and `C.cfg`: TLC toy spec
- `.../scratchpad/tools/dltest/`: Rust crate using `ascent` 0.8.1 and `crepe` 0.2.0 with stratified negation

---

## 1. Alloy 6

### Current release and download [RUN][SRC]
- The latest release is **v6.2.0**. `https://github.com/AlloyTools/org.alloytools.alloy/releases/latest/download/org.alloytools.alloy.dist.jar` redirects to `.../releases/download/v6.2.0/org.alloytools.alloy.dist.jar` (HTTP 200, 21,062,377 bytes, sha256 `6b8c1cb5bc93bedfc7c61435c4e1ab6e688a242dc702a394628d9a9801edb78d`). `java -jar alloy.jar version` prints `6.2.0`.
- v6.2.0 also ships `alloy-6.2.0-linux-amd64.tar.gz` (about 52 MB, with a bundled runtime).
- Probes for v6.2.1, v6.3.0 and v7.0.0 return 404. There is a git tag `v6.3.0-begin`, and master HEAD is 2026-06-11, so 6.3 is in development but unreleased.
- The README says the tool requires Java 17 or later. It ran fine on Java 21 [RUN].
- Release page: https://github.com/AlloyTools/org.alloytools.alloy/releases . Alloy 6 overview: https://alloytools.org/alloy6.html

### Headless CLI: an official one exists [RUN][SRC]
`org.alloytools.alloy.cli/src/main/java/org/alloytools/alloy/cli/CLI.java` is in the official repo and inside the dist jar. `java -jar alloy.jar help` lists these sub-commands: `natives, prefs, solvers, version, gui, commands, exec, ls, lsp`.

The command that matters is **`exec`**, which executes **all** `run`/`check` commands in the file by default:
```
java -jar alloy.jar commands model.als                      # list commands with their indexes
java -jar alloy.jar exec -f -o out -t text model.als        # run all; results written to ./out/
java -jar alloy.jar exec -c 'NoLoss*' -o - -t json model.als   # glob or index select; '-' = stdout
java -jar alloy.jar exec -s minisat -r 3 ...                # native solver; up to 3 solutions
```
Options, per the source: `-c/--command` (glob or index), `-t/--type none|text|table|json|xml`, `-o/--output dir|-`, `-f/--force`, `-s/--solver` (default sat4j), `-r/--repeat`, `--nooverflow`, `-u/--unrolls`, `-q/--quiet`, `-e/--evaluator`.

Output from my run:
```
00. check NoLoss                   0    1/1     SAT       <- counterexample found (a lasso trace, state by state)
01. check UnanchoredSurvive        0       UNSAT     <- holds within scope
02. run   Show                     0    1/1     SAT
```
The output directory contains `<Cmd>-solution-N.{txt,json}` plus a `receipt.json` that summarises every command.

Gotchas I verified:
- **Exit code is 0 even when a `check` finds a counterexample.** It becomes non-zero (exit 1) only when you annotate commands with `expect 0` or `expect 1` and the result contradicts the annotation. Example: `check NoLoss for 3 but 4 steps expect 0` then produces `Error ... was satisfied against expectation` and exit status 1. For CI, annotate every command with `expect`.
- Native solvers `minisat`, `glucose` and `minisat.prover` (unsat cores) work on linux/amd64 out of the box. The default is Java `sat4j`.
- Minor source bug: `opt.symmetry = options.depth(opt.symmetry)` reads the depth option where it should read the symmetry option (CLI.java, `_exec`), so `--ymmetry` is effectively ignored.
- The `solvers` list shows only an `electrod.elo` *transformer*. The unbounded model-checking backend (Electrod plus nuXmv) is not wired in as a solver in this jar, so treat analysis as **bounded** (`for N but K steps`) [RUN, inferred from the solver list].

### Fit
- Relational logic over typed signatures (`sig`, subtyping, multiplicities `one/lone/some/set`) is the closest match to "a dozen primitives, precise relations".
- `var sig`, `var` fields, primes (`x'`) and past and future LTL (`always, eventually, after, until, releases, historically, once, before, since, triggered`) cover events that change which commitments hold.
- Commands `check`/`run ... for N but K steps` give bounded counterexamples as lasso traces. A GUI visualiser exists, but the CLI emits text or JSON.
- Defeasibility is not native. Alloy is classical first-order logic. You encode "survives unless anchored" as an explicit frame condition. That is exact inside a closed, bounded world, but not elaboration-tolerant: adding a new exception means editing the frame condition.
- No code generation to Rust. You translate sigs to structs and relations to `HashSet<(A,B)>` by hand. That translation is straightforward, but it is manual.
- Background: Electrum was the precursor of Alloy 6's temporal layer. Brunel, Chemouil, Cunha, Macedo, "The Electrum Analyzer: model checking relational first-order temporal specifications", ASE 2018 [WEB: https://www.researchgate.net/publication/327132014]. Pardinus is the temporal relational model finder [WEB: https://www.researchgate.net/publication/362412021]. A free book is *Formal Software Design with Alloy 6* (haslab) [WEB: https://haslab.github.io/formal-software-design/].

### Prior work: Alloy for agents, norms, commitments and access control
- Podorozhny, Khurshid, Perry, Zhang, "Verification of Multi-agent Negotiations Using the Alloy Analyzer", IFM 2007, LNCS 4591, pp. 501-517. It describes itself as the first application of Alloy to MAS. [WEB: https://link.springer.com/chapter/10.1007/978-3-540-73210-5_26]
- "An Alloy Verification Model for Consensus-Based Auction Protocols" [WEB: https://arxiv.org/pdf/1407.5074]
- Spatio-temporal RBAC analysed in Alloy, with counterexamples [WEB: https://www.researchgate.net/publication/221495112]. E-RBAC with Alloy (J. Inf. Sec. Appl. 2019) [WEB: https://dl.acm.org/doi/10.1016/j.jisa.2019.01.008]. RBAC-to-XACML translation validated with Alloy [WEB: https://link.springer.com/chapter/10.1007/978-3-642-11811-1_26]. OAuth 2.0 in Alloy (Pai et al.) [WEB: https://www.semanticscholar.org/paper/84627584b6fcf78c896d473b4b0e24dc089d814b]
- **Gap:** I found no substantial published Alloy model of *social commitments* (Singh-style C(debtor, creditor, antecedent, consequent)) or of normative systems. Chopra et al., "Analyzing Contract Robustness through a Model of Commitments" (AOSE 2010, LNCS 6788) is a commitment model of contracts, but its text mentions no Alloy or model checker. I checked by extracting its PDF: https://www.lancaster.ac.uk/~chopraak/pdfs/contracts-2010.pdf. The commitment-verification literature mostly uses event calculus, ASP, CSP or model checkers (NuSMV/MCMAS), not Alloy. Treat "commitments in Alloy" as largely open ground, which is both an opportunity and a risk.

---

## 2. TLA+ (TLC, Apalache, Quint)
- **TLC**: the latest non-prerelease is **v1.7.4**. `releases/latest/download/tla2tools.jar` redirects to v1.7.4. v1.8.0 "Clarke" (2024-09-30) is marked pre-release. The nightly is at `https://nightly.tlapl.us/dist/tla2tools.jar` [RUN]. `java -cp tla2tools.jar tlc2.TLC -deadlock C` on my toy spec reported `Action property NoLoss is violated` with a state trace [RUN].
- **Apalache**: latest **v0.62.2** (resolved via the `releases/latest` redirect) [RUN]. The tarball contains `apalache/bin/apalache-mc` and `apalache/lib/apalache.jar` [RUN]. It is actively maintained under github.com/apalache-mc [WEB]. It is SMT-based (Z3) bounded model checking with type annotations (Snowcat).
- **Quint**: typed, code-like syntax for TLA+ semantics, with a simulator and an Apalache backend. `@informalsystems/quint` 0.33.0 was published 2026-09-28 on npm [RUN].
- Fit: very mature and good at *protocol and state-machine* safety and liveness, including fairness. It is weaker for our needs:
  - Relations are sets of tuples or functions in untyped ZF set theory (TLC) or lightly typed (Apalache/Quint). There is no relational join or transitive-closure algebra comparable to Alloy's.
  - No defeasibility.
  - TLC enumerates states explicitly, so it needs concrete CONSTANT sets; it does not search over unknown *structures* the way Alloy searches over all relation instances up to a scope.
  - Conversion to Rust is manual.

  Choose it if the eventual concern is concurrency and interleaving (fork/merge races), not ontology structure.

---

## 3. Datalog: Soufflé and Rust-embedded engines

| Crate | Version / updated | Status | Negation | Notes |
|---|---|---|---|---|
| `ascent` | 0.8.1, 2026-08-29 | active (repo HEAD 2026-08-29) | stratified `!rel(..)` [RUN] | aggregates (`agg`), lattices, `ascent_par!`, BYODS (OOPSLA 2023, DOI 10.1145/3622840) and CC paper "Seamless Deductive Inference via Macros" [WEB: https://github.com/s-arash/ascent] |
| `crepe` | 0.2.0, 2025-12-14 | maintained, slow-moving (HEAD 2025-12-13) | stratified `!Rel(..)` [RUN] | no aggregates or lattices in README; Rust fns callable in rules [WEB: https://github.com/ekzhang/crepe] |
| `datafrog` | 2.0.1, 2019-01-02 | frozen but widely used (Polonius) | antijoin primitive only | low-level engine, not a language |
| differential-datalog (DDlog) | last release v1.2.3, 2021-12-13 | **archived**, repo under `vmware-archive` (read-only) [WEB: https://github.com/vmware-archive/differential-datalog/releases] | stratified | not published on crates.io; do not adopt |
| Soufflé | 2.5, 2025-03-24 | active | stratified | `.deb` for Ubuntu 24.04 verified: `x86_64-ubuntu-2404-souffle-2.5-Linux.deb` [RUN] |
| `biscuit-auth` | 6.0.0, 2025-07-16 | active | yes (checks and policies) | Datalog **for capability delegation with offline attenuation**; very relevant precedent for delegation scope [WEB: https://doc.biscuitsec.org/getting-started/introduction.html] |

Hands-on [RUN]: the rules below compile and run identically in `ascent` and `crepe`, giving `survives = {2}`:
```
dropped(c) <-- commitment(c,a), swapped(a,s), anchored(c,s);
survives(c) <-- commitment(c,_), !dropped(c);      // default: survives unless dropped
```

**Important limitation [RUN]:** ascent requires *predicate-level* stratification. A classic event-calculus inertia rule where clipping depends on the current fluent value (`clipped(c,t) <-- happens(c,t), holds(c,t); holds(c,t+1) <-- holds(c,t), !clipped(c,t)`) is rejected with `cannot be stratified`. clingo accepts the same program because it is only *locally* stratified by time [RUN]. The practical Rust design is therefore a **per-step fold**: `state_{t+1} = datalog(state_t, events_t)`, which is also the natural event-sourced architecture.

Conversion to Rust: this is the best of all options. ascent and crepe rules are Rust macros whose rules are nearly 1:1 with textbook Datalog, typed by Rust tuple and struct types.

Datalog has **no counterexample search**. It computes the unique least model from given facts; it does not search for facts. You can property-test it with `proptest` over generated event traces, which is random rather than exhaustive-bounded.

Trust-management precedent (Datalog as delegation logic):
- Li and Mitchell, "Datalog with Constraints: A Foundation for Trust Management Languages", PADL 2003 [WEB: https://link.springer.com/chapter/10.1007/3-540-36388-2_6]
- DeTreville, "Binder, a logic-based security language", IEEE S&P 2002 [WEB: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/tr-2002-21.pdf]
- Becker, Fournet, Gordon, "SecPAL" [WEB: https://people.mpi-sws.org/~dg/teaching/lis2014/modules/authorization-1-becker07.pdf]

---

## 4. Answer Set Programming (clingo / Potassco)

### Install [RUN]
- `python3.11 -m pip install clingo` installs **clingo 5.8.2** (PyPI release 2026-08-14; wheels for CPython 3.9 to 3.14, manylinux x86-64/arm64) [WEB: https://pypi.org/project/clingo/]. The latest git tag is v5.8.2.
- **Gotcha:** the 5.8.2 wheel installs **no `clingo` console script** (the dist-info has no `entry_points.txt`). Use `python3 -m clingo file.lp` [RUN]. For a standalone binary, use conda (`conda install -c potassco clingo`) or build from source [UNVERIFIED for 5.8.2].
- Related packages: `clorm` 1.6.3 (2026-08-20; typed ORM for ASP facts in Python), `telingo` 2.1.3 (2024-02-15; temporal ASP), `clingox` 1.2.1 [RUN, PyPI JSON].

### Bounded model finding with ASP [RUN]
The pattern in `ec.lp`:
- Choice rules generate unknowns: anchoring, the initial state, and at most one event per step (`{ happens(E,T) : event(E) } 1 :- time(T), T<n.`).
- Event-calculus rules derive fluents using default-negation inertia: `holds(F,T+1) :- holds(F,T), not clipped(F,T).`
- An integrity constraint keeps only violating traces: `:- not bad.`

Results:
- The true claim ("an unanchored commitment is never lost except by discharge") gives `UNSATISFIABLE`, meaning no counterexample up to horizon n=4.
- The false claim ("no commitment is ever lost by a swap") gives `SATISFIABLE` with a concrete trace: `anchor(c1,s2) ... happens(swap(a1,s1),3)`.

This is exactly Alloy's `check` semantics, done by hand.

Precedent: Heljanko and Niemelä, "Bounded LTL Model Checking with Stable Models", TPLP 2003 [WEB: https://arxiv.org/pdf/cs/0305040]. Temporal ASP (telingo): Cabalar et al., "Linear-Time Temporal Answer Set Programming", TPLP [WEB: https://www.cambridge.org/core/services/aop-cambridge-core/content/view/AB07F1F913DC0068B22E2A929276EDD2/S1471068421000557a.pdf/lineartime_temporal_answer_set_programming.pdf].

### Event calculus in ASP
Kim, Lee, Palla, "Circumscriptive Event Calculus as Answer Set Programming", IJCAI 2009, pp. 823-829, with the `ecasp` prototype [WEB: https://www.ijcai.org/Proceedings/09/Papers/141.pdf ; http://decreasoner.sourceforge.net/csr/ecasp/].

### Defeasibility
This is native. `not` is negation as failure, so "X unless Y" is `x :- ..., not y.` Adding a new exception adds a rule and never edits the old one, which is the elaboration tolerance Alloy lacks. Weak constraints (`:~`) give preferences. See also "Deontic Paradoxes in ASP with Weak Constraints" [WEB: https://arxiv.org/pdf/2308.15870].

### InstAL (institutional action language compiled to ASP)
- InstAL is a DSL with `exogenous event`, `inst event`, `violation event`, `fluent`, `obligation fluent obl(act, deadline, violation)`, `generates`, `initiates`/`terminates`, `pow`/`perm`. It compiles to AnsProlog and is solved by clingo with a bounded number of steps [WEB: https://instsuite.github.io/ ; Springer chapter https://link.springer.com/chapter/10.1007/978-3-319-33570-4_6].
- Repo `github.com/instsuite/instal-stable`: last commit **2023-07-14**. Its INSTALLATION.md pins **clingo 5.1.0 built from source and Python 3.4**, and its `requirements.txt` pins 2017-era packages [RUN/SRC]. **Status: stale.** Use it as a design precedent, particularly its vocabulary of `obl/3`, power versus permission, and generation, not as a dependency.
- Foundational paper: Cliffe, De Vos, Padget (2006), on ASP for virtual institutions [WEB, via search; exact title not re-verified].

### clingo from Rust
- `clingo` crate 0.8.0 (updated 2023-10-20) and `clingo-sys` 0.7.2 [RUN crates.io]. Repo `potassco/clingo-rs` last commit **2024-01-08** [RUN].
- The README says it targets clingo **5.6.2**. It links dynamically by default (needs `CLINGO_LIBRARY_PATH`), with a `static-linking` feature that builds clingo with CMake and a C++14 compiler [WEB: https://github.com/potassco/clingo-rs].
- **Status: usable but stale** (about 2.5 years without commits; behind 5.8). A subprocess (`python3 -m clingo --outf=2` gives JSON output) is the lower-risk integration.

---

## 5. Event calculus and commitments (literature, all [WEB])
- Kowalski and Sergot, "A logic-based calculus of events", *New Generation Computing* 4:67-95, 1986. https://link.springer.com/article/10.1007/BF03037383
- Shanahan, "The Event Calculus Explained", in *Artificial Intelligence Today*, LNCS 1600, 1999. https://link.springer.com/chapter/10.1007/3-540-48317-9_17
- Singh, "An ontology for commitments in multiagent systems", *AI and Law* 7:97-113, 1999 (commitment operations; spheres of commitment). https://link.springer.com/article/10.1023/A:1008319631231
- Yolum and Singh, "Flexible protocol specification and execution: applying event calculus planning using commitments", AAMAS 2002, pp. 527-534. https://dl.acm.org/doi/10.1145/544862.544867 . Also "Reasoning about Commitments in the Event Calculus", *Annals of Math and AI* (2004). https://link.springer.com/article/10.1023/B:AMAI.0000034528.55456.d9
- Chesani, Mello, Montali, Torroni:
  - "Commitment Tracking via the Reactive Event Calculus", IJCAI 2009
  - "Representing and monitoring social commitments using the event calculus", *JAAMAS* 2013. https://link.springer.com/article/10.1007/s10458-012-9202-0
  - REC general paper: "Reactive Event Calculus for Monitoring Global Computing Applications". https://link.springer.com/chapter/10.1007/978-3-642-29414-3_8
- Artikis, Sergot, Pitt, "Specifying norm-governed computational societies", *ACM TOCL* 10(1), 2009 (EC and C+; power, permission, obligation). https://dl.acm.org/doi/10.1145/1459010.1459011
- Artikis, Sergot, Paliouras, "An Event Calculus for Event Recognition" (RTEC), *IEEE TKDE* 27(4):895-908, 2015 (Prolog, runtime). https://www.semanticscholar.org/paper/19a7a03a679edc06d03bcaf82af3801e0c010a9d

Takeaway: EC's `initiates`/`terminates`/`holds_at` plus inertia *is* the right semantic core for "events change which commitments hold". Commitment lifecycles (create, discharge, cancel, release, delegate, assign) have been axiomatised in EC for over 20 years. EC is a *theory*, not a tool: you host it in Prolog (REC/RTEC), in ASP (clingo, which gives search and counterexamples), or in Alloy (as frame conditions).

---

## 6. Lean 4, Rego/OPA, Cedar
- **Lean 4**: install with `curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y` (URL returns 200 [RUN]).
  - Strengths: dependent types, real proofs, and `decide` on finite domains. The `plausible` library (successor of slim_check) does random property testing that finds counterexamples [WEB: https://deepwiki.com/leanprover-community/plausible].
  - It has no built-in exhaustive bounded model finder like Alloy's.
  - Precedent for "spec in Lean, production in Rust": Cedar.
  - Cost: steep for an ontology still being discovered. Proofs fight you while definitions churn. Better as phase 2.
- **Cedar** (AWS):
  - The Rust crate `cedar-policy` 4.13.0 (2026-09-15) is the production engine [RUN crates.io].
  - The `cedar-spec` repo (HEAD 2026-09-28) now has `cedar-lean`, `cedar-lean-cli`, `cedar-lean-ffi` and `cedar-drt` (differential random testing of Rust against Lean), and **no Dafny directory** [RUN]. The earlier Dafny model was superseded by Lean.
  - Lean proofs cover: forbid overrides permit, default deny, typechecker soundness, and slicing. The symbolic compiler is proved sound and complete [WEB: https://github.com/cedar-policy/cedar-spec/blob/main/cedar-lean/README.md].
  - `cedar-policy-symcc` 0.7.0 (Rust) compiles policies to SMT-LIB (needs **cvc5 1.3.1**). It checks never-errors, always-allow/deny, subsumption, equivalence and disjointness, **with counterexamples** (a synthesized request plus entity store) [WEB: https://github.com/cedar-policy/cedar/tree/main/cedar-policy-symcc].
  - Announced as "Cedar Analysis", 2025-06-16 [WEB: https://aws.amazon.com/blogs/opensource/introducing-cedar-analysis-open-source-tools-for-verifying-authorization-policies/]. Paper: "Cedar: A New Language for Expressive, Fast, Safe, and Analyzable Authorization", OOPSLA 2024 [WEB: https://dl.acm.org/doi/full/10.1145/3649835].
  - Fit: excellent for the *delegation-scope* sub-problem (can principal P, acting for Q, do action A on resource R?), and the tooling is Rust-native. It is stateless (no time or events) and not for commitments. Use it as the target representation for scope, not for the ontology.
- **Rego/OPA**: Datalog-inspired and Go-native. `regorus` 0.12.0 (Microsoft) is a Rust Rego interpreter [RUN crates.io]. It has no symbolic or counterexample analysis comparable to Cedar's [UNVERIFIED absence, but none found]. Lower fit than Cedar.
- `oso`/`polar-core` 0.27.3: last updated 2024-01; the open-source library is effectively legacy [RUN crates.io; status inference].

---

## Comparison table
Scale: ++ excellent, + good, o workable, - weak, -- absent.

| | Typed relations | Time / events | Defeasibility | Counterexample search | Conversion to Rust | Readability | Tool maturity (2026) |
|---|---|---|---|---|---|---|---|
| **Alloy 6.2** | ++ (sigs, multiplicities, join, closure) | ++ (var, LTL past and future, lasso traces) | - (encoded as frame conditions) | ++ (bounded, exhaustive, symmetry breaking; CLI plus JSON) | o (manual; clean struct/set mapping) | ++ | + (active; CLI verified; single maintainer-ish; 6.3 pending) |
| **TLA+ TLC/Apalache/Quint** | o (sets and functions; Apalache/Quint typed) | ++ (actions, fairness, liveness) | -- | + (TLC explicit over given constants; Apalache SMT bounded) | o (Quint is closest to code) | + (Quint) / o (TLA+) | ++ (TLC), + (Apalache, Quint) |
| **Datalog (ascent/crepe/Soufflé)** | + (Rust types in ascent/crepe) | o (time as a column; per-step fold) | + (stratified negation = defaults) | -- (least model only; pair with proptest) | ++ (ascent/crepe *are* Rust) | + | + ascent, o crepe, -- DDlog (archived) |
| **ASP clingo (+ EC)** | - (untyped terms; domain predicates; clorm helps in Python) | + (EC by hand, or telingo) | ++ (NAF, weak constraints, elaboration tolerant) | + (choice rules plus constraints; no symmetry breaking; grounding blowup) | o (stratified subset ports to ascent; clingo-rs stale) | o | ++ (clingo 5.8.2), - (clingo-rs, InstAL, telingo stale) |
| **Event calculus (theory)** | n/a | ++ | + (inertia is a default) | depends on host | depends on host | + | theory, not a tool |
| **Lean 4** | ++ (dependent types) | o (you build it) | o (you build it) | o (plausible: random; decide: finite) | o (manual; the Cedar pattern is differential testing) | o | ++ |
| **Cedar (+ SymCC)** | + (entity schema) | -- (stateless) | o (forbid overrides permit; default deny) | ++ (SMT counterexamples, verified) | ++ (Rust-native) | ++ | ++ |
| **Rego/OPA (regorus)** | o | -- | + (default rules) | -- | + (regorus) | o | ++ (OPA), + (regorus) |

---

## Recommendation

**Spec of record: Alloy 6.2**, using an event-calculus *style*:
- sigs for the primitives: Party, Agent, Substrate, Commitment, Event, and so on;
- a `var` relation for the holding commitments;
- one predicate per event kind that states its initiates, terminates and frame explicitly;
- invariants as `check ... for N but K steps expect 0`.

Run headless with `java -jar alloy.jar exec -f -o out -t json spec.als`.

Reasons:
1. It is the only tool that is natively *relational plus typed plus temporal plus exhaustive bounded counterexample search*, which is exactly what "a dozen primitives, precise relations, show claims wrong" asks for.
2. The spec reads like the ontology.
3. The CLI is official and verified, with JSON output suitable for CI.
4. Relations map directly to Rust `struct`s and `BTreeSet<(A,B)>`.

**Runtime and defeasibility layer: the same rules as Datalog in `ascent`**, evaluated per step (`state_{t+1} = rules(state_t, event_t)`). Default rules become stratified negation (`survives(c) <-- commitment(c,_), !dropped(c)`). Cross-check the Rust implementation against Alloy traces: export Alloy counterexample and instance JSON as test fixtures, replay them through the ascent fold, and assert the same `holds` sets. This is Cedar's Lean/Rust differential-testing pattern at low cost.

**If defeasibility turns out to be central** (many layered "unless" exceptions, priorities among norms), switch the spec of record to **clingo plus event calculus**:
- It keeps counterexample search through choice rules and `:- not bad`, verified here.
- Its stratified-per-step fragment ports almost verbatim to ascent.
- InstAL's vocabulary (obl/3, pow, perm, generates) is a ready-made normative design template.

**Delegation scope**: express it as Cedar policies (Rust-native, SMT counterexamples, Lean-verified) rather than inventing a scope logic. Keep it outside the commitment ontology and link the two through a `scope` relation.

### Where this recommendation is weak (honest flags)
- **Alloy defeasibility is simulated.** "Survives unless anchored" is exact within the model, but each new exception edits a frame condition. If the ontology's core claims are about default reasoning, ASP is the better formal home, and this recommendation flips.
- **Two languages means two semantics to keep in sync.** The Alloy-to-ascent correspondence is by hand plus differential tests, not by construction. No Alloy-to-Rust code generator exists.
- **Bounded only.** Alloy (in this jar), clingo with horizon n and Apalache all give "no counterexample up to scope K", never a proof. For proofs you need Lean, later.
- **Alloy exits 0 on counterexamples** unless you use `expect`. There is also a small option-wiring bug in `exec`. Development is concentrated in a small team, and 6.3 has been "begun" but not released.
- **Scaling.** Alloy scopes beyond about 6-8 atoms per sig with 10+ steps can get slow. Clingo grounding grows as |time| x |fluents| x |events|, and it has no symmetry breaking.
- **Prior art for commitments specifically in Alloy is thin.** I found none. The commitment formalisation lineage (Singh; Yolum and Singh; Chesani, Montali, Torroni; Artikis and Sergot) is event calculus in Prolog or ASP, so the ASP route has more directly reusable literature.
- **ascent needs predicate-level stratification**, so EC programs must be restructured into a per-step fold. That is fine architecturally, but it is not a verbatim copy from ASP.

---

## Install commands (Linux, Java 21, Python 3.11)
```bash
# Alloy 6.2.0 (verified: 200 OK, runs on Java 21, `exec` works)
mkdir -p ~/tools
curl -fsSL -o ~/tools/alloy.jar \
  https://github.com/AlloyTools/org.alloytools.alloy/releases/download/v6.2.0/org.alloytools.alloy.dist.jar
java -jar ~/tools/alloy.jar version                 # -> 6.2.0
java -jar ~/tools/alloy.jar exec -f -o out -t json spec.als ; echo $?   # non-zero only on `expect` mismatch

# clingo 5.8.2 (verified; note: no `clingo` console script, use python -m)
python3.11 -m pip install clingo==5.8.2 clorm
python3.11 -m clingo spec.lp -V0 0               # --outf=2 for JSON

# TLA+ TLC (v1.7.4 = latest non-prerelease; verified)
curl -fsSL -o ~/tools/tla2tools.jar https://github.com/tlaplus/tlaplus/releases/download/v1.7.4/tla2tools.jar
java -cp ~/tools/tla2tools.jar tlc2.TLC -deadlock Spec      # needs Spec.cfg

# Apalache v0.62.2 (tarball layout verified; running not tested)
curl -fsSL https://github.com/apalache-mc/apalache/releases/download/v0.62.2/apalache.tgz | tar xz -C ~/tools
~/tools/apalache/bin/apalache-mc check --length=10 Spec.tla

# Quint (npm; version verified, not run)
npm i -g @informalsystems/quint@0.33.0

# Rust Datalog (verified to build and run with rustc 1.94)
cargo add ascent@0.8.1 crepe@0.2.0

# Souffle 2.5 on Ubuntu 24.04 (deb URL verified; not installed)
curl -fsSLO https://github.com/souffle-lang/souffle/releases/download/2.5/x86_64-ubuntu-2404-souffle-2.5-Linux.deb
sudo apt-get install -y ./x86_64-ubuntu-2404-souffle-2.5-Linux.deb

# Lean 4 (script URL verified; not run)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y

# Cedar (crate versions verified; not installed); SymCC additionally needs cvc5 1.3.1
cargo install cedar-policy-cli
```
