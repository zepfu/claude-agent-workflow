# Claude Code Project Orchestrator

A project management framework for Claude Code that organizes work through specialist agent personas.

```
OPERATOR (human — final authority)
│
PROJECT-COORDINATOR (main session — state, routing, GitHub)
├── PRODUCT-OWNER (vision, roadmap, priorities, spec, gates)
├── TECH-LEAD (execution quality, agent dispatch, code review)
│   └── Engineering Agents (implementation specialists)
```

## Setup

### First time ever (one-time bootstrap)

Extract the zip anywhere and install the `/convert` command:

```bash
unzip claude-code-project-orchestrator.zip -d /tmp/orchestrator
mkdir -p ~/.claude/commands
cp /tmp/orchestrator/global/commands/convert.md ~/.claude/commands/
rm -rf /tmp/orchestrator
```

### Per project

1. Drop the zip in your project's repo root
2. Run `/convert`

That's it. `/convert` installs global agents and commands, places all repo files, and if an existing CTO-orchestrator CLAUDE.md is found, converts it to the new model while preserving all project-specific content.

## Commands

| Command | What it does |
|---------|-------------|
| `/convert` | Set up a new project or convert an existing one from the template zip |
| `/start` | Begin a session — read state, plan with PRODUCT-OWNER, dispatch via TECH-LEAD |
| `/stop` | End a session — gather state, sync GitHub, write summary |
| `/status` | Read-only check — no writes, no agent invocations |

## Available Agents (23)

All agents live in `~/.claude/agents/`. Only add the ones you need to your project's CLAUDE.md roster.

**Leadership:** product-owner, tech-lead
**Core Engineering:** backend-lead, frontend-lead, api-architect, integrations-lead, mobile-engineer
**Quality & Security:** qa-engineer, security-engineer, pentest-team, performance-engineer
**Data & Infrastructure:** database-engineer, database-admin, data-engineer, infrastructure-engineer, network-admin, devops-engineer
**Operations & Governance:** release-manager, incident-responder, compliance-officer, solutions-architect
**Design & Documentation:** ux-designer, tech-writer

## Scaling

| Size | Agents | Typical Roster |
|------|--------|----------------|
| Small | 5–7 | PRODUCT-OWNER, TECH-LEAD, BACKEND-LEAD, FRONTEND-LEAD, QA-ENGINEER |
| Medium | 8–12 | + SECURITY-ENGINEER, DATABASE-ENGINEER, DEVOPS-ENGINEER, API-ARCHITECT |
| Large | 12–20+ | + INTEGRATIONS-LEAD, UX-DESIGNER, TECH-WRITER, INFRASTRUCTURE-ENGINEER, etc. |

## Files

See `PLACEMENT.md` for the complete file-to-destination map.
See `CONVERSION.md` for details on converting existing projects.
