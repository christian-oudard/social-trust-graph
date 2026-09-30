%% C3. Burdens are sticky (L3): a commitment in force stays in force from one step to the
%% next unless its creditor released it, its grantor revoked it (powers and permits), an
%% ancestor grant was revoked, or it is a warranty past its deadline. Swaps, rewrites,
%% rollbacks, forks, merges and debtor-side acts are all generated; none may end one, and
%% nothing ended may come back.
#include "lib/world.lp".
anc(G2,G1) :- parent_grant(G2,G1).
anc(G3,G1) :- anc(G3,G2), parent_grant(G2,G1).
legit_end(C,T) :- releases(I,C), at(I,T0), time(T), T > T0, creditor(C,Q), acts_for(I,releasing,Q).
legit_end(G,T) :- revokes(I,G), at(I,T0), time(T), T > T0, debtor(G,P), acts_for(I,revoking,P).
legit_end(G,T) :- anc(G,G0), legit_end(G0,T), created(G,I), at(I,T0), T > T0.
legit_end(W,T) :- mode(W,warrant), deadline(W,D), time(T), T > D.
cx_dropped(C,T) :- live(C,T), time(T+1), not live(C,T+1), not legit_end(C,T+1).
cx_revived(C,T) :- live(C,T0), T0 < T, not live(C,T), live(C,T+1).
cx :- cx_dropped(_,_). cx :- cx_revived(_,_).
interesting :- live(C,1), swap(_,_), rollback(_), edge(_,_,copy), edge(_,_,merge), releases(_,_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
