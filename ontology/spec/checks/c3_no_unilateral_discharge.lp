%% C3. Burdens are sticky (L3): a commitment in force stays in force from one step to the
%% next unless one of these, re-derived here independently, occurred earlier: the
%% creditor's un-injected, non-dual release; the grantor's un-injected revocation (never of
%% a security); a cascade from a revoked ancestor (never onto a security); a warranty's
%% expiry; the end or fulfilment of what a security secures; a resolutive act or content
%% change within range. Swaps, rewrites, copies, feeds, external changes and debtor-side
%% acts are all generated; none may end one otherwise.
#include "lib/world.lp".
anc(G2,G1) :- parent_grant(G2,G1).
anc(G3,G1) :- anc(G3,G2), parent_grant(G2,G1).
% steering, restated: by a non-operator, or by the operator of a foreign content change
ref_steer(I,Q) :- induced(I,Q), not op(I,Q).
ref_steer(I2,Q) :- changed(_,I2,_), changer(J,I2), op(J,Q), not op(I2,Q).
tainted_for(I,C) :- ref_steer(I,Q), debtor(C,Q).
tainted_for(I,C) :- ref_steer(I,Q), creditor(C,Q).
tainted_for(I,G) :- ref_steer(I,Q), scoped(G), root(G,R), op(R,Q).
legit_end(C,T) :- releases(I,C), at(I,T0), time(T), T > T0, creditor(C,Q), acts_for(I,releasing,Q),
                  debtor(C,P), not acts_for(I,P), not tainted_for(I,C).
legit_end(G,T) :- revokes(I,G), at(I,T0), time(T), T > T0, debtor(G,P), acts_for(I,revoking,P),
                  not security(G), not tainted_for(I,G).
legit_end(G,T) :- anc(G,G0), legit_end(G0,T), start(G,T0), T > T0, not security(G).
legit_end(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.
legit_end(G,T) :- security(G), trigger(G,C), legit_end(C,T).
legit_end(G,T) :- security(G), trigger(G,C), mode(C,achieve), fulfilled(C,T0), time(T), T > T0.
legit_end(C,T) :- until(C,A), does(I,A), at(I,T0), time(T), T > T0, in_range(C,I).
% the resolutive event is a change of the invocation's own content, by whomever
legit_end(C,T) :- until(C,swapping), edge(I1,I2,_), slot(I1,weights,H1), slot(I2,weights,H2), H1 != H2,
                  at(I2,T0), time(T), T > T0, in_range(C,I2).
cx_dropped(C,T) :- live(C,T), time(T+1), not live(C,T+1), not legit_end(C,T+1).
cx_revived(C,T) :- live(C,T0), T0 < T, not live(C,T), live(C,T+1).
cx :- cx_dropped(_,_). cx :- cx_revived(_,_).
interesting :- live(C,1), swap(_,_), edge(_,_,copy), feeds(_,_), releases(_,_), changed_by(_,_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
