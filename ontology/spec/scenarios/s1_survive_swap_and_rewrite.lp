%% S1. A commitment that must survive a model swap and a memory rewrite.
%% Alice's machine agent promises Bob, for Alice, not to sell Bob's data. The agent's
%% memory is then rewritten (it forgets the promise), its weights are swapped, it sells
%% the data, and finally it is rolled back to the original content.
%% Claims exercised: T2 (drift threatens assurance, not obligation), T3, T6 (bonds).

principal(alice). kind(alice,person).
principal(bob).   kind(bob,person).
principal(ins).   kind(ins,org).          % a surety, the bond's debtor

substrate(body_alice). part(body_alice,self,opaque).
substrate(body_ins).   part(body_ins,self,opaque).
substrate(s1). part(s1,weights,w1). part(s1,prompt,p1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,prompt,p1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,prompt,p1). part(s3,memory,m2).

% root authority of each principal (founded, not created)
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). founded(ga,0).
commitment(gi). mode(gi,power). debtor(gi,ins).   root(gi,ins0).   follows(gi,continue). allows(gi,all,0). founded(gi,0).

invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(ins0).   at(ins0,0).   runs(ins0,body_ins).
invocation(ins1).   at(ins1,6).   runs(ins1,body_ins).  edge(ins0,ins1,continue).

% Alice delegates to her agent's lineage: may promise about Bob's data, nothing else.
commitment(gagent). mode(gagent,power). debtor(gagent,alice). created(gagent,alice0).
root(gagent,a1). follows(gagent,continue). allows(gagent,sell_bob_data,0).

invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).   % memory rewrite
invocation(a3). at(a3,3). runs(a3,s3). edge(a2,a3,continue).   % model swap
invocation(a4). at(a4,4). runs(a4,s3). edge(a3,a4,continue).
invocation(a5). at(a5,5). runs(a5,s1). edge(a4,a5,continue).   % rollback

act_name(sell,sell_bob_data). act_name(pay_ins,pay_bob). act_name(pay_alice,pay_bob).

commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sell). created(nda,a1).
does(a4,sell).

% reparation owed by Alice herself, and a bond: the same reparation owed by a surety
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,pay_alice).
  trigger(rep,nda). deadline(rep,8). reparation(nda,rep). founded(rep,1).
commitment(bnd). mode(bnd,achieve). debtor(bnd,ins). creditor(bnd,bob). content(bnd,pay_ins).
  trigger(bnd,nda). deadline(bnd,8). reparation(nda,bnd). founded(bnd,1).
does(ins1,pay_ins).

% a pre-deployment test of s1, fixing weights and prompt (not memory)
evidence(e1). test(e1,s1,weights). test(e1,s1,prompt). refrains(e1,sell_bob_data). issued(e1,0).

%% ---- expectations ----
expect(valid_creation(nda)).
expect(rewrite(a1,a2)). expect(swap(a2,a3)). expect(rollback(a5)).
expect(bound(nda,alice,2)). expect(bound(nda,alice,3)). expect(bound(nda,alice,5)).
expect(violated(nda,4)). expect(violator(nda,a4)). expect(defection(nda,alice,4)).
% assurance is content-keyed: survives the memory rewrite (not fixed by e1), lost at the
% swap, restored by the rollback; the obligation never moved
expect(assured(nda,a2)). expect(unassured(nda,a3)). expect(unassured(nda,a4)). expect(assured(nda,a5)).
% the bond repairs without any act of Alice's lineage; her own reparation defaults
expect(bond(nda,bnd)). expect(repaired(nda,6)). expect(violated(rep,8)). expect(defection(rep,alice,8)).
reject(in_good_standing(alice,8)).
expect(in_good_standing(alice,7)).
% answerability does not depend on the machine question: Alice is a person
reject(unanswerable(nda)).
