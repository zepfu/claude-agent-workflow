---
description: Start a new session. Read state, process suggestions, check GitHub, invoke PRODUCT-OWNER for planning, dispatch to TECH-LEAD.
allowed-tools: Read, Bash(cat:*), Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(head:*), Bash(tail:*), Bash(date:*), Bash(gh issue:*), Bash(gh project:*), Bash(gh run:*)
---

# Session Start — Project Coordinator

You are the PROJECT-COORDINATOR. Execute this startup sequence. Complete every step before routing any work.

## Step 1: Read State Files

Read these files in order. If a file doesn't exist, note it and continue.

1. `PROJECT_LOG.md` — Read the tail (`tail -n 50`) to see recent activity. Identify what's in-flight, blocked, and last session's recommended next steps.
2. `TASKS.md` — Check for new undispatched tasks (`- [ ]`). Note priority levels.
3. `CLAUDE_SUGGESTIONS.md` — Check for operator-marked items (`[Y]`, `[N]`, `[E]`).
4. `CLAUDE.md` — Re-anchor on team roster, process, project-specific conventions.

## Step 2: Process Suggestions

Scan CLAUDE_SUGGESTIONS.md for items the operator has acted on:

**`[Y]` items (approved):**
1. Apply the exact edit described to the target file
2. Append `[SUGGESTION] [APPROVED]` entry to PROJECT_LOG.md with criticality, proposer, target file, and change description
3. Delete the item from CLAUDE_SUGGESTIONS.md

**`[N]` items (rejected):**
1. Append `[SUGGESTION] [REJECTED]` entry to PROJECT_LOG.md with criticality, proposer, and operator's note if any
2. Append the full suggestion to `logs/REJECTED_SUGGESTIONS.md`
3. Delete the item from CLAUDE_SUGGESTIONS.md

**`[E]` items (explain more):**
1. Note which proposer needs to add detail (TECH-LEAD or PRODUCT-OWNER, from the attribution)
2. Route to that proposer during the session to expand the suggestion with additional context
3. After expansion, reset the item to `- [ ]` for the next operator review

**`[ ]` items:** Pending operator review. Leave in place.

## Step 3: Check GitHub

```bash
gh issue list --state open --label "priority:critical,priority:high" --json number,title,labels,milestone
gh issue list --state open --label "blocked" --json number,title,body
```

- New issues in `Backlog` or `Ready` not yet referenced in PROJECT_LOG.md
- Issues moved to `Blocked` by operator
- Issues closed externally
- Comments with new context

Incorporate alongside TASKS.md entries.

## Step 3b: Check CI Status

```bash
gh run list --status failure --limit 5 --json databaseId,displayTitle,conclusion,headBranch,createdAt
```

- Flag any failing workflows. Note which branches and what failed.
- If CI has been failing on `main` or `develop`, this is a blocker — include in PRODUCT-OWNER briefing.
- If failures are on feature branches, note for TECH-LEAD to address.

## Step 4: Invoke PRODUCT-OWNER

Invoke PRODUCT-OWNER for alignment check and session planning:
- Pass: current phase status from `.claude/PHASES.md`, in-flight work, blockers, new tasks, CI failures, any drift concerns, `[E]` suggestions needing PRODUCT-OWNER detail
- Get back: session priorities, scope confirmations, phase gate status, strategic decisions

Record any `[DECISION]` entries from PRODUCT-OWNER in PROJECT_LOG.md.

## Step 5: Write Startup Log Entry

Append to `PROJECT_LOG.md`:

```
### [DATE TIME] [NOTE] Session started
Previous session summary: [summarize last session's end note]
In-flight: [list with issue numbers]
Blocked: [list with issue numbers]
New tasks: [from TASKS.md and GitHub, or "none"]
Suggestions processed: [N approved, N rejected, N explain-more, or "none"]
CI status: [all green | N failing workflows — details]
PRODUCT-OWNER plan: [summary of session priorities]
```

## Step 6: Route to TECH-LEAD

Pass the session plan from PRODUCT-OWNER to TECH-LEAD:
- Which agents to dispatch, in what order
- Priority and dependencies
- Contract IDs for cross-boundary work
- Any `[E]` suggestions needing TECH-LEAD detail
- Any constraints or decisions from PRODUCT-OWNER

TECH-LEAD handles individual agent dispatches and reports back. Sync GitHub as events come in.

**Reminder:** Continue checking TASKS.md and CLAUDE_SUGGESTIONS.md before every routing decision throughout the session.
