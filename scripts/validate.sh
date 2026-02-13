#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Run markdownlint + shellcheck + structure validation locally

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXIT_CODE=0

echo "=== Markdown Lint ==="
if command -v markdownlint-cli2 &>/dev/null; then
    markdownlint-cli2 "$REPO_ROOT/**/*.md" || EXIT_CODE=1
elif command -v markdownlint &>/dev/null; then
    markdownlint "$REPO_ROOT/**/*.md" --config "$REPO_ROOT/.markdownlint.json" || EXIT_CODE=1
else
    echo "WARNING: markdownlint not found. Install with: npm install -g markdownlint-cli2"
    EXIT_CODE=1
fi

echo ""
echo "=== ShellCheck ==="
if command -v shellcheck &>/dev/null; then
    find "$REPO_ROOT/scripts" -name "*.sh" -exec shellcheck {} + || EXIT_CODE=1
else
    echo "WARNING: shellcheck not found. Install with: apt install shellcheck"
    EXIT_CODE=1
fi

echo ""
echo "=== Structure Validation ==="
errors=0

required_files=("template/CONVERSION.md" "template/repo/CLAUDE.md" "template/repo/TASKS.md" "template/repo/PROJECT_LOG.md" "template/repo/CLAUDE_SUGGESTIONS.md" "template/repo/.claude/SPEC.md" "template/repo/.claude/GUIDELINES.md" "template/repo/.claude/PHASES.md" "template/repo/.claude/CONTRACTS.md" "template/repo/.claude/GITHUB_INTEGRATION.md" "VERSION")
for item in "${required_files[@]}"; do
    if [[ ! -f "$REPO_ROOT/$item" ]]; then
        echo "MISSING: $item"
        errors=$((errors + 1))
    else
        echo "OK: $item"
    fi
done

required_dirs=("template/repo/agent-logs" "template/repo/logs" "template/conversion" "global/agents" "global/commands")
for item in "${required_dirs[@]}"; do
    if [[ ! -d "$REPO_ROOT/$item" ]]; then
        echo "MISSING DIR: $item"
        errors=$((errors + 1))
    else
        echo "OK: $item/"
    fi
done

# Count checks
agent_count=$(find "$REPO_ROOT/global/agents" -name "*.md" | wc -l)
command_count=$(find "$REPO_ROOT/global/commands" -name "*.md" | wc -l)
echo ""
echo "Agents: $agent_count (expected 23)"
echo "Commands: $command_count (expected 4)"

if [[ "$agent_count" -lt 23 ]]; then
    echo "WARNING: Expected 23 agents, found $agent_count"
fi
if [[ "$command_count" -lt 4 ]]; then
    echo "WARNING: Expected 4 commands, found $command_count"
fi

if [[ $errors -gt 0 ]]; then
    echo ""
    echo "FAILED: $errors missing items"
    EXIT_CODE=1
else
    echo ""
    echo "All structure checks passed."
fi

exit $EXIT_CODE
