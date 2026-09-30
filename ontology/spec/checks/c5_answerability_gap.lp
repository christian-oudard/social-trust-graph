%% C5. Where answerability fails (L8): a commitment nobody answers for arises only from a
%% machine debtor, from an invocation no principal with standing answers for, or from an
%% office with no answerable holder and no appointer. A person's own acts are always
%% answered, under every hypothesis.
#include "lib/world.lp".
cx_person_unanswered(C) :- unanswerable(C), created(C,I), body(I,_), not role(D), debtor(C,D).
cx_person_unanswered(C) :- unanswerable(C), created(C,I), body(I,_), debtor(C,D), principal(D).
cx_covered_unanswered(C) :- unanswerable(C), created(C,I), content(C,A), acts_for(I,A,P), standing(P),
                            debtor(C,D), principal(D).
cx_office(C) :- unanswerable(C), debtor(C,R), role(R), appointer(R,Q), standing(Q), in_force(C).
cx_person_orphan(I,A) :- orphan(I,A), body(I,_).
cx :- cx_person_unanswered(_). cx :- cx_covered_unanswered(_). cx :- cx_office(_). cx :- cx_person_orphan(_,_).
interesting :- unanswerable(c(_)), orphan(_,_), hyp(delegate).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
