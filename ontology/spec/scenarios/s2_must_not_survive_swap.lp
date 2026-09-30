%% S2. A commitment that must NOT survive a model swap.
%% Bob evaluated weights w1 and permitted Alice's agent to process his data only while it
%% runs w1 (the sub-processor analog, GDPR Art. 28(2)). Alice owes Bob a standing
%% prohibition on processing his data. Bob's consent is a PERMIT: it shares a grant's
%% scope fields (root, follows, pins, allows) but its only effect is to excuse. It does
%% not make the agent Bob's agent, so Bob neither answers for it nor knows what it knows.
%% After a memory rewrite the permit still covers the agent; after a weight swap it lapses
%% by itself, and the same act becomes Alice's violation. Carol's unpinned permit survives.

principal(alice). kind(alice,person).
principal(bob).   kind(bob,person).
principal(carol). kind(carol,person).

substrate(body_alice). part(body_alice,self,opaque(alice)).
substrate(body_bob).   part(body_bob,self,opaque(bob)).
substrate(body_carol). part(body_carol,self,opaque(carol)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,memory,m2).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob).   root(gb,bob0).   follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gc). mode(gc,power). debtor(gc,carol). root(gc,carol0). follows(gc,continue). allows(gc,all,0). recognized(gc,0).
invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(bob0).   at(bob0,0).   runs(bob0,body_bob).
invocation(carol0). at(carol0,0). runs(carol0,body_carol).

% Alice's agent acts for Alice generally
commitment(gagent). mode(gagent,power). debtor(gagent,alice). created(gagent,alice0).
root(gagent,a1). follows(gagent,continue). allows(gagent,all,0).

invocation(a1). at(a1,1). runs(a1,s1). learns(a1,alice_secret).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).   % memory rewrite
invocation(a3). at(a3,3). runs(a3,s3). edge(a2,a3,continue).   % model swap

act_name(pb,process_bob). act_name(pc,process_carol).
does(a1,pb). does(a2,pb). does(a3,pb).
does(a1,pc). does(a2,pc). does(a3,pc).

% standing prohibitions (recognized: imposed by law, not made by any invocation)
commitment(nb). mode(nb,avoid). debtor(nb,alice). creditor(nb,bob).   content(nb,pb). recognized(nb,0).
commitment(nc). mode(nc,avoid). debtor(nc,alice). creditor(nc,carol). content(nc,pc). recognized(nc,0).

% Bob's permit: pinned to w1. Carol's permit: unpinned.
commitment(cb). mode(cb,permit). debtor(cb,bob). created(cb,bob0).
root(cb,a1). follows(cb,continue). pin(cb,weights,w1). allows(cb,process_bob,0).
commitment(cc). mode(cc,permit). debtor(cc,carol). created(cc,carol0).
root(cc,a1). follows(cc,continue). allows(cc,process_carol,0).

%% ---- expectations ----
expect(excused(nb,a1)). expect(excused(nb,a2)). reject(excused(nb,a3)).
expect(covered(cb,a2)). reject(covered(cb,a3)).
reject(violated(nb,1)). reject(violated(nb,2)). expect(violated(nb,3)).
expect(defection(nb,alice,3)).
expect(excused(nc,a3)). reject(violated(nc,3)).
% the swap did not touch Alice's own authority over her agent
expect(covered(gagent,a3)). expect(acts_for(a3,alice)).
% consenting is not appointing: Bob answers for nothing and knows nothing
reject(acts_for(a1,bob)). reject(acts_for(a2,pb,bob)). expect(permitted(a2,pb,bob)).
reject(imputed(bob,alice_secret)). expect(imputed(alice,alice_secret)).

%% ---- S2b. Debtor-side forms of the same pin mechanism ----
% (i) a version warranty: Alice promises Carol that her agent, while on w1, will not
%     emit unsafe output. After the swap, unsafe output is not a breach of THIS promise.
% (ii) a performer-specific duty: the audit must be produced by w1 (Carol's substantial
%     interest in the performer, Restatement (Second) 318(2)). The swapped agent's audit
%     does not count, so the duty is violated at its deadline (self-induced impossibility).
% (iii) a change envelope: a second permit from Bob covering two tested configurations,
%     {w1, m1} and {w2, m2}, survives this swap, but not the untested mix {w2, m1}.
act_name(unsafe,unsafe). act_name(audit,audit). act_name(pb2,process_bob2).
substrate(s4). part(s4,weights,w2). part(s4,memory,m1).
invocation(a4). at(a4,4). runs(a4,s4). edge(a3,a4,continue).  % memory restored under w2
does(a3,unsafe). does(a3,audit). does(a3,pb2). does(a4,pb2).
commitment(war). mode(war,avoid). debtor(war,alice). creditor(war,carol). content(war,unsafe).
  pin(war,weights,w1). recognized(war,0).
commitment(aud). mode(aud,achieve). debtor(aud,alice). creditor(aud,carol). content(aud,audit).
  pin(aud,weights,w1). deadline(aud,5). recognized(aud,0).
commitment(nb2). mode(nb2,avoid). debtor(nb2,alice). creditor(nb2,bob). content(nb2,pb2). recognized(nb2,0).
commitment(cb2). mode(cb2,permit). debtor(cb2,bob). created(cb2,bob0).
  root(cb2,a1). follows(cb2,continue). allows(cb2,process_bob2,0).
  pin(cb2,k1,weights,w1). pin(cb2,k1,memory,m1). pin(cb2,k2,weights,w2). pin(cb2,k2,memory,m2).

reject(violated(war,3)). expect(off_pin(war,a3)).
reject(fulfilled(aud,5)). expect(violated(aud,5)). expect(defection(aud,alice,5)).
expect(covered(cb2,a1)). expect(covered(cb2,a3)). expect(excused(nb2,a3)). reject(violated(nb2,3)).
reject(covered(cb2,a4)). expect(violated(nb2,4)).
