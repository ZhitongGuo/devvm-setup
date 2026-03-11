#!/usr/bin/env bash
set -euo pipefail

# Sync devvm-setup repo: pull remote changes, push local changes
# Intended to run as a daily cron job

REPO_DIR="$HOME/Repos/devvm-setup"
LOG_FILE="$HOME/.devvm-setup-sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

cd "$REPO_DIR" || { log "ERROR: repo not found at $REPO_DIR"; exit 1; }

for branch in master macos-setup; do
    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        git checkout "$branch" >> "$LOG_FILE" 2>&1
        git pull --rebase origin "$branch" >> "$LOG_FILE" 2>&1 || log "WARN: pull failed for $branch"
        git push origin "$branch" >> "$LOG_FILE" 2>&1 || log "WARN: push failed for $branch"
        log "Synced $branch"
    fi
done

# Return to macos-setup as default
git checkout macos-setup >> "$LOG_FILE" 2>&1 || true

log "Sync complete"
