%% S2. A commitment that must NOT survive a model swap.
%% Bob evaluated weights w1 and consented to Alice's agent processing his data, on his
%% behalf, only while it runs w1 (the sub-processor analog, GDPR Art. 28(2)). Alice owes
%% Bob a standing prohibition on processing his data. Consent is modelled as Bob's own
%% authority extended to the agent (a grant pinned to w1), not as a new primitive.
%% After a memory rewrite the consent still covers the agent; after a weight swap it
%% lapses by itself, and the same act becomes Alice's violation. A second, unpinned
%% consent from Carol survives the same swap.

principal(alice). kind(alice,person).
principal(bob).   kind(bob,person).
principal(carol). kind(carol,person).

substrate(body_alice). part(body_alice,self,opaque).
substrate(body_bob).   part(body_bob,self,opaque).
substrate(body_carol). part(body_carol,self,opaque).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,memory,m2).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). founded(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob).   root(gb,bob0).   follows(gb,continue). allows(gb,all,0). founded(gb,0).
commitment(gc). mode(gc,power). debtor(gc,carol). root(gc,carol0). follows(gc,continue). allows(gc,all,0). founded(gc,0).
invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(bob0).   at(bob0,0).   runs(bob0,body_bob).
invocation(carol0). at(carol0,0). runs(carol0,body_carol).

% Alice's agent acts for Alice generally
commitment(gagent). mode(gagent,power). debtor(gagent,alice). created(gagent,alice0).
root(gagent,a1). follows(gagent,continue). allows(gagent,all,0).

invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).   % memory rewrite
invocation(a3). at(a3,3). runs(a3,s3). edge(a2,a3,continue).   % model swap

act_name(pb,process_bob). act_name(pc,process_carol).
does(a1,pb). does(a2,pb). does(a3,pb).
does(a1,pc). does(a2,pc). does(a3,pc).

% standing prohibitions (founded: e.g. by law, not by any invocation)
commitment(nb). mode(nb,avoid). debtor(nb,alice). creditor(nb,bob).   content(nb,pb). founded(nb,0).
commitment(nc). mode(nc,avoid). debtor(nc,alice). creditor(nc,carol). content(nc,pc). founded(nc,0).

% Bob's consent: pinned to w1. Carol's consent: unpinned.
commitment(cb). mode(cb,power). debtor(cb,bob). created(cb,bob0).
root(cb,a1). follows(cb,continue). pin(cb,weights,w1). allows(cb,process_bob,0).
commitment(cc). mode(cc,power). debtor(cc,carol). created(cc,carol0).
root(cc,a1). follows(cc,continue). allows(cc,process_carol,0).

%% ---- expectations ----
expect(excused(nb,a1)). expect(excused(nb,a2)). reject(excused(nb,a3)).
expect(covered(cb,a2)). reject(covered(cb,a3)).
reject(violated(nb,1)). reject(violated(nb,2)). expect(violated(nb,3)).
expect(defection(nb,alice,3)).
expect(excused(nc,a3)). reject(violated(nc,3)).
% the swap did not touch Alice's own authority over her agent
expect(covered(gagent,a3)). expect(acts_for(a3,alice)).
% the swapped agent is not Bob's processor: nothing it does is attributed to Bob
reject(acts_for(a3,pb,bob)). expect(acts_for(a2,pb,bob)). expect(acts_for(a3,pb2,bob)).

%% ---- S2b. Debtor-side forms of the same pin mechanism ----
% (i) a version warranty: Alice warrants to Carol that her agent, while on w1, will not
%     emit unsafe output. After the swap, unsafe output is not a breach of THIS promise.
% (ii) a performer-specific duty: the audit must be produced by w1 (Carol's substantial
%     interest in the performer, Restatement (Second) 318(2)). The swapped agent's audit
%     does not count, so the duty is violated at its deadline (self-induced impossibility).
% (iii) a change envelope: a second consent from Bob, pinned to {w1, w2}, survives the swap.
act_name(unsafe,unsafe). act_name(audit,audit). act_name(pb2,process_bob2).

does(a3,unsafe). does(a3,audit). does(a3,pb2).
commitment(war). mode(war,avoid). debtor(war,alice). creditor(war,carol). content(war,unsafe).
  pin(war,weights,w1). founded(war,0).
commitment(aud). mode(aud,achieve). debtor(aud,alice). creditor(aud,carol). content(aud,audit).
  pin(aud,weights,w1). deadline(aud,5). founded(aud,0).
commitment(nb2). mode(nb2,avoid). debtor(nb2,alice). creditor(nb2,bob). content(nb2,pb2). founded(nb2,0).
commitment(cb2). mode(cb2,power). debtor(cb2,bob). created(cb2,bob0).
  root(cb2,a1). follows(cb2,continue). pin(cb2,weights,w1). pin(cb2,weights,w2). allows(cb2,process_bob2,0).

reject(violated(war,3)). expect(off_pin(war,a3)).
reject(fulfilled(aud,5)). expect(violated(aud,5)). expect(defection(aud,alice,5)).
expect(covered(cb2,a3)). expect(excused(nb2,a3)). reject(violated(nb2,3)).
