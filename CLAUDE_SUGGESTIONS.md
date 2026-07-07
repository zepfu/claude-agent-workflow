# CLAUDE_SUGGESTIONS.md — Spec Improvement Suggestions

> **Pending inbox.** TECH-LEAD and PRODUCT-OWNER write suggestions here. Operator reviews and marks each item.
>
> **Format:** `- [ ] [CRITICALITY] Description — PROPOSER (via UNDERLYING-AGENT)`
>
> **Operator actions** (change the brackets):
> - `[Y]` — Yes, approve. Coordinator applies the edit, logs to PROJECT_LOG.md, removes from this file.
> - `[N]` — No, reject. Coordinator logs to PROJECT_LOG.md, archives to `logs/REJECTED_SUGGESTIONS.md`, removes from this file.
> - `[E]` — Explain more. Coordinator routes back to the proposer for additional detail, then resets to `[ ]`.
> - `[ ]` — Pending operator review (default).
>
> **Checked continuously** — same cadence as TASKS.md. Operator can mark items at any time during a session.
>
> **Before adding a new suggestion**, check `logs/REJECTED_SUGGESTIONS.md` to avoid re-proposing previously rejected items.

---

## Suggestions

- [ ] [MEDIUM] Add "CI/CD Tool Quirks" section to template GUIDELINES.md for per-project documentation — PROJECT-COORDINATOR (via repo-standards field experience)
  **File:** template/repo/.claude/GUIDELINES.md → new section after "Pre-commit Hooks"
  **Change:** Add the following section:
  ```
  ## CI/CD Tool Quirks

  <!--
  Document project-specific CI tool behaviors that differ between local and CI environments.
  These are discovered during development and prevent repeat debugging across sessions.

  Common patterns to document:
  - Tools that behave differently locally vs CI (e.g., linters with different configs, tools missing from PATH)
  - Config files that are ignored by certain tool invocations (e.g., actionlint passes --norc to shellcheck)
  - Environment-specific suppressions (which rules to suppress and WHERE — hook args, config files, inline comments)
  - Auto-commit CI workflows that cause remote divergence (always pull --rebase before push)

  Example:
  - **actionlint + shellcheck:** actionlint passes `--norc` to shellcheck, so `.shellcheckrc` is never read.
    Suppress shellcheck rules via `-ignore` args on the actionlint pre-commit hook, not `.shellcheckrc`.
    Locally, shellcheck may not be in PATH (only in pre-commit venv), so actionlint silently skips
    shellcheck — issues only surface in CI where shellcheck is pre-installed.
  -->
  ```
  **Reason:** Spent significant debugging time on repo-standards discovering that actionlint passes `--norc` to shellcheck, making `.shellcheckrc` ineffective. This is the kind of project-specific gotcha that gets rediscovered every session. Each project should document its own CI quirks in GUIDELINES.md rather than the framework hardcoding specific tool behaviors. The template should provide the section scaffold with guidance on what to document.
- [ ] [MEDIUM] Add dependency/runtime EOL check to `/start` startup sequence — fcmp (Federated Commerce Middleware project)
  **File:** Startup sequence logic (session `/start` handler)
  **Change:** During `/start`, add a step that evaluates project dependency and runtime platform versions against their EOL/LTS schedules, and warns if any are within 6 months of EOL or have known unpatched CVEs.
  **Implementation:**
  - Check `engines` field in `package.json`, `FROM` image versions in Dockerfiles, and `node-version` settings in CI workflow files
  - Cross-reference against known LTS/EOL schedules (via a maintained lookup table or web search)
  - Warn if any runtime platform (Node.js, Python, etc.) is within 6 months of EOL
  - Warn if major framework versions (Next.js, React, Express, Fastify, etc.) have known unpatched CVEs in the version being used
  - Log the check result in the session startup summary so it is visible to the operator
  **Reason:** The FedCom project (fcmp) was built on Node.js 20 and Next.js 14 from inception. By the time Phase 4 was complete (v1.0.0-rc.1), Node.js 20 was approaching its April 2026 EOL and Next.js 14 had already reached EOL for security patches (CVE-2025-59471 and CVE-2026-23864 had no v14 fix). The resulting upgrade from Node 20 to 24 LTS and Next.js 14 to 15 was low risk individually but required touching 10+ Dockerfiles/CI files, resolving React version conflicts in a monorepo, and fixing Next.js 15 breaking changes. If this check had been part of the startup sequence from the beginning, the team would have caught the approaching EOL months earlier and could have upgraded incrementally rather than performing a bulk upgrade at the end of the project.

