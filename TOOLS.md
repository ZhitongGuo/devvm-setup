# Tools Guide

All tools installed by `setup-macos.sh` (or `setup.sh` on DevVM), organized by use case.

## Shell & Navigation

| Tool | What it does | Example |
|---|---|---|
| **zsh + Oh My Zsh** | Enhanced shell with plugin ecosystem, themes, tab completion | Auto-completes git commands, paths, etc. |
| **starship** | Fast, customizable prompt — shows git branch, language versions, exit codes at a glance | Your prompt shows `🌱 main` when in a git repo |
| **zoxide** | Learns your most-visited directories. Type `z proj` instead of `cd ~/code/my-project` | `z devvm` jumps to `~/devvm-setup` |
| **fzf** | Fuzzy finder for everything — `Ctrl-R` searches shell history, `Ctrl-T` finds files | Type `Ctrl-R` then `git` to find past git commands |
| **fish** | Alternative shell with built-in autosuggestions (if you ever want to try it) | Suggests commands as you type in gray text |

## File Management & Viewing

| Tool | What it does | Example |
|---|---|---|
| **eza** | Modern `ls` with colors, icons, git status per file | `ll` shows files with git modified/untracked markers |
| **bat** | `cat` with syntax highlighting, line numbers, git diffs | `bat setup-macos.sh` — color-coded bash script |
| **fd** | Fast file finder (simpler than `find`) | `fd "\.lua$"` finds all Lua files recursively |
| **ripgrep (rg)** | Blazingly fast code search across files | `rg "TODO"` searches all files in the repo |
| **tree** | Shows directory structure as a tree | `tree -L 2` shows 2 levels of directories |
| **broot** | Interactive tree view — navigate, search, open files | `broot` then type to fuzzy-filter the tree |
| **glow** | Renders Markdown beautifully in the terminal | `glow README.md` — formatted, colored output |

## System Monitoring

| Tool | What it does | Example |
|---|---|---|
| **htop** | Classic interactive process viewer | See CPU/memory per process, kill processes |
| **btop** | Gorgeous graphical system monitor (CPU, RAM, disk, network) | Dashboard view of your entire system |
| **bottom (btm)** | Widget-based system monitor with charts | `btm` — CPU graphs, process list, network I/O |
| **dust** | Visual disk usage — shows what's eating space | `dust ~/` — bar chart of biggest directories |
| **duf** | Pretty `df` — shows disk space per volume | `duf` — colored table of all mounted drives |
| **ncdu** | Interactive disk analyzer — drill into directories | `ncdu ~/` — navigate and delete large files |
| **procs** | Modern `ps` with color, tree view, search | `procs --tree` — process hierarchy with colors |

## Development & Git

| Tool | What it does | Example |
|---|---|---|
| **lazygit** | Full git TUI — stage, commit, rebase, resolve conflicts visually | `lazygit` — point-and-click git workflow |
| **git-delta** | Beautiful syntax-highlighted diffs in git | `git diff` now shows colored, side-by-side changes |
| **gh** | GitHub CLI — PRs, issues, repos from terminal | `gh pr create`, `gh issue list`, `gh repo clone` |
| **tig** | Text-mode git log browser | `tig` — scroll through commits, view diffs |
| **jq** | Parse/filter JSON from APIs or files | `curl api.example.com \| jq '.data[0].name'` |
| **yq** | Same as jq but for YAML/TOML/XML | `yq '.services' docker-compose.yml` |

## Networking & HTTP

| Tool | What it does | Example |
|---|---|---|
| **xh** | Friendly HTTP client (like httpie) | `xh GET api.example.com/users` — colored JSON output |

## Editors & Multiplexers

| Tool | What it does | Example |
|---|---|---|
| **neovim** | Extensible vim editor — configured with LazyVim for IDE features | Fuzzy find, LSP, auto-complete, file tree |
| **helix** | Modern modal editor that works out of the box (no config) | `hx file.py` — LSP, tree-sitter, multicursors built in |
| **tmux** | Terminal multiplexer — splits, tabs, persistent sessions | Split screen: Claude Code on left, nvim on right |
| **zellij** | Modern tmux alternative with floating panes and layouts | `zellij` — tabbed panes with a status bar |

## Productivity

| Tool | What it does | Example |
|---|---|---|
| **tldr** | Simplified man pages with practical examples | `tldr tar` — shows the 5 most common tar commands |

## Common Workflows

**"I need to find something in my codebase"** — `rg "pattern"` (search content) or `fd "filename"` (search files), then `bat file.py` to view with syntax highlighting

**"I need to debug a slow machine"** — `btop` for a dashboard, `dust ~/` to find disk hogs, `procs --sortd cpu` to find CPU-heavy processes

**"I want a nice git workflow"** — `lazygit` for visual staging/committing, `git-delta` makes `git diff` beautiful, `tig` for browsing history

**"I'm working on a project"** — `./dev-session.sh ~/project` gives you a tmux split with Claude Code + neovim side by side

**"I need to hit an API"** — `xh GET https://api.example.com` with auto-colored JSON output, or pipe through `jq` for filtering
