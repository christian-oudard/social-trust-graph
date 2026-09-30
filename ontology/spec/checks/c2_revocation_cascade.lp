%% C2. Revocation cascades: once any grant in a delegation chain is revoked, no
%% invocation acts under any grant below it.
#include "lib/world.lp".
below(G2,G1) :- parent_grant(G2,G1), G2 != G1.
below(G3,G1) :- below(G3,G2), below(G2,G1).
cx_after_revoke(I,G,G0) :- covered(G,I), below(G,G0), revoked(G0,T0), at(I,T), T >= T0.
cx :- cx_after_revoke(_,_,_).
interesting :- below(d(2),d(1)), revoked(d(1),_), covered(d(2),_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
