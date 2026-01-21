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
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Defaults
TASKS_FILE="tasks.md"
CHANGELOG_FILE="CHANGELOG.md"
CLI_TOOL="claude"
MODEL=""
PROFILE=""
INTERACTIVE=false
PLAN_MODE=false
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"

# Parse arguments
show_help() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  plan                  Start planning mode to create/refine tasks.md"
    echo "  run (default)         Run the task loop"
    echo ""
    echo "Options:"
    echo "  -t, --tasks FILE      Tasks markdown file (default: tasks.md)"
    echo "  -c, --changelog FILE  Changelog file (default: CHANGELOG.md)"
    echo "  -C, --cli TOOL        CLI tool: 'claude' or 'opencode' (default: claude)"
    echo "  -m, --model MODEL     Model to use (e.g., 'opus', 'openai/gpt-4o')"
    echo "  -p, --profile NAME    Load profile from ~/.ralph/profiles/NAME.env"
    echo "  -i, --interactive     Run Claude with full TUI (manual exit required)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 plan --profile zai          # Plan tasks interactively"
    echo "  $0 --profile zai               # Run task loop"
    echo "  $0 -i --profile zai            # Run with interactive Claude"
    exit 0
}

# Check for subcommand first
case "${1:-}" in
    plan)
        PLAN_MODE=true
        shift
        ;;
    run)
        shift
        ;;
    -*)
        # It's a flag, not a subcommand
        ;;
esac

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tasks) TASKS_FILE="$2"; shift 2 ;;
        -c|--changelog) CHANGELOG_FILE="$2"; shift 2 ;;
        -C|--cli) CLI_TOOL="$2"; shift 2 ;;
        -m|--model) MODEL="$2"; shift 2 ;;
        -p|--profile) PROFILE="$2"; shift 2 ;;
        -i|--interactive) INTERACTIVE=true; shift ;;
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

# ============================================
# PLAN MODE
# ============================================
if [[ "$PLAN_MODE" == true ]]; then
    echo -e "${YELLOW}"
    echo "  ╔═══════════════════════════════════╗"
    echo "  ║     RALPH PLANNING MODE           ║"
    echo "  ╚═══════════════════════════════════╝"
    echo -e "${NC}"

    PLAN_PROMPT="You're helping plan tasks for a project.

Your job is to help create or refine a tasks.md file. This file will be used by an autonomous agent to complete work.

Current tasks file: $TASKS_FILE
$(if [[ -f "$TASKS_FILE" ]]; then echo "The file exists - read it to see current tasks."; else echo "The file doesn't exist yet - we'll create it."; fi)

Guidelines for tasks.md:
- Use '- [ ]' checkbox format for each task
- Be specific - include file paths, function names, context
- Add a References section with helpful context, links, patterns to follow
- Order by dependency when possible
- Keep tasks atomic - one clear objective each

Help the user think through what needs to be done and create a solid task list.
When the user is happy with the plan, write it to $TASKS_FILE."

    cmd=(claude --dangerously-skip-permissions)
    [[ -n "$MODEL" ]] && cmd+=(--model "$MODEL")
    cmd+=("$PLAN_PROMPT")

    "${cmd[@]}"
    exit $?
fi

# ============================================
# RUN MODE
# ============================================

# Print Ralph's greeting
echo -e "${YELLOW}"
echo "  ╔═══════════════════════════════════╗"
echo "  ║     RALPH WIGGUM LOOP             ║"
echo "  ╚═══════════════════════════════════╝"
echo -e "${NC}"

# Check if tasks file exists
if [[ ! -f "$TASKS_FILE" ]]; then
    echo -e "${RED}Error: Tasks file '$TASKS_FILE' not found!${NC}"
    echo ""
    echo "Create one with: $0 plan"
    exit 1
fi

# Initialize changelog if it doesn't exist
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
    echo "All notable changes from Ralph Wiggum Loop sessions." >> "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# Count tasks
count_tasks() {
    local total=$(grep -c '\- \[' "$TASKS_FILE" 2>/dev/null || echo "0")
    local done=$(grep -c '\- \[x\]' "$TASKS_FILE" 2>/dev/null || echo "0")
    echo "$done/$total"
}

# Get next incomplete task text
get_next_task() {
    grep '\- \[ \]' "$TASKS_FILE" | head -1 | sed 's/^- \[ \] //'
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
start_time=$(date +%s)

while true; do
    # Check if there are incomplete tasks
    if ! grep -q '\- \[ \]' "$TASKS_FILE" 2>/dev/null; then
        break
    fi
    iteration=$((iteration + 1))
    progress=$(count_tasks)
    next_task=$(get_next_task)
    iter_start=$(date +%s)

    echo -e "${YELLOW}"
    echo "═══════════════════════════════════════"
    echo "  Iteration #$iteration (Progress: $progress)"
    echo "═══════════════════════════════════════"
    echo -e "${NC}"

    # Show what task is likely next
    echo -e "${CYAN}Next task:${NC} ${DIM}$next_task${NC}"
    echo ""

    # Build the command
    if [[ "$CLI_TOOL" == "claude" ]]; then
        if [[ "$INTERACTIVE" == true ]]; then
            cmd=(claude --dangerously-skip-permissions)
        else
            # Use stdbuf to force line-buffered output for streaming
            cmd=(stdbuf -oL claude --dangerously-skip-permissions --print)
        fi
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
        iter_end=$(date +%s)
        iter_duration=$((iter_end - iter_start))

        echo ""
        echo "────────────────────────────────────────"

        # Show completion summary
        new_progress=$(count_tasks)
        echo -e "${GREEN}✓ Iteration #$iteration complete${NC} ${DIM}(${iter_duration}s)${NC}"
        echo -e "${BLUE}Progress:${NC} $new_progress tasks done"

        # Show last changelog entry
        last_entry=$(grep -A1 "^\- \[" "$CHANGELOG_FILE" 2>/dev/null | tail -1)
        if [[ -n "$last_entry" ]]; then
            echo -e "${BLUE}Last logged:${NC} ${DIM}$last_entry${NC}"
        fi
    else
        echo ""
        echo -e "${RED}Error or interruption. Stopping.${NC}"
        exit 1
    fi

    echo ""
    sleep 2  # Brief pause between iterations
done

end_time=$(date +%s)
total_duration=$((end_time - start_time))

echo -e "${GREEN}"
echo "═══════════════════════════════════════"
echo "  All tasks complete!"
echo "  $iteration iterations in ${total_duration}s"
echo "═══════════════════════════════════════"
echo -e "${NC}"
echo -e "${BLUE}Check $CHANGELOG_FILE for details.${NC}"
