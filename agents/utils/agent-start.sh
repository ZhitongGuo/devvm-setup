#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for team agents. Syncs to latest, then launches claude.
# Usage: agent-start.sh <role> <team_number>
#   role:        manager | engineer | reviewer
#   team_number: e.g. 01, 02

ROLE="$1"
TEAM_NUM="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Auto-detect VCS and sync to latest.
if [[ -d ".sl" ]]; then
    # Sapling repo (Meta internal)
    echo "[agent-start] Detected Sapling repo, syncing..."
    sl status 2>/dev/null | { grep '^!' || true; } | awk '{print $2}' | xargs -r sl forget 2>/dev/null || true
    if [ -n "$(sl status 2>/dev/null)" ]; then
        sl commit -m "WIP: temporary commit $(date '+%Y-%m-%d %H:%M:%S')" || true
    fi
    if ! sl pull; then
        echo "[agent-start] Warning: 'sl pull' failed. Continuing with current state..."
    fi
    sleep 2
    sl goto --rev remote/master || echo "[agent-start] Warning: 'sl goto remote/master' failed. Continuing..."

elif git rev-parse --git-dir &>/dev/null; then
    # Git repo
    echo "[agent-start] Detected Git repo, syncing..."
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git stash push -m "WIP: temporary stash $(date '+%Y-%m-%d %H:%M:%S')" || true
    fi
    git fetch origin 2>/dev/null || echo "[agent-start] Warning: 'git fetch' failed. Continuing..."
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@') || true
    if [[ -z "$default_branch" ]]; then
        if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
            default_branch="main"
        else
            default_branch="master"
        fi
    fi
    git rebase "origin/$default_branch" 2>/dev/null || echo "[agent-start] Warning: rebase failed. Continuing..."

else
    echo "[agent-start] No recognized VCS found. Continuing without sync..."
fi

# Clean up stale Claude settings files in /tmp that may be owned by other users.
# On shared devgpus, these cause EACCES errors and prevent Claude from starting.
for f in /tmp/claude-settings-*.json; do
    [[ -e "$f" ]] || continue
    if [[ ! -w "$f" ]]; then
        echo "[agent-start] Removing inaccessible settings cache: $f"
        sudo rm -f "$f" 2>/dev/null || echo "[agent-start] Warning: could not remove $f (no sudo?)"
    fi
done

# Launch claude with the appropriate role.
exec "$SCRIPT_DIR/utils/claude.sh" "$ROLE" "$TEAM_NUM"
