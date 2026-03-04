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
echo "  DevVM Setup — Idempotent Bootstrap Script"
echo "============================================"
echo ""

# ─── Phase 1: DevFeature packages ────────────────────────────────────────────
echo "── Phase 1: DevFeature packages ──"
DEVFEATURE_PKGS=(bat eza fd fzf ripgrep zoxide neovim fwdproxy fish btop helix zellij)
for pkg in "${DEVFEATURE_PKGS[@]}"; do
    if devfeature list 2>/dev/null | grep -q "^${pkg}\b"; then
        log "$pkg already installed (devfeature)"
    else
        warn "Installing $pkg via devfeature..."
        devfeature install "$pkg" || fail "$pkg failed to install via devfeature"
    fi
done
echo ""

# ─── Phase 2: System packages (dnf) ─────────────────────────────────────────
echo "── Phase 2: System packages (dnf) ──"
DNF_PKGS=(git-delta tmux htop ncdu tree jq wget curl tig)
for pkg in "${DNF_PKGS[@]}"; do
    if rpm -q "$pkg" &>/dev/null || command -v "$pkg" &>/dev/null; then
        log "$pkg already installed"
    else
        warn "Installing $pkg via dnf..."
        sudo dnf install -y "$pkg"
    fi
done
echo ""

# ─── Phase 3: Binary installs (go, npm, pip, direct download) ───────────────
echo "── Phase 3: Tools via binary install ──"
mkdir -p ~/.local/bin

# Ensure ~/.local/bin is in PATH for this session
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# lazygit — git TUI (Go)
if command -v lazygit &>/dev/null; then
    log "lazygit already installed"
else
    warn "Installing lazygit via go install..."
    GOBIN=~/.local/bin go install github.com/jesseduffield/lazygit@latest
fi

# glow — markdown renderer (Go)
if command -v glow &>/dev/null; then
    log "glow already installed"
else
    warn "Installing glow via go install..."
    GOBIN=~/.local/bin go install github.com/charmbracelet/glow@latest
fi

# duf — disk usage / better df (Go)
if command -v duf &>/dev/null; then
    log "duf already installed"
else
    warn "Installing duf via go install..."
    GOBIN=~/.local/bin go install github.com/muesli/duf@latest
fi

# yq — YAML/XML/TOML processor (Go)
if command -v yq &>/dev/null; then
    log "yq already installed"
else
    warn "Installing yq via go install..."
    GOBIN=~/.local/bin go install github.com/mikefarah/yq/v4@latest
fi

# tldr — simplified man pages (npm)
if command -v tldr &>/dev/null; then
    log "tldr already installed"
else
    warn "Installing tldr via npm..."
    npm install --prefix ~/.local/lib tldr
    ln -sf ~/.local/lib/node_modules/.bin/tldr ~/.local/bin/tldr
fi

# xh — httpie-compatible HTTP client (binary, since pip is blocked on devvms)
if command -v http &>/dev/null || command -v xh &>/dev/null; then
    log "xh/httpie already installed"
else
    warn "Installing xh (httpie-compatible)..."
    XH_VER="0.24.1"
    with-proxy curl -fsSL "https://github.com/ducaale/xh/releases/download/v${XH_VER}/xh-v${XH_VER}-x86_64-unknown-linux-musl.tar.gz" -o /tmp/xh.tar.gz
    tar xzf /tmp/xh.tar.gz -C /tmp
    mv "/tmp/xh-v${XH_VER}-x86_64-unknown-linux-musl/xh" ~/.local/bin/xh
    ln -sf ~/.local/bin/xh ~/.local/bin/http
    chmod +x ~/.local/bin/xh
    rm -rf /tmp/xh.tar.gz "/tmp/xh-v${XH_VER}-x86_64-unknown-linux-musl"
fi

# bottom (btm) — system monitor (binary)
if command -v btm &>/dev/null; then
    log "bottom (btm) already installed"
else
    warn "Installing bottom..."
    with-proxy curl -fsSL "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" | tar xz -C ~/.local/bin btm
    chmod +x ~/.local/bin/btm
fi

