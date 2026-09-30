%% types.lp: sort discipline, loaded with every scenario. Each violation derives
%% type_error/2, which run.py reports, so an ill-sorted scenario fails loudly.
entity(X) :- principal(X).
entity(X) :- role(X).
slotname(weights). slotname(prompt). slotname(scaffold). slotname(tools).
slotname(memory). slotname(context). slotname(self).

% principals and roles
type_error(5,"appoints(I,P,R,_): P principal, R role") :- appoints(_,P,_,_), not principal(P).
type_error(6,"appoints(I,P,R,_): P principal, R role") :- appoints(_,_,R,_), not role(R).
type_error(9,"every role needs an appointer") :- role(R), not appointer(R,_).
% a person's content is exactly one opaque self slot, along its whole lineage
person_inv(I) :- root(G,I), recognized(G,_), debtor(G,P), kind(P,person).
person_inv(I2) :- person_inv(I1), edge(I1,I2,_).
type_error(29,"a person's content is one opaque self slot") :- person_inv(I), slot(I,Sl,_), Sl != self.
type_error(56,"a person's content is one opaque self slot") :- person_inv(I), not opaque_inv(I).
type_error(1,"kind(P,_), not principal(P)") :- kind(P,_), not principal(P).
type_error(2,"principal(P), not kind(P,_)") :- principal(P), not kind(P,_).
type_error(3,"kind(P,K), K not person|org|machine") :- kind(P,K), K != person, K != org, K != machine.
type_error(4,"role(X), principal(X): a coordinator is a role, never a kind of party") :- role(X), principal(X).
type_error(7,"appointer(R,Q) not role/principal") :- appointer(R,Q), not role(R).
type_error(8,"appointer(R,Q) not role/principal") :- appointer(R,Q), not principal(Q).

% invocations and content
type_error(19,"edge kind not continue|copy (a merge is feeds: knowledge, never authority)") :- edge(_,_,K), K != continue, K != copy.
type_error(22,"a self slot cannot be copied") :- edge(I1,_,copy), slot(I1,self,_).
type_error(57,"changed_by(I2,J): invocations") :- changed_by(I2,J), not invocation(J).
type_error(58,"changed_by(I2,J): I2 must have a parent") :- changed_by(I2,_), not edge(_,I2,_).
type_error(69,"changed_by(I2,J): the change is made before I2 runs") :- changed_by(I2,J), at(I2,T2), at(J,TJ), TJ >= T2.
type_error(59,"deadline beyond the horizon") :- deadline(_,D), not time(D).
type_error(60,"until(C,A): A must be an act") :- until(_,A), not act_name(A,_).
type_error(10,"at(I,_), not invocation(I)") :- at(I,_), not invocation(I).
type_error(11,"invocation(I), not at(I,_)") :- invocation(I), not at(I,_).
type_error(12,"invocation(I) without content") :- invocation(I), not slot(I,_,_).
type_error(13,"at(I,T1), at(I,T2), T1 != T2") :- at(I,T1), at(I,T2), T1 != T2.
type_error(14,"runs(I,S1), runs(I,S2), S1 != S2") :- runs(I,S1), runs(I,S2), S1 != S2.
type_error(15,"slot outside the closed vocabulary") :- slot(_,Sl,_), not slotname(Sl).
type_error(16,"two hashes in one slot (hash layered parts together)") :- slot(I,Sl,H1), slot(I,Sl,H2), H1 != H2.
type_error(17,"edge endpoint not an invocation") :- edge(I1,_,_), not invocation(I1).
type_error(18,"edge endpoint not an invocation") :- edge(_,I2,_), not invocation(I2).
type_error(20,"lineage runs forward in time") :- edge(I1,I2,_), at(I1,T1), at(I2,T2), T2 <= T1.
type_error(21,"at most one continuation") :- edge(I,I2,continue), edge(I,I3,continue), I2 != I3.
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
type_error(46,"warranty without pin: a warranty's range is its pin") :- mode(W,warrant), not has_pin(W).
type_error(47,"warranty over opaque content must expire") :- mode(W,warrant), pin(W,_,_,opaque(_)), not deadline(W,_).
type_error(48,"pin on a slot outside the vocabulary") :- pin(_,_,Sl,_), not slotname(Sl).
type_error(49,"releases(I,C) not invocation/commitment") :- releases(_,C), not commitment(C).
type_error(50,"revokes(I,G): G must be scoped") :- revokes(_,G), not scoped(G).
type_error(52,"invocation after the horizon") :- at(_,T), not time(T).
type_error(53,"recognized and created: pick one") :- recognized(C,_), created(C,_).
type_error(55,"feeds run forward in time") :- feeds(I1,I2), at(I1,T1), at(I2,T2), T2 <= T1.
type_error(61,"ambiguous delegation: cite the parent with under/2") :- candidate_parent(G,G1), candidate_parent(G,G3), G1 < G3, not cites(G).
type_error(62,"under/2 must cite a power of the same grantor") :- under(G,G1), not mode(G1,power).
type_error(62,"under/2 must cite a power of the same grantor") :- under(G,G1), debtor(G,P), not debtor(G1,P).
type_error(63,"a commitment is created once") :- created(C,I1), created(C,I2), I1 != I2.
type_error(64,"a power's pin must be observable: scope is public only if it can be checked") :- grant(G), pin(G,_,_,opaque(_)).
type_error(65,"a security performs its reparation; it takes no resolutive condition") :- security(G), until(G,_).
type_error(66,"operator(I,P): P must be a principal") :- operator(_,P), not principal(P).
contested(I) :- root(G1,I), root(G2,I), grant(G1), grant(G2), debtor(G1,P1), debtor(G2,P2), P1 != P2.
type_error(67,"powers of several principals share a root: record its operator") :- contested(I), not op_set(I), not has_parent(I).
type_error(51,"pin/3 with two hashes for one slot: use pin/4 configurations") :- pin(C,Sl,H1), pin(C,Sl,H2), H1 != H2.

% retired v0.1 vocabulary, flagged so old scenarios fail loudly
type_error(90,"founded/2 is now recognized/2") :- founded(_,_).
type_error(97,"fills/4 is now the act appoints(I,P,R,Tend)") :- fills(_,_,_,_).
type_error(91,"released/2 is now the act releases(I,C)") :- released(_,_).
type_error(92,"revoked/2 is now the act revokes(I,G)") :- revoked(_,_).
type_error(93,"evidence is now a warranty (mode warrant)") :- evidence(_).
type_error(94,"evidence is now a warranty (mode warrant)") :- test(_,_,_).
type_error(95,"record/2 is now recorded(I,K)") :- record(_,_).
type_error(96,"clean/3 is now a warranty with content carry(X)") :- clean(_,_,_).
% an opaque slot cannot be seen to change, so no default author is credible: API weights do
% not change themselves. Name the maker (possibly the parent) with changed_by.
type_error(68,"a change to opaque content needs its maker: changed_by") :- changed(_,I2,Sl), slot(I2,Sl,opaque(_)), not external(I2).
