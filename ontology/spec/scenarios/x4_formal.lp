%% X4 (regressions from review R2). Formal corner cases.
%% (a) Role powers respect revocation and pins; co-holders do not share an act's blame.
%% (b) Repair is per breach: a repaired first breach does not cover a second. A repaired
%%     reparation repairs what it answers (chains of depth 2).
%% (c) Only a grant that may delegate is a parent: revoking an unrelated narrow grant
%%     that also covered the delegating invocation does not end the sub-grant.

principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(carol). kind(carol,person).
substrate(ba). part(ba,self,opaque(alice)). substrate(bb). part(bb,self,opaque(bob)). substrate(bc). part(bc,self,opaque(carol)).
substrate(s1). part(s1,weights,w1). substrate(s2). part(s2,weights,w2).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,a0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
commitment(gb). mode(gb,power). debtor(gb,bob). root(gb,b0). follows(gb,continue). allows(gb,all,0). recognized(gb,0).
commitment(gc). mode(gc,power). debtor(gc,carol). root(gc,c0). follows(gc,continue). allows(gc,all,0). recognized(gc,0).
invocation(a0). at(a0,0). runs(a0,ba). invocation(b0). at(b0,0). runs(b0,bb). invocation(c0). at(c0,0). runs(c0,bc).

% (a)
role(coord). appointer(coord,carol). appoints(c0,alice,coord,13). appoints(c0,bob,coord,13).
commitment(gcoord). mode(gcoord,power). debtor(gcoord,coord). allows(gcoord,give,0). recognized(gcoord,0).
  trigger(gcoord,never).                % the charter power sleeps until an act that never comes
act_name(never,approve_role). act_name(gv,give). act_name(fav,favor).
invocation(a1). at(a1,3). runs(a1,ba). edge(a0,a1,continue).
commitment(al). mode(al,achieve). debtor(al,coord). creditor(al,carol). content(al,gv). deadline(al,9). created(al,a1).
commitment(nf). mode(nf,avoid). debtor(nf,coord). creditor(nf,carol). content(nf,fav). recognized(nf,0).
does(a1,fav).
expect(ultra_vires(al)). expect(defection(nf,alice,3)). reject(defection(nf,bob,3)).

% (b)
invocation(c1). at(c1,3). runs(c1,bc). edge(c0,c1,continue).
invocation(c2). at(c2,4). runs(c2,bc). edge(c1,c2,continue).
invocation(c3). at(c3,6). runs(c3,bc). edge(c2,c3,continue).
act_name(leak,leak). act_name(pay,pay). act_name(pay2,pay2). act_name(pay3,pay3).
commitment(nda). mode(nda,avoid). debtor(nda,carol). creditor(nda,bob). content(nda,leak). recognized(nda,0).
commitment(r). mode(r,achieve). debtor(r,carol). creditor(r,bob). content(r,pay). trigger(r,nda). reparation(nda,r). deadline(r,5). recognized(r,0).
does(c1,leak). does(c2,pay).            % breach at 3, repaired at 4
does(c3,leak).                          % second breach at 6, never repaired
expect(repaired(nda,3,4)). reject(repaired(nda,6,7)).
expect(in_good_standing(carol,5)). reject(in_good_standing(carol,7)).
commitment(k). mode(k,achieve). debtor(k,bob). creditor(k,alice). content(k,pay2). deadline(k,1). recognized(k,0).
commitment(r1). mode(r1,achieve). debtor(r1,bob). creditor(r1,alice). content(r1,pay2). trigger(r1,k). reparation(k,r1). deadline(r1,2). recognized(r1,0).
commitment(r2). mode(r2,achieve). debtor(r2,bob). creditor(r2,alice). content(r2,pay3). trigger(r2,r1). reparation(r1,r2). deadline(r2,8). recognized(r2,0).
invocation(b1). at(b1,5). runs(b1,bb). edge(b0,b1,continue). does(b1,pay3).
expect(repaired(k,1,5)). expect(in_good_standing(bob,8)). reject(in_good_standing(bob,4)).

% (c)
invocation(x1). at(x1,2). runs(x1,s1).
invocation(y1). at(y1,4). runs(y1,s2).
invocation(y2). at(y2,6). runs(y2,s2). edge(y1,y2,continue).
commitment(gbig). mode(gbig,power). debtor(gbig,alice). created(gbig,a0). root(gbig,x1). follows(gbig,continue). allows(gbig,all,0).
commitment(gsmall). mode(gsmall,power). debtor(gsmall,alice). created(gsmall,a0). root(gsmall,x1). follows(gsmall,continue). allows(gsmall,spam,0).
invocation(a2). at(a2,4). runs(a2,ba). edge(a1,a2,continue).
revokes(a2,gsmall).
commitment(gsub). mode(gsub,power). debtor(gsub,alice). created(gsub,x1). root(gsub,y1). follows(gsub,continue). allows(gsub,pay,5).
act_name(p,pay). act_amount(p,3).
commitment(c). mode(c,achieve). debtor(c,alice). creditor(c,bob). content(c,p). deadline(c,9). created(c,y2).
expect(valid_creation(c)). reject(parent_grant(gsub,gsmall)). expect(parent_grant(gsub,gbig)).
