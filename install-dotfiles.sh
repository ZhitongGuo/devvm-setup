#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[→]${NC} $*"; }

backup_and_link() {
    local src="$1"
    local dest="$2"

    # If dest is already a symlink pointing to src, skip
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
        log "$(basename "$dest") already linked"
        return
    fi

    # Backup existing file if it exists and is not a symlink
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$BACKED_UP" = false ]; then
            mkdir -p "$BACKUP_DIR"
            BACKED_UP=true
            warn "Backing up existing files to $BACKUP_DIR/"
        fi
        mv "$dest" "$BACKUP_DIR/"
        warn "Backed up $(basename "$dest")"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    ln -sf "$src" "$dest"
    log "Linked $(basename "$dest") → $src"
}

echo "── Installing dotfiles ──"

# Standard dotfiles → ~/
backup_and_link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
backup_and_link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
backup_and_link "$DOTFILES_DIR/.vimrc"        "$HOME/.vimrc"

# Multi-agent profiles → ~/
backup_and_link "$DOTFILES_DIR/engineer.md"    "$HOME/engineer.md"
backup_and_link "$DOTFILES_DIR/manager.md"     "$HOME/manager.md"
backup_and_link "$DOTFILES_DIR/reviewer.md"    "$HOME/reviewer.md"

# Config files → ~/.config/
backup_and_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# Claude Code → ~/.claude/
backup_and_link "$DOTFILES_DIR/CLAUDE.md"    "$HOME/.claude/CLAUDE.md"

# Neovim → ~/.config/nvim/
backup_and_link "$SCRIPT_DIR/nvim/init.lua"   "$HOME/.config/nvim/init.lua"

# Neovim plugin configs → ~/.config/nvim/lua/plugins/
mkdir -p "$HOME/.config/nvim/lua/plugins"
for f in "$SCRIPT_DIR"/nvim/lua/plugins/*.lua; do
    [ -f "$f" ] && backup_and_link "$f" "$HOME/.config/nvim/lua/plugins/$(basename "$f")"
done

# Neovim core configs → ~/.config/nvim/lua/config/
mkdir -p "$HOME/.config/nvim/lua/config"
for f in "$SCRIPT_DIR"/nvim/lua/config/*.lua; do
    [ -f "$f" ] && backup_and_link "$f" "$HOME/.config/nvim/lua/config/$(basename "$f")"
done

if [ "$BACKED_UP" = true ]; then
    echo ""
    warn "Backups saved to: $BACKUP_DIR/"
fi

log "Dotfiles installation complete"
