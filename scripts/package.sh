#!/usr/bin/env bash
set -euo pipefail

# package.sh — Build distributable template zip
# Assembles global/ + template/ into a zip that /convert can consume.
# Output: project-orchestrator-vX.Y.Z.zip in repo root.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$REPO_ROOT/VERSION")"
OUTPUT_NAME="project-orchestrator-v${VERSION}.zip"
TEMPLATE_DIR="$REPO_ROOT/template"
STAGING_DIR="$(mktemp -d)"

trap 'rm -rf "$STAGING_DIR"' EXIT

echo "Packaging v${VERSION}..."

# Check for zip command
if ! command -v zip &>/dev/null; then
    echo "ERROR: 'zip' command not found. Install with: apt install zip" >&2
    exit 1
fi

# Validate source structure
echo "Validating source files..."
errors=0

for dir in "$TEMPLATE_DIR/repo" "$TEMPLATE_DIR/repo/.claude" "$TEMPLATE_DIR/repo/agent-logs" "$TEMPLATE_DIR/repo/logs" "$TEMPLATE_DIR/conversion" "$REPO_ROOT/global/agents" "$REPO_ROOT/global/commands"; do
    if [[ ! -d "$dir" ]]; then
        echo "ERROR: Missing directory: $dir" >&2
        errors=$((errors + 1))
    fi
done

for file in "$TEMPLATE_DIR/CONVERSION.md" "$TEMPLATE_DIR/repo/CLAUDE.md" "$TEMPLATE_DIR/repo/TASKS.md" "$TEMPLATE_DIR/repo/PROJECT_LOG.md" "$TEMPLATE_DIR/repo/CLAUDE_SUGGESTIONS.md"; do
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Missing file: $file" >&2
        errors=$((errors + 1))
    fi
done

if [[ $errors -gt 0 ]]; then
    echo "Aborting: $errors validation errors found." >&2
    exit 1
fi

# Assemble into staging directory
echo "Assembling package..."

# Copy template contents (repo/, conversion/, CONVERSION.md)
cp -r "$TEMPLATE_DIR/"* "$STAGING_DIR/"

# Copy global/ from repo root (not duplicated in template/)
cp -r "$REPO_ROOT/global" "$STAGING_DIR/global"

# Count contents
agent_count=$(find "$STAGING_DIR/global/agents" -name "*.md" | wc -l)
command_count=$(find "$STAGING_DIR/global/commands" -name "*.md" | wc -l)
echo "  Agents: $agent_count"
echo "  Commands: $command_count"

# Remove any .gitkeep files (not needed in zip)
find "$STAGING_DIR" -name ".gitkeep" -delete

# Build zip
cd "$STAGING_DIR"
zip -r "$REPO_ROOT/$OUTPUT_NAME" . -x '*.Zone.Identifier' > /dev/null
cd "$REPO_ROOT"

echo ""
echo "Created: $OUTPUT_NAME ($(du -h "$OUTPUT_NAME" | cut -f1))"
echo "Verify with: unzip -l $OUTPUT_NAME"
