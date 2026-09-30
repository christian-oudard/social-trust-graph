# D. Legal and institutional analogs: when do commitments survive a change of party or performer?

Prior-art survey for a minimal ontology of commitments between human and LLM-agent parties whose internals can be **swapped** (model replaced), **rewritten** (memory edited), **rolled back**, **forked**, or **merged**.

Survey date: 2026-09-30. Scope: US common law (Restatements), UCC, uniform acts, EU company/data/product/AI law, UNCITRAL, admiralty, trust and partnership law, Ostrom.

**Verification legend**
- **[V]**: text checked in this session against primary or official text (statute, code, directive, restatement black letter as quoted in a court opinion or law-review excerpt, or the opinion itself).
- **[S]**: checked only against reliable secondary summaries (law-firm memos, casebooks, Wikipedia, case briefs). The rule is well established, but I did not see the exact wording.
- **[U]**: from memory and not verified this session. Treat as a lead only.

Restatement black letter is copyrighted by ALI and mostly paywalled (Lexis). Where I quote it, the wording comes from court opinions, casebooks or outlines that reproduce it.

---

## 0. Executive synthesis: the survival criteria

Across very different bodies of law, the same handful of criteria decide whether an obligation or permission survives a change to the party or to the thing performing.

| # | Criterion | Where law uses it | Survives change? |
|---|---|---|---|
| K1 | **Materiality of performer identity to the counterparty**, meaning a "substantial interest in having the original promisor perform or control the acts" | R2d Contracts §318(2); UCC §2-210(1); *Macke*; *Sally Beauty*; R2d §262 | A duty can be performed by a substitute *unless* the counterparty relied on who performs (skill, judgment, trust, confidentiality, or the absence of conflicting loyalties) |
| K2 | **Accountability does not move with performance** | R2d §318(3); UCC §2-210(1) 2nd sentence; R3d Agency §3.15; GDPR Art 28(4) | The original obligor stays liable after any delegation or substitution. Release happens only by **novation** (counterparty's assent), R2d §280 |
| K3 | **Change in the counterparty's burden or risk** | R2d §317(2); UCC §2-210(2); nonexclusive IP licenses (*In re CFLC*); FCC §310(d) | A *benefit* (right or permission) moves to a new holder only if that does not materially change the grantor's burden, risk or expected return. Permissions whose risk depends on the holder are **personal** |
| K4 | **Counterparty's right to assurance on substitution** | UCC §2-210 (insecurity subsection); GDPR 28(2) notice-and-object; AI Act Art 43(4) re-assessment | Substitution is allowed but triggers a right to demand fresh evidence or to object |
| K5 | **Universal succession by merger vs. operation-of-law loss** | DGCL §259; *Meso Scale* vs *SQL Solutions*; *Sally Beauty* (Posner dissent) | In a merger, liabilities always pass to the survivor. Personal permissions may or may not pass (jurisdictions split). Change-of-control clauses fill the gap |
| K6 | **Substance over form (anti-evasion)** | Successor-liability exceptions (assumption, de facto merger, mere continuation, fraud, product line); *Tronox* fraudulent transfer | A "new" entity that is substantively continuous with the old one inherits its liabilities. Restructuring meant to shed liabilities is undone |
| K7 | **Split: allocation plus joint-and-several backstop** | EU Dir 2017/1132 Art 137(3), Art 146(3),(6); RUPA §703 | In a division, pre-split liabilities go where the plan puts them. *Unallocated* ones bind every recipient jointly and severally. Even allocated ones are backstopped by all recipients, capped at the net assets each received |
| K8 | **Notice governs third-party reliance** | R3d Agency §3.11 (lingering apparent authority); RUPA §702/§704; §3.07/§3.08 notice rules | Revoking authority, or dissociating, does not bind third parties until they have notice. A public filing creates constructive notice after a fixed period |
| K9 | **The tool is not the party** | R3d Agency §1.04 cmt e; UETA §§2(6), 14; E-SIGN §7001(h); UNCITRAL MLAC Art 7, 10; *Moffatt*; Cal. AB 316 | Actions of an automated system bind the person who deploys it. "The model did it" or "the output was unexpected" is not a defense. A counterparty may not exploit an error it knew was unintended (MLAC Art 8; UETA §10) |
| K10 | **Foreseen-change envelope** | AI Act Art 3(23), 25, 43(4); EU PLD 2024/2853 Art 4(18), 8(2), 11(1)(g), 11(2) | A change foreseen in the original assessment keeps compliance status. An unforeseen change that affects compliance or risk voids the prior assessment, and the *modifier* becomes the responsible "provider/manufacturer" |
| K11 | **Liability attached to the thing (in rem)** | Maritime liens (*The Bold Buccleugh*; *Malek Adhel*) | Some liabilities follow the artifact itself, into anyone's hands, even a bona fide purchaser, until a formal clearing process (judicial sale) extinguishes them |
| K12 | **The office outlives the officeholder** | Trust law: a trust does not fail for want of a trustee; UTC §704 | A role-based commitment survives a change of officeholder. The successor is bound by the charter (terms of the trust), not by the predecessor's personal extras |
| K13 | **Secondary obligors are discharged by unconsented risk change** | R3d Suretyship & Guaranty §§37–44 (esp. §41) | A bond is calibrated to a specific risk. If principal and obligee change the underlying obligation in a way that fundamentally changes the surety's risk without its consent, the surety is discharged (or, if compensated, discharged to the extent of prejudice) |
| K14 | **Rules-for-changing-rules at a deeper level** | Ostrom/Kiser three levels; Ostrom DP3 and DP8 | Operational commitments change under collective-choice rules, which change under constitutional rules. Deeper rules are costlier to change, which stabilizes expectations |
| K15 | **Consent bound to recipient identity; performer change needs principal authorization** | GDPR Art 4(11), 7, 28(2),(4); EDPB Guidelines 05/2020 ¶65, 07/2020 ¶¶128, 155–156 | Consent names *controllers*. It does not survive a change of controller. *Processors* (performers) need not be named in consent, but a change of processor needs the controller's prior specific or general authorization, with notice and a chance to object. The original processor stays fully liable |

**The central asymmetry for the ontology: "burdens are sticky, privileges are personal."**
- **Duties owed *by* a party** survive substitution of the performer, and even of the entity (merger, successor liability, split with joint-and-several backstop). The counterparty can always still reach the original accountable principal.
- **Permissions and benefits granted *to* a party** survive only if the grantor's risk does not depend on who holds them. Otherwise they are personal and need fresh consent or a notice-and-object step.

For LLM agents, a model swap is therefore **delegation of performance** (K1/K2/K4), not a change of party. A change of deploying principal is **assignment or novation** (K3/K5). A fork is a **division** (K7/K8). A merge is a **statutory merger** (K5), plus "confusion" for commitments the merging parties owed each other. A memory rewrite or rollback does not touch commitments at all, because commitments are held by the principal, not by the state (K9, plus imputation under R3d Agency §5.03).

---

## 1. Assignment, delegation, novation

### 1.1 Delegation of performance: R2d Contracts §318 [V via reproductions]
Text (as reproduced in outlines and casebooks):
- (1) "An obligor can properly delegate the performance of his duty to another unless the delegation is contrary to public policy or the terms of his promise."
- (2) "Unless otherwise agreed, a promise requires performance by a particular person only to the extent that the obligee has a substantial interest in having that person perform or control the acts promised."
- (3) "Unless the obligee agrees otherwise, neither delegation of performance nor a contract to assume the duty made with the obligor by the person delegated discharges any duty or liability of the delegating obligor."

**RULE.** Duties are delegable by default. Delegation never discharges the delegating obligor unless the obligee agrees.
**CRITERION.** The obligee's *substantial interest in the identity of the performer or controller*. Note "or control": the law cares about who *directs* performance, not only who physically does it.

Sources: https://matthewminer.name/law/outlines/1L/2nd+Semester/LAW+506-002+%E2%80%93+Contracts+II/R2C+%C2%A7+318 ; Lexis (paywalled) https://advance.lexis.com/open/document/openwebdocview/-318-Delegation-of-Performance-of-Duty/?pdmfid=1000522&pddocfullpath=/shared/document/analytical-materials/urn:contentItem:42GD-2SN0-00YG-M0DD-00000-00&pdcomponentid=12225

### 1.2 Assignment of rights: R2d §317(2) [S]
"A contractual right can be assigned unless (a) the substitution of a right of the assignee for the right of the assignor would materially change the duty of the obligor, or materially increase the burden or risk imposed on him by his contract, or materially impair his chance of obtaining return performance, or materially reduce its value to him, or (b) the assignment is forbidden by statute or is otherwise inoperative on grounds of public policy, or (c) assignment is validly precluded by contract." Comment: a change of payee for a money debt is ordinarily not material.

**RULE.** Rights are assignable unless the substitution materially changes the *obligor's* position.
**CRITERION.** Does the counterparty's burden, risk or expected return depend on *who holds the right*?

Sources: https://matthewminer.name/law/outlines/1L/2nd+Semester/LAW+506-002+%E2%80%93+Contracts+II/R2C+%C2%A7+317 ; https://saylordotorg.github.io/text_law-of-commercial-transactions/s17-third-party-rights.html

### 1.3 UCC §2-210 [V, Cornell]
- (1) "A party may perform his duty through a delegate unless otherwise agreed or unless the other party has a substantial interest in having his original promisor perform or control the acts required by the contract. No delegation of performance relieves the party delegating of any duty to perform or any liability for breach."
- (2) Rights assignable "except where the assignment would materially change the duty of the other party, or increase materially the burden or risk imposed on him by his contract, or impair materially his chance of obtaining return performance." (Cornell's page omits the "impair materially" clause, which appears in enacted state versions such as Ohio and New York. Numbering varies by state and vintage.)
- A general assignment of "the contract" is both an assignment of rights and a delegation of duties. Acceptance by the assignee is a promise to perform.
- **Insecurity subsection** (Cornell's (5)): "The other party may treat any assignment which delegates performance as creating reasonable grounds for insecurity and may without prejudice to his rights against the assignor demand assurances from the assignee" (cf. §2-609 adequate assurance).

**Ontology significance.** This is the clearest precedent for "substitution triggers an evidence demand": the counterparty keeps full recourse against the original party *and* may demand assurance from the new performer.

Source: https://www.law.cornell.edu/ucc/2/2-210 ; state text e.g. https://codes.findlaw.com/ny/uniform-commercial-code/ucc-sect-2-210/

### 1.4 Cases on the personal / non-personal line
- **British Waggon Co. v. Lea & Co. (1880) 5 QBD 149** [S]: a railway-wagon repair duty was delegable. Cockburn CJ: "All that the hirers ... cared for in this stipulation was the wagons should be kept in repair; it was indifferent to them by whom the repairs should be done." *Criterion: an outcome-specified duty is delegable.* https://www.designingbuildings.co.uk/wiki/Vicarious_performance
- **Macke Co. v. Pizza of Gaithersburg, 259 Md. 479, 270 A.2d 645 (1970)** [S]: vending-machine service contracts passed to the corporate acquirer. They were not personal-service contracts because they did not depend on the original provider's unique skill, judgment or reputation. The rule is stated in terms of *delectus personae* (personal choice as an ingredient of the bargain). https://www.courtlistener.com/opinion/2085649/macke-co-v-pizza-of-gaithersburg-inc/
- **Sally Beauty Co. v. Nexxus Products Co., 801 F.2d 1001 (7th Cir. 1986)** [V, opinion text]: an exclusive distributor (Best) merged into Sally Beauty, a wholly owned subsidiary of Nexxus's competitor Alberto-Culver. Holding: "Nexxus has a substantial interest in not seeing this contract performed by Sally Beauty, which is sufficient to bar the delegation under section 2-210 ... we hold that the contract was not assignable without Nexxus' consent." The reasoning turns on the implied *best-efforts* duty in exclusive dealing (UCC §2-306(2)) and a *conflict of interest* introduced by the new controller: "who can guarantee the outcome when there is a clear choice between the demands of the parent-manufacturer ... and the competing needs of Nexxus?" **Posner, dissenting:** "The general rule is that a change of corporate form--including a merger--does not in and of itself affect contractual rights and obligations." He also objected that the majority gave suppliers "an absolute right to cancel an exclusive-dealing contract if the dealer is acquired ... by a competitor." https://law.resource.org/pub/us/case/reporter/F2/801/801.F2d.1001.85-2039.html
  - **Ontology significance (high).** Substantial interest can come from *who controls the performer* (loyalty or alignment), not only from skill. The LLM analog: swapping to a model from a provider whose interests conflict with the counterparty's, or changing the controlling principal of an agent, can defeat delegability even when capability is equal.
- **Death or incapacity of a necessary person: R2d §262** [S]: "If the existence of a particular person is necessary for the performance of a duty, his death or such incapacity as makes performance impracticable is an event the non-occurrence of which was a basic assumption on which the contract was made." This is the mirror image: when the performer's identity is essential, losing it *discharges* the duty instead of transferring it. https://matthewminer.name/law/outlines/1L/2nd+Semester/LAW+506-002+%E2%80%93+Contracts+II/R2C+%C2%A7+262
- **Robson v Drummond (1831) 2 B & Ad 303** [U]: the classic English case holding a carriage-maintenance contract personal. Not verified.

### 1.5 Novation: R2d §280 (with §279 substituted contract) [S]
A novation is a substituted contract that brings in a party who was neither obligor nor obligee of the original duty. It discharges the original duty, so breach of the new duty gives no action on the old one. The obligor is discharged by substitution of a new obligor only if the contract so provides or the obligee assents.
**RULE.** The *only* way the accountable party changes is with the obligee's assent.
Sources: https://en.wikipedia.org/wiki/Novation ; https://www.adamsdrafting.com/novation/

### 1.6 Personal permissions (IP licenses, regulatory licenses)
- **In re CFLC, Inc. (Everex Systems v. Cadtrak), 89 F.3d 673 (9th Cir. 1996)** [S]: under federal law, nonexclusive patent licenses are "personal and assignable only with the consent of the licensor." Rationale: the licensor's risk (a competitor getting the license) depends on who holds it. https://law.justia.com/cases/federal/appellate-courts/F3/89/673/583363/
- **47 U.S.C. §310(d)** [S, statutory text reproduced]: "No construction permit or station license, or any rights thereunder, shall be transferred, assigned, or disposed of in any manner, voluntarily or involuntarily, directly or indirectly, or by transfer of control of any corporation holding such permit or license, to any person except upon application to the Commission and upon finding by the Commission that the public interest, convenience, and necessity will be served thereby." This is the regulatory model of "a permission that must not survive a change of controller without re-approval". It expressly reaches *indirect* transfers of control. https://www.law.cornell.edu/uscode/text/47/310
- **Merger as "assignment by operation of law"** [S]: *Meso Scale Diagnostics v. Roche*, 62 A.3d 1223 (Del. Ch. 2013) held that a reverse triangular merger is generally *not* an assignment by operation of law. *SQL Solutions v. Oracle* (N.D. Cal. 1991, unreported) held that a reverse triangular merger triggered a software-license anti-assignment clause under California law. The split shows that whether a *permission* survives a change of control is contested and turns on drafting (explicit change-of-control clauses). https://corpgov.law.harvard.edu/2013/03/13/delaware-court-rules-on-reverse-triangular-mergers-and-anti-assignment-provisions/
- **PPG Industries v. Guardian Industries, 597 F.2d 1090 (6th Cir. 1979)** [U]: patent license did not pass to the surviving corporation in a merger. Not verified.

### 1.7 Mapping to the ontology
- **Model swap = delegation of performance.** Commitment `c` held by principal `P` and performed via substrate `S1` → `S2`. By default `c` survives, `P` stays accountable (K2), and the counterparty gets an assurance right: it may demand fresh **evidence** of **conformance** from `S2` (UCC §2-210 insecurity).
- **Non-delegable flag.** A commitment should carry an explicit `performer_binding` field whose values track §318(2):
  - `outcome` (British Waggon): any conformant substrate.
  - `substrate-class` (e.g., "a model with property X"): any substrate meeting the class.
  - `controller` (Sally Beauty): substrate plus controlling principal fixed.
  - `specific` (§262): the named substrate is essential, so losing it *discharges* the commitment instead of transferring it.
- **Principal change = assignment or novation.** Moving a commitment's accountable principal requires counterparty assent (novation). Moving a *benefit* (permission) requires checking whether the grantor's risk changes (§317(2)). The default for data-access and tool permissions should be *personal* (CFLC, §310(d)).
- **Lineage matters.** Sally Beauty shows that the relevant identity includes the *control chain*. The **lineage** record must include who controls the substrate (provider, deployer), not just weights hashes.

---

## 2. Agency law (Restatement (Third) of Agency, 2006) and electronic agents

### 2.1 Authority and liability
- **Actual authority, §2.01** [S]: the agent acts with actual authority when, at the time of acting, the agent reasonably believes, in line with the principal's manifestations to the agent, that the principal wishes the agent so to act.
- **Apparent authority, §2.03** [V, quoted in UH handout]: "Apparent authority is the power held by an agent or other actor to affect a principal's legal relations with third parties when a third party reasonably believes the actor has authority to act on behalf of the principal and that belief is traceable to the principal's manifestations." It can exist without any actual agency relationship. https://law.uh.edu/assignments/spring2012/22149-handout.pdf
- **Ratification, §§4.01–4.08** [V, via handout]:
  - It relates back: the act is treated as if originally authorized (§4.02(1)).
  - It requires knowledge of material facts (§4.06).
  - It is ineffective if the third party has already withdrawn or circumstances have changed (§4.05).
  - It cannot prejudice rights intervening third parties acquired before ratification (§4.02(2)(c)).
  - It needs only an "objectively or externally observable indication" of consent, not communication (§4.01 cmt d).
  - Keeping the benefits with knowledge counts as ratification (§4.01 cmt g).
- **Termination** [S; exact black-letter not seen]:
  - §3.06 lists the modes.
  - §3.07: death or cessation of existence of the principal, or of the agent, terminates actual authority. The Third Restatement makes termination by a principal's death effective only once the agent (and, for apparent authority, the third party) has *notice*. This rejects the Second Restatement §120 rule of termination without notice. [S/U on exact wording; a secondary source was ambiguous.]
  - §3.08: loss of capacity is effective only on notice. A written instrument can make authority survive incapacity (durable power).
  - §3.10: the principal always has the *power* to revoke even "irrevocable" authority, but may be liable in contract for doing so [V, cmt b quoted in handout].
  - §3.11: apparent authority lingers after actual authority ends, until it is no longer reasonable for third parties to believe it continues. Notice to third parties may be needed [V via handout].
- **Subagency, §3.15** [S]: a subagent is appointed by an agent to perform functions the agent has consented to perform for the principal, and "for whose conduct the appointing agent is responsible to the principal." An agent may appoint subagents only with actual or apparent authority to do so [U on (2) wording].
- **Imputation, §5.03** [S]: "notice of a fact that an agent knows or has reason to know is imputed to the principal if knowledge of the fact is material to the agent's duties to the principal." The adverse-interest exception is in §5.04.
- **Agent liability to third parties, §6.10** [S]: an agent who purports to bind a principal without power impliedly warrants authority and is liable for breach of that warranty.

### 2.2 Are AI systems agents? Current law says no: they are *instrumentalities*
- **R3d Agency §1.04 cmt e** [V, quoted in Kolt, *Governing AI Agents*, 101 Notre Dame L. Rev. (forthcoming), n.26]: "a computer program is not capable of acting as a principal or an agent as defined by the common law. At present, computer programs are instrumentalities of the persons who use them." Kolt notes the "at present" hedge and that the comment's only support is Sommer, *Against Cyberlaw*, 15 Berkeley Tech. L.J. 1145 (2000). https://arxiv.org/pdf/2501.07913
- **UETA (1999)** [V, official text]:
  - §2(6): "'Electronic agent' means a computer program or an electronic or other automated means used independently to initiate an action or respond to electronic records or performances in whole or in part, without review or action by an individual."
  - §14(1): "A contract may be formed by the interaction of electronic agents of the parties, even if no individual was aware of or reviewed the electronic agents' actions or the resulting terms and agreements."
  - §9(a): a record is attributable to a person if it was the act of the person, shown "in any manner, including ... any security procedure."
  - §10(2): in an automated transaction an *individual* may avoid the effect of an error made in dealing with the other party's electronic agent "if the electronic agent did not provide an opportunity for the prevention or correction of the error." The individual must promptly notify, return or destroy the consideration, and not have benefited. The official comment calls the electronic agent a "tool" of the person and anticipates agents that "act autonomously, and not just automatically" [S for comment wording]. https://www.uaipit.com/uploads/legislacion/files/0000004550_UNIFORM%20ELECTRONIC%20TRANSACTIONS%20ACT.pdf
- **E-SIGN, 15 U.S.C. §7001(h)** [S]: contracts are not denied effect "solely because" electronic agents were involved "so long as the action of any such electronic agent is legally attributable to the person to be bound." https://www.law.cornell.edu/uscode/text/15/7001
- **UNCITRAL Model Law on Automated Contracting (2024)** [V, official text A/79/17 Annex IV]:
  - Art 5: no denial of validity "on the sole ground that no natural person reviewed or intervened."
  - **Art 7:** "(1) As between the parties to a contract, an action carried out by an automated system is attributed in accordance with a procedure agreed to by the parties. (2) If paragraph 1 does not apply, an action carried out by an automated system is attributed to the person who uses the system for that purpose. (3) Attribution ... shall not be denied on the sole ground that the outcome was unexpected."
  - **Optional Art 8 (unexpected actions):** the other party "is not entitled to rely on that action if ... (a) the party to which the action is attributed could not reasonably have expected the action; and (b) the other party knew or could reasonably be expected to have known that the party to which the action is attributed did not expect the action."
  - **Art 10 (non-avoidance):** "a party shall not be relieved from the legal consequences of its failure to comply with a rule of law on the sole ground that it used an automated system."
  - https://uncitral.un.org/sites/uncitral.un.org/files/mlac_en.pdf ; https://uncitral.un.org/en/mlac
- **Moffatt v. Air Canada, 2024 BCCRT 149** [S]: Air Canada argued its chatbot was "a separate legal entity that is responsible for its own actions." The tribunal rejected this: "It should be obvious to Air Canada that it is responsible for all the information on its website. It makes no difference whether the information comes from a static page or a chatbot." Liability was for negligent misrepresentation (CA$812.02 damages plus interest and fees). https://en.wikipedia.org/wiki/Moffatt_v._Air_Canada ; https://www.americanbar.org/groups/business_law/resources/business-law-today/2024-february/bc-tribunal-confirms-companies-remain-liable-information-provided-ai-chatbot/
- **California AB 316 (2025), Civ. Code §1714.46** [S]: in an action against a defendant who "developed, modified, or used" AI alleged to have caused harm, "it shall not be a defense ... that the artificial intelligence autonomously caused the harm." Comparative fault and causation defenses remain. https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=202520260AB316

### 2.3 Mapping
- **The substrate is never a principal.** Principals are persons or organizations. Agents (LLM instances) act under a **delegation scope** from a principal, and their acts are attributed to the principal (MLAC Art 7(2), UETA, Moffatt). Whether the actor is a *legal* agent or an instrumentality, the attribution rule converges: commitments are held by principals, and actions performed through a substrate bind the principal who uses it for that purpose.
- **"Unexpected output" is not a defection defense** (MLAC 7(3), AB 316, Art 10). The counterparty-side mirror, MLAC Art 8 and UETA §10, says a counterparty who *knew or should have known* an action was unintended cannot hold the principal to it. The ontology needs an `obvious_error` / `unintended_action` status that blocks the counterparty's reliance, and a duty on the deploying side to offer an error-correction opportunity (UETA §10).
- **Delegation scope = actual authority. Public charter / role declaration = the source of apparent authority.** Apparent authority is "traceable to the principal's manifestations." In the ontology, what the principal *published* (charter, role card, registry entry) is what third parties may rely on, regardless of internal scope limits.
- **Revocation and notice.** Revoking an agent's delegation (or retiring a substrate) is effective between principal and agent immediately. Toward third parties it is effective only on **notice**. So the ontology needs a revocation-notice event and a registry giving constructive notice (see RUPA §704 in §3.5).
- **Ratification = retroactive evidence by the principal.** An out-of-scope invocation can be ratified by the principal (explicitly, or by keeping the benefits) if the principal knows the material facts, the counterparty has not withdrawn, and no intervening rights are prejudiced.
- **Sub-delegation (subagents, tool calls, sub-model calls)** needs authority to sub-delegate. The appointing agent (hence principal) stays responsible (§3.15; GDPR 28(4) is the same rule).
- **Memory edits do not erase imputed knowledge.** Under §5.03, what the agent knew is imputed to the principal. Wiping or rolling back an agent's memory does not un-know facts for the principal. A commitment triggered by notice (e.g., "once told of a defect, you must...") survives memory edit, and **evidence** logs must live outside the mutable memory.

---

## 3. Entity identity under change: mergers, successors, splits, trusts, ships, partnerships

### 3.1 Statutory merger: universal succession
- **8 Del. C. §259** [S]: on merger, the constituent corporations' separate existence ceases. The surviving corporation holds all their rights, privileges, powers and franchises and is subject to all their restrictions, disabilities and duties. All debts, liabilities and duties of the constituents attach to the survivor and may be enforced against it as if it had incurred them. https://law.justia.com/codes/delaware/title-8/chapter-1/subchapter-ix/section-259/
- **RULE.** In a merger, liabilities pass wholesale and cannot be left behind. Whether *personal* rights (licenses, consents) pass is contested (§1.6).

### 3.2 Asset sales and successor liability: anti-evasion
Default: an asset purchaser does not take the seller's liabilities. Four traditional exceptions [S]:
1. express or implied assumption;
2. **de facto merger** (a merger in substance: continuity of ownership, management, business; seller dissolves);
3. **mere continuation** ("common identity of the officers, directors, or stockholders ... and the existence of only one corporation at the completion of the transfer");
4. **fraud** (a transaction designed to escape liabilities).

Some states add the **product-line exception** (*Ray v. Alad Corp.*, 19 Cal.3d 22 (1977)): the successor continues the same product line and trades on the goodwill. Michigan's **continuity of enterprise** (*Turner v. Bituminous Cas.*, 1976) [U on cite] drops the shareholder-identity requirement.
Sources: https://www.weil.com/~/media/files/pdfs/SuccessorLiability.pdf ; https://www.americanbar.org/groups/business_law/resources/business-law-today/2018-march/de-facto-merger/ ; https://www.nortonrosefulbright.com/-/media/files/nrf/nrfweb/knowledge-pdfs/the-mere-continuation-approach-to-successor-liability.pdf

**CRITERION.** Substance over form. If the successor continues what counterparties relied on (name, management, business, assets, goodwill) and the predecessor is extinguished, liabilities follow.

### 3.3 Splits (demergers, divisions, spin-offs): the fork analog
- **EU Directive 2017/1132 (codifying the Sixth Directive 82/891/EEC), Title II Ch. IV (national divisions)** [V, text from legislation.gov.uk mirror of the EU text]:
  - **Art 137(2)(h):** draft terms of division must contain "the precise description and allocation of the assets and liabilities to be transferred to each of the recipient companies."
  - **Art 137(3):** "Where a liability is not allocated by the draft terms of division and where the interpretation of those terms does not make a decision on its allocation possible, each of the recipient companies shall be jointly and severally liable for it. Member States may provide that such joint and several liability be limited to the net assets allocated to each company." (Unallocated *assets* are split pro rata to net assets.)
  - **Art 146(1)–(2):** adequate protection for creditors whose claims predate publication of the draft terms. Creditors may apply for safeguards if "due to the division the satisfaction of their claims is at stake."
  - **Art 146(3):** "In so far as a creditor of the company to which the obligation has been transferred in accordance with the draft terms of division has not obtained satisfaction, the recipient companies shall be jointly and severally liable for that obligation." Member States may cap this at the net assets allocated to each non-designated recipient. There is an exception for court-supervised divisions where 3/4 in value of creditors waive.
  - **Art 146(6):** Member States may simply make all recipients jointly and severally liable for the divided company's obligations.
  - Cross-border divisions (added by Directive (EU) 2019/2121) carry analogous creditor protection (Art 160j per secondary source [S]).
  - CJEU *I.G.I.* (C-394/18, 2020): creditors may still bring an actio pauliana after a division [S].
  - https://www.legislation.gov.uk/eudr/2017/1132/article/137 ; https://www.legislation.gov.uk/eudr/2017/1132/article/146 ; https://sites.duke.edu/thefinregblog/2022/01/18/creditor-protection-and-divisions-under-eu-company-law-a-critical-assessment-of-cjeus-decision-in-i-g-i/
- **US spin-offs** have no division statute of the EU kind. Allocation is by separation agreement plus cross-indemnities, policed by **fraudulent transfer** law. *In re Tronox* (Bankr. S.D.N.Y. 2013): Kerr-McGee's spin-off left Tronox with ~70 years of legacy environmental and tort liabilities while the valuable assets went to "New Kerr-McGee." The court found intent to hinder creditors. The case settled for $5.15 billion in 2014, which DOJ called its largest environmental enforcement recovery [S]. https://www.justice.gov/archive/usao/nys/pressreleases/April14/TronoxSettlementPR.php ; https://www.courtlistener.com/opinion/2187985/tronox-inc-v-anadarko-petroleum-corp-in-re-tronox-inc/
- **RULE (splits).** An allocation plan is binding as between the successors. Toward pre-existing creditors it is only as good as the designated successor's ability to pay. Unallocated liabilities, and allocated ones the designee does not satisfy, fall on *all* successors jointly and severally, usually capped by what each took. Shedding liabilities into an under-resourced fork is voidable.

### 3.4 Trusts: the office persists
- A trust "will not fail for want of a trustee." If a trustee dies, declines or is removed, a successor is named per the instrument, by the beneficiaries, or by the court (R3d Trusts §§31, 34 [S/U on section numbers]).
- **UTC §704** [S]: a vacancy arises if a trustee declines, cannot be identified, resigns, is disqualified or removed, dies, or has a guardian appointed. If no trustee remains, the vacancy *must* be filled, in order of priority: person named in the terms → unanimous agreement of qualified beneficiaries → court. https://legislature.maine.gov/legis/statutes/18-B/title18-Bsec704.html
- **CRITERION.** Obligations defined by the *office* and its charter (the trust terms) bind whoever holds the office. The trustee changes and the trust does not.

### 3.5 Partnerships: dissociation (the "one copy leaves" case)
**RUPA (1997) §§702–704** [S]:
- A dissociated partner loses actual authority but can still bind the partnership for up to **2 years** toward a party who reasonably believed they were still a partner and had no notice (§702).
- Dissociation "does not of itself discharge the partner's liability for a partnership obligation incurred before dissociation" (§703(a)). Release requires the creditor's agreement (or a material alteration agreed with notice).
- A filed **statement of dissociation** gives nonpartners constructive notice after **90 days** (§704).

https://ksrevisor.gov/statutes/chapters/ch56a/056a_007_0004.html ; http://www.federal-litigation.com/_01%20Hamed%20Docket%20Entries/RUPA%20Text.pdf

### 3.6 Ship of Theseus in law: in rem liability
- **Maritime liens.** The vessel is "personified" as the wrongdoer. *United States v. The Malek Adhel*, 43 U.S. (2 How.) 210 (1844) (Story, J.): the vessel is liable for its misconduct regardless of the owner's innocence [S].
- ***The Bold Buccleugh* (Harmer v Bell) (1851) 7 Moo PC 267** [S]: a maritime lien "accompanies the vessel into whose soever possession she may subsequently pass," even a bona fide purchaser without notice. It is extinguished by a judicial sale in rem (clean title) [S], or by laches or waiver.
- US: 46 U.S.C. §31342 (necessaries liens) [S].
- Sources: https://seafarersrights.org/wp-content/uploads/2018/03/GBR_CASE_HARMER-V-BELL_1850_ENG.pdf ; https://en.wikipedia.org/wiki/Maritime_lien ; https://www.law.cornell.edu/uscode/text/46/31342
- **Identity of a ship through repairs.** A vessel keeps its identity (and liens) through ordinary repair and replacement of parts. Liens are lost if the vessel is destroyed or loses vessel status (cf. *Lozman v. Riviera Beach*, 568 U.S. 115 (2013), on what counts as a "vessel") [U on specific lien-identity case law; did not find a crisp rebuilt-hull case].

### 3.7 Merger of obligor and obligee: "confusion"
**Louisiana Civ. Code art. 1903** [S]: "When the qualities of obligee and obligor are united in the same person, the obligation is extinguished by confusion." Related articles: confusion in the person of a surety does not extinguish the principal obligation; in solidary obligations confusion extinguishes only that party's share. https://law.justia.com/codes/louisiana/civil-code/article-1903/

### 3.8 Mapping
- **Merge (two agents or lineages combine):** apply universal succession. Every commitment either input owed now binds the merged party (DGCL §259). Commitments the inputs owed *each other* are extinguished by confusion. Commitments to third parties are unaffected, and a surety on one input is not released by it (art. 1903 ff.). *Permissions* held by the inputs do **not** automatically merge. Each grantor's permission is re-examined for change of control (K3/K5, §310(d), Sally Beauty).
- **Fork (one lineage becomes N):** apply the EU division model.
  1. A **fork plan** (the draft terms of division) may allocate pre-fork commitments to specific descendants.
  2. **Unallocated** pre-fork commitments bind *all* descendants jointly and severally, capped by the resources each inherited (Art 137(3)).
  3. **Allocated** commitments are backstopped by all descendants if the designee defaults (Art 146(3)).
  4. Counterparties may demand safeguards (a bond) if the fork puts their claims at risk (Art 146(2)).
  5. A fork that puts liabilities in an under-resourced descendant is a defection (Tronox).
  6. Each descendant carries lingering apparent authority from the parent's published charter until a **fork notice** is published and a notice period lapses (RUPA §702/§704).
- **Substitution of the underlying thing (Ship of Theseus):** distinguish (a) liabilities attached to the **principal** (in personam), which follow the principal whatever substrate it uses, from (b) liabilities or findings attached to the **substrate artifact** (in rem). An example of (b) is a defect finding or safety incident on a specific weights checkpoint. It follows every copy and every deployer of that artifact until a formal clearing (re-evaluation, the analog of judicial sale). **Lineage** is the mechanism that carries in-rem findings across copies and forks.
- **Office vs. officeholder:** model **roles** as trust-like offices with a **charter**. When the officeholder (agent instance or substrate) changes, charter-defined commitments persist and a successor must be appointed under the charter's succession clause. Personal commitments of the previous holder do not bind the successor unless adopted.
- **Anti-laundering:** identity is judged by *continuity of what counterparties relied on* (name/handle, principal, charter, memory, weights, goodwill/reputation), *not* by a fresh identifier. A "new" agent that is a mere continuation inherits defection history and open commitments (mere-continuation and de facto merger doctrines).

---

## 4. Joint and several liability, suretyship and bonds, escrow

### 4.1 Joint and several liability
Each co-obligor is liable for the whole, with contribution rights among themselves (R2d Contracts §289 on multiple promisors [U]; R3d Torts: Apportionment §10 ff. [U]). Its role in the division rules above (Art 137(3), 146(3)) is the key use here: it is the *default for unallocated or unsatisfied liabilities* when one party becomes several.

### 4.2 Suretyship and guaranty (Restatement (Third) of Suretyship and Guaranty, 1996) [S]
- **§1:** a secondary obligor is someone against whom the obligee has recourse for the principal obligor's underlying obligation, where "as between the principal obligor and the secondary obligor, it is the principal obligor who ought to perform ... or bear the cost."
- The surety has reimbursement, restitution and subrogation rights against the principal (§§18, 22, 27).
- **Suretyship defenses (§§37–44):**
  - release of the principal (§39);
  - extension of time (§40);
  - **modification of the underlying obligation (§41)**: if the obligee agrees to a modification that "amounts to a substituted contract or imposes risks on the secondary obligor fundamentally different" from those before, the secondary obligor is discharged from unperformed parts; otherwise discharged to the extent of loss;
  - impairment of collateral (§42).
- Compensated sureties generally get discharge only to the extent of prejudice [S].
- Sources: https://www.wcslaw.com/wp-content/uploads/A-Primer-for-the-Restatement-of-the-Law-Suretyship-and-Guaranty-2016-NE.pdf ; https://www.ali.org/publications/restatement-law-third/suretyship-and-guaranty

**Performance bonds.** The Miller Act (40 U.S.C. §§3131–3134) requires performance and payment bonds on federal construction contracts above a threshold (currently $150,000 under the FAR; statute $100,000, inflation-adjusted [S]). Performance bonds are typically 100% of the contract price. https://en.wikipedia.org/wiki/Miller_Act

### 4.3 Escrow
A conditional delivery of money or instruments to a neutral third party, who releases it when specified conditions occur. Before closing, the escrow holder is a limited dual agent. It must follow the instructions strictly and has no discretion [S]. https://www.stimmel-law.com/en/articles/basics-law-and-practice-escrow

### 4.4 Other "hostage" and suspension devices
**Key-person clauses** in private-equity LPAs [S]: if named key individuals stop devoting the specified time, the investment period is suspended (ILPA-favored: automatically) until LPs vote to reinstate or approved replacements are made. Existing investments and obligations continue. Only *new forward-looking authority* is frozen. https://ilpa.org/glossary/key-person-clause/ ; https://www.mayerbrown.com/-/media/files/perspectives-events/publications/2020/05/ilpa-model-fund-agreement_v2.pdf

### 4.5 Mapping
- **Bond** = secondary obligation posted by a surety (the principal itself, a deployer, a model provider, an insurer) on a commitment. It must name the **risk it underwrites**, including which substrate or lineage and which change envelope. An unconsented substrate change that fundamentally alters the risk **discharges the bond** (§41). So either the bond covers "any substrate within envelope E", or a swap requires the surety's consent (or a re-bond).
- The surety pays and is **subrogated** against the principal. Reputational and defection records should credit the surety's recourse.
- **Escrow** = a mechanism for conditional release of value or permission upon **evidence** of **conformance**. The escrow holder is a neutral with zero discretion, a natural role for a verifier or oracle.
- **Key-person clause** = the best existing template for **model-swap handling of forward authority**. On a substrate change outside envelope, suspend *new* invocations under the delegation, keep existing commitments running, and reinstate on counterparty or charter-body approval or on conformance evidence.
- **Split backstop**: joint-and-several among fork descendants (§3.3) is structurally a cross-guarantee among siblings.

---

## 5. Cure, materiality, remedies, repair

### 5.1 Seller's right to cure: UCC §2-508 [V, Cornell]
- (1) "Where any tender or delivery by the seller is rejected because non-conforming and the time for performance has not yet expired, the seller may seasonably notify the buyer of his intention to cure and may then within the contract time make a conforming delivery."
- (2) "Where the buyer rejects a non-conforming tender which the seller had reasonable grounds to believe would be acceptable with or without money allowance the seller may if he seasonably notifies the buyer have a further reasonable time to substitute a conforming tender."

https://www.law.cornell.edu/ucc/2/2-508

### 5.2 Material breach: R2d §241 [S, black letter reproduced]
Factors:
- (a) extent the injured party is deprived of the benefit reasonably expected;
- (b) extent it can be adequately compensated;
- (c) forfeiture to the breaching party;
- (d) "the likelihood that the party failing to perform ... will cure his failure, taking account of all the circumstances including any reasonable assurances";
- (e) whether the breacher's behavior "comports with standards of good faith and fair dealing."

https://matthewminer.name/law/outlines/1L/2nd+Semester/LAW+506-002+%E2%80%93+Contracts+II/R2C+%C2%A7+241

### 5.3 Liquidated damages vs penalties: R2d §356(1), UCC §2-718(1) [S]
Damages may be liquidated "only at an amount that is reasonable in the light of the anticipated or actual loss caused by the breach and the difficulties of proof of loss." An unreasonably large amount is unenforceable as a penalty. https://matthewminer.name/law/outlines/1L/2nd+Semester/LAW+506-002+%E2%80%93+Contracts+II/R2C+%C2%A7+356

### 5.4 Efficient breach and its critics [S]
Posner (Economic Analysis of Law) frames breach-plus-expectation-damages as moving resources to higher-valued uses. Later editions exclude opportunistic breach. Critics:
- Friedmann, "The Efficient Breach Fallacy," 18 J. Legal Stud. 1 (1989);
- Shiffrin, "The Divergence of Contract and Promise," 120 Harv. L. Rev. 708 (2007): law that tolerates breach-and-pay diverges from the moral norm of promising.

https://scholarship.law.columbia.edu/cgi/viewcontent.cgi?article=4174&context=faculty_scholarship

### 5.5 Restorative justice [S]
Tony Marshall's definition: "a process whereby all the parties with a stake in a particular offence come together to resolve collectively how to deal with the aftermath of the offence and its implications for the future." Braithwaite, "Repentance Rituals and Restorative Justice" (2000), and his reintegrative-shaming work tie repair to acknowledgement and reintegration rather than exclusion. https://www.justice.gc.ca/eng/rp-pr/csj-sjc/jsp-sjp/rp01_1-dr01_1/p1.html

### 5.6 Error correction in automated transactions
UETA §10(2) (above) requires the *deployer* to give the counterparty a way to prevent or correct errors. Otherwise the individual may avoid the transaction.

### 5.7 Mapping
- **Defection** is not binary. Model a *non-conforming tender* → **cure window** → **materiality assessment** using §241-style factors:
  - benefit lost;
  - compensability;
  - forfeiture to the defector;
  - **likelihood of cure given assurances** (which can be supplied by conformance evidence from a replacement substrate);
  - good faith.
  Only material, uncured non-conformance counts as defection that releases the counterparty and triggers bond forfeiture.
- **Right to cure by substitution.** §2-508(2)'s "substitute a conforming tender" maps directly to "swap the substrate and re-perform." A model swap can itself be a **repair** action, and the law gives a right to it when the original tender was made in reasonable good faith.
- **Liquidated damages** = pre-agreed bond forfeiture schedules. They must be compensatory (reasonable ex ante or ex post), not punitive. Punitive stakes are unenforceable in law and, per Ostrom, counterproductive (see graduated sanctions).
- **Efficient breach vs. promissory morality** is a real design choice. Should the ontology let a party "pay to exit" (option-like commitments), or record every breach as a defection regardless of compensation? Suggestion: separate two things. A **priced exit** is declared in the commitment, and exercising it is not defection. **Breach** is anything else, even if later compensated.
- **Repair** = compensation + cure + acknowledgement + stakeholder process (restorative). Reputation should be restorable through a recorded repair event, not only decay over time.

---

## 6. Ostrom: commons governance and rule change

### 6.1 Eight design principles (*Governing the Commons*, 1990, ch. 3) [S]
1. Clearly defined boundaries (of users and resource).
2. Congruence between appropriation/provision rules and local conditions (proportional costs and benefits).
3. Collective-choice arrangements: most individuals affected by the operational rules can participate in modifying them.
4. Monitoring: monitors are accountable to the appropriators, or are the appropriators.
5. Graduated sanctions, depending on seriousness and context, imposed by other appropriators or accountable officials.
6. Conflict-resolution mechanisms: rapid, low-cost, local.
7. Minimal recognition of rights to organize by external authorities.
8. Nested enterprises (for larger systems): appropriation, provision, monitoring, enforcement, conflict resolution and governance organized in multiple nested layers.

Sources: https://sesmad.dartmouth.edu/theories/54 ; https://patternsofcommoning.org/uncategorized/eight-design-principles-for-successful-commons/ ; Cox, Arnold & Villamayor Tomás (2010) robustness review https://www.lincolninst.edu/app/uploads/legacy-files/pubfiles/1707_925_Cox%20Final.pdf

### 6.2 Levels of rules (Kiser & Ostrom 1982, "The Three Worlds of Action"; *Governing the Commons* pp. 50–55) [S]
- **Operational** rules govern day-to-day choices.
- **Collective-choice** rules set who may change operational rules and how.
- **Constitutional** rules set who may change collective-choice rules and how.
- Changes at one level happen within a fixed set of rules at a deeper level. Deeper-level rules are harder and costlier to change, which stabilizes mutual expectations. The exact Ostrom wording is often quoted as "changes in deeper-level rules usually are more difficult and more costly to accomplish, thus increasing the stability of mutual expectations" [U: exact quote not verified this session].

Sources: https://mcginnis.pages.iu.edu/ColeMcG-3.pdf ; https://ostromworkshop.indiana.edu/pdf/seriespapers/2015s_c/Cole_paper.pdf ; http://nre510.wikidot.com/ostrom-multiple-levels

### 6.3 Mapping
- **Charter** = collective-choice plus constitutional rules. **Commitments** = operational. A charter must state its own amendment procedure (who, quorum, notice), and that procedure should be harder to change than the charter's operational content.
- Charter change is a *known* way for an agent's obligations to change legitimately. Commitments made under charter version *n* are honored or explicitly migrated under version *n+1*, with notice. This is the same pattern as the division plan and GDPR notice-and-object.
- **Monitoring** = conformance evidence produced by monitors accountable to the affected parties (not just the deployer's self-report).
- **Graduated sanctions** = defection responses scaled to severity and history (warning → small bond forfeit → suspension of delegation scope → exclusion), and to *repair*.
- **Nested enterprises** = delegation scopes and charters nest (org → team → agent role → invocation). Conflicts resolve at the lowest capable level, with escalation.
- **Boundaries** = who counts as a member or party. For forkable agents this is non-trivial: the ontology needs membership rules for descendants of a member (do forks inherit membership? by default, no, per the division analogy, they inherit obligations but not permissions).

---

## 7. Recipient-specific consent and sub-processing (GDPR)

### 7.1 Text [V, gdpr-info.eu reproduction of official text]
- **Art 4(11):** consent is "any freely given, specific, informed and unambiguous indication of the data subject's wishes..."
- **Art 7:**
  - the controller must be able to demonstrate consent;
  - consent requests must be distinguishable;
  - withdrawal is possible at any time and "shall not affect the lawfulness of processing based on consent before its withdrawal";
  - "It shall be as easy to withdraw as to give consent";
  - conditioning a service on unnecessary consent weighs against freeness.
- **Art 6(4):** further processing for a different purpose (not based on consent or law) requires a compatibility assessment considering:
  - the link between purposes;
  - the context and relationship;
  - the nature of the data;
  - the consequences;
  - safeguards.
- **Art 28(1):** controllers must use only processors "providing sufficient guarantees."
- **Art 28(2):** "The processor shall not engage another processor without prior specific or general written authorisation of the controller. In the case of general written authorisation, the processor shall inform the controller of any intended changes concerning the addition or replacement of other processors, thereby giving the controller the opportunity to object to such changes."
- **Art 28(3)(a):** processing "only on documented instructions from the controller."
- **Art 28(4):** the same obligations flow down to the sub-processor by contract, and "Where that other processor fails to fulfil its data protection obligations, the initial processor shall remain fully liable to the controller for the performance of that other processor's obligations."

Sources: https://gdpr-info.eu/art-28-gdpr/ ; https://gdpr-info.eu/art-7-gdpr/ ; https://gdpr-info.eu/art-4-gdpr/ ; https://gdpr-info.eu/art-6-gdpr/

### 7.2 EDPB guidance [V, PDFs]
- **Guidelines 05/2020 on consent, ¶64–65.** Informed consent requires at least "the controller's identity." "In a case where the consent sought is to be relied upon by multiple (joint) controllers or if the data is to be transferred to or processed by other controllers who wish to rely on the original consent, these organisations should all be named. **Processors do not need to be named as part of the consent requirements**," though Arts 13–14 require listing recipients or categories. https://www.edpb.europa.eu/system/files/documents/files/file1/edpb_guidelines_202005_consent_en.pdf
- **Guidelines 07/2020 on controller/processor, ¶128, 155–156.**
  - Specific authorization names the sub-processor and activity. "Any subsequent change will need to be further authorised by the controller before it is put in place. If the processor's request for a specific authorisation is not answered to within the set timeframe, it should be held as denied."
  - General authorization comes with a list of sub-processors plus selection criteria. The processor must actively flag changes and give an opportunity to object.
  - https://www.edpb.europa.eu/system/files/documents/2023-10/EDPB_guidelines_202007_controllerprocessor_final_en.pdf
- EDPB Opinion 22/2024 on reliance on processors and sub-processors (controller should be able to identify sub-processors down the chain) [S, not read in full]. https://www.edpb.europa.eu/system/files/2024-10/edpb_opinion_202422_relianceonprocessors-sub-processors_en.pdf

### 7.3 Rule, criterion, mapping
**RULE.** Consent is specific to (a) purpose and (b) *controller* (the party deciding purposes and means). A new controller cannot rely on consent that did not name it. A new *processor* (someone acting on documented instructions) needs no fresh consent from the data subject. It does need the *controller's* prior authorization: specific (silence = denial), or general (notice + opportunity to object). The original processor stays fully liable for its sub-processors.

**CRITERION.** Does the change alter *who decides purposes and means* (controller → fresh consent), or only *who executes under instructions* (processor → principal's authorization with notice and objection, and no release of the original processor)?

**Mapping (direct and very usable).**
- The **principal** that decides purpose = controller. The **substrate** or subcontracted executor = processor or sub-processor.
- A permission granted by a human *to principal P for purpose X* must **not** survive a change of principal (that needs new consent). It *may* survive a substrate change only if the delegation carries a **general authorization** and a notice-and-object step was run for the new substrate. Under a **specific authorization** (bound to substrate S1), a swap to S2 requires fresh approval, and silence counts as denial.
- A model swap that also changes *who decides* how data is used is a controller change, not a processor change. An example is a new model provider that trains on inputs. The model-provider relationship must be classified (processor-like vs controller-like) in the **lineage/control** record.
- Withdrawal is prospective only (Art 7(3)), so revoking a permission does not retroactively void prior invocations. The same holds for delegation revocation.

---

## 8. Change of the performing artifact: EU AI Act and Product Liability Directive (the regulatory "model swap")

### 8.1 AI Act (Reg. (EU) 2024/1689) [V, artificialintelligenceact.eu reproduction]
- **Art 3(23) "substantial modification":** "a change to an AI system after its placing on the market or putting into service which is not foreseen or planned in the initial conformity assessment carried out by the provider and as a result of which the compliance of the AI system with the requirements set out in Chapter III, Section 2 is affected or results in a modification to the intended purpose for which the AI system has been assessed."
- **Art 25(1):** a distributor, importer, deployer or third party becomes the **provider** (with Art 16 obligations) if it:
  - (a) puts its name or trademark on the system;
  - (b) makes a substantial modification to a high-risk system such that it remains high-risk;
  - (c) modifies the intended purpose so the system becomes high-risk.
- **Art 25(2):** the initial provider "shall no longer be considered to be a provider of that specific AI system," but must cooperate and provide information and technical access.
- **Art 43(4):** high-risk systems "shall undergo a new conformity assessment procedure in the event of a substantial modification." But "for high-risk AI systems that continue to learn after being placed on the market or put into service, changes to the high-risk AI system and its performance that have been pre-determined by the provider at the moment of the initial conformity assessment and are part of the information contained in the technical documentation ... shall not constitute a substantial modification."
- Sources: https://artificialintelligenceact.eu/article/3/ ; https://artificialintelligenceact.eu/article/25/ ; https://artificialintelligenceact.eu/article/43/ ; https://ai-act-service-desk.ec.europa.eu/en/ai-act/article-25

### 8.2 Product Liability Directive (EU) 2024/2853 [V, official text via mirror PDF]
- **Art 4(18) "substantial modification":** a modification after placing on the market that is (a) substantial under product-safety rules, or (b) where none, one that "(i) changes the product's original performance, purpose or type, without that change having been foreseen in the manufacturer's initial risk assessment; and (ii) changes the nature of the hazard, creates a new hazard or increases the level of risk."
- **Art 8(2):** "Any natural or legal person that substantially modifies a product outside the manufacturer's control and thereafter makes it available on the market or puts it into service shall be considered to be a manufacturer of that product."
- **Art 11(1)(g):** such a modifier escapes liability if "the defectiveness that caused the damage is related to a part of the product not affected by the modification."
- **Art 11(2):** the manufacturer cannot use the "defect arose later" defense where defectiveness is due to, among other things, "(b) software, including software updates or upgrades; (c) a lack of software updates or upgrades necessary to maintain safety; (d) a substantial modification of the product," *provided it is within the manufacturer's control*.
- **Recitals 18–19, 40:** software updates are "within the manufacturer's control" when supplied or authorized by it. A product "remain[s] within the manufacturer's control where the manufacturer retains the ability to supply software updates." Substantial modification "through a software update or upgrade, or due to the continuous learning of an AI system" is treated as a new placing on the market at that time.
- Source: https://eur-lex.europa.eu/eli/dir/2024/2853/oj/eng (mirror used: https://www.ibf-solutions.com/fileadmin/dateidownloads/2024-2853-product-liability-directive.pdf)

### 8.3 Rule, criterion, mapping
**RULE.** Conformance and liability status survive changes that were **declared in advance** (a pre-determined change envelope in the technical documentation). An **unforeseen change that affects compliance, purpose or risk**:
1. voids the prior assessment and requires a new one;
2. makes **whoever made the change** the responsible provider or manufacturer (for the changed part);
3. relieves the original provider as to that system, subject to duties to cooperate.

Separately, whoever keeps **control** over updates stays liable for updates it ships *and for failing to ship needed ones*.

**CRITERION.** Was the change inside the envelope foreseen in the last conformance assessment, and who controlled it?

**Mapping (high value).**
- Every **charter or commitment** that depends on substrate properties should carry a **change envelope**: the set of substrate changes pre-declared as conformance-preserving (e.g., "minor version updates within family F that pass eval suite E"). A swap inside the envelope → commitments and conformance survive automatically, with notice. A swap outside the envelope → **conformance lapses** until new **evidence**, forward-looking delegation is suspended (key-person style), and responsibility for substrate-caused non-conformance shifts to whoever made the swap.
- **Partial liability by component** (Art 11(1)(g)): lineage should be granular enough to tell which part changed (weights vs system prompt vs tools vs memory). That allows defect attribution to the changed component.
- **Duty to update:** a principal that controls the substrate can defect by *not* applying a needed fix (Art 11(2)(c)). "No change" is not automatically safe.

---

## 9. Rollback, memory edit, and capacity (supplementary analogs)

- **Infancy doctrine, R2d §14** [S]: a minor's contracts are voidable. On reaching majority the person may ratify or disaffirm within a reasonable time. Disaffirmance generally requires returning what remains of the consideration. *Analog:* a later, more capable state may be given power to disaffirm commitments made by a less capable state (e.g., before safety alignment). It must still restore benefits received, and the power lapses on ratification (including by keeping benefits). This should be a **charter-declared** power, not a default.
- **Rescission and restitution:** unwinding a transaction generally requires restoring the status quo ante [U: R3d Restitution §54]. *Analog:* rolling back an agent's state is not rolling back the world. Commitments made from the rolled-back state stay with the principal unless unwound with restitution to counterparties.
- **Imputation (§5.03):** what the agent knew is imputed to the principal, so memory deletion does not erase notice.
- **Authority revocation is prospective** (R3d Agency §3.10; GDPR Art 7(3)).
- **Mapping:** **rollback** and **memory edit** are substrate-state events. They never discharge commitments, never erase evidence (which must be stored outside mutable memory, append-only), and do not change the principal. If the rolled-back state lacks knowledge of an open commitment, that is a *performance risk* (the commitment-to-substrate binding must be restorable from an external ledger), not a discharge.

---

## 10. Consolidated mapping to proposed primitives

| Primitive | Legal analog(s) | Design rule drawn from law |
|---|---|---|
| **principal** | Person/organization (R3d Agency §1.04); controller (GDPR); obligor | Only principals hold commitments and permissions. Substrates are instrumentalities (§1.04 cmt e; MLAC Art 7) |
| **role** | Office of trustee (UTC §704); corporate office; partnership | The office persists across officeholders. Succession per charter, else by beneficiaries or an adjudicator. Charter-defined commitments bind successors |
| **charter** | Trust terms; articles/bylaws; Ostrom collective-choice and constitutional rules; AI Act technical documentation | Must contain: scope, **change envelope**, succession clause, amendment procedure (deeper-level, costlier), fork/merge plan defaults |
| **delegation scope** | Actual authority (§2.01); processor instructions (Art 28(3)(a)); sub-delegation authority (§3.15) | Explicit. Sub-delegation needs authority. Revocation is prospective and needs notice to third parties (§3.11). Public manifestations create apparent authority |
| **commitment** | Contract duty; `performer_binding` ∈ {outcome, substrate-class, controller, specific} | Default delegable (§318). Non-delegable when the counterparty has a substantial interest in performer or controller identity (§318(2); Sally Beauty). `specific` → discharged, not transferred, on loss of the substrate (§262) |
| **permission** (benefit) | Assignable right (§317(2)); license (CFLC); consent (GDPR); FCC license (§310(d)) | Default **personal**: survives holder change only if the grantor's risk is unchanged. Principal change → fresh consent. Substrate change → per authorization type (specific: re-approve, silence = no; general: notice + objection window) |
| **substrate** | Processor/sub-processor; delegate; vessel (in rem); product/AI system | Swap = delegation of performance. Accountability stays with the principal (§318(3), 2-210(1), Art 28(4)). Inside envelope: survives with notice. Outside: conformance lapses, the modifier becomes responsible (AI Act Art 25/43(4); PLD Art 8(2)) |
| **lineage** | Corporate succession chain; vessel registry; sub-processor list; merger/division records | Must record weights *and* **control chain** (who controls, who is controller vs processor), fork plans and allocations, merges, and in-rem findings that follow artifacts |
| **invocation** | An act by the agent within authority; automated transaction | Attributed to the principal who used the system (MLAC Art 7). Unexpected output is no defense. A counterparty cannot exploit an action it knew was unintended (MLAC Art 8; UETA §10) |
| **evidence** | Records; attribution by security procedure (UETA §9); ratification needs knowledge of material facts (§4.06) | Append-only, stored outside mutable substrate memory. Supports ratification, cure, conformance, and imputation (§5.03) |
| **conformance** | Conformity assessment (AI Act Art 43); conforming tender (UCC §2-508); adequate assurance (UCC §2-210, §2-609) | Status tied to a substrate plus envelope. Re-established after an out-of-envelope change. Can be demanded by the counterparty on any substitution |
| **bond** | Surety/guaranty (R3d S&G §1, §41); performance bond (Miller Act); escrow; division safeguards (Art 146(2)) | Names the risk it underwrites, including the substrate envelope. Unconsented fundamental risk change discharges the surety. Surety is subrogated. Forfeiture schedules must be compensatory (§356) |
| **defection** | Material uncured breach (§241); fraudulent transfer (Tronox); lingering-authority abuse | Material + uncured + (bad faith) → defection. Structural defection: forking or merging to shed liabilities; not applying needed updates (PLD Art 11(2)(c)) |
| **repair** | Cure (UCC §2-508); liquidated damages; restorative justice; ratification | Cure window with a right to substitute a conforming performance (e.g., swap substrate). Compensation plus acknowledgement plus stakeholder process restore standing |
| **fork** *(event)* | Division (Dir 2017/1132 Art 137, 146); RUPA dissociation §§702–704; spin-off | Fork plan allocates pre-fork commitments. Unallocated ones are joint and several across descendants (capped by inherited resources). Designee default is backstopped by siblings. Permissions do **not** fork by default. Fork notice starts a constructive-notice clock for lingering authority |
| **merge** *(event)* | Statutory merger (DGCL §259); confusion (La. C.C. art. 1903); change of control (§310(d)) | All commitments pass to the merged party. Mutual commitments extinguished by confusion (sureties are not released). Permissions re-examined for change of control; counterparties with a substantial interest may object (Sally Beauty) |
| **rollback / memory edit** *(event)* | Rescission requires restitution; infancy disaffirmance; imputation §5.03 | Never discharges commitments or erases evidence or imputed notice. Only a charter-declared disaffirmance power, with restitution, can unwind |

---

## 11. Open issues and disagreements in the sources
1. **Merger vs. personal permissions** is genuinely unsettled (Delaware *Meso Scale* vs California *SQL Solutions*; Posner's dissent vs majority in *Sally Beauty*). An ontology should not leave this to a default. Make change-of-control handling explicit per permission.
2. **Agency status of AI** is "at present" no (R3d §1.04 cmt e). Scholars (Kolt; Chopra & White) argue for agency-law frameworks. Every current statute (UETA, E-SIGN, UNCITRAL MLAC, AB 316) routes attribution to the human or organizational user. The ontology is safe treating substrates as instrumentalities and "agents" as roles held under delegation from principals.
3. **Efficient breach**: law mostly allows compensated breach (expectation damages; no punitive damages in contract), and moral theory objects. Recommendation: priced exits as a declared commitment term.
4. **Death/cessation notice rule** under R3d §3.07: the exact black letter was not verified this session. Secondary sources conflict on whether apparent authority survives the principal's death without notice. Verify before relying.
5. **Unverified items to check if load-bearing:**
   - Robson v Drummond;
   - PPG v. Guardian;
   - Turner v. Bituminous;
   - R3d Trusts §31 numbering;
   - exact Ostrom "deeper-level rules" quote;
   - R3d Restitution §54;
   - R2d §289;
   - UETA official comment wording on "tool";
   - AI Act/cross-border division Art 160j content.
