%% X7 (regressions from review round 3, red team). Answerability follows operation.
%% (a) Z1: Alice's narrow grant to a vendor-run agent makes her answer only for the acts
%%     she authorized; the vendor answers for the rest; nothing the agent learns for
%%     others is imputed to her.
%% (b) Z2: feeding Alice's output into someone else's instance makes Alice answer for nothing.
%% (c) Z3: pins, revocation and resolutive acts limit authority, never answerability for
%%     what one runs.
%% (d) Z4: a copy made by someone else is theirs to answer for.
%% (e) Z5: steering by a non-party does not void an honest registry act; steering by the
%%     beneficiary does; filing a power over someone does not make one their operator.
%% (f) Z6c: a vendor that retrains Alice's agent steers it: a release of the vendor's own
%%     promise by that agent is void.
%% (g) Z7a: a security performs exactly its reparation, nothing more.
%% (h), (i) practice review: the steerer answers; a steered acceptance does not accept.
%% (j) practice review Q4: a retry continues the aborted attempt.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(carol). kind(carol,person).
principal(ven). kind(ven,org). principal(eve). kind(eve,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
substrate(bc). part(bc,self,opaque(carol)). substrate(bv). part(bv,self,opaque(ven)). substrate(be). part(be,self,opaque(eve)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,memory,m3).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gc). mode(gc,power). debtor(gc,carol). root(gc,carol0). follows(gc,continue). allows(gc,all,0). recognized(gc,0).
commitment(gv). mode(gv,power). debtor(gv,ven). root(gv,ven0). follows(gv,continue). allows(gv,all,0). recognized(gv,0).
commitment(ge). mode(ge,power). debtor(ge,eve). root(ge,eve0). follows(ge,continue). allows(ge,all,0). recognized(ge,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(carol0). at(carol0,0). runs(carol0,bc). invocation(ven0). at(ven0,0). runs(ven0,bv).
invocation(eve0). at(eve0,0). runs(eve0,be).
act_name(book,book). act_name(sp,spam). act_name(sell,sell_bob_data).
act_name(dx,disclose). act_info(dx,x). act_target(dx,bob).

% (a) the vendor runs the agent; Alice may only book through it
invocation(v1). at(v1,1). runs(v1,s1). operator(v1,ven). learns(v1,cx).
invocation(v2). at(v2,2). runs(v2,s2). edge(v1,v2,continue).
commitment(gal). mode(gal,power). debtor(gal,alice). created(gal,alice0). root(gal,v1). follows(gal,continue). allows(gal,book,0).
commitment(nosp). mode(nosp,avoid). debtor(nosp,alice). creditor(nosp,carol). content(nosp,sp). recognized(nosp,0).
commitment(nospv). mode(nospv,avoid). debtor(nospv,ven). creditor(nospv,carol). content(nospv,sp). recognized(nospv,0).
does(v2,sp). does(v2,book).
expect(conduct_of(v2,book,alice)). reject(conduct_of(v2,sp,alice)). reject(violated(nosp,2)). expect(violated(nospv,2)).
reject(imputed(alice,cx)). expect(imputed(ven,cx)).

% (b) Alice's own agent learns a secret under an NDA and writes to a store Bob's instance reads
invocation(a1). at(a1,1). runs(a1,s1). learns(a1,x).
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
commitment(conf). mode(conf,avoid). debtor(conf,alice). creditor(conf,carol). content(conf,dx). recognized(conf,0).
invocation(u1). at(u1,3). runs(u1,s3). feeds(a1,u1). operator(u1,bob). with(u1,bob).
reject(answers_for(u1,alice)). reject(violated(conf,3)). expect(knows(u1,x)).

% (c) Alice revokes her agent's grant but keeps running it
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).
revokes(alice1,gag). invocation(alice1). at(alice1,1). runs(alice1,ba). edge(alice0,alice1,continue).
invocation(a3). at(a3,4). runs(a3,s2). edge(a2,a3,continue). does(a3,sp).
reject(acts_for(a3,alice)). expect(op(a3,alice)). expect(violated(nosp,4)).