# dust — disk usage analyzer (binary)
if command -v dust &>/dev/null; then
    log "dust already installed"
else
    warn "Installing dust..."
    DUST_VER="1.2.4"
    with-proxy curl -fsSL "https://github.com/bootandy/dust/releases/download/v${DUST_VER}/dust-v${DUST_VER}-x86_64-unknown-linux-gnu.tar.gz" -o /tmp/dust.tar.gz
    tar xzf /tmp/dust.tar.gz -C /tmp
    mv "/tmp/dust-v${DUST_VER}-x86_64-unknown-linux-gnu/dust" ~/.local/bin/dust
    rm -rf /tmp/dust.tar.gz "/tmp/dust-v${DUST_VER}-x86_64-unknown-linux-gnu"
    chmod +x ~/.local/bin/dust
fi

# procs — modern ps replacement (binary)
if command -v procs &>/dev/null; then
    log "procs already installed"
else
    warn "Installing procs..."
    PROCS_VER="0.14.8"
    with-proxy curl -fsSL "https://github.com/dalance/procs/releases/download/v${PROCS_VER}/procs-v${PROCS_VER}-x86_64-linux.zip" -o /tmp/procs.zip
    unzip -o /tmp/procs.zip -d ~/.local/bin/ && rm -f /tmp/procs.zip
    chmod +x ~/.local/bin/procs
fi

# broot — interactive tree view (binary)
if command -v broot &>/dev/null; then
    log "broot already installed"
else
    warn "Installing broot..."
    with-proxy curl -fsSL "https://dystroy.org/broot/download/x86_64-linux/broot" -o ~/.local/bin/broot
    chmod +x ~/.local/bin/broot
fi

# gh — GitHub CLI (binary, devfeature fbpkg may not resolve)
if command -v gh &>/dev/null; then
    log "gh already installed"
else
    warn "Installing gh CLI..."
    GH_VER="2.65.0"
    with-proxy curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VER}/gh_${GH_VER}_linux_amd64.tar.gz" -o /tmp/gh.tar.gz
    tar xzf /tmp/gh.tar.gz -C /tmp
    mv "/tmp/gh_${GH_VER}_linux_amd64/bin/gh" ~/.local/bin/gh
    chmod +x ~/.local/bin/gh
    rm -rf /tmp/gh.tar.gz "/tmp/gh_${GH_VER}_linux_amd64"
fi

warn "Ensure ~/.local/bin is in your PATH"
echo ""

# ─── Phase 4: Oh-My-Zsh + plugins ───────────────────────────────────────────
echo "── Phase 4: Oh-My-Zsh + plugins ──"
if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh-My-Zsh already installed"
else
    warn "Installing Oh-My-Zsh..."
    sh -c "$(with-proxy curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

# ─── Phase 5: NVM + Node ────────────────────────────────────────────────────
echo "── Phase 5: NVM + Node ──"
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    log "NVM already installed"
else
    warn "Installing NVM..."
    with-proxy curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Source nvm so we can use it
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v node &>/dev/null; then
    log "Node $(node --version) already installed"
else
    warn "Installing Node LTS..."
    nvm install --lts
fi
echo ""

# ─── Phase 6: Starship prompt ───────────────────────────────────────────────
echo "── Phase 6: Starship prompt ──"
if command -v starship &>/dev/null; then
    log "Starship already installed"
else
    warn "Installing Starship..."
    with-proxy curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi
echo ""

# ─── Phase 7: Dotfiles ──────────────────────────────────────────────────────
echo "── Phase 7: Dotfiles ──"
bash "$SCRIPT_DIR/install-dotfiles.sh"
echo ""

# ─── Verify ─────────────────────────────────────────────────────────────────
echo "── Verification ──"
VERIFY_CMDS=(bat eza fd fzf rg zoxide nvim gh fish btop hx zellij delta tmux htop ncdu tree jq wget curl tig lazygit glow duf yq tldr http btm dust procs broot starship)
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
echo "  Manual steps:"
echo "    - SSH keys: ssh-keygen -t ed25519"
echo "    - Git certs: update ~/.gitconfig with your certs"
echo "============================================"
