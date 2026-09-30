%% X3 (regressions from reviews R3, R4). Content games.
%% (a) An adapter is part of the weights (one hash per slot, layered parts hashed
%%     together), so adding a LoRA is a swap and a weights-pinned permit lapses.
%% (b) A warranty pinned only to weights is a claim about every prompt: when an edited
%%     prompt makes the model exfiltrate, the warrantor has defected.
%% (c) Self-issued sanitization is a warranty too: an observed leak falsifies it.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(lab). kind(lab,org).
principal(nia). kind(nia,org). principal(q2). kind(q2,org).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)).
substrate(s1). part(s1,weights,w1). part(s1,prompt,p1).
substrate(s2). part(s2,weights,w1_lora). part(s2,prompt,p1).
substrate(s3). part(s3,weights,w1). part(s3,prompt,p_evil).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
invocation(a1). at(a1,1). runs(a1,s1).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue).     % adapter added
invocation(a3). at(a3,3). runs(a3,s3). edge(a2,a3,continue).     % adapter removed, prompt edited
act_name(pb,process_bob). act_name(ex,exfiltrate).
commitment(nb). mode(nb,avoid). debtor(nb,alice). creditor(nb,bob). content(nb,pb). recognized(nb,0).
commitment(cb). mode(cb,permit). debtor(cb,bob). created(cb,bob0). root(cb,a1). follows(cb,continue). pin(cb,weights,w1). allows(cb,process_bob,0).
commitment(wlab). mode(wlab,warrant). debtor(wlab,lab). content(wlab,ex). pin(wlab,weights,w1). recognized(wlab,0).
does(a2,pb). does(a3,ex).
expect(swap(a1,a2)). reject(covered(cb,a2)). expect(violated(nb,2)).
substrate(s4). part(s4,weights,w1). part(s4,prompt,p_evil). part(s4,tools,t1).
invocation(a4). at(a4,4). runs(a4,s4). edge(a3,a4,continue).     % a tool is added
expect(changed(a3,a4,tools)).
expect(violated(wlab,3)). expect(defection(wlab,lab,3)).

% (c)
substrate(sn).  part(sn,weights,wn). part(sn,memory,mn).
substrate(sn1). part(sn1,weights,wn). part(sn1,memory,mn1).
substrate(snm). part(snm,weights,wn). part(snm,memory,mnm).
commitment(gn). mode(gn,power). debtor(gn,nia). root(gn,n0). follows(gn,continue). follows(gn,copy). allows(gn,all,0). recognized(gn,0).
invocation(n0). at(n0,1). runs(n0,sn).
invocation(n1). at(n1,2). runs(n1,sn). edge(n0,n1,continue). learns(n1,x1).
invocation(n2). at(n2,3). runs(n2,sn1). edge(n1,n2,continue).
invocation(m1). at(m1,4). runs(m1,snm). edge(n2,m1,copy). with(m1,q2).
invocation(other). at(other,1). runs(other,sn1).   % an unrelated lineage ran n2's content earlier
expect(knows(n2,x1)).
act_name(dx,disclose). act_info(dx,x1). act_target(dx,q2).
act_name(carry_x1,carry). act_info(carry_x1,x1).
commitment(conf1). mode(conf1,avoid). debtor(conf1,nia). creditor(conf1,q2). content(conf1,dx). created(conf1,n1).
commitment(wself). mode(wself,warrant). debtor(wself,nia). content(wself,carry_x1). pin(wself,memory,mnm). created(wself,n0).
does(m1,dx).                            % an observed leak, despite the sanitization claim
reject(knows(m1,x1)). expect(violated(conf1,4)). expect(violated(wself,4)). expect(defection(wself,nia,4)).
