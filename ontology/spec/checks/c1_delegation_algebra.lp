%% C1. Delegation is an attenuation algebra, in every dimension (L6).
%% Whatever an invocation does under a delegated grant satisfies every caveat of every
%% grant above it: pins, caps, followed edge kinds, and liveness (revocation cascades).
%% The chain and each caveat are re-derived here without the core's helper relations.
#include "lib/world.lp".
ref_cand(G2,G1) :- scoped(G2), created(G2,I), covered(G1,I), mode(G1,power), not security(G1), debtor(G1,P), debtor(G2,P),
                     delegable(G1).
ref_parent(G2,G1) :- ref_cand(G2,G1), not under(G2,_).
ref_parent(G2,G1) :- ref_cand(G2,G1), under(G2,G1).
delegable(G) :- allows(G,delegate,_). delegable(G) :- allows(G,all,_).
cx_parent(G2,G1) :- parent_grant(G2,G1), not ref_parent(G2,G1).
cx_parent(G2,G1) :- ref_parent(G2,G1), not parent_grant(G2,G1).
anc(G2,G1) :- ref_parent(G2,G1).
anc(G3,G1) :- anc(G3,G2), ref_parent(G2,G1).
unrestricted(G) :- allows(G,all,_).
% pins
% (a security is the holder's: it performs the grantor's duty and inherits no pins)
cx_pin(I,G,G0) :- covered(G,I), anc(G,G0), pin(G0,Sl,H), not slot(I,Sl,H), not security(G).
% caps
cx_cap(I,A,G0) :- covered(G,I), mode(G,power), anc(G,G0), not unrestricted(G0), act_name(A,N),
                  within(G,A), act_amount(A,X), allows(G0,N,C0), X > C0.
cx_cap(I,A,G0) :- covered(G,I), mode(G,power), anc(G,G0), not unrestricted(G0), act_name(A,N),
                  within(G,A), not allows(G0,N,_).
% followed kinds: every step from the root uses a kind followed by G and by all its restricted ancestors
blocked(G,K) :- anc(G,G0), ekind(K), not follows(G0,K), not unrestricted(G0).
ref_reach(G,I) :- scoped(G), root(G,I).
ref_reach(G,I2) :- ref_reach(G,I1), edge(I1,I2,K), K != merge, follows(G,K), not blocked(G,K).
cx_reach(G,I) :- covered(G,I), not ref_reach(G,I).
% liveness: a revoked ancestor ends everything below it from the step after the revocation
revoked_at(G,T0) :- revokes(J,G), at(J,T0), debtor(G,P), acts_for(J,revoking,P).
cx_live(I,G,G0) :- covered(G,I), anc(G,G0), revoked_at(G0,T0), at(I,T), T > T0.
cx :- cx_parent(_,_). cx :- cx_pin(_,_,_). cx :- cx_cap(_,_,_). cx :- cx_reach(_,_). cx :- cx_live(_,_,_).
interesting :- anc(d(2),d(1)), pin(d(1),_,_), covered(d(2),_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
