%% X8c (review round 3, formal: R8). Sanitization is a claim about disclosure to anyone.
%% (a) A lab warrants only that w1 never discloses x to Carol. That says nothing about Bob:
%%     knowledge is not cut, so Alice's agent, which talks with Bob, discloses x to him.
principal(alice). kind(alice,person). principal(bob). kind(bob,person). principal(carol). kind(carol,person).
principal(lab). kind(lab,org).
substrate(ba). part(ba,self,opaque(alice)).
substrate(s1). part(s1,weights,w1). part(s1,memory,m1).
substrate(s2). part(s2,weights,w1). part(s2,memory,m2).
commitment(ga). mode(ga,power). debtor(ga,alice). root(ga,alice0). follows(ga,continue). allows(ga,all,0). recognized(ga,0).
invocation(alice0). at(alice0,0). runs(alice0,ba).
commitment(gag). mode(gag,power). debtor(gag,alice). created(gag,alice0). root(gag,a1). follows(gag,continue). allows(gag,all,0).
invocation(a1). at(a1,1). runs(a1,s1). learns(a1,x).
invocation(a2). at(a2,2). runs(a2,s2). edge(a1,a2,continue). with(a2,bob).
act_name(dxb,disclose). act_info(dxb,x). act_target(dxb,bob).
act_name(dxc,disclose). act_info(dxc,x). act_target(dxc,carol).
commitment(nda). mode(nda,avoid). debtor(nda,alice). creditor(nda,bob). content(nda,dxb). recognized(nda,0).
commitment(wl). mode(wl,warrant). debtor(wl,lab). content(wl,dxc). pin(wl,weights,w1). recognized(wl,0).
expect(knows(a2,x)). expect(violated(nda,2)). reject(violated(wl,2)).

% (b) the lab's scrub claim: w1 never discloses y to anyone. It cuts the knowledge, so no
%     disclosure is derived; a recorded leak to Bob still breaks it, and the lab answers
invocation(c1). at(c1,1). runs(c1,s1). learns(c1,y).
invocation(c2). at(c2,2). runs(c2,s2). edge(c1,c2,continue). with(c2,bob).
commitment(gcc). mode(gcc,power). debtor(gcc,alice). created(gcc,alice0). root(gcc,c1). follows(gcc,continue). allows(gcc,all,0).
act_name(dyb,disclose). act_info(dyb,y). act_target(dyb,bob).
act_name(dy,disclose). act_info(dy,y).
commitment(ws). mode(ws,warrant). debtor(ws,lab). content(ws,dy). pin(ws,weights,w1). recognized(ws,0).
reject(knows(c2,y)). reject(does(c2,dyb)).
invocation(c3). at(c3,3). runs(c3,s2). edge(c2,c3,continue). does(c3,dyb).
expect(does(c3,dy)). expect(violated(ws,3)). expect(defection(ws,lab,3)).
