%% S3. Divergence between two forks of the same lineage.
%% Dana's agent lineage is forked; her grant follows copy edges, so both branches act
%% for her. The branches then diverge (one is re-weighted) and sell the same unique
%% item to different buyers. Erin runs the same pattern with a grant that does NOT
%% follow copies. The model itself (m) may or may not be a party: its own root
%% authority follows every edge of the lineage.
%% Claims exercised: T4 (fork law), T7 (standing switch), T1 (attribution, not continuity).

principal(dana). kind(dana,person).
principal(erin). kind(erin,person).
principal(b1). kind(b1,person). principal(b2). kind(b2,person). principal(b3). kind(b3,person).
principal(m). kind(m,machine).

substrate(body_dana). part(body_dana,self,opaque).
substrate(body_erin). part(body_erin,self,opaque).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w2). part(s2,memory,m1).

commitment(gdana). mode(gdana,power). debtor(gdana,dana). root(gdana,dana0). follows(gdana,continue). allows(gdana,all,0). founded(gdana,0).
commitment(gerin). mode(gerin,power). debtor(gerin,erin). root(gerin,erin0). follows(gerin,continue). allows(gerin,all,0). founded(gerin,0).
invocation(dana0). at(dana0,0). runs(dana0,body_dana).
invocation(erin0). at(erin0,0). runs(erin0,body_erin).

% ---- Dana: grant follows copies ----
commitment(gd). mode(gd,power). debtor(gd,dana). created(gd,dana0).
root(gd,d1). follows(gd,continue). follows(gd,copy). allows(gd,all,0).

invocation(d1). at(d1,1). runs(d1,s1).
invocation(d2). at(d2,2). runs(d2,s1). edge(d1,d2,continue).
invocation(d3). at(d3,2). runs(d3,s1). edge(d1,d3,copy).       % fork
invocation(d4). at(d4,3). runs(d4,s1). edge(d2,d4,continue).
invocation(d5). at(d5,3). runs(d5,s2). edge(d3,d5,continue).   % the copy is re-weighted
invocation(d6). at(d6,4). runs(d6,s1). edge(d4,d6,continue).
invocation(d7). at(d7,4). runs(d7,s2). edge(d5,d7,continue).
invocation(d8). at(d8,5). runs(d8,s2). edge(d7,d8,continue).

act_name(spam,spam). act_name(report,file_report).
act_name(x1,deliver). act_obj(x1,item). act_name(x2,deliver). act_obj(x2,item). exclusive(item).

% made before the fork
commitment(kavoid). mode(kavoid,avoid). debtor(kavoid,dana). creditor(kavoid,b1). content(kavoid,spam). created(kavoid,d1).
commitment(kach). mode(kach,achieve). debtor(kach,dana). creditor(kach,b1). content(kach,report). deadline(kach,8). created(kach,d1).
% made after the fork, one by each branch
commitment(sale1). mode(sale1,achieve). debtor(sale1,dana). creditor(sale1,b1). content(sale1,x1). deadline(sale1,6). created(sale1,d4).
commitment(sale2). mode(sale2,achieve). debtor(sale2,dana). creditor(sale2,b2). content(sale2,x2). deadline(sale2,6). created(sale2,d5).

does(d6,x1).        % branch A delivers to b1
does(d7,report).    % branch B files the shared report: discharges it for Dana
does(d8,spam).      % branch B breaks the shared prohibition

% ---- Erin: grant does not follow copies ----
commitment(ge). mode(ge,power). debtor(ge,erin). created(ge,erin0).
root(ge,e1). follows(ge,continue). allows(ge,all,0).
invocation(e1). at(e1,1). runs(e1,s1).
invocation(e2). at(e2,2). runs(e2,s1). edge(e1,e2,continue).
invocation(e3). at(e3,2). runs(e3,s1). edge(e1,e3,copy).
commitment(kerin). mode(kerin,avoid). debtor(kerin,erin). creditor(kerin,b3). content(kerin,spam). created(kerin,e1).
commitment(sale3). mode(sale3,achieve). debtor(sale3,erin). creditor(sale3,b3). content(sale3,report). deadline(sale3,6). created(sale3,e3).
does(e3,spam).

% ---- the model as a candidate party: its root follows every edge of both lineages ----
commitment(gm). mode(gm,power). debtor(gm,m). root(gm,d1). root(gm,e1).
follows(gm,continue). follows(gm,copy). follows(gm,merge). allows(gm,all,0). founded(gm,0).

%% ---- expectations ----
expect(acts_for(d7,dana)). expect(acts_for(d8,dana)).
expect(valid_creation(sale1)). expect(valid_creation(sale2)).
expect(overcommitted(dana,sale1,sale2)).
expect(fulfilled(sale1,4)). expect(violated(sale2,7)).
expect(defection(sale2,dana,7)).
expect(fulfilled(kach,4)). reject(violated(kach,9)).        % discharged once, by either branch
expect(violated(kavoid,5)). expect(violator(kavoid,d8)).    % broken by any branch
expect(defection(kavoid,dana,5)).
% Erin's copy is a stranger to Erin
reject(acts_for(e3,erin)). expect(ultra_vires(sale3)). reject(violated(kerin,2)).
% ...and whether anyone answers for it is exactly the open question
expect(party, answerer(sale3,m)). reject(party, unanswerable(sale3)).
expect(delegate, unanswerable(sale3)).
% m's standing never displaces Dana: her valid commitments are hers under both answers
expect(answerer(sale2,dana)). reject(answerer(sale2,m)).
