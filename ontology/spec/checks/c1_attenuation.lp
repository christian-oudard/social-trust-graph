%% C1. Attenuation: no machine invocation ever acts for a principal beyond what that
%% principal granted from its own body. Sub-delegation can narrow, never widen.
#include "lib/world.lp".
first_level(P,A) :- grant(G), debtor(G,P), created(G,I0), body(I0,P), within(G,A).
cx_widened(I,A,P) :- acts_for(I,A,P), I = i(_), tp(P), not first_level(P,A).
cx :- cx_widened(_,_,_).
interesting :- parent_grant(d(2),d(1)).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
