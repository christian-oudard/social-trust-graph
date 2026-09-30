%% types.lp: sort discipline, loaded with every scenario. Each violation derives
%% type_error/2, which run.py reports, so an ill-sorted scenario fails loudly.
entity(X) :- principal(X). entity(X) :- role(X).
grant(G) :- mode(G,power).
type_error(1,"kind(P,_), not principal(P)") :- kind(P,_), not principal(P).
type_error(2,"principal(P), not kind(P,_)") :- principal(P), not kind(P,_).
type_error(3,"kind(P,K), K != person, K != org, K != machine") :- kind(P,K), K != person, K != org, K != machine.
type_error(4,"at(I,_), not invocation(I)") :- at(I,_), not invocation(I).
type_error(5,"invocation(I), not at(I,_)") :- invocation(I), not at(I,_).
type_error(6,"invocation(I), not runs(I,_)") :- invocation(I), not runs(I,_).
type_error(7,"runs(I,S), not substrate(S)") :- runs(I,S), not substrate(S).
type_error(8,"runs(I,S1), runs(I,S2), S1 != S2") :- runs(I,S1), runs(I,S2), S1 != S2.
type_error(9,"at(I,T1), at(I,T2), T1 != T2") :- at(I,T1), at(I,T2), T1 != T2.
type_error(10,"part(S,_,_), not substrate(S)") :- part(S,_,_), not substrate(S).
type_error(11,"edge(I1,I2,_), not invocation(I1)") :- edge(I1,I2,_), not invocation(I1).
type_error(12,"edge(I1,I2,_), not invocation(I2)") :- edge(I1,I2,_), not invocation(I2).
type_error(13,"edge(I1,I2,K), K != continue, K != copy, K != merge") :- edge(I1,I2,K), K != continue, K != copy, K != merge.
type_error(14,"edge(I1,I2,_), at(I1,T1), at(I2,T2), T2 <= T1.          % lineage runs forward in time") :- edge(I1,I2,_), at(I1,T1), at(I2,T2), T2 <= T1.          % lineage runs forward in time.
type_error(15,"edge(I,I2,continue), edge(I,I3,continue), I2 != I3.     % at most one continuation") :- edge(I,I2,continue), edge(I,I3,continue), I2 != I3.     % at most one continuation.
type_error(16,"mode(C,M), not commitment(C)") :- mode(C,M), not commitment(C).
type_error(17,"commitment(C), not mode(C,_)") :- commitment(C), not mode(C,_).
type_error(18,"mode(C,M), M != achieve, M != avoid, M != power") :- mode(C,M), M != achieve, M != avoid, M != power.
type_error(19,"commitment(C), not debtor(C,_)") :- commitment(C), not debtor(C,_).
type_error(20,"debtor(C,X), not entity(X)") :- debtor(C,X), not entity(X).
type_error(21,"creditor(C,X), not entity(X)") :- creditor(C,X), not entity(X).
type_error(22,"commitment(C), not grant(C), not content(C,_)") :- commitment(C), not grant(C), not content(C,_).
type_error(23,"content(C,A), not act_name(A,_)") :- content(C,A), not act_name(A,_).
type_error(24,"mode(C,achieve), not deadline(C,_)") :- mode(C,achieve), not deadline(C,_).
type_error(25,"commitment(C), not created(C,_), not founded(C,_)") :- commitment(C), not created(C,_), not founded(C,_).
type_error(26,"created(C,I), not invocation(I)") :- created(C,I), not invocation(I).
type_error(27,"root(G,_), not grant(G)") :- root(G,_), not grant(G).
type_error(28,"grant(G), debtor(G,P), principal(P), not root(G,_)") :- grant(G), debtor(G,P), principal(P), not root(G,_).
type_error(29,"trigger(C,C0), not commitment(C0)") :- trigger(C,C0), not commitment(C0).
type_error(30,"reparation(C,C2), not trigger(C2,C)") :- reparation(C,C2), not trigger(C2,C).
type_error(31,"fills(P,R,_,_), not principal(P)") :- fills(P,R,_,_), not principal(P).
type_error(32,"fills(P,R,_,_), not role(R)") :- fills(P,R,_,_), not role(R).
type_error(33,"does(I,_), not invocation(I)") :- does(I,_), not invocation(I).
type_error(99,"debtor(C,X), creditor(C,X)") :- debtor(C,X), creditor(C,X).   % Symboleo: !(rightHolder & liable)
type_error(100,"edge(I1,I2,copy), runs(I1,S), part(S,self,_)") :- edge(I1,I2,copy), runs(I1,S), part(S,self,_).   % persons cannot be copied
type_error(101,"role(X), principal(X)") :- role(X), principal(X).   % a coordinator is a role, never a kind of party
