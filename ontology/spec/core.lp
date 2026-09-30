%% core.lp: coordination ontology v0.2, executable core.
%%
%% Fragment: Datalog with negation and integer comparison; no choice rules, disjunction
%% or aggregates (those appear only in checks/). The program is TIME-stratified: each
%% negated literal on a derived relation refers to the same step of a relation lower in
%% the step's order, or to an earlier step. It runs as a per-step fold in a stratified
%% engine (see ../rust), not as one predicate-stratified program.
%%
%% Five sorts. Everything else is a relation between them or derived.
%%   principal(P)    to whom acts and commitments are attributed   kind(P, person|org|machine)
%%   role(R)         a position with a charter, held over time by principals
%%   invocation(I)   one sampling step: which (lineage), when, what content, what acts
%%   commitment(C)   directed deontic unit, mode achieve | avoid | power | permit | warrant
%%   act(A)          the domain vocabulary: act_name(A,N), act_amount, act_obj, act_info, act_target
%%
%% Content is a map slot -> hash per invocation, slot(I,Slot,H). A named "substrate" is
%% input sugar: runs(I,S) with part(S,Slot,H). Opaque hashes opaque(Id) are unobservable.
%%
%% Every change to normative state is an act of some invocation, effective only in scope,
%% from the step after the act: creating (created), releasing (releases), revoking
%% (revokes), copying and merging (lineage edges), swapping and rewriting (content change
%% on an edge). What is not an act is recognized: recognized(C,T) is the adjudicator's
%% rule of recognition (a principal's root authority, duties imposed by law, charters).
%%
%% Base relations (a scenario is the adjudicator's accepted record of these):
%%   lineage     at(I,T) runs(I,S) part(S,Slot,H) edge(I1,I2,K)  K in {continue,copy,merge}
%%   conduct     does(I,A) with(I,Q) learns(I,X) feeds(I1,I2) induced(I,Q) recorded(I,K)
%%   commitment  debtor creditor mode content deadline trigger reparation created recognized
%%               releases(I,C) pin(C,Slot,H) | pin(C,Config,Slot,H)
%%   scoped      root(G,I) follows(G,K) allows(G,N,Cap) revokes(I,G)   (modes power, permit)
%%   role        fills(P,R,T1,T2) appointer(R,Q)
%%   open        hyp(delegate | actor | party)   which Hohfeldian capacities machines have

#const horizon = 12.
time(0..horizon).

% ============================================================================
% 0. Capacities: the party-vs-delegate question as a bundle, not a bit.
% ============================================================================

cap(owe). cap(claim). cap(empower). cap(answer).
bundle(party,owe). bundle(party,claim). bundle(party,empower). bundle(party,answer).
bundle(actor,owe). bundle(actor,answer).          % duties without rights ("legal actor")
                                                  % delegate: the empty bundle
capacity(P,C) :- kind(P,person), cap(C).
capacity(P,C) :- kind(P,org), cap(C).
capacity(P,C) :- kind(P,machine), hyp(H), bundle(H,C).
standing(P) :- capacity(P,answer).

% ============================================================================
% 1. Content and lineage. Change kinds are derived from content; making them is an act.
% ============================================================================

slot(I,Sl,H) :- runs(I,S), part(S,Sl,H).
opaque_inv(I) :- slot(I,_,opaque(_)).

changed(I1,I2,Sl) :- edge(I1,I2,_), slot(I1,Sl,H), not slot(I2,Sl,H).
changed(I1,I2,Sl) :- edge(I1,I2,_), slot(I2,Sl,H), not slot(I1,Sl,H).
swap(I1,I2)    :- changed(I1,I2,weights).
rewrite(I1,I2) :- changed(I1,I2,memory).

ancestor(I1,I2) :- edge(I1,I2,_).
ancestor(I1,I3) :- ancestor(I1,I2), edge(I2,I3,_).
anc_differs(I0,I) :- ancestor(I0,I), slot(I,Sl,H), not slot(I0,Sl,H).
anc_differs(I0,I) :- ancestor(I0,I), slot(I0,Sl,H), not slot(I,Sl,H).
% same observable content as an ancestor; opaque content never counts as the same
same_as_ancestor(I0,I) :- ancestor(I0,I), not anc_differs(I0,I), not opaque_inv(I).
rollback(I) :- same_as_ancestor(_,I), changed(_,I,_).

% lineage and content changes are acts of the parent invocation
act_name(copying,copy). act_name(merging,merge). act_name(swapping,swap). act_name(rewriting,rewrite).
act_name(releasing,release). act_name(revoking,revoke).
does(I1,copying)   :- edge(I1,_,copy).
does(I2,merging)   :- edge(_,I2,merge).      % a merge is the receiving side's act
does(I1,swapping)  :- swap(I1,_).
does(I1,rewriting) :- rewrite(I1,_).
does(I,releasing)  :- releases(I,_).
does(I,revoking)   :- revokes(I,_).


% ============================================================================
% 2. Life of a commitment. Registry acts take effect from the next step.
% ============================================================================

scoped(G) :- mode(G,power).
scoped(G) :- mode(G,permit).
grant(G)  :- mode(G,power).

% void: a party lacks the capacity its position needs
void(C) :- debtor(C,P), principal(P), mode(C,M), M != power, M != permit, not capacity(P,owe).
% a recognized root is self-attribution (one's conduct is one's own): it needs only owe;
% creating a power or permit for someone else needs empower
void(C) :- scoped(C), recognized(C,_), debtor(C,P), principal(P), not capacity(P,owe).
void(C) :- scoped(C), created(C,_), debtor(C,P), principal(P), not capacity(P,empower).
void(C) :- creditor(C,Q), principal(Q), not capacity(Q,claim).

ended_by(C,T) :- releases(I,C), at(I,T0), creditor(C,Q), acts_for(I,releasing,Q), time(T), T > T0.
ended_by(G,T) :- revokes(I,G), at(I,T0), debtor(G,P), acts_for(I,revoking,P), time(T), T > T0.
% revocation cascades down sub-delegation
ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), created(G2,I), at(I,T0), T > T0.
% warranties expire after their deadline
ended_by(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.

live(C,T) :- recognized(C,T0), time(T), T >= T0, not ended_by(C,T), not void(C).
live(C,T) :- created(C,I), at(I,T0), valid_creation(C), time(T), T > T0, not ended_by(C,T), not void(C).

% Conditional commitments (Singh's antecedent) detach when their trigger occurs: another
% commitment is violated, or the trigger party performs the trigger act. The trigger party
% is the creditor, or for a scoped instrument its grantor (human-in-the-loop approval).
trigger_party(C,Q) :- creditor(C,Q), not scoped(C).
trigger_party(G,P) :- scoped(G), debtor(G,P).
has_trigger(C) :- trigger(C,_).
detached(C,T) :- live(C,T), not has_trigger(C).
detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 < T.
detached(C,T) :- live(C,T), trigger(C,A), act_name(A,_), trigger_party(C,Q), does(I,A), acts_for(I,A,Q),
                 at(I,T0), T0 < T, start(C,Ts), Ts <= T0.
start(C,T) :- created(C,I), at(I,T).
start(C,T) :- recognized(C,T).

% ============================================================================
% 3. Attribution. Authority flows only through powers, in scope.
% ============================================================================

in_lineage(G,I)  :- scoped(G), root(G,I).
% authority crosses continue and copy edges only; a merge carries knowledge, not authority
in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), K != merge, eff_follows(G,K).
% caveats accumulate down delegation: followed kinds intersect, pins add up. A
% principal's own unattenuated root is the exception (it constrains nothing below it).
eff_follows(G,K)  :- follows(G,K), not parent_grant(G,_).
eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), eff_follows(G1,K).
eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), scope(G1,all,_).

