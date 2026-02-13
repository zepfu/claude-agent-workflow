---
description: Set up or convert a project using the orchestrator template. Finds the template zip in repo root, installs everything, and configures the project.
allowed-tools: Read, Bash, Write, Edit
---

# /convert — Project Orchestrator Setup & Conversion

This command handles full setup from a template zip dropped in the repo root. It works for **new projects** (fresh setup) and **existing projects** (conversion/upgrade from prior template versions).

---

## Step 1: Find the Template Zip

```bash
ls *.zip 2>/dev/null
```

Look for `*orchestrator*.zip` or `*project-orchestrator*.zip`. If multiple zips, ask the operator which one. If none:

> "No orchestrator template zip found in repo root. Drop the zip file here and run `/convert` again."

## Step 2: Extract to Temp

```bash
TEMPLATE_DIR=$(mktemp -d)
unzip -q <zip-file> -d "$TEMPLATE_DIR"
```

Verify expected structure. If nested in a subdirectory, adapt `$TEMPLATE_DIR`:
```bash
ls "$TEMPLATE_DIR/global/agents/" "$TEMPLATE_DIR/global/commands/" "$TEMPLATE_DIR/repo/"
```

Also read `$TEMPLATE_DIR/CONVERSION.md` for version-specific notes.

## Step 3: Assess Current Project

```bash
cat CLAUDE.md 2>/dev/null | head -30

for f in PROJECT_LOG.md TASKS.md CLAUDE_SUGGESTIONS.md; do
  echo "=== $f ===" && head -10 "$f" 2>/dev/null && wc -l "$f" 2>/dev/null
done

for f in .claude/SPEC.md .claude/GUIDELINES.md .claude/PHASES.md .claude/CONTRACTS.md .claude/GITHUB_INTEGRATION.md; do
  echo "=== $f ===" && head -5 "$f" 2>/dev/null && wc -l "$f" 2>/dev/null
done

ls agent-logs/*.md 2>/dev/null
ls logs/REJECTED_SUGGESTIONS.md 2>/dev/null
git status --short 2>/dev/null
```

**Classify:**
- **No CLAUDE.md** → New project
- **CLAUDE.md has "You are the CTO"** → CTO-orchestrator, full conversion
- **CLAUDE.md has "Project Coordinator"** → Already coordinator, template upgrade
- **Other** → Unknown, ask operator

If uncommitted git changes, WARN operator.

## Step 4: Classify Each File

| Action | Meaning |
|--------|---------|
| **CREATE** | File doesn't exist. Copy from template. |
| **REPLACE** | File exists but no project content (all placeholders). Overwrite. |
| **MERGE** | File has project content AND template has structural updates. Update structure, preserve content. |
| **PRESERVE** | File exists, no template changes needed. Leave as-is. |

## Step 5: Present Plan and Confirm

Show every file action, what's preserved, what's updated. **WAIT for operator confirmation.**

---

## Step 6: Install Global Files

```bash
mkdir -p ~/.claude/agents ~/.claude/commands
cp "$TEMPLATE_DIR/global/agents/"*.md ~/.claude/agents/
cp "$TEMPLATE_DIR/global/commands/"*.md ~/.claude/commands/
```

---

## Step 7: Process Each File

### 7a: CLAUDE.md

**CREATE (new):** Copy from template.

**MERGE (existing):**
1. Extract all project-specific content (Identity, Context, Conventions, Roster with agent context, Reviewers, Source Control).
2. Read template for new structure.
3. Build new CLAUDE.md: template structure + preserved project content.
4. Key structural updates:
   - Role Hierarchy, Dispatch Flow, Who Reads What
   - Suggestion Protocol with `- [ ]` checkbox format, `[Y]`/`[N]`/`[E]` operator actions, continuous processing, rejected suggestions log, attribution chain `PROPOSER (via AGENT)`
   - Mid-session checks now include CLAUDE_SUGGESTIONS.md alongside TASKS.md
   - `[SUGGESTION]` entry type in Project Log section

### 7b: TASKS.md

**CREATE:** Copy from template.

**MERGE:**
1. Use template scaffolding (updated role references).
2. Preserve all existing task entries with completion state.

### 7c: PROJECT_LOG.md

**CREATE:** Copy from template.

**MERGE:**
1. Use template header (adds `[SUGGESTION]` entry type, role attribution).
2. Preserve ALL existing log entries as-is.
3. Append conversion entry (Step 9).

### 7d: CLAUDE_SUGGESTIONS.md

**CREATE:** Copy from template.

**MERGE — this file has significant structural changes:**

1. Read existing file format.

2. **Old format (PROPOSED/APPROVED/REJECTED headings):**
   - Migrate items from `## Applied` section → append each to PROJECT_LOG.md as `[SUGGESTION] [APPROVED]` entries
   - Migrate items from `## Rejected` section → append each to PROJECT_LOG.md as `[SUGGESTION] [REJECTED]` entries AND to `logs/REJECTED_SUGGESTIONS.md`
   - Convert remaining `### [PROPOSED]` items to new checkbox format: `- [ ] [CRITICALITY] Description — PROPOSER (via AGENT)`. Infer attribution from context if not explicit.
   - Remove old section headers (`## Proposed Changes`, `## Applied`, `## Rejected`)

