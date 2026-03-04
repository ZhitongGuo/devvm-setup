# DevVM Setup — Presenter Script

Run `./demo.sh` and press ENTER to advance. The demo is now **self-narrating** — talking points, live demos, and explore suggestions all print on screen. These notes are your extra color commentary and backup.

---

## Slide 0: Title

**On screen:** Tool count, idempotent badge, "let's walk through the tools"

**Extra color:**
> "I built this because every time I got a new devvm, I'd spend half a day reinstalling everything. Now it's one command."

---

## Slide 1: Ghostty — GPU-Accelerated Terminal

**On screen:** Why Ghostty, install command, config example

**Extra color:**
> "This is the foundation — the terminal you SSH into. Ghostty is what makes all these tools look good. The GPU rendering means btop, lazygit, even heavy nvim sessions don't lag."

**If asked "Why not iTerm2?":**
> "iTerm2 is great but it's showing its age. Ghostty is faster, native, and the image protocol means you can literally display images inline."

**If asked "Can I use it today?":**
> "Yeah — `brew install --cask ghostty` on your Mac, then SSH to your devvm like normal."

---

## Slide 2: eza — Modern ls replacement

**On screen:** Before/after comparison, tree view, explore box

**Extra color:**
> "Notice the git status column — you can see which files are modified without running `git status`. And the icons make it scannable at a glance."

---

## Slide 3: bat — cat with syntax highlighting

**On screen:** Before/after comparison, explore box

**Extra color:**
> "The killer feature nobody mentions: set bat as your MANPAGER and `man git` becomes syntax-highlighted. Game changer."

---

## Slide 4: fd — Faster, friendlier find

**On screen:** Before/after comparison, config file search, explore box

**Extra color:**
> "On fbsource, `find` returns millions of results because it doesn't respect .gitignore. fd does — automatically."

---

## Slide 5: ripgrep — Blazingly fast grep

**On screen:** Before/after comparison, context search, explore box

**Extra color:**
> "This is the same search engine VS Code uses. On our codebase it's 5-10x faster than grep. The -C flag for context is what I use most."

---

## Slide 6: fzf — Fuzzy finder

**On screen:** Key bindings, pipe example, explore box

**Extra color:**
> "The real magic is Ctrl-R. Try it right now — fuzzy search your entire command history. Once you use it, you can't go back to the default reverse-i-search."

**Demo suggestion:** Pause here and let people try Ctrl-R in their own terminals.

---

## Slide 7: zoxide — Smarter cd

**On screen:** Usage examples, frecency database, explore box

**Extra color:**
> "After a week of using it, my most common directories are just `z fb`, `z setup`, `z config`. It learns from how you actually work."

---

## Slide 8: git-delta — Beautiful diffs

**On screen:** Colored diff output, explore box

**Extra color:**
> "The word-level highlighting is the key — it shows you exactly which characters changed on a line, not just that the line changed."

---

## Slide 9: jq & yq — Structured data tools

**On screen:** Three live demos (extract, reshape, convert), explore box

**Extra color:**
> "jq is one of those tools where once you learn the basics, you use it daily. Parsing API responses, transforming config files, CI/CD pipelines."

---

## Slide 10: glow — Render markdown

**On screen:** Rendered README, explore box

**Extra color:**
> "Quick one — useful for checking READMEs, PR descriptions, or doc files without opening a browser."

---

## Slide 11: dust & duf — Disk usage

**On screen:** Visual bar charts, filesystem table, explore box

**Extra color:**
> "Replaces the `du -sh * | sort -rh | head` dance that nobody remembers."

---

## Slide 12: procs — Modern ps

**On screen:** Colored process tree, explore box

**Extra color:**
> "Tree mode shows parent-child relationships — useful for debugging process hierarchies."

---

## Slide 13: xh — HTTP client

**On screen:** Syntax comparison, POST example, explore box

**Extra color:**
> "We can't demo live HTTP on devvm, but the key selling point is: `xh api.example.com` vs `curl -s api.example.com -H 'Accept: application/json' | jq .` — same result, much less typing."

---

## Slide 14: tldr — Simplified man pages

**On screen:** tldr tar output, explore box

**Extra color:**
> "Raise your hand if you can write a tar compress command from memory. Now you don't have to."

---

## Slide 15: btop & bottom — System monitors

**On screen:** Tool list, explore box

**Extra color:**
> "Not launching these since they take over the terminal, but if you want to see the prettiest terminal app ever made, try `btop` after the talk."

---

## Slide 16: lazygit — Git TUI

**On screen:** Feature list, explore box

**Extra color:**
> "This is the one that saves the most time. Interactive rebase by just moving lines up and down. Conflict resolution side-by-side. No more `git rebase -i` and editing in vim."

**Demo suggestion:** If time allows, offer to open lazygit live.

