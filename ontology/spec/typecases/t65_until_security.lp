%% A security with a resolutive condition: it would end on something other than its obligation.
expect_error(65).
principal(alice). kind(alice,person). principal(bob). kind(bob,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
act_name(pay,pay_bob). act_name(sx,sell).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sx). recognized(nda,0).
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,pay). deadline(rep,9).
  trigger(rep,nda). reparation(nda,rep). recognized(rep,0).
commitment(gcol). mode(gcol,power). debtor(gcol,alice). created(gcol,alice0). creditor(gcol,bob).
  root(gcol,bob0). follows(gcol,continue). allows(gcol,pay_bob,0). trigger(gcol,nda). until(gcol,sx).
