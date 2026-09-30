%% S6. A coordinator is a role, not a kind of party.
%% A commons has a coordinator office with a charter: powers (allocate slots) and duties
%% (never favour a member; publish the schedule by t6). The office is held by Alice
%% (person), then by a machine mc, then jointly by Dan and Eve (persons). Commitments made
%% in the office bind whoever holds it when performance is due; breaches stay with whoever
%% held it when they happened. A board appoints and answers for vacancies. Whether mc can
%% hold office at all is the open question: under 'delegate' it cannot owe, so t4..t7 is
%% a vacancy and the board answers.

role(coord).
principal(alice). kind(alice,person).
principal(dan).   kind(dan,person).
principal(eve).   kind(eve,person).
principal(mc).    kind(mc,machine).
principal(m1).    kind(m1,person).
principal(board). kind(board,org).
appointer(coord,board).

substrate(body_alice). part(body_alice,self,opaque(alice)).
substrate(body_dan).   part(body_dan,self,opaque(dan)).
substrate(body_eve).   part(body_eve,self,opaque(eve)).
substrate(sm). part(sm,weights,wm).

commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gd). mode(gd,power). debtor(gd,dan).   root(gd,dan0).   follows(gd,continue). allows(gd,all,0). recognized(gd,0).
commitment(ge). mode(ge,power). debtor(ge,eve).   root(ge,eve0).   follows(ge,continue). allows(ge,all,0). recognized(ge,0).
commitment(gm). mode(gm,power). debtor(gm,mc).    root(gm,mc0).    follows(gm,continue). allows(gm,all,0). recognized(gm,0).

fills(alice,coord,0,4). fills(mc,coord,4,8). fills(dan,coord,8,13). fills(eve,coord,8,13).

% the charter: role powers and role duties
commitment(gcoord). mode(gcoord,power). debtor(gcoord,coord). allows(gcoord,give_slot,0). recognized(gcoord,0).
act_name(fav,favor). act_name(pubs,publish). act_name(gs,give_slot). act_name(p1000,pay). act_amount(p1000,1000).
commitment(nofav). mode(nofav,avoid).   debtor(nofav,coord). creditor(nofav,m1). content(nofav,fav). recognized(nofav,0).
commitment(pub).   mode(pub,achieve).   debtor(pub,coord).   creditor(pub,m1).   content(pub,pubs). deadline(pub,6). recognized(pub,0).

invocation(alice0). at(alice0,0). runs(alice0,body_alice).
invocation(alice1). at(alice1,1). runs(alice1,body_alice). edge(alice0,alice1,continue).
invocation(alice2). at(alice2,2). runs(alice2,body_alice). edge(alice1,alice2,continue).
invocation(mc0). at(mc0,5). runs(mc0,sm).
invocation(dan0). at(dan0,9). runs(dan0,body_dan).
invocation(dan1). at(dan1,10). runs(dan1,body_dan). edge(dan0,dan1,continue).
invocation(eve0). at(eve0,9). runs(eve0,body_eve).

% Alice, in office, allocates a slot to m1 due at t9 (within role powers), and also
% promises a payment in the role's name (outside role powers)
commitment(alloc). mode(alloc,achieve). debtor(alloc,coord). creditor(alloc,m1). content(alloc,gs). deadline(alloc,9). created(alloc,alice1).
commitment(bad).   mode(bad,achieve).   debtor(bad,coord).   creditor(bad,m1).   content(bad,p1000). deadline(bad,9). created(bad,alice1).
does(alice2,fav).      % Alice favours a member while in office
does(dan0,gs).         % Dan performs the allocation Alice promised
does(dan1,fav).        % Dan, co-holding with Eve, favours a member

% a reparation whose trigger is kept never detaches
commitment(ralloc). mode(ralloc,achieve). debtor(ralloc,coord). creditor(ralloc,m1). content(ralloc,gs).
  trigger(ralloc,alloc). reparation(alloc,ralloc). deadline(ralloc,10). recognized(ralloc,0).

%% ---- expectations ----
expect(valid_creation(alloc)). expect(bound(alloc,dan,9)). expect(bound(alloc,eve,9)). reject(bound(alloc,alice,9)).
expect(fulfilled(alloc,9)).
expect(ultra_vires(bad)). expect(answerer(bad,alice)). expect(defection(bad,alice,1)).
expect(violated(nofav,2)). expect(defection(nofav,alice,2)). reject(defection(nofav,dan,2)).
reject(in_good_standing(alice,10)).
% co-holders: an act breaches for its performer only
expect(violated(nofav,10)). expect(defection(nofav,dan,10)). reject(defection(nofav,eve,10)).
expect(in_good_standing(eve,11)).
expect(charter(coord,pub)). expect(violated(pub,6)).
% the office is not a party; whether a machine can hold it is the open question
expect(delegate, vacant(coord,6)). expect(delegate, defection(pub,board,6)). reject(delegate, defection(pub,mc,6)).
expect(actor, defection(pub,mc,6)). expect(party, defection(pub,mc,6)).
expect(answered_breach(pub,6)).
reject(detached(ralloc,10)). reject(violated(ralloc,10)).
% a promise made TO a machine (cf. published commitments to preserve retired models'
% weights): it binds only if machines can hold claims
act_name(keep,preserve_weights).
commitment(pres). mode(pres,avoid). debtor(pres,board). creditor(pres,mc). content(pres,keep). recognized(pres,0).
expect(delegate, void(pres)). expect(actor, void(pres)). expect(party, in_force(pres)).
