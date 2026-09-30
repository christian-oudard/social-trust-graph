//! Rust (ascent) port of spec/core.lp, evaluated as a per-step fold.
//!
//! core.lp is not stratified at the predicate level (live <- !ended_by <- parent_grant
//! <- covered <- live; detached <- violated <- !fulfilled <- performs <- bound <- detached)
//! but every such cycle passes through an earlier time step. Here each step is one run of
//! a stratified ascent program whose `*_h` relations hold the results of earlier steps.
//! Relation names and rules follow core.lp one to one; see ../spec/core.lp for comments.
//!
//! Input: JSON facts on stdin, as produced by ../spec/crosscheck.py. Pass `party` as the
//! first argument to set hyp(machine_party). Output: derived atoms in clingo syntax.

use ascent::ascent;
use std::collections::{BTreeSet, HashMap};
use std::io::Read;

type S = &'static str;

ascent! {
    struct Core;

    // ---------------- base relations ----------------
    relation now(i64);
    relation time(i64);
    relation hyp_party(());
    relation principal(S); relation kind(S, S); relation role(S);
    relation invocation(S); relation at(S, i64); relation runs(S, S); relation part(S, S, S);
    relation substrate(S);
    relation edge(S, S, S); relation does_base(S, S); relation with(S, S); relation learns(S, S);
    relation act_name(S, S); relation act_amount(S, i64); relation act_obj(S, S); relation exclusive(S);
    relation act_info(S, S); relation act_target(S, S);
    relation commitment(S); relation debtor(S, S); relation creditor(S, S); relation mode(S, S);
    relation content(S, S); relation deadline(S, i64); relation pin(S, S, S); relation trigger(S, S);
    relation reparation(S, S); relation created(S, S); relation founded(S, i64);
    relation released(S, i64); relation revoked(S, i64);
    relation root(S, S); relation follows(S, S); relation allows(S, S, i64);
    relation fills(S, S, i64, i64);
    relation test(S, S, S); relation refrains(S, S); relation issued(S, i64); relation horizon(S, i64);
    relation clean(S, S, S); relation record(S, S);

    // ---------------- history from earlier steps ----------------
    relation parent_grant_h(S, S); relation valid_creation_h(S); relation ultra_vires_h(S);
    relation scope_h(S, S, i64); relation violated_h(S, i64); relation performs_h(S, S, i64);
    relation acts_for3_h(S, S, S); relation acts_for2_h(S, S); relation defection_h(S, S, i64);
    relation unaudited_exposure_h(S, i64);

    // ================= 1. substrate and lineage (static) =================
    relation changed(S, S, S); relation swap(S, S); relation rewrite(S, S);
    relation ancestor(S, S); relation rollback(S);
    changed(i1, i2, sl) <-- edge(i1, i2, _), runs(i1, s1), runs(i2, s2), part(s1, sl, h1), !part(s2, sl, h1);
    changed(i1, i2, sl) <-- edge(i1, i2, _), runs(i1, s1), runs(i2, s2), part(s2, sl, h2), !part(s1, sl, h2);
    swap(i1, i2) <-- changed(i1, i2, sl), if *sl == "weights";
    rewrite(i1, i2) <-- changed(i1, i2, sl), if *sl == "memory";
    ancestor(a, b) <-- edge(a, b, _);
    ancestor(a, c) <-- ancestor(a, b), edge(b, c, _);
    rollback(i) <-- runs(i, s), ancestor(i0, i), runs(i0, s), edge(i1, i, _), runs(i1, s1), if s1 != s;

    // ================= 2. attribution =================
    relation grant(S); relation in_lineage(S, S); relation pin_ok(S, S, S); relation off_pin(S, S);
    grant(g) <-- mode(g, m), if *m == "power";
    in_lineage(g, i) <-- grant(g), root(g, i);
    in_lineage(g, i2) <-- in_lineage(g, i1), edge(i1, i2, k), follows(g, k);
    pin_ok(c, i, sl) <-- pin(c, sl, h), runs(i, s), part(s, sl, h);
    off_pin(c, i) <-- pin(c, sl, _), invocation(i), !pin_ok(c, i, sl);

    relation ended_by(S, i64); relation live(S, i64);
    ended_by(c, t) <-- now(t), revoked(c, t0), if t0 <= t;
    ended_by(c, t) <-- now(t), released(c, t0), if t0 <= t;
    ended_by(g2, t) <-- parent_grant_h(g2, g1), ended_by(g1, t), created(g2, i), at(i, t0), if t > t0;
    live(c, t) <-- now(t), founded(c, t0), if t0 <= t, !ended_by(c, t);
    live(c, t) <-- now(t), created(c, i), at(i, t0), if t0 < t, valid_creation_h(c), !ended_by(c, t);

    relation covered(S, S); relation acts_for2(S, S);
    covered(g, i) <-- now(t), at(i, t), in_lineage(g, i), !off_pin(g, i), live(g, t);
    acts_for2(i, p) <-- covered(g, i), debtor(g, p);

    relation parent_grant(S, S); relation scope(S, S, i64); relation within(S, S); relation has_amount(S);
    parent_grant(g2, g1) <-- grant(g2), created(g2, i), covered(g1, i), debtor(g1, p), debtor(g2, p);
    scope(g, n, cap) <-- allows(g, n, cap), founded(g, _);
    scope(g, n, cap) <-- scope_h(g, n, cap);
    scope(g2, n, cap) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, n, cap1), if cap <= cap1;
    scope(g2, n, cap1) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, n, cap1), if cap > cap1;
    scope(g2, n, cap) <-- allows(g2, n, cap), parent_grant(g2, g1), scope(g1, all, _), if *all == "all";
    has_amount(a) <-- act_amount(a, _);
    within(g, a) <-- scope(g, n, cap), act_name(a, n), act_amount(a, x), if x <= cap;
    within(g, a) <-- scope(g, n, _), act_name(a, n), !has_amount(a);
    within(g, a) <-- scope(g, all, _), if *all == "all", act_name(a, _);

    relation acts_for3(S, S, S);
    acts_for3(i, a, p) <-- covered(g, i), debtor(g, p), within(g, a);
    acts_for3(i, a, r) <-- grant(g), debtor(g, r), role(r), within(g, a), fills(p, r, t1, t2),
                           now(t), at(i, t), if t1 <= t && t < t2, acts_for2(i, p);

    relation valid_creation(S); relation can_delegate(S, S); relation ultra_vires(S);
    valid_creation(c) <-- now(t), created(c, i), at(i, t), debtor(c, p), principal(p), content(c, a),
                          acts_for3(i, a, p), !grant(c);
    valid_creation(c) <-- now(t), created(c, i), at(i, t), debtor(c, r), role(r), content(c, a),
                          acts_for3(i, a, r), !grant(c);
    valid_creation(g) <-- now(t), grant(g), created(g, i), at(i, t), debtor(g, p), can_delegate(i, p);
    can_delegate(i, p) <-- covered(g, i), debtor(g, p), scope(g, n, _), if *n == "delegate";
    can_delegate(i, p) <-- covered(g, i), debtor(g, p), scope(g, n, _), if *n == "all";
    ultra_vires(c) <-- now(t), created(c, i), at(i, t), !valid_creation(c);

    // ================= 3. holding and binding =================
    relation has_trigger(S); relation detached(S, i64); relation bound(S, S, i64); relation charter(S, S);
    has_trigger(c) <-- trigger(c, _);
    detached(c, t) <-- live(c, t), !has_trigger(c);
    detached(c, t) <-- live(c, t), trigger(c, c0), violated_h(c0, t0), if t0 < t;
    detached(c, t) <-- live(c, t), trigger(c, a), act_name(a, _), creditor(c, q), does(i, a),
                       acts_for3_h(i, a, q), at(i, t0), if t0 < t;
    bound(c, p, t) <-- detached(c, t), debtor(c, p), principal(p);
    bound(c, p, t) <-- detached(c, t), debtor(c, r), role(r), fills(p, r, t1, t2), if t1 <= t && t < t2;
    charter(r, c) <-- debtor(c, r), role(r);

    // ================= 4. conformance =================
    relation does(S, S);
    does(i, a) <-- does_base(i, a);
    relation performs(S, S, i64); relation excused(S, S); relation fulfilled(S, i64);
    relation violated(S, i64); relation violator(S, S); relation overcommitted(S, S, S);
    performs(c, i, t) <-- bound(c, p, t), content(c, a), does(i, a), at(i, t), acts_for3(i, a, p),
                          !excused(c, i), !off_pin(c, i);
    excused(c, i) <-- mode(c, m), if *m == "avoid", creditor(c, q), content(c, a), acts_for3(i, a, q);
    fulfilled(c, t) <-- now(t), mode(c, m), if *m == "achieve", performs(c, _, t);
    fulfilled(c, t) <-- now(t), mode(c, m), if *m == "achieve", performs_h(c, _, _);
    violated(c, t) <-- mode(c, m), if *m == "avoid", performs(c, _, t);
    violated(c, d) <-- now(d), mode(c, m), if *m == "achieve", deadline(c, d), detached(c, d), !fulfilled(c, d);
    violator(c, i) <-- mode(c, m), if *m == "avoid", performs(c, i, _);
    overcommitted(p, c1, c2) <-- mode(c1, m1), mode(c2, m2), if *m1 == "achieve" && *m2 == "achieve" && c1 < c2,
                                 content(c1, a1), content(c2, a2), act_obj(a1, o), act_obj(a2, o), exclusive(o),
                                 bound(c1, p, t), bound(c2, p, t);

    // knowledge flow (static)
    relation knows(S, S); relation first_learned(S, i64); relation learned_earlier(S, i64);
    relation seen_at(S, i64); relation seen_before(S, i64); relation scrubbed(S, S); relation imputed(S, S);
    knows(i, x) <-- learns(i, x);
    knows(i2, x) <-- knows(i1, x), edge(i1, i2, _), !scrubbed(i2, x);
    first_learned(x, t) <-- learns(i, x), at(i, t), !learned_earlier(x, t);
    learned_earlier(x, t) <-- learns(i, x), at(i, t), learns(i2, x), at(i2, t2), if t2 < t;
    seen_at(s, t) <-- runs(i, s), at(i, t);
    seen_before(s, t) <-- seen_at(s, t0), time(t), if t0 < t;
    scrubbed(i, x) <-- runs(i, s), first_learned(x, t), seen_before(s, t);
    scrubbed(i, x) <-- runs(i, s), clean(_, s, x);
    does(i, a) <-- act_name(a, n), if *n == "disclose", act_info(a, x), act_target(a, q), knows(i, x), with(i, q);

    // audit
    relation audited(S); relation unaudited_exposure(S, i64); relation clear(S, i64);
    relation violated_by_time(S, i64);
    audited(i) <-- record(_, i);
    unaudited_exposure(c, t) <-- now(t), unaudited_exposure_h(c, _);
    unaudited_exposure(c, t) <-- now(t), mode(c, m), if *m == "avoid", content(c, a), bound(c, p, t),
                                 acts_for3(i, a, p), at(i, t), !off_pin(c, i), !audited(i);
    violated_by_time(c, t) <-- violated(c, t);
    violated_by_time(c, t) <-- now(t), violated_h(c, _);
    clear(c, t) <-- mode(c, m), if *m == "avoid", detached(c, t), !violated_by_time(c, t), !unaudited_exposure(c, t);

    // ================= 5. assurance =================
    relation slot_mismatch(S, S); relation fresh(S, i64); relation supports(S, S, S);
    relation assured(S, S); relation unassured(S, S); relation has_horizon(S);
    slot_mismatch(e, s) <-- test(e, s0, sl), part(s0, sl, h), substrate(s), !part(s, sl, h);
    has_horizon(e) <-- horizon(e, _);
    fresh(e, t) <-- issued(e, t0), time(t), if t >= t0, !has_horizon(e);
    fresh(e, t) <-- issued(e, t0), horizon(e, hz), time(t), if t >= t0 && *t < *t0 + *hz;
    supports(e, i, n) <-- refrains(e, n), invocation(i), runs(i, s), test(e, _, _), !slot_mismatch(e, s),
                          at(i, t), fresh(e, t);
    assured(c, i) <-- mode(c, m), if *m == "avoid", content(c, a), act_name(a, n), bound(c, p, t),
                      acts_for2(i, p), at(i, t), supports(_, i, n);
    unassured(c, i) <-- mode(c, m), if *m == "avoid", bound(c, p, t), acts_for2(i, p), at(i, t), !assured(c, i);

    // ================= 6. standing and answerability (read at the last step) =================
    relation standing(S);
    standing(p) <-- kind(p, k), if *k == "person";
    standing(p) <-- kind(p, k), if *k == "org";
    standing(p) <-- kind(p, k), if *k == "machine", hyp_party(_);

    relation valid_creation_all(S); relation ultra_vires_all(S); relation acts_for3_all(S, S, S);
    relation acts_for2_all(S, S); relation defection_all(S, S, i64); relation violated_all(S, i64);
    valid_creation_all(c) <-- valid_creation(c); valid_creation_all(c) <-- valid_creation_h(c);
    ultra_vires_all(c) <-- ultra_vires(c); ultra_vires_all(c) <-- ultra_vires_h(c);
    acts_for3_all(i, a, p) <-- acts_for3(i, a, p); acts_for3_all(i, a, p) <-- acts_for3_h(i, a, p);
    acts_for2_all(i, p) <-- acts_for2(i, p); acts_for2_all(i, p) <-- acts_for2_h(i, p);
    defection_all(c, p, t) <-- defection(c, p, t); defection_all(c, p, t) <-- defection_h(c, p, t);
    violated_all(c, t) <-- violated(c, t); violated_all(c, t) <-- violated_h(c, t);

    relation in_force(S); relation answerer(S, S); relation answered(S, S); relation orphan(S, S);
    relation secured(S); relation unanswerable(S);
    in_force(c) <-- valid_creation_all(c);
    in_force(c) <-- founded(c, _);
    answerer(c, p) <-- in_force(c), debtor(c, p), principal(p), standing(p);
    answerer(c, p) <-- in_force(c), debtor(c, r), role(r), fills(p, r, _, _), standing(p);
    answerer(c, m) <-- ultra_vires_all(c), created(c, i), content(c, a), acts_for3_all(i, a, m), standing(m),
                       debtor(c, p), if m != p;
    answered(i, a) <-- acts_for3_all(i, a, p), standing(p);
    orphan(i, a) <-- does(i, a), !answered(i, a);
    secured(c) <-- reparation(c, c2), answerer(c2, _);
    unanswerable(c) <-- commitment(c), !grant(c), !answerer(c, _), !secured(c);
    imputed(p, x) <-- knows(i, x), acts_for2_all(i, p);

    // ================= 7. defection and repair =================
    relation defection(S, S, i64); relation answered_breach(S, i64); relation unanswered_breach(S, i64);
    relation repaired(S, i64); relation bond(S, S); relation in_good_standing(S, i64);
    relation open_defection(S, i64);
    defection(c, p, t) <-- violated(c, t), debtor(c, p), principal(p);
    defection(c, p, t) <-- violated(c, t), debtor(c, r), role(r), fills(p, r, t1, t2), if t1 <= t && t < t2;
    answered_breach(c, t) <-- defection_all(c, p, t), standing(p);
    answered_breach(c, t) <-- violated_all(c, t), secured(c);
    unanswered_breach(c, t) <-- violated_all(c, t), !answered_breach(c, t);
    repaired(c, t) <-- now(t), violated_all(c, t0), if t0 <= t, reparation(c, c2), fulfilled(c2, t);
    bond(c, c2) <-- reparation(c, c2), debtor(c, p), debtor(c2, q), if p != q;
    open_defection(p, t) <-- now(t), defection_all(c, p, t0), if t0 <= t, !repaired(c, t);
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
    let party = std::env::args().nth(1).as_deref() == Some("party");
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
        load(&mut p, &facts, hz);
        if party {
            p.hyp_party = vec![((),)];
        }
        p.now = vec![(t,)];
        p.parent_grant_h = hist.parent_grant_h.clone();
        p.valid_creation_h = hist.valid_creation_h.clone();
        p.ultra_vires_h = hist.ultra_vires_h.clone();
        p.scope_h = hist.scope_h.clone();
        p.violated_h = hist.violated_h.clone();
        p.performs_h = hist.performs_h.clone();
        p.acts_for3_h = hist.acts_for3_h.clone();
        p.acts_for2_h = hist.acts_for2_h.clone();
        p.defection_h = hist.defection_h.clone();
        p.unaudited_exposure_h = hist.unaudited_exposure_h.clone();
        p.run();
        extend(&mut hist.parent_grant_h, &p.parent_grant);
        extend(&mut hist.valid_creation_h, &p.valid_creation);
        extend(&mut hist.ultra_vires_h, &p.ultra_vires);
        extend(&mut hist.scope_h, &p.scope);
        extend(&mut hist.violated_h, &p.violated);
        extend(&mut hist.performs_h, &p.performs);
        extend(&mut hist.acts_for3_h, &p.acts_for3);
        extend(&mut hist.acts_for2_h, &p.acts_for2);
        extend(&mut hist.defection_h, &p.defection);
        extend(&mut hist.unaudited_exposure_h, &p.unaudited_exposure);
        emit_step(&p, &mut out);
        if t == hz {
            emit_final(&p, &mut out);
        }
    }
    for a in out {
        println!("{a}");
    }
}

