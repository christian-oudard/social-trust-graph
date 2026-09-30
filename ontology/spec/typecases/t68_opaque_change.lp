%% API weights change between two steps and the record names no maker (review 3, Z6b):
%% the default would blame whoever runs the agent for a change it could not see.
expect_error(68).
principal(alice). kind(alice,person). substrate(ba). part(ba,self,opaque(alice)).
invocation(alice0). at(alice0,0). runs(alice0,ba).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
substrate(s1). part(s1,weights,opaque(w1)). substrate(s2). part(s2,weights,opaque(w2)).
invocation(a1). at(a1,1). runs(a1,s1). operator(a1,alice).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).
