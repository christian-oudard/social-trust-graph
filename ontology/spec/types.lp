%% types.lp: sort discipline, loaded with every scenario. Each violation derives
%% type_error/2, which run.py reports, so an ill-sorted scenario fails loudly.
entity(X) :- principal(X).
entity(X) :- role(X).
slotname(weights). slotname(prompt). slotname(scaffold). slotname(tools).
slotname(memory). slotname(context). slotname(self).

% principals and roles
type_error(1,"kind(P,_), not principal(P)") :- kind(P,_), not principal(P).
type_error(2,"principal(P), not kind(P,_)") :- principal(P), not kind(P,_).
type_error(3,"kind(P,K), K not person|org|machine") :- kind(P,K), K != person, K != org, K != machine.
type_error(4,"role(X), principal(X): a coordinator is a role, never a kind of party") :- role(X), principal(X).
type_error(5,"fills(P,R,_,_) not principal/role") :- fills(P,R,_,_), not principal(P).
type_error(6,"fills(P,R,_,_) not principal/role") :- fills(P,R,_,_), not role(R).
type_error(7,"appointer(R,Q) not role/principal") :- appointer(R,Q), not role(R).
type_error(8,"appointer(R,Q) not role/principal") :- appointer(R,Q), not principal(Q).

% invocations and content
type_error(10,"at(I,_), not invocation(I)") :- at(I,_), not invocation(I).
type_error(11,"invocation(I), not at(I,_)") :- invocation(I), not at(I,_).
type_error(12,"invocation(I) without content") :- invocation(I), not slot(I,_,_).
type_error(13,"at(I,T1), at(I,T2), T1 != T2") :- at(I,T1), at(I,T2), T1 != T2.
type_error(14,"runs(I,S1), runs(I,S2), S1 != S2") :- runs(I,S1), runs(I,S2), S1 != S2.
type_error(15,"slot outside the closed vocabulary") :- slot(_,Sl,_), not slotname(Sl).
type_error(16,"two hashes in one slot (hash layered parts together)") :- slot(I,Sl,H1), slot(I,Sl,H2), H1 != H2.
type_error(17,"edge endpoint not an invocation") :- edge(I1,_,_), not invocation(I1).
type_error(18,"edge endpoint not an invocation") :- edge(_,I2,_), not invocation(I2).
type_error(19,"edge kind not continue|copy|merge") :- edge(_,_,K), K != continue, K != copy, K != merge.
type_error(20,"lineage runs forward in time") :- edge(I1,I2,_), at(I1,T1), at(I2,T2), T2 <= T1.
type_error(21,"at most one continuation") :- edge(I,I2,continue), edge(I,I3,continue), I2 != I3.
type_error(22,"opaque content cannot be copied") :- edge(I1,_,copy), opaque_inv(I1).
type_error(23,"learning must change observable content") :- learns(I,_), edge(I,I2,_), not opaque_inv(I),
                                                           not changed(I,I2,_).
type_error(24,"feeds endpoint not an invocation") :- feeds(I1,I2), not invocation(I1).
type_error(25,"feeds endpoint not an invocation") :- feeds(I1,I2), not invocation(I2).
type_error(26,"does(I,_), not invocation(I)") :- does(I,_), not invocation(I).
type_error(27,"induced(I,Q) not invocation/principal") :- induced(I,Q), not principal(Q).
type_error(28,"recorded(I,K): K must be a principal") :- recorded(_,K), not principal(K).

% commitments
type_error(30,"mode(C,_), not commitment(C)") :- mode(C,_), not commitment(C).
type_error(31,"commitment(C), not mode(C,_)") :- commitment(C), not mode(C,_).
type_error(32,"unknown mode") :- mode(_,M), M != achieve, M != avoid, M != power, M != permit, M != warrant.
type_error(33,"commitment without debtor") :- commitment(C), not debtor(C,_).
type_error(34,"debtor not principal or role") :- debtor(_,X), not entity(X).
type_error(35,"creditor not principal or role") :- creditor(_,X), not entity(X).
type_error(36,"debtor = creditor (Symboleo: not both right-holder and liable)") :- debtor(C,X), creditor(C,X).
type_error(37,"non-scoped commitment without content") :- commitment(C), not scoped(C), not content(C,_).
type_error(38,"content(C,A), not act_name(A,_)") :- content(_,A), not act_name(A,_).
type_error(39,"achieve without deadline") :- mode(C,achieve), not deadline(C,_).
type_error(40,"commitment neither created nor recognized") :- commitment(C), not created(C,_), not recognized(C,_).
type_error(41,"created(C,I), not invocation(I)") :- created(_,I), not invocation(I).
type_error(42,"scoped instrument with a principal debtor needs a root") :- scoped(G), debtor(G,P), principal(P), not root(G,_).
type_error(43,"root(G,_), not scoped(G)") :- root(G,_), not scoped(G).
type_error(44,"trigger target is neither commitment nor act") :- trigger(_,X), not commitment(X), not act_name(X,_).
type_error(45,"reparation(C,C2) without trigger(C2,C)") :- reparation(C,C2), not trigger(C2,C).
type_error(46,"warranty without pin: a warranty's range is its pin") :- mode(W,warrant), not has_pin(W).
type_error(47,"warranty over opaque content must expire") :- mode(W,warrant), pin(W,_,_,opaque(_)), not deadline(W,_).
type_error(48,"pin on a slot outside the vocabulary") :- pin(_,_,Sl,_), not slotname(Sl).
type_error(49,"releases(I,C) not invocation/commitment") :- releases(_,C), not commitment(C).
type_error(50,"revokes(I,G): G must be scoped") :- revokes(_,G), not scoped(G).
type_error(52,"invocation after the horizon") :- at(_,T), not time(T).
type_error(53,"recognized and created: pick one") :- recognized(C,_), created(C,_).
type_error(54,"follows merge: a merge carries knowledge, never authority") :- follows(_,merge).
type_error(55,"feeds run forward in time") :- feeds(I1,I2), at(I1,T1), at(I2,T2), T2 <= T1.
type_error(51,"pin/3 with two hashes for one slot: use pin/4 configurations") :- pin(C,Sl,H1), pin(C,Sl,H2), H1 != H2.

% retired v0.1 vocabulary, flagged so old scenarios fail loudly
type_error(90,"founded/2 is now recognized/2") :- founded(_,_).
type_error(91,"released/2 is now the act releases(I,C)") :- released(_,_).
type_error(92,"revoked/2 is now the act revokes(I,G)") :- revoked(_,_).
type_error(93,"evidence is now a warranty (mode warrant)") :- evidence(_).
type_error(94,"evidence is now a warranty (mode warrant)") :- test(_,_,_).
type_error(95,"record/2 is now recorded(I,K)") :- record(_,_).
type_error(96,"clean/3 is now a warranty with content carry(X)") :- clean(_,_,_).
