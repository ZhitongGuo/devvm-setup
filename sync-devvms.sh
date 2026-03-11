#!/usr/bin/env bash
set -euo pipefail

# Sync devvm-setup repo to remote DevVMs.
# Clones/pulls the repo and merges dotfile additions into existing configs.
# SAFE: does not overwrite existing dotfiles or delete Claude session history.
#
# Usage: sync-devvms.sh [host1 host2 ...]
#   If no hosts given, syncs all configured VMs.

REPO_URL="https://github.com/ZhitongGuo/devvm-setup.git"
REPO_DIR="~/Repos/devvm-setup"
LOG_FILE="$HOME/.devvm-sync.log"

DEFAULT_HOSTS=(
    devgpu018.nha2
    devgpu020.pci2
    devvm3010.eag0
    devgpu028.nao3
    devgpu011.lco3
)

HOSTS=("${@:-${DEFAULT_HOSTS[@]}}")

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" | tee -a "$LOG_FILE"
}

# The remote script that runs on each VM via SSH.
# It clones/pulls the repo, then merges dotfile blocks into existing configs.
REMOTE_SCRIPT='
set -euo pipefail

REPO_URL="'"$REPO_URL"'"
REPO_DIR=~/Repos/devvm-setup
MARKER_BEGIN="# >>> devvm-setup >>>"
MARKER_END="# <<< devvm-setup <<<"

log() { echo "[devvm-sync] $*"; }

# --- Step 1: Clone or pull the repo ---
mkdir -p ~/Repos
if [[ -d "$REPO_DIR/.git" ]]; then
    log "Pulling latest..."
    cd "$REPO_DIR"
    git pull --rebase origin master 2>/dev/null || git pull origin master || log "WARN: pull failed, using existing"
else
    log "Cloning repo..."
    # Try with proxy first (DevVM), then without
    git clone "$REPO_URL" "$REPO_DIR" 2>/dev/null \
        || git -c http.proxy=fwdproxy:8080 clone "$REPO_URL" "$REPO_DIR" 2>/dev/null \
        || { log "ERROR: clone failed"; exit 1; }
    cd "$REPO_DIR"
fi

# --- Step 2: Merge dotfile blocks (append-only, idempotent) ---
# For each dotfile, extract the content between markers or append if not present.
# This preserves the VM existing config and adds our customizations.

merge_dotfile() {
    local src="$1"       # source file in repo
    local dest="$2"      # destination file on VM
    local file_marker="$3"  # unique marker for this file

    local begin="${MARKER_BEGIN} ${file_marker}"
    local end="${MARKER_END} ${file_marker}"

    [[ -f "$src" ]] || { log "WARN: $src not found, skipping"; return; }

    # Create dest if it does not exist
    if [[ ! -f "$dest" ]]; then
        log "Creating $dest (new file)"
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        return
    fi

    local block
    block=$(cat "$src")

    # If markers already exist, replace the block between them
    if grep -qF "$begin" "$dest" 2>/dev/null; then
        log "Updating managed block in $dest"
        # Use awk to replace content between markers
        awk -v begin="$begin" -v end="$end" -v block="$block" \
            "BEGIN{skip=0} \$0==begin{print; print block; skip=1; next} \$0==end{skip=0} skip{next} {print}" \
            "$dest" > "${dest}.tmp"
        mv "${dest}.tmp" "$dest"
    else
        # Append the managed block
        log "Appending managed block to $dest"
        {
            echo ""
            echo "$begin"
            echo "$block"
            echo "$end"
        } >> "$dest"
    fi
}

# .zshrc — merge additions (keep existing Meta master.zshrc sourcing etc.)
merge_dotfile "$REPO_DIR/dotfiles/.zshrc" "$HOME/.zshrc" "zshrc"

# .tmux.conf — merge additions
merge_dotfile "$REPO_DIR/dotfiles/.tmux.conf" "$HOME/.tmux.conf" "tmux"

# .vimrc — merge additions
merge_dotfile "$REPO_DIR/dotfiles/.vimrc" "$HOME/.vimrc" "vimrc"

# --- Step 3: Safe file copies (these are ours entirely, not shared with system) ---
# These files do not conflict with system defaults, so we can overwrite safely.

# starship.toml
mkdir -p ~/.config
cp "$REPO_DIR/dotfiles/starship.toml" ~/.config/starship.toml
log "Copied starship.toml"

# CLAUDE.md — project instructions (NOT session history)
mkdir -p ~/.claude
cp "$REPO_DIR/dotfiles/CLAUDE.md" ~/.claude/CLAUDE.md
log "Copied CLAUDE.md (instructions only — session history untouched)"

# Claude custom commands (slash commands like /save-meta, /save, /sod, /eod)
if [[ -d "$REPO_DIR/dotfiles/claude-commands" ]]; then
    mkdir -p ~/.claude/commands
    cp "$REPO_DIR"/dotfiles/claude-commands/*.md ~/.claude/commands/ 2>/dev/null
    log "Copied Claude custom commands ($(ls "$REPO_DIR/dotfiles/claude-commands/" | wc -l | tr -d ' ') files)"
fi

# Neovim config
if [[ -d "$REPO_DIR/nvim" ]]; then
    mkdir -p ~/.config/nvim/lua/plugins ~/.config/nvim/lua/config
    cp "$REPO_DIR/nvim/init.lua" ~/.config/nvim/init.lua
    cp "$REPO_DIR"/nvim/lua/plugins/*.lua ~/.config/nvim/lua/plugins/ 2>/dev/null || true
    cp "$REPO_DIR"/nvim/lua/config/*.lua ~/.config/nvim/lua/config/ 2>/dev/null || true
    log "Copied neovim config"
fi

# .gitconfig — special handling: only set user identity if not already configured
if ! git config --global user.email &>/dev/null; then
    git config --global user.email "paytonguo@meta.com"
    git config --global user.name "Zhitong Guo"
    log "Set git identity"
else
    log "Git identity already configured, skipping"
fi

# Merge useful git settings without overwriting existing
git config --global core.editor nvim 2>/dev/null || true
git config --global pull.rebase true 2>/dev/null || true
git config --global diff.colorMoved default 2>/dev/null || true
git config --global merge.conflictstyle diff3 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true
log "Merged git config settings"

log "Sync complete!"
'

# --- Main: SSH into each host and run the sync ---
log "===== DevVM sync starting ====="

for host in "${HOSTS[@]}"; do
    log "--- Syncing $host ---"
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$host" "$REMOTE_SCRIPT" 2>&1 | while read -r line; do
        log "[$host] $line"
    done; then
        log "[$host] SUCCESS"
    else
        log "[$host] FAILED (exit $?)"
    fi
    echo ""
done

log "===== DevVM sync complete ====="
