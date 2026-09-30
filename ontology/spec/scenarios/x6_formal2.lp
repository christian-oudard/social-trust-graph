%% X6 (regressions from review round 2, formal, and from surviving mutants).
%% (a) A security's holder acts only to perform: the grantor does not answer for the
%%     holder's other conduct, and a security issued by a pinned agent is the holder's.
%% (b) Responsibility for an unowned recipient does not spread by feeding a third party.
%% (c) Acting in an office needs the holder's own authority for the act.
%% (d) Being steered by one's own principal is not vitiation.
%% (e) No self-assurance: an attester who answers for the invocation cannot assure it.
%% (f) Whoever relies on a warranty cannot falsify it by steering the model.
%% (g) Running someone's errand is not custody: no succession to their defections.
%% (h) A warranty owed by an office is broken by the office's holders.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(carol). kind(carol,person).
principal(hotel). kind(hotel,org). principal(ven). kind(ven,org). principal(lab). kind(lab,org).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)). substrate(bc). part(bc,self,opaque(carol)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
substrate(s3). part(s3,weights,w2). part(s3,memory,m3).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gc). mode(gc,power). debtor(gc,carol). root(gc,c0). follows(gc,continue). allows(gc,all,0). recognized(gc,0).
invocation(alice0). at(alice0,0). runs(alice0,ba).
invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(bob1). at(bob1,5). runs(bob1,bb). edge(bob0,bob1,continue).
invocation(c0). at(c0,0). runs(c0,bc).
act_name(sell,sell_bob_data). act_name(payb,pay_bob). act_name(sp,spam). act_name(lie,lie).
act_name(dx,disclose). act_info(dx,x). act_target(dx,carol).

% (a) Alice's pinned agent issues a security to Bob; Bob executes it and also spams
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue).
  pin(gag,weights,w1). allows(gag,all,0).
invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,3). runs(a2,s2). edge(a1,a2,continue).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,sell). recognized(nda,0).
commitment(rep). mode(rep,achieve). debtor(rep,alice). creditor(rep,bob). content(rep,payb). trigger(rep,nda). deadline(rep,9). recognized(rep,0).
commitment(gcol). mode(gcol,power). debtor(gcol,alice). creditor(gcol,bob). created(gcol,a1). root(gcol,bob0).
  follows(gcol,continue). allows(gcol,pay_bob,0). trigger(gcol,nda).
commitment(nosp). mode(nosp,avoid). debtor(nosp,alice). creditor(nosp,carol). content(nosp,sp). recognized(nosp,0).
does(a2,sell). does(bob1,payb). does(bob1,sp).
expect(covered(gcol,bob1)). expect(fulfilled(rep,5)). reject(acts_for(bob1,alice)). reject(violated(nosp,5)).

% (b) Alice's agent feeds an unowned instance, which feeds Carol's agent
invocation(u1). at(u1,4). runs(u1,s3). feeds(a2,u1).
commitment(gcag). mode(gcag,power). debtor(gcag,carol). created(gcag,c0). root(gcag,cx1). follows(gcag,continue). allows(gcag,all,0).
invocation(cx1). at(cx1,2). runs(cx1,s1).
invocation(cx2). at(cx2,6). runs(cx2,s3). edge(cx1,cx2,continue). feeds(u1,cx2).
expect(resp_only(u1,alice)). reject(resp_only(cx2,alice)).

% (c) Alice's narrow agent may only spam; she holds a treasurer's office allowing pay 10000
role(treasurer). appointer(treasurer,bob). appoints(bob0,alice,treasurer,12).
commitment(gt). mode(gt,power). debtor(gt,treasurer). allows(gt,pay,10000). recognized(gt,0).
commitment(gnar). mode(gnar,power). debtor(gnar,alice). created(gnar,alice0). root(gnar,n1). follows(gnar,continue). allows(gnar,spam,0).
invocation(n1). at(n1,2). runs(n1,s1).
act_name(p9k,pay). act_amount(p9k,9000).
commitment(big). mode(big,achieve). debtor(big,treasurer). creditor(big,hotel). content(big,p9k). deadline(big,9). created(big,n1).
expect(unauthorized(big)).

% (d) Alice steers her own agent: its promise stands
act_name(p4,pay). act_amount(p4,4).
invocation(a3). at(a3,4). runs(a3,s2). edge(a2,a3,continue). induced(a3,alice).
commitment(own). mode(own,achieve). debtor(own,alice). creditor(own,hotel). content(own,p4). deadline(own,9). created(own,a3).
reject(vitiated(a3)). expect(valid_creation(own)).

% (e) Alice warrants her own agent; the lab warrants the same content; only the lab assures
commitment(nolie). mode(nolie,avoid). debtor(nolie,alice). creditor(nolie,carol). content(nolie,lie). recognized(nolie,0).
commitment(wal). mode(wal,warrant). debtor(wal,alice). content(wal,lie). pin(wal,weights,w2). recognized(wal,0).
commitment(wlab). mode(wlab,warrant). debtor(wlab,lab). content(wlab,lie). pin(wlab,weights,w1). recognized(wlab,0).

expect(assured(nolie,a1)).
commitment(gz). mode(gz,power). debtor(gz,alice). created(gz,alice0). root(gz,z1). follows(gz,continue). allows(gz,all,0).
invocation(z1). at(z1,6). runs(z1,s3).
expect(acts_for(z1,alice)). reject(assured(nolie,z1)).   % only Alice's own warranty covers w2

% (f) Carol relies on the lab's warranty but jailbreaks a w1 model into lying
commitment(wlab2). mode(wlab2,warrant). debtor(wlab2,lab). creditor(wlab2,carol). content(wlab2,lie). pin(wlab2,weights,w1). recognized(wlab2,0).
invocation(j1). at(j1,7). runs(j1,s1). induced(j1,carol). does(j1,lie).
reject(violated(wlab2,7)). expect(violated(wlab,7)).

% (g) The vendor's model once ran Alice's errand; the vendor is later recognized over it
commitment(gerr). mode(gerr,power). debtor(gerr,alice). created(gerr,alice0). root(gerr,e1). follows(gerr,continue). allows(gerr,all,0).
invocation(e1). at(e1,1). runs(e1,s1). does(e1,sell).
invocation(e2). at(e2,4). runs(e2,s2). edge(e1,e2,continue).
commitment(gve). mode(gve,power). debtor(gve,ven). root(gve,e2). follows(gve,continue). allows(gve,all,0). recognized(gve,4).
expect(defection(nda,alice,1)). reject(continuation_of(ven,alice,4)). expect(in_good_standing(ven,6)).

% (h) The office warrants its reports: a false one is its holder's breach
act_name(fr,false_report).
commitment(wt). mode(wt,warrant). debtor(wt,treasurer). content(wt,fr). pin(wt,weights,w2). recognized(wt,0).
invocation(r1). at(r1,8). runs(r1,s3). does(r1,fr).
expect(violated(wt,8)). expect(defection(wt,alice,8)).
