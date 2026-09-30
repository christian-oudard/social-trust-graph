%% A vendor act at t9 named as the maker of a swap first run at t2 (review 3, R15): a later
%% act would breach a no-swap duty through an earlier change.
expect_error(69).
principal(alice). kind(alice,person). principal(ven). kind(ven,org).
substrate(ba). part(ba,self,opaque(alice)). substrate(bv). part(bv,self,opaque(ven)).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(ven0). at(ven0,0). runs(ven0,bv).
invocation(ven9). at(ven9,9). runs(ven9,bv). edge(ven0,ven9,continue).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gv). mode(gv,power). debtor(gv,ven). root(gv,ven0). follows(gv,continue). allows(gv,all,0). recognized(gv,0).
substrate(s1). part(s1,weights,w1). substrate(s2). part(s2,weights,w2).
invocation(a1). at(a1,1). runs(a1,s1). operator(a1,alice).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue). changed_by(a2,ven9).
