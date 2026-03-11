# DevVM Setup

Reproducible devvm bootstrap — one script to set up a fresh Meta DevVM with all tools, configs, and workflows. Optimized for modern terminals like **Ghostty**.

## Quick Start

```bash
git clone <this-repo> ~/devvm-setup
cd ~/devvm-setup
./setup.sh
source ~/.zshrc
```

## Proxy Configuration

Add these to your shell profile (`~/.zshrc` or `~/.bashrc`) to route traffic through Meta's forward proxy:

```bash
export https_proxy=http://fwdproxy:8080
export http_proxy=http://fwdproxy:8080
export HTTPS_PROXY=$https_proxy
export HTTP_PROXY=$http_proxy
export no_proxy=.facebook.com,.thefacebook.com,.fb.com,.internalfb.com,localhost,127.0.0.1
```

These are required for most external network access on devvms (e.g., `curl`, `git clone`, `go install`, `npm install`).

## Installing Ghostty

[Ghostty](https://ghostty.org) is a fast, feature-rich, GPU-accelerated terminal emulator that uses platform-native UI. It supports ligatures, true color, images (Kitty protocol), and has excellent font rendering.

### Install (macOS — local machine)

```bash
brew install --cask ghostty
```

### Install (Linux — from source)

```bash
# Requires Zig 0.13.0+
git clone https://github.com/ghostty-org/ghostty
cd ghostty
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/ghostty /usr/local/bin/
```

### Recommended Ghostty Config

Create `~/.config/ghostty/config`:

```
font-family = JetBrains Mono
font-size = 14
theme = tokyonight
cursor-style = block
cursor-style-blink = false
mouse-hide-while-typing = true
window-padding-x = 8
window-padding-y = 4
window-decoration = false
confirm-close-surface = false
shell-integration = zsh
```

### Why Ghostty?

- GPU-accelerated rendering — no lag even with heavy output
- Native platform UI (not Electron)
- First-class support for ligatures and Nerd Fonts
- Kitty image protocol support (view images in terminal)
- Built-in multiplexing (splits/tabs without tmux)
- Extremely low latency input handling

## Top CLI Tools for Modern Terminals & Ghostty

### Shell & Navigation

| Tool | Description | Install |
|---|---|---|
| **zsh + Oh My Zsh** | Enhanced shell with plugins, themes, autocompletion | `setup.sh` |
| **fish** | User-friendly shell with intelligent autosuggestions | `devfeature` |
| **starship** | Fast, customizable, cross-shell prompt | `with-proxy curl` |
| **zoxide** | Smarter `cd` that learns your habits (`z` to jump) | `devfeature` |
| **fzf** | Fuzzy finder for files, history, and more | `devfeature` |

### File Management & Viewing

| Tool | Description | Install |
|---|---|---|
| **eza** | Modern `ls` with colors, icons, git integration | `devfeature` |
| **bat** | `cat` with syntax highlighting and git integration | `devfeature` |
| **fd** | Fast, user-friendly alternative to `find` | `devfeature` |
| **ripgrep (rg)** | Blazingly fast `grep` replacement | `devfeature` |
| **tree** | Display directory structures | `dnf` |
| **broot** | Interactive tree view with fuzzy search | binary |
| **glow** | Render markdown beautifully in terminal | `go install` |

### System Monitoring

| Tool | Description | Install |
|---|---|---|
| **htop** | Interactive process viewer (classic) | `dnf` |
| **btop** | Interactive process viewer (gorgeous visuals) | `devfeature` |
| **bottom (btm)** | Graphical system monitor with widgets | binary |
| **dust** | Intuitive disk usage analyzer (better `du`) | binary |
| **duf** | Better `df` with nice formatting | `go install` |
| **ncdu** | NCurses disk usage analyzer | `dnf` |
| **procs** | Modern replacement for `ps` | binary |

### Development & Git

| Tool | Description | Install |
|---|---|---|
| **lazygit** | Terminal UI for git commands | `go install` |
| **git-delta** | Syntax-highlighting pager for git diffs | `dnf` |
| **gh** | GitHub CLI | binary |
| **tig** | Text-mode interface for git | `dnf` |
| **jq** | JSON processor | `dnf` |
| **yq** | YAML/XML/TOML processor | `go install` |

### Networking & HTTP

| Tool | Description | Install |
|---|---|---|
| **xh** | httpie-compatible HTTP client (pre-built binary) | binary |
| **curl** | Classic HTTP client | `dnf` |
| **wget** | File downloader | `dnf` |

### Editors & Multiplexers

| Tool | Description | Install |
|---|---|---|
| **neovim** | Hyperextensible vim-based editor (LazyVim + meta.nvim) | `devfeature` |
| **helix** | Modern modal editor (no config needed) | `devfeature` |
| **vim** | Classic editor | pre-installed |
| **tmux** | Terminal multiplexer | `dnf` |
| **zellij** | Modern tmux alternative with layouts | `devfeature` |

### Productivity

| Tool | Description | Install |
|---|---|---|
| **tldr** | Simplified man pages with examples | `npm` |
| **Claude Code** | AI coding assistant (with Meta plugins) | pre-installed |

## Dotfiles

| File | Description |
|---|---|
| `.zshrc` | Oh-my-zsh, starship, zoxide, fwdproxy, aliases (eza, bat) |
| `.tmux.conf` | 256color, mouse, vi-mode copy-paste, OSC 52 clipboard |
| `.gitconfig` | Template — fill in your username and cert paths |
| `.vimrc` | Sources Meta's master.vimrc |
| `starship.toml` | Custom prompt with git branch icons |
| `CLAUDE.md` | Claude Code persistent memory (preferences, commands, conventions) |
| `nvim/init.lua` | LazyVim + meta.nvim + tokyonight theme |

## Scripts

| Script | Purpose |
|---|---|
| `setup.sh` | Main idempotent bootstrap (safe to re-run) |
| `install-dotfiles.sh` | Symlink dotfiles with automatic backup |
| `dev-session.sh [path]` | Launch tmux session: claude + nvim side-by-side |
| `claude-code-setup.sh` | Install Claude Code plugins and write settings |
| `sync-repo.sh` | Daily git pull/push for both branches (master + macos-setup) |

## Dev Session

Launch a split tmux session with Claude Code and nvim:

```bash
./dev-session.sh              # current directory
./dev-session.sh ~/project    # specific project
```

**Layout:**
```
┌────────────────────────┬───────────────────┐
│                        │                   │
│     claude code        │      neovim       │
│       (60%)            │       (40%)       │
│                        │                   │
└────────────────────────┴───────────────────┘
```

## Key Shortcuts

### LazyVim (Neovim)

| Key | Action |
|---|---|
| `Space` | Leader key |
| `Space f f` | Find files (telescope) |
| `Space f g` | Live grep |
| `Space e` | File explorer (neo-tree) |
| `Space b d` | Close buffer |
| `Space c a` | Code actions |
| `g d` | Go to definition |
| `K` | Hover documentation |

### tmux

| Key | Action |
|---|---|
| `Ctrl-b %` | Split vertical |
| `Ctrl-b "` | Split horizontal |
| `Alt-arrow` | Navigate panes (no prefix) |
| `Ctrl-b d` | Detach session |
| `Ctrl-b [` | Enter copy mode (scroll/select) |
| `v` / `V` / `Ctrl-v` | Visual / line / block select (in copy mode) |
| `y` | Yank to system clipboard (in copy mode) |
| `Ctrl-b ]` | Paste from tmux buffer |
| Mouse drag | Auto-copies selection to clipboard |

### Ghostty

| Key | Action |
|---|---|
| `Ctrl-Shift-Enter` | New split |
| `Ctrl-Shift-T` | New tab |
| `Ctrl-Shift-N` | New window |
| `Ctrl-Shift-W` | Close surface |
| `Ctrl-+` / `Ctrl--` | Zoom in / out |

### Shell Tools

| Key / Command | Action |
|---|---|
| `z <dir>` | Smart cd (zoxide) |
| `Ctrl-r` | Fuzzy history search (fzf) |
| `Ctrl-t` | Fuzzy file finder (fzf) |
| `Alt-c` | Fuzzy cd (fzf) |

## Multi-Agent Team (Claude Code)

Run parallel Claude Code agents as a coordinated team — a Manager plans and delegates, Engineers implement, and Reviewers audit. Inspired by [master-claude](https://github.com/Chef-SWanger/master-claude).

### How It Works

```
┌─────────────┐     delegates      ┌─────────────┐
│   Manager   │ ──────────────────→│  Engineer   │
│  (planner)  │←────────────────── │ (implements)│
└──────┬──────┘    status/done     └─────────────┘
       │
       │  assigns review           ┌─────────────┐
       └──────────────────────────→│  Reviewer   │
                                   │  (audits)   │
                                   └─────────────┘
```

Agents communicate via **tmux** (`send-keys` / `capture-pane`) and share context through **Memory.md** (project-wide) and **journal files** (per-agent). Each team gets its own isolated repo checkout.

### Quick Start

```bash
# 1. Setup — create 2 team checkouts from a repo
./agents/agent-team.sh setup ~/my-project 2

# 2. Start team 1 (launches manager + engineer + reviewer)
./agents/agent-team.sh start 1

# 3. Connect to the manager to give it a task
./agents/agent-team.sh connect 1 manager

# 4. (Optional) Start an orchestrator for multi-team coordination
./agents/agent-team.sh orchestrator:start
```

### Commands

| Command | Description |
|---|---|
| `setup <repo> <N>` | Create N isolated checkouts (git worktree or sl clone) |
| `start <N>` | Launch manager + engineer + reviewer for team N |
| `stop <N>` | Gracefully stop team N (saves journals first) |
| `list` | Show all active agent sessions |
| `connect <N> [role]` | Attach to a specific agent's tmux session |
| `logs <N> [role]` | Tail an agent's log output |
| `orchestrator:start` | Start the cross-team orchestrator |
| `orchestrator:stop` | Stop the orchestrator |
| `stop-all` | Kill all agent sessions |

### Agent Roles

| Role | Prompt | Responsibilities |
|---|---|---|
| **Manager** | `agents/prompts/manager.md` | Plans tasks, delegates to engineer, assigns reviews |
| **Engineer** | `agents/prompts/engineer.md` | Implements changes, runs tests, reports completion |
| **Reviewer** | `agents/prompts/reviewer.md` | Audits code quality, approves or requests changes |
| **Orchestrator** | `agents/prompts/orchestrator.md` | Coordinates multiple teams on large projects |

### Directory Structure

```
agents/
├── agent-team.sh              # Main CLI entrypoint
├── profiles/                  # Claude CLI settings per role
│   ├── engineer.json
│   ├── manager.json
│   ├── reviewer.json
│   └── orchestrator.json
├── prompts/                   # System prompts for each agent
│   ├── common/
│   │   ├── compaction.md      # Context preservation during compaction
│   │   └── filesystem-rules.md # Safe search/navigation rules
│   ├── engineer.md
│   ├── manager.md
│   ├── reviewer.md
│   └── orchestrator.md
└── utils/
    ├── agent-start.sh         # VCS bootstrap (Git + Sapling)
    └── claude.sh              # Prompt assembly & Claude CLI launcher
```

### Runtime State

```
~/.agent-team/
├── config                     # CHECKOUT_BASE, SOURCE_REPO
├── logs/                      # Per-agent session logs
└── checkouts/
    ├── team_01/               # Isolated repo for team 1
    ├── team_02/               # Isolated repo for team 2
    └── Memory.md              # Shared project-wide context
```

### Customizing

- **Profiles**: Edit `agents/profiles/<role>.json` to add Claude plugins or env vars
- **Prompts**: Edit `agents/prompts/<role>.md` to change agent behavior
- **Common rules**: Add new `.md` files to `agents/prompts/common/` — they're auto-appended to all prompts

### Tips

- Use `connect` to watch agents work in real-time
- The Manager handles all coordination — just give it a task and watch
- Agents save state to journals before shutdown, so they can resume context
- Works with both Git repos (worktrees) and Sapling repos (clones)

## Daily Sync (macOS)

A launchd agent automatically syncs this repo daily at 9am — pulling and pushing both `master` and `macos-setup` branches.

### Install

```bash
# Copy the plist (already included in this repo's LaunchAgents)
cp ~/Repos/devvm-setup/com.payton.devvm-setup-sync.plist ~/Library/LaunchAgents/

# Load it
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.payton.devvm-setup-sync.plist
```

### Manual trigger

```bash
launchctl kickstart gui/$(id -u)/com.payton.devvm-setup-sync
```

### Check logs

```bash
cat ~/.devvm-setup-sync.log
```

### Unload

```bash
launchctl bootout gui/$(id -u)/com.payton.devvm-setup-sync
```

## Manual Steps After Setup

1. **Ghostty**: Install on your local machine (see above) — connects to devvm via SSH
2. **Git credentials**: Edit `~/.gitconfig` and replace `YOUR_USERNAME` with your unix username
3. **SSH keys**: `ssh-keygen -t ed25519` if needed
4. **GitHub auth**: `gh auth login` for GitHub CLI access
5. **Claude Code**: Run `claude` once to trigger Meta org plugin auto-install

## Repo Structure

```
~/devvm-setup/
├── README.md                  # This file
├── setup.sh                   # Main idempotent bootstrap (DevVM)
├── setup-macos.sh             # macOS bootstrap (Homebrew-based)
├── dev-session.sh             # tmux dev session (claude + nvim split)
├── claude-code-setup.sh       # Claude Code plugins/settings installer
├── agents/                    # Multi-agent orchestration system
│   ├── agent-team.sh          # Main CLI (setup/start/stop/connect)
│   ├── profiles/              # Claude CLI settings per role
│   ├── prompts/               # System prompts (manager/engineer/reviewer/orchestrator)
│   │   └── common/            # Shared rules (compaction, filesystem safety)
│   └── utils/                 # VCS bootstrap + Claude launcher
├── dotfiles/
│   ├── .zshrc                 # Full zsh config
│   ├── .tmux.conf             # tmux config
│   ├── .gitconfig             # Git config (template)
│   ├── .vimrc                 # Vim config
│   ├── starship.toml          # Starship prompt config
│   └── CLAUDE.md              # Claude Code persistent memory → ~/.claude/
├── nvim/
│   ├── init.lua               # Neovim LazyVim + Meta config
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua   # Auto-commands
│       │   ├── keymaps.lua    # Arrow-key pane nav, typo aliases
│       │   └── options.lua    # Relative line numbers, clipboard, wildmode
│       └── plugins/
│           ├── cmp.lua        # Blink.cmp + Meta completion sources
│           ├── coding.lua     # Tab/S-Tab completion, CR confirm
│           ├── colorscheme.lua # Tokyonight storm + orange borders
│           ├── editor.lua     # Signify (Sapling diffs), Telescope tweaks
│           ├── lsp.lua        # Truncated diagnostics, arc lint timeout
│           ├── treesitter.lua # 40+ parsers, proxy-aware, motion keymaps
│           └── ui.lua         # Bufferline slant style, notify history
├── install-dotfiles.sh        # Symlink dotfiles into place
├── sync-repo.sh               # Daily git sync script (both branches)
├── com.payton.devvm-setup-sync.plist  # macOS launchd agent for daily sync
└── sync-reminders.swift       # Apple Reminders ↔ Obsidian two-way sync
```
