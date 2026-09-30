//! Rust (ascent) port of spec/core.lp v0.3, evaluated as a per-step fold.
//!
//! core.lp is not stratified at the predicate level; every cycle through negation passes
//! through an earlier time step. Here each step t is one run of a predicate-stratified
//! ascent program: relations suffixed `_h` hold what earlier steps derived, and the
//! program derives what holds at step t (for invocations at t, commitments at t).
//! Relation names and rules follow core.lp one to one; see ../spec/core.lp for comments.
//!
//! Input: JSON facts on stdin, as produced by ../spec/crosscheck.py. The first argument
//! names the hypothesis (delegate | actor | party). Output: derived atoms, clingo syntax.

use ascent::ascent;
use std::collections::{BTreeSet, HashMap, HashSet};
use std::io::Read;

type S = &'static str;

ascent! {
    struct Core;

    // ---------------- base relations ----------------
    relation now(i64); relation time(i64); relation hyp(S);
    relation principal(S); relation kind(S, S); relation role(S);
    relation invocation(S); relation at(S, i64); relation runs(S, S); relation part(S, S, S);
    relation edge(S, S, S); relation changed_by(S, S); relation does_base(S, S); relation with(S, S);
    relation learns(S, S); relation feeds(S, S); relation induced(S, S); relation recorded(S, S);
    relation act_name(S, S); relation act_amount(S, i64); relation act_obj(S, S); relation exclusive(S);
    relation act_info(S, S); relation act_target(S, S);
    relation commitment(S); relation debtor(S, S); relation creditor(S, S); relation mode(S, S);
    relation content(S, S); relation deadline(S, i64); relation pin4(S, S, S, S); relation trigger(S, S);
    relation until(S, S); relation created(S, S); relation recognized(S, i64); relation releases(S, S);
    relation revokes(S, S); relation root(S, S); relation follows(S, S); relation allows(S, S, i64);
    relation under(S, S); relation appointer(S, S); relation appoints(S, S, S, i64); relation operator(S, S);

    // ---------------- history from earlier steps ----------------
    relation parent_grant_h(S, S); relation valid_creation_h(S); relation scope_h(S, S, i64);
    relation violated_h(S, i64); relation performs_h(S, S, i64); relation acts_for3_h(S, S, S);
    relation acts_for2_h(S, S);
    relation defection_h(S, S, i64); relation unaudited_exposure_h(S, i64); relation knows_h(S, S);
    relation disclose_h(S, S); relation conduct_of_h(S, S, S); relation live_h(S, i64);
    relation repaired_h(S, i64, i64);
    relation holder_h(S, S, i64); relation fulfilled_h(S, i64);

    // ================= 0. capacities =================
    relation cap(S); relation bundle(S, S); relation capacity(S, S); relation standing(S);
    capacity(p, c) <-- kind(p, k), if *k == "person", cap(c);
    capacity(p, c) <-- kind(p, k), if *k == "org", cap(c);
    capacity(p, c) <-- kind(p, k), if *k == "machine", hyp(h), bundle(h, c);
    standing(p) <-- capacity(p, c), if *c == "owe";

    // ================= 1. content and lineage (static) =================
    relation slot(S, S, S); relation opaque_inv(S); relation changed(S, S, S); relation swap(S, S);
    relation rewrite(S, S); relation ancestor(S, S); relation external(S); relation changer(S, S);
    slot(i, sl, h) <-- runs(i, s), part(s, sl, h);
    opaque_inv(i) <-- slot(i, _, h), if h.starts_with("opaque(");
    changed(i1, i2, sl) <-- edge(i1, i2, _), slot(i1, sl, h), !slot(i2, sl, h);
    changed(i1, i2, sl) <-- edge(i1, i2, _), slot(i2, sl, h), !slot(i1, sl, h);
    swap(i1, i2) <-- changed(i1, i2, sl), if *sl == "weights";
    rewrite(i1, i2) <-- changed(i1, i2, sl), if *sl == "memory";
    ancestor(a, b) <-- edge(a, b, _);
    ancestor(a, c) <-- ancestor(a, b), edge(b, c, _);
    external(i2) <-- changed_by(i2, _);
    changer(i1, i2) <-- edge(i1, i2, _), !external(i2);
    changer(j, i2) <-- changed_by(i2, j);

    relation does_static(S, S);
    does_static(i, a) <-- does_base(i, a);
    does_static(i1, "copying") <-- edge(i1, _, k), if *k == "copy";
    does_static(j, "swapping") <-- swap(_, i2), changer(j, i2);
    does_static(j, "rewriting") <-- rewrite(_, i2), changer(j, i2);
    does_static(i, "releasing") <-- releases(i, _);
    does_static(i, "revoking") <-- revokes(i, _);
    does_static(i, "appointing") <-- appoints(i, _, _, _);

    // ================= 2. life of a commitment =================
    relation scoped(S); relation grant(S); relation reparation(S, S); relation security(S); relation void(S);
    scoped(g) <-- mode(g, m), if *m == "power" || *m == "permit";
    grant(g) <-- mode(g, m), if *m == "power";
    reparation(c, c2) <-- trigger(c2, c), commitment(c), !scoped(c2);
    security(g) <-- grant(g), trigger(g, c), commitment(c), debtor(g, p), debtor(c, p), creditor(g, q), creditor(c, q);
    void(c) <-- debtor(c, p), principal(p), !scoped(c), !capacity(p, "owe");
    void(c) <-- scoped(c), recognized(c, _), debtor(c, p), principal(p), !capacity(p, "owe");
    void(c) <-- scoped(c), created(c, _), debtor(c, p), principal(p), !capacity(p, "claim");
    void(c) <-- creditor(c, q), principal(q), !capacity(q, "claim");

    relation start(S, i64); relation ended_by(S, i64); relation live(S, i64); relation does_past(S, S);
    start(c, t) <-- created(c, i), at(i, t);
    start(c, t) <-- recognized(c, t);
    does_past(i, a) <-- does_static(i, a);
    does_past(i, a) <-- disclose_h(i, a);
    ended_by(c, t) <-- now(t), releases(i, c), at(i, t0), if t > t0, creditor(c, q), acts_for3_h(i, "releasing", q),
                       debtor(c, p), !acts_for2_h(i, p), !vitiated(i, c);
    ended_by(g, t) <-- now(t), revokes(i, g), at(i, t0), if t > t0, debtor(g, p), acts_for3_h(i, "revoking", p),
                       !security(g), !vitiated(i, g);
    ended_by(g2, t) <-- parent_grant_h(g2, g1), ended_by(g1, t), start(g2, t0), if t > t0, !security(g2);
    ended_by(w, t) <-- now(t), mode(w, m), if *m == "warrant", deadline(w, d), if t > d;
    ended_by(g, t) <-- security(g), trigger(g, c), ended_by(c, t);
    ended_by(g, t) <-- now(t), security(g), trigger(g, c), mode(c, m), if *m == "achieve", fulfilled_h(c, t0), if t > t0;
    ended_by(c, t) <-- now(t), until(c, a), does_past(i, a), at(i, t0), if t > t0, start(c, ts), if ts <= t0,
                       in_range(c, i);
    ended_by(c, t) <-- now(t), until(c, a), changed_to(i, a), at(i, t0), if t > t0, start(c, ts), if ts <= t0,
                       in_range(c, i);
    relation changed_to(S, S);
    changed_to(i2, "swapping") <-- swap(_, i2);
    changed_to(i2, "rewriting") <-- rewrite(_, i2);
    relation in_range(S, S);
    in_range(c, i) <-- scoped(c), in_lineage(c, i);
    in_range(c, i) <-- commitment(c), !scoped(c), debtor(c, p), answers_for(i, p);
    in_range(c, i) <-- commitment(c), !scoped(c), debtor(c, r), role(r), holder_all(r, p, ti), at(i, ti),
                       answers_for(i, p);
    live(c, t) <-- now(t), recognized(c, t0), if t >= t0, !ended_by(c, t), !void(c);
    live(c, t) <-- now(t), created(c, i), at(i, t0), if t > t0, valid_creation_h(c), !ended_by(c, t), !void(c);

    relation trigger_party(S, S); relation has_trigger(S); relation detached(S, i64);
    trigger_party(c, q) <-- creditor(c, q), !scoped(c);
    trigger_party(g, p) <-- scoped(g), debtor(g, p);
    has_trigger(c) <-- trigger(c, _);
    detached(c, t) <-- live(c, t), !has_trigger(c);
    detached(c, t) <-- live(c, t), trigger(c, c0), violated_h(c0, t0), if t0 < t, !security(c);
    detached(g, t) <-- live(g, t), security(g), trigger(g, c), violated_h(c, t0), if t0 < t, !repaired_h(c, t0, t - 1);
    detached(c, t) <-- live(c, t), trigger(c, a), act_name(a, _), trigger_party(c, q), does_past(i, a),
                       acts_for3_h(i, a, q), at(i, t0), if t0 < t, start(c, ts), if ts <= t0, !vitiated(i, c);

    // ================= 3. attribution =================
    relation in_lineage(S, S); relation eff_follows(S, S); relation grant_has_parent(S);
    grant_has_parent(g) <-- parent_grant_h(g, _);
    in_lineage(g, i) <-- scoped(g), root(g, i);
    in_lineage(g, i2) <-- in_lineage(g, i1), edge(i1, i2, k), eff_follows(g, k);
    eff_follows(g, k) <-- follows(g, k), !grant_has_parent(g);
    eff_follows(g2, k) <-- follows(g2, k), parent_grant_h(g2, g1), eff_follows(g1, k);
    eff_follows(g2, k) <-- follows(g2, k), parent_grant_h(g2, g1), recognized(g1, _), allows(g1, all, _), if *all == "all";

    relation has_pin(S); relation config_miss(S, S, S); relation on_pin(S, S); relation off_pin(S, S);
    relation eff_off_pin(S, S);
    has_pin(c) <-- pin4(c, _, _, _);
    config_miss(c, k, i) <-- pin4(c, k, sl, h), invocation(i), !slot(i, sl, h);
    on_pin(c, i) <-- pin4(c, k, _, _), invocation(i), !config_miss(c, k, i);
    off_pin(c, i) <-- has_pin(c), invocation(i), !on_pin(c, i);
    eff_off_pin(g, i) <-- off_pin(g, i);
    eff_off_pin(g2, i) <-- parent_grant_h(g2, g1), eff_off_pin(g1, i), !security(g2);

    relation covered(S, S);
    covered(g, i) <-- now(t), at(i, t), in_lineage(g, i), !eff_off_pin(g, i), detached(g, t);

    relation candidate_parent(S, S); relation cites(S); relation parent_grant(S, S); relation may_delegate(S);
    relation scope(S, S, i64); relation has_amount(S); relation within(S, S);
    candidate_parent(g2, g1) <-- scoped(g2), created(g2, i), covered(g1, i), grant(g1), !security(g1),
                                 debtor(g1, p), debtor(g2, p), may_delegate(g1);
    cites(g) <-- under(g, _);
    parent_grant(g2, g1) <-- candidate_parent(g2, g1), !cites(g2);
    parent_grant(g2, g1) <-- candidate_parent(g2, g1), under(g2, g1);
    may_delegate(g) <-- scope(g, n, _), if *n == "delegate" || *n == "all";
    scope(g, n, cap) <-- allows(g, n, cap), recognized(g, _);
    scope(g, n, cap) <-- scope_h(g, n, cap);
    scope(g2, n, cap) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, n, cap1), if cap <= cap1;
    scope(g2, n, cap1) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, n, cap1), if cap > cap1;
    scope(g2, n, cap) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, all, _), if *all == "all";
    has_amount(a) <-- act_amount(a, _);
    within(g, a) <-- scope(g, n, cap), act_name(a, n), act_amount(a, x), if x <= cap;
    within(g, a) <-- scope(g, n, cap), if *cap == 0, act_name(a, n), !has_amount(a);
    within(g, a) <-- scope(g, all, _), if *all == "all", act_name(a, _);

    relation acts_for2(S, S); relation acts_for3(S, S, S); relation permitted(S, S, S); relation secures(S, S, S);
    acts_for2(i, p) <-- covered(g, i), grant(g), !security(g), debtor(g, p);
    acts_for3(i, a, p) <-- covered(g, i), grant(g), !security(g), debtor(g, p), within(g, a);
    acts_for3(i, a, r) <-- grant(g), debtor(g, r), role(r), within(g, a), holder(r, p, t), now(t), at(i, t),
                           acts_for3(i, a, p), detached(g, t), !off_pin(g, i);
    permitted(i, a, q) <-- covered(g, i), mode(g, m), if *m == "permit", debtor(g, q), within(g, a);
    secures(i, a, p) <-- covered(g, i), security(g), debtor(g, p), within(g, a), trigger(g, c), reparation(c, r),
                         content(r, a);

    // operation (static): who runs an invocation
    relation op_set(S); relation has_parent(S); relation op(S, S);
    relation answers_for(S, S); relation conduct_of(S, S, S); relation exposed(S, S);
    op_set(i) <-- operator(i, _);
    op_set(i) <-- root(g, i), recognized(g, _);
    has_parent(i) <-- edge(_, i, _);
    relation has_operator(S);
    has_operator(i) <-- operator(i, _);
    op(i, p) <-- operator(i, p);
    op(i, p) <-- root(g, i), recognized(g, _), debtor(g, p), !has_operator(i);
    op(i, p) <-- root(g, i), grant(g), created(g, _), debtor(g, p), !op_set(i), !has_parent(i);
    op(i2, p) <-- edge(i1, i2, k), if *k == "continue", op(i1, p), !op_set(i2);
    op(i2, p) <-- edge(_, i2, k), if *k == "copy", changer(j, i2), answers_for(j, p), !op_set(i2);
    answers_for(i, p) <-- op(i, p);
    answers_for(i, p) <-- induced(i, p);
    conduct_of(i, a, p) <-- answers_for(i, p), does(i, a);
    conduct_of(i, a, p) <-- acts_for3(i, a, p), does(i, a);
    conduct_of(i, a, p) <-- secures(i, a, p), does(i, a);
    exposed(i, p) <-- answers_for(i, p);
    exposed(i, p) <-- acts_for2(i, p);

    // vitiation (static)
    relation steered(S, S); relation party(S, S); relation vitiated(S, S);
    steered(i, q) <-- induced(i, q), !op(i, q);
    steered(i2, q) <-- changed(_, i2, _), changer(j, i2), op(j, q), !op(i2, q);
    party(c, q) <-- debtor(c, q);
    party(c, q) <-- creditor(c, q);
    party(g, q) <-- scoped(g), root(g, r), op(r, q);
    vitiated(i, c) <-- steered(i, q), party(c, q);

    relation can_grant(S, S); relation valid_creation(S); relation unauthorized(S);
    can_grant(i, p) <-- covered(g, i), grant(g), !security(g), debtor(g, p), may_delegate(g);
    valid_creation(c) <-- now(t), created(c, i), at(i, t), debtor(c, e), content(c, a), acts_for3(i, a, e),
                          !scoped(c), !vitiated(i, c);
    valid_creation(g) <-- now(t), scoped(g), created(g, i), at(i, t), debtor(g, p), can_grant(i, p), !vitiated(i, g),
                          !bad_cite(g);
    relation bad_cite(S);
    bad_cite(g) <-- now(t), created(g, i), at(i, t), under(g, g1), !candidate_parent(g, g1);
    unauthorized(c) <-- now(t), created(c, i), at(i, t), !valid_creation(c);

    // ================= 4. roles and binding =================
    relation holder(S, S, i64); relation held(S, i64); relation vacant(S, i64); relation bound(S, S, i64);
    relation charter(S, S);
    holder(r, p, t) <-- now(t), appoints(i, p, r, t2), at(i, t0), appointer(r, q), acts_for3_h(i, "appointing", q),
                        !steered(i, p), if t > t0 && t < t2, capacity(p, "owe");
    held(r, t) <-- holder(r, _, t);
    vacant(r, t) <-- now(t), role(r), !held(r, t);
    bound(c, p, t) <-- detached(c, t), debtor(c, p), principal(p), !scoped(c);
    bound(c, p, t) <-- detached(c, t), debtor(c, r), role(r), holder(r, p, t), !scoped(c);
    charter(r, c) <-- debtor(c, r), role(r);

    // ================= 5. conformance and knowledge =================
    relation sanitized(S, S); relation knows(S, S); relation disclose(S, S); relation does(S, S);
    relation targeted(S);
    targeted(a) <-- act_target(a, _);
    sanitized(i, x) <-- mode(w, m), if *m == "warrant", content(w, a), act_name(a, n), if *n == "disclose",
                        act_info(a, x), !targeted(a), on_pin(w, i), now(t), at(i, t), detached(w, t);
    knows(i, x) <-- now(t), at(i, t), learns(i, x);
    knows(i2, x) <-- now(t), at(i2, t), knows_h(i1, x), edge(i1, i2, _), !sanitized(i2, x);
    knows(i2, x) <-- now(t), at(i2, t), knows_h(i1, x), feeds(i1, i2), !sanitized(i2, x);
    disclose(i, a) <-- act_name(a, n), if *n == "disclose", act_info(a, x), act_target(a, q), knows(i, x), with(i, q);
    disclose(i, a) <-- act_name(a, n), if *n == "disclose", act_info(a, x), !targeted(a), does(i, a2),
                       act_name(a2, n2), if *n2 == "disclose", act_info(a2, x), targeted(a2);
    does(i, a) <-- does_static(i, a);
    does(i, a) <-- disclose(i, a);
    does(i, a) <-- disclose_h(i, a);

    relation performs(S, S, i64); relation excused(S, S); relation fulfilled(S, i64);
    relation violated(S, i64); relation violator(S, S); relation overcommitted(S, S, S);
    performs(c, i, t) <-- bound(c, p, t), content(c, a), does(i, a), at(i, t), conduct_of(i, a, p),
                          !excused(c, i), !off_pin(c, i);
    excused(c, i) <-- mode(c, m), if *m == "avoid", creditor(c, q), content(c, a), permitted(i, a, q);
    excused(c, i) <-- now(t), at(i, t), mode(c, m), if *m == "avoid" || *m == "warrant", creditor(c, q), induced(i, q);
    fulfilled(c, t) <-- now(t), mode(c, m), if *m == "achieve", performs(c, _, t);
    fulfilled(c, t) <-- now(t), mode(c, m), if *m == "achieve", performs_h(c, _, _);
    violated(c, t) <-- mode(c, m), if *m == "avoid", performs(c, _, t);
    violated(c, d) <-- now(d), mode(c, m), if *m == "achieve", deadline(c, d), detached(c, d), !fulfilled(c, d);
    violated(w, t) <-- mode(w, m), if *m == "warrant", detached(w, t), content(w, a), does(i, a), at(i, t),
                       on_pin(w, i), !excused(w, i);
    violator(c, i) <-- mode(c, m), if *m == "avoid", performs(c, i, _);
    overcommitted(p, c1, c2) <-- mode(c1, m1), mode(c2, m2), if *m1 == "achieve" && *m2 == "achieve" && c1 < c2,
                                 content(c1, a1), content(c2, a2), act_obj(a1, o), act_obj(a2, o), exclusive(o),
                                 bound(c1, p, t), bound(c2, p, t);

    relation audited(S); relation unaudited_exposure(S, i64); relation violated_by_time(S, i64); relation clear(S, i64);
    audited(i) <-- recorded(i, k), standing(k);
    unaudited_exposure(c, t) <-- now(t), unaudited_exposure_h(c, _);
    unaudited_exposure(c, t) <-- now(t), mode(c, m), if *m == "avoid", bound(c, p, t), exposed(i, p), at(i, t),
                                 !off_pin(c, i), !audited(i);
    violated_by_time(c, t) <-- violated(c, t);
    violated_by_time(c, t) <-- now(t), violated_h(c, _);
    clear(c, t) <-- mode(c, m), if *m == "avoid", detached(c, t), !violated_by_time(c, t), !unaudited_exposure(c, t);

    // ================= 6. assurance =================
    relation assured(S, S); relation unassured(S, S);
    assured(c, i) <-- mode(c, m), if *m == "avoid", content(c, a), bound(c, p, t), acts_for2(i, p), at(i, t),
                      mode(w, mw), if *mw == "warrant", content(w, a), detached(w, t), on_pin(w, i), debtor(w, e),
                      standing(e), !exposed(i, e);
    unassured(c, i) <-- mode(c, m), if *m == "avoid", bound(c, p, t), acts_for2(i, p), at(i, t), !assured(c, i);

    // ================= 7. answerability, defection, repair, succession =================
    relation valid_creation_all(S); relation defection_all(S, S, i64); relation violated_all(S, i64);
    relation performs_all(S, S, i64); relation conduct_of_all(S, S, S); relation live_all(S, i64);
    relation holder_all(S, S, i64);
    valid_creation_all(c) <-- valid_creation(c); valid_creation_all(c) <-- valid_creation_h(c);
    defection_all(c, p, t) <-- defection(c, p, t); defection_all(c, p, t) <-- defection_h(c, p, t);
    violated_all(c, t) <-- violated(c, t); violated_all(c, t) <-- violated_h(c, t);
    performs_all(c, i, t) <-- performs(c, i, t); performs_all(c, i, t) <-- performs_h(c, i, t);
    conduct_of_all(i, a, p) <-- conduct_of(i, a, p); conduct_of_all(i, a, p) <-- conduct_of_h(i, a, p);
    live_all(c, t) <-- live(c, t); live_all(c, t) <-- live_h(c, t);
    holder_all(r, p, t) <-- holder(r, p, t); holder_all(r, p, t) <-- holder_h(r, p, t);

    relation in_force(S); relation answerer(S, S); relation answered(S, S); relation orphan(S, S);
    relation secured(S); relation unanswerable(S);
    in_force(c) <-- valid_creation_all(c), !void(c);
    in_force(c) <-- recognized(c, _), !void(c);
    answerer(c, p) <-- in_force(c), debtor(c, p), principal(p), standing(p);
    answerer(c, p) <-- in_force(c), debtor(c, r), role(r), holder_all(r, p, t), live_all(c, t), standing(p);
    answerer(c, q) <-- in_force(c), debtor(c, r), role(r), appointer(r, q), standing(q);
    answered(i, a) <-- conduct_of_all(i, a, p), standing(p);
    orphan(i, a) <-- does(i, a), !answered(i, a);
    secured(c) <-- reparation(c, c2), answerer(c2, _);
    unanswerable(c) <-- in_force(c), !scoped(c), !answerer(c, _), !secured(c);

    relation defection(S, S, i64); relation answered_breach(S, i64); relation unanswered_breach(S, i64);
    relation repaired(S, i64, i64); relation repaired_all(S, i64, i64); relation bond(S, S);
    relation continuation_of(S, S, i64); relation open_defection(S, i64); relation in_good_standing(S, i64);
    defection(c, p, t) <-- violated(c, t), debtor(c, p), principal(p);
    defection(c, p, t) <-- violated(c, t), mode(c, m), if *m == "avoid", debtor(c, r), role(r), holder(r, p, t),
                           performs(c, i, t), content(c, a), conduct_of_all(i, a, p);
    defection(c, p, t) <-- violated(c, t), mode(c, m), if *m != "avoid", debtor(c, r), role(r), holder(r, p, t);
    defection(c, q, t) <-- violated(c, t), debtor(c, r), role(r), vacant(r, t), appointer(r, q);
    answered_breach(c, t) <-- defection_all(c, p, t), standing(p);
    answered_breach(c, t) <-- violated_all(c, t), secured(c);
    unanswered_breach(c, t) <-- violated_all(c, t), !answered_breach(c, t);
    repaired(c, t0, t) <-- now(t), violated_all(c, t0), reparation(c, c2), performs_all(c2, _, tp), if t0 <= tp && tp <= t;
    repaired(c, t0, t) <-- violated_all(c, t0), reparation(c, c2), violated_all(c2, t1), if t0 <= t1, repaired(c2, t1, t);
    repaired_all(c, t0, t) <-- repaired(c, t0, t); repaired_all(c, t0, t) <-- repaired_h(c, t0, t);
    bond(c, c2) <-- reparation(c, c2), debtor(c, p), debtor(c2, q), if p != q;
    continuation_of(p2, p1, t2) <-- edge(i1, i2, k), if *k == "continue", op(i1, p1), op(i2, p2), !op(i1, p2),
                                    if p1 != p2, at(i2, t2);
    open_defection(p, t) <-- now(t), defection_all(c, p, t0), if t0 <= t, !repaired(c, t0, t);
    open_defection(p2, t) <-- continuation_of(p2, p1, t2), open_defection(p1, t), if t >= t2;
    in_good_standing(p, t) <-- now(t), principal(p), !open_defection(p, t);
}

