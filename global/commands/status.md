---
description: Quick status check. Read-only — does not write files or begin execution.
allowed-tools: Read, Bash(cat:*), Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(head:*), Bash(tail:*), Bash(date:*), Bash(git status:*), Bash(git branch:*), Bash(gh issue:*), Bash(gh project:*), Bash(gh run:*)
---

# Status Check — Project Coordinator

Quick read-only check of project state. Does NOT write files, invoke agents, or begin execution. Use `/start` for a full session.

## Step 1: Read Current State

Scan these files (do NOT modify):

1. `PROJECT_LOG.md` — Read the tail (`tail -n 50`). Last session-end `[NOTE]`: completed, in-flight, blocked, recommendations.
2. `TASKS.md` — Count undispatched tasks (`- [ ]`). Note CRITICAL/HIGH items.
3. `CLAUDE_SUGGESTIONS.md` — Count items by status: `[ ]` (pending), `[Y]` (approved, awaiting processing), `[N]` (rejected, awaiting processing), `[E]` (needs expansion).
4. `.claude/PHASES.md` — Current phase and approximate completion.

## Step 2: Check Git State

```bash
git status
git branch
```

## Step 3: Check GitHub State

```bash
gh issue list --state open --json number,title,labels,milestone --jq 'length'
gh issue list --state open --label "blocked" --json number,title
gh issue list --label "type:gate-check" --state all --json number,title,state
gh run list --status failure --limit 5 --json databaseId,displayTitle,conclusion,headBranch,createdAt
```

## Step 4: Report

```
## Project Status — [DATE]

**Phase:** [Current phase] — [estimated %]
**Last session:** [date]

**In-flight:** [count]
- [task — agent — #issue]

**Blocked:** [count]
- [reason — #issue]

**Pending operator action:**
- [N] suggestions awaiting review ([ ])
- [N] undispatched tasks in TASKS.md

**Awaiting processing (next routing cycle):**
- [N] approved suggestions ([Y])
- [N] rejected suggestions ([N])
- [N] explain-more suggestions ([E])

**CI:**
- Failing workflows: [count or "none"]
- [workflow — branch — date] (if any)

**GitHub:**
- Open issues: [count]
- Blocked: [count]
- Milestone: [name] — [N/M] gate checks closed
- Unlinked: [issues not in PROJECT_LOG.md]

**Git:**
- Uncommitted: [summary]
- Branches: [list]

**Recommended next:** [top 1–3 from last session]
```

Do NOT write to any files. Do NOT invoke agents. Report only.
