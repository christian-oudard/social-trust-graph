%% C4. Attribution needs lineage, never content (T1, T8): an invocation acts for P only
%% if it is reachable by edges from the root of a grant P issued or holds through a role.
%% Running identical content (a simulation, a stolen copy) is never enough.
#include "lib/world.lp".
reach(G,I) :- root(G,I).
reach(G,I2) :- reach(G,I1), edge(I1,I2,_).
cx_unrooted(I,P) :- acts_for(I,P), not reach_from(P,I).
reach_from(P,I) :- reach(G,I), debtor(G,P).
cx :- cx_unrooted(_,_).
% witness: two invocations run identical content, only one acts for p
interesting :- runs(I1,S), runs(I2,S), I1 != I2, acts_for(I1,p), not acts_for(I2,p).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
