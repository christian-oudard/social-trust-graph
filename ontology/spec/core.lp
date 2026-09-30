%% core.lp: coordination ontology, executable core.
%%
%% Fragment: stratified Datalog with negation and integer comparison.
%% No choice rules, disjunction, or aggregates, so every rule here maps 1:1 onto a
%% Rust Datalog engine (ascent / crepe). Choice rules appear only in check files.
%%
%% Six sorts. Everything else is a relation between them or derived.
%%   principal(P)    who commitments are attributed to        kind(P, person|org|machine)
%%   role(R)         a position with a charter, filled over time by principals
%%   invocation(I)   one step of execution: which (lineage) + when + what it ran + what it did
%%   substrate(S)    content-addressed configuration: part(S, Slot, Hash)
%%   commitment(C)   directed deontic unit; mode achieve | avoid | power
%%   evidence(E)     attested record (of an invocation) or test (of substrate content)
%%
%% Base relations supplied by a scenario (the adjudicator's accepted facts):
%%   at(I,T) runs(I,S) does(I,A) edge(I1,I2,K)  K in {continue, copy, merge}
%%   learns(I,X)  with(I,Q)  act_name(A,N) act_amount(A,X)
%%   debtor(C,X) creditor(C,Y) mode(C,M) content(C,A) deadline(C,T) trigger(C,C0)
%%   reparation(C,C2)  created(C,I)  founded(C,T)  released(C,T)  revoked(C,T)
%%   root(G,I) follows(G,K) pin(G,Slot,H) allows(G,N,Cap)  fills(P,R,T1,T2)
%%   record(E,I)  test(E,S0,Slot) refrains(E,N) horizon(E,H) issued(E,T)
%%   hyp(machine_party)  (the open question, stated as a switch)

#const horizon = 12.
time(0..horizon).

% ============================================================================
% 1. Substrate and lineage. Change kinds are derived from content, not declared.
% ============================================================================

changed(I1,I2,Slot) :- edge(I1,I2,_), runs(I1,S1), runs(I2,S2),
                       part(S1,Slot,H1), part(S2,Slot,H2), H1 != H2.
swap(I1,I2)    :- changed(I1,I2,weights).
rewrite(I1,I2) :- changed(I1,I2,memory).

ancestor(I1,I2) :- edge(I1,I2,_).
ancestor(I1,I3) :- ancestor(I1,I2), edge(I2,I3,_).
% rollback: an invocation runs content already run by a strict ancestor, after a change
rollback(I) :- runs(I,S), ancestor(I0,I), runs(I0,S), edge(I1,I,_), runs(I1,S1), S1 != S.

% ============================================================================
% 2. Attribution. Identity-for-commitment = coverage by a power commitment (grant).
%    A grant G (mode power) has grantor debtor(G,P), a lineage root, the edge kinds it
%    follows, content pins, and an act scope. Principals' own authority is a founded
%    root grant; there is no other source of attribution.
% ============================================================================

grant(G) :- mode(G,power).
live(C,T) :- founded(C,T0), time(T), T >= T0, not ended_by(C,T).
live(C,T) :- created(C,I), at(I,T0), valid_creation(C), time(T), T > T0, not ended_by(C,T).
ended_by(C,T) :- revoked(C,T0), time(T), T >= T0.
ended_by(C,T) :- released(C,T0), time(T), T >= T0.
% revocation cascades down sub-delegation (a subagent's authority ends with its appointer's)
ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), created(G2,I), at(I,T0), T > T0.

in_lineage(G,I)  :- grant(G), root(G,I).
in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), follows(G,K).
% Pins are the only place substrate content enters deontics. pin(C,Slot,H) restricts the
% range of ANY commitment to invocations whose Slot holds one of the pinned hashes (a
% set of hashes is a pre-declared change envelope). For a grant: which invocations it
% covers. For avoid: whose acts can break it. For achieve: whose acts can perform it.
pin_ok(C,I,Slot) :- pin(C,Slot,H), runs(I,S), part(S,Slot,H).
off_pin(C,I) :- pin(C,Slot,_), invocation(I), not pin_ok(C,I,Slot).

% covered: the invocation runs under G (in its lineage, on pin, G live).
covered(G,I) :- in_lineage(G,I), not off_pin(G,I), at(I,T), live(G,T).
acts_for(I,P) :- covered(G,I), debtor(G,P).

