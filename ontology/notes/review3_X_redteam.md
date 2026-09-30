# X3: red team, round 3, of the coordination ontology v0.3

Stance: mechanism design, security, contract law, AI agent systems. I read `README.md`,
`spec/core.lp`, `types.lp`, `run.py`, all scenarios (s1–s7, x1–x6), `notes/v0.3_changes.md`
and `notes/review2_X_redteam.md`. Round-2 findings that v0.3 fixed are not repeated. I did not
modify the repository.

Work copy: `reviews3/red_work/spec/`.

* The exploit scenarios are `scenarios/z1…z11`. In them, `expect`/`reject` state what the exploit
  achieves, so **`pass` means the exploit works**. `zc_control` is a control and `zf_fix_demo` is
  a demo of the fix.
* Against the committed v0.3 core (f44b42b, copied at the start), `python3 run.py z` passes
  every z scenario under delegate, actor and party.
* The repository working tree changed during the review, with uncommitted edits: securities end
  with the obligation they secure, and `ultra_vires` is renamed `unauthorized`. I re-ran z1–z11
  against that in-flight core, with a one-line alias for the rename. **Every exploit still
  works.**
* `core_patched.lp` and `types_patched.lp` hold the minimal fixes below, about 25 lines.
  * The z scenarios they target flip. The residuals are listed per finding.
  * s1–s3, s5–s7 and x1–x4 still pass, as do c1, c4 and c5. `props.py 60` passes.
  * c3 passes once its independent re-derivation of vitiation uses the new rule
    (`c3_patched.lp.txt`).
  * There are three intended regressions, each noted below: s4 `orphan(v1a,spam)`, x5(c) and
    x6(b).

Categories:
* (a) handled;
* (b) the ontology can express it, but the rules do not handle it;
* (c) the ontology cannot express it.

---

## Bet 1: answerability = coverage

### Z2. Griefing by feed, and creditor-run breaches. Critical. (b)

`spawn(I1,I2) :- feeds(I1,I2), not owned(I2)`. "Unowned" is a property that the *recipient's
operator* controls: they just don't register a power. Anyone who reads your agent's output with
an unregistered instance makes you answer for everything that instance does, and for its
continuations, forever.

```
feeds(a1,u1). does(u1,spam)                      -> resp_only(u1,alice), violated(nosp,2)   [nosp owed to Mallory]
Bob's unregistered helper: feeds(a1,h1). does(h1,sell_bob_data)
                                                 -> violated(nda,3), defection(nda,alice,3),
                                                    covered(gcol,bob1), fulfilled(rep,6)   [Bob collects]
edge(u1,u2,continue) at t11                      -> resp_only(u2,alice), violated(nosp,11)
```

The creditor-induced excuse does not apply, because running your own instance is not being
"induced" by yourself. The same rule makes every message to a counterparty's *unregistered*
agent a transfer of unlimited liability. It is also the exfiltration channel: a thief who loads
stolen memory is "fed".

**Fix (coalesce with `changed_by`):**
* Feeds carry knowledge only. That restores README §3's own slogan.
* An unowned invocation is answered for by its **maker**. `changed_by(I,J)` on a root invocation
  means "launched by J"; the type rule 58 is dropped.

  ```
  spawn(J,I2) :- changed_by(I2,J), not edge(_,I2,_), not owned(I2).
  ```
* Y4 laundering (x5c) is still caught when the record says who launched `fresh`. `zf` shows
  both halves: the maker answers, and a merely fed instance is orphan.
* x5(c) and x6(b) regress intentionally, because they carry no launch record.
* Residual: whether a feed was *pushed* by the source is still unmodelled.

### Z1. Vendor-operated lineage: a narrow grant makes you answer for the vendor's other customers. High. (b)

Alice's `book_hotel`-only grant is rooted at a turn of the vendor's hosted agent lineage. The
lineage then serves Carol:

```
acts_for(v3,alice), acts_for(v3,spam,carol), violated(nosp,4), defection(nosp,alice,4),
imputed(alice,csecret), not in_good_standing(alice,5)
```

