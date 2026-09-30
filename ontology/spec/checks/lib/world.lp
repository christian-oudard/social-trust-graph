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

% content, lineage, external change, feeds, learning, injection
w(1..2). mm(1..2).
substrate(s(W,M)) :- w(W), mm(M). part(s(W,M),weights,W) :- w(W), mm(M). part(s(W,M),memory,M) :- w(W), mm(M).
ix(1..n). invocation(i(X)) :- ix(X). at(i(X),X) :- ix(X).
1 { runs(i(X),s(W,M)) : w(W), mm(M) } 1 :- ix(X).
ekind(continue;copy).
{ edge(i(X),i(Y),K) : ekind(K) } 1 :- ix(X), ix(Y), X < Y.
{ feeds(i(X),i(Y)) } :- ix(X), ix(Y), X < Y.
{ changed_by(i(Y),J) : invocation(J), at(J,TJ), TJ < Y } 1 :- ix(Y), edge(_,i(Y),_).
{ learns(i(X),x) : ix(X) } 1.
{ with(i(X),q) } :- ix(X).
{ induced(i(X),P) : tp(P) } 1 :- ix(X).
{ operator(i(X),P) : principal(P) } 1 :- ix(X).
act_name(dq,disclose). act_info(dq,x). act_target(dq,q). act_name(da,disclose). act_info(da,x).

% delegated instruments: powers and permits, possibly conditional, possibly securities
gx(1..g). commitment(d(G)) :- gx(G).
1 { mode(d(G),power); mode(d(G),permit) } 1 :- gx(G).
1 { debtor(d(G),P) : tp(P) } 1 :- gx(G).
{ creditor(d(G),P) : tp(P) } 1 :- gx(G).
1 { created(d(G),I) : invocation(I) } 1 :- gx(G).
1 { root(d(G),I) : invocation(I) } 1 :- gx(G).
{ follows(d(G),continue); follows(d(G),copy) } :- gx(G).
{ pin(d(G),weights,W) : w(W) } 1 :- gx(G).
1 { allows(d(G),pay,C) : C = 1..3 } 1 :- gx(G).
{ allows(d(G),delegate,0); allows(d(G),release,0); allows(d(G),spam,0) } :- gx(G).
{ revokes(I,d(G)) : invocation(I) } 1 :- gx(G).
{ trigger(d(G),ok); trigger(d(G),c(1)) } 1 :- gx(G).
{ until(d(G),swapping) } :- gx(G).
{ under(d(G),H) : commitment(H), H != d(G) } 1 :- gx(G).
act_name(ok,approve).

% acts
act_name(a(X),pay) :- X = 1..3. act_amount(a(X),X) :- X = 1..3. act_name(sp,spam).
act(a(1..3)). act(sp). act(ok).
{ does(I,A) : act(A) } 1 :- invocation(I).

% commitments, possibly owed by a role, possibly with a reparation; warranties
role(r). appointer(r,q). { appoints(q0,P,r,T2) : principal(P), T2 = 2..n+1 } 1.
ent(p;q;r).
ck(1..k). commitment(c(C)) :- ck(C).
1 { mode(c(C),achieve); mode(c(C),avoid); mode(c(C),warrant) } 1 :- ck(C).
1 { debtor(c(C),E) : ent(E) } 1 :- ck(C).
creditor(c(C),q) :- debtor(c(C),p), not mode(c(C),warrant).
creditor(c(C),p) :- debtor(c(C),q), not mode(c(C),warrant).
creditor(c(C),p) :- debtor(c(C),r), not mode(c(C),warrant).
1 { content(c(C),A) : act(A), A != ok ; content(c(C),dq) ; content(c(C),da) } 1 :- ck(C).
1 { created(c(C),I) : invocation(I) ; recognized(c(C),0) } 1 :- ck(C).
deadline(c(C),n) :- mode(c(C),achieve).
pin(c(C),weights,1) :- mode(c(C),warrant).
{ pin(c(C),weights,W) : w(W) } 1 :- ck(C), not mode(c(C),warrant).
{ releases(I,c(C)) : invocation(I) } 1 :- ck(C).
{ until(c(C),swapping) } :- ck(C).
{ gen_rep(C) } :- ck(C), not mode(c(C),warrant).
commitment(rp(C)) :- gen_rep(C). mode(rp(C),achieve) :- gen_rep(C). trigger(rp(C),c(C)) :- gen_rep(C).
content(rp(C),a(1)) :- gen_rep(C). deadline(rp(C),n) :- gen_rep(C). recognized(rp(C),0) :- gen_rep(C).
1 { debtor(rp(C),E) : ent(E) } 1 :- gen_rep(C).
creditor(rp(C),Q) :- gen_rep(C), creditor(c(C),Q).

:- type_error(_,_).
