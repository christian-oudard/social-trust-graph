%% X8e (review round 3, formal: R12). A stale citation is unauthorized, not ill-typed.
%% Alice's agent cites g1 as its authority, but Alice revoked g1 at t2: the delegation is
%% unauthorized. (As a type error it was invisible to the exhaustive checks, which discard
%% ill-typed worlds.)
principal(alice). kind(alice,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(s1). part(s1,weights,w1).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(alice2). at(alice2,2). runs(alice2,ba). edge(alice0,alice2,continue).
commitment(g1). mode(g1,power). debtor(g1,alice). created(g1,alice0). root(g1,k1). follows(g1,continue). allows(g1,delegate,0). allows(g1,pay,5).
invocation(k1). at(k1,1). runs(k1,s1). invocation(k5). at(k5,5). runs(k5,s1). edge(k1,k5,continue).
revokes(alice2,g1).
commitment(g2). mode(g2,power). debtor(g2,alice). created(g2,k5). root(g2,k5). follows(g2,continue). allows(g2,pay,5). under(g2,g1).
expect(bad_cite(g2)). expect(unauthorized(g2)). reject(live(g2,6)).
