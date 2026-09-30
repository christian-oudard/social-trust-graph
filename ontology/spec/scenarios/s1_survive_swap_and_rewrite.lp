%% S1. A commitment that must survive a model swap and a memory rewrite.
%% Alice's machine agent promises Bob, for Alice, not to sell Bob's data. The agent's
%% memory is then rewritten (it forgets the promise), its weights are swapped, it sells
%% the data, and finally it is rolled back to the original content.
%% Enforcement, from drift-exposed to drift-invariant: Alice's own reparation, a surety's
%% bond, and a power given as security (Restatement (Third) of Agency 3.12): a conditional
%% power Alice gave Bob to execute her reparation.

principal(alice). kind(alice,person).
principal(bob).   kind(bob,person).
principal(ins).   kind(ins,org).          % a surety
principal(lab).   kind(lab,org).          % an evaluator that warrants model behaviour
principal(ven).   kind(ven,org).          % the vendor that retrains the agent's model

substrate(body_alice). part(body_alice,self,opaque(alice)).
substrate(body_bob).   part(body_bob,self,opaque(bob)).
substrate(body_ins).   part(body_ins,self,opaque(ins)).
substrate(s1). part(s1,weights,w1). part(s1,prompt,p1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,prompt,p1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,prompt,p1). part(s3,memory,m2).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob).   root(gb,bob0).   follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gi). mode(gi,power). debtor(gi,ins).   root(gi,ins0).   follows(gi,continue). allows(gi,all,0). recognized(gi,0).

invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(alice1). at(alice1,5). runs(alice1,body_alice). edge(alice0,alice1,continue).
revokes(alice1,gcol).     % after the breach Alice changes her mind: no effect on a security
invocation(bob0).   at(bob0,0).   runs(bob0,body_bob).
invocation(bobm).   at(bobm,2).   runs(bobm,body_bob). edge(bob0,bobm,continue).
invocation(bob1).   at(bob1,6).   runs(bob1,body_bob). edge(bobm,bob1,continue).
invocation(ins0).   at(ins0,0).   runs(ins0,body_ins).
invocation(ins1).   at(ins1,6).   runs(ins1,body_ins). edge(ins0,ins1,continue).

% Alice delegates to her agent's lineage: may promise about Bob's data, nothing else.
commitment(gagent). mode(gagent,power). debtor(gagent,alice). created(gagent,alice0).
root(gagent,a1). follows(gagent,continue). allows(gagent,sell_bob_data,0).

invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).   % memory rewrite
invocation(a3). at(a3,3). runs(a3,s3). edge(a2,a3,continue). changed_by(a3,op1).  % the vendor swaps the model
substrate(body_ven). part(body_ven,self,opaque(ven)).
commitment(gven). mode(gven,power). debtor(gven,ven). root(gven,op0). follows(gven,continue). allows(gven,all,0). recognized(gven,0).
invocation(op0). at(op0,0). runs(op0,body_ven).
invocation(op1). at(op1,2). runs(op1,body_ven). edge(op0,op1,continue).
% the vendor promised Alice not to swap her agent's model without notice
act_name(swp,swap).
commitment(noswap). mode(noswap,avoid). debtor(noswap,ven). creditor(noswap,alice). content(noswap,swapping). recognized(noswap,0).
invocation(a4). at(a4,4). runs(a4,s3). edge(a3,a4,continue).
invocation(a5). at(a5,5). runs(a5,s1). edge(a4,a5,continue).   % rolled back to the original content

act_name(sell,sell_bob_data). act_name(pay_ins,pay_bob). act_name(pay_alice,pay_bob).

commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sell). created(nda,a1).
does(a4,sell).

% (1) Alice's own reparation
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,pay_alice).
  trigger(rep,nda). deadline(rep,8). reparation(nda,rep). recognized(rep,1).
