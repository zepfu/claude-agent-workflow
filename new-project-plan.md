# AAWM — Autonomous Agent Workflow Management

## Overview

Database-backed system for managing autonomous agent workflows across multiple Claude Code instances and repositories. Two interfaces share one PostgreSQL backend: a CLI (`aawm`) for agent-facing interactions within Claude Code sessions, and a web dashboard for human oversight, configuration, and cross-repo monitoring.

---

## Workstream A: Core CLI + Database

Foundation. Everything else depends on basic CRUD and query working.

### A1: PostgreSQL Schema + Connection

- Set up PostgreSQL instance (local dev + VPS)
- Implement `contexts` table with full schema: id, scope, name, type, header, content, inject, priority, status, tags, token_estimate, agent, model, allowed_tools, agent_type, created, updated
- Add `UNIQUE(scope, name, agent)` constraint
- Implement `repos` table: id, name, path, gh_url, complexity_tier (simple/medium/complex/enterprise), created, updated
- Implement `metrics` table: id, repo_id, agent, metric_type, value, timestamp — time-series for health tracking
- Implement `users` table: id, username, email, password_hash, role (admin/user), created, updated
- Password hashing via bcrypt/argon2, never plaintext
- Connection config: env var or `~/.aawm/config.toml` with local/remote profiles
- Auto-compute `token_estimate` on insert/update (`len(content) // 4`)
- Migration system: versioned schema changes (alembic or raw SQL migrations)

### A2: Scope Chain Resolution

- Walk cwd up to root collecting scope markers or using path-based scopes
- Local scope overrides project scope overrides global scope
- `aawm scope` command to show current resolution chain and what each scope contributes
- Handle edge cases: no scope found, conflicting names across scopes

### A3: Basic CRUD Commands

- `aawm add <name>` — interactive or flag-based (--scope, --type, --header, --content, --file, --agent, --tags, --inject, --status)
- `aawm edit <name>` — open in $EDITOR, update DB on save
- `aawm rm <name>` — soft delete (set status=deprecated) with --hard flag for real delete
- `aawm show <name>` — display single context entry
- `aawm ls` — list contexts for current scope chain, with filters: --all, --status, --tags, --type, --agent

### A4: Query + Serve Commands

- `aawm start` — return orchestrator context (inject=always entries for current scope, no agent filter)
- `aawm start --<agent-name>` — return base + agent-specific context
- `aawm serve <name>` — on-demand retrieval of specific context entries
- `aawm serve --tags <tag>` — filtered retrieval
- `aawm query --status Y --last 50` — arbitrary filtered queries
- `aawm --help` — index output: command | tokens | description

### A5: Output Formatting

- Default markdown format: `# name | status | scope` followed by content
- Compact format (--compact): `[name] content...`
- JSON format (--json): for programmatic consumption and API responses
- Token budget awareness: if aawm can detect budget from env, auto-select compact when tight

### A6: Metrics Collection

- `aawm metric log <type> <value>` — agents and hooks write metrics
- Metric types: context_tokens_used, context_velocity, tool_error, task_complete, task_blocked, compaction_count, session_duration
- `aawm metric query --repo --type --since` — CLI access to metrics
- Automatic collection via hooks: session-init logs start, time-check logs checkpoints, gate-check logs blocked attempts
- Retention policy: raw metrics for 30 days, hourly aggregates for 6 months

---

## Workstream B: Workflow Engine

Operational features: task tracking, proposals, approvals, directives. Can develop against mock data while Workstream A builds real CRUD.

### B1: Type System

- Implement all context types: claude_md, agent, skill, command, reference
- Add workflow types: task_log, directive, introspection, suggestion
- Status state machines per type:
  - task_log: pending → active → complete | blocked
  - directive: pending → acknowledged → complete
  - introspection: pending_review → approved | rejected
  - suggestion: proposed → approved | rejected
- Validate status transitions in application layer

### B2: Task Management

- `aawm task add "description" --agent tech-lead` — create task_log entry
- `aawm task ls` — list tasks by status, agent, recency
- `aawm task update <id> --status complete` — update task status
- `aawm task log` — append to task completion log
- Agents can write task updates: `aawm task complete <id> --summary "..."`

### B3: Proposal + Approval Pipeline