Restatement §7.07 limits vicarious liability to the *engagement*. An agent's work for another
principal is not a frolic of yours. v0.3 overshoots.

**Fix (sharpen conduct_of):** an act within some person's or org's scope is theirs, not a
co-coverer's:

```
inscope_other(I,A,P) :- answers_for(I,P), acts_for(I,A,Q), Q!=P, kind(Q,K), K!=machine, not acts_for(I,A,P).
conduct_of(I,A,P) :- answers_for(I,P), does(I,A), not inscope_other(I,A,P).
```

* Out-of-everyone's-scope conduct stays joint, so Y3 does not reopen.
* **Residual:** `imputed` still gives Alice Carol's secret. Imputation should be limited to
  knowledge acquired while the invocation was engaged for P.

### Z3. Scope immunity reopens through pins, `until` and revocation. Critical. (b)

`covered` requires `not eff_off_pin` and `detached`, so the scope fields other than `allows`
still end *answerability*:

```
pin(gp,memory,m1); the agent updates memory; does(p2,sell)     -> orphan(p2,sell), no violation
revokes(alice1,gr); the agent keeps running; does(r2,spam)     -> orphan(r2,spam)
until(gu,log_off); does(t1,log_off); does(t2,spam)             -> orphan(t2,spam)
```

A pin on `context` makes every agent answer-free after its first step. "Revoke and run" is the
classic dangerous-instrumentality dodge. L3 says burdens are sticky, but answerability is a
burden and is not sticky.

**Fix:** pins, `until` and revocation limit **authority** only. Answerability is sticky from
detachment on:

```
engaged(G,I) :- in_lineage(G,I), grant(G), not security(G), in_force(G), at(I,T), detached(G,T0), T0<=T.
answers_for(I,P) :- engaged(G,I), debtor(G,P).
```

s4's `orphan(v1a,spam)` flips, on purpose: pin laundering no longer orphans conduct.

### Z4. Framing and theft through copy edges. High. (b)

Y5 was fixed for feeds, but copies still spawn into *owned* lineages. The copy is also always
the source's act (`does(I1,copying)`), with no `copied_by`.

```
edge(a1,bc1,copy), acts_for(bc1,bob), does(bc1,sell_bob_data) -> resp_only(bc1,alice), defection(nda,alice,2)
thief: edge(a1,th,copy)                                       -> resp_only(th,alice), does(a1,copying)
```

**Fix:**
* `spawn(J,I2) :- edge(_,I2,copy), changer(J,I2), not owned(I2)`.
* `does(J,copying)` via `changer`, which is `changed_by`, so an external copier is the copier.
* Residual: with no maker recorded, the default still blames the source (see Z6b).

### Perverse incentive: "never grant". (a) once patched; (c) at the record

v0.3 plus Z2: registering a power costs unlimited answerability, and not registering costs the
same (fed-unowned).

With the patch, *launching* is what makes you answer, whether you registered or not. So
registering is neutral and the incentive disappears. What remains is an unrecorded launch,
which is the "record is trusted" limit.

---

## Bet 2: no warranty of authority, because scope is public

### Z8a. Pin-and-swap is a free option, and "public" scope is unobservable. Critical. (b)

A grant pinned to `opaque(v1)`, the vendor's API weights. The vendor swaps them
(`changed_by`). Carol cannot observe opaque weights.

```
unauthorized(sale) [ultra_vires], not answerer(sale,alice), orphan(a2,spam), not violated(nosp,2)
```

Alice and the vendor can collude: "reveal" the swap when a deal sours, and release the vendor's
no-swap promise. Carol has no one to sue.

