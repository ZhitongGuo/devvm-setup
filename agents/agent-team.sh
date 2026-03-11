#!/usr/bin/env bash
set -euo pipefail

# agent-team.sh — Multi-agent orchestration for Claude Code
# Adapted from github.com/Chef-SWanger/master-claude
#
# Usage:
#   agent-team.sh setup <repo-path> <N>    Create N repo checkouts for teams
#   agent-team.sh start <N>                Start all agents for team N
#   agent-team.sh stop <N>                 Stop all agents for team N
#   agent-team.sh list                     List active teams and agents
#   agent-team.sh connect <N> [role]       Attach to an agent's tmux session
#   agent-team.sh logs <N> [role]          View agent logs
#   agent-team.sh orchestrator:start       Start the orchestrator agent
#   agent-team.sh orchestrator:stop        Stop the orchestrator agent
#   agent-team.sh stop-all                 Stop everything

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SOCKET="agent-team"
CONFIG_DIR="$HOME/.agent-team"
LOG_DIR="$CONFIG_DIR/logs"

mkdir -p "$CONFIG_DIR" "$LOG_DIR"

# Load config if it exists
CONFIG_FILE="$CONFIG_DIR/config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# --- Helpers ---

fmt_team() {
    printf "%02d" "$1"
}

log() {
    echo "[agent-team] $*"
}

err() {
    echo "[agent-team] ERROR: $*" >&2
    exit 1
}

has_session() {
    tmux -L "$TMUX_SOCKET" has-session -t "$1" 2>/dev/null
}

# Trust a directory in Claude's allowed list
trust_dir() {
    local dir="$1"
    local claude_config="$HOME/.claude.json"

    if [[ ! -f "$claude_config" ]]; then
        echo '{}' > "$claude_config"
    fi

    # Add to trustedDirectories if not already present
    if command -v jq &>/dev/null; then
        local tmp
        tmp=$(mktemp)
        jq --arg d "$dir" '.trustedDirectories = ((.trustedDirectories // []) + [$d] | unique)' "$claude_config" > "$tmp"
        mv "$tmp" "$claude_config"
    else
        log "Warning: jq not found, skipping auto-trust for $dir"
    fi
}

# --- Commands ---

cmd_setup() {
    local repo_path="${1:?Usage: agent-team.sh setup <repo-path> <N>}"
    local num_teams="${2:?Usage: agent-team.sh setup <repo-path> <N>}"

    repo_path="$(cd "$repo_path" && pwd)"

    # Save config
    cat > "$CONFIG_FILE" <<EOF
CHECKOUT_BASE="$CONFIG_DIR/checkouts"
CHECKOUT_PREFIX="team"
SOURCE_REPO="$repo_path"
EOF
    source "$CONFIG_FILE"

    mkdir -p "$CHECKOUT_BASE"

    for i in $(seq 1 "$num_teams"); do
        local tn
        tn=$(fmt_team "$i")
        local checkout_dir="$CHECKOUT_BASE/${CHECKOUT_PREFIX}_${tn}"

        if [[ -d "$checkout_dir" ]]; then
            log "Team $tn checkout already exists at $checkout_dir"
            continue
        fi

        if [[ -d "$repo_path/.sl" ]]; then
            # Sapling repo — detect Eden vs non-Eden
            if [[ -d "$repo_path/.eden" ]] && command -v eden &>/dev/null; then
                # Eden-backed repo — use fbclone for a lightweight FUSE checkout
                local repo_name
                repo_name=$(basename "$repo_path")
                local eden_dest="${checkout_dir}"
                log "Creating Eden clone of $repo_name for team $tn..."
                if command -v fbclone &>/dev/null; then
                    fbclone "$repo_name" --eden "$eden_dest"
                else
                    # Fallback: use eden clone directly with the backing repo
                    local backing_repo="/data/users/$USER/.eden-backing-repos/$repo_name"
                    if [[ -d "$backing_repo" ]]; then
                        eden clone "$backing_repo" -r master "$eden_dest"
                    else
                        log "WARN: fbclone not found and no backing repo. Falling back to sl clone..."
                        sl clone "$repo_path" "$checkout_dir"
                    fi
                fi
            else
                # Non-Eden Sapling repo — use sl clone
                log "Creating Sapling clone for team $tn..."
                sl clone "$repo_path" "$checkout_dir"
            fi
        elif git -C "$repo_path" rev-parse --git-dir &>/dev/null; then
            # Git repo — use worktree
            log "Creating Git worktree for team $tn..."
            local branch_name="team-${tn}"
            git -C "$repo_path" worktree add "$checkout_dir" -b "$branch_name" 2>/dev/null \
                || git -C "$repo_path" worktree add "$checkout_dir" "$branch_name"
        else
            # Plain directory — just copy
            log "Copying directory for team $tn..."
            cp -r "$repo_path" "$checkout_dir"
        fi

        trust_dir "$checkout_dir"
        log "Team $tn ready at $checkout_dir"
    done

    # Initialize shared memory
    if [[ ! -f "$CHECKOUT_BASE/Memory.md" ]]; then
        cat > "$CHECKOUT_BASE/Memory.md" <<'MEMEOF'
# Shared Memory

Project-wide context accessible to all agents.

## Project
<!-- Updated by the Manager when tasks are assigned -->

## Architecture Decisions
<!-- Key decisions and their rationale -->

## Known Issues
<!-- Blockers, workarounds, things to watch out for -->
MEMEOF
    fi

    log "Setup complete: $num_teams teams ready"
    log "Shared memory: $CHECKOUT_BASE/Memory.md"
}