- `aawm propose --agent tech-lead --content "Add caching layer..."` — agent creates suggestion
- `aawm review` — list pending proposals across all agents
- `aawm approve <id>` — approve proposal, change status
- `aawm reject <id> --reason "..."` — reject with feedback
- `aawm directives --<agent-name>` — agent queries approved items relevant to them
- Approved suggestions can auto-promote to context entries via flag

### B4: Introspection System

- `aawm introspect --agent tech-lead` — agent writes self-assessment
- Structured fields: workflow_issues, suggested_agents, constraints, recommendations
- `aawm introspect review` — you review pending introspections
- Approved introspection items feed back into context or agent definitions
- Gate-based triggers: agents introspect at defined project milestones

### B5: Infrastructure Gate-Check

- `aawm gate-check` — reads bash command from stdin, inspects for destructive patterns
- Configurable pattern lists per CLI tool (your cloud CLI, kubectl, terraform, etc.)
- Whitelist read-only commands (list, status, info, describe)
- Block mutations (create, destroy, delete, resize, deploy) with exit code 2
- Namespace-aware: allow creates in `testing` namespace, block `production`
- Dry-run passthrough: allow `--dry-run` flagged commands

---

## Workstream C: Claude Code Integration

Hooks, agents, sync. Can develop independently using stub aawm commands.

### C1: Hook System

- `aawm install` — writes hook config to `~/.claude/settings.json`
- SessionStart hook: `aawm session-init` (record timestamp, verify sync, log session start metric)
- SubagentStop hook: `aawm time-check` (elapsed time tracking, CTO report triggers)
- Stop hook: `aawm time-check --on-stop` (orchestrator checkpoint)
- PreToolUse hook: `aawm gate-check` (infrastructure mutation blocking)
- PostToolUse hook: `aawm metric tool-result` (log tool errors for health tracking)
- PreCompact hook: `aawm pre-compact` (output state summary for compaction input, log compaction metric)
- `aawm install --dry-run` to preview what would be written

### C2: Agent File Management

- Agent markdown files stay hand-authored in `.claude/agents/`
- Frontmatter: name, model, tools, memory
- System prompt includes `aawm start --<agent-name>` instruction inherited from CLAUDE.md
- `aawm agent ls` — list known agents from DB + filesystem
- `aawm agent validate` — check agent files match DB entries, flag orphans

### C3: CLAUDE.md Management

- Generate minimal CLAUDE.md content:
  ```
  Python 3.12, pytest, black, ruff.
  Additional project context available via `aawm --help`.
  Run `aawm start` on new session, or `aawm start --<your-agent-name>` if you are a subagent.
  ```
- `aawm sync claude-md` — write/update the CLAUDE.md section
- Keep universal conventions (language, toolchain, style) in CLAUDE.md since it survives compaction
- Keep session-specific and reference context in aawm (re-fetchable)

### C4: Agent Memory Integration

- Support memory scopes: user, project, local
- user memory: `~/.claude/agent-memory/<agent>/`
- project memory: `.claude/agent-memory/<agent>/` (git tracked)
- local memory: `.claude/agent-memory/<agent>/` (gitignored)
- MEMORY.md as index (first 200 lines loaded at startup), topic files on demand
- `aawm memory --<agent-name>` — show memory status and size

### C5: Sync Command

- `aawm sync` — full sync operation:
  - Validate DB integrity
  - Generate/update CLAUDE.md section
  - Verify agent files exist for DB-registered agents
  - Report drift between DB and filesystem
- `aawm sync --check` — dry run, report what would change
- `aawm sync --force` — overwrite filesystem from DB

### C6: Infra-Engineer Agent Setup

- Create infra-engineer agent file with user memory scope
- Seed initial memory: preferred region, OS image, SSH keys, naming conventions, firewall defaults
- Wire up gate-check hook for your cloud CLI
- Create cli-essentials context (always loaded, common commands)
- Create cli-full-reference context (manual load, complete docs)
- Test provision → gate → approve → execute flow end to end

---

## Workstream D: Web Dashboard

Human-facing management plane. Shares the same PostgreSQL backend and data access layer as the CLI. Can develop UI against API stubs from day one.

### D1: Backend API