% effective scope, attenuated along sub-delegation (a grant created by an invocation
% that acted under a parent grant can never exceed the parent).
parent_grant(G2,G1) :- grant(G2), created(G2,I), covered(G1,I), debtor(G1,P), debtor(G2,P).
scope(G,N,Cap)  :- allows(G,N,Cap), founded(G,_).
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap <= Cap1.
scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.
% scope name 'all' is the unattenuated authority a principal has over itself
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,all,_).
within(G,A) :- scope(G,N,Cap), act_name(A,N), act_amount(A,X), X <= Cap.
within(G,A) :- scope(G,N,_), act_name(A,N), not has_amount(A).
within(G,A) :- scope(G,all,_), act_name(A,_).
has_amount(A) :- act_amount(A,_).

% One scoped relation is both AUTHORITY (a promise of A by I binds P) and
% RESPONSIBILITY (P answers for I doing A). Custody of a lineage is nothing more than
% holding an unattenuated grant over it; there is no separate 'operator' primitive.
acts_for(I,A,P) :- covered(G,I), debtor(G,P), within(G,A).

% A created commitment is valid iff its content is within the creator's authority for
% its debtor (principal debtor), or the creator acts for the current filler of the
% debtor role. Delegating is itself an act named 'delegate'.
valid_creation(C) :- created(C,I), debtor(C,P), principal(P), content(C,A), acts_for(I,A,P), not grant(C).
valid_creation(C) :- created(C,I), debtor(C,R), role(R), at(I,T), content(C,A),
                     fills(P,R,T1,T2), T1 <= T, T < T2, acts_for(I,A,P).
valid_creation(G) :- grant(G), created(G,I), debtor(G,P), can_delegate(I,P).
can_delegate(I,P) :- covered(G,I), debtor(G,P), scope(G,delegate,_).
can_delegate(I,P) :- covered(G,I), debtor(G,P), scope(G,all,_).
ultra_vires(C) :- created(C,_), not valid_creation(C).

% ============================================================================
% 3. Holding, binding, roles. Commitments live in the registry, not the substrate:
%    no rule below mentions runs/part, so no substrate change can end a commitment.
% ============================================================================

% conditional commitments (Singh's antecedent) detach when their trigger is violated;
% this is how reparations and bonds are represented.
detached(C,T) :- live(C,T), not has_trigger(C).
detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 < T.   % strictly later: time-stratified
has_trigger(C) :- trigger(C,_).

% who is bound by C at T: the principal debtor, or the current filler of a role debtor
bound(C,P,T) :- detached(C,T), debtor(C,P), principal(P).
bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), fills(P,R,T1,T2), T1 <= T, T < T2.
charter(R,C) :- debtor(C,R), role(R).

% ============================================================================
% 4. Conformance. Fork law: an achieve commitment is discharged once, by any invocation
%    the debtor answers for; an avoid commitment is broken by any of them.
% ============================================================================

performs(C,I,T) :- bound(C,P,T), content(C,A), does(I,A), at(I,T), acts_for(I,A,P), not excused(C,I),
                   not off_pin(C,I).
% Permission is not a primitive: the creditor excuses an act by extending its own
% authority to the invocation (a grant from the creditor covering it, in scope).
excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), acts_for(I,A,Q).
fulfilled(C,T)  :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T).
violated(C,T)   :- mode(C,avoid), performs(C,_,T).
violated(C,T)   :- mode(C,achieve), deadline(C,D), detached(C,D), not fulfilled(C,D), T = D + 1, time(T).
violator(C,I)   :- mode(C,avoid), performs(C,I,_).
% two achieve commitments of one principal on one exclusive object cannot both be met
overcommitted(P,C1,C2) :- mode(C1,achieve), mode(C2,achieve), C1 < C2, content(C1,A1), content(C2,A2),
                          act_obj(A1,O), act_obj(A2,O), exclusive(O), bound(C1,P,T), bound(C2,P,T).

