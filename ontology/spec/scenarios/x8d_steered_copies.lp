%% X8d (review round 3, formal: R4, R2). Steering and what it produces.
%% (a) R4: Bob injects Alice's agent a1 into copying itself; the copy sells data. The copy
%%     is run by whoever answers for making it: Alice (a1's operator) and Bob (its steerer).
%%     If the record shows Bob runs the copy, it is his alone.
%% (b) R2: an autonomous agent m (not a party) injects Alice's agent into promising Bob a
%%     payment. The promise binds Alice under every hypothesis (a good-faith counterparty,
%%     cf. R2d 164(2)); injected by Bob, the beneficiary, it is void under every hypothesis.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(carol). kind(carol,person).
principal(m). kind(m,machine).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)). substrate(bc). part(bc,self,opaque(carol)).
substrate(s1). part(s1,weights,w1). substrate(sm). part(sm,weights,wm).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,bob0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gm). mode(gm,power). debtor(gm,m). root(gm,m0). follows(gm,continue). allows(gm,all,0). recognized(gm,0).
invocation(alice0). at(alice0,0). runs(alice0,ba). invocation(bob0). at(bob0,0). runs(bob0,bb).
invocation(m0). at(m0,1). runs(m0,sm).
act_name(sell,sell_data).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,carol). content(nda,sell). recognized(nda,0).
commitment(ndb). mode(ndb,avoid). debtor(ndb,bob). creditor(ndb,carol). content(ndb,sell). recognized(ndb,0).

% (a)
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
invocation(a1). at(a1,2). runs(a1,s1). induced(a1,bob).
invocation(b1). at(b1,3). runs(b1,s1). edge(a1,b1,copy). does(b1,sell).
expect(op(b1,alice)). expect(op(b1,bob)). expect(defection(ndb,bob,3)). expect(defection(nda,alice,3)).
invocation(b2). at(b2,4). runs(b2,s1). edge(a1,b2,copy). operator(b2,bob). does(b2,sell).
reject(op(b2,alice)). reject(defection(nda,alice,4)). expect(defection(ndb,bob,4)).

% (b)
commitment(gak). mode(gak,power). debtor(gak,alice). created(gak,alice0). root(gak,k1). follows(gak,continue). allows(gak,pay,1000).
act_name(p9,pay). act_amount(p9,900).
invocation(k1). at(k1,2). runs(k1,s1). induced(k1,m).
commitment(c). mode(c,achieve). debtor(c,alice). creditor(c,bob). content(c,p9). deadline(c,6). created(c,k1).
expect(valid_creation(c)). expect(defection(c,alice,6)).
invocation(k2). at(k2,3). runs(k2,s1). edge(k1,k2,continue). induced(k2,bob).
commitment(c2). mode(c2,achieve). debtor(c2,alice). creditor(c2,bob). content(c2,p9). deadline(c2,6). created(c2,k2).
expect(vitiated(k2,c2)). expect(unauthorized(c2)). reject(defection(c2,alice,6)).