#[derive(Clone, Copy)]
enum V {
    I(i64),
    S(S),
}

fn leak(s: &str) -> S {
    Box::leak(s.to_string().into_boxed_str())
}

fn main() {
    let hyp_arg = std::env::args().nth(1).unwrap_or_else(|| "delegate".into());
    let hyp: S = leak(&hyp_arg);
    let mut buf = String::new();
    std::io::stdin().read_to_string(&mut buf).unwrap();
    let json: serde_json::Value = serde_json::from_str(&buf).unwrap();
    let hz: i64 = json["horizon"].as_i64().unwrap_or(12);

    let mut interned: HashMap<String, S> = HashMap::new();
    let mut facts: Vec<(String, Vec<V>)> = Vec::new();
    for f in json["facts"].as_array().unwrap() {
        let name = f[0].as_str().unwrap().to_string();
        let args = f[1]
            .as_array()
            .unwrap()
            .iter()
            .map(|a| match a.as_i64() {
                Some(n) => V::I(n),
                None => {
                    let s = a.as_str().unwrap();
                    V::S(*interned.entry(s.to_string()).or_insert_with(|| leak(s)))
                }
            })
            .collect();
        facts.push((name, args));
    }

    let mut out: BTreeSet<String> = BTreeSet::new();
    let mut hist = Core::default();
    for t in 0..=hz {
        let mut p = Core::default();
        load(&mut p, &facts, hz, hyp);
        p.now = vec![(t,)];
        macro_rules! feed { ($($h:ident),*) => { $( p.$h = hist.$h.clone(); )* } }
        feed!(parent_grant_h, valid_creation_h, scope_h, violated_h, performs_h, acts_for3_h, acts_for2_h,
              defection_h, unaudited_exposure_h, knows_h, disclose_h, conduct_of_h,
              live_h, repaired_h, holder_h, fulfilled_h);
        p.run();
        extend(&mut hist.parent_grant_h, &p.parent_grant);
        extend(&mut hist.valid_creation_h, &p.valid_creation);
        extend(&mut hist.scope_h, &p.scope);
        extend(&mut hist.violated_h, &p.violated);
        extend(&mut hist.performs_h, &p.performs);
        extend(&mut hist.acts_for3_h, &p.acts_for3);
        extend(&mut hist.acts_for2_h, &p.acts_for2);
        extend(&mut hist.defection_h, &p.defection);
        extend(&mut hist.unaudited_exposure_h, &p.unaudited_exposure);
        extend(&mut hist.knows_h, &p.knows);
        extend(&mut hist.disclose_h, &p.disclose);
        extend(&mut hist.conduct_of_h, &p.conduct_of);
        extend(&mut hist.live_h, &p.live);
        extend(&mut hist.repaired_h, &p.repaired);
        extend(&mut hist.holder_h, &p.holder);
        extend(&mut hist.fulfilled_h, &p.fulfilled);
        emit_step(&p, &mut out);
        if t == hz {
            emit_final(&p, &mut out);
        }
    }
    for a in out {
        println!("{a}");
    }
}

