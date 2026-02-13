# PHASES.md — Build Phases & Execution Plan

## Current Status

<!--
Update this section every session. It's the first thing PRODUCT-OWNER reviews when invoked for planning.
Mark phases as: NOT STARTED | ACTIVE | SUBSTANTIALLY COMPLETE ✅ | COMPLETE ✅
-->

### Phase 1 — [Status]

**Built:**
- [List completed deliverables]

**Gaps:**
- [List remaining items]

### Phase 2 — [Status]

**Built:**
- [List completed deliverables]

**Gaps:**
- [List remaining items]

---

## Build Phases

<!--
Define 3-5 phases. Each phase should have:
- A clear deliverable (what a user can DO when this phase is done)
- A timeline estimate
- A checklist of items to build

Phases should be ordered by dependency: each phase builds on the previous.
Keep Phase 1 small — it's the foundation everything else depends on.
-->

### Phase 1: Foundation (Weeks 1–[N])
**Deliverable:** [What a user can do when this phase is done]

- [ ] [Item 1]
- [ ] [Item 2]
- [ ] [Item 3]

### Phase 2: [Name] (Weeks [N]–[N])
**Deliverable:** [What a user can do when this phase is done]

- [ ] [Item 1]
- [ ] [Item 2]
- [ ] [Item 3]

### Phase 3: [Name] (Weeks [N]–[N])
**Deliverable:** [What a user can do when this phase is done]

- [ ] [Item 1]
- [ ] [Item 2]

### Phase 4: Polish & Launch (Weeks [N]–[N])
**Deliverable:** Production-ready MVP.

- [ ] Security hardening (full audit)
- [ ] Finalized documentation
- [ ] E2E test suite, performance testing
- [ ] Pilot launch prep

---

## Execution Streams

<!--
Define parallel work streams. Typical patterns:

- Stream A: Gap closure / tech debt from previous phase
- Stream B: Current phase feature work
- Stream C: Infrastructure / DevOps foundation

Each stream has a task table with agent assignments, branches, and dependencies.
-->

### Stream A: [Previous Phase] Gap Closure

| Task | Agent | Status |
|------|-------|--------|
| A1. [Task] | [AGENT] | |
| A2. [Task] | [AGENT] | |

### Stream B: Phase [N] — [Name]

| Task | Agent | Branch | Depends On |
|------|-------|--------|------------|
| B1. [Task] | [AGENT] | `feature/[name]` | A1 |
| B2. [Task] | [AGENT] | `feature/[name]` | B1 |

### Stream C: Infrastructure Foundation

| Task | Agent | Status |
|------|-------|--------|
| C1. [Task] | [AGENT] | |
| C2. [Task] | [AGENT] | |

---

## Phase Gate Checks

<!--
Gate checks prevent moving forward with unresolved issues.
All items must be true before advancing. PRODUCT-OWNER evaluates these.

Each gate check item should also exist as a GitHub Issue:
- Milestone: the phase being gated
- Label: type:gate-check
- Assigned to the reviewing agent
- Project field: Gate Blocker = true

When all gate-check issues in a milestone are closed, the phase is complete.

IMPORTANT: Every phase gate MUST include a CI health check. No phase transition
with failing GitHub Actions on main/develop. Use: gh run list --status failure

At every phase gate, also:
1. Check CLAUDE_SUGGESTIONS.md for outstanding items awaiting operator review.
   Remind the operator if any are pending — they should be resolved before advancing.
2. Ask TECH-LEAD and PRODUCT-OWNER for framework feedback:
   - Are there agent types missing that would have helped this phase?
   - Are there workflow optimizations that would improve the next phase?
   - Did any agents hit context limits or get overloaded with reference files?
   - Were cross-agent contracts clear, or did handoffs cause friction?
   - Were tasks appropriately scoped and dependencies correctly identified?
   - Did the template provide adequate structure, or were sections missing?
   Post actionable feedback to the framework repo's CLAUDE_SUGGESTIONS.md (see Cross-Repo Feedback).
-->

### Phase 1 → Phase 2

All must be true:
- [ ] CI green on main/develop (`gh run list --status failure` returns empty)
- [ ] [Core functionality works end-to-end]
- [ ] [Tests passing with adequate coverage]
- [ ] [Security review complete, no Critical/High open]
- [ ] [Documentation updated]
- [ ] [All code merged via approved PRs]

### Phase 2 → Phase 3

All must be true:
- [ ] [Phase 2 deliverable demonstrated]
- [ ] [Integration tests on all new endpoints]
- [ ] [Security review complete]
- [ ] [API spec updated]
- [ ] [Database queries reviewed and optimized]

### Phase 3 → Phase 4

All must be true:
- [ ] [End-to-end critical path works]
- [ ] [Pentest complete on high-risk surface, no Critical/High open]
- [ ] [Load test passes at target concurrency]
- [ ] [All critical test scenarios passing]

### Phase 4 → v1 Release

- [ ] All Phase 4 deliverables complete
- [ ] Full pentest, all Critical/High resolved
- [ ] Full regression suite passing
- [ ] Documentation complete and reviewed
- [ ] Go-live runbook tested on staging
- [ ] Pilot users onboarded on staging
- [ ] Release candidate tagged, changelog generated
- [ ] PRODUCT-OWNER final recommendation, operator approval

---

## Pentest Timing

<!--
Define when to run pentests. Common pattern:
1. After the phase that introduces the highest-risk surface (payments, auth, PII)
2. Before v1 release — full assessment

Don't pentest too early — insufficient attack surface wastes effort.
SECURITY-ENGINEER does continuous review throughout.
-->