% Pins: the only place content enters deontics. A pin is a set of configurations,
% each a partial content map; an invocation is on pin if it matches some configuration.
pin(C,one,Sl,H) :- pin(C,Sl,H).
has_pin(C) :- pin(C,_,_,_).
config_miss(C,K,I) :- pin(C,K,Sl,H), invocation(I), not slot(I,Sl,H).
on_pin(C,I)  :- pin(C,K,_,_), invocation(I), not config_miss(C,K,I).
off_pin(C,I) :- has_pin(C), invocation(I), not on_pin(C,I).
eff_off_pin(G,I)  :- off_pin(G,I).
eff_off_pin(G2,I) :- parent_grant(G2,G1), eff_off_pin(G1,I).

covered(G,I) :- in_lineage(G,I), not eff_off_pin(G,I), at(I,T), detached(G,T).

parent_grant(G2,G1) :- scoped(G2), created(G2,I), covered(G1,I), grant(G1), debtor(G1,P), debtor(G2,P),
                        may_delegate(G1).
may_delegate(G) :- scope(G,delegate,_).
may_delegate(G) :- scope(G,all,_).
scope(G,N,Cap)  :- allows(G,N,Cap), recognized(G,_).
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap <= Cap1.
scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,all,_).
has_amount(A) :- act_amount(A,_).
within(G,A) :- scope(G,N,Cap), act_name(A,N), act_amount(A,X), X <= Cap.
within(G,A) :- scope(G,N,_), act_name(A,N), not has_amount(A).
within(G,A) :- scope(G,all,_), act_name(A,_).