3. **Old format (checkbox but no Y/N/E):**
   - Keep all `- [ ]` items as-is
   - Convert any other marker format to `[ ]`

4. Use template scaffolding (header, workflow description, format instructions, examples).

5. Ensure `logs/REJECTED_SUGGESTIONS.md` exists. Create from template if not.

### 7e: SPEC.md

**CREATE / REPLACE:** Copy from template.

**MERGE:** Preserve all project content. Add new sections from template. Update guidance comments.

### 7f: GUIDELINES.md

**CREATE / REPLACE:** Copy from template.

**MERGE:** Preserve all project conventions. Add new sections. Update guidance comments and defaults.

### 7g: PHASES.md

**CREATE / REPLACE:** Copy from template.

**MERGE:** Preserve all phase content. Update role references ("CTO evaluates" → "PRODUCT-OWNER evaluates", "CTO final approval" → "PRODUCT-OWNER recommendation, operator approval"). Add new structural guidance.

### 7h: CONTRACTS.md

**CREATE / REPLACE:** Copy from template.

**MERGE:** Preserve all contracts and changelog. Update process docs and role references ("CTO creates/approves" → "PRODUCT-OWNER approves").

### 7i: GITHUB_INTEGRATION.md

**CREATE / REPLACE:** Copy from template.

**MERGE:** Preserve project board config. Replace process sections with updated role references.

---

## Step 8: Handle Agent Logs

```bash
if [ -f agent-logs/project-owner.md ]; then
  cp agent-logs/project-owner.md agent-logs/tech-lead.md
  mv agent-logs/project-owner.md "agent-logs/archive/project-owner_converted_$(date +%Y%m%d).md"
fi

if [ -f agent-logs/project-coordinator.md ]; then
  mv agent-logs/project-coordinator.md "agent-logs/archive/project-coordinator_converted_$(date +%Y%m%d).md"
fi

[ ! -f agent-logs/product-owner.md ] && cp agent-logs/_TEMPLATE.md agent-logs/product-owner.md
[ ! -f agent-logs/tech-lead.md ] && cp agent-logs/_TEMPLATE.md agent-logs/tech-lead.md
```

## Step 9: Create Missing Directories and Files

```bash
mkdir -p agent-logs/archive logs
[ ! -f agent-logs/_TEMPLATE.md ] && cp "$TEMPLATE_DIR/repo/agent-logs/_TEMPLATE.md" agent-logs/
[ ! -f logs/REJECTED_SUGGESTIONS.md ] && cp "$TEMPLATE_DIR/repo/logs/REJECTED_SUGGESTIONS.md" logs/
```

## Step 10: Append Conversion Entry

For existing projects:

```markdown
### [DATE TIME] [DECISION] Project orchestrator template conversion
Previous model: [CTO-orchestrator / coordinator vPrevious]
New model: PROJECT-COORDINATOR (main session) + PRODUCT-OWNER (strategy) + TECH-LEAD (execution)
Template: [zip filename]
Global installed: [N] agents, 4 commands
Files created: [list]
Files merged: [list]
Files preserved: [list]
Agent logs: [renames/creates]
Suggestion migration: [N items from old Applied/Rejected → PROJECT_LOG.md + REJECTED_SUGGESTIONS.md]
```

## Step 11: Cleanup

```bash
rm -rf "$TEMPLATE_DIR"
```

Ask operator: "Template zip [filename] is still in repo root. Remove it, add to .gitignore, or leave as-is?"

## Step 12: Verify and Report

```bash
ls CLAUDE.md TASKS.md PROJECT_LOG.md CLAUDE_SUGGESTIONS.md
ls .claude/SPEC.md .claude/GUIDELINES.md .claude/PHASES.md .claude/CONTRACTS.md .claude/GITHUB_INTEGRATION.md
ls agent-logs/product-owner.md agent-logs/tech-lead.md
ls logs/REJECTED_SUGGESTIONS.md
ls ~/.claude/agents/product-owner.md ~/.claude/agents/tech-lead.md
ls ~/.claude/commands/start.md ~/.claude/commands/convert.md
```

```
## Conversion Complete

**Global (~/.claude/):**
  ~/.claude/agents/    — [N] agents
  ~/.claude/commands/  — start, stop, status, convert

**Repo files:**
  Created:   [list]
  Merged:    [list]
  Preserved: [list]

**Agent logs:**
  Created: [list]
  Renamed: [list]
  Archived: [list]

**Suggestion migration:** [details]

**Next steps:**
  New projects:
    1. Configure CLAUDE.md — Project Identity, Team Roster, Reviewers, scopes
    2. Configure .claude/SPEC.md, GUIDELINES.md, PHASES.md
    3. Create agent logs for roster agents
    4. Run /start

  Converted projects:
    1. Review CLAUDE.md — confirm project content
    2. Review CLAUDE_SUGGESTIONS.md — confirm format conversion
    3. Check logs/REJECTED_SUGGESTIONS.md exists
    4. Run /status then /start
```
