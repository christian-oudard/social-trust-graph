%% world.lp: generator of all small worlds, shared by every check.
%% Bounds: n machine invocations (time = index), g delegated grants, k commitments.
%% Everything the scenarios fix by hand is chosen here, subject to types.lp.
#const n = 3.
#const g = 2.
#const k = 2.

principal(p). kind(p,person). principal(q). kind(q,person). principal(m). kind(m,machine).
substrate(body_p). part(body_p,self,opaque). substrate(body_q). part(body_q,self,opaque).
invocation(p0). at(p0,0). runs(p0,body_p). invocation(q0). at(q0,0). runs(q0,body_q).
body(p0,p). body(q0,q).
commitment(gp). mode(gp,power). debtor(gp,p). root(gp,p0). follows(gp,continue). allows(gp,all,0). founded(gp,0).
commitment(gq). mode(gq,power). debtor(gq,q). root(gq,q0). follows(gq,continue). allows(gq,all,0). founded(gq,0).
% the machine's own root authority, sometimes present
{ gen_mroot }.
commitment(gm) :- gen_mroot. mode(gm,power) :- gen_mroot. debtor(gm,m) :- gen_mroot. root(gm,i(1)) :- gen_mroot.
follows(gm,(continue;copy;merge)) :- gen_mroot. allows(gm,all,0) :- gen_mroot. founded(gm,0) :- gen_mroot.

w(1..2). mm(1..2).
substrate(s(W,M)) :- w(W), mm(M). part(s(W,M),weights,W) :- w(W), mm(M). part(s(W,M),memory,M) :- w(W), mm(M).
ix(1..n). invocation(i(X)) :- ix(X). at(i(X),X) :- ix(X).
1 { runs(i(X),s(W,M)) : w(W), mm(M) } 1 :- ix(X).
ekind(continue;copy;merge).
{ edge(i(X),i(Y),K) : ekind(K) } 1 :- ix(X), ix(Y), X < Y.
tp(p;q).

% delegated grants
gx(1..g). commitment(d(G)) :- gx(G). mode(d(G),power) :- gx(G).
1 { debtor(d(G),P) : tp(P) } 1 :- gx(G).
1 { created(d(G),I) : invocation(I) } 1 :- gx(G).
1 { root(d(G),i(X)) : ix(X) } 1 :- gx(G).
{ follows(d(G),K) : ekind(K) } :- gx(G).
{ pin(d(G),weights,W) : w(W) } 1 :- gx(G).
1 { allows(d(G),pay,C) : C = 1..3 } 1 :- gx(G).
{ allows(d(G),delegate,0) } :- gx(G).
{ revoked(d(G),T) : T = 1..n } 1 :- gx(G).

% acts
act_name(a(X),pay) :- X = 1..3. act_amount(a(X),X) :- X = 1..3. act_name(sp,spam).
act(a(1..3)). act(sp).
{ does(i(X),A) : act(A) } 1 :- ix(X).

% ordinary commitments
ck(1..k). commitment(c(C)) :- ck(C).
1 { mode(c(C),achieve); mode(c(C),avoid) } 1 :- ck(C).
1 { debtor(c(C),P) : tp(P) } 1 :- ck(C).
creditor(c(C),q) :- debtor(c(C),p). creditor(c(C),p) :- debtor(c(C),q).
1 { content(c(C),A) : act(A) } 1 :- ck(C).
1 { created(c(C),I) : invocation(I) } 1 :- ck(C).
deadline(c(C),n) :- mode(c(C),achieve).
{ pin(c(C),weights,W) : w(W) } 1 :- ck(C).
{ released(c(C),T) : T = 1..n } 1 :- ck(C).

:- type_error(_,_).
{ hyp(machine_party) }.