% AUTHORITY: I's act A is P's act (a promise of A binds P; P answers for I doing A).
acts_for(I,P)   :- covered(G,I), grant(G), debtor(G,P).
acts_for(I,A,P) :- covered(G,I), grant(G), debtor(G,P), within(G,A).
% a role's powers cover what its current holder's invocations do within the charter
acts_for(I,A,R) :- grant(G), debtor(G,R), role(R), within(G,A), holder(R,P,T), at(I,T), acts_for(I,P),
                   detached(G,T), not off_pin(G,I).
% PERMISSION: a permit makes I's act A excused towards its grantor, and nothing more
permitted(I,A,Q) :- covered(G,I), mode(G,permit), debtor(G,Q), within(G,A).

% RESPONSIBILITY beyond authority: copying is an act. Whoever's scope covered it answers
% for the conduct of the copy's lineage, which gains no authority from it.
resp_only(I2,P) :- edge(I1,I2,copy), acts_for(I1,copying,P), not acts_for(I2,P).
resp_only(I2,P) :- resp_only(I1,P), edge(I1,I2,_), not acts_for(I2,P).
conduct_of(I,A,P) :- acts_for(I,A,P).
conduct_of(I,A,P) :- resp_only(I,P), does(I,A).

% creation. A promise induced by its own creditor (fraud, duress, prompt injection) is void.
induced_by_creditor(C) :- created(C,I), creditor(C,Q), induced(I,Q).
can_grant(I,P) :- covered(G,I), grant(G), debtor(G,P), may_delegate(G).
valid_creation(C) :- created(C,I), debtor(C,P), principal(P), content(C,A), acts_for(I,A,P),
                     not scoped(C), not induced_by_creditor(C).
valid_creation(C) :- created(C,I), debtor(C,R), role(R), content(C,A), acts_for(I,A,R),
                     not scoped(C), not induced_by_creditor(C).
valid_creation(G) :- scoped(G), created(G,I), debtor(G,P), can_grant(I,P).
ultra_vires(C) :- created(C,_), not valid_creation(C).

% ============================================================================
% 4. Binding and roles.
% ============================================================================

