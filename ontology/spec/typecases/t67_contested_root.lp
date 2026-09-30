%% Two principals file powers rooted at the same fresh invocation, and nobody records who runs it.
expect_error(67).
principal(alice). kind(alice,person). principal(eve). kind(eve,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(be). part(be,self,opaque(eve)).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(eve0). at(eve0,0). runs(eve0,be).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(ge). mode(ge,power). debtor(ge,eve). root(ge,eve0). follows(ge,continue). allows(ge,all,0). recognized(ge,0).
substrate(s1). part(s1,weights,w1).
invocation(a1). at(a1,1). runs(a1,s1).
commitment(g1). mode(g1,power). debtor(g1,alice). created(g1,alice0). root(g1,a1). follows(g1,continue). allows(g1,all,0).
commitment(g2). mode(g2,power). debtor(g2,eve). created(g2,eve0). root(g2,a1). follows(g2,continue). allows(g2,all,0).
