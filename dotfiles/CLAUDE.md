# Instructions for Claude

## About Me
- Primary languages: Python, JavaScript/TypeScript, Hack
- Editor: Neovim (LazyVim)
- Source control: git

## Environment
- Shell: zsh with oh-my-zsh, starship prompt
- Package manager: Homebrew (macOS) or devfeature/dnf (DevVM)
- Node: managed via nvm (source ~/.nvm/nvm.sh if needed)
- Extra binaries live in ~/.local/bin

## Preferences
- Be concise — skip lengthy explanations unless I ask
- Prefer editing existing files over creating new ones
- Always show what you're changing before applying edits
- Default to creating NEW git commits, never amend without asking
- Do not git push without asking
- Do not add yourself as co-author of commits
- Follow existing code style and patterns in the file being edited

## Common Commands
- Dev session: `~/devvm-setup/dev-session.sh [path]`

## Project Paths
- Home setup repo: ~/devvm-setup
- Neovim config: ~/.config/nvim/ (LazyVim)
- Claude config: ~/.claude/settings.json
- Local binaries: ~/.local/bin
- Oh-my-zsh custom: ~/.oh-my-zsh/custom/plugins/

## Tools Available
All tools from devvm-setup are installed:
- File nav: eza, bat, fd, fzf, ripgrep, zoxide, tree, broot
- Git: lazygit, git-delta, gh, tig
- Data: jq, yq, glow
- System: btop, btm, dust, duf, procs, htop, ncdu
- HTTP: xh (httpie-compatible)
- Editors: nvim (primary), hx (helix), vim
- Multiplexers: tmux (primary), zellij
- Other: tldr, fish, starship, nvm, node

## Code Conventions
- Shell scripts: use `set -euo pipefail`, prefer bash over sh
- Python: follow PEP 8, use type hints, use pathlib over os.path
- Config files: prefer TOML/YAML over JSON when possible
- When writing scripts, make them idempotent (check before installing)
