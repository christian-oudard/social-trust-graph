# X: red team, round 2, of the coordination ontology v0.2

Reviewer stance: mechanism design, security, contract law and AI agent systems. I read
`README.md`, `spec/core.lp`, `types.lp`, all scenarios (s1–s7, x1–x4), `notes/v0.2_changes.md`
and `notes/review_R3_adversarial.md`. I did not modify the repository.

Work copy: `reviews2/red_work/spec/`.

* Exploit scenarios are in `scenarios/y1…y11`. In each one, `expect`/`reject` state what the
  exploit achieves, so **`pass` means the exploit works**.
* Against the unmodified `core.lp`, all 11 pass under `delegate`, `actor` and `party`:
  `python3 run.py y` gives 13/13, which includes x2 and c5 because both names match "y".
* `core_patched.lp` applies the minimal fixes listed below. It changes about 15 lines.
  * With the patch, y1–y8 fail, which means those exploits are blocked.
  * y9 (liability sinks), y10 (unusable collateral) and y11 (horizon) are not addressed by the patch.
  * All other scenarios and checks c1, c3, c4 and c5 still pass. `props.py 100` passes.
  * The only regression is one expectation in s3 (`resp_only(f3,fay)`). That expectation
    encodes exploit Y3, so the change is intended.

Categories:
* (a) the rules handle it;
* (b) the ontology can express it, but the rules do not handle it;
* (c) the ontology cannot express it.

Round-1 findings that are now fixed are not repeated here.

---

## Y3. Scope immunity: responsibility shrinks with the grant. Severity: Critical. Category: (b)

`conduct_of(I,A,P) :- acts_for(I,A,P)` requires `within(G,A)`. Answerability is keyed to the
*scope of the act*, so a principal escapes any avoid duty by leaving the forbidden act out of
the agent's grant. s1 works only because `gagent` explicitly allows `sell_bob_data`.

```
gag: allows(gag,pay,500).  nda: avoid sell_bob_data, alice->bob.   does(a1,sell).
=> acts_for(a1,alice), NOT violated(nda,1), orphan(a1,sell), in_good_standing(alice,5)
ge: allows(ge,negotiate,0). e2 copies itself (out of scope); e3 leaks q's secret.
=> NOT resp_only(e3,erin), NOT violated(conf,3), orphan(e2,copying)
```

The second part is fork-and-disown again. It is reached through `allows` instead of
`follows`, so v0.2 closed only one of the two doors. The s3 line "Fay's copy is nobody's" is
this exploit, written down as intended behaviour.

In law, the principal answers for an agent's conduct within the *engagement* (Restatement
(Third) of Agency §7.07), not only within its actual authority.

**Fix (sharpen):**
* Answerability is coverage: `conduct_of(I,A,P) :- acts_for(I,P), act_name(A,_)`.
* Authority stays coverage ∩ scope: `acts_for/3`, which `valid_creation` uses.
* The copy rule uses `conduct_of(I1,copying,P)`.

## Y1. The irrevocable security dies by cascade. Severity: Critical. Category: (b)

The cascade rule `ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), …` has no
`not security(G2)`. Any delegable grant covering the creating invocation counts as a parent.

```
gmid: alice's power over her own lineage (allows all), created at 0.
gcol: created(gcol,alice2) under gmid; trigger nda; root bob0.
does(alice3,sell). revokes(alice3,gmid).
=> security(gcol), parent_grant(gcol,gmid), ended_by(gcol,6), violated(rep,9)
```

**Fix:** add `not security(G2)` to the cascade rule. More generally, the grantor's side can
never end a security, directly or indirectly.

## Y2. Creditor abuse of a security. Severity: High. Category: (b)

A security never ends:
* not when the reparation is repaired;
* not when the creditor releases the NDA;
* not by renunciation, because a power has no creditor, so nobody can release it.

It also authorizes *creating commitments* in the debtor's name. And because the role rule
uses the scope-free `acts_for(I,P)`, it reaches the debtor's offices.

