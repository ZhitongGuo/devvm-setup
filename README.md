# DevVM Setup

Reproducible devvm bootstrap — one script to set up a fresh Meta DevVM with all tools, configs, and workflows. Optimized for modern terminals like **Ghostty**.

## Quick Start

```bash
git clone <this-repo> ~/devvm-setup
cd ~/devvm-setup
./setup.sh
source ~/.zshrc
./vault-auth.sh          # one-time: configure Google Drive (two-machine OAuth)
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
| `.zshrc` | Oh-my-zsh, starship, zoxide, fwdproxy, aliases, MetaVault mount |
| `.tmux.conf` | 256color, mouse support, 500k history |
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
| `vault-auth.sh` | Interactive Google Drive OAuth (two-machine flow) |
| `dev-session.sh [path]` | Launch tmux session: claude + nvim side-by-side |
| `claude-code-setup.sh` | Install Claude Code plugins and write settings |

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
| `Ctrl-b arrow` | Navigate panes |
| `Ctrl-b d` | Detach session |
| `Ctrl-b [` | Scroll mode |

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

## Google Drive / MetaVault Sync

Mount your Google Drive (Obsidian vault, notes, etc.) on every devserver:

### First-time setup (two-machine flow)

Devservers have no browser, so auth requires your **laptop + devserver**:

1. **On the devserver**, run:
   ```bash
   ./vault-auth.sh
   ```
   Follow the prompts. When asked **"Use auto config?"**, answer **`n`**.
   It will print a command like:
   ```
   rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
   ```

2. **On your Mac** (with mclone or rclone installed), run that command:
   ```bash
   # Install if needed: brew install rclone (or use mclone if available)
   mclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
   ```
   This opens a browser. Authorize with your Meta Google account. It prints a token.

3. **Back on the devserver**, paste the token and finish the config.

### After first-time setup

```bash
# dotsync2 syncs ~/.config/rclone/rclone.conf across devservers automatically
# New shells auto-mount gdrive:MetaVault -> ~/my-vault
# Token refresh daemon keeps the mount alive (tokens expire hourly)
```

**Shell functions** (available after `source ~/.zshrc`):
- `mount-vault` — mount Google Drive to `~/my-vault` (handles stale FUSE mounts)
- `unmount-vault` — cleanly unmount

**Troubleshooting**:
- Stale mount (`Transport endpoint not connected`): `fusermount -uz ~/my-vault`
- Token expired: `mclone refresh-token -a -e`
- Kill stuck processes: `pkill -9 -f mclone`
- Check logs: `cat ~/.mclone-vault.log`
- Re-auth from scratch: `./vault-auth.sh`

## dotsync2 (Cross-DevServer Sync)

`setup.sh` configures dotsync2 to sync these paths across all devservers:

| Path | What |
|---|---|
| `~/.config/rclone/rclone.conf` | mclone/Google Drive tokens |
| `~/.claude/CLAUDE.md` | Claude Code persistent memory |
| `~/.claude/settings.json` | Claude Code settings |
| `~/.claude/commands/` | Custom slash commands |
| `~/.claude/hooks/` | Event hooks |
| `~/.claude/plugins/` | Plugin config |
| `~/.claude/skills/` | Skills |
| `~/.claude/agents/` | Agent profiles |

On a new devserver, `dotsync2 sync` (run by `setup.sh`) pulls all config automatically.

## Manual Steps After Setup

1. **Ghostty**: Install on your local machine (see above) — connects to devvm via SSH
2. **Google Drive**: Run `./vault-auth.sh` on one devserver (dotsync2 handles the rest)
3. **Git credentials**: Edit `~/.gitconfig` and replace `YOUR_USERNAME` with your unix username
4. **SSH keys**: `ssh-keygen -t ed25519` if needed
5. **GitHub auth**: `gh auth login` for GitHub CLI access
6. **Claude Code**: Run `claude` once to trigger Meta org plugin auto-install

## Repo Structure

```
~/devvm-setup/
├── README.md                  # This file
├── setup.sh                   # Main idempotent setup script (Phases 1-9)
├── vault-auth.sh              # Interactive Google Drive OAuth setup
├── dev-session.sh             # tmux dev session (claude + nvim split)
├── claude-code-setup.sh       # Claude Code plugins/settings installer
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
└── install-dotfiles.sh        # Symlink dotfiles into place
```
