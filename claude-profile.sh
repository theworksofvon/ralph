#!/bin/zsh
source ~/.zshrc 2>/dev/null
# ============================================
# Claude Profile Switcher
# ============================================
# Quick way to run claude with a specific profile
#
# Usage:
#   ./claude-profile.sh zai "your prompt here"
#   ./claude-profile.sh default "your prompt here"
#
# Or source a profile for your current shell session:
#   source ~/.ralph/profiles/zai.env
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <profile> [claude args...]"
    echo ""
    echo "Available profiles:"
    ls "$PROFILES_DIR"/*.env 2>/dev/null | xargs -n1 basename | sed 's/.env$/  /'
    exit 1
fi

PROFILE="$1"
shift

PROFILE_FILE="$PROFILES_DIR/${PROFILE}.env"

if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "Profile not found: $PROFILE"
    echo "Available: $(ls "$PROFILES_DIR"/*.env 2>/dev/null | xargs -n1 basename | sed 's/.env$//' | tr '\n' ' ')"
    exit 1
fi

# Source the profile and run claude
source "$PROFILE_FILE"
exec claude-yolo "$@"
