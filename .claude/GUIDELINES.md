# GUIDELINES.md — Development Conventions & Standards

## Markdown Standards

All content in this project is Markdown. These standards apply to all `.md` files:

- Use ATX-style headers (`#` not `===` underlines)
- One blank line before and after headers
- No trailing whitespace
- Code blocks use fenced style (triple backtick) with language identifiers where applicable
- Lists use `-` (not `*` or `+`)
- Nested lists indent by 2 spaces
- Tables use `|` with alignment row
- HTML comments (`<!-- -->`) are used for template placeholder instructions — allowed
- No hard line-length limit for prose (MD013 disabled), but keep code blocks under 120 chars
- Files end with a single newline

## Shell Script Standards

All scripts live in `scripts/` and must follow:

- Shebang: `#!/usr/bin/env bash`
- Safety: `set -euo pipefail` at top of every script
- Quote all variables: `"$VAR"` not `$VAR`
- Use `[[ ]]` for conditionals (bash-specific is acceptable)
- Functions: `snake_case`, documented with a comment above
- Exit codes: 0 success, 1 general error, 2 usage error
- ShellCheck clean — no suppressed warnings without an explanatory comment
- Use `trap` for cleanup of temp files/directories
- Prefer `$(command)` over backticks

## Commit Conventions

Conventional Commits format: `<type>(<scope>): <description>`

**Types:** feat, fix, refactor, test, docs, chore, ci, perf, security

**Scopes for this project:**

| Scope | Covers |
|-------|--------|
| `template` | Files in `template/` |
| `agents` | Agent definitions in `global/agents/` |
| `commands` | Command definitions in `global/commands/` |
| `scripts` | Shell scripts in `scripts/` |
| `ci` | GitHub Actions, linting configs |
| `docs` | Conversion docs, READMEs |
| `conversion` | Conversion/migration guides |

## Versioning

Semantic versioning (`MAJOR.MINOR.PATCH`) tracked in `VERSION` file at repo root.

| Version Bump | When |
|-------------|------|
| **MAJOR** | Breaking template changes that require existing projects to reconvert |
| **MINOR** | New agents, new commands, new template sections, new features |
| **PATCH** | Typo fixes, wording improvements, bug fixes in scripts |

The `VERSION` file is the single source of truth. `scripts/package.sh` reads it to name the output zip.

## Testing Strategy

This is a documentation/framework project. "Testing" means validation:

- **Markdown lint:** markdownlint-cli2 on all `**/*.md` files
- **Shell lint:** shellcheck on all `scripts/*.sh` files
- **Structure validation:** Required files and directories exist in `template/`
- **Package validation:** `scripts/package.sh` produces a zip with correct structure
- **Conversion validation:** `/convert` successfully processes the packaged zip on a fresh project

### Critical Validation Scenarios

1. `scripts/package.sh` produces a valid zip matching `/convert`'s expected structure
2. `scripts/validate.sh` passes with zero errors
3. All 23 agent definitions and 4 command definitions are present
4. Template CLAUDE.md contains all required sections (worktree isolation, cross-repo feedback, suggestion protocol)
5. Conversion docs accurately describe migration steps for current version