- [ ] [MEDIUM] Add mdformat re-stage instruction to template Pre-commit Hooks section — PROJECT-COORDINATOR (via repo-standards field experience)
  **File:** template/repo/.claude/GUIDELINES.md → "Pre-commit Hooks" section, under "Rules:"
  **Add after:** "Agents MUST fix hook failures and re-commit. Never use `--no-verify`."
  **Change:** Add bullet: `- When a formatter hook (Black, isort, mdformat, etc.) modifies files during commit, the commit will fail. Re-stage with \`git add -u\` and re-commit immediately. This is expected behavior — the formatter fixes on first run, passes on second.`
  **Reason:** This is a universal pre-commit pattern, not project-specific. Every project using formatters in pre-commit hooks hits this. Agents currently waste a round-trip being surprised by it each time. Adding it to the template rules section means all projects get the guidance automatically.

- [ ] [LOW] Add CI failure triage dispatch pattern to DEVOPS-ENGINEER agent definition — PROJECT-COORDINATOR (via repo-standards field experience)
  **File:** global/agents/devops-engineer.md → "Instructions" section
  **Change:** Add to instructions list: `- CI failure triage: When dispatched for CI debugging, extract the specific failing step and error from \`gh run view <id> --log-failed\`, identify root cause (tool version mismatch, config not read, env difference local vs CI), and propose a targeted fix. Always verify the fix passes in CI before marking complete — local passing is insufficient for CI issues.`
  **Reason:** CI debugging follows a specific pattern (push → wait → read logs → diagnose → fix → repeat) that is distinct from general DevOps work. Adding explicit triage instructions prevents agents from stopping at "it passes locally" and ensures they verify fixes in the actual CI environment. The repo-standards session required 4 push/CI cycles to resolve an issue that could have been 1-2 with better triage discipline.

- [ ] [HIGH] Provide small/medium/large template variants to match project scale — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/ → new directory structure
  **Change:** Create three template tiers:
  - `template/small/` — For 1-developer, <5k LOC projects. CLAUDE.md ~100 lines: project identity, current phase, key conventions, simplified startup. No agent roster, no worktrees, no contracts, no GitHub sync. Coordinator plans and executes directly.
  - `template/medium/` — For 2-5 agent projects. Adds role hierarchy (PRODUCT-OWNER, TECH-LEAD, 3-5 engineering agents), basic GitHub sync, agent logs.
  - `template/large/` — Current full template. 10+ agents, worktrees, contracts, full GitHub project board integration.
  **Reason:** The current template is tuned for large multi-agent projects. On rpctl (single-developer Python CLI, ~1,350 LOC), ~80% of the framework went unused: 17 agent roles, worktree lifecycle, cross-agent contracts, required reviewer matrices, GitHub project board sync. The 20% that helped (phased builds, gate checks, plan mode) could be delivered in ~100 lines. Small projects pay a context window tax for process documentation they never use.

- [ ] [HIGH] Reduce CLAUDE.md context window footprint — split process docs into on-demand reference files — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/repo/CLAUDE.md → restructure
  **Change:** Split current CLAUDE.md into:
  - `CLAUDE.md` (~80-100 lines): Project identity, current phase/status, team roster (names only), key conventions, "read `.claude/PROCESS.md` for full workflow details"
  - `.claude/PROCESS.md` (new): Full session startup sequence, task injection protocol, suggestion protocol, log rotation rules, agent dispatch flow, worktree lifecycle
  - Keep `.claude/SPEC.md`, `.claude/GUIDELINES.md`, etc. as-is
  Move operational process details out of the always-loaded system prompt into a file that's read only when the coordinator needs to execute a specific workflow.
  **Reason:** CLAUDE.md is ~350 lines and loaded into every system prompt. On rpctl, the session hit context compaction during Phase 2 implementation. The framework's own documentation consumed ~15-20% of the context window — mostly process rules (suggestion protocol, log rotation, dispatch flow) that were never referenced during actual coding work. Only project identity, current phase, and conventions need to be always-loaded.

- [ ] [MEDIUM] Add conditional/abbreviated session startup — skip unchanged files and unused integrations — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/repo/CLAUDE.md → "Session Startup Sequence" section
  **Change:** Replace the current 10-step mandatory startup with a tiered approach:
  ```
  ## Session Startup Sequence

  ### Quick Resume (default)
  1. Read CLAUDE.md (always loaded)
  2. Check TASKS.md for new operator-injected tasks (skip if unchanged)
  3. Check CLAUDE_SUGGESTIONS.md for operator decisions (skip if unchanged)
  4. Resume from prior conversation context or PROJECT_LOG.md tail

  ### Full Startup (first session, or after major changes)
  1-4 above, plus:
  5. Read PROJECT_LOG.md for full context
  6. Check GitHub Issues and CI status (skip if no GitHub repo configured)
  7. Invoke PRODUCT-OWNER for alignment check
  8. Invoke TECH-LEAD for dispatch planning
  ```
  **Reason:** The current 10-step startup (read 4 files, check GitHub, check CI, invoke PRODUCT-OWNER, invoke TECH-LEAD, sync GitHub) consumes 8-10 tool calls and significant context before any real work begins. On rpctl, we skipped most of it every session and jumped straight to building. Projects without GitHub repos configured shouldn't check GitHub. Projects with no new tasks shouldn't re-read TASKS.md. The startup should match what actually changed.

