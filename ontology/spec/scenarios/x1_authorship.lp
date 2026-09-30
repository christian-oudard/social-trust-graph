%% X1 (regressions from review R3, R2). Registry changes need authors.
%% (a) Theft is content without lineage: a thief running Dana's exact agent content has no
%%     edge from Dana's agent, so it cannot bind her, whatever her grant follows. The thief's
%%     custodian answers for its conduct; its promise in Dana's name binds nobody.
%% (b) Consent cannot be manufactured by copying the consenter's agent: powers never
%%     excuse, only permits do, and the copy of Bob's agent holds no permit from Bob.
%% (c) A feed from someone else's agent carries knowledge, never authority.
%% (d) A debtor cannot release itself, nor revoke what is not a power; releases are the
%%     creditor's acts and take effect from the next step, so they cannot be backdated.
%% (e) A dual agent covered by both sides' broad powers excuses nothing between them.

principal(dana). kind(dana,person). principal(eve). kind(eve,person). principal(bob). kind(bob,person).
principal(b). kind(b,org). principal(s). kind(s,org).
substrate(bd). part(bd,self,opaque(dana)). substrate(be). part(be,self,opaque(eve)). substrate(bb). part(bb,self,opaque(bob)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(sb). part(sb,weights,wb). part(sb,memory,mb).
commitment(gdana). mode(gdana,power). debtor(gdana,dana). root(gdana,dana0). follows(gdana,continue). allows(gdana,all,0). recognized(gdana,0).
commitment(geve). mode(geve,power). debtor(geve,eve). root(geve,eve0). follows(geve,continue). allows(geve,all,0). recognized(geve,0).
commitment(gbob). mode(gbob,power). debtor(gbob,bob). root(gbob,bob0). follows(gbob,continue). allows(gbob,all,0). recognized(gbob,0).
invocation(dana0). at(dana0,0). runs(dana0,bd).
invocation(eve0). at(eve0,0). runs(eve0,be).
invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(bob1). at(bob1,3). runs(bob1,bb). edge(bob0,bob1,continue).

% (a)
commitment(gd). mode(gd,power). debtor(gd,dana). created(gd,dana0). root(gd,d1). follows(gd,continue). follows(gd,copy). allows(gd,all,0).
commitment(gthief). mode(gthief,power). debtor(gthief,eve). created(gthief,eve0). root(gthief,thief). follows(gthief,continue). allows(gthief,all,0).
invocation(d1). at(d1,1). runs(d1,s1).
invocation(thief). at(thief,3). runs(thief,s1).                 % exfiltrated content, no edge
act_name(p9,pay). act_amount(p9,900).
commitment(loot). mode(loot,achieve). debtor(loot,dana). creditor(loot,bob). content(loot,p9). deadline(loot,6). created(loot,thief).
expect(ultra_vires(loot)). reject(bound(loot,dana,5)). expect(acts_for(thief,eve)). reject(answerer(loot,eve)).

% (b)
commitment(gba). mode(gba,power). debtor(gba,bob). created(gba,bob0). root(gba,bx1). follows(gba,continue). follows(gba,copy). allows(gba,all,0).
invocation(bx1). at(bx1,1). runs(bx1,sb).
invocation(bcopy). at(bcopy,2). runs(bcopy,sb). edge(bx1,bcopy,copy).
act_name(sellb,sell_bob_data).
commitment(nda). mode(nda,avoid). debtor(nda,dana). creditor(nda,bob). content(nda,sellb). recognized(nda,0).
invocation(d2). at(d2,2). runs(d2,s1). edge(d1,d2,continue).
does(d2,sellb).
reject(excused(nda,d2)). expect(violated(nda,2)).

% (c)
substrate(s3). part(s3,weights,w1). part(s3,memory,m3).
invocation(d3). at(d3,4). runs(d3,s3). edge(d2,d3,continue). feeds(bx1,d3).
reject(acts_for(d3,bob)).

% (d)
act_name(sx,spam).
commitment(k). mode(k,avoid). debtor(k,dana). creditor(k,bob). content(k,sx). recognized(k,0).
invocation(d4). at(d4,5). runs(d4,s3). edge(d3,d4,continue).
releases(d3,k).                         % the debtor "releases" itself: no effect
does(d4,sx).
reject(ended_by(k,5)). expect(violated(k,5)).
commitment(k2). mode(k2,avoid). debtor(k2,dana). creditor(k2,bob). content(k2,sx). recognized(k2,0).
releases(bob1,k2).                      % the creditor releases at t3: effective from t4
reject(ended_by(k2,3)). expect(ended_by(k2,4)).

% (e)
substrate(smk). part(smk,weights,wk).
commitment(gbuy). mode(gbuy,power). debtor(gbuy,b). root(gbuy,mk). follows(gbuy,continue). allows(gbuy,all,0). recognized(gbuy,0).
commitment(gsel). mode(gsel,power). debtor(gsel,s). root(gsel,mk). follows(gsel,continue). allows(gsel,all,0). recognized(gsel,0).
invocation(mk). at(mk,1). runs(mk,smk).
act_name(fr,front_run_buyer).
commitment(kfr). mode(kfr,avoid). debtor(kfr,s). creditor(kfr,b). content(kfr,fr). recognized(kfr,0).
does(mk,fr).
reject(excused(kfr,mk)). expect(violated(kfr,1)).
