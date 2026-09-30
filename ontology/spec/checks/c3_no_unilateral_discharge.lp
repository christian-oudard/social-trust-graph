%% C3. Burdens are sticky (L3): a commitment in force stays in force from one step to the
%% next unless one of these, re-derived here independently, occurred earlier: the
%% creditor's un-injected, non-dual release; the grantor's un-injected revocation (never of
%% a security); a cascade from a revoked ancestor (never onto a security); a warranty's
%% expiry; a security's breach repaired; a resolutive act within range. Swaps, rewrites,
%% copies, feeds, external changes and debtor-side acts are all generated; none may end one.
#include "lib/world.lp".
anc(G2,G1) :- parent_grant(G2,G1).
anc(G3,G1) :- anc(G3,G2), parent_grant(G2,G1).
steered(I) :- induced(I,X), not acts_for(I,X).
legit_end(C,T) :- releases(I,C), at(I,T0), time(T), T > T0, creditor(C,Q), acts_for(I,releasing,Q),
                  debtor(C,P), not acts_for(I,P), not steered(I).
legit_end(G,T) :- revokes(I,G), at(I,T0), time(T), T > T0, debtor(G,P), acts_for(I,revoking,P),
                  not security(G), not steered(I).
legit_end(G,T) :- anc(G,G0), legit_end(G0,T), start(G,T0), T > T0, not security(G).
legit_end(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.
legit_end(G,T) :- security(G), trigger(G,C), repaired(C,_,T1), time(T), T > T1.
legit_end(C,T) :- until(C,A), does(I,A), at(I,T0), time(T), T > T0, in_range(C,I).
cx_dropped(C,T) :- live(C,T), time(T+1), not live(C,T+1), not legit_end(C,T+1).
cx_revived(C,T) :- live(C,T0), T0 < T, not live(C,T), live(C,T+1).
cx :- cx_dropped(_,_). cx :- cx_revived(_,_).
interesting :- live(C,1), swap(_,_), edge(_,_,copy), feeds(_,_), releases(_,_), changed_by(_,_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