---

## Slide 17: Neovim & Helix — Editors

**On screen:** Feature lists for both, explore box

**Extra color:**
> "The full neovim config is 10 lua files — all in the repo. LazyVim gives you the IDE layer, meta.nvim adds the Meta-specific stuff. Helix is there for when you want a quick edit without loading the full config."

---

## Slide 18: tmux & zellij — Multiplexers

**On screen:** tmux config highlights, zellij description, explore box

**Extra color:**
> "zellij is worth trying if you've never used tmux. It has keybinding hints built into the UI so you don't need a cheat sheet."

---

## Slide 19: CLAUDE.md — Persistent AI Memory

**On screen:** What goes in it, hierarchy, first 25 lines of the actual file

**Extra color:**
> "This is the most underrated Claude Code feature. Instead of telling Claude your preferences every session, you write them once in CLAUDE.md and it reads them automatically. Our setup.sh symlinks it so every new devvm gets it."

**Key points to emphasize:**
- It's a file, not a setting — version controlled, shareable
- The hierarchy means you can have personal prefs AND team standards
- `@import` lets you include external docs (style guides, architecture docs)
- Start small — add rules when Claude gets something wrong

**If asked "What should I put in mine?":**
> "Start with: your common commands (build, test, lint), your language preferences, and 'use with-proxy for external URLs'. Add more based on what Claude gets wrong."

---

## Slide 20: dev-session.sh — The AI-native workflow

**On screen:** Layout diagram, description

**Extra color:**
> "This is the payoff of everything. Claude on the left knows your CLAUDE.md, knows your tools. Neovim on the right has LSP, telescope, Meta integration. You're pair programming with AI."

---

## Slide 21: setup.sh — The bootstrap

**On screen:** 7 phases listed, verification count

**Extra color:**
> "This is the one-command pitch. Fresh devvm? `git clone && ./setup.sh`. 32 tools, 17 dotfiles, full IDE config. Re-run it after a migration and it just fills in what's missing."

---

## Slide: Finale

**On screen:** Repo overview, get started command

**What to say:**
> "That's it — the repo link is in the chat. Clone it, run setup.sh, you're set. Questions?"

---

## Q&A Prepared Answers

**"How long does setup.sh take?"**
> "Fresh devvm: 5-10 minutes (mostly downloading Go binaries). Re-run: under 30 seconds."

**"Can I customize it?"**
> "Fork the repo, edit whatever. The dotfiles are symlinked — editing ~/devvm-setup/dotfiles/.zshrc immediately updates your live config."

**"What about Ghostty?"**
> "Install on your Mac with `brew install --cask ghostty`. It connects to the devvm via SSH. I have recommended config in the README."

**"What's CLAUDE.md?"**
> "A markdown file Claude reads at the start of every session. Your preferences, commands, conventions — persistent memory. The setup script symlinks ours automatically."

**"What if I already have a .zshrc?"**
> "setup.sh backs up all existing files to ~/dotfiles-backup-<timestamp>/ before symlinking. Your originals are safe."

**"Does this work on a fresh devvm?"**
> "Yes — that's the whole point. I've tested it end-to-end. 32/32 tools verified."

**"What's the difference between devfeature and dnf?"**
> "devfeature is Meta's package manager — uses fbpkg under the hood, preferred for Meta-supported packages. dnf is the system package manager for everything else."

---

## Timing Guide

| Section | Time | Running total |
|---|---|---|
| Title + intro | 1 min | 1 min |
| Ghostty | 2 min | 3 min |
| eza, bat, fd, rg (file tools) | 4 min | 7 min |
| fzf, zoxide (navigation) | 2 min | 9 min |
| delta, jq/yq, glow (dev tools) | 3 min | 12 min |
| dust, procs (system) | 1 min | 13 min |
| xh, tldr (quick tools) | 1 min | 14 min |
| btop, lazygit (TUI tools) | 2 min | 16 min |
| Editors, multiplexers | 2 min | 18 min |
| CLAUDE.md | 2 min | 20 min |
| dev-session + setup.sh | 3 min | 23 min |
| Q&A | 7 min | 30 min |

**Total: ~23 min presentation + Q&A fits a 30 min slot**

---

## Pre-Demo Checklist

- [ ] Terminal font has Nerd Font icons (JetBrains Mono Nerd Font recommended)
- [ ] Terminal window maximized / large enough
- [ ] Ghostty installed on local Mac (to show during slide 1)
- [ ] `source ~/.zshrc` done (starship prompt visible)
- [ ] `cd ~/devvm-setup` ready
- [ ] `./demo.sh` tested once to confirm all sections render
- [ ] CLAUDE.md symlinked (`ls -la ~/.claude/CLAUDE.md`)
- [ ] Repo link ready to share in chat
