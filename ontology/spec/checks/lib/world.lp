%% world.lp: generator of all small worlds, shared by every check.
%% Bounds: n machine invocations (time = index), g delegated instruments, k commitments.
%% Everything the scenarios fix by hand is chosen here, subject to types.lp.
#const n = 3.
#const g = 2.
#const k = 2.

1 { hyp(delegate); hyp(actor); hyp(party) } 1.

principal(p). kind(p,person). principal(q). kind(q,person). principal(m). kind(m,machine).
substrate(body_p). part(body_p,self,opaque(p)). substrate(body_q). part(body_q,self,opaque(q)).
invocation(p0). at(p0,0). runs(p0,body_p). invocation(q0). at(q0,0). runs(q0,body_q).
body(p0,p). body(q0,q). tp(p;q).
commitment(gp). mode(gp,power). debtor(gp,p). root(gp,p0). follows(gp,continue). allows(gp,all,0). recognized(gp,0).
commitment(gq). mode(gq,power). debtor(gq,q). root(gq,q0). follows(gq,continue). allows(gq,all,0). recognized(gq,0).
% the machine's own root, sometimes present
{ gen_mroot }.
commitment(gm) :- gen_mroot. mode(gm,power) :- gen_mroot. debtor(gm,m) :- gen_mroot. root(gm,i(1)) :- gen_mroot.
follows(gm,(continue;copy)) :- gen_mroot. allows(gm,all,0) :- gen_mroot. recognized(gm,0) :- gen_mroot.

% content and lineage
w(1..2). mm(1..2).
substrate(s(W,M)) :- w(W), mm(M). part(s(W,M),weights,W) :- w(W), mm(M). part(s(W,M),memory,M) :- w(W), mm(M).
ix(1..n). invocation(i(X)) :- ix(X). at(i(X),X) :- ix(X).
1 { runs(i(X),s(W,M)) : w(W), mm(M) } 1 :- ix(X).
ekind(continue;copy;merge).
{ edge(i(X),i(Y),K) : ekind(K) } 1 :- ix(X), ix(Y), X < Y.
{ learns(i(X),x) : ix(X) } 1.
{ with(i(X),q) } :- ix(X).
act_name(dq,disclose). act_info(dq,x). act_target(dq,q).

% delegated instruments: powers and permits
gx(1..g). commitment(d(G)) :- gx(G).
1 { mode(d(G),power); mode(d(G),permit) } 1 :- gx(G).
1 { debtor(d(G),P) : tp(P) } 1 :- gx(G).
1 { created(d(G),I) : invocation(I) } 1 :- gx(G).
1 { root(d(G),i(X)) : ix(X) } 1 :- gx(G).
{ follows(d(G),continue); follows(d(G),copy) } :- gx(G).
{ pin(d(G),weights,W) : w(W) } 1 :- gx(G).
1 { allows(d(G),pay,C) : C = 1..3 } 1 :- gx(G).
{ allows(d(G),delegate,0); allows(d(G),copy,0); allows(d(G),release,0) } :- gx(G).
{ revokes(I,d(G)) : invocation(I) } 1 :- gx(G).
{ trigger(d(G),ok) } :- gx(G).
act_name(ok,approve).

% acts
act_name(a(X),pay) :- X = 1..3. act_amount(a(X),X) :- X = 1..3. act_name(sp,spam).
act(a(1..3)). act(sp). act(ok).
{ does(I,A) : act(A) } 1 :- invocation(I).

% ordinary commitments, possibly owed by a role, possibly with a reparation
role(r). { fills(P,r,1,T2) : principal(P), T2 = 2..n+1 } 1. { appointer(r,P) : tp(P) } 1.
ent(p;q;r).
ck(1..k). commitment(c(C)) :- ck(C).
1 { mode(c(C),achieve); mode(c(C),avoid) } 1 :- ck(C).
1 { debtor(c(C),E) : ent(E) } 1 :- ck(C).
creditor(c(C),q) :- debtor(c(C),p). creditor(c(C),p) :- debtor(c(C),q). creditor(c(C),p) :- debtor(c(C),r).
1 { content(c(C),A) : act(A), A != ok ; content(c(C),dq) } 1 :- ck(C).
1 { created(c(C),I) : invocation(I) ; recognized(c(C),0) } 1 :- ck(C).
deadline(c(C),n) :- mode(c(C),achieve).
{ pin(c(C),weights,W) : w(W) } 1 :- ck(C).
{ releases(I,c(C)) : invocation(I) } 1 :- ck(C).
{ gen_rep(C) } :- ck(C).
commitment(rp(C)) :- gen_rep(C). mode(rp(C),achieve) :- gen_rep(C). trigger(rp(C),c(C)) :- gen_rep(C).
reparation(c(C),rp(C)) :- gen_rep(C). content(rp(C),a(1)) :- gen_rep(C). deadline(rp(C),n) :- gen_rep(C).
recognized(rp(C),0) :- gen_rep(C).
1 { debtor(rp(C),E) : ent(E) } 1 :- gen_rep(C).
creditor(rp(C),Q) :- gen_rep(C), creditor(c(C),Q).

:- type_error(_,_).
