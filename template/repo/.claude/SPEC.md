# SPEC.md — Technical Specification

## Architecture Overview

<!--
Describe your system's architecture at a high level. What are the major components and how do they interact?

Example patterns:
- Monolith with modules
- Three-layer (API + Plugin/Connector + UI)
- Microservices with API gateway
- Serverless functions + managed services
- Monorepo with packages (api, dashboard, shared, plugins)
-->

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Core API | | |
| Database | | |
| Cache | | |
| Frontend/Dashboard | | |
| Auth | | |
| External Services | | |
| Infrastructure | | |
| Testing | | |

---

## Core Concepts

<!--
Define the 2-4 most important domain concepts that every feature touches.
These are the mental models the entire team must share.

For each concept, explain:
- What it is
- Why it matters
- How it affects the system
- Key rules/invariants

Example:
### [Concept Name]
Most important concept — every feature touches it.
- **Rule 1:** ...
- **Rule 2:** ...
- **Invariant:** ...
-->

---

## Data Model

<!--
Define every entity in the system. Use this format for each:

### EntityName
```
field_name      Type        Description
```

Include:
- Primary keys, foreign keys, and their relationships
- Enums with all valid values
- JSON/JSONB fields with expected structure
- Timestamps (created_at, updated_at)
- Version fields for optimistic locking where needed
- Status fields with state machine transitions

Tips:
- Start with the entities you'll build in Phase 1
- Mark "Should Have" entities that come in later phases
- Note which fields are required vs optional
- Document any soft-delete patterns
-->

---

## API Design

<!--
Define your API contract. Include:
- API style (REST, GraphQL, gRPC)
- Auth mechanism (API key, JWT, OAuth)
- Base path and versioning strategy
- Standard response envelope
- Pagination, filtering, sorting conventions (reference GUIDELINES.md)
-->

### Endpoint Groups

<!--
List all endpoints grouped by resource. Use this format:

```
METHOD /path                              Description
```

Group by domain area (e.g., stores, products, orders, etc.)
Mark endpoints that belong to later phases.
-->

### Webhook/Event Contracts

<!--
If your system emits events (webhooks, pub/sub, SSE), define them here.

```
event.name                    Description / payload summary
```
-->

---

## Project Structure

<!--
Define the directory structure for the project. This is the source of truth for where code lives.

```
project/
├── CLAUDE.md
├── TASKS.md
├── PROJECT_LOG.md
├── CLAUDE_SUGGESTIONS.md
├── .claude/
│   ├── SPEC.md
│   ├── GUIDELINES.md
│   ├── PHASES.md
│   └── commands/
│       ├── start.md
│       └── stop.md
├── agent-logs/
│   └── archive/
├── logs/
├── src/ (or packages/, apps/, etc.)
│   └── ...
├── tests/
├── docs/
└── ...
```

Be specific about what goes where. Agents use this to know where to create files.
-->
