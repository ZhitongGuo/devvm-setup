#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# DevVM Setup — Interactive Self-Narrating Demo
# Run this during the knowledge share to showcase each tool.
# Press ENTER to advance between steps. Press Ctrl-C to exit.
#
# Each section has 3 parts:
#   1. CONTEXT  — what the tool is and why it matters (printed on screen)
#   2. DEMO     — live command output
#   3. EXPLORE  — commands the audience can try on their own
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# ─── Colors & helpers ────────────────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'

DEMO_DIR=$(mktemp -d /tmp/devvm-demo-XXXX)
trap 'rm -rf "$DEMO_DIR"' EXIT

pause() {
    echo ""
    echo -e "${DIM}  ── press ENTER to continue ──${NC}"
    read -r
}

section() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}  ║  $1$(printf '%*s' $((46 - ${#1})) '')║${NC}"
    echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

narrate() {
    # Print talking point — what the presenter says out loud
    echo -e "  ${WHITE}$*${NC}"
}

detail() {
    # Print a supporting detail line
    echo -e "  ${DIM}$*${NC}"
}

explore_header() {
    echo ""
    echo -e "  ${BLUE}┌─ Explore on your own ─────────────────────────────┐${NC}"
}

explore() {
    echo -e "  ${BLUE}│${NC}  ${GREEN}$*${NC}"
}

explore_footer() {
    echo -e "  ${BLUE}└───────────────────────────────────────────────────┘${NC}"
}

run() {
    echo -e "  ${YELLOW}\$${NC} ${GREEN}$*${NC}"
    echo ""
    eval "$@" 2>&1 | sed 's/^/    /'
    echo ""
}

compare() {
    local old_cmd="$1"
    local new_cmd="$2"
    local old_label="$3"
    local new_label="$4"
    echo -e "  ${DIM}${old_label}:${NC}"
    echo -e "  ${YELLOW}\$${NC} ${DIM}${old_cmd}${NC}"
    eval "$old_cmd" 2>&1 | head -8 | sed 's/^/    /'
    echo ""
    echo -e "  ${BOLD}${new_label}:${NC}"
    echo -e "  ${YELLOW}\$${NC} ${GREEN}${new_cmd}${NC}"
    echo ""
    eval "$new_cmd" 2>&1 | head -15 | sed 's/^/    /'
    echo ""
}

# ─── Prepare demo files ─────────────────────────────────────────────────────
mkdir -p "$DEMO_DIR/src/components" "$DEMO_DIR/src/utils" "$DEMO_DIR/docs"
cat > "$DEMO_DIR/src/main.py" << 'PYEOF'
#!/usr/bin/env python3
"""DevVM Demo — Sample Python file."""
import os
import json
from pathlib import Path

def load_config(path: str) -> dict:
    """Load configuration from a JSON file."""
    config_path = Path(path)
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {path}")
    with open(config_path) as f:
        return json.load(f)

def setup_environment(config: dict) -> None:
    """Apply environment variables from config."""
    for key, value in config.get("env", {}).items():
        os.environ[key] = str(value)
        print(f"  Set {key}={value}")

class DevServer:
    """A simple development server."""
    def __init__(self, host="localhost", port=8080):
        self.host = host
        self.port = port
        self.running = False

    def start(self):
        self.running = True
        print(f"Server started on {self.host}:{self.port}")

    def stop(self):
        self.running = False
        print("Server stopped")

if __name__ == "__main__":
    config = load_config("config.json")
    setup_environment(config)
    server = DevServer()
    server.start()
PYEOF

cat > "$DEMO_DIR/src/utils/helpers.js" << 'JSEOF'
// Helper utilities
export function debounce(fn, delay) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

export function formatDate(date) {
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric', month: 'short', day: 'numeric'
  }).format(date);
}

// TODO: add throttle function
// FIXME: formatDate doesn't handle timezones
JSEOF

cat > "$DEMO_DIR/config.json" << 'JSONEOF'
{
  "env": {
    "NODE_ENV": "development",
    "PORT": 3000,
    "DEBUG": true
  },
  "features": {
    "dark_mode": true,
    "notifications": false,
    "beta_features": ["ai_assist", "live_collab"]
  }
}
JSONEOF

cat > "$DEMO_DIR/README.md" << 'MDEOF'
# Demo Project

A sample project for the **DevVM Setup** knowledge share.

## Features
- Fast development server
- Hot module reloading
- AI-powered code assist

## Getting Started
```bash
./setup.sh && source ~/.zshrc
```

> This is a blockquote with some *italic* and **bold** text.
MDEOF

# ═════════════════════════════════════════════════════════════════════════════
# DEMO START
# ═════════════════════════════════════════════════════════════════════════════

# ─── 0. Title ────────────────────────────────────────────────────────────────
section "DevVM Setup — Knowledge Share Demo"
narrate "One script to bootstrap a full dev environment on a fresh devvm."
narrate "Everything you see today installs automatically with ./setup.sh."
echo ""
echo -e "  ${MAGENTA}32 tools${NC} installed via: devfeature, dnf, go, npm, binary"
echo -e "  ${MAGENTA}17 dotfiles${NC} symlinked with automatic backup"
echo -e "  ${MAGENTA}Idempotent${NC} — safe to re-run anytime"
echo ""
narrate "Let's walk through the tools and see why they're worth switching to."
pause

# ─── 1. Ghostty ──────────────────────────────────────────────────────────────
section "1. Ghostty — GPU-Accelerated Terminal"
narrate "Before we look at CLI tools, let's talk about the terminal itself."
narrate "Ghostty is a GPU-accelerated terminal emulator — it's what renders"
narrate "everything you're about to see. Fast, native, no Electron."
echo ""
echo -e "  ${BOLD}Why Ghostty over iTerm2/Terminal.app/Alacritty?${NC}"
detail "  GPU rendering  — no lag even with heavy output (btop, lazygit)"
detail "  Native UI      — not Electron, feels like a real Mac app"
detail "  Nerd Fonts     — first-class ligatures and icon support"
detail "  Image protocol — view images inline (Kitty protocol)"
detail "  Low latency    — input feels instant"
echo ""
echo -e "  ${BOLD}Install (on your Mac):${NC}"
echo -e "    ${GREEN}brew install --cask ghostty${NC}"
echo ""
echo -e "  ${BOLD}Recommended config (${DIM}~/.config/ghostty/config${NC}${BOLD}):${NC}"
echo -e "    ${DIM}font-family = JetBrains Mono${NC}"
echo -e "    ${DIM}font-size = 14${NC}"
echo -e "    ${DIM}theme = tokyonight${NC}"
echo -e "    ${DIM}cursor-style = block${NC}"
echo -e "    ${DIM}shell-integration = zsh${NC}"
explore_header
explore "brew install --cask ghostty"
explore "open https://ghostty.org"
explore "ghostty +show-config            # see all config options"
explore_footer
pause

# ─── 2. eza vs ls ────────────────────────────────────────────────────────────
section "2. eza — Modern ls replacement"
narrate "How many times a day do you type 'ls'? Now look at the difference."
narrate "eza adds icons, colors, git status, and tree view — all built in."
narrate "In my .zshrc, 'ls' is aliased to 'eza --icons' — zero friction."
echo ""
compare \
    "/bin/ls -la $DEMO_DIR" \
    "eza -la --icons --git $DEMO_DIR" \
    "Old: ls -la" \
    "New: eza -la --icons --git"
pause

narrate "It also does tree views — replaces 'tree' + 'find' in one command."
echo ""
run "eza --tree --icons --level=3 $DEMO_DIR"
explore_header
explore "eza -la --icons --git             # daily driver"
explore "eza --tree --level=2              # tree view"
explore "eza -la --sort=modified           # sort by time"
explore "eza --git-ignore --tree           # respect .gitignore"
explore_footer
pause

# ─── 3. bat vs cat ──────────────────────────────────────────────────────────
section "3. bat — cat with syntax highlighting"
narrate "Same upgrade for 'cat'. bat gives you syntax highlighting and"
narrate "line numbers instantly. It auto-detects the language."
narrate "I alias 'cat' to 'bat' — works as a drop-in replacement."
echo ""
compare \
    "cat $DEMO_DIR/src/main.py" \
    "bat --style=full --paging=never $DEMO_DIR/src/main.py" \
    "Old: cat" \
    "New: bat"
explore_header
explore "bat src/main.py                   # syntax highlighting"
explore "bat -d file.py                    # diff markers only"
explore "bat --style=numbers file.py       # line numbers only"
explore "export MANPAGER=\"sh -c 'col -bx | bat -l man -p'\""
explore_footer
pause

# ─── 4. fd vs find ──────────────────────────────────────────────────────────
section "4. fd — Faster, friendlier find"
narrate "The 'find' command is powerful but the syntax is painful."
narrate "fd makes it simple — extension flags, recursive by default,"
narrate "and it respects .gitignore automatically."
echo ""
compare \
    "find $DEMO_DIR -name '*.py' -type f" \
    "fd -e py . $DEMO_DIR" \
    "Old: find -name '*.py'" \
    "New: fd -e py"
echo ""
echo -e "  ${BOLD}Find all config files:${NC}"
run "fd -e json -e toml . $DEMO_DIR"
explore_header
explore "fd -e py                          # find Python files"
explore "fd -e js -x wc -l                 # count lines in each JS file"
explore "fd -H '.env'                      # include hidden files"
explore "fd -e py | xargs rg 'TODO'        # chain with ripgrep"
explore_footer
pause

# ─── 5. ripgrep vs grep ─────────────────────────────────────────────────────
section "5. ripgrep — Blazingly fast grep"
narrate "ripgrep is what VS Code uses under the hood for search."
narrate "It's 5-10x faster than grep — and on fbsource with millions"
narrate "of files, that speed difference is real."
echo ""
compare \
    "grep -rn 'config' $DEMO_DIR --include='*.py'" \
    "rg 'config' $DEMO_DIR" \
    "Old: grep -rn" \
    "New: rg"
echo ""
narrate "Use -C for context lines around matches:"
echo ""
run "rg -C2 'def ' $DEMO_DIR/src/main.py"
explore_header
explore "rg 'pattern'                      # recursive search"
explore "rg -t py 'TODO'                   # filter by file type"
explore "rg -C3 'error'                    # 3 lines of context"
explore "rg -l 'import' | head             # files only (no content)"
explore_footer
pause

# ─── 6. fzf ─────────────────────────────────────────────────────────────────
section "6. fzf — Fuzzy finder"
narrate "fzf is the glue that makes everything interactive."
narrate "It's a fuzzy filter you can pipe anything into."
narrate "The real power is the shell key bindings."
echo ""
echo -e "  ${BOLD}Shell key bindings (built into your zshrc):${NC}"
echo -e "    ${GREEN}Ctrl-R${NC}   fuzzy search command history"
echo -e "    ${GREEN}Ctrl-T${NC}   fuzzy find a file, paste the path"
echo -e "    ${GREEN}Alt-C${NC}    fuzzy cd into a subdirectory"
echo ""
narrate "You can also pipe anything into fzf:"
echo ""
run "fd . $DEMO_DIR | fzf --height=10 --select-1 --exit-0 -q 'main'"
explore_header
explore "Ctrl-R                            # try this NOW in your shell"
explore "ps aux | fzf                      # fuzzy find processes"
explore "git log --oneline | fzf           # pick a commit"
explore "rg -l 'TODO' | fzf               # pick from files with TODOs"
explore_footer
pause

# ─── 7. zoxide ───────────────────────────────────────────────────────────────
section "7. zoxide — Smarter cd"
narrate "zoxide learns which directories you visit most."
narrate "Instead of 'cd ~/long/path/to/project', just type 'z project'."
narrate "It uses frecency — frequency + recency — to rank results."
echo ""
echo -e "  ${BOLD}How it works:${NC}"
echo -e "    ${GREEN}z foo${NC}         jump to best match for 'foo'"
echo -e "    ${GREEN}z src comp${NC}    match dirs containing BOTH 'src' and 'comp'"
echo -e "    ${GREEN}zi${NC}            interactive fzf picker"
echo ""
echo -e "  ${BOLD}Current frecency database:${NC}"
run "zoxide query --list 2>/dev/null | head -10 || echo '  (builds as you cd around)'"
explore_header
explore "z project                         # jump to ~/project"
explore "z fb src                          # jump to fbsource/..."
explore "zi                                # interactive picker"
explore "zoxide query --list               # see full database"
explore_footer
pause

# ─── 8. delta ────────────────────────────────────────────────────────────────
section "8. git-delta — Beautiful diffs"
narrate "If you review diffs in the terminal, delta makes them readable."
narrate "Syntax highlighting, word-level diffs, line numbers on both sides."
narrate "Just set it as your git pager and every 'git diff' is upgraded."
echo ""
echo -e "  ${BOLD}Example diff (piped through delta):${NC}"
echo '--- a/main.py
+++ b/main.py
@@ -5,7 +5,8 @@
 from pathlib import Path

 def load_config(path: str) -> dict:
-    """Load configuration from a JSON file."""
+    """Load and validate configuration from a JSON file."""
     config_path = Path(path)
     if not config_path.exists():
         raise FileNotFoundError(f"Config not found: {path}")
+    print(f"Loading config from {path}")' | delta --paging=never 2>/dev/null | sed 's/^/    /' || echo "    (delta renders colored diffs — best seen in a real terminal)"
explore_header
explore "git diff | delta                  # pipe any diff through delta"
explore "git log -p --follow file.py       # git log with delta"
explore "delta --side-by-side              # side-by-side mode"
explore "git config core.pager delta       # make it permanent"
explore_footer
pause

# ─── 9. jq + yq ─────────────────────────────────────────────────────────────
section "9. jq & yq — Structured data tools"
narrate "Two essential tools for config files and API responses."
narrate "jq handles JSON, yq handles YAML/TOML/XML."
narrate "Think of jq as 'sed for structured data'."
echo ""
echo -e "  ${BOLD}jq — extract nested values:${NC}"
run "cat $DEMO_DIR/config.json | jq '.features.beta_features'"
echo -e "  ${BOLD}jq — reshape into new objects:${NC}"
run "cat $DEMO_DIR/config.json | jq '{port: .env.PORT, debug: .env.DEBUG}'"
echo -e "  ${BOLD}yq — convert JSON to YAML:${NC}"
run "cat $DEMO_DIR/config.json | yq -P"
explore_header
explore "curl api | jq '.data[0].name'     # parse API responses"
explore "jq -r '.env | keys[]' config.json # extract keys"
explore "yq '.field' config.yaml           # query YAML files"
explore "yq -P < file.json > file.yaml     # JSON to YAML"
explore_footer
pause

# ─── 10. glow ────────────────────────────────────────────────────────────────
section "10. glow — Render markdown in terminal"
narrate "Quick one — glow renders markdown beautifully in the terminal."
narrate "Great for reading READMEs without leaving your shell."
echo ""
run "glow $DEMO_DIR/README.md"
explore_header
explore "glow README.md                    # render any markdown"
explore "glow https://url/to/README.md     # render from URL"
explore "glow -p README.md                 # pager mode"
explore_footer
pause

# ─── 11. dust + duf ─────────────────────────────────────────────────────────
section "11. dust & duf — Disk usage tools"
narrate "Two tools for understanding disk usage."
narrate "dust shows a visual bar chart of file sizes."
narrate "duf shows mounted filesystems with usage bars."
echo ""
echo -e "  ${BOLD}dust — intuitive disk usage (replaces du -sh | sort):${NC}"
run "dust -n 8 $DEMO_DIR"
echo -e "  ${BOLD}duf — filesystem overview:${NC}"
run "duf --only local 2>/dev/null || duf 2>/dev/null | head -15"
explore_header
explore "dust ~/                           # where's my disk space?"
explore "dust -n 20 /tmp                   # top 20 entries"
explore "duf                               # all filesystems"
explore_footer
pause

# ─── 12. procs ───────────────────────────────────────────────────────────────
section "12. procs — Modern ps replacement"
narrate "procs is ps with colors, tree view, and search."
narrate "Much easier to scan than ps aux | grep."
echo ""
run "procs --tree zsh 2>/dev/null | head -20 || procs zsh 2>/dev/null | head -15"
explore_header
explore "procs                             # all processes, colored"
explore "procs --tree                      # process tree"
explore "procs zsh                         # search by name"
explore "procs --sortd cpu                 # sort by CPU descending"
explore_footer
pause

# ─── 13. xh ─────────────────────────────────────────────────────────────────
section "13. xh — Human-friendly HTTP client"
narrate "xh is an httpie-compatible HTTP client — curl for humans."
narrate "Colored output, auto-formatted JSON, simple POST syntax."
echo ""
echo -e "  ${BOLD}Syntax comparison:${NC}"
echo -e "    ${DIM}curl -s https://httpbin.org/json | jq .${NC}   (old)"
echo -e "    ${GREEN}xh httpbin.org/json${NC}                       (new)"
echo ""
echo -e "  ${BOLD}POST is just key=value:${NC}"
echo -e "    ${GREEN}xh POST api.example.com name=demo type=test${NC}"
echo ""
detail "(Skipping live HTTP on devvm — try it yourself!)"
explore_header
explore "xh httpbin.org/json               # GET with colors"
explore "xh POST api.example.com key=val   # POST JSON body"
explore "xh -d url > file                  # download"
explore "xh --help                         # full options"
explore_footer
pause

# ─── 14. tldr ────────────────────────────────────────────────────────────────
section "14. tldr — Simplified man pages"
narrate "tldr gives you practical examples instead of dense man pages."
narrate "When you forget tar flags for the 100th time — this saves minutes."
echo ""
run "tldr tar 2>/dev/null || echo '  Run: tldr --update && tldr tar'"
explore_header
explore "tldr tar                          # how do tar flags work?"
explore "tldr git-rebase                   # common rebase patterns"
explore "tldr curl                         # curl examples"
explore "tldr ffmpeg                       # the one you always forget"
explore_footer
pause

# ─── 15. btop + bottom ──────────────────────────────────────────────────────
section "15. btop & bottom — System monitors"
narrate "For system monitoring, btop and bottom are beautiful replacements"
narrate "for htop. Both show CPU, memory, disk, and network."
narrate "Won't launch them since they take over the terminal."
echo ""
echo -e "  ${BOLD}Available monitors:${NC}"
echo -e "    ${GREEN}btop${NC}    full TUI — CPU graphs, memory bars, disk I/O, network"
echo -e "    ${GREEN}btm${NC}     lightweight with a widget-based layout"
echo -e "    ${GREEN}htop${NC}    the classic — still great"
explore_header
explore "btop                              # the gorgeous one"
explore "btm                               # lightweight alternative"
explore "htop                              # the classic"
explore_footer
pause

# ─── 16. lazygit ─────────────────────────────────────────────────────────────
section "16. lazygit — Git TUI"
narrate "lazygit is a full git UI in the terminal."
narrate "Stage hunks, interactive rebase, conflict resolution — all visual."
narrate "No more memorizing git flags."
echo ""
echo -e "  ${BOLD}What you can do:${NC}"
echo -e "    • Stage/unstage individual lines and hunks"
echo -e "    • Interactive rebase by moving commits up/down"
echo -e "    • Side-by-side merge conflict resolution"
echo -e "    • Visual branch log with cherry-pick"
echo -e "    • Stash management, bisect — everything"
explore_header
explore "lazygit                           # open in any repo"
explore "lazygit -p                        # open in patch mode"
explore "lazygit log                       # jump to log view"
explore_footer
pause

# ─── 17. Editors ─────────────────────────────────────────────────────────────
section "17. Neovim (LazyVim) & Helix — Editors"
narrate "The repo includes a full neovim config: LazyVim + meta.nvim."
narrate "That gives you LSP, completion, telescope, Sapling integration."
narrate "10 lua config files — all captured in the repo."
echo ""
echo -e "  ${BOLD}Neovim (LazyVim + meta.nvim):${NC}"
echo -e "    • Full IDE: LSP, telescope, neo-tree, completion"
echo -e "    • Meta: blink.cmp sources for tasks, tags, revsub"
echo -e "    • Tokyonight storm theme, signify for Sapling diffs"
echo -e "    • 40+ treesitter parsers"
echo ""
echo -e "  ${BOLD}Helix — zero-config alternative:${NC}"
echo -e "    • Built-in LSP, tree-sitter, multiple cursors"
echo -e "    • Selection-first modal editing"
echo -e "    • No config needed — great for quick edits"
explore_header
explore "nvim .                            # launch neovim IDE"
explore "hx file.py                        # quick edit with helix"
explore "nvim +'Telescope find_files'      # jump to file finder"
explore_footer
pause

# ─── 18. Multiplexers ───────────────────────────────────────────────────────
section "18. tmux & zellij — Multiplexers"
narrate "tmux is configured with mouse support, 500k scroll history."
narrate "zellij is a modern alternative with built-in keybinding hints"
narrate "so you don't need a cheat sheet."
echo ""
echo -e "  ${BOLD}tmux (configured in repo):${NC}"
echo -e "    • Mouse, 256color, 500k history"
echo -e "    • ${GREEN}./dev-session.sh${NC} → claude (60%) + nvim (40%)"
echo ""
echo -e "  ${BOLD}zellij (alternative):${NC}"
echo -e "    • Discoverable UI with keybinding bar"
echo -e "    • Floating panes, named layouts"
echo -e "    • No config needed to start"
explore_header
explore "./dev-session.sh                  # claude + nvim split"
explore "./dev-session.sh ~/fbsource       # specific project"
explore "zellij                            # try the modern alternative"
explore_footer
pause

# ─── 19. CLAUDE.md ───────────────────────────────────────────────────────────
section "19. CLAUDE.md — Persistent AI Memory"
narrate "CLAUDE.md is a file Claude Code reads at the start of EVERY session."
narrate "It's like onboarding Claude to your environment — once."
narrate "Your preferences, commands, conventions — all automatic."
echo ""
echo -e "  ${BOLD}What goes in it:${NC}"
echo -e "    • Your tools, languages, editor preferences"
echo -e "    • Common commands (build, test, lint, deploy)"
echo -e "    • Code conventions ('use with-proxy', 'never amend without asking')"
echo -e "    • Project paths and architecture context"
echo ""
echo -e "  ${BOLD}Hierarchy (all merged, specific overrides general):${NC}"
echo -e "    ${DIM}~/.claude/CLAUDE.md${NC}      personal (all projects)"
echo -e "    ${DIM}repo/CLAUDE.md${NC}           project (shared with team)"
echo -e "    ${DIM}repo/subdir/CLAUDE.md${NC}    module-specific"
echo ""
narrate "The setup script symlinks CLAUDE.md into ~/.claude/ automatically."
narrate "Edit ~/devvm-setup/dotfiles/CLAUDE.md to update your preferences."
echo ""
echo -e "  ${BOLD}What's in ours:${NC}"
run "head -25 $HOME/.claude/CLAUDE.md 2>/dev/null || echo '  (will be created by setup.sh)'"
explore_header
explore "cat ~/.claude/CLAUDE.md            # see your full config"
explore "nvim ~/devvm-setup/dotfiles/CLAUDE.md  # edit preferences"
explore "@import ./docs/style-guide.md     # import other docs"
explore "claude /init                       # auto-generate a starter"
explore_footer
pause

# ─── 20. dev-session ─────────────────────────────────────────────────────────
section "20. dev-session.sh — The AI-native workflow"
narrate "This is the payoff. One command gives you Claude Code on the left"
narrate "and neovim on the right. AI pair programming + full IDE."
echo ""
echo -e "  ${GREEN}\$ ./dev-session.sh ~/my-project${NC}"
echo ""
echo -e "  ┌──────────────────────────────┬─────────────────────┐"
echo -e "  │                              │                     │"
echo -e "  │       ${CYAN}claude code${NC}             │      ${MAGENTA}neovim${NC}         │"
echo -e "  │         ${DIM}(60%)${NC}                │       ${DIM}(40%)${NC}        │"
echo -e "  │                              │                     │"
echo -e "  │  ${DIM}AI pair programming${NC}         │  ${DIM}Full IDE${NC}            │"
echo -e "  │  ${DIM}Code review & generation${NC}    │  ${DIM}Edit, navigate${NC}      │"
echo -e "  │  ${DIM}Search & explain${NC}            │  ${DIM}LSP, completion${NC}     │"
echo -e "  │                              │                     │"
echo -e "  └──────────────────────────────┴─────────────────────┘"
echo ""
narrate "Claude has your CLAUDE.md, knows your tools, your conventions."
narrate "Neovim has LSP, telescope, Meta integration. Side by side."
explore_header
explore "./dev-session.sh                  # current directory"
explore "./dev-session.sh ~/fbsource       # specific project"
explore_footer
pause

# ─── 21. setup.sh ────────────────────────────────────────────────────────────
section "21. setup.sh — The bootstrap"
narrate "Everything you just saw installs in one command."
narrate "Clone the repo, run setup.sh, and you're done."
echo ""
echo -e "  ${GREEN}\$ git clone <repo> ~/devvm-setup${NC}"
echo -e "  ${GREEN}\$ cd ~/devvm-setup && ./setup.sh${NC}"
echo ""
echo -e "  ${BOLD}7 phases, all idempotent:${NC}"
echo -e "    1. ${CYAN}devfeature${NC}  bat, eza, fd, fzf, rg, zoxide, nvim, fish, btop, helix, zellij"
echo -e "    2. ${CYAN}dnf${NC}         git-delta, tmux, htop, ncdu, tree, jq, tig, wget, curl"
echo -e "    3. ${CYAN}binary${NC}      lazygit, glow, duf, yq, tldr, xh, btm, dust, procs, broot, gh"
echo -e "    4. ${CYAN}oh-my-zsh${NC}   + autosuggestions, syntax-highlighting"
echo -e "    5. ${CYAN}nvm + node${NC}  LTS"
echo -e "    6. ${CYAN}starship${NC}    prompt (via with-proxy curl)"
echo -e "    7. ${CYAN}dotfiles${NC}    17 files symlinked (including CLAUDE.md)"
echo ""
narrate "Re-run after a devvm migration — it fills in what's missing."
narrate "32/32 tools verified at the end."
explore_header
explore "cd ~/devvm-setup && ./setup.sh    # run it yourself"
explore "cat setup.sh                      # read the source"
explore_footer
pause

# ─── Finale ──────────────────────────────────────────────────────────────────
section "That's it!"
narrate "~/devvm-setup — your entire dev environment, version controlled."
echo ""
echo -e "  ${BOLD}What you get:${NC}"
echo -e "    setup.sh              32 tools, 7 phases, idempotent"
echo -e "    dev-session.sh        claude (60%) + nvim (40%) tmux split"
echo -e "    claude-code-setup.sh  Claude Code plugins & settings"
echo -e "    install-dotfiles.sh   17 config files symlinked"
echo -e "    dotfiles/             zshrc, tmux, git, vim, starship, CLAUDE.md"
echo -e "    nvim/                 LazyVim + meta.nvim + 10 lua configs"
echo ""
echo -e "  ${BOLD}Get started:${NC}"
echo -e "    ${GREEN}git clone <repo> ~/devvm-setup && cd ~/devvm-setup && ./setup.sh${NC}"
echo ""
narrate "Questions?"
echo ""