- [ ] [MEDIUM] Collapse role hierarchy for small projects — allow coordinator to plan and execute directly — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/repo/CLAUDE.md → "Role Hierarchy" and "When to Invoke Each Persona" sections
  **Change:** Add a "Solo Mode" option at the top of the Role Hierarchy section:
  ```
  ### Solo Mode (small projects, 1-3 agents)
  For small projects, the coordinator may plan and execute directly without
  invoking PRODUCT-OWNER or TECH-LEAD as separate personas. Use solo mode when:
  - The project has fewer than 3 engineering agents
  - There is a single developer/operator
  - Tasks don't require cross-agent coordination

  In solo mode, the coordinator handles planning, execution, and review directly.
  Phase gates still apply. Suggestion protocol still applies.
  ```
  **Reason:** The full chain (triage → PRODUCT-OWNER priority → TECH-LEAD dispatch → agent execution → TECH-LEAD review → coordinator logging → GitHub sync) is 6 hops for what amounts to "write the code." On rpctl, every task went directly from "user asked" to "coordinator builds it." The role separation adds value when there are genuinely separate concerns (multiple agents, conflicting priorities, cross-team contracts) but adds pure overhead for solo projects.

- [ ] [MEDIUM] Make reference files opt-in — create on first use rather than at scaffold time — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/repo/.claude/ → scaffold script or setup instructions
  **Change:** Instead of creating all reference files at project init, only create:
  - Required: `CLAUDE.md`, `TASKS.md`, `CLAUDE_SUGGESTIONS.md`, `PROJECT_LOG.md`
  - Optional (created when first needed): `.claude/CONTRACTS.md` (first cross-agent dispatch), `.claude/GITHUB_INTEGRATION.md` (first `gh` command), `.claude/PHASES.md` (can live in CLAUDE.md for small projects), `agent-logs/` directory (first agent dispatch)
  Add a note in CLAUDE.md: "Reference files are created as needed. See `.claude/README.md` for descriptions of each file."
  **Reason:** On rpctl, `CONTRACTS.md`, `GITHUB_INTEGRATION.md`, and `agent-logs/` were never used. Empty placeholder files add noise to the repo and to the coordinator's mental model of what needs to be maintained. Creating files on first use makes the project structure reflect what's actually in play.

- [ ] [LOW] Replace placeholder brackets in agent roster with a setup wizard or conditional generation — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** template/repo/CLAUDE.md → "Team Roster" section
  **Change:** Replace the 17-row agent table with empty brackets (`[language/framework]`, `[Auth method]`, etc.) with either:
  (a) A setup wizard prompt: "On first session, ask the operator: What's your stack? How many agents do you need? Which areas need dedicated reviewers?" and generate only the relevant rows.
  (b) A minimal starter roster (PRODUCT-OWNER, TECH-LEAD, 2-3 blank engineering slots) with instructions: "Add agents as needed. See `~/.claude/agents/` for available roles."
  **Reason:** The current 17-role table with unfilled brackets suggests the project needs all these roles. On rpctl, we needed zero of the 15 engineering agent slots. The empty brackets also make CLAUDE.md feel incomplete/broken rather than intentionally minimal. A smaller starting roster that grows organically better matches how projects actually evolve.

- [ ] [LOW] Document context window cost of the framework in the README — PROJECT-COORDINATOR (via runpod-automation field experience)
  **File:** README.md → new "Context Window Considerations" section
  **Change:** Add:
  ```
  ## Context Window Considerations
  The full CLAUDE.md template (~350 lines) is loaded into every system prompt,
  consuming approximately 15-20% of the available context window. For long
  implementation sessions, this overhead can contribute to earlier context
  compaction.

  For small projects, consider using the small template variant or splitting
  process documentation into on-demand reference files (see template options).
  ```
  **Reason:** Users should understand the tradeoff before adopting the full template. On rpctl, a 2-phase implementation session hit context compaction — framework overhead was a contributing factor. This isn't a bug, it's a design tradeoff that should be documented so users can make informed choices about which template tier to use.
