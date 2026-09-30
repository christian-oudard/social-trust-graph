%% S6. A coordinator is a role, not a kind of party.
%% A commons has a coordinator office with a charter: powers (allocate slots) and duties
%% (never favour a member; publish the schedule by t6). The office is filled by Alice
%% (person), then by a machine mc, then by Dan (person). Commitments made in the role
%% bind whoever holds the office when performance is due; breaches stay with whoever
%% held it when they happened (the trust-law pattern: an office outlives its holders).

role(coord).
principal(alice). kind(alice,person).
principal(dan).   kind(dan,person).
principal(mc).    kind(mc,machine).
principal(m1).    kind(m1,person).

substrate(body_alice). part(body_alice,self,opaque).
substrate(body_dan).   part(body_dan,self,opaque).
substrate(sm). part(sm,weights,wm).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). founded(ga,0).
commitment(gd). mode(gd,power). debtor(gd,dan).   root(gd,dan0).   follows(gd,continue). allows(gd,all,0). founded(gd,0).
commitment(gm). mode(gm,power). debtor(gm,mc).    root(gm,mc0).    follows(gm,continue). allows(gm,all,0). founded(gm,0).

fills(alice,coord,0,4). fills(mc,coord,4,8). fills(dan,coord,8,13).

% the charter: role powers and role duties
commitment(gcoord). mode(gcoord,power). debtor(gcoord,coord). allows(gcoord,give_slot,0). founded(gcoord,0).
act_name(fav,favor). act_name(pubs,publish). act_name(gs,give_slot). act_name(p1000,pay). act_amount(p1000,1000).
commitment(nofav). mode(nofav,avoid).   debtor(nofav,coord). creditor(nofav,m1). content(nofav,fav). founded(nofav,0).
commitment(pub).   mode(pub,achieve).   debtor(pub,coord).   creditor(pub,m1).   content(pub,pubs). deadline(pub,6). founded(pub,0).

invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(alice1). at(alice1,1). runs(alice1,body_alice). edge(alice0,alice1,continue).
invocation(alice2). at(alice2,2). runs(alice2,body_alice). edge(alice1,alice2,continue).
invocation(mc0). at(mc0,5). runs(mc0,sm).
invocation(dan0). at(dan0,9). runs(dan0,body_dan).

% Alice, in office, allocates a slot to m1 due at t9 (within role powers), and also
% promises a payment in the role's name (outside role powers)
commitment(alloc). mode(alloc,achieve). debtor(alloc,coord). creditor(alloc,m1). content(alloc,gs). deadline(alloc,9). created(alloc,alice1).
commitment(bad).   mode(bad,achieve).   debtor(bad,coord).   creditor(bad,m1).   content(bad,p1000). deadline(bad,9). created(bad,alice1).
does(alice2,fav).      % Alice favours a member while in office
does(dan0,gs).         % Dan performs the allocation Alice promised

%% ---- expectations ----
expect(valid_creation(alloc)). expect(bound(alloc,dan,9)). reject(bound(alloc,alice,9)).
expect(fulfilled(alloc,9)).
expect(ultra_vires(bad)). expect(answerer(bad,alice)).        % she warranted authority she lacked
expect(violated(nofav,2)). expect(defection(nofav,alice,2)). reject(defection(nofav,dan,2)).
reject(in_good_standing(alice,10)). expect(in_good_standing(dan,10)).
expect(charter(coord,pub)). expect(violated(pub,6)). expect(defection(pub,mc,6)).
% whether mc's breach in office is answered is the open question; the office is not a party
expect(party, answered_breach(pub,6)). expect(delegate, unanswered_breach(pub,6)).