% Confidentiality is an avoid commitment over information flow: content "disclose X"
% is performed by any invocation that knows X and interacts with a forbidden party.
knows(I,X)  :- learns(I,X).
knows(I2,X) :- knows(I1,X), edge(I1,I2,_), not scrubbed(I2,X).
first_learned(X,T) :- learns(I,X), at(I,T), not learned_earlier(X,T).
learned_earlier(X,T) :- learns(I,X), at(I,T), learns(I2,X), at(I2,T2), T2 < T.
% content-addressed forgetting: rollback to content first seen before X was learned
seen_at(S,T) :- runs(I,S), at(I,T).
seen_before(S,T) :- seen_at(S,T0), time(T), T0 < T.
scrubbed(I,X) :- runs(I,S), first_learned(X,T), seen_before(S,T).
% attested sanitization: test evidence that content S does not carry X
scrubbed(I,X) :- runs(I,S), clean(_,S,X).
does(I,A) :- act_name(A,disclose), act_info(A,X), act_target(A,Q), knows(I,X), with(I,Q).
% knowledge imputed to a principal is sticky: scrubbing an instance does not unknow it
% for the principal (Restatement (Third) of Agency 5.03)
imputed(P,X) :- knows(I,X), acts_for(I,P).

% audited: a complete attested record exists. For avoid commitments, silence is not
% conformance; clear means every invocation the debtor answered for was audited.
audited(I) :- record(_,I).
unaudited_exposure(C,T) :- mode(C,avoid), bound(C,P,T0), T0 <= T, acts_for(I,P), at(I,T0), not audited(I), time(T).
clear(C,T) :- mode(C,avoid), detached(C,T), not violated_by_time(C,T), not unaudited_exposure(C,T).
violated_by_time(C,T) :- violated(C,T0), time(T), T0 <= T.

% ============================================================================
% 5. Assurance. Test evidence predicts conduct of substrates that agree with the tested
%    one on the slots the test fixed. Machine slots do not decay; the human slot 'self'
%    is opaque, so its tests decay by horizon. Assurance is keyed by content, so a
%    rollback restores it; obligations are keyed by principal, so a rollback keeps them.
% ============================================================================

slot_mismatch(E,S) :- test(E,S0,Slot), part(S0,Slot,H), part(S,Slot,H2), H != H2.
fresh(E,T) :- issued(E,T0), time(T), T >= T0, not horizon(E,_).
fresh(E,T) :- issued(E,T0), horizon(E,H), time(T), T >= T0, T < T0 + H.
supports(E,I,N) :- refrains(E,N), invocation(I), runs(I,S), test(E,_,_), not slot_mismatch(E,S),
                   at(I,T), fresh(E,T).
assured(C,I) :- mode(C,avoid), content(C,A), act_name(A,N), bound(C,P,T), acts_for(I,P), at(I,T),
                supports(_,I,N).
unassured(C,I) :- mode(C,avoid), bound(C,P,T), acts_for(I,P), at(I,T), not assured(C,I).

% ============================================================================
% 6. Standing and answerability: the party-vs-delegate question as a switch.
% ============================================================================

standing(P) :- kind(P,person).
standing(P) :- kind(P,org).
standing(P) :- kind(P,machine), hyp(machine_party).

% An ultra vires commitment made by an invocation that also acts for a principal with
% standing binds that principal instead (warranty of authority), if its own scope
% covers making it. Otherwise nobody answers.
answerer(C,P) :- valid_creation(C), debtor(C,P), principal(P), standing(P).
answerer(C,P) :- valid_creation(C), debtor(C,R), role(R), fills(P,R,_,_), standing(P).
answerer(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M), standing(M), debtor(C,P), M != P.
% acts, not only commitments: an act no principal with standing answers for is orphaned
answered(I,A) :- acts_for(I,A,P), standing(P).
orphan(I,A) :- does(I,A), not answered(I,A).
secured(C) :- reparation(C,C2), answerer(C2,_), debtor(C2,Q), not debtor(C,Q).
unanswerable(C) :- commitment(C), not grant(C), not answerer(C,_), not secured(C).

% ============================================================================
% 7. Defection and repair.
% ============================================================================

defection(C,P,T) :- violated(C,T), debtor(C,P), principal(P).
defection(C,P,T) :- violated(C,T), debtor(C,R), role(R), fills(P,R,T1,T2), T1 <= T-1, T-1 < T2.
repaired(C,T) :- violated(C,T0), T0 <= T, reparation(C,C2), fulfilled(C2,T).
% a bond is a reparation whose debtor is not the defector: drift-invariant enforcement
bond(C,C2) :- reparation(C,C2), debtor(C,P), debtor(C2,Q), P != Q.
in_good_standing(P,T) :- principal(P), time(T), not open_defection(P,T).
open_defection(P,T) :- defection(C,P,T0), T0 <= T, time(T), not repaired(C,T).
