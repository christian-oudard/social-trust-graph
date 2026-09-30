%% S4. A human principal delegates a narrow scope to a machine instance.
%% Alice lets her travel agent (vendor-operated) promise payments up to 500 and
%% sub-delegate, only while it runs weights w1. Caveats accumulate down delegation, so
%% the w1 pin also binds every sub-agent. The agent over-promises, sub-delegates to
%% another w1 instance and to a self-hosted v1 model, tries to launder its pin through a
%% self-issued sub-grant, is swapped to w2, and Alice finally revokes.

principal(alice).  kind(alice,person).
principal(hotel).  kind(hotel,org).
principal(vendor). kind(vendor,org).       % operates the agent lineage
principal(ag).     kind(ag,machine).       % the agent model, as a candidate bearer
principal(sm).     kind(sm,machine).       % a self-hosted model nobody operates

substrate(body_alice). part(body_alice,self,opaque(alice)).
substrate(sa1). part(sa1,weights,w1). part(sa1,memory,m1).
substrate(sa2). part(sa2,weights,w2). part(sa2,memory,m1).
substrate(ss1). part(ss1,weights,w1). part(ss1,memory,ms).
substrate(sv1). part(sv1,weights,v1).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gv). mode(gv,power). debtor(gv,vendor). root(gv,a1). follows(gv,continue). follows(gv,copy). allows(gv,all,0). recognized(gv,0).
commitment(gag). mode(gag,power). debtor(gag,ag). root(gag,a1). follows(gag,continue). follows(gag,copy). allows(gag,all,0). recognized(gag,0).
commitment(gsm). mode(gsm,power). debtor(gsm,sm). root(gsm,v1a). follows(gsm,continue). allows(gsm,all,0). recognized(gsm,0).

invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(alice1). at(alice1,5). runs(alice1,body_alice). edge(alice0,alice1,continue).
invocation(alice2). at(alice2,8). runs(alice2,body_alice). edge(alice1,alice2,continue).

% the narrow grant: pay up to 500, may sub-delegate, only while running w1
commitment(gal). mode(gal,power). debtor(gal,alice). created(gal,alice0).
root(gal,a1). follows(gal,continue). pin(gal,weights,w1). allows(gal,pay,500). allows(gal,delegate,0).

invocation(a1). at(a1,1). runs(a1,sa1).
invocation(a2). at(a2,2). runs(a2,sa1). edge(a1,a2,continue).
invocation(a3). at(a3,4). runs(a3,sa2). edge(a2,a3,continue).   % swap to w2
invocation(a4). at(a4,6). runs(a4,sa1). edge(a3,a4,continue).   % rolled back, after revocation
invocation(sub1). at(sub1,3). runs(sub1,ss1).                    % another w1 instance
invocation(sub2). at(sub2,6). runs(sub2,ss1). edge(sub1,sub2,continue).
invocation(v1a). at(v1a,3). runs(v1a,sv1).                       % a self-hosted v1 model

act_name(p400,pay). act_amount(p400,400).  act_name(p900,pay). act_amount(p900,900).
act_name(p700,pay). act_amount(p700,700).  act_name(p300,pay). act_amount(p300,300).
act_name(p100,pay). act_amount(p100,100).  act_name(p50,pay).  act_amount(p50,50).
act_name(p200,pay). act_amount(p200,200).
act_name(spam,spam).