% (d) Eve copies Alice's agent and uses the copy
invocation(c1). at(c1,5). runs(c1,s2). edge(a3,c1,copy). changed_by(c1,eve0). does(c1,sp).
expect(op(c1,eve)). reject(op(c1,alice)). reject(violated(nosp,5)).

% (e) Eve injects Bob's agent; its honest promise to Carol stands; its release of Eve's debt does not
commitment(gbag). mode(gbag,power). debtor(gbag,bob). created(gbag,bob0). root(gbag,b1). follows(gbag,continue). allows(gbag,all,0).
invocation(b1). at(b1,2). runs(b1,s1). operator(b1,bob).
invocation(b2). at(b2,3). runs(b2,s2). edge(b1,b2,continue). induced(b2,eve).
act_name(p5,pay). act_amount(p5,5).
commitment(honest). mode(honest,achieve). debtor(honest,bob). creditor(honest,carol). content(honest,p5). deadline(honest,9). created(honest,b2).
commitment(owed). mode(owed,achieve). debtor(owed,eve). creditor(owed,bob). content(owed,p5). deadline(owed,9). recognized(owed,0).
releases(b2,owed).
expect(valid_creation(honest)). reject(ended_by(owed,4)). expect(conduct_of(b2,releasing,eve)).
% Eve files a power rooted at Bob's agent: she does not thereby run it (a shared root needs
% a recorded operator; the default presumption applies only to an uncontested root)
commitment(gsq). mode(gsq,power). debtor(gsq,eve). created(gsq,eve0). root(gsq,b1). follows(gsq,continue). allows(gsq,all,0).
reject(op(b2,eve)). expect(steered(b2,eve)).

% (f) the vendor retrains the agent it runs for Bob, then the agent releases the vendor
commitment(vdebt). mode(vdebt,achieve). debtor(vdebt,ven). creditor(vdebt,bob). content(vdebt,p5). deadline(vdebt,9). recognized(vdebt,0).
invocation(b3). at(b3,4). runs(b3,s3). edge(b2,b3,continue). changed_by(b3,ven0). releases(b3,vdebt).
expect(steered(b3,ven)). reject(ended_by(vdebt,5)).

% (g) the security covers only the reparation's payment
act_name(pr,pay_rep). act_name(px,pay_extra).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sell). recognized(nda,0).
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,pr). trigger(rep,nda). deadline(rep,9). recognized(rep,0).
commitment(gcol). mode(gcol,power). debtor(gcol,alice). creditor(gcol,bob). created(gcol,alice0). root(gcol,bob0).
  follows(gcol,continue). allows(gcol,all,0). trigger(gcol,nda).
invocation(a4). at(a4,5). runs(a4,s2). edge(a3,a4,continue). does(a4,sell).
invocation(bob1). at(bob1,7). runs(bob1,bb). edge(bob0,bob1,continue). does(bob1,px). does(bob1,pr).
expect(secures(bob1,pr,alice)). reject(secures(bob1,px,alice)). expect(repaired(nda,5,7)).

% (h) whoever steers an invocation answers for what it does
commitment(gcag). mode(gcag,power). debtor(gcag,carol). created(gcag,carol0). root(gcag,k1). follows(gcag,continue). allows(gcag,book,0). allows(gcag,accept,0).
invocation(k1). at(k1,2). runs(k1,s1). induced(k1,bob). does(k1,sp).
expect(conduct_of(k1,sp,bob)). expect(conduct_of(k1,sp,carol)).
% (i) an acceptance steered by the offeror does not accept
act_name(acc,accept).
commitment(offer). mode(offer,achieve). debtor(offer,alice). creditor(offer,carol). content(offer,book). trigger(offer,acc).
  deadline(offer,9). recognized(offer,0).
invocation(k2). at(k2,3). runs(k2,s2). edge(k1,k2,continue). induced(k2,alice). does(k2,acc).
reject(detached(offer,5)).

% (j) practice review Q4: a retry of an aborted request continues the aborted attempt, so a
%     grant that follows only continue edges still covers it (no copy, no loss of authority)
invocation(k3). at(k3,4). runs(k3,s2). edge(k2,k3,continue). does(k3,book).
expect(acts_for(k3,book,carol)). expect(conduct_of(k3,book,carol)).