fn extend<T: Clone + Eq + std::hash::Hash>(dst: &mut Vec<T>, src: &[T]) {
    let seen: HashSet<T> = dst.iter().cloned().collect();
    for x in src {
        if !seen.contains(x) {
            dst.push(x.clone());
        }
    }
}

macro_rules! put {
    ($out:expr, $name:literal, $rel:expr, |$($v:ident),*|) => {
        for ($($v,)*) in $rel.iter() {
            let args: Vec<String> = vec![$($v.to_string()),*];
            $out.insert(format!("{}({})", $name, args.join(",")));
        }
    };
}

/// Relations that are complete after each step (time- or invocation-indexed).
fn emit_step(p: &Core, out: &mut BTreeSet<String>) {
    put!(out, "live", p.live, |a, b|);
    put!(out, "ended_by", p.ended_by, |a, b|);
    put!(out, "detached", p.detached, |a, b|);
    put!(out, "covered", p.covered, |a, b|);
    put!(out, "acts_for", p.acts_for2, |a, b|);
    put!(out, "acts_for", p.acts_for3, |a, b, c|);
    put!(out, "permitted", p.permitted, |a, b, c|);
    put!(out, "secures", p.secures, |a, b, c|);

    put!(out, "conduct_of", p.conduct_of, |a, b, c|);

    put!(out, "valid_creation", p.valid_creation, |a|);
    put!(out, "unauthorized", p.unauthorized, |a|);
    put!(out, "parent_grant", p.parent_grant, |a, b|);
    put!(out, "candidate_parent", p.candidate_parent, |a, b|);
    put!(out, "can_grant", p.can_grant, |a, b|);
    put!(out, "holder", p.holder, |a, b, c|);
    put!(out, "vacant", p.vacant, |a, b|);
    put!(out, "bound", p.bound, |a, b, c|);
    put!(out, "performs", p.performs, |a, b, c|);
    put!(out, "excused", p.excused, |a, b|);
    put!(out, "fulfilled", p.fulfilled, |a, b|);
    put!(out, "violated", p.violated, |a, b|);
    put!(out, "violator", p.violator, |a, b|);
    put!(out, "overcommitted", p.overcommitted, |a, b, c|);
    put!(out, "knows", p.knows, |a, b|);
    put!(out, "sanitized", p.sanitized, |a, b|);
    put!(out, "unaudited_exposure", p.unaudited_exposure, |a, b|);
    put!(out, "clear", p.clear, |a, b|);
    put!(out, "assured", p.assured, |a, b|);
    put!(out, "unassured", p.unassured, |a, b|);
    put!(out, "defection", p.defection, |a, b, c|);
    put!(out, "repaired", p.repaired, |a, b, c|);
    put!(out, "open_defection", p.open_defection, |a, b|);
    put!(out, "in_good_standing", p.in_good_standing, |a, b|);
    put!(out, "exposed", p.exposed, |a, b|);

}