cmd_start() {
    local team_num="${1:?Usage: agent-team.sh start <N>}"
    local tn
    tn=$(fmt_team "$team_num")

    source "$CONFIG_FILE" 2>/dev/null || err "Run 'agent-team.sh setup' first"

    local checkout_dir="$CHECKOUT_BASE/${CHECKOUT_PREFIX}_${tn}"
    [[ -d "$checkout_dir" ]] || err "Team $tn checkout not found at $checkout_dir. Run setup first."

    # Symlink shared Memory.md into each checkout
    ln -sf "$CHECKOUT_BASE/Memory.md" "$checkout_dir/Memory.md" 2>/dev/null || true

    for role in manager engineer reviewer; do
        local session="team_${tn}_${role}"

        if has_session "$session"; then
            log "$session already running"
            continue
        fi

        log "Starting $session..."
        # Use 'script' to preserve PTY (Claude needs a TTY for interactive mode).
        # Piping through tee destroys the TTY and causes Claude to enter --print mode.
        # Note: script syntax differs between macOS and Linux:
        #   macOS:  script -q <logfile> <command> [args...]
        #   Linux:  script -q -c "<command> [args...]" <logfile>
        local script_cmd
        if [[ "$(uname -s)" == "Darwin" ]]; then
            script_cmd="script -q $LOG_DIR/${session}.log $SCRIPT_DIR/utils/agent-start.sh $role $tn"
        else
            script_cmd="script -q -c '$SCRIPT_DIR/utils/agent-start.sh $role $tn' $LOG_DIR/${session}.log"
        fi
        tmux -L "$TMUX_SOCKET" new-session -d -s "$session" -c "$checkout_dir" \
            "$script_cmd; read"

        sleep 2
    done

    # Wait for agents to initialize, then send activation prompts
    sleep 5

    # Activate manager first
    local manager_session="team_${tn}_manager"
    if has_session "$manager_session"; then
        tmux -L "$TMUX_SOCKET" send-keys -t "$manager_session" \
            "Read ~/Memory.md and your journal (if it exists) at ~/${manager_session}.journal.md. Report when ready." Enter
    fi

    # Activate engineer
    local engineer_session="team_${tn}_engineer"
    if has_session "$engineer_session"; then
        tmux -L "$TMUX_SOCKET" send-keys -t "$engineer_session" \
            "Read ~/Memory.md and your journal (if it exists) at ~/${engineer_session}.journal.md. Report when ready. Wait for the Manager to assign you work." Enter
    fi

    # Activate reviewer
    local reviewer_session="team_${tn}_reviewer"
    if has_session "$reviewer_session"; then
        tmux -L "$TMUX_SOCKET" send-keys -t "$reviewer_session" \
            "Read ~/Memory.md and your journal (if it exists) at ~/${reviewer_session}.journal.md. Report when ready. Wait for the Manager to assign you a review." Enter
    fi

    log "Team $tn started (manager, engineer, reviewer)"
}

cmd_stop() {
    local team_num="${1:?Usage: agent-team.sh stop <N>}"
    local tn
    tn=$(fmt_team "$team_num")

    for role in manager engineer reviewer; do
        local session="team_${tn}_${role}"
        if has_session "$session"; then
            # Ask agent to save state before killing
            tmux -L "$TMUX_SOCKET" send-keys -t "$session" \
                "Write your current state to your journal, then type /exit" Enter
            sleep 3
            tmux -L "$TMUX_SOCKET" kill-session -t "$session" 2>/dev/null || true
            log "Stopped $session"
        fi
    done
}

cmd_list() {
    log "Active agent sessions:"
    tmux -L "$TMUX_SOCKET" list-sessions 2>/dev/null || echo "  (none)"
}

cmd_connect() {
    local team_num="${1:?Usage: agent-team.sh connect <N> [role]}"
    local role="${2:-manager}"
    local tn
    tn=$(fmt_team "$team_num")
    local session="team_${tn}_${role}"

    has_session "$session" || err "Session $session not found"
    tmux -L "$TMUX_SOCKET" attach-session -t "$session"
}

