%% X8b (review round 3, formal: R6, R7). Offices.
%% (a) An office's duty "avoid trading until the results are published": the holder
%%     publishes, so the duty ends; her later trade breaches nothing.
principal(alice). kind(alice,person). principal(bob). kind(bob,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
invocation(alice0). at(alice0,0). runs(alice0,ba).
invocation(alice2). at(alice2,2). runs(alice2,ba). edge(alice0,alice2,continue). does(alice2,pub).
invocation(alice5). at(alice5,5). runs(alice5,ba). edge(alice2,alice5,continue). does(alice5,tr).
invocation(bob0). at(bob0,0). runs(bob0,bb).
role(treasurer). appointer(treasurer,bob). appoints(bob0,alice,treasurer,12).
commitment(gt). mode(gt,power). debtor(gt,treasurer). allows(gt,all,0). recognized(gt,0).
act_name(pub,publish). act_name(tr,trade).
commitment(nt). mode(nt,avoid). debtor(nt,treasurer). creditor(nt,bob). content(nt,tr). recognized(nt,0). until(nt,pub).
expect(holder(treasurer,alice,2)). expect(ended_by(nt,3)). reject(violated(nt,5)).

% (b) R7: the holder's own copy trades: the office's breach is the holder's, not unanswered
principal(alice). kind(alice,person). principal(bob). kind(bob,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)). substrate(s1). part(s1,weights,w1).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
role(clerk). appointer(clerk,bob). appoints(bob0,alice,clerk,12).
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
invocation(a1). at(a1,1). runs(a1,s1). invocation(a2). at(a2,3). runs(a2,s1). edge(a1,a2,copy). does(a2,tr).
act_name(tr,trade).
commitment(nc). mode(nc,avoid). debtor(nc,clerk). creditor(nc,bob). content(nc,tr). recognized(nc,0).
expect(violated(nc,3)). expect(defection(nc,alice,3)). reject(unanswered_breach(nc,3)).
