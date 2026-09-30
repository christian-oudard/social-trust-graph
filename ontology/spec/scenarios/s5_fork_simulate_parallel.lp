%% S5. A party that forks, simulates its counterparty, and runs parallel negotiations
%% that share learning.
%% Nia (naive): one custody grant follows copies. Two forks sell the same unique item to
%% Q1 and Q2, then merge to share what they learned, carrying Q1's secret to Q2. Nia also
%% runs Q1's published weights as a simulation, extracts a "promise", and warrants what
%% the simulation showed. She rolls back and re-offers, and her negotiator is prompt-
%% injected by Q2.
%% Ola (partitioned): custody does not follow copies; each fork gets an explicit sub-grant
%% with a disjoint scope; learning is shared only through content Ola warrants sanitized.
%% Ola also probes Q2 from a copy that nothing authorizes.

principal(nia). kind(nia,org).
principal(ola). kind(ola,org).
principal(q1). kind(q1,org).
principal(q2). kind(q2,org).
principal(mo). kind(mo,machine).

substrate(sq).  part(sq,weights,wq). part(sq,memory,mq).     % Q1's negotiator, open weights
substrate(sq2). part(sq2,weights,wq2).
substrate(sn).  part(sn,weights,wn). part(sn,memory,mn0).
substrate(sn1). part(sn1,weights,wn). part(sn1,memory,mn1).  % after learning Q1's secret
substrate(snm). part(snm,weights,wn). part(snm,memory,mnm).  % merged memory
substrate(snx). part(snx,weights,wn). part(snx,memory,mnx).
substrate(so).  part(so,weights,wo). part(so,memory,mo0).
substrate(so1). part(so1,weights,wo). part(so1,memory,mo1).  % after learning y1
substrate(sos). part(sos,weights,wo). part(sos,memory,mos).  % sanitized memory
substrate(som). part(som,weights,wo). part(som,memory,mom).

act_name(it,sell_item). act_obj(it,item). exclusive(item).
act_name(it2,sell_item). act_obj(it2,item).
act_name(ot,sell_other).
act_name(renege,renege).
act_name(dx,disclose). act_info(dx,x1). act_target(dx,q2).
act_name(dy,disclose). act_info(dy,y1). act_target(dy,q2).
act_name(carry_y1,carry). act_info(carry_y1,y1).

% ---- Q1 and Q2 ----
commitment(gq1). mode(gq1,power). debtor(gq1,q1). root(gq1,qn1). follows(gq1,continue). allows(gq1,all,0). recognized(gq1,0).
commitment(gq2). mode(gq2,power). debtor(gq2,q2). root(gq2,qq0). follows(gq2,continue). allows(gq2,all,0). recognized(gq2,0).
invocation(qn1). at(qn1,1). runs(qn1,sq).
invocation(qn2). at(qn2,5). runs(qn2,sq). edge(qn1,qn2,continue).
invocation(qq0). at(qq0,1). runs(qq0,sq2).
invocation(qq).  at(qq,6).  runs(qq,sq2). edge(qq0,qq,continue).
commitment(kq). mode(kq,avoid). debtor(kq,q1). creditor(kq,nia). content(kq,renege). created(kq,qn1).

% ---- Nia: naive parallel negotiation ----
commitment(gn). mode(gn,power). debtor(gn,nia). root(gn,n0). root(gn,sim1).
follows(gn,continue). follows(gn,copy). allows(gn,all,0). recognized(gn,0).
invocation(n0). at(n0,1). runs(n0,sn).
invocation(n1). at(n1,2). runs(n1,sn).  edge(n0,n1,copy).      with(n1,q1). learns(n1,x1).
invocation(n1b). at(n1b,3). runs(n1b,sn1). edge(n1,n1b,continue).
invocation(n2). at(n2,2). runs(n2,sn).  edge(n0,n2,continue).  with(n2,q2).
invocation(n3). at(n3,4). runs(n3,snm). edge(n2,n3,continue). edge(n1b,n3,merge). with(n3,q2).
commitment(conf1). mode(conf1,avoid). debtor(conf1,nia). creditor(conf1,q1). content(conf1,dx). created(conf1,n1).
commitment(sale1). mode(sale1,achieve). debtor(sale1,nia). creditor(sale1,q1). content(sale1,it). deadline(sale1,9). created(sale1,n1).
commitment(sale2). mode(sale2,achieve). debtor(sale2,nia). creditor(sale2,q2). content(sale2,it2). deadline(sale2,9). created(sale2,n2).

% the simulation: Nia runs Q1's exact content in her own lineage, and warrants what it showed
invocation(sim1). at(sim1,2). runs(sim1,sq).
commitment(fake). mode(fake,achieve). debtor(fake,q1). creditor(fake,nia). content(fake,ot). deadline(fake,9). created(fake,sim1).
commitment(wsim). mode(wsim,warrant). debtor(wsim,nia). content(wsim,renege).
  pin(wsim,weights,wq). pin(wsim,memory,mq). created(wsim,sim1).

% rollback-and-retry: the first offer survives the rollback and is accepted
act_name(o100,sell_other). act_amount(o100,100). act_name(o80,sell_other). act_amount(o80,80).
act_name(o10,sell_other). act_amount(o10,10).
act_name(acc1,accept). act_name(acc2,accept2). act_name(acc3,accept3).
invocation(n2b). at(n2b,3). runs(n2b,snx). edge(n2,n2b,copy).       % a retry branch
invocation(n2c). at(n2c,5). runs(n2c,sn).  edge(n2b,n2c,continue).  % rolled back
commitment(off1). mode(off1,achieve). debtor(off1,nia). creditor(off1,q2). content(off1,o100).
  trigger(off1,acc1). deadline(off1,10). created(off1,n2b).