cmd_logs() {
    local team_num="${1:?Usage: agent-team.sh logs <N> [role]}"
    local role="${2:-manager}"
    local tn
    tn=$(fmt_team "$team_num")
    local logfile="$LOG_DIR/team_${tn}_${role}.log"

    [[ -f "$logfile" ]] || err "Log file not found: $logfile"
    tail -f "$logfile"
}

cmd_orchestrator_start() {
    local session="orchestrator"

    if has_session "$session"; then
        log "Orchestrator already running"
        return
    fi

    source "$CONFIG_FILE" 2>/dev/null || err "Run 'agent-team.sh setup' first"

    log "Starting orchestrator..."
    local script_cmd
    if [[ "$(uname -s)" == "Darwin" ]]; then
        script_cmd="script -q $LOG_DIR/orchestrator.log $SCRIPT_DIR/utils/claude.sh orchestrator"
    else
        script_cmd="script -q -c '$SCRIPT_DIR/utils/claude.sh orchestrator' $LOG_DIR/orchestrator.log"
    fi
    tmux -L "$TMUX_SOCKET" new-session -d -s "$session" -c "$CHECKOUT_BASE" \
        "$script_cmd; read"

    sleep 3
    tmux -L "$TMUX_SOCKET" send-keys -t "$session" \
        "Read ~/Memory.md. You are the orchestrator. List active teams and await instructions." Enter

    log "Orchestrator started"
}

cmd_orchestrator_stop() {
    if has_session "orchestrator"; then
        tmux -L "$TMUX_SOCKET" send-keys -t "orchestrator" \
            "Write your current state to your journal, then type /exit" Enter
        sleep 3
        tmux -L "$TMUX_SOCKET" kill-session -t "orchestrator" 2>/dev/null || true
        log "Orchestrator stopped"
    fi
}

cmd_stop_all() {
    log "Stopping all agent sessions..."
    tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
    log "All sessions terminated"
}

cmd_cleanup() {
    local team_num="${1:?Usage: agent-team.sh cleanup <N>}"
    local tn
    tn=$(fmt_team "$team_num")

    source "$CONFIG_FILE" 2>/dev/null || err "No config found"

    local checkout_dir="$CHECKOUT_BASE/${CHECKOUT_PREFIX}_${tn}"
    [[ -d "$checkout_dir" ]] || { log "Team $tn checkout not found"; return; }

    # Stop agents first
    cmd_stop "$team_num" 2>/dev/null || true

    # Remove checkout — use eden rm for Eden mounts, git worktree remove for Git
    if [[ -d "$checkout_dir/.eden" ]] && command -v eden &>/dev/null; then
        log "Removing Eden checkout for team $tn..."
        eden rm "$checkout_dir"
    elif [[ -f "$checkout_dir/.git" ]] && grep -q "gitdir:" "$checkout_dir/.git" 2>/dev/null; then
        log "Removing Git worktree for team $tn..."
        local main_repo
        main_repo=$(grep "gitdir:" "$checkout_dir/.git" | sed 's/gitdir: //' | sed 's|/.git/worktrees/.*||')
        git -C "$main_repo" worktree remove "$checkout_dir" --force 2>/dev/null || rm -rf "$checkout_dir"
    else
        log "Removing directory for team $tn..."
        rm -rf "$checkout_dir"
    fi

    log "Team $tn cleaned up"
}

# --- Main ---

cmd="${1:-help}"
shift || true

case "$cmd" in
    setup)              cmd_setup "$@" ;;
    start)              cmd_start "$@" ;;
    stop)               cmd_stop "$@" ;;
    cleanup)            cmd_cleanup "$@" ;;
    list)               cmd_list ;;
    connect)            cmd_connect "$@" ;;
    logs)               cmd_logs "$@" ;;
    orchestrator:start) cmd_orchestrator_start ;;
    orchestrator:stop)  cmd_orchestrator_stop ;;
    stop-all)           cmd_stop_all ;;
    help|*)
        cat <<'USAGE'
agent-team.sh — Multi-agent orchestration for Claude Code

Commands:
  setup <repo-path> <N>    Create N repo checkouts for agent teams
  start <N>                Start all agents for team N
  stop <N>                 Stop all agents for team N
  cleanup <N>              Stop team N and remove its checkout (Eden-safe)
  list                     List active teams and agents
  connect <N> [role]       Attach to an agent's tmux session
  logs <N> [role]          Tail agent logs
  orchestrator:start       Start the cross-team orchestrator
  orchestrator:stop        Stop the orchestrator
  stop-all                 Stop everything

Roles: manager, engineer, reviewer, orchestrator
USAGE
        ;;
esac
