%% X8a (regressions from review round 3, formal: R5, R13). Resolutive conditions.
%% Bob consents to Alice's agent processing his data "until the model is swapped". The
%% vendor retrains it (changed_by): the swap occurs at the swapped invocation, whoever made
%% it, so the consent ends and later processing breaches Alice's standing prohibition.
principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(ven). kind(ven,org).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
substrate(s1). part(s1,weights,w1). substrate(s2). part(s2,weights,w2). substrate(sv). part(sv,weights,wv).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gv). mode(gv,power). debtor(gv,ven). root(gv,v0). follows(gv,continue). allows(gv,all,0). recognized(gv,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(v0). at(v0,0). runs(v0,sv). invocation(v1). at(v1,2). runs(v1,sv). edge(v0,v1,continue).
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,3). runs(a2,s2). edge(a1,a2,continue). changed_by(a2,v1).
invocation(a3). at(a3,5). runs(a3,s2). edge(a2,a3,continue). does(a3,pb).
act_name(pb,process_bob).
commitment(cb). mode(cb,permit). debtor(cb,bob). created(cb,bob0). root(cb,a1). follows(cb,continue). allows(cb,process_bob,0).
  until(cb,swapping).
commitment(nb). mode(nb,avoid). debtor(nb,alice). creditor(nb,bob). content(nb,pb). recognized(nb,0).
expect(does(v1,swapping)). expect(ended_by(cb,4)). reject(ended_by(cb,3)). expect(violated(nb,5)).

% R13: an until act before the commitment starts does not end it (only later acts count)
principal(alice). kind(alice,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(s1). part(s1,weights,w1).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
invocation(alice0). at(alice0,0). runs(alice0,ba).
commitment(g1). mode(g1,power). debtor(g1,alice). created(g1,alice0). root(g1,k1). follows(g1,continue). allows(g1,all,0).
invocation(k1). at(k1,1). runs(k1,s1). invocation(k5). at(k5,5). runs(k5,s1). edge(k1,k5,continue).
commitment(g2). mode(g2,power). debtor(g2,alice). created(g2,k5). root(g2,r0). follows(g2,continue). follows(g2,copy). allows(g2,pay,1). until(g2,ok).
invocation(r0). at(r0,1). runs(r0,s1). invocation(r1). at(r1,2). runs(r1,s1). edge(r0,r1,copy). does(r1,ok).
act_name(ok,approve).
reject(ended_by(g2,3)). expect(live(g2,6)).