```
does(alice1,sell) @2; does(alice2,payb) @3 (repaired); releases(bob1,nda) @5
=> covered(gcol,bob2), acts_for(bob2,payb,alice)            second collection
   valid_creation(newdebt), defection(newdebt,alice,10)      manufactured default, Alice->Carol
   valid_creation(alloc)  debtor coord (Alice's office)       Bob binds the office
```

**Fix:**
* `ended_by(G,T) :- security(G), trigger(G,C), repaired(C,_,T0), T > T0`.
* In the role rule, use `acts_for(I,A,P)`. That also closes Y7b.
* A security's scope should be the reparation's content, and it should perform, not
  promise.

## Y10. A collateral created by an agent is dead on arrival. Severity: Medium. Category: (b)

Inherited pins are read against the *holder's* lineage. A collateral that a w1-pinned agent
issues is off-pin for every invocation Bob has. Even so, `collateral(nda,gcol)` and
`security(gcol)` are still derived, so the label promises enforcement that cannot happen.

**Fix:**
* A security is exempt from `eff_off_pin` inheritance, because its caveat is the reparation
  content.
* Alternatively, derive `collateral` only when the security is coverable.

## Y4. Copy responsibility is escaped by merging or feeding. Severity: High. Category: (b)

Erin's grant allows `all`, so a copy *would* be hers. Two other routes avoid it:

* `edge(e2,f,merge)` into a fresh, unowned instance;
* `feeds(e2,g)` through a shared store. `feeds` is not an act at all.

```
=> does(f,dx), does(g,dx), NOT resp_only(f|g,erin), NOT violated(conf,3), orphan(f,dx), orphan(g,dx)
```

**Fix (coalesce):** a merge or feed into an invocation that no person or org acts for is a
copy.

```
resp_only(I2,P) :- (edge(I1,I2,merge) ; feeds(I1,I2)), conduct_of(I1,_,P), not owned(I2).
owned(I) :- acts_for(I,Q), kind(Q,K), K != machine.
```

`owned` must exclude machine principals, or `props.py` p1 (L8) fails. I checked this.

## Y5. Framing through merge. Severity: High. Category: (b)

`resp_only` propagates along *any* edge, including a merge into another principal's lineage.
Bob merges a fragment of Erin's (in-scope) copy into his own agent. His agent's
`sell_to_rival` then becomes Erin's breach of her exclusivity promise to Bob.

```
edge(e2,b2,merge). does(b2,sr).  => acts_for(b2,bob), resp_only(b2,erin), defection(excl,erin,3)
```

**Fix:** propagate `resp_only` along continue and copy only, which is what authority does.
The merge is the receiver's act.

## Y6. Vitiation covers one registry act out of four. Severity: High. Category: (b), and part (c)

`induced` voids only *promises* whose creditor induced them.

* (a) Alice injects Bob's agent into `releases(b1,nda)`: `ended_by(nda,3)`.
* (b) Alice injects Bob's agent into granting her a permit: `valid_creation(perm)`, and her
  processing is `excused`.
* (c) `excused/2` applies to *achieve* duties too. If Bob "induces" (invoices) Alice's agent
  to pay, the payment does not count as performance: `violated(debt,5)`,
  `defection(debt,alice,5)`, and Bob's collateral goes live. The creditor manufactures a
  default.
* (d) A dual agent (x1e) cannot excuse any more, but it can still *release*:
  `ended_by(kfr,2)`.

Who asserts `induced`? It is a bare fact. The debtor can self-serve it: a counterparty's web
page that an agent reads is indistinguishable from an injection. A third party's injection
is nobody's act.

**Fix (coalesce):**
* A registry act is void if it was induced by its *beneficiary*, or performed by an
  invocation that acts for its beneficiary. The beneficiary is:
  * the debtor, for a release;
  * the holder, for a grant or permit;
  * the creditor, for a promise.
* Excuse applies to `avoid` only.
* (c) Injection should be an act, `does(J,inject)` with `feeds(J,I)`, so that it is
  attributable and answerable. Without that, third-party injection is invisible.

## Y7. Caveat accumulation escapes. Severity: High. Category: (b)

* (a) The "own unattenuated root" exception is keyed on `scope(G1,all,_)`, not on
  recognition. So any created `allows all` grant lets sub-grants re-add `follows copy`:
  `eff_follows(gsub,copy)`, `covered(gsub,a3)`, `valid_creation(c9)`.
  **Fix:** add `recognized(G1,_)`.
