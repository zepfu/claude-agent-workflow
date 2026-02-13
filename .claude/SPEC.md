# SPEC.md — Technical Specification

## Architecture Overview

This is a file-based framework, not a running application. The architecture describes three distribution layers:

1. **Global layer** (`~/.claude/agents/` + `~/.claude/commands/`) — Agent definitions and slash commands shared across all projects. Installed once per machine.
2. **Per-repo layer** (project root) — Project-specific orchestration files (CLAUDE.md, TASKS.md, PROJECT_LOG.md, etc.) and reference docs (`.claude/`). Created per project via `/convert`.
3. **Packaging pipeline** (`scripts/package.sh`) — Assembles `global/` + `template/` into a distributable zip that `/convert` consumes.

```
┌─────────────────────────────────────────────────────┐
│  This Repo (claude-agent-workflow)                  │
│                                                     │
│  global/          ← Canonical agent & command defs  │
│  template/repo/   ← Generic per-project templates   │
│  scripts/         ← Packaging & maintenance tools    │
│  conversion/      ← Version migration guides         │
│                                                     │
│  package.sh → project-orchestrator-vX.Y.Z.zip       │
└──────────────────────┬──────────────────────────────┘
                       │
            ┌──────────▼──────────┐
            │  Target Project     │
            │  drops zip, runs    │
            │  /convert           │
            └──────────┬──────────┘
                       │
          ┌────────────▼────────────┐
          │  Global: ~/.claude/     │
          │  ├── agents/*.md        │
          │  └── commands/*.md      │
          │                         │
          │  Repo: <project>/       │
          │  ├── CLAUDE.md          │
          │  ├── TASKS.md           │
          │  ├── .claude/*.md       │
          │  └── ...                │
          └─────────────────────────┘
```

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Content | Markdown | All agent defs, commands, templates, docs |
| Scripting | Bash (POSIX-compatible where possible) | Packaging, validation, sync |
| CI | GitHub Actions | Linting, structure validation |
| MD Linting | markdownlint-cli2 | Consistency enforcement |
| Shell Linting | shellcheck | Script quality |
| Packaging | zip | Distribution format consumed by `/convert` |
| VCS | Git + GitHub | Source control, issues, project board |

---

## Core Concepts

### Template Package

The distributable zip file that gets dropped into target projects for `/convert` to consume. It has a required structure:

```
project-orchestrator-vX.Y.Z.zip
├── CONVERSION.md              ← Read by /convert for migration notes
├── global/
│   ├── agents/*.md            ← Installed to ~/.claude/agents/
│   └── commands/*.md          ← Installed to ~/.claude/commands/
├── repo/
│   ├── CLAUDE.md              ← Generic template, customized per project
│   ├── TASKS.md, PROJECT_LOG.md, CLAUDE_SUGGESTIONS.md
│   ├── .claude/*.md
│   ├── agent-logs/
│   └── logs/
└── conversion/
    ├── README.md, CONVERSION.md, PLACEMENT.md
```

The `/convert` command detects this zip via `*orchestrator*.zip` glob.

### Global vs Repo Scope

- **Global** (`~/.claude/`): Shared across all projects. Agent role definitions and slash commands. Updated by `scripts/sync-global.sh` or `/convert`.
- **Repo** (project root): Project-specific. CLAUDE.md with team roster, SPEC.md with architecture, PHASES.md with build plan. Created/merged by `/convert`.

Agents are defined globally but contextualized per project via the Team Roster table in CLAUDE.md.

### Conversion Pipeline

The mechanism for getting the framework into a project:

1. **Bootstrap** (one-time): Install `/convert` command to `~/.claude/commands/`
2. **Per-project**: Drop zip in repo root, run `/convert`
3. `/convert` classifies each file as CREATE/REPLACE/MERGE/PRESERVE
4. Global files are copied to `~/.claude/`. Repo files are intelligently merged with existing project content.
5. Version-to-version migrations documented in `conversion/vX.Y.Z/CONVERSION.md`

---

## Project Structure

```
claude-agent-workflow/
├── CLAUDE.md                        ← This project's coordinator config
├── TASKS.md                         ← Task injection for this project
├── PROJECT_LOG.md                   ← This project's build log
├── CLAUDE_SUGGESTIONS.md            ← Suggestions for this project
├── VERSION                          ← Semver (read by package.sh)
├── .gitignore
├── .markdownlint.json               ← MD lint config
├── .claude/
│   ├── SPEC.md                      ← This file
│   ├── GUIDELINES.md                ← Markdown + shell standards
│   ├── PHASES.md                    ← Build phases for this project
│   ├── CONTRACTS.md                 ← Cross-agent contracts (minimal for this project)
│   └── GITHUB_INTEGRATION.md        ← GitHub sync rules
├── global/
│   ├── agents/                      ← Canonical agent definitions (23)
│   │   ├── product-owner.md
│   │   ├── tech-lead.md
│   │   ├── backend-lead.md
│   │   └── ... (20 more)
│   └── commands/                    ← Canonical command definitions (4)
│       ├── convert.md
│       ├── start.md
│       ├── stop.md
│       └── status.md
├── template/
│   ├── CONVERSION.md                ← At zip root for /convert to find
│   ├── repo/                        ← Generic per-project templates
│   │   ├── CLAUDE.md
│   │   ├── TASKS.md
│   │   ├── PROJECT_LOG.md
│   │   ├── CLAUDE_SUGGESTIONS.md
│   │   ├── .claude/
│   │   │   ├── SPEC.md, GUIDELINES.md, PHASES.md
│   │   │   ├── CONTRACTS.md, GITHUB_INTEGRATION.md
│   │   ├── agent-logs/
│   │   │   ├── _TEMPLATE.md
│   │   │   └── archive/
│   │   └── logs/
│   │       └── REJECTED_SUGGESTIONS.md
│   └── conversion/
│       ├── README.md
│       ├── CONVERSION.md
│       └── PLACEMENT.md
├── conversion/
│   └── v1.0.0/                      ← CTO→Coordinator migration docs
│       ├── CONVERSION.md
│       ├── PLACEMENT.md
│       └── README.md
├── scripts/
│   ├── package.sh                   ← Build distributable zip
│   ├── sync-global.sh               ← Copy global/ to ~/.claude/
│   └── validate.sh                  ← Run linters locally
├── .github/
│   └── workflows/
│       └── lint.yml                 ← CI: markdownlint + shellcheck + structure
├── agent-logs/
│   ├── _TEMPLATE.md
│   └── archive/
└── logs/
    └── REJECTED_SUGGESTIONS.md
```
