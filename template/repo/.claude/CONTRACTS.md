# CONTRACTS.md — Cross-Agent Interface Contracts

> **Shared source of truth for boundaries between agents.** When two or more agents must produce/consume the same interface (API response shape, webhook payload, event format, shared type, config schema), the contract is defined here BEFORE either agent begins implementation.
>
> PRODUCT-OWNER approves contracts. TECH-LEAD enforces them during dispatch and review. Changes require PRODUCT-OWNER approval and are logged in the changelog at the bottom.

---

## How Contracts Work

### Lifecycle

1. **PRODUCT-OWNER identifies a coordination boundary** during planning (typically from PHASES.md execution streams or when multiple agents touch the same interface). TECH-LEAD may also escalate the need for a contract during dispatch.
2. **PRODUCT-OWNER drafts the contract** with the producing agent's input (or the coordinator dispatches to API-ARCHITECT for complex contracts via TECH-LEAD).
3. **Contract is written here** with status `DRAFT`.
4. **Both sides confirm** — producer and consumer agents acknowledge the contract in their dispatch response. Status moves to `ACTIVE`.
5. **Agents implement against the contract**, not against assumptions or each other's code.
6. **Changes go through PRODUCT-OWNER** — if an agent discovers the contract needs to change during implementation, they propose the change (not apply it). PRODUCT-OWNER evaluates impact on the other side, updates the contract, and the coordinator notifies affected agents. Logged in the changelog.
7. **Contract is marked `VERIFIED`** once both sides have integration tests passing against it.
8. **Contract moves to `ARCHIVED`** when the feature is stable and the interface is unlikely to change.

### When to Create a Contract

- An API endpoint's response shape is consumed by a frontend component, plugin, or external integration
- A webhook/event payload is produced by one agent and handled by another
- A shared type or interface is used across packages/modules owned by different agents
- A database query result is shaped by one agent and consumed by another's service layer
- A configuration format is written by one agent and read by another

### When NOT Needed

- Work entirely within one agent's ownership boundary
- Internal implementation details that don't cross agent boundaries
- Standard patterns already fully defined in GUIDELINES.md (e.g., error response envelope, pagination format)

---

## Active Contracts

<!--
One section per contract. Format:

### C-[NNN]: [Contract Name]
**Status:** DRAFT | ACTIVE | VERIFIED | DEPRECATED | ARCHIVED
**Producer:** [AGENT] — who builds/owns the interface
**Consumer(s):** [AGENT(S)] — who depends on it
**Phase:** [Phase/Stream reference, e.g., "Phase 2, Stream B, B4-B6"]
**Related files:** [Source files where this interface lives in code]

**Interface:**
```typescript (or json, or whatever is appropriate)
// The actual contract definition — types, shapes, schemas
```

**Rules/Invariants:**
- [Any behavioral contract beyond the shape itself]

**Notes:**
- [Context, edge cases, known limitations]
-->

---

## Draft Contracts

<!-- Contracts being defined but not yet confirmed by both sides -->

---

## Deprecated / Archived Contracts

<!-- Contracts that are no longer active. Keep for historical reference.
Move here with a note on what replaced them and when. -->

---

## Changelog

<!--
Append-only log of contract changes. Every creation, modification, and status change gets an entry.

Format:
### YYYY-MM-DD HH:MM — [Action]
**Contract:** C-[NNN]
**Change:** [What changed]
**Reason:** [Why]
**Impact:** [Which agents/code affected]
**Notified:** [Agents who were informed]
-->
