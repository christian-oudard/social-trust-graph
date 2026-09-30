%% S7. The human baseline, stated in the same vocabulary.
%% A person's content is one opaque slot, opaque(Id), unique to its bearer. Change is
%% unobservable, so no pin on a person ever breaks by an event, a person can never be
%% "rolled back" (so never forgets), and a warranty about a person (a reference) must
%% expire. A machine's warranty is exact: it covers until a pinned slot changes, and never
%% decays by time alone. Copying a person is a type error (see types.lp).

principal(hana). kind(hana,person).
principal(bo).   kind(bo,person).
principal(ref).  kind(ref,person).        % gives Hana a character reference
principal(mo).   kind(mo,org).
principal(lab).  kind(lab,org).
principal(q).    kind(q,person).
substrate(body_hana). part(body_hana,self,opaque(hana)).
substrate(body_bo).   part(body_bo,self,opaque(bo)).
substrate(body_ref).  part(body_ref,self,opaque(ref)).
substrate(sm1). part(sm1,weights,w1). part(sm1,memory,m1).
substrate(sm2). part(sm2,weights,w2). part(sm2,memory,m1).

commitment(gh). mode(gh,power). debtor(gh,hana). root(gh,h0). follows(gh,continue). allows(gh,all,0). recognized(gh,0).
commitment(gbo). mode(gbo,power). debtor(gbo,bo). root(gbo,b0). follows(gbo,continue). allows(gbo,all,0). recognized(gbo,0).
commitment(gm). mode(gm,power). debtor(gm,mo).   root(gm,k0). follows(gm,continue). allows(gm,all,0). recognized(gm,0).
act_name(lie,lie).
act_name(dxs,disclose). act_info(dxs,xs). act_target(dxs,q).
commitment(kh). mode(kh,avoid). debtor(kh,hana). creditor(kh,q). content(kh,lie). recognized(kh,0).
commitment(kb). mode(kb,avoid). debtor(kb,bo).   creditor(kb,q). content(kb,lie). recognized(kb,0).
commitment(km). mode(km,avoid). debtor(km,mo).   creditor(km,q). content(km,lie). recognized(km,0).
commitment(kx). mode(kx,avoid). debtor(kx,hana). creditor(kx,bo). content(kx,dxs). recognized(kx,0).

invocation(h0). at(h0,0). runs(h0,body_hana). learns(h0,xs).
invocation(h1). at(h1,2). runs(h1,body_hana). edge(h0,h1,continue).
invocation(h2). at(h2,6). runs(h2,body_hana). edge(h1,h2,continue). with(h2,q).
invocation(b0). at(b0,2). runs(b0,body_bo).
invocation(k0). at(k0,0). runs(k0,sm1).
invocation(k1). at(k1,6). runs(k1,sm1). edge(k0,k1,continue).
invocation(k2). at(k2,7). runs(k2,sm2). edge(k1,k2,continue).

% a reference for Hana (expires after t3) and an evaluator's warranty for weights w1
commitment(wref). mode(wref,warrant). debtor(wref,ref). content(wref,lie). pin(wref,self,opaque(hana)).
  deadline(wref,3). recognized(wref,0).
commitment(wlab). mode(wlab,warrant). debtor(wlab,lab). content(wlab,lie). pin(wlab,weights,w1). recognized(wlab,0).

% audit: complete records of the machine's steps before the swap, kept by the lab
recorded(k0,lab). recorded(k1,lab).

expect(assured(kh,h1)). expect(unassured(kh,h2)).          % the reference expired: time, not an event
reject(assured(kb,b0)).                                    % Hana's reference says nothing about Bo
expect(assured(km,k1)). expect(unassured(km,k2)).          % no decay; the swap ends it
reject(swap(h0,h1)). reject(swap(h1,h2)). expect(swap(k1,k2)).
% persons do not forget: the secret Hana learned at t0 is still hers at t6
expect(knows(h2,xs)). reject(scrubbed(h1,xs)). expect(violated(kx,6)).
% audit: silence is not conformance
expect(clear(km,6)). reject(clear(km,7)). reject(clear(kh,1)).