**Fix:**
* Minimal: a type error for a power pinned to opaque content (`types_patched.lp` #64).
* General: `observable(G,Q)`. An off-scope promise whose defect the creditor could not observe
  binds the grantor, as apparent authority, and the grantor recovers from the changer. This is
  the one place a warranty of authority must return.

### Registry lag, private scopes, and humans who cannot read registries. High. (c)

There is no time of notice or observation, no private scope, and no manifestation other than a
grant. README §9 concedes the lag.

Apparent authority in law comes from the principal's manifestation, such as an agent on your
checkout page. That is not expressible.

**Fix:**
* Add `manifests(I,G,Q)`: a principal-side act that makes G's scope *as manifested* the scope
  as against Q.
* Add an explicit notice step `noticed(Q,Act,T)` for revocations to take effect against Q.

---

## Bet 3: securities

### Z7a. Over-collection. High. (b)

The security's scope (`pay_bob` up to 1000) is wider than the reparation (`pay_bob 100`). Bob
pays himself 900 twice. Neither payment is the reparation, so the breach is never repaired and
the security never ends:

```
conduct_of(bob1,p900a,alice), conduct_of(bob2,p900b,alice), covered(gcol,bob2), violated(rep,9)
```

The in-flight change, "ends with the obligation", does not help.

**Fix:** a security performs exactly its reparation's content:

```
secures(...) :- ..., trigger(G,C), reparation(C,R), content(R,A).
```

It then ends on first exercise, because that exercise is the repair.

### Z7b. Double pledge. Medium. (b)

Alice pledges an exclusive car to Bob and sells it to Carol. `overcommitted` sees only achieve
commitments.

**Fix:** with the scope fix above, a security is a conditional achieve, so extend
`overcommitted` to secured reparations.

### Z7c. A creditor that sits on the security. Low. (b)

Alice defaults, `defection(rep,alice,9)`, although Bob could have cured the default at will.
Mitigation is not modelled.

### Z11. `until` on a security. Medium. (b)

`until(gcol,rewriting)`. The holder's routine memory update ends it, `ended_by(gcol,2)`, but
`security(gcol)` is still derived. The "irrevocable" label misleads.

**Fix:** a type error for `until` on a security, since L3 already lists how a security ends.

### Security over what the debtor does not control. Medium. (c)

There are no resources or custody of assets. A security needs the *asset holder* to honour the
registry. That is a third party who can drift, which is L9's own objection to bonds.

---

## Bet 4: vitiation

### Z5a and Z10. Root squatting defeats vitiation. Critical. (b)

`root(G,I)` is unconstrained. Alice files a spam-only power rooted at Bob's agent lineage, or at
Bob's *own body*. Then `acts_for(bob1,alice)` holds and her fraud no longer vitiates:

```
Z5a:  valid_creation(perm), valid_creation(gf), defection(gf,bob,9)
Z10:  induced(bob1,alice), acts_for(bob1,alice), valid_creation(hs), violated(hs,8)
      control (no squat): vitiated, unauthorized
```

**Fix:**
* Steering is foreign unless it comes from *every* principal the invocation acts for:
  `foreign_steer(I,Q) :- steer(I,Q), acts_for(I,P), P != Q`.
* Separately, constrain roots: a non-security grant must root in the creator's own lineage,
  or be accepted by the root's custodian.

### Z5b. Sock puppets and third-party sabotage. High. (b)

`induced(a2,mallory)`, where Mallory is Alice's puppet or a real web-page injector. Alice's
honest sale to Carol becomes `unauthorized`. Anyone can void anyone's deals.

**Fix (round-2 Y6 again):** vitiation voids only the registry acts that **benefit the
steerer**:
* the creditor, for a promise;
* the holder, for a security or permit;
* the debtor, for a release;
* the appointee, for an appointment.

`vitiated_for/rel/app` in the patch.

### Z5c. Every negotiated release is voidable. High. (b) and (c)

Bob's agent reads Alice's request and releases her. Reading a counterparty is steering by it,
so `induced(b3,alice)` blocks the release. The control run without the label ends the NDA.

`induced` is a bare fact that the adjudicator, or the self-serving party, asserts. The core
cannot tell persuasion from injection. **Not fixed by the patch.**

**Fix:** derive `induced` only from an attributable act, `does(J,deceive|coerce|inject)` with
`feeds(J,I)`. It is then conduct, answerable and falsifiable. Plain feeds never vitiate.

### Z6c and Z8c. Content change is steering, but is not vitiation. High. (b)

* The vendor retrains Alice's agent, which then releases the vendor's data promise:
  `ended_by(vdata,7)`. The swap itself is caught, `violated(noswap,5)`, but its fruit stands.
* Under party, Alice edits the memory of a machine creditor and it releases her:
  `ended_by(owem,5)`.

**Fix (coalesce):** `changed_by` by Q's agent counts as steering by Q, along the continuation.
This is `csteer` in the patch, and both exploits flip.

---

## Bet 5: citation, `until`, appointments, `changed_by`, succession

* **`under`: (a).** The creator can choose which parent's cascade applies, but all candidates
  share a debtor. Low.
* **`until` on grants: (b).** See Z3 and Z11.
* **Z6a, vendor swap through unregistered automation: High (b).** `does(opu,swapping)` is
  orphan, so `noswap` is never violated. Fixed by the maker rule: `changed_by(opu,op0)` makes it
  the vendor's (`zf`).
* **Z6b, no recorded changer: High (b).** The swap defaults to the parent, which is Alice's
  agent: `violated(stable,2)`, `defection(stable,alice,2)`. The default blames the customer.
  **Fix:** a type error when `weights`, or any opaque slot, changes without `changed_by`,
  because API weights never self-modify.
* **Z9, succession: Medium (b).** `custodian` needs a recognized grant, but ordinary agents run
  under created grants. The defaulting org's agent moves to a new org: no `continuation_of`,
  and `in_good_standing(nco,6)`. This is a declared limit, but it means the rule almost never
  fires. **Fix:** key custodian on any in-force grant (round-2 Y8a).
* **Result obligations: (c).** "The vendor keeps your agent on w1" is a result, not an act. Only
  "the vendor does not do the swap act" is expressible. Z6a and Z6b show why this matters.

---

## Bet 6: capacity bundles as liability sinks

* **Z8b (actor): High (b).** A machine that can owe but not claim cannot hold assets. Yet
  `answerer(mdebt,m)` holds, and `not unanswerable` and `not unanswered_breach(mdebt,6)`: the
  obligation is reported as answered. So actor is a structural judgment-proof sink.
  **Fix:** `answerer` requires `capacity(P,claim)` or `secured(C)`.
* **Z10 appointments (actor): High (b), round-2 Y9b still open.** The board appoints `mc` the
  step before a deadline: `defection(duty,mc,9)`, not the board, and `in_good_standing(board,10)`.
  **Fix:** an appointer is jointly in defection when the holder cannot claim.
* **Z8d (actor): Medium (b), round-2 Y9c still open.** A machine attester makes a
  person-to-person NDA `assured`, which depends on the hypothesis. L8 is silent on assurance.
  **Fix:** an attester needs claim capacity, or collateral.
* **Z8c (party): (b), fixed by `csteer`.** A machine creditor releases whoever edits its
  memory.

---

## Top 3 for v0.4

1. **Answerability = sticky engagement, and makers answer for the unowned.**
   * Pins, `until` and revocation limit authority, not answerability (Z3).
   * An act in another person's or org's scope is theirs (Z1).
   * Feeds carry knowledge only. An unowned invocation, launched or copied, is its *maker's*,
     through one generalized `changed_by`. This fixes Z2, Z4 and Z6a.
   * Require a maker for weight changes and opaque changes (Z6b).
   * About 10 lines; they coalesce spawn-by-feed into `changed_by`.
2. **Beneficiary-keyed vitiation with an attributable inducement.**
   * Void only acts that benefit the steerer (Z5b).
   * Foreign unless from all principals (Z5a, Z10).
   * A content change by Q counts as steering by Q (Z6c, Z8c).
   * `induced` is derived from a deceive/inject act, never asserted bare (Z5c).
   * Constrain `root` to the creator's lineage, or to acceptance.
3. **Observable scope, and securities that only perform.**
   * Where a scope defect was unobservable to the creditor (opaque pins, lag, private scope),
     the grantor is bound and recovers from the changer (Z8a, bet 2).
   * A security performs exactly its reparation's content, once. It carries no `until`, and it
     counts toward over-commitment (Z7, Z11).
   * Under actor, answering needs claim capacity or security (Z8b, Z10).
