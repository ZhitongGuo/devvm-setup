#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[→]${NC} $*"; }
fail() { echo -e "${RED}[✗]${NC} $*"; }

echo "============================================"
echo "  macOS Setup — Homebrew Bootstrap Script"
echo "============================================"
echo ""

# ─── Phase 1: Homebrew ───────────────────────────────────────────────────────
echo "── Phase 1: Homebrew ──"
if command -v brew &>/dev/null; then
    log "Homebrew already installed"
else
    warn "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi
echo ""

# ─── Phase 2: Brew packages ─────────────────────────────────────────────────
echo "── Phase 2: Brew packages ──"
BREW_PKGS=(
    # Shell & Navigation
    bat eza fd fzf ripgrep zoxide fish
    # Editors & Multiplexers
    neovim helix tmux zellij
    # System Monitoring
    btop bottom dust duf htop ncdu procs
    # Development & Git
    lazygit git-delta gh tig jq yq glow broot
    # Networking & HTTP
    xh wget curl
    # Misc
    tree starship
)

for pkg in "${BREW_PKGS[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        log "$pkg already installed"
    else
        warn "Installing $pkg..."
        brew install "$pkg" || fail "$pkg failed to install"
    fi
done
echo ""

# ─── Phase 3: Oh-My-Zsh + plugins ───────────────────────────────────────────
echo "── Phase 3: Oh-My-Zsh + plugins ──"
if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh-My-Zsh already installed"
else
    warn "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log "zsh-autosuggestions already installed"
else
    warn "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log "zsh-syntax-highlighting already installed"
else
    warn "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
echo ""

# ─── Phase 4: NVM + Node ────────────────────────────────────────────────────
echo "── Phase 4: NVM + Node ──"
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    log "NVM already installed"
else
    warn "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Source nvm so we can use it
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if nvm ls --no-colors 2>/dev/null | grep -q "lts"; then
    log "Node $(node --version) already installed via NVM"
else
    warn "Installing Node LTS..."
    nvm install --lts
fi

# tldr — simplified man pages
if command -v tldr &>/dev/null; then
    log "tldr already installed"
else
    warn "Installing tldr via npm..."
    npm install -g tldr
fi
echo ""

# ─── Phase 5: Dotfiles ──────────────────────────────────────────────────────
echo "── Phase 5: Dotfiles ──"
bash "$SCRIPT_DIR/install-dotfiles.sh"
echo ""

# ─── Verify ─────────────────────────────────────────────────────────────────
echo "── Verification ──"
VERIFY_CMDS=(bat eza fd fzf rg zoxide nvim gh fish btop hx zellij delta tmux htop ncdu tree jq wget curl tig lazygit glow duf yq tldr xh btm dust procs broot starship)
PASS=0
TOTAL=${#VERIFY_CMDS[@]}
for cmd in "${VERIFY_CMDS[@]}"; do
    if command -v "$cmd" &>/dev/null; then
        log "$cmd"
        PASS=$((PASS + 1))
    else
        fail "$cmd not found"
    fi
done
echo ""
echo "$PASS/$TOTAL tools verified"
echo ""

# ─── Done ────────────────────────────────────────────────────────────────────
echo "============================================"
echo "  Setup complete!"
echo ""
echo "  Next steps:"
echo "    1. source ~/.zshrc"
echo "    2. ./dev-session.sh          # launch tmux dev session"
echo "    3. ./claude-code-setup.sh    # configure Claude Code plugins"
echo ""
echo "  Optional:"
echo "    - brew install --cask ghostty  # GPU-accelerated terminal"
echo "    - gh auth login               # GitHub CLI auth"
echo "============================================"
