# TASKS.md — Task Injection File

> **For the human operator.** Add tasks below while the orchestrator is running. The project coordinator checks this file before every routing cycle and incorporates new tasks into the active plan.
>
> Format: `- [ ]` for new tasks, `- [x]` once dispatched. Include priority and optionally suggest an agent.

## Injected Tasks

<!-- Add new tasks here. Examples:
- [ ] **PRIORITY:HIGH** Fix: [service] crashes on [condition]. Assign to [AGENT].
- [ ] **PRIORITY:MEDIUM** Add: [feature] to [component]. Assign to [AGENT].
- [ ] **PRIORITY:LOW** Chore: Add [tool] to CI pipeline.
- [ ] **PRIORITY:CRITICAL** Halt [feature] work. Redirect all agents to [priority] immediately.
- [ ] Investigate: intermittent [error] on [endpoint]. Assign to [AGENT] + [AGENT].
-->

- [x] **PRIORITY:HIGH** Add git worktree-based agent isolation to the workflow template. **Origin: claude-interceptor project.**
  **Problem:** When multiple engineering agents are dispatched in parallel on the same git checkout, they overwrite each other's files and switch branches under each other, causing data loss and requiring manual rework. Discovered during Phase 2 of claude-interceptor when parallel B3 (BACKEND-LEAD) and SEC fix (SECURITY-ENGINEER) agents corrupted each other's work.
  **Proposed changes to template CLAUDE.md:**
  1. **Dispatch Flow → new "Agent Isolation (Git Worktrees)" subsection:** Define lifecycle — TECH-LEAD creates a worktree at `../<project>-worktrees/<branch-name>/` before dispatch, agent works there, coordinator merges and cleans up on completion. Main checkout reserved for coordinator session only. Serial dispatches may skip worktrees.
  2. **Source Control → new "Worktrees (Parallel Agent Dispatch)" subsection:** Document the directory convention (`../<project>-worktrees/`) with example layout showing one worktree per concurrent agent.
  3. **Dispatch Flow → TECH-LEAD checklist → new item 7:** "Always use `subagent_type=general-purpose` for engineering agents. The `Bash` subagent type cannot use Write/Edit tools, which are required for file creation and modification."
  **Reference implementation:** See `claude-interceptor/CLAUDE.md` lines 149-181 and 183-191 (already applied to that project).
- [x] **PRIORITY:HIGH** Add CI/GitHub Actions failure checks to the workflow. **Origin: operator observation.**
  Added: CI status check at session startup (Step 6 in startup sequence), CI gate in mid-session checks (no phase transition with failing CI), `gh run list` in start.md and status.md commands.
- [x] **PRIORITY:HIGH** Add pre-commit hook recommendation to workflow template. **Origin: claude-interceptor project.**
  **Problem:** Agents dispatched via `subagent_type=general-purpose` cannot run Python in the sandbox, so they can't self-verify lint/format compliance. Every agent in Phase 3 wave 1 needed post-hoc coordinator fixes for import sorting, line length, and style rules. Pre-commit hooks solve this: when the agent runs `git commit`, the hook runs linting automatically, fails with exact errors, and the agent can self-correct.
  **Proposed changes:**
  1. **GUIDELINES.md template → new "Pre-commit Hooks" section:** Recommend `pre-commit` framework with `ruff-pre-commit` for lint + format. Note: mypy stays in CI only (needs project deps, complex in worktrees). Pre-commit hooks are shared across git worktrees via `.git/hooks/`, making them compatible with the worktree dispatch pattern.
  2. **CLAUDE.md template → "Source Control Process" section:** Add note that pre-commit hooks are expected. Agents should fix hook failures and re-commit, not use `--no-verify`.
  3. **Template `.pre-commit-config.yaml`:** Provide a starter config with ruff lint + format that projects can customize.
  **Reference implementation:** See `claude-interceptor/.pre-commit-config.yaml` and `pyproject.toml` dev deps (already applied to that project). Confirmed working in git worktrees during Phase 3 parallel dispatch.

## Questions for Operator

<!-- The project coordinator writes questions here when injected tasks are ambiguous or conflict with the current plan. -->
