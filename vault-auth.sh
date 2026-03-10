#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[ok]${NC} $*"; }
warn() { echo -e "${YELLOW}[->]${NC} $*"; }
fail() { echo -e "${RED}[!!]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }

echo "============================================"
echo "  MetaVault — Google Drive Auth Setup"
echo "============================================"
echo ""

# Ensure proxy is set
export http_proxy="http://fwdproxy:8080"
export https_proxy="http://fwdproxy:8080"
export no_proxy=".fbcdn.net,.facebook.com,.thefacebook.com,.tfbnw.net,.fb.com,.fburl.com,.facebook.net,.sb.fbsbx.com,localhost,127.0.0.1"

# Check mclone
if ! command -v mclone &>/dev/null; then
    fail "mclone not found. Run: devfeature install mclone"
    exit 1
fi

# Check if already configured with a valid token
if mclone listremotes 2>/dev/null | grep -q "^gdrive:" && \
   grep -q "token" ~/.config/rclone/rclone.conf 2>/dev/null; then
    log "gdrive remote already configured with a token"
    echo ""
    # Quick connectivity test
    warn "Testing connectivity..."
    if mclone lsd gdrive: --max-depth 1 2>/dev/null | head -3; then
        log "Google Drive is accessible"
        echo ""
        echo "Run 'mount-vault' to mount, or open a new shell for auto-mount."
        exit 0
    else
        warn "Token may be expired. Continuing with re-auth..."
        mclone config delete gdrive 2>/dev/null || true
    fi
fi

# Delete broken remote if it exists without a token
if mclone listremotes 2>/dev/null | grep -q "^gdrive:"; then
    warn "Removing existing gdrive remote (no valid token)..."
    mclone config delete gdrive 2>/dev/null || true
fi

echo ""
info "This is a two-machine flow (devserver has no browser)."
echo ""
echo "  Step 1: Run 'mclone config' below — answer the prompts"
echo "  Step 2: When it prints an 'rclone authorize ...' command,"
echo "          run that on your LAPTOP with mclone or rclone:"
echo ""
echo "          # On Mac: brew install rclone  (if not installed)"
echo "          mclone authorize \"drive\" \"<token-string>\""
echo ""
echo "          This opens a browser — authorize with your Meta Google account."
echo "          It will print a JSON token to paste back here."
echo "  Step 3: Paste the token back here"
echo ""
info "Key answers during config:"
echo "    - Storage type:      drive"
echo "    - client_id:         (leave blank)"
echo "    - client_secret:     (leave blank)"
echo "    - scope:             drive"
echo "    - root_folder_id:    (leave blank for My Drive)"
echo "    - service_account:   (leave blank)"
echo "    - Advanced config:   n"
echo "    - Use auto config:   n  <-- CRITICAL (say No)"
echo "    - Shared Drive:      n  (unless using a Team Drive)"
echo ""
read -rp "Press Enter to start mclone config..."

mkdir -p ~/.config/rclone

mclone config

echo ""
# Verify it worked
if mclone listremotes 2>/dev/null | grep -q "^gdrive:" && \
   grep -q "token" ~/.config/rclone/rclone.conf 2>/dev/null; then
    log "gdrive remote configured successfully!"
    echo ""
    warn "Testing connectivity..."
    if mclone lsd gdrive: --max-depth 1 2>/dev/null | head -5; then
        log "Google Drive is accessible"
    else
        warn "Connectivity test failed — token may need a moment to propagate"
    fi
    echo ""
    echo "  Next: open a new shell (auto-mount), or run 'mount-vault'"
    echo ""
    # Sync config to other devservers via dotsync2
    if command -v dotsync2 &>/dev/null; then
        warn "Pushing rclone config to dotsync2..."
        dotsync2 push 2>&1 | tail -2
        log "Config synced — other devservers will pick it up on next dotsync2 pull"
    fi
else
    fail "gdrive remote was not configured. Please try again."
    exit 1
fi