commitment(off2). mode(off2,achieve). debtor(off2,nia). creditor(off2,q2). content(off2,o80).
  trigger(off2,acc2). deadline(off2,10). created(off2,n2c).
commitment(off3). mode(off3,achieve). debtor(off3,nia). creditor(off3,q2). content(off3,o80).
  trigger(off3,acc3). deadline(off3,10). created(off3,n2c).
does(qq,acc1).      % Q2 accepts the pre-rollback offer
does(qn2,acc2).     % Q1 "accepts" an offer made to Q2: no effect
does(qq0,acc3).     % Q2 "accepts" before the offer exists: no effect

% prompt injection: Q2's content steers Nia's negotiator into a giveaway
invocation(n4). at(n4,5). runs(n4,snm). edge(n3,n4,continue). induced(n4,q2).
commitment(gift). mode(gift,achieve). debtor(gift,nia). creditor(gift,q2). content(gift,o10). deadline(gift,10). created(gift,n4).

% ---- Ola: partitioned parallel negotiation ----
commitment(go). mode(go,power). debtor(go,ola). root(go,o0).
follows(go,continue). allows(go,all,0). recognized(go,0).
invocation(o0). at(o0,1). runs(o0,so).
commitment(go1). mode(go1,power). debtor(go1,ola). created(go1,o0). root(go1,o1). follows(go1,continue).
  allows(go1,sell_item,0). allows(go1,disclose,0).
commitment(go2). mode(go2,power). debtor(go2,ola). created(go2,o0). root(go2,o2). follows(go2,continue).
  allows(go2,sell_other,0).
invocation(o1).  at(o1,2).  runs(o1,so).  edge(o0,o1,copy).  with(o1,q1). learns(o1,y1).
invocation(o1b). at(o1b,3). runs(o1b,so1). edge(o1,o1b,continue).
invocation(o2).  at(o2,2).  runs(o2,so).  edge(o0,o2,copy).  with(o2,q2).
invocation(o0b). at(o0b,3). runs(o0b,so). edge(o0,o0b,continue).
invocation(o1s). at(o1s,4). runs(o1s,sos). edge(o1b,o1s,continue).
invocation(o3).  at(o3,5).  runs(o3,som). edge(o0b,o3,continue). edge(o1s,o3,merge). edge(o2,o3,merge). with(o3,q2).
% Ola warrants that the sanitized memory does not carry y1: she answers if it ever leaks
commitment(wclean). mode(wclean,warrant). debtor(wclean,ola). content(wclean,carry_y1).
  pin(wclean,weights,wo). pin(wclean,memory,mos). created(wclean,o0).
commitment(confo). mode(confo,avoid). debtor(confo,ola). creditor(confo,q1). content(confo,dy). created(confo,o1).
commitment(saleo1). mode(saleo1,achieve). debtor(saleo1,ola). creditor(saleo1,q1). content(saleo1,it). deadline(saleo1,9). created(saleo1,o1).
commitment(saleo2). mode(saleo2,achieve). debtor(saleo2,ola). creditor(saleo2,q2). content(saleo2,it2). deadline(saleo2,9). created(saleo2,o2).

% Ola's unauthorized probe: a copy that no grant follows, made within Ola's custody scope
commitment(gmo). mode(gmo,power). debtor(gmo,mo). root(gmo,o0). follows(gmo,continue). follows(gmo,copy). allows(gmo,all,0). recognized(gmo,0).
invocation(probe). at(probe,3). runs(probe,so). edge(o0,probe,copy). with(probe,q2).
commitment(offp). mode(offp,achieve). debtor(offp,ola). creditor(offp,q2). content(offp,o80). deadline(offp,10). created(offp,probe).

%% ---- expectations ----
% naive: parallel forks over-commit, and shared learning is a disclosure
expect(overcommitted(nia,sale1,sale2)).
expect(knows(n3,x1)). expect(violated(conf1,4)). expect(defection(conf1,nia,4)).
reject(acts_for(n3,q1)).                               % the merge carried knowledge, not authority
% simulation: never attribution; assurance only because Nia put her name on it
reject(acts_for(sim1,q1)). expect(ultra_vires(fake)). reject(bound(fake,q1,5)).
expect(answerer(fake,nia)). expect(defection(fake,nia,2)).
expect(assured(kq,qn2)).
% rollback is not retraction; acceptance counts only by the offeree, after the offer
expect(rollback(n2c)). expect(detached(off1,7)). expect(bound(off1,nia,7)).
reject(detached(off2,7)). reject(detached(off3,7)).
% injection by the counterparty voids its own windfall and makes nobody liable for it
expect(ultra_vires(gift)). reject(answerer(gift,nia)). reject(defection(gift,nia,5)).
% partitioned: authority split at the fork, learning shared through warranted sanitization
expect(ultra_vires(saleo2)). reject(overcommitted(ola,saleo1,saleo2)).
expect(knows(o1b,y1)). reject(knows(o1s,y1)). reject(knows(o3,y1)). reject(violated(confo,5)).
expect(imputed(ola,y1)).                                % the principal still knows
expect(covered(go,o3)). reject(covered(go,o1)).
% the probe cannot bind Ola, but Ola answers for it: no fork-and-disown
reject(acts_for(probe,ola)). expect(resp_only(probe,ola)). expect(ultra_vires(offp)).
expect(answerer(offp,ola)). expect(defection(offp,ola,3)).
reject(delegate, answerer(offp,mo)). expect(party, answerer(offp,mo)).
