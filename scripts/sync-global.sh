#!/usr/bin/env bash
set -euo pipefail

# sync-global.sh — Copy global/ to ~/.claude/ (dev convenience)
# Run this after modifying agent or command definitions to update your local install.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p ~/.claude/agents ~/.claude/commands

echo "Syncing agents..."
cp "$REPO_ROOT/global/agents/"*.md ~/.claude/agents/
agent_count=$(find "$REPO_ROOT/global/agents" -name "*.md" | wc -l)
echo "  Copied $agent_count agents to ~/.claude/agents/"

echo "Syncing commands..."
cp "$REPO_ROOT/global/commands/"*.md ~/.claude/commands/
command_count=$(find "$REPO_ROOT/global/commands" -name "*.md" | wc -l)
echo "  Copied $command_count commands to ~/.claude/commands/"

echo "Done. Global files installed to ~/.claude/"
