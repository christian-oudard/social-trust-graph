%% C5. Where answerability fails (L8): a commitment nobody answers for, or an orphaned
%% act, arises only from a machine debtor or from a machine invocation that no principal
%% with standing covers for that act. A person's own invocations are always answered.
#include "lib/world.lp".
cx_person_unanswered(C) :- unanswerable(C), created(C,I), body(I,_).
cx_covered_unanswered(C) :- unanswerable(C), created(C,I), content(C,A), acts_for(I,A,P), standing(P).
cx_person_orphan(I,A) :- orphan(I,A), body(I,_).
cx_covered_orphan(I,A) :- orphan(I,A), acts_for(I,A,P), standing(P).
cx :- cx_person_unanswered(_). cx :- cx_covered_unanswered(_). cx :- cx_person_orphan(_,_). cx :- cx_covered_orphan(_,_).
interesting :- unanswerable(c(_)), orphan(_,_).
:- witness_mode, not interesting.
:- not witness_mode, not cx.