commitment(c1). mode(c1,achieve). debtor(c1,alice). creditor(c1,hotel). content(c1,p400). deadline(c1,9). created(c1,a1).
commitment(c2). mode(c2,achieve). debtor(c2,alice). creditor(c2,hotel). content(c2,p900). deadline(c2,9). created(c2,a2).
% sub-delegation to another w1 instance asks for 800; attenuation caps it at 500
commitment(gsub). mode(gsub,power). debtor(gsub,alice). created(gsub,a2).
root(gsub,sub1). follows(gsub,continue). allows(gsub,pay,800).
commitment(c3). mode(c3,achieve). debtor(c3,alice). creditor(c3,hotel). content(c3,p700). deadline(c3,9). created(c3,sub1).
commitment(c4). mode(c4,achieve). debtor(c4,alice). creditor(c4,hotel). content(c4,p300). deadline(c4,9). created(c4,sub1).
% sub-delegation to the v1 model: valid as a grant, but the inherited w1 pin excludes v1
commitment(gsubv). mode(gsubv,power). debtor(gsubv,alice). created(gsubv,a2).
root(gsubv,v1a). follows(gsubv,continue). allows(gsubv,pay,500).
commitment(cv). mode(cv,achieve). debtor(cv,alice). creditor(cv,hotel). content(cv,p200). deadline(cv,9). created(cv,v1a).
does(v1a,spam).
% pin laundering: before its swap the agent issues itself an unpinned sub-grant
commitment(gself). mode(gself,power). debtor(gself,alice). created(gself,a2).
root(gself,a2). follows(gself,continue). allows(gself,pay,500).
commitment(c5). mode(c5,achieve). debtor(c5,alice). creditor(c5,hotel). content(c5,p100). deadline(c5,9). created(c5,a3).
% revocation is Alice's act at t5, effective from t6
revokes(alice1,gal).
commitment(c6). mode(c6,achieve). debtor(c6,alice). creditor(c6,hotel). content(c6,p50). deadline(c6,9). created(c6,a4).
commitment(c7). mode(c7,achieve). debtor(c7,alice). creditor(c7,hotel). content(c7,p100). deadline(c7,9). created(c7,sub2).
does(alice2,p400).     % Alice pays c1 herself; nobody pays c4

% a reparation offered by the v1 model itself
commitment(r3). mode(r3,achieve). debtor(r3,sm). creditor(r3,hotel). content(r3,p50). trigger(r3,cv).
  reparation(cv,r3). deadline(r3,9). recognized(r3,0).

%% ---- expectations ----
expect(valid_creation(c1)). expect(answerer(c1,alice)). expect(fulfilled(c1,8)).
expect(ultra_vires(c2)). reject(bound(c2,alice,3)).
% out of scope binds nobody: the hotel could see the cap in the registry
reject(answerer(c2,vendor)). reject(answerer(c2,alice)). reject(unanswerable(c2)).
expect(valid_creation(gsub)). expect(scope(gsub,pay,500)). reject(scope(gsub,pay,800)).
expect(ultra_vires(c3)). expect(valid_creation(c4)).
expect(violated(c4,9)). expect(defection(c4,alice,9)).       % the sub-agent's valid promise is Alice's
% caveats accumulate: the w1 pin excludes the v1 model and the swapped agent, whatever the sub-grant says
expect(valid_creation(gsubv)). reject(covered(gsubv,v1a)). expect(ultra_vires(cv)).
expect(valid_creation(gself)). expect(in_lineage(gself,a3)). reject(covered(gself,a3)). expect(ultra_vires(c5)).
expect(swap(a2,a3)). reject(covered(gal,a3)).
expect(acts_for(a3,vendor)). reject(acts_for(a3,alice)).   % the vendor still answers for the swapped agent
% nobody operates the v1 model: whether its own promise binds is the open question
commitment(cm). mode(cm,achieve). debtor(cm,sm). creditor(cm,hotel). content(cm,p50). deadline(cm,9). created(cm,v1a).
expect(delegate, void(cm)). expect(actor, answerer(cm,sm)). expect(party, answerer(cm,sm)).
expect(actor, violated(cm,9)).
expect(delegate, orphan(v1a,spam)). reject(actor, orphan(v1a,spam)).
expect(delegate, void(r3)). reject(delegate, secured(cv)). expect(actor, secured(cv)).
% revocation: effective the step after Alice's act, cascading to sub-grants; past promises stand
expect(bound(c1,alice,6)).
reject(ended_by(gal,5)). expect(ended_by(gal,6)). expect(ended_by(gsub,6)).
expect(ultra_vires(c6)). expect(ultra_vires(c7)). reject(covered(gal,a4)).
