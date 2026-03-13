#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[→]${NC} $*"; }

echo "============================================"
echo "  Claude Code — Plugin & Settings Setup"
echo "============================================"
echo ""

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"

# ─── Install claude-templates plugins ────────────────────────────────────────
echo "── Installing claude-templates plugins ──"
TEMPLATE_PLUGINS=(
    10x-engineer
    chat-notifications
    meta-statusline-pro
    source-control-at-meta
    tmux-statusline
)

for plugin in "${TEMPLATE_PLUGINS[@]}"; do
    if claude plugin list 2>/dev/null | grep -q "$plugin@claude-templates"; then
        log "$plugin already installed"
    else
        warn "Installing $plugin..."
        claude plugin add "$plugin@claude-templates" 2>/dev/null || true
    fi
done
echo ""

# ─── Meta org plugins ───────────────────────────────────────────────────────
echo "── Meta org plugins ──"
echo "The following Meta org plugins auto-install on first claude launch:"
META_PLUGINS=(meta meta_codesearch meta_knowledge code_provenance llm-rules trajectory)
for plugin in "${META_PLUGINS[@]}"; do
    log "$plugin@Meta (auto-installed)"
done
echo ""

# ─── Write settings.json ────────────────────────────────────────────────────
echo "── Writing settings.json ──"
if [ -f "$SETTINGS_FILE" ]; then
    warn "Backing up existing settings to $SETTINGS_FILE.bak"
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
fi

cp "$SCRIPT_DIR/dotfiles/claude-settings.json" "$SETTINGS_FILE"

log "Settings written to $SETTINGS_FILE"
echo ""

echo "============================================"
echo "  Claude Code setup complete!"
echo "  Run 'claude' to verify plugins load."
echo "============================================"