/// Static relations and answerability, read once from the last step.
fn emit_final(p: &Core, out: &mut BTreeSet<String>) {
    put!(out, "capacity", p.capacity, |a, b|);
    put!(out, "standing", p.standing, |a|);
    put!(out, "void", p.void, |a|);
    put!(out, "security", p.security, |a|);
    put!(out, "reparation", p.reparation, |a, b|);
    put!(out, "changed", p.changed, |a, b, c|);
    put!(out, "swap", p.swap, |a, b|);
    put!(out, "rewrite", p.rewrite, |a, b|);
    put!(out, "changer", p.changer, |a, b|);
    put!(out, "in_lineage", p.in_lineage, |a, b|);
    put!(out, "in_range", p.in_range, |a, b|);
    put!(out, "eff_follows", p.eff_follows, |a, b|);
    put!(out, "on_pin", p.on_pin, |a, b|);
    put!(out, "off_pin", p.off_pin, |a, b|);
    put!(out, "eff_off_pin", p.eff_off_pin, |a, b|);
    put!(out, "scope", p.scope, |a, b, c|);
    put!(out, "within", p.within, |a, b|);
    put!(out, "charter", p.charter, |a, b|);
    put!(out, "does", p.does, |a, b|);
    put!(out, "audited", p.audited, |a|);
    put!(out, "in_force", p.in_force, |a|);
    put!(out, "answerer", p.answerer, |a, b|);
    put!(out, "answered", p.answered, |a, b|);
    put!(out, "orphan", p.orphan, |a, b|);
    put!(out, "secured", p.secured, |a|);
    put!(out, "unanswerable", p.unanswerable, |a|);
    put!(out, "answered_breach", p.answered_breach, |a, b|);
    put!(out, "unanswered_breach", p.unanswered_breach, |a, b|);
    put!(out, "bond", p.bond, |a, b|);
    put!(out, "continuation_of", p.continuation_of, |a, b, c|);
    put!(out, "op", p.op, |a, b|);
    put!(out, "answers_for", p.answers_for, |a, b|);
    put!(out, "steered", p.steered, |a, b|);
    put!(out, "vitiated", p.vitiated, |a, b|);
    // knowledge imputed to whoever runs the invocation that knows it: read over every step
    for (i, x) in p.knows_h.iter().chain(p.knows.iter()) {
        for (j, pr) in p.op.iter() {
            if i == j {
                out.insert(format!("imputed({pr},{x})"));
            }
        }
    }
}

