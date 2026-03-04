# Instructions for Claude

## About Me
- DevVM user on Meta infrastructure
- Primary languages: Python, JavaScript/TypeScript, Hack
- Editor: Neovim (LazyVim + meta.nvim)
- Terminal: Ghostty + tmux
- Source control: Sapling (sl), Phabricator diffs

## Environment
- OS: Linux (CentOS/Fedora-based devvm)
- Shell: zsh with oh-my-zsh, starship prompt
- Proxy: use `with-proxy` prefix for commands that need internet access (curl, git clone, etc.)
- Package managers: `devfeature install` (preferred), `dnf`, `go install`, `npm`
- IMPORTANT: `pip3 install` is blocked on devvms. Use pre-built binaries or `go install` instead.
- Node: managed via nvm (source ~/.nvm/nvm.sh if needed)
- Go: available at /usr/local/go/bin/go
- Extra binaries live in ~/.local/bin

## Preferences
- Be concise — skip lengthy explanations unless I ask
- Prefer editing existing files over creating new ones
- Always show what you're changing before applying edits
- Use `with-proxy` for any external URL fetches (curl, wget, git clone from github)
- Default to creating NEW git commits, never amend without asking
- Do not git push without asking
- Do not add yourself as co-author of commits
- Follow existing code style and patterns in the file being edited

## Common Commands
- Build: `buck2 build //path:target`
- Test: `buck2 test //path:target`
- Lint: `arc lint`
- Format: `arc lint --apply-patches`
- Source control: `sl` (Sapling) — not `git` for fbsource
- Create diff: `jf submit` (Jellyfish)
- Dev session: `~/devvm-setup/dev-session.sh [path]`

## Project Paths
- Home setup repo: ~/devvm-setup
- Neovim config: ~/.config/nvim/ (LazyVim + meta.nvim)
- Claude config: ~/.claude/settings.json
- Local binaries: ~/.local/bin
- Oh-my-zsh custom: ~/.oh-my-zsh/custom/plugins/

## Tools Available
All 32 tools from devvm-setup are installed:
- File nav: eza, bat, fd, fzf, ripgrep, zoxide, tree, broot
- Git: lazygit, git-delta, gh, tig
- Data: jq, yq, glow
- System: btop, btm, dust, duf, procs, htop, ncdu
- HTTP: xh (httpie-compatible, aliased to `http`)
- Editors: nvim (primary), hx (helix), vim
- Multiplexers: tmux (primary), zellij
- Other: tldr, fish, starship, nvm, node

## Code Conventions
- IMPORTANT: Use `with-proxy` for ALL external network calls
- Use `devfeature install` before trying dnf or manual installs
- Shell scripts: use `set -euo pipefail`, prefer bash over sh
- Python: follow PEP 8, use type hints, use pathlib over os.path
- Config files: prefer TOML/YAML over JSON when possible
- When writing scripts, make them idempotent (check before installing)
