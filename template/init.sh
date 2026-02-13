#!/usr/bin/env bash
set -euo pipefail

# init.sh — Project Orchestrator Installer
# Extract this script from the zip first, then run it.
# It finds the orchestrator zip, extracts files to the right places,
# and prompts before overwriting anything in ~/.claude/.
#
# Usage:
#   unzip -j project-orchestrator-v*.zip init.sh
#   bash init.sh
#
# Or extract and run in one step:
#   unzip -j project-orchestrator-v*.zip init.sh && bash init.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Colors (if terminal supports them) ---
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' BOLD='' NC=''
fi

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# --- Find the zip ---
ZIP_FILE=""
shopt -s nullglob
for f in "$SCRIPT_DIR"/*orchestrator*.zip; do
    ZIP_FILE="$f"
    break
done
shopt -u nullglob

if [[ -z "$ZIP_FILE" ]]; then
    error "No orchestrator zip found in $SCRIPT_DIR"
    echo "  Expected: project-orchestrator-v*.zip"
    echo "  Download from: gh release download -R <org>/claude-agent-workflow"
    exit 1
fi

echo -e "${BOLD}Project Orchestrator Installer${NC}"
echo "  Zip: $(basename "$ZIP_FILE")"
echo "  Target repo: $SCRIPT_DIR"
echo "  Global dir: ~/.claude/"
echo ""

# --- Extract to temp ---
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

unzip -q "$ZIP_FILE" -d "$STAGING_DIR"

# Verify expected structure
if [[ ! -d "$STAGING_DIR/repo" ]] || [[ ! -d "$STAGING_DIR/global" ]]; then
    error "Zip doesn't have expected structure (repo/ and global/ directories)"
    exit 1
fi

# --- Prompt helper ---
prompt_overwrite() {
    local target="$1"
    local source="$2"

    if [[ ! -e "$target" ]]; then
        return 0  # doesn't exist, safe to write
    fi

    # Check if files are identical
    if diff -q "$source" "$target" &>/dev/null; then
        return 1  # identical, skip
    fi

    echo ""
    warn "File already exists: $target"
    while true; do
        read -rp "  Overwrite? [y]es / [n]o / [d]iff: " choice
        case "$choice" in
            y|Y|yes)  return 0 ;;
            n|N|no)   return 1 ;;
            d|D|diff) diff --color=auto "$target" "$source" || true; echo "" ;;
            *)        echo "  Please enter y, n, or d" ;;
        esac
    done
}

# --- Install global files (~/.claude/) ---
echo -e "${BOLD}Installing global files...${NC}"
mkdir -p ~/.claude/agents ~/.claude/commands

global_installed=0
global_skipped=0
global_updated=0

for source_file in "$STAGING_DIR"/global/agents/*.md; do
    filename="$(basename "$source_file")"
    target="$HOME/.claude/agents/$filename"

    if [[ ! -e "$target" ]]; then
        cp "$source_file" "$target"
        global_installed=$((global_installed + 1))
    elif diff -q "$source_file" "$target" &>/dev/null; then
        global_skipped=$((global_skipped + 1))
    elif prompt_overwrite "$target" "$source_file"; then
        cp "$source_file" "$target"
        global_updated=$((global_updated + 1))
    else
        global_skipped=$((global_skipped + 1))
    fi
done

for source_file in "$STAGING_DIR"/global/commands/*.md; do
    filename="$(basename "$source_file")"
    target="$HOME/.claude/commands/$filename"

    if [[ ! -e "$target" ]]; then
        cp "$source_file" "$target"
        global_installed=$((global_installed + 1))
    elif diff -q "$source_file" "$target" &>/dev/null; then
        global_skipped=$((global_skipped + 1))
    elif prompt_overwrite "$target" "$source_file"; then
        cp "$source_file" "$target"
        global_updated=$((global_updated + 1))
    else
        global_skipped=$((global_skipped + 1))
    fi
done

info "Global: $global_installed new, $global_updated updated, $global_skipped unchanged"

# --- Install repo files ---
echo ""
echo -e "${BOLD}Installing repo files...${NC}"

repo_created=0
repo_skipped=0

# Create directory structure first
for dir in .claude agent-logs agent-logs/archive logs; do
    mkdir -p "$SCRIPT_DIR/$dir"
done

# Install repo files, never clobber existing project files without asking
install_repo_file() {
    local rel_path="$1"
    local source="$STAGING_DIR/repo/$rel_path"
    local target="$SCRIPT_DIR/$rel_path"

    if [[ ! -e "$source" ]]; then
        return
    fi

    if [[ ! -e "$target" ]]; then
        # Ensure parent directory exists
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        info "Created: $rel_path"
        repo_created=$((repo_created + 1))
    else
        repo_skipped=$((repo_skipped + 1))
    fi
}

# Core files
install_repo_file "CLAUDE.md"
install_repo_file "TASKS.md"
install_repo_file "PROJECT_LOG.md"
install_repo_file "CLAUDE_SUGGESTIONS.md"

# .claude/ reference files
for f in SPEC.md GUIDELINES.md PHASES.md CONTRACTS.md GITHUB_INTEGRATION.md; do
    install_repo_file ".claude/$f"
done

# Support files
install_repo_file "agent-logs/_TEMPLATE.md"
install_repo_file "logs/REJECTED_SUGGESTIONS.md"

# Ensure archive dir has .gitkeep
if [[ ! -e "$SCRIPT_DIR/agent-logs/archive/.gitkeep" ]]; then
    touch "$SCRIPT_DIR/agent-logs/archive/.gitkeep"
fi

info "Repo: $repo_created created, $repo_skipped already existed (not overwritten)"

# --- Copy conversion docs for reference ---
if [[ -f "$STAGING_DIR/CONVERSION.md" ]] && [[ ! -e "$SCRIPT_DIR/CONVERSION.md" ]]; then
    cp "$STAGING_DIR/CONVERSION.md" "$SCRIPT_DIR/CONVERSION.md"
    info "Created: CONVERSION.md (reference — safe to delete after setup)"
fi

# --- Summary ---
echo ""
echo -e "${BOLD}Installation complete.${NC}"
echo ""

agent_count=$(find ~/.claude/agents -name "*.md" 2>/dev/null | wc -l)
command_count=$(find ~/.claude/commands -name "*.md" 2>/dev/null | wc -l)

echo "  Global (~/.claude/):"
echo "    Agents:   $agent_count"
echo "    Commands: $command_count"
echo ""
echo "  Repo files:"
echo "    Created:  $repo_created"
echo "    Existing: $repo_skipped (not overwritten)"
echo ""

# --- Guidance ---
if [[ $repo_created -gt 0 ]]; then
    echo -e "${BOLD}Next steps:${NC}"
    echo ""
    echo "  1. Open the project in Claude Code terminal"
    echo ""
    echo "  2. For a NEW project, try this prompt:"
    echo ""
    echo '     "This is a new project. Read CLAUDE.md and the files in .claude/ to'
    echo '     understand the framework. Then help me configure them for this project:'
    echo '     fill in the Project Identity section of CLAUDE.md, set up the team'
    echo '     roster for my needs, configure SPEC.md with our architecture, and'
    echo '     define build phases in PHASES.md. Our project is: [describe your project]"'
    echo ""
    echo "  3. For an EXISTING project being converted, try:"
    echo ""
    echo '     "Run /convert to set up the project orchestrator framework."'
    echo ""
    echo "  4. Once configured, start a session with: /start"
    echo ""
fi

# --- Cleanup prompt ---
echo -e "${YELLOW}Cleanup:${NC}"
echo "  You can remove these files from the repo root:"
echo "    - $(basename "$ZIP_FILE")"
echo "    - init.sh"
if [[ -e "$SCRIPT_DIR/CONVERSION.md" ]]; then
    echo "    - CONVERSION.md (after reviewing)"
fi
echo ""
echo "  Consider adding to .gitignore:"
echo "    *.zip"
echo "    init.sh"