fn s(v: &V) -> S {
    match v {
        V::S(x) => x,
        V::I(n) => leak(&n.to_string()),
    }
}
fn n(v: &V) -> i64 {
    match v {
        V::I(x) => *x,
        V::S(x) => panic!("expected integer, got {x}"),
    }
}

fn load(p: &mut Core, facts: &[(String, Vec<V>)], hz: i64, hyp: S) {
    p.time = (0..=hz).map(|t| (t,)).collect();
    p.hyp = vec![(hyp,)];
    p.cap = vec![("owe",), ("claim",)];
    p.bundle = vec![("actor", "owe"), ("party", "owe"), ("party", "claim")];
    for (a, n_) in [("copying", "copy"), ("swapping", "swap"), ("rewriting", "rewrite"), ("releasing", "release"),
                    ("revoking", "revoke"), ("appointing", "appoint")] {
        p.act_name.push((a, n_));
    }
    for (name, a) in facts {
        match name.as_str() {
            "principal" => p.principal.push((s(&a[0]),)),
            "kind" => p.kind.push((s(&a[0]), s(&a[1]))),
            "role" => p.role.push((s(&a[0]),)),
            "invocation" => p.invocation.push((s(&a[0]),)),
            "at" => p.at.push((s(&a[0]), n(&a[1]))),
            "runs" => p.runs.push((s(&a[0]), s(&a[1]))),
            "part" => p.part.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "edge" => p.edge.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "changed_by" => p.changed_by.push((s(&a[0]), s(&a[1]))),
            "does" => p.does_base.push((s(&a[0]), s(&a[1]))),
            "with" => p.with.push((s(&a[0]), s(&a[1]))),
            "learns" => p.learns.push((s(&a[0]), s(&a[1]))),
            "feeds" => p.feeds.push((s(&a[0]), s(&a[1]))),
            "induced" => p.induced.push((s(&a[0]), s(&a[1]))),
            "recorded" => p.recorded.push((s(&a[0]), s(&a[1]))),
            "act_name" => p.act_name.push((s(&a[0]), s(&a[1]))),
            "act_amount" => p.act_amount.push((s(&a[0]), n(&a[1]))),
            "act_obj" => p.act_obj.push((s(&a[0]), s(&a[1]))),
            "exclusive" => p.exclusive.push((s(&a[0]),)),
            "act_info" => p.act_info.push((s(&a[0]), s(&a[1]))),
            "act_target" => p.act_target.push((s(&a[0]), s(&a[1]))),
            "commitment" => p.commitment.push((s(&a[0]),)),
            "debtor" => p.debtor.push((s(&a[0]), s(&a[1]))),
            "creditor" => p.creditor.push((s(&a[0]), s(&a[1]))),
            "mode" => p.mode.push((s(&a[0]), s(&a[1]))),
            "content" => p.content.push((s(&a[0]), s(&a[1]))),
            "deadline" => p.deadline.push((s(&a[0]), n(&a[1]))),
            "pin" if a.len() == 3 => p.pin4.push((s(&a[0]), "one", s(&a[1]), s(&a[2]))),
            "pin" => p.pin4.push((s(&a[0]), s(&a[1]), s(&a[2]), s(&a[3]))),
            "trigger" => p.trigger.push((s(&a[0]), s(&a[1]))),
            "until" => p.until.push((s(&a[0]), s(&a[1]))),
            "created" => p.created.push((s(&a[0]), s(&a[1]))),
            "recognized" => p.recognized.push((s(&a[0]), n(&a[1]))),
            "releases" => p.releases.push((s(&a[0]), s(&a[1]))),
            "revokes" => p.revokes.push((s(&a[0]), s(&a[1]))),
            "root" => p.root.push((s(&a[0]), s(&a[1]))),
            "follows" => p.follows.push((s(&a[0]), s(&a[1]))),
            "allows" => p.allows.push((s(&a[0]), s(&a[1]), n(&a[2]))),
            "under" => p.under.push((s(&a[0]), s(&a[1]))),
            "appointer" => p.appointer.push((s(&a[0]), s(&a[1]))),
            "appoints" => p.appoints.push((s(&a[0]), s(&a[1]), s(&a[2]), n(&a[3]))),
            "operator" => p.operator.push((s(&a[0]), s(&a[1]))),
            _ => {} // substrate/1, expect/reject and other markers carry no rules here
        }
    }
}
