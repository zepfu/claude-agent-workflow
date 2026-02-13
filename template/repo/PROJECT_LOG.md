# PROJECT_LOG.md — Build Log

> **Append-only, ascending by time.** New entries go at the bottom. To catch up, read the last N lines (`tail -n`).
>
> Records every dispatch, completion, review, merge, blocker, decision, suggestion outcome, and session note.
>
> **Entry types:** `[DISPATCH]` `[COMPLETE]` `[REVIEW]` `[MERGED]` `[BLOCKER]` `[DECISION]` `[GATE]` `[HOTFIX]` `[SUGGESTION]` `[NOTE]`
>
> **Who writes what:**
> - **Coordinator:** `[NOTE]` (session start/end), `[GATE]`, `[SUGGESTION]`
> - **TECH-LEAD:** `[DISPATCH]`, `[COMPLETE]`, `[REVIEW]`, `[MERGED]`, `[BLOCKER]`
> - **PRODUCT-OWNER:** `[DECISION]`
>
> When this file grows too large, the coordinator rotates it to `logs/PROJECT_LOG_YYYYMMDDHHMMSS-YYYYMMDDHHMMSS.md` and starts fresh with a summary entry. See CLAUDE.md "Log Rotation."

---

## Log

<!-- Append new entries below this line. Never edit or delete previous entries. -->
