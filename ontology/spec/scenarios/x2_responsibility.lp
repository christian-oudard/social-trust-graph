%% X2 (regressions from review R3). Responsibility cannot be shed.
%% (a) Fork-and-disown: Erin's agent learns Q's secret, copies itself (within her scope),
%%     and the copy leaks it. The copy cannot bind Erin, but she answers for it.
%% (b) Mere continuation: a vendor's agent defaults; a fresh org is recognized over the
%%     very next step of the same lineage and inherits the open defection.
%% (c) A vacancy is the appointer's: an office cannot shed a duty by emptying itself.

principal(erin). kind(erin,person). principal(q). kind(q,person). principal(r). kind(r,person).
substrate(bde). part(bde,self,opaque(erin)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
commitment(gerin). mode(gerin,power). debtor(gerin,erin). root(gerin,erin0). follows(gerin,continue). allows(gerin,all,0). recognized(gerin,0).
invocation(erin0). at(erin0,0). runs(erin0,bde).
commitment(ge). mode(ge,power). debtor(ge,erin). created(ge,erin0). root(ge,e1). follows(ge,continue). allows(ge,all,0).
invocation(e1). at(e1,1). runs(e1,s1). learns(e1,x). with(e1,q).
invocation(e2). at(e2,2). runs(e2,s2). edge(e1,e2,continue).
invocation(e3). at(e3,3). runs(e3,s2). edge(e2,e3,copy). with(e3,r).
act_name(dx,disclose). act_info(dx,x). act_target(dx,r).
act_name(sr,sell_to_rival).
commitment(conf). mode(conf,avoid). debtor(conf,erin). creditor(conf,q). content(conf,dx). created(conf,e1).
commitment(excl). mode(excl,avoid). debtor(excl,erin). creditor(excl,q). content(excl,sr). created(excl,e1).
does(e3,sr).
expect(knows(e3,x)). expect(does(e3,dx)). reject(acts_for(e3,erin)). expect(resp_only(e3,erin)).
expect(violated(conf,3)). expect(violated(excl,3)). reject(orphan(e3,sr)).
reject(in_good_standing(erin,5)).

% (b)
principal(v1). kind(v1,org). principal(v2). kind(v2,org). principal(c). kind(c,person).
substrate(sv). part(sv,weights,wv). part(sv,memory,mv1).
substrate(sv2). part(sv2,weights,wv). part(sv2,memory,mv2).
commitment(g1). mode(g1,power). debtor(g1,v1). root(g1,a1). follows(g1,continue). allows(g1,all,0). recognized(g1,0).
invocation(a1). at(a1,1). runs(a1,sv).
invocation(a2). at(a2,2). runs(a2,sv2). edge(a1,a2,continue).
invocation(a3). at(a3,4). runs(a3,sv2). edge(a2,a3,continue).
revokes(a2,g1).                         % v1 abandons the lineage (effective t3)
commitment(g2). mode(g2,power). debtor(g2,v2). root(g2,a3). follows(g2,continue). allows(g2,all,0). recognized(g2,4).
act_name(sx,sell). act_name(py,pay).
commitment(nda). mode(nda,avoid). debtor(nda,v1). creditor(nda,c). content(nda,sx). created(nda,a1).
does(a2,sx).
expect(defection(nda,v1,2)). expect(acts_for(a3,v2)). reject(acts_for(a3,v1)).
expect(continuation_of(v2,v1,4)). reject(in_good_standing(v2,9)). expect(in_good_standing(v2,3)).   % not before it exists
% a fresh instantiation of the same weights is not a continuation
principal(v3). kind(v3,org).
invocation(fresh). at(fresh,4). runs(fresh,sv2).
commitment(g3). mode(g3,power). debtor(g3,v3). root(g3,fresh). follows(g3,continue). allows(g3,all,0). recognized(g3,4).
reject(continuation_of(v3,v1,4)). expect(in_good_standing(v3,9)).

% (c)
role(office). principal(al). kind(al,person). principal(bd). kind(bd,org). appointer(office,bd).
substrate(bbd). part(bbd,self,opaque(bd)). invocation(bd0). at(bd0,0). runs(bd0,bbd).
commitment(gbd). mode(gbd,power). debtor(gbd,bd). root(gbd,bd0). follows(gbd,continue). allows(gbd,all,0). recognized(gbd,0).
appoints(bd0,al,office,5).
act_name(pubs,publish).
commitment(pub). mode(pub,achieve). debtor(pub,office). creditor(pub,c). content(pub,pubs). deadline(pub,6). recognized(pub,0).
expect(violated(pub,6)). expect(vacant(office,6)). expect(defection(pub,bd,6)). reject(unanswered_breach(pub,6)).