- FastAPI application with versioned routes (`/api/v1/`)
- Auth: JWT tokens, bcrypt password hashing, refresh token rotation
- Admin endpoints: user CRUD, role management
- Repo endpoints: list, detail, register, update complexity tier, unregister
- Agent endpoints: list all, detail, edit config, list repos using agent
- Context endpoints: CRUD mirroring CLI (add, edit, list, query)
- Task endpoints: list, detail, approve, reject (proposal pipeline via API)
- Metrics endpoints: health summary per repo, time-series queries, aggregates
- Memory endpoints: read/write agent memory files (user + project scope)
- Sync endpoint: trigger `aawm sync` for a given repo, return diff preview
- WebSocket channel for live metric updates and notification feed

### D2: Authentication + Authorization

- Login/register with email + password
- Password storage: argon2id hashing
- JWT access tokens (short-lived) + refresh tokens (longer-lived, rotatable)
- Role system: admin (full access, user management) and user (own repos, read-only on others configurable)
- Admin can invite users, deactivate accounts, assign repo access
- Session management: active sessions list, force logout
- Rate limiting on auth endpoints

### D3: Dashboard — Repo Overview

- Card-based grid layout for all registered repos
- Each card shows:
  - Repo name + link to GitHub
  - GitHub Actions badge(s) (CI status, coverage, deploy)
  - Complexity tier indicator (simple/medium/complex/enterprise) — color-coded
  - Health indicator: composite score from context velocity, tool error rate, task throughput
  - Active agents count
  - Task summary: pending / active / complete / blocked
  - Last activity timestamp
  - Pending proposals count (attention badge)
- Sort options: needs attention (default), alphabetical, last active, complexity
- Filter by: complexity tier, health status, has pending proposals
- Quick actions from card: focus repo, open GitHub, trigger sync

### D4: Dashboard — Repo Detail View

- Expanding panel or dedicated view when repo card is focused
- Tabs or sections:
  - Tasks: full task list with status filters, agent filters, timeline view
  - Agents: agents active in this repo, their project-specific memory, last activity
  - Suggestions: pending proposals and introspection reports for this repo, approve/reject inline
  - Context: browsable list of all context entries scoped to this repo, with search and filters
  - Metrics: time-series charts — context velocity, tool errors, task completion rate, session durations
  - Settings: complexity tier, GitHub URL, scope path, sync status
- Inline editing for context entries with save → sync prompt
- Task detail view: full history, agent assignment, status transitions with timestamps

### D5: Dashboard — Global Agent Gallery

- All agents across all repos in a grid/list view
- Each agent card shows:
  - Name, model, memory scope (user/project/local)
  - Repos where this agent is active
  - Global memory summary (user-scoped memory preview)
  - Last active timestamp across all repos
- Agent detail view:
  - Full agent config: frontmatter fields, system prompt preview
  - Edit-in-place for agent configuration
  - Sync warning banner: "Changes not synced to: repo-a, repo-b" with sync button
  - Global memory: MEMORY.md content, topic files list, edit capability
  - Per-repo memory: project-scoped memories for each repo this agent works in
  - Activity history: recent tasks, proposals, introspection reports across repos

### D6: Notification + Action Feed

- Persistent feed across the dashboard (sidebar or top bar)
- Items: pending proposals, introspection reports awaiting review, health alerts, sync drift warnings, gate-check blocks
- Each item is actionable: approve/reject inline, link to repo detail, trigger sync
- Unread count badge on navigation
- Filterable by type, repo, agent
- WebSocket-powered: new items appear in real time without refresh

### D7: UI Foundation

- Light and dark mode from day one, system preference detection with manual toggle
- Accessibility: WCAG 2.1 AA compliance
  - Semantic HTML, proper ARIA labels
  - Full keyboard navigation: tab order, focus indicators, skip links
  - Screen reader friendly: live regions for notifications, meaningful alt text
  - Sufficient color contrast in both themes
  - Reduced motion support
- Keyboard shortcuts:
  - `g d` — go to dashboard
  - `g a` — go to agents
  - `g n` — go to notifications
  - `/` — focus search
  - `j/k` — navigate items in lists
  - `a` — approve selected proposal
  - `r` — reject selected proposal
  - `?` — show shortcut help overlay
- Responsive: functional on tablet, primary target is desktop
- Command palette (Cmd+K / Ctrl+K): search repos, agents, tasks, navigate anywhere

### D8: Infrastructure Cost View

- Aggregated infrastructure spend across repos where infra-engineer is active
- Per-repo cost breakdown: instance count, hourly burn rate, projected monthly
- Active resources list: instance name, size, region, uptime, cost
- Alerts: instances older than configurable threshold, spend exceeding budget
- Historical cost chart: daily/weekly/monthly trend