holder(R,P,T) :- fills(P,R,T1,T2), time(T), T1 <= T, T < T2, capacity(P,owe).
held(R,T) :- holder(R,_,T).
vacant(R,T) :- role(R), time(T), not held(R,T).
bound(C,P,T) :- detached(C,T), debtor(C,P), principal(P), not scoped(C).
bound(C,P,T) :- detached(C,T), debtor(C,R), role(R), holder(R,P,T), not scoped(C).
charter(R,C) :- debtor(C,R), role(R).

% ============================================================================
% 5. Conformance. Fork law: achieve is discharged once by any invocation whose conduct
%    the debtor answers for; avoid is broken by any of them.
% ============================================================================

performs(C,I,T) :- bound(C,P,T), content(C,A), does(I,A), at(I,T), conduct_of(I,A,P),
                   not excused(C,I), not off_pin(C,I).
excused(C,I) :- mode(C,avoid), creditor(C,Q), content(C,A), permitted(I,A,Q).
excused(C,I) :- creditor(C,Q), induced(I,Q), invocation(I), commitment(C).
fulfilled(C,T) :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T).
violated(C,T)  :- mode(C,avoid), performs(C,_,T).
violated(C,D)  :- mode(C,achieve), deadline(C,D), detached(C,D), not fulfilled(C,D).
violator(C,I)  :- mode(C,avoid), performs(C,I,_).
overcommitted(P,C1,C2) :- mode(C1,achieve), mode(C2,achieve), C1 < C2, content(C1,A1), content(C2,A2),
                          act_obj(A1,O), act_obj(A2,O), exclusive(O), bound(C1,P,T), bound(C2,P,T).

% A WARRANTY ranges over content, not over whom an invocation acts for: the attester
% answers if any on-pin invocation does the act. Tests, references and sanitization
% claims are warranties; there is no separate evidence sort.
violated(W,T) :- mode(W,warrant), detached(W,T), content(W,A), does(I,A), at(I,T), on_pin(W,I).
% a sanitization warranty (content: carry X) is falsified by an observed disclosure of X
violated(W,T) :- mode(W,warrant), detached(W,T), content(W,A), act_name(A,carry), act_info(A,X),
                 on_pin(W,I), at(I,T), does(I,A2), act_name(A2,disclose), act_info(A2,X).

% Knowledge flows along every lineage edge and every feed (message, shared store). It is
% cut only by reverting to the content of an ancestor upstream of all learning of X, or by
% a live sanitization warranty. Knowledge imputed to a principal is never cut.
learned(X) :- learns(_,X).
tainted(I,X) :- learns(I,X).
tainted(I,X) :- learns(L,X), ancestor(L,I).
reverted(I,X) :- same_as_ancestor(I0,I), learned(X), not tainted(I0,X).
sanitized(I,X) :- mode(W,warrant), content(W,A), act_name(A,carry), act_info(A,X), on_pin(W,I),
                  at(I,T), detached(W,T).
scrubbed(I,X) :- reverted(I,X).
scrubbed(I,X) :- sanitized(I,X).
knows(I,X)  :- learns(I,X).
knows(I2,X) :- knows(I1,X), edge(I1,I2,_), not scrubbed(I2,X).
knows(I2,X) :- knows(I1,X), feeds(I1,I2), not scrubbed(I2,X).
does(I,A) :- act_name(A,disclose), act_info(A,X), act_target(A,Q), knows(I,X), with(I,Q).
imputed(P,X) :- knows(I,X), acts_for(I,P).

% audit: silence is not conformance
audited(I) :- recorded(I,K), standing(K).
unaudited_exposure(C,T) :- mode(C,avoid), content(C,A), bound(C,P,T0), T0 <= T, conduct_of(I,A,P), at(I,T0),
                           not off_pin(C,I), not audited(I), time(T).
violated_by_time(C,T) :- violated(C,T0), time(T), T0 <= T.
clear(C,T) :- mode(C,avoid), detached(C,T), not violated_by_time(C,T), not unaudited_exposure(C,T).

