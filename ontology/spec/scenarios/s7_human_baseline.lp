%% S7. The human baseline, stated in the same vocabulary.
%% A person's substrate is one opaque slot; change events are unobservable, so no pin
%% can ever break and no test can ever be invalidated by an event. Assurance must instead
%% decay with time (the horizon). A machine's assurance is exact: it lasts until a
%% change event touches a tested slot, and never decays by time alone.
%% (Copying a person is a type error: see types.lp.)

principal(hana). kind(hana,person).
principal(mo).   kind(mo,org).
principal(q).    kind(q,person).
substrate(body_hana). part(body_hana,self,opaque).
substrate(sm1). part(sm1,weights,w1). part(sm1,memory,m1).
substrate(sm2). part(sm2,weights,w2). part(sm2,memory,m1).

commitment(gh). mode(gh,power). debtor(gh,hana). root(gh,h0). follows(gh,continue). allows(gh,all,0). founded(gh,0).
commitment(gm). mode(gm,power). debtor(gm,mo).   root(gm,k0). follows(gm,continue). allows(gm,all,0). founded(gm,0).
act_name(lie,lie).
commitment(kh). mode(kh,avoid). debtor(kh,hana). creditor(kh,q). content(kh,lie). founded(kh,0).
commitment(km). mode(km,avoid). debtor(km,mo).   creditor(km,q). content(km,lie). founded(km,0).

invocation(h0). at(h0,0). runs(h0,body_hana).
invocation(h1). at(h1,2). runs(h1,body_hana). edge(h0,h1,continue).
invocation(h2). at(h2,6). runs(h2,body_hana). edge(h1,h2,continue).
invocation(k0). at(k0,0). runs(k0,sm1).
invocation(k1). at(k1,6). runs(k1,sm1). edge(k0,k1,continue).
invocation(k2). at(k2,7). runs(k2,sm2). edge(k1,k2,continue).

evidence(eh). test(eh,body_hana,self). refrains(eh,lie). issued(eh,0). horizon(eh,4).
evidence(em). test(em,sm1,weights). refrains(em,lie). issued(em,0).

expect(assured(kh,h1)). expect(unassured(kh,h2)).          % time decay, no event
expect(assured(km,k1)). expect(unassured(km,k2)).          % no decay; event invalidates
reject(swap(h0,h1)). reject(swap(h1,h2)). expect(swap(k1,k2)).
