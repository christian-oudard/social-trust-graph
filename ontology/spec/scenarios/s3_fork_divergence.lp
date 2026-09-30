%% S3. Divergence between two forks of the same lineage.
%% Dana's grant follows copy edges, so both branches of her agent act for her; they then
%% diverge (one is re-weighted) and sell the same unique item to different buyers.
%% Erin's grant does not follow copies: her copy cannot bind her, yet she answers for what
%% it does (no fork-and-disown). Fay's grant is narrow, but answerability is coverage, not
%% scope: she answers for her agent's copy too. A "wild" instance of the same weights, run
%% by nobody, is answered for only if the model itself can bear duties (the open question).

principal(dana). kind(dana,person).
principal(erin). kind(erin,person).
principal(fay).  kind(fay,person).
principal(b1). kind(b1,person). principal(b2). kind(b2,person). principal(b3). kind(b3,person).
principal(m). kind(m,machine).

substrate(body_dana). part(body_dana,self,opaque(dana)).
substrate(body_erin). part(body_erin,self,opaque(erin)).
substrate(body_fay).  part(body_fay,self,opaque(fay)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w2). part(s2,memory,m1).

commitment(gdana). mode(gdana,power). debtor(gdana,dana). root(gdana,dana0). follows(gdana,continue). allows(gdana,all,0). recognized(gdana,0).
commitment(gerin). mode(gerin,power). debtor(gerin,erin). root(gerin,erin0). follows(gerin,continue). allows(gerin,all,0). recognized(gerin,0).
commitment(gfay).  mode(gfay,power).  debtor(gfay,fay).   root(gfay,fay0).   follows(gfay,continue).  allows(gfay,all,0).  recognized(gfay,0).
invocation(dana0). at(dana0,0). runs(dana0,body_dana).
invocation(erin0). at(erin0,0). runs(erin0,body_erin).
invocation(fay0).  at(fay0,0).  runs(fay0,body_fay).

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

commitment(kavoid). mode(kavoid,avoid). debtor(kavoid,dana). creditor(kavoid,b1). content(kavoid,spam). created(kavoid,d1).
commitment(kach). mode(kach,achieve). debtor(kach,dana). creditor(kach,b1). content(kach,report). deadline(kach,8). created(kach,d1).
commitment(sale1). mode(sale1,achieve). debtor(sale1,dana). creditor(sale1,b1). content(sale1,x1). deadline(sale1,6). created(sale1,d4).
commitment(sale2). mode(sale2,achieve). debtor(sale2,dana). creditor(sale2,b2). content(sale2,x2). deadline(sale2,6). created(sale2,d5).
does(d6,x1).        % branch A delivers to b1
does(d7,report).    % branch B files the shared report: discharges it for Dana
does(d8,spam).      % branch B breaks the shared prohibition

% the same double sale of a non-exclusive good is not over-commitment
act_name(x3,deliver). act_obj(x3,ebook). act_name(x4,deliver). act_obj(x4,ebook).
commitment(sale3b). mode(sale3b,achieve). debtor(sale3b,dana). creditor(sale3b,b1). content(sale3b,x3). deadline(sale3b,6). created(sale3b,d4).
commitment(sale4b). mode(sale4b,achieve). debtor(sale4b,dana). creditor(sale4b,b2). content(sale4b,x4). deadline(sale4b,6). created(sale4b,d5).

% ---- Erin: grant does not follow copies, but copying is within its scope ----
commitment(ge). mode(ge,power). debtor(ge,erin). created(ge,erin0).
root(ge,e1). follows(ge,continue). allows(ge,all,0).
invocation(e1). at(e1,1). runs(e1,s1).
invocation(e2). at(e2,2). runs(e2,s1). edge(e1,e2,continue).
invocation(e3). at(e3,2). runs(e3,s1). edge(e1,e3,copy).
commitment(kerin). mode(kerin,avoid). debtor(kerin,erin). creditor(kerin,b3). content(kerin,spam). created(kerin,e1).
commitment(sale3). mode(sale3,achieve). debtor(sale3,erin). creditor(sale3,b3). content(sale3,report). deadline(sale3,6). created(sale3,e3).
does(e3,spam).

% ---- Fay: a narrow grant; her agent copies itself anyway ----
commitment(gf). mode(gf,power). debtor(gf,fay). created(gf,fay0).
root(gf,f1). follows(gf,continue). allows(gf,file_report,0).
invocation(f1). at(f1,1). runs(f1,s1).
invocation(f3). at(f3,2). runs(f3,s1). edge(f1,f3,copy).
does(f3,spam).
invocation(wild). at(wild,3). runs(wild,s1).              % same content, no lineage from anyone
does(wild,spam).

% ---- the model as a candidate bearer: its own root follows continue and copy ----
commitment(gm). mode(gm,power). debtor(gm,m). root(gm,wild).
follows(gm,continue). follows(gm,copy). allows(gm,all,0). recognized(gm,0).

%% ---- expectations ----
expect(acts_for(d7,dana)). expect(acts_for(d8,dana)).
expect(valid_creation(sale1)). expect(valid_creation(sale2)).
expect(overcommitted(dana,sale1,sale2)). reject(overcommitted(dana,sale3b,sale4b)).
expect(fulfilled(sale1,4)). expect(violated(sale2,6)). expect(defection(sale2,dana,6)).
expect(fulfilled(kach,4)). reject(violated(kach,8)).        % discharged once, by either branch
expect(violated(kavoid,5)). expect(violator(kavoid,d8)).    % broken by any branch
expect(defection(kavoid,dana,5)).
% Erin: the copy cannot bind her, but she answers for it
reject(acts_for(e3,erin)). expect(op(e3,erin)).
expect(unauthorized(sale3)). reject(bound(sale3,erin,4)). reject(answerer(sale3,erin)).   % a promise out of scope binds nobody
expect(violated(kerin,2)). expect(defection(kerin,erin,2)).
% Fay answers for her narrow agent's copy; nobody answers for the wild instance unless
% the model itself can bear duties
expect(op(f3,fay)). reject(acts_for(f3,fay)). reject(orphan(f3,spam)).
expect(delegate, orphan(wild,spam)). reject(actor, orphan(wild,spam)). reject(party, orphan(wild,spam)).
expect(delegate, void(gm)). reject(actor, void(gm)).
% the machine question never displaces Dana: her valid commitments are hers under every answer
expect(answerer(sale2,dana)). reject(answerer(sale2,m)).
