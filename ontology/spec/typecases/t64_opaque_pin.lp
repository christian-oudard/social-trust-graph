%% A power pinned to opaque content: its scope could not be checked by anyone relying on it.
expect_error(64).
principal(alice). kind(alice,person). substrate(ba). part(ba,self,opaque(alice)).
invocation(alice0). at(alice0,0). runs(alice0,ba).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
substrate(s1). part(s1,weights,opaque(w1)).
invocation(a1). at(a1,1). runs(a1,s1). operator(a1,alice).
commitment(g). mode(g,power). debtor(g,alice). created(g,alice0). root(g,a1). follows(g,continue). allows(g,book,0).
  pin(g,weights,opaque(w1)).
act_name(book,book).
