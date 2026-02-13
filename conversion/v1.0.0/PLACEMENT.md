# PLACEMENT.md — File Placement Map

This document maps every file in the template to its installation destination.
**You don't need to do this manually** — the `/convert` command handles all placement.

---

## One-Time Bootstrap

Before the first use, manually install the `/convert` command:

```bash
mkdir -p ~/.claude/commands
cp global/commands/convert.md ~/.claude/commands/
```

After this, all future setup is handled by `/convert`.

---

## Per-Project Workflow

1. Drop this zip file in the project's repo root
2. Run `/convert`
3. `/convert` handles everything below automatically

---

## What Goes Where

### Global → `~/.claude/` (shared across all projects)

```
global/agents/*.md              → ~/.claude/agents/
  api-architect.md                  Backend API design review
  backend-lead.md                   Core backend engineering
  compliance-officer.md             Regulatory & privacy
  data-engineer.md                  Analytics & data pipelines
  database-admin.md                 Database operations
  database-engineer.md              Query optimization
  devops-engineer.md                CI/CD & deployment
  frontend-lead.md                  Frontend & CMS plugins
  incident-responder.md             Runbooks & incident management
  infrastructure-engineer.md        Server & container infra
  integrations-lead.md              Third-party API integrations
  mobile-engineer.md                Native/cross-platform mobile
  network-admin.md                  Networking & proxy
  pentest-team.md                   Penetration testing
  performance-engineer.md           Load testing & profiling
  product-owner.md                  Vision, roadmap, priorities
  qa-engineer.md                    Testing & quality gates
  release-manager.md                Release process & versioning
  security-engineer.md              Application security
  solutions-architect.md            System architecture
  tech-lead.md                      Execution quality & dispatch
  tech-writer.md                    Documentation
  ux-designer.md                    User experience design

global/commands/*.md            → ~/.claude/commands/
  convert.md                        /convert — setup & conversion
  start.md                          /start — session initialization
  stop.md                           /stop — session shutdown
  status.md                         /status — read-only check
```

### Repo → `<project>/` (per-project)

```
repo/CLAUDE.md                  → <project>/CLAUDE.md
repo/TASKS.md                   → <project>/TASKS.md
repo/PROJECT_LOG.md             → <project>/PROJECT_LOG.md
repo/CLAUDE_SUGGESTIONS.md      → <project>/CLAUDE_SUGGESTIONS.md
repo/.claude/SPEC.md            → <project>/.claude/SPEC.md
repo/.claude/GUIDELINES.md      → <project>/.claude/GUIDELINES.md
repo/.claude/PHASES.md          → <project>/.claude/PHASES.md
repo/.claude/CONTRACTS.md       → <project>/.claude/CONTRACTS.md
repo/.claude/GITHUB_INTEGRATION.md → <project>/.claude/GITHUB_INTEGRATION.md
repo/agent-logs/_TEMPLATE.md    → <project>/agent-logs/_TEMPLATE.md
repo/agent-logs/archive/        → <project>/agent-logs/archive/   (empty)
repo/logs/REJECTED_SUGGESTIONS.md → <project>/logs/REJECTED_SUGGESTIONS.md
repo/logs/                      → <project>/logs/
```

### Created During Setup (not in template)

```
<project>/agent-logs/product-owner.md      ← from _TEMPLATE.md
<project>/agent-logs/tech-lead.md          ← from _TEMPLATE.md
<project>/agent-logs/<agent>.md            ← one per agent in roster
```

---

## Template-Only Files (not installed anywhere)

```
PLACEMENT.md          ← This file
CONVERSION.md         ← Conversion instructions (read by /convert)
README.md             ← Template overview
```