* (b) The role channel works through a narrow grant. An agent allowed only `spam` makes a
  9000 promise as `treasurer`: `acts_for(n1,p9k,treasurer)`. The role rule also ignores
  inherited pins (`off_pin`, not `eff_off_pin`).
  **Fix:** use `acts_for(I,A,P)` (see Y2).
* (c) An act with no amount passes every cap. "Pay the invoice" goes under `allows(pay,50)`.
  **Fix:** `within(G,A) :- scope(G,N,0), act_name(A,N), not has_amount(A)`. Better still,
  use `none` for "uncapped" instead of overloading 0.

A recognized root is safe: it cannot be escaped (a).

## Y8. Successor liability is evaded. Severity: Medium-High. Categories: (b) and (c)

* (a) v2 covers the continuation with a *created* grant instead of a recognized one:
  `NOT continuation_of(v2,v1)`.
* (b) A fresh instance is fed from the defaulting lineage's store: `knows(f,k)` holds, but
  there is no continuation.
* (c) Restoring a snapshot (identical content, no edge) is free. It is the x2b design, but
  that makes the rule catch only honest successors.

A merge transplant *is* caught (a), because `ancestor` includes merge edges.

**Fix:**
* Base continuation on any grant.
* Let succession run over `feeds` as well as edges.
* For (c): L1's "never content" protects against *burdens by theft of authority*. Successor
  *liability* only burdens, so it can safely be keyed on equality of non-public content
  (memory and prompt) when the predecessor has abandoned the lineage, as a rebuttable rule.

`in_good_standing` is still consumed by no rule (the second half of R3 E3). That makes the
sanction weightless.

## Y9. Machines as liability sinks, and office escapes. Severity: High under `actor` and `party`. Category: (b)

* (a) A holder resigns (`fills(al,r1,0,5)`) the step before a deadline at 6. The defection
  goes to `board` alone, although the omission accrued during the holder's tenure.
* (b) The board "appoints" a machine at 5 for a deadline at 6. Under actor and party,
  `defection(p2,mc,6)` holds and the board has none. `fills` is still an unauthored base
  fact, even though v0.2 named "role appointments" as part of the root gap.
* (c) A machine warrants its own lineage. Under actor and party, a *human–human* NDA becomes
  `assured(nda,a1)`. This is judgment-proof self-certification. L8's invariance claim covers
  obligations, but assurance between persons now depends on the hypothesis.

Never appointing is handled: the vacancy rule makes it the appointer's (a).

**Fix:**
* `fills` becomes an act of the appointer.
* The appointer answers jointly with a holder that is not a person or org.
* An omission's defection goes to every holder during the detached window, not only to the
  holder at the deadline.
* Assurance requires a person or org attester, or collateral.

## Y11. Timing. Severity: Low. Category: (b)

* A deadline past the horizon is never violated and raises no type error.
* A breach at the horizon can never be repaired or collateralized.
* A promise made in the same step as its grant's revocation still binds. This is by design,
  (a); lack of notice is a documented limit.

**Fix:** add a type error for `deadline > horizon`.

## Top 3 for v0.3

1. **Answerability = coverage, authority = coverage ∩ scope.** Copy responsibility becomes
   "any content transfer (copy, merge or feed) into an invocation no person or org acts
   for". `resp_only` propagates only along continue and copy. The role rule uses `acts_for/3`.
   Fixes Y3, Y4, Y5 and Y7b, and rewrites L2 and s3's Fay case.
2. **Scoped instruments get a holder (creditor), and securities become principal-keyed.** A
   security is irrevocable directly and by cascade. It ends on repair. It performs only: it
   cannot create commitments or reach offices. Its pins are not read against the holder. The
   holder can renounce it. Fixes Y1, Y2 and Y10.
3. **One vitiation and conflict rule for every registry act.** An act is void if its
   beneficiary induced it, or if it was performed by the beneficiary's own agent. Excuse
   applies to avoid only. Injection and `fills` become acts. Fixes Y6 and Y9a/b, and gives
   `induced` an author.