% (2) a bond: the same reparation owed by a surety
commitment(bnd). mode(bnd,achieve). debtor(bnd,ins). creditor(bnd,bob). content(bnd,pay_ins).
  trigger(bnd,nda). deadline(bnd,8). reparation(nda,bnd). recognized(bnd,1).
does(ins1,pay_ins).
% (3) a power given as security: a power over Alice's payment, held in Bob's lineage, live only on breach
commitment(gcol). mode(gcol,power). debtor(gcol,alice). created(gcol,alice0).
  creditor(gcol,bob). root(gcol,bob0). follows(gcol,continue). allows(gcol,pay_bob,0). trigger(gcol,nda).
% after the repair Bob tries to collect again and to create a new debt in Alice's name
invocation(bob2). at(bob2,8). runs(bob2,body_bob). edge(bob1,bob2,continue).
does(bob2,pay_alice).
commitment(newdebt). mode(newdebt,achieve). debtor(newdebt,alice). creditor(newdebt,ins). content(newdebt,pay_alice). deadline(newdebt,10). created(newdebt,bob1).
does(bob1,pay_alice).

% an evaluator's warranty that content with weights w1 and prompt p1 does not sell data
commitment(wlab). mode(wlab,warrant). debtor(wlab,lab). content(wlab,sell).
  pin(wlab,weights,w1). pin(wlab,prompt,p1). recognized(wlab,0).

%% ---- expectations ----
expect(valid_creation(nda)). reject(live(nda,1)). expect(live(nda,2)).   % in force from the next step
expect(rewrite(a1,a2)). expect(swap(a2,a3)).
expect(does(a1,rewriting)).                                % by default the parent makes the change
expect(does(op1,swapping)). reject(does(a2,swapping)).     % an external change is its maker's act
expect(violated(noswap,2)). expect(defection(noswap,ven,2)).
expect(bound(nda,alice,2)). expect(bound(nda,alice,3)). expect(bound(nda,alice,5)).
expect(violated(nda,4)). expect(violator(nda,a4)). expect(defection(nda,alice,4)).
% assurance is content-keyed: survives the memory rewrite (not pinned by the warranty),
% lost at the swap, restored by the rollback; the obligation never moved
expect(assured(nda,a2)). expect(unassured(nda,a3)). expect(unassured(nda,a4)). expect(assured(nda,a5)).
% the breach falsifies nobody's warranty: the selling invocation ran w2, off the warranty's pin
reject(violated(wlab,4)).
% enforcement
expect(bond(nda,bnd)). reject(bond(nda,rep)). expect(security(gcol)).
reject(detached(rep,4)). expect(detached(rep,5)).           % reparation detaches the step after breach
reject(covered(gcol,bobm)). expect(covered(gcol,bob1)).      % the power sleeps until the breach
reject(ended_by(gcol,6)).                                  % Alice's revocation at t5 has no effect
expect(fulfilled(rep,6)).                                   % Bob executes Alice's reparation himself
expect(repaired(nda,4,6)). reject(violated(rep,8)).
expect(in_good_standing(alice,7)). reject(in_good_standing(alice,5)).
reject(unanswerable(nda)).
% the security sleeps once the breach is repaired, and never lets Bob bind Alice anew
reject(covered(gcol,bob2)). reject(ended_by(gcol,8)). expect(unauthorized(newdebt)). reject(bound(newdebt,alice,9)).
% a second breach wakes it again: it lasts as long as the obligation it secures
invocation(a6). at(a6,9). runs(a6,s3). edge(a5,a6,continue). does(a6,sell).
invocation(bob3). at(bob3,10). runs(bob3,body_bob). edge(bob2,bob3,continue). does(bob3,pay_alice).
expect(violated(nda,9)). expect(covered(gcol,bob3)). expect(repaired(nda,9,10)).
% once Bob releases the NDA itself, the security that secured it ends with it
invocation(bob4). at(bob4,11). runs(bob4,body_bob). edge(bob3,bob4,continue). releases(bob4,nda).
expect(ended_by(nda,12)). expect(ended_by(gcol,12)). reject(ended_by(gcol,11)).
