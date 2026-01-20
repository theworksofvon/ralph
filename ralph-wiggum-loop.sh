#!/bin/zsh
# Ralph Wiggum Loop - "I'm helping!"
# A while loop that lets Claude autonomously work through tasks

set +e
source ~/.zshrc 2>/dev/null
setopt aliases 2>/dev/null
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
TASKS_FILE="tasks.md"
CHANGELOG_FILE="CHANGELOG.md"
CLI_TOOL="claude"
MODEL=""
PROFILE=""
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"

# Parse arguments
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -t, --tasks FILE      Tasks markdown file (default: tasks.md)"
    echo "  -c, --changelog FILE  Changelog file (default: CHANGELOG.md)"
    echo "  -C, --cli TOOL        CLI tool: 'claude' or 'opencode' (default: claude)"
    echo "  -m, --model MODEL     Model to use (e.g., 'opus', 'openai/gpt-4o')"
    echo "  -p, --profile NAME    Load profile from ~/.ralph/profiles/NAME.env"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Profiles:"
    echo "  Available: $(ls "$PROFILES_DIR"/*.env 2>/dev/null | xargs -n1 basename | sed 's/.env$//' | tr '\n' ' ')"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run with defaults"
    echo "  $0 --profile zai                      # Use z.ai backend"
    echo "  $0 --profile zai -m haiku -t my-tasks.md"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tasks) TASKS_FILE="$2"; shift 2 ;;
        -c|--changelog) CHANGELOG_FILE="$2"; shift 2 ;;
        -C|--cli) CLI_TOOL="$2"; shift 2 ;;
        -m|--model) MODEL="$2"; shift 2 ;;
        -p|--profile) PROFILE="$2"; shift 2 ;;
        -h|--help) show_help ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; show_help ;;
    esac
done

# Load profile if specified
if [[ -n "$PROFILE" ]]; then
    PROFILE_FILE="$PROFILES_DIR/${PROFILE}.env"
    if [[ -f "$PROFILE_FILE" ]]; then
        echo -e "${BLUE}Loading profile: ${GREEN}$PROFILE${NC}"
        source "$PROFILE_FILE"
    else
        echo -e "${RED}Profile not found: $PROFILE_FILE${NC}"
        exit 1
    fi
fi

# Print Ralph's greeting
echo -e "${YELLOW}"
echo "  ╔═══════════════════════════════════╗"
echo "  ║     RALPH WIGGUM LOOP             ║"
echo "  ║     \"I'm helping!\"                ║"
echo "  ╚═══════════════════════════════════╝"
echo -e "${NC}"

# Check if tasks file exists
if [[ ! -f "$TASKS_FILE" ]]; then
    echo -e "${RED}Error: Tasks file '$TASKS_FILE' not found!${NC}"
    echo ""
    echo "Create a tasks.md file with tasks like:"
    echo "  - [ ] First task to complete"
    echo "  - [ ] Second task to complete"
    exit 1
fi

# Initialize changelog if it doesn't exist
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
    echo "All notable changes from Ralph Wiggum Loop sessions." >> "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# Check for incomplete tasks
has_incomplete_tasks() {
    grep -q '\- \[ \]' "$TASKS_FILE"
}

# Count tasks
count_tasks() {
    local total=$(grep -c '\- \[' "$TASKS_FILE" 2>/dev/null || echo "0")
    local done=$(grep -c '\- \[x\]' "$TASKS_FILE" 2>/dev/null || echo "0")
    echo "$done/$total"
}

# The prompt that gives Claude full control
RALPH_PROMPT="You're tasked with working on this project.

Read $TASKS_FILE - it contains your task list and any references or context you may need.
Tasks marked '- [ ]' are incomplete. Tasks marked '- [x]' are done.

Your job:
1. Read the tasks file
2. Pick the most important incomplete task
3. Complete it
4. Mark it done in $TASKS_FILE (change '- [ ]' to '- [x]')
5. Write what you changed in $CHANGELOG_FILE

Important: Complete only ONE task, then stop. You will be called again for the next task."

# Main loop
echo -e "${BLUE}Starting Ralph Wiggum Loop...${NC}"
echo -e "CLI tool:   ${GREEN}$CLI_TOOL${NC}"
[[ -n "$PROFILE" ]] && echo -e "Profile:    ${GREEN}$PROFILE${NC}"
[[ -n "$MODEL" ]] && echo -e "Model:      ${GREEN}$MODEL${NC}"
echo -e "Tasks file: ${GREEN}$TASKS_FILE${NC}"
echo -e "Changelog:  ${GREEN}$CHANGELOG_FILE${NC}"
echo ""

iteration=0

while true; do
    # Check if there are incomplete tasks
    if ! grep -q '\- \[ \]' "$TASKS_FILE" 2>/dev/null; then
        break
    fi
    iteration=$((iteration + 1))
    progress=$(count_tasks)

    echo -e "${YELLOW}"
    echo "═══════════════════════════════════════"
    echo "  Iteration #$iteration (Progress: $progress)"
    echo "═══════════════════════════════════════"
    echo -e "${NC}"

    # Build the command
    if [[ "$CLI_TOOL" == "claude" ]]; then
        cmd=(claude --dangerously-skip-permissions --print)
        [[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
        cmd+=("$RALPH_PROMPT")
    elif [[ "$CLI_TOOL" == "opencode" ]]; then
        cmd=(opencode run)
        [[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
        cmd+=("$RALPH_PROMPT")
    else
        echo -e "${RED}Unknown CLI tool: $CLI_TOOL${NC}"
        exit 1
    fi

    # Run Claude
    echo -e "${GREEN}Running $CLI_TOOL...${NC}"
    echo "────────────────────────────────────────"

    if "${cmd[@]}"; then
        echo ""
        echo "────────────────────────────────────────"
        echo -e "${GREEN}Iteration complete.${NC}"
    else
        echo ""
        echo -e "${RED}Error or interruption. Stopping.${NC}"
        exit 1
    fi

    echo ""
    sleep 2  # Brief pause between iterations
done

echo -e "${GREEN}"
echo "═══════════════════════════════════════"
echo "  All tasks complete! Ralph did good!"
echo "  \"Me fail English? That's unpossible!\""
echo "═══════════════════════════════════════"
echo -e "${NC}"
echo -e "${BLUE}Check $CHANGELOG_FILE for details.${NC}"