---

## Phase 5: Integration + Hardening

After workstreams converge.

### I1: End-to-End Testing

- Fresh session: SessionStart hook → aawm session-init → Claude reads CLAUDE.md → runs aawm start → gets context
- Agent delegation: orchestrator delegates → agent runs aawm start --agent-name → gets scoped context
- Proposal flow: agent proposes → notification appears on dashboard → approve via web → agent sees directive via CLI
- Infra flow: agent attempts create → gate-check blocks → dashboard shows blocked action → approve via web → executes
- Compaction: PreCompact outputs summary → post-compaction Claude re-fetches via aawm → no context loss
- Multi-machine: local session + VPS session both hitting Postgres without conflicts
- Dashboard: metrics flowing from hooks → visible on repo cards in real time

### I2: Error Handling + Recovery

- DB connection failures: graceful fallback message in CLI, error state in dashboard
- Missing scope: clear error with suggested fix
- Stale sync: detect drift, warn on session-init, visual indicator on dashboard
- Agent stuck detection: PostToolUse hook tracking repeated identical commands, alert in notification feed
- Cost tracking: `aawm infra-cost` via CLI, cost view on dashboard

### I3: Token Optimization

- Measure actual token usage of aawm outputs across real sessions
- Tune output formats: identify where compact vs full markdown matters
- Profile scope chain resolution performance
- Set up `aawm stats` — token usage across projects, agents, context types
- Context versioning: version column or history table for rollback capability

### I4: Secret Management

- Pattern for CLI tokens, API keys, SSH keys
- Never stored in aawm context entries or agent memory
- Environment variables or `aawm secrets` command that injects at runtime without persistence
- Audit: `aawm audit` scans DB and memory files for accidentally stored secrets
- Dashboard: never displays secret values, only shows "configured" / "missing" status

---

## Parallelization Map

```
Week 1-2        Week 2-3        Week 3-4        Week 4-5        Week 5-6
──────────────────────────────────────────────────────────────────────────
A1: Schema ───► A2: Scope ────► A4: Query ────► A5: Format
              ► A3: CRUD ─────► A6: Metrics ──►

B1: Types ────► B2: Tasks ────► B3: Proposals ► B4: Introspect
                              ► B5: Gate-check►

C1: Hooks ────► C2: Agents ──► C3: CLAUDE.md ► C5: Sync
              ► C4: Memory ──►               ► C6: Infra Agent

D7: UI Found ► D1: API ──────► D3: Repo Cards► D4: Repo Detail
             ► D2: Auth ─────► D5: Agents ──► D6: Notifications
                                             ► D8: Cost View

                                                      Week 6-8
                                                ────────────────────
                                                I1: E2E Testing
                                                I2: Error Handling
                                                I3: Token Optimization
                                                I4: Secret Management
```

A1 is the only hard blocker — schema must exist before anything writes to it. Workstreams B, C, and D can develop against mock data, stub commands, or API stubs from day one. D7 (UI foundation) starts immediately alongside A1 since it has no data dependency. The integration phase assumes all four workstreams are substantially complete.

---

## Tech Stack

### Shared
- PostgreSQL 16+ (single source of truth, local dev + VPS)
- Python 3.12+
- Thin data access layer (not an ORM) shared between CLI and API
- Alembic for schema migrations
- TOML config: `~/.aawm/config.toml`

### CLI
- Click or Typer for CLI framework
- psycopg2 for DB access

### Web Dashboard
- FastAPI for backend API
- asyncpg for async DB access
- JWT auth (python-jose + passlib[argon2])
- React + TypeScript for frontend
- Tailwind CSS for styling
- Recharts or similar for time-series charts
- WebSocket (FastAPI native) for live updates

---

## File Locations

| What | Where |
|---|---|
| Database | PostgreSQL (local dev + VPS) |
| CLI config | `~/.aawm/config.toml` |
| Hooks | `~/.claude/settings.json` |
| Agent files | `.claude/agents/*.md` |
| CLAUDE.md | Project root |
| Agent memory (user) | `~/.claude/agent-memory/<agent>/` |
| Agent memory (project) | `.claude/agent-memory/<agent>/` |
| Agent memory (local) | `.claude/agent-memory/<agent>/` (gitignored) |
| Web dashboard | VPS, served via reverse proxy |
| API | VPS, FastAPI behind nginx/caddy |