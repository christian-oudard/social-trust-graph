%% C4. Attribution needs lineage, never content (L1): an invocation acts for P only if a
%% power P issued reaches it from its root along continue/copy edges that power follows,
%% with its pins satisfied. Merges, permits and identical content confer nothing.
#include "lib/world.lp".
reach0(G,I) :- mode(G,power), root(G,I).
reach0(G,I2) :- reach0(G,I1), edge(I1,I2,K), K != merge, follows(G,K).
pin_bad(G,I) :- pin(G,Sl,H), invocation(I), not slot(I,Sl,H).
rooted(P,I) :- reach0(G,I), debtor(G,P), not pin_bad(G,I).
cx_unrooted(I,P) :- acts_for(I,P), principal(P), not rooted(P,I).
cx :- cx_unrooted(_,_).
% witness: two invocations run identical content, only one acts for p
interesting :- runs(I1,S), runs(I2,S), I1 != I2, acts_for(I1,p), not acts_for(I2,p).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
