%% operator/2 names a principal, not an invocation.
expect_error(66).
principal(alice). kind(alice,person). substrate(ba). part(ba,self,opaque(alice)).
invocation(alice0). at(alice0,0). runs(alice0,ba).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
substrate(s1). part(s1,weights,w1).
invocation(a1). at(a1,1). runs(a1,s1). operator(a1,alice0).
