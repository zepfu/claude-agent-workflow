# CONVERSION.md — Converting to the Project Coordinator Model

This document provides instructions for converting an existing Claude Code project to the **Project Coordinator model**.

> **Use the `/convert` slash command** to have Claude Code walk through these steps interactively using your repo's actual context.

---

## What Changed and Why

### Role Hierarchy

**Old:**
```
CTO (CLAUDE.md — main session, does everything)
└── Engineering Agents
```

**New:**
```
OPERATOR (human — final authority)
│
PROJECT-COORDINATOR (CLAUDE.md — main session, state/routing/tracking)
├── PRODUCT-OWNER (vision, roadmap, priorities, spec, gates)
├── TECH-LEAD (execution quality, agent dispatch, code review)
│   └── Engineering Agents
```

### Suggestion Workflow

**Old:** Suggestions used `[PROPOSED]`/`[APPROVED]`/`[REJECTED]` headings with `## Applied` and `## Rejected` sections. CTO processed on session start only.

**New:**
- Checkbox format matching TASKS.md: `- [ ] [CRITICALITY] Description — PROPOSER (via AGENT)`
- Operator marks `[Y]` (yes), `[N]` (no), or `[E]` (explain more)
- Processed **continuously** — same cadence as task injection, not just on `/start`
- `[Y]`: edit applied, `[SUGGESTION] [APPROVED]` logged to PROJECT_LOG.md, deleted from file
- `[N]`: `[SUGGESTION] [REJECTED]` logged to PROJECT_LOG.md, archived to `logs/REJECTED_SUGGESTIONS.md`, deleted from file
- `[E]`: routed back to proposer for more detail, reset to `[ ]` after expansion
- CLAUDE_SUGGESTIONS.md only contains `[ ]` items — clean pending inbox
- Before proposing new suggestions, check `logs/REJECTED_SUGGESTIONS.md` to avoid re-proposing rejected items
- Attribution chain: `PROPOSER (via UNDERLYING-AGENT)` tracks who wrote it and whose work surfaced it

### New Files

- `logs/REJECTED_SUGGESTIONS.md` — Append-only archive of rejected suggestions. Checked before proposing new items.

### Log Ordering

PROJECT_LOG.md is append-only, ascending by time. New entries always go at the bottom. To catch up on recent activity, read from the tail (`tail -n 50`). This applies within sessions and across sessions — the file grows downward naturally.

### Role References Updated

All files updated:
- "CTO" → PRODUCT-OWNER (strategic), TECH-LEAD (operational), or coordinator (state/routing)
- "PROJECT-OWNER" (old) → TECH-LEAD
- "PROJECT-COORDINATOR" (old sub-agent) → main session

---

## Pre-Conversion Checklist

- [ ] Session cleanly stopped (`/stop`)
- [ ] No in-flight work
- [ ] PROJECT_LOG.md has session-end entry
- [ ] Git working tree clean
- [ ] Template zip dropped in repo root

---

## Conversion Steps

### Step 1: Global Agents (`~/.claude/agents/`)

**Install/update all agents** from the template. This ensures every agent definition is current:
- All 23 agent definitions copied to `~/.claude/agents/`
- Existing agents are updated to latest template versions
- New agents (e.g., `product-owner.md`, `tech-lead.md`) are added

**Remove old agents (if present):**
- `~/.claude/agents/project-owner.md` — replaced by `tech-lead.md`
- `~/.claude/agents/project-coordinator.md` — now the main session, not a sub-agent

### Step 2: Global Commands (`~/.claude/commands/`)

Install all four to `~/.claude/commands/`: `start.md`, `stop.md`, `status.md`, `convert.md`. Key changes:
- Coordinator perspective throughout
- Continuous suggestion processing (not just `/start`)
- Y/N/E checkbox format
- Rejected suggestions archived to `logs/REJECTED_SUGGESTIONS.md`

### Step 3: Agent Logs

- Create `agent-logs/product-owner.md` and `agent-logs/tech-lead.md`
- Rename `project-owner.md` → `tech-lead.md` if it existed
- Archive `project-coordinator.md` if it existed

### Step 4: CLAUDE.md

Full rewrite. Extract project content, rebuild with template structure. Key changes:
- Role Hierarchy with dispatch flow
- Suggestion Protocol with Y/N/E, continuous processing, rejected log, attribution chain
- Mid-session checks include CLAUDE_SUGGESTIONS.md
- `[SUGGESTION]` entry type in Project Log
- Who Reads What for agent logs

### Step 5: State Files

**TASKS.md:** Update header — "CTO agent" → "project coordinator"

**PROJECT_LOG.md:** Update header — add `[SUGGESTION]` entry type, update role attribution

**CLAUDE_SUGGESTIONS.md:** Major restructure:
- Migrate `## Applied` items → PROJECT_LOG.md as `[SUGGESTION] [APPROVED]` entries
- Migrate `## Rejected` items → PROJECT_LOG.md as `[SUGGESTION] [REJECTED]` entries AND to `logs/REJECTED_SUGGESTIONS.md`
- Convert `[PROPOSED]` items to checkbox format: `- [ ] [CRIT] Description — PROPOSER (via AGENT)`
- Remove old section headers
- Use new template scaffolding

### Step 6: Reference Files

**CONTRACTS.md:** "CTO creates/approves" → "PRODUCT-OWNER approves"
**PHASES.md:** "CTO evaluates" → "PRODUCT-OWNER evaluates"
**GITHUB_INTEGRATION.md:** All role references updated
**SPEC.md, GUIDELINES.md:** Add new sections, update guidance comments

### Step 7: New Files

- Create `logs/REJECTED_SUGGESTIONS.md` from template

---

## Role Mapping

| Old | New |
|-----|-----|
| CTO (main session) | PROJECT-COORDINATOR (main session) |
| CTO strategy | PRODUCT-OWNER |
| CTO execution | TECH-LEAD |
| PROJECT-OWNER (old) | TECH-LEAD |
| PROJECT-COORDINATOR (old) | Main session |
| `[PROPOSED]` → `## Applied` | `[ ]` → `[Y]` → PROJECT_LOG.md |
| `[PROPOSED]` → `## Rejected` | `[ ]` → `[N]` → PROJECT_LOG.md + REJECTED_SUGGESTIONS.md |
| (no equivalent) | `[ ]` → `[E]` → expanded → `[ ]` |
| CTO writes suggestions | TECH-LEAD + PRODUCT-OWNER write suggestions |
| No attribution chain | `PROPOSER (via AGENT)` attribution |

---

## Rollback

```bash
git checkout -- CLAUDE.md TASKS.md PROJECT_LOG.md CLAUDE_SUGGESTIONS.md .claude/
rm logs/REJECTED_SUGGESTIONS.md
```

Remove `product-owner.md` and `tech-lead.md` from `~/.claude/agents/`. Restore old commands from git. Add `[NOTE]` to PROJECT_LOG.md explaining rollback.
