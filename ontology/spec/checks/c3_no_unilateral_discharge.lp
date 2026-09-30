%% C3. No unilateral discharge (T2): a commitment in force stays in force from one step
%% to the next unless its creditor releases it or (for a grant) its grantor revokes it or
%% an ancestor grant is revoked. Substrate swaps, rewrites, rollbacks, forks and merges
%% are all generated and none may end a commitment.
#include "lib/world.lp".
% legitimate endings, defined independently of core's ended_by
anc(G2,G1) :- parent_grant(G2,G1), G2 != G1.
anc(G3,G1) :- anc(G3,G2), anc(G2,G1).
excused_end(C,T) :- released(C,T0), time(T), T >= T0.
excused_end(C,T) :- revoked(C,T0), time(T), T >= T0.
excused_end(C,T) :- anc(C,G), revoked(G,T0), time(T), T >= T0.
cx_dropped(C,T) :- live(C,T), time(T+1), not live(C,T+1), not excused_end(C,T+1).
cx :- cx_dropped(_,_).
interesting :- live(C,1), swap(I1,I2), rollback(_), edge(_,_,copy), edge(_,_,merge).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
