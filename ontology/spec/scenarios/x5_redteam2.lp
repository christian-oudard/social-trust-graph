%% X5 (regressions from review round 2, red team). Each exploit is now blocked.
%% (a) Securities cannot be killed by revoking an intermediate grant (cascade).
%% (b) Answerability is coverage, not scope: an agent allowed only to pay still makes a
%%     sale Alice's breach, and its out-of-scope copy's leak is Alice's too.
%% (c) Feeding passes knowledge, not answerability: Bob launched the instance he fed Alice's
%%     output into, so its leak is Bob's conduct, not Alice's (no griefing by feed).
%% (d) Feeding into another principal's agent does not frame the source.
%% (e) An injected invocation cannot release, permit or appoint.
%% (f) Caveats: a created 'all' grant is not a root; role powers need the holder's own
%%     authority; an act without an amount passes no cap.
%% (g) A security created by a pinned agent is the holder's, not pinned to the agent.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(q). kind(q,person).
principal(hotel). kind(hotel,org).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,memory,m3).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
invocation(alice0). at(alice0,0). runs(alice0,ba).
invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(bob1). at(bob1,6). runs(bob1,bb). edge(bob0,bob1,continue).
act_name(sell,sell_bob_data). act_name(payb,pay_bob). act_name(sp,spam).
act_name(dx,disclose). act_info(dx,x). act_target(dx,q).

% (a)
commitment(gmid). mode(gmid,power). debtor(gmid,alice). created(gmid,alice0). root(gmid,m0). follows(gmid,continue). allows(gmid,all,0).
invocation(m0). at(m0,1). runs(m0,s1).
invocation(m1). at(m1,4). runs(m1,s2). edge(m0,m1,continue).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sell). recognized(nda,0).
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,payb). trigger(rep,nda). deadline(rep,9). recognized(rep,0).
commitment(gcol). mode(gcol,power). debtor(gcol,alice). creditor(gcol,bob). created(gcol,m0). root(gcol,bob0). follows(gcol,continue).
  allows(gcol,pay_bob,0). trigger(gcol,nda).

invocation(alice2). at(alice2,2). runs(alice2,ba). edge(alice0,alice2,continue). revokes(alice2,gmid).

% (b)
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,pay,500).
invocation(a1). at(a1,2). runs(a1,s1). learns(a1,x).
invocation(a2). at(a2,3). runs(a2,s2). edge(a1,a2,continue). does(a2,sell).
invocation(a3). at(a3,4). runs(a3,s2). edge(a2,a3,copy). with(a3,q).
commitment(conf). mode(conf,avoid). debtor(conf,alice). creditor(conf,q). content(conf,dx). recognized(conf,0).
% (c)
invocation(fresh). at(fresh,5). runs(fresh,s3). with(fresh,q). operator(fresh,bob).
feeds(a2,fresh).
% (d)
commitment(gba). mode(gba,power). debtor(gba,bob). created(gba,bob0). root(gba,b1). follows(gba,continue). allows(gba,all,0).
invocation(b1). at(b1,1). runs(b1,s1).
invocation(b2). at(b2,4). runs(b2,s3). edge(b1,b2,continue). feeds(a2,b2). does(b2,sp).
commitment(nosp). mode(nosp,avoid). debtor(nosp,alice). creditor(nosp,bob). content(nosp,sp). recognized(nosp,0).
% (e) Alice injects Bob's agent into releasing her, permitting her, and appointing her
invocation(b3). at(b3,5). runs(b3,s3). edge(b2,b3,continue). induced(b3,alice).
commitment(k2). mode(k2,avoid). debtor(k2,alice). creditor(k2,bob). content(k2,sp). recognized(k2,0).
releases(b3,k2).
commitment(perm). mode(perm,permit). debtor(perm,bob). created(perm,b3). root(perm,a1). follows(perm,continue). allows(perm,spam,0).
role(desk). appointer(desk,bob). appoints(b3,alice,desk,12).
% (f)
invocation(k1). at(k1,1). runs(k1,s1).
commitment(gcap). mode(gcap,power). debtor(gcap,alice). created(gcap,alice0). root(gcap,k1). follows(gcap,continue). allows(gcap,pay,50).
act_name(pinv,pay).
commitment(inv). mode(inv,achieve). debtor(inv,alice). creditor(inv,hotel). content(inv,pinv). deadline(inv,9). created(inv,k1).
commitment(gsub). mode(gsub,power). debtor(gsub,alice). created(gsub,m0). root(gsub,m1). follows(gsub,continue). follows(gsub,copy). allows(gsub,all,0).

%% ---- expectations ----
expect(security(gcol)). expect(parent_grant(gcol,gmid)).
expect(ended_by(gmid,3)). reject(ended_by(gcol,4)). reject(ended_by(gcol,8)).
% (b)
reject(acts_for(a2,sell,alice)). expect(acts_for(a2,alice)). expect(violated(nda,3)). expect(defection(nda,alice,3)).
expect(op(a3,alice)). expect(violated(conf,4)).
% (c)
reject(answers_for(fresh,alice)). reject(violated(conf,5)). expect(conduct_of(fresh,dx,bob)). reject(orphan(fresh,dx)).
% (d)
reject(answers_for(b2,alice)). reject(violated(nosp,4)).
% (e)
expect(vitiated(b3,k2)). reject(ended_by(k2,6)). expect(unauthorized(perm)). reject(holder(desk,alice,7)).
% (f)
reject(within(gcap,pinv)). expect(unauthorized(inv)).
reject(eff_follows(gsub,copy)).