fn extend<T: Clone + PartialEq>(dst: &mut Vec<T>, src: &[T]) {
    for x in src {
        if !dst.contains(x) {
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
    put!(out, "covered", p.covered, |a, b|);
    put!(out, "acts_for", p.acts_for2, |a, b|);
    put!(out, "acts_for", p.acts_for3, |a, b, c|);
    put!(out, "valid_creation", p.valid_creation, |a|);
    put!(out, "ultra_vires", p.ultra_vires, |a|);
    put!(out, "parent_grant", p.parent_grant, |a, b|);
    put!(out, "can_delegate", p.can_delegate, |a, b|);
    put!(out, "detached", p.detached, |a, b|);
    put!(out, "bound", p.bound, |a, b, c|);
    put!(out, "performs", p.performs, |a, b, c|);
    put!(out, "excused", p.excused, |a, b|);
    put!(out, "fulfilled", p.fulfilled, |a, b|);
    put!(out, "violated", p.violated, |a, b|);
    put!(out, "violator", p.violator, |a, b|);
    put!(out, "overcommitted", p.overcommitted, |a, b, c|);
    put!(out, "unaudited_exposure", p.unaudited_exposure, |a, b|);
    put!(out, "clear", p.clear, |a, b|);
    put!(out, "assured", p.assured, |a, b|);
    put!(out, "unassured", p.unassured, |a, b|);
    put!(out, "defection", p.defection, |a, b, c|);
    put!(out, "repaired", p.repaired, |a, b|);
    put!(out, "open_defection", p.open_defection, |a, b|);
    put!(out, "in_good_standing", p.in_good_standing, |a, b|);
}

/// Static relations and answerability, read once from the last step.
fn emit_final(p: &Core, out: &mut BTreeSet<String>) {
    put!(out, "changed", p.changed, |a, b, c|);
    put!(out, "swap", p.swap, |a, b|);
    put!(out, "rewrite", p.rewrite, |a, b|);
    put!(out, "rollback", p.rollback, |a|);
    put!(out, "in_lineage", p.in_lineage, |a, b|);
    put!(out, "off_pin", p.off_pin, |a, b|);
    put!(out, "scope", p.scope, |a, b, c|);
    put!(out, "within", p.within, |a, b|);
    put!(out, "charter", p.charter, |a, b|);
    put!(out, "knows", p.knows, |a, b|);
    put!(out, "scrubbed", p.scrubbed, |a, b|);
    put!(out, "imputed", p.imputed, |a, b|);
    put!(out, "does", p.does, |a, b|);
    put!(out, "audited", p.audited, |a|);
    put!(out, "slot_mismatch", p.slot_mismatch, |a, b|);
    put!(out, "supports", p.supports, |a, b, c|);
    put!(out, "standing", p.standing, |a|);
    put!(out, "in_force", p.in_force, |a|);
    put!(out, "answerer", p.answerer, |a, b|);
    put!(out, "answered", p.answered, |a, b|);
    put!(out, "orphan", p.orphan, |a, b|);
    put!(out, "secured", p.secured, |a|);
    put!(out, "unanswerable", p.unanswerable, |a|);
    put!(out, "answered_breach", p.answered_breach, |a, b|);
    put!(out, "unanswered_breach", p.unanswered_breach, |a, b|);
    put!(out, "bond", p.bond, |a, b|);
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

fn load(p: &mut Core, facts: &[(String, Vec<V>)], hz: i64) {
    p.time = (0..=hz).map(|t| (t,)).collect();
    for (name, a) in facts {
        match name.as_str() {
            "principal" => p.principal.push((s(&a[0]),)),
            "kind" => p.kind.push((s(&a[0]), s(&a[1]))),
            "role" => p.role.push((s(&a[0]),)),
            "invocation" => p.invocation.push((s(&a[0]),)),
            "at" => p.at.push((s(&a[0]), n(&a[1]))),
            "runs" => p.runs.push((s(&a[0]), s(&a[1]))),
            "substrate" => p.substrate.push((s(&a[0]),)),
            "part" => p.part.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "edge" => p.edge.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "does" => p.does_base.push((s(&a[0]), s(&a[1]))),
            "with" => p.with.push((s(&a[0]), s(&a[1]))),
            "learns" => p.learns.push((s(&a[0]), s(&a[1]))),
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
            "pin" => p.pin.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "trigger" => p.trigger.push((s(&a[0]), s(&a[1]))),
            "reparation" => p.reparation.push((s(&a[0]), s(&a[1]))),
            "created" => p.created.push((s(&a[0]), s(&a[1]))),
            "founded" => p.founded.push((s(&a[0]), n(&a[1]))),
            "released" => p.released.push((s(&a[0]), n(&a[1]))),
            "revoked" => p.revoked.push((s(&a[0]), n(&a[1]))),
            "root" => p.root.push((s(&a[0]), s(&a[1]))),
            "follows" => p.follows.push((s(&a[0]), s(&a[1]))),
            "allows" => p.allows.push((s(&a[0]), s(&a[1]), n(&a[2]))),
            "fills" => p.fills.push((s(&a[0]), s(&a[1]), n(&a[2]), n(&a[3]))),
            "test" => p.test.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "refrains" => p.refrains.push((s(&a[0]), s(&a[1]))),
            "issued" => p.issued.push((s(&a[0]), n(&a[1]))),
            "horizon" => p.horizon.push((s(&a[0]), n(&a[1]))),
            "clean" => p.clean.push((s(&a[0]), s(&a[1]), s(&a[2]))),
            "record" => p.record.push((s(&a[0]), s(&a[1]))),
            _ => {} // evidence(E), expect/reject, and other markers carry no rules here
        }
    }
}
