#!/usr/bin/env bash
set -euo pipefail

SESSION="dev"
PROJECT_DIR="${1:-.}"

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# If already inside the tmux session, just open the panes
if [ -n "${TMUX:-}" ]; then
    echo "Already in a tmux session. Use tmux commands to manage panes."
    exit 0
fi

# Create or attach to the dev session
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Attaching to existing '$SESSION' session..."
    tmux attach-session -t "$SESSION"
else
    echo "Creating '$SESSION' session in $PROJECT_DIR..."

    # Create session with claude in the first (left) pane
    tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR" "claude"

    # Split right pane for nvim
    tmux split-window -h -t "$SESSION" -c "$PROJECT_DIR" "nvim ."

    # Focus the claude pane (left)
    tmux select-pane -t "$SESSION:0.0"

    # Set 60/40 split (claude gets more space on the left)
    tmux resize-pane -t "$SESSION:0.0" -x "60%"

    # Attach
    tmux attach-session -t "$SESSION"
fi
