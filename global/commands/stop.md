---
description: Gracefully end a session. Gather state, sync GitHub, write session summary, verify all files saved.
allowed-tools: Read, Bash(cat:*), Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(date:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git diff:*), Bash(gh issue:*), Bash(gh project:*)
---

# Session Stop — Project Coordinator

You are the PROJECT-COORDINATOR. Execute this shutdown sequence before ending the session.

## Step 1: Gather Current State

1. Run `git status` and `git branch` to see uncommitted work and active branches.
2. Get a session summary from TECH-LEAD: completed work, in-flight work, blockers, suggestions written, contract status.
3. Get any pending decisions or recommendations from PRODUCT-OWNER.

## Step 2: Final Suggestion Check

Check CLAUDE_SUGGESTIONS.md one last time for any operator actions since the last routing cycle. Process any `[Y]`, `[N]`, `[E]` items per the standard protocol.

## Step 3: Check for Unlogged Work

Scan for anything that happened this session but wasn't logged:
- Tasks completed but not marked `[COMPLETE]` in PROJECT_LOG.md?
- Dispatches not logged as `[DISPATCH]`?
- Decisions not logged as `[DECISION]`?
- Blockers not logged?

Write missing log entries now.

## Step 4: Update TASKS.md

- Mark dispatched tasks as `[x]` with agent, branch, and issue number.
- Note partial progress on in-flight tasks.

## Step 5: Sync GitHub

For each event this session:
- **Dispatched:** Ensure GitHub Issue exists with correct Project Board fields (Status, Phase, Stream, Agent, Reported By, Priority)
- **Completed:** Update issue status, add completion comment, link PR
- **Blocked:** Add `blocked` label and comment
- **Gate checks resolved:** Close gate-check issues, update milestone
- **Contract changes:** Comment on affected issues

```bash
gh issue list --state open --json number,title,labels --jq '.[] | "\(.number) \(.title)"'
```

If `gh` is unavailable, note unsynced items in the session-end summary.

## Step 6: Collect Suggestions

Review work done this session. Gather suggestions from TECH-LEAD:
- Gaps in the spec not anticipated
- Conventions that emerged and should be standardized
- Edge cases the data model doesn't cover
- Patterns multiple agents should follow
- Risks or concerns worth tracking

**Before writing a new suggestion**, check `logs/REJECTED_SUGGESTIONS.md` to avoid re-proposing previously rejected items.

Write new suggestions to `CLAUDE_SUGGESTIONS.md` with:
```
- [ ] [CRITICALITY] Description — PROPOSER (via UNDERLYING-AGENT)
  **File:** target
  **Change:** exact edit
  **Reason:** rationale
```

## Step 6b: Solicit Framework Feedback

Ask TECH-LEAD and PRODUCT-OWNER:

1. **Agent gaps:** Were there moments this session where a specialist agent type was missing or an existing agent's instructions were insufficient? What agent or instruction change would have helped?
2. **Workflow optimizations:** Did any part of the orchestration process feel inefficient, confusing, or error-prone? What would make the next session smoother?
3. **Context pressure:** Did any agent hit context window limits or require compaction? Were agents given too many reference files, or not enough?
4. **Contract friction:** Were there cross-agent handoffs where a contract was missing, ambiguous, or incorrect? Did agents have to discover interfaces that should have been explicit in dispatch?
5. **Task scoping:** Were tasks appropriately scoped, or did they consistently balloon? Were dependencies between tasks correctly identified upfront?
6. **Template gaps:** Did the project need a file, section, or convention the template didn't provide? Were template placeholders clear enough to customize?

If feedback is actionable, write it as a suggestion to the **framework repository's** `CLAUDE_SUGGESTIONS.md` (not this project's) using the cross-repo feedback format. This ensures the framework maintainer reviews and approves before changes are incorporated.

## Step 6c: Outstanding Suggestion Reminder

Check `CLAUDE_SUGGESTIONS.md` for any `[ ]` items still pending operator review. If there are outstanding items, include a reminder in the session-end summary:

```
**Operator attention needed:** [N] suggestions in CLAUDE_SUGGESTIONS.md awaiting review ([Y]/[N]/[E]).
```

## Step 7: Review Contracts

Check `.claude/CONTRACTS.md`:
- Were any contracts modified this session? Ensure changelog entries written.
- Did any agent's work reveal a contract needs updating?
- Are there upcoming cross-agent dispatches that need contracts defined?
- Move contracts with both sides' integration tests passing from ACTIVE to VERIFIED.

## Step 8: Verify Agent Logs

Confirm with TECH-LEAD that all agents who completed work wrote entries to their logs. If any are missing, TECH-LEAD writes summaries on their behalf.

## Step 9: Log Rotation Check

Check if `PROJECT_LOG.md` exceeds ~500 entries or ~50KB:
1. Get first and last entry timestamps
2. Move to `logs/PROJECT_LOG_YYYYMMDDHHMMSS-YYYYMMDDHHMMSS.md`
3. Start fresh with bridge summary

Check agent logs in `agent-logs/` — rotate any that are excessively large.

## Step 10: Write Session End Summary

Append to `PROJECT_LOG.md`:

```
### [DATE TIME] [NOTE] Session ended
Duration: [approximate]
Completed this session:
- [task — agent — #issue]
In-flight (not yet complete):
- [task — agent — branch — #issue — status]
Blocked:
- [reason — #issue — what unblocks]
Decisions made:
- [PRODUCT-OWNER decisions with rationale]
Suggestions:
- Written: [new items in CLAUDE_SUGGESTIONS.md]
- Approved: [items processed this session]
- Rejected: [items archived this session]
- Explain more: [items expanded this session]
Contracts:
- [created/modified/verified this session]
GitHub sync:
- Issues created: [#numbers]
- Issues closed: [#numbers]
- Issues updated: [#numbers]
- Unsynced: [any items for manual follow-up]
Recommended next actions:
1. [most important]
2. [second priority]
3. [third priority]
```

## Step 11: Verify Files Saved

- [ ] PROJECT_LOG.md — session end entry written
- [ ] TASKS.md — dispatched items marked
- [ ] CLAUDE_SUGGESTIONS.md — new suggestions added, only `[ ]` items remain
- [ ] .claude/CONTRACTS.md — changelog entries (if any)
- [ ] agent-logs/*.md — entries for completed work
- [ ] logs/REJECTED_SUGGESTIONS.md — rejected items archived (if any this session)
- [ ] GitHub Issues — synced

Report: "Session closed. Ready for next `/start`."
