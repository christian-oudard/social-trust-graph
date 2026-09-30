%% C5. Where answerability fails (L8): an in-force commitment nobody answers for arises only
%% from a machine debtor; an office always has its appointer; and an act nobody answers for
%% comes only from an invocation no person, org or answerable machine runs, authorizes or steers. A person's
%% own acts are always answered, under every hypothesis.
#include "lib/world.lp".
cx_person_unanswered(C) :- unanswerable(C), debtor(C,D), principal(D), kind(D,K), K != machine.
cx_office(C) :- unanswerable(C), debtor(C,R), role(R), appointer(R,Q), standing(Q).
cx_person_orphan(I,A) :- orphan(I,A), body(I,_).
cx_covered_orphan(I,A) :- orphan(I,A), op(I,P), standing(P).
cx_covered_orphan(I,A) :- orphan(I,A), acts_for(I,A,P), standing(P).
cx :- cx_person_unanswered(_). cx :- cx_office(_). cx :- cx_person_orphan(_,_). cx :- cx_covered_orphan(_,_).
interesting :- orphan(_,_), hyp(delegate), acts_for(_,p).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
