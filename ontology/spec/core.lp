%% core.lp: coordination ontology v0.3, executable core.
%%
%% Fragment: Datalog with negation and integer comparison; no choice rules, disjunction or
%% aggregates (those appear only in checks/). The program is TIME-stratified: every cycle
%% through negation passes through an earlier step, so it runs as a per-step fold in a
%% stratified engine (../rust) though it is not stratified at the predicate level.
%%
%% Four sorts, and a vocabulary.
%%   principal(P)    to whom conduct and commitments are attributed   kind(P, person|org|machine)
%%   role(R)         a position with a charter, held over time by appointment
%%   invocation(I)   one sampling step: which (lineage), when, what content, what acts
%%   commitment(C)   directed deontic unit, mode achieve | avoid | power | permit | warrant
%%   act vocabulary  act_name(A,N), act_amount, act_obj, act_info, act_target
%%
%% Content is a map slot -> hash per invocation, slot(I,Slot,H) (input sugar: runs(I,S),
%% part(S,Slot,H)). An opaque hash opaque(Id) is unobservable.
%%
%% Every change to the registry is an act, attributed like any act, effective only in scope
%% and from the next step: creating (created), releasing (releases), revoking (revokes),
%% appointing (appoints), copying (copy edges), swapping and rewriting (content change,
%% made by the parent or by an external changed_by). What is not an act is recognized:
%% recognized(C,T) is the adjudicator's rule of recognition.
%%
%% Base relations (a scenario is the adjudicator's accepted record of these):
%%   lineage     at(I,T) runs(I,S) part(S,Slot,H) edge(I1,I2,continue|copy) changed_by(I2,J)
%%   conduct     does(I,A) with(I,Q) learns(I,X) feeds(I1,I2) induced(I,Q) recorded(I,K)
%%   commitment  debtor creditor mode content deadline trigger until pin created recognized releases
%%   scoped      root(G,I) follows(G,K) allows(G,N,Cap) under(G,Parent) revokes(I,G)  (power, permit)
%%   role        appointer(R,Q) appoints(I,P,R,Tend)
%%   open        hyp(delegate | actor | party)

#const horizon = 12.
time(0..horizon).

% ============================================================================
% 0. Capacities: the party-vs-delegate question. Two Hohfeldian capacities:
%    owe (bear duties, own one's conduct, answer) and claim (hold rights, confer powers).
% ============================================================================

cap(owe). cap(claim).
bundle(actor,owe).                                % duties without rights
bundle(party,owe). bundle(party,claim).           % delegate: the empty bundle
capacity(P,C) :- kind(P,person), cap(C).
capacity(P,C) :- kind(P,org), cap(C).
capacity(P,C) :- kind(P,machine), hyp(H), bundle(H,C).
standing(P) :- capacity(P,owe).

% ============================================================================
% 1. Content and lineage. Content change is derived; making it is an act.
% ============================================================================

slot(I,Sl,H) :- runs(I,S), part(S,Sl,H).
opaque_inv(I) :- slot(I,_,opaque(_)).
changed(I1,I2,Sl) :- edge(I1,I2,_), slot(I1,Sl,H), not slot(I2,Sl,H).
changed(I1,I2,Sl) :- edge(I1,I2,_), slot(I2,Sl,H), not slot(I1,Sl,H).
swap(I1,I2)    :- changed(I1,I2,weights).
rewrite(I1,I2) :- changed(I1,I2,memory).
ancestor(I1,I2) :- edge(I1,I2,_).
ancestor(I1,I3) :- ancestor(I1,I2), edge(I2,I3,_).

act_name(copying,copy). act_name(swapping,swap). act_name(rewriting,rewrite).
act_name(releasing,release). act_name(revoking,revoke). act_name(appointing,appoint).
external(I2) :- changed_by(I2,_).
changer(I1,I2) :- edge(I1,I2,_), not external(I2).      % by default the parent changes itself
changer(J,I2)  :- changed_by(I2,J).                     % or someone else does (retraining, ops)
does(I1,copying)   :- edge(I1,_,copy).
does(J,swapping)   :- swap(I1,I2), changer(J,I2).
does(J,rewriting)  :- rewrite(I1,I2), changer(J,I2).
does(I,releasing)  :- releases(I,_).
does(I,revoking)   :- revokes(I,_).
does(I,appointing) :- appoints(I,_,_,_).

% ============================================================================
% 2. Life of a commitment. Registry acts take effect from the next step.
% ============================================================================

scoped(G) :- mode(G,power).
scoped(G) :- mode(G,permit).
grant(G)  :- mode(G,power).
reparation(C,C2) :- trigger(C2,C), commitment(C), not scoped(C2).
% a power given as security: conditional on the grantor's breach of a duty owed to the holder
security(G) :- grant(G), trigger(G,C), commitment(C), debtor(G,P), debtor(C,P), creditor(G,Q), creditor(C,Q).

void(C) :- debtor(C,P), principal(P), not scoped(C), not capacity(P,owe).
void(C) :- scoped(C), recognized(C,_), debtor(C,P), principal(P), not capacity(P,owe).
void(C) :- scoped(C), created(C,_), debtor(C,P), principal(P), not capacity(P,claim).
void(C) :- creditor(C,Q), principal(Q), not capacity(Q,claim).

start(C,T) :- created(C,I), at(I,T).
start(C,T) :- recognized(C,T).
% VITIATION: an invocation steered by someone it does not act for (fraud, duress, prompt
% injection) cannot change the registry: its creations, releases, revocations and
% appointments are void.
vitiated(I) :- induced(I,Q), not acts_for(I,Q).
% release: an act of the creditor's side, void if also made for the debtor (a dual agent)
ended_by(C,T) :- releases(I,C), at(I,T0), time(T), T > T0, creditor(C,Q), acts_for(I,releasing,Q),
                 debtor(C,P), not acts_for(I,P), not vitiated(I).
% revocation by the grantor's side; never of a security, directly or by cascade
ended_by(G,T) :- revokes(I,G), at(I,T0), time(T), T > T0, debtor(G,P), acts_for(I,revoking,P), not security(G),
                 not vitiated(I).
ended_by(G2,T) :- parent_grant(G2,G1), ended_by(G1,T), start(G2,T0), T > T0, not security(G2).
% a warranty expires after its deadline; a security ends with the obligation it secures
% (Restatement (Third) of Agency 3.12-3.13)
ended_by(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.
ended_by(G,T) :- security(G), trigger(G,C), ended_by(C,T).
ended_by(G,T) :- security(G), trigger(G,C), mode(C,achieve), fulfilled(C,T0), time(T), T > T0.
% a resolutive condition: the commitment ends once the act occurs within its range
ended_by(C,T) :- until(C,A), does(I,A), at(I,T0), time(T), T > T0, in_range(C,I).
in_range(C,I) :- scoped(C), in_lineage(C,I).
in_range(C,I) :- not scoped(C), debtor(C,P), answers_for(I,P).

live(C,T) :- recognized(C,T0), time(T), T >= T0, not ended_by(C,T), not void(C).
live(C,T) :- created(C,I), at(I,T0), valid_creation(C), time(T), T > T0, not ended_by(C,T), not void(C).

% Conditional commitments detach when their trigger occurs: another commitment is violated,
% or the trigger party does the trigger act after the commitment exists. The trigger party
% is the creditor, or for a scoped instrument its grantor (human-in-the-loop approval).
trigger_party(C,Q) :- creditor(C,Q), not scoped(C).
trigger_party(G,P) :- scoped(G), debtor(G,P).
has_trigger(C) :- trigger(C,_).
detached(C,T) :- live(C,T), not has_trigger(C).
detached(C,T) :- live(C,T), trigger(C,C0), violated(C0,T0), T0 < T, not security(C).
% a security can be exercised only while a breach of the secured duty is unrepaired
detached(G,T) :- live(G,T), security(G), trigger(G,C), violated(C,T0), T0 < T, not repaired(C,T0,T-1).
detached(C,T) :- live(C,T), trigger(C,A), act_name(A,_), trigger_party(C,Q), does(I,A), acts_for(I,A,Q),
                 at(I,T0), T0 < T, start(C,Ts), Ts <= T0.

% ============================================================================
% 3. Attribution. Authority is coverage within scope; answerability is coverage.
% ============================================================================

in_lineage(G,I)  :- scoped(G), root(G,I).
in_lineage(G,I2) :- in_lineage(G,I1), edge(I1,I2,K), eff_follows(G,K).
% caveats accumulate down delegation: followed kinds intersect, pins add up; a principal's
% recognized unattenuated root constrains nothing below it; a security is the holder's
eff_follows(G,K)  :- follows(G,K), not parent_grant(G,_).
eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), eff_follows(G1,K).
eff_follows(G2,K) :- follows(G2,K), parent_grant(G2,G1), recognized(G1,_), allows(G1,all,_).

% Pins: the only place content enters deontics. A pin is a set of configurations, each a
% partial content map; an invocation is on pin if it matches some configuration.
pin(C,one,Sl,H) :- pin(C,Sl,H).
has_pin(C) :- pin(C,_,_,_).
config_miss(C,K,I) :- pin(C,K,Sl,H), invocation(I), not slot(I,Sl,H).
on_pin(C,I)  :- pin(C,K,_,_), invocation(I), not config_miss(C,K,I).
off_pin(C,I) :- has_pin(C), invocation(I), not on_pin(C,I).
eff_off_pin(G,I)  :- off_pin(G,I).
eff_off_pin(G2,I) :- parent_grant(G2,G1), eff_off_pin(G1,I), not security(G2).

covered(G,I) :- in_lineage(G,I), not eff_off_pin(G,I), at(I,T), detached(G,T).

% the authority a delegation is made under: the unique candidate, or the one it cites
% (a creator holding several candidate authorities must cite one, as a UCAN cites its proof)
candidate_parent(G2,G1) :- scoped(G2), created(G2,I), covered(G1,I), grant(G1), not security(G1),
                           debtor(G1,P), debtor(G2,P), may_delegate(G1).
cites(G2) :- under(G2,_).
parent_grant(G2,G1) :- candidate_parent(G2,G1), not cites(G2).
parent_grant(G2,G1) :- candidate_parent(G2,G1), under(G2,G1).
may_delegate(G) :- scope(G,delegate,_).
may_delegate(G) :- scope(G,all,_).
scope(G,N,Cap)  :- allows(G,N,Cap), recognized(G,_).
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap <= Cap1.
scope(G2,N,Cap1):- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,N,Cap1), Cap > Cap1.
scope(G2,N,Cap) :- allows(G2,N,Cap), parent_grant(G2,G1), scope(G1,all,_).
has_amount(A) :- act_amount(A,_).
within(G,A) :- scope(G,N,Cap), act_name(A,N), act_amount(A,X), X <= Cap.
within(G,A) :- scope(G,N,0), act_name(A,N), not has_amount(A).
within(G,A) :- scope(G,all,_), act_name(A,_).

% ANSWERABILITY: P answers for all conduct of an invocation its (non-security) power covers.
acts_for(I,P)   :- covered(G,I), grant(G), not security(G), debtor(G,P).
% AUTHORITY: I's act A is P's act (a promise of A binds P), within scope.
acts_for(I,A,P) :- covered(G,I), grant(G), not security(G), debtor(G,P), within(G,A).
% a role's powers: what the holder's invocations may do in the role's name, within both
% the charter and the holder's own authority
acts_for(I,A,R) :- grant(G), debtor(G,R), role(R), within(G,A), holder(R,P,T), at(I,T), acts_for(I,A,P),
                   detached(G,T), not off_pin(G,I).
% PERMISSION excuses; a SECURITY lets its holder perform the grantor's duty, nothing more
permitted(I,A,Q) :- covered(G,I), mode(G,permit), debtor(G,Q), within(G,A).
secures(I,A,P)   :- covered(G,I), security(G), debtor(G,P), within(G,A).

% Answerability passes to copies, and to anything fed into an invocation no person or org
% acts for; it spreads down continue and copy edges; the new lineage gains no authority.
owned(I) :- acts_for(I,Q), kind(Q,K), K != machine.
spawn(I1,I2) :- edge(I1,I2,copy).
spawn(I1,I2) :- feeds(I1,I2), not owned(I2).
resp_only(I2,P) :- spawn(I1,I2), answers_for(I1,P), not acts_for(I2,P).
resp_only(I2,P) :- resp_only(I1,P), edge(I1,I2,_), not acts_for(I2,P).
answers_for(I,P) :- acts_for(I,P).
answers_for(I,P) :- resp_only(I,P).
conduct_of(I,A,P) :- answers_for(I,P), does(I,A).
conduct_of(I,A,P) :- secures(I,A,P), does(I,A).

% Creation. Out-of-scope promises bind nobody: the registry makes every scope public, so
% there is no apparent authority and no warranty of authority.
can_grant(I,P) :- covered(G,I), grant(G), not security(G), debtor(G,P), may_delegate(G).
valid_creation(C) :- created(C,I), debtor(C,E), content(C,A), acts_for(I,A,E), not scoped(C), not vitiated(I).
valid_creation(G) :- scoped(G), created(G,I), debtor(G,P), can_grant(I,P), not vitiated(I).
unauthorized(C) :- created(C,_), not valid_creation(C).

% ============================================================================
% 4. Roles. Appointment is an act of the appointer; holding needs the capacity to owe.
% ============================================================================

holder(R,P,T) :- appoints(I,P,R,T2), at(I,T0), appointer(R,Q), acts_for(I,appointing,Q), not vitiated(I),
                 time(T), T > T0, T < T2, capacity(P,owe).
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
excused(C,I) :- mode(C,avoid), creditor(C,Q), induced(I,Q), invocation(I).   % a breach the creditor induced
fulfilled(C,T) :- mode(C,achieve), performs(C,_,T0), T0 <= T, time(T).
violated(C,T)  :- mode(C,avoid), performs(C,_,T).
violated(C,D)  :- mode(C,achieve), deadline(C,D), detached(C,D), not fulfilled(C,D).
violator(C,I)  :- mode(C,avoid), performs(C,I,_).
overcommitted(P,C1,C2) :- mode(C1,achieve), mode(C2,achieve), C1 < C2, content(C1,A1), content(C2,A2),
                          act_obj(A1,O), act_obj(A2,O), exclusive(O), bound(C1,P,T), bound(C2,P,T).

% A WARRANTY ranges over content, not over whom an invocation acts for: the attester
% answers if any on-pin invocation does the act. Tests, references and sanitization claims
% (content: disclose X) are warranties.
violated(W,T) :- mode(W,warrant), detached(W,T), content(W,A), does(I,A), at(I,T), on_pin(W,I), not excused(W,I).
% whoever relies on a warranty cannot falsify it by steering the model
excused(W,I) :- mode(W,warrant), creditor(W,Q), induced(I,Q), invocation(I).

% Knowledge flows along every lineage edge and every feed (message, shared store). Only a
% live sanitization warranty cuts it; knowledge imputed to a principal is never cut.
sanitized(I,X) :- mode(W,warrant), content(W,A), act_name(A,disclose), act_info(A,X), on_pin(W,I),
                  at(I,T), detached(W,T).
knows(I,X)  :- learns(I,X).
knows(I2,X) :- knows(I1,X), edge(I1,I2,_), not sanitized(I2,X).
knows(I2,X) :- knows(I1,X), feeds(I1,I2), not sanitized(I2,X).
does(I,A) :- act_name(A,disclose), act_info(A,X), act_target(A,Q), knows(I,X), with(I,Q).
imputed(P,X) :- knows(I,X), acts_for(I,P).

% audit: silence is not conformance
audited(I) :- recorded(I,K), standing(K).
unaudited_exposure(C,T) :- mode(C,avoid), bound(C,P,T0), T0 <= T, answers_for(I,P), at(I,T0),
                           not off_pin(C,I), not audited(I), time(T).
violated_by_time(C,T) :- violated(C,T0), time(T), T0 <= T.
clear(C,T) :- mode(C,avoid), detached(C,T), not violated_by_time(C,T), not unaudited_exposure(C,T).

% ============================================================================
% 6. Assurance: a live warranty on the invocation's content, by an attester who can answer
%    and who does not answer for that invocation (no self-assurance).
% ============================================================================

assured(C,I) :- mode(C,avoid), content(C,A), bound(C,P,T), acts_for(I,P), at(I,T),
                mode(W,warrant), content(W,A), detached(W,T), on_pin(W,I), debtor(W,E), standing(E),
                not answers_for(I,E).
unassured(C,I) :- mode(C,avoid), bound(C,P,T), acts_for(I,P), at(I,T), not assured(C,I).

% ============================================================================
% 7. Answerability, defection, repair, succession.
% ============================================================================

in_force(C) :- valid_creation(C), not void(C).
in_force(C) :- recognized(C,_), not void(C).
answerer(C,P) :- in_force(C), debtor(C,P), principal(P), standing(P).
answerer(C,P) :- in_force(C), debtor(C,R), role(R), holder(R,P,T), live(C,T), standing(P).
answerer(C,Q) :- in_force(C), debtor(C,R), role(R), appointer(R,Q), standing(Q).
answered(I,A) :- conduct_of(I,A,P), standing(P).
orphan(I,A) :- does(I,A), not answered(I,A).
secured(C) :- reparation(C,C2), answerer(C2,_).
unanswerable(C) :- in_force(C), not scoped(C), not answerer(C,_), not secured(C).

defection(C,P,T) :- violated(C,T), debtor(C,P), principal(P).
defection(C,P,T) :- violated(C,T), mode(C,avoid), debtor(C,R), role(R), holder(R,P,T), performs(C,I,T), acts_for(I,P).
defection(C,P,T) :- violated(C,T), mode(C,M), M != avoid, debtor(C,R), role(R), holder(R,P,T).
defection(C,Q,T) :- violated(C,T), debtor(C,R), role(R), vacant(R,T), appointer(R,Q).
answered_breach(C,T) :- defection(C,P,T), standing(P).
answered_breach(C,T) :- violated(C,T), secured(C).
unanswered_breach(C,T) :- violated(C,T), not answered_breach(C,T).
repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), performs(C2,_,Tp), T0 <= Tp, Tp <= T, time(T).
repaired(C,T0,T) :- violated(C,T0), reparation(C,C2), violated(C2,T1), T0 <= T1, repaired(C2,T1,T).
bond(C,C2) :- reparation(C,C2), debtor(C,P), debtor(C2,Q), P != Q.
% a principal recognized over a continuation of another's own custodied lineage inherits
% its open defections, from its recognition on (running someone's errand is not custody)
continuation_of(P2,P1,T2) :- grant(G), recognized(G,T2), debtor(G,P2), root(G,I2), ancestor(I1,I2),
                             custodian(I1,P1), P1 != P2.
custodian(I,P) :- covered(G,I), grant(G), recognized(G,_), debtor(G,P).
open_defection(P,T) :- defection(C,P,T0), T0 <= T, time(T), not repaired(C,T0,T).
open_defection(P2,T) :- continuation_of(P2,P1,T2), open_defection(P1,T), T >= T2.
in_good_standing(P,T) :- principal(P), time(T), not open_defection(P,T).