% ============================================================================
% 6. Assurance: a live warranty by an attester with standing, on pin for the invocation.
% ============================================================================

assured(C,I) :- mode(C,avoid), content(C,A), bound(C,P,T), acts_for(I,P), at(I,T),
                mode(W,warrant), content(W,A), detached(W,T), on_pin(W,I), debtor(W,E), standing(E).
unassured(C,I) :- mode(C,avoid), bound(C,P,T), acts_for(I,P), at(I,T), not assured(C,I).

% ============================================================================
% 7. Answerability.
% ============================================================================

in_force(C) :- valid_creation(C), not void(C).
in_force(C) :- recognized(C,_), not void(C).
answerer(C,P) :- in_force(C), debtor(C,P), principal(P), standing(P).
answerer(C,P) :- in_force(C), debtor(C,R), role(R), holder(R,P,T), live(C,T), standing(P).
answerer(C,Q) :- in_force(C), debtor(C,R), role(R), appointer(R,Q), standing(Q).
% warranty of authority: whoever answers for the creator's conduct answers for its false claim
answerer(C,M) :- warranted_authority(C,M), standing(M).
% (a promise its own creditor induced gives that creditor nothing, not even this)
warranted_authority(C,M) :- ultra_vires(C), created(C,I), content(C,A), acts_for(I,A,M), not induced_by_creditor(C).
warranted_authority(C,M) :- ultra_vires(C), created(C,I), resp_only(I,M), not induced_by_creditor(C).
answered(I,A) :- conduct_of(I,A,P), standing(P).
orphan(I,A) :- does(I,A), not answered(I,A).
secured(C) :- reparation(C,C2), answerer(C2,_).
unanswerable(C) :- commitment(C), not scoped(C), not void(C), not answerer(C,_), not secured(C).

% ============================================================================
% 8. Defection, repair, succession.
% ============================================================================

defection(C,P,T) :- violated(C,T), debtor(C,P), principal(P).
defection(C,P,T) :- violated(C,T), mode(C,avoid), debtor(C,R), role(R), holder(R,P,T), performs(C,I,T), acts_for(I,P).
defection(C,P,T) :- violated(C,T), mode(C,achieve), debtor(C,R), role(R), holder(R,P,T).
% a breach during a vacancy is the appointer's
defection(C,Q,T) :- violated(C,T), debtor(C,R), role(R), vacant(R,T), appointer(R,Q).
% breach of warranty of authority happens when the unauthorized promise is made
defection(C,M,T) :- warranted_authority(C,M), created(C,I), at(I,T).
answered_breach(C,T) :- defection(C,P,T), standing(P).
answered_breach(C,T) :- violated(C,T), secured(C).
unanswered_breach(C,T) :- violated(C,T), not answered_breach(C,T).
repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), performs(C2,_,Tp), T0 <= Tp, Tp <= T, time(T).
repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), violated(C2,T1), T0 <= T1, repaired(C2,T1,T).
% drift-invariant enforcement, weakest to strongest
bond(C,C2) :- reparation(C,C2), debtor(C,P), debtor(C2,Q), P != Q.
collateral(C,G) :- grant(G), trigger(G,C), debtor(G,P), debtor(C,P), creditor(C,Q), root(G,I), acts_for(I,Q).
% a principal recognized over a continuation of another's lineage inherits its defections
continuation_of(P2,P1) :- grant(G), recognized(G,_), debtor(G,P2), root(G,I2), ancestor(I1,I2),
                          acts_for(I1,P1), P1 != P2.
open_defection(P,T) :- defection(C,P,T0), T0 <= T, time(T), not repaired(C,T0,T).
open_defection(P2,T) :- continuation_of(P2,P1), open_defection(P1,T).
in_good_standing(P,T) :- principal(P), time(T), not open_defection(P,T).
