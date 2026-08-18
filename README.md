<div align="center">

# dotfiles

**A zsh environment that boots fast, degrades gracefully, and knows about AI agents.**

[![shell](https://img.shields.io/badge/shell-zsh-89e051?style=flat-square&logo=gnubash&logoColor=white)](https://www.zsh.org/)
[![platform](https://img.shields.io/badge/platform-Debian%20·%20Ubuntu%20·%20Pop!__OS-A81D33?style=flat-square&logo=debian&logoColor=white)](https://www.debian.org/)
[![license](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](#license)

</div>

---

```bash
git clone https://github.com/talpah/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install     # essentials, symlinks, shell switch
make goodies     # Docker, gh, glab, and the modern CLI toolchain
```

## ✨ Highlights

- **🧩 Modular** — `.zshrc` is a loader under 100 lines; the real config lives in numbered `zsh/*.zsh` modules.
- **🛡️ Degrades gracefully** — every tool integration is guarded on the binary actually existing. Clone this onto a bare server and you still get a working shell, not a screen of errors.
- **🤖 Agent-aware** — worktree launcher, context piping, local-model routing for Claude Code.
- **🦀 Rust CLI toolchain** — eza, ripgrep, fd, zoxide, fzf, bat, delta, atuin.
- **🧪 Actually tested** — 32 local assertions plus full installs verified in throwaway Debian and Ubuntu containers.
- **🔒 Never clobbers** — your original files are backed up, and a diverged file gets a timestamped copy rather than being overwritten.

## 📂 Layout

```
.zshrc                 thin loader — sources the modules below
zsh/
  00-path.zsh          PATH construction, Homebrew, the has() helper
  10-env.zsh           environment, pager, locale
  20-aliases.zsh       aliases, including modern command replacements
  30-tools.zsh         fzf, zoxide, atuin, direnv, completions, keybindings
  40-ai.zsh            Claude Code and local-model helpers
  50-motd.zsh          once-a-day cool-apps reminder
zfunc/                 static zsh completions (make completions)
config/ghostty/        terminal emulator config
.gitconfig             included into ~/.gitconfig, never symlinked over it
bin/                   installers, symlinked into ~/bin
test/docker/           container test images and assertions
```

> [!TIP]
> Machine-specific settings belong in `~/.zshrc.local` — sourced last, never tracked.
> When an installer appends something to your shell config, that is where it goes.

## 🛠 Commands

| Command | Does |
| ------- | ---- |
| `make install` | Install dotfiles and essentials |
| `make goodies` | Optional packages and the Homebrew CLI toolchain |
| `make update` | Update oh-my-zsh, p10k, zsh plugins, brew formulae |
| `make completions` | Regenerate `zfunc/` completions |
| `make test` | Full suite: syntax, zsh parse, config validity, shellcheck |
| `make test-docker` | Install and verify in clean containers |
| `make lint` | shellcheck only |
| `make uninstall` | Restore backups, remove symlinks |
| `make clean` | Delete `backup/` — destroys pre-install originals (prompts) |

## ⚡ Modern CLI replacements

Every replacement is guarded on the binary being present, so a machine without
the tool keeps the original command. Escape any alias with a backslash: `\ls`.

| Command | Becomes | Notes |
| ------- | ------- | ----- |
| `ls` | `eza` | `l`, `ll`, `la`, `lt` (tree), `lm` (by mtime) |
| `cd` | `zoxide` | frecency-ranked; `cdi` picks interactively |
| `cat` | `bat` | `catp` for unstyled output |
| `grep` | `ripgrep` | |
| `find` | `fd` | different syntax — `\find` for the original |
| `rm` | `trash-put` | `rml`, `rmr`, `rme` to list / restore / empty |
| `du` | `dust` | `dus` keeps the old `du -sh *` |
| `df` | `duf` | |
| `ps` | `procs` | |
| `top` | `btop` | |

## 🧰 Toolchain

The tools these dotfiles install and configure.

**Shell and prompt**

| | |
| --- | --- |
| [zsh](https://www.zsh.org/) | the shell itself |
| [oh-my-zsh](https://ohmyz.sh/) | plugin and theme framework |
| [powerlevel10k](https://github.com/romkatv/powerlevel10k) | prompt, with instant-prompt support |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | inline suggestions from history |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | highlights the command line as you type |
| [powerline fonts](https://github.com/powerline/powerline) | glyphs the prompt needs |

**Navigation and search**

| | |
| --- | --- |
| [eza](https://eza.rocks) | modern, maintained replacement for `ls` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | navigate the filesystem by frecency |
| [fzf](https://junegunn.github.io/fzf/) | command-line fuzzy finder |
| [fd](https://github.com/sharkdp/fd) | simple, fast, user-friendly alternative to `find` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | fast recursive search that respects `.gitignore` |
| [tree](http://oldmanprogrammer.net/source.php?dir=projects/tree) | indented directory tree |

**Viewing and inspection**

| | |
| --- | --- |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting and git integration |
| [dust](https://github.com/bootandy/dust) | more intuitive `du` |
| [duf](https://github.com/muesli/duf) | better `df` |
| [procs](https://github.com/dalance/procs) | modern replacement for `ps` |
| [btop](https://github.com/aristocratos/btop) | resource monitor |
| [mc](https://www.midnight-commander.org) | Midnight Commander file manager |

**Git and diff**

| | |
| --- | --- |
| [git-delta](https://dandavison.github.io/delta/) | syntax-highlighting pager for git and diff |
| [difftastic](https://difftastic.wilfred.me.uk/) | diff that understands syntax — `git dft` |
| [lazygit](https://github.com/jesseduffield/lazygit/) | terminal UI for git |
| [gh](https://github.com/cli/cli) | GitHub CLI |
| [glab](https://gitlab.com/gitlab-org/cli) | GitLab CLI |

**Data and text**

| | |
| --- | --- |
| [jq](https://jqlang.github.io/jq/) | command-line JSON processor |
| [yq](https://github.com/mikefarah/yq) | YAML, JSON, XML, CSV and properties |
| [sd](https://github.com/chmln/sd) | intuitive find and replace |
| [ast-grep](https://ast-grep.github.io/) | structural code search, linting, rewriting |

**History, safety and docs**

| | |
| --- | --- |
| [atuin](https://atuin.sh/) | searchable, syncable shell history |
| [trash-cli](https://github.com/andreafrancia/trash-cli) | send files to the trash instead of deleting |
| [tldr](https://tldr.sh/) | simplified, community-driven man pages |

**Dev and ops**

| | |
| --- | --- |
| [Docker](https://www.docker.com) | containers, with the compose v2 plugin |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | terminal UI for docker |
| [shellcheck](https://www.shellcheck.net/) | shell script linter — used by `make lint` |
| [hyperfine](https://github.com/sharkdp/hyperfine) | command-line benchmarking |
| [tilix](https://gnunn1.github.io/tilix-web/) | tiling terminal emulator |
| [vim](https://www.vim.org/) | `$EDITOR` |

> [!NOTE]
> **atuin needs a one-time import.** It starts with an empty database, so your
> existing shell history stays invisible to <kbd>Ctrl</kbd>+<kbd>R</kbd> until you run:
> ```bash
> atuin import auto
> ```

## ⌨️ Shell integration

| | |
| --- | --- |
| <kbd>Ctrl</kbd>+<kbd>T</kbd> | fuzzy file finder, with a `bat` preview |
| <kbd>Ctrl</kbd>+<kbd>R</kbd> | history search — `atuin` when installed, else `fzf` |
| <kbd>Alt</kbd>+<kbd>C</kbd> | fuzzy `cd`, with an `eza` tree preview |
| <kbd>Ctrl</kbd>+<kbd>Space</kbd> | accept the autosuggestion |
| <kbd>Ctrl</kbd>+<kbd>B</kbd> / <kbd>Ctrl</kbd>+<kbd>Y</kbd> | zsh-navigation-tools cd / kill widgets |

Candidate lists come from `fd`, so `.gitignore` is respected.
`direnv` and `mise` activate automatically when present.

## 🤖 AI tooling

All of these are no-ops when `claude` is not installed.

| Alias / function | Does |
| ---------------- | ---- |
| `cc` | `claude` |
| `ccy` | `--dangerously-skip-permissions` |
| `ccr` / `ccc` | resume / continue |
| `ccp` | one-shot print mode |
| `ccw <branch>` | create a git worktree for the branch and open claude in it |
| `cx <file\|-> [prompt]` | pipe files or stdin into claude as context |
| `gdc [args]` | send `git diff` to claude for review |
| `cc-local` / `cc-ollama` | route claude at LM Studio (`:1234`) or Ollama (`:11434`) |
| `ai-models` | list what the local backends currently serve |

`ccw` keeps the main clone clean while an agent works — worktrees land in
`../<repo>-worktrees/<branch>/`.

```bash
ccw fix/login-retry           # branch + worktree + claude, in one go
kubectl logs pod | cx - "what is failing here?"
gdc HEAD~3                    # review the last three commits
```

## 🌳 Git configuration

`install.sh` sets `include.path` rather than symlinking, so your own
`~/.gitconfig` keeps identity and credentials while this file layers on top.

<details>
<summary><b>What it changes</b></summary>

- **[delta](https://github.com/dandavison/delta)** as pager and interactive diff filter, both in shell-fallback form so a machine without delta degrades to `less` rather than erroring
- `rerere` with `autoUpdate` — remembers conflict resolutions
- `rebase.updateRefs` — keeps stacked branches in sync
- `branch.sort = -committerdate`, `tag.sort = version:refname`, `column.ui = auto`
- `maintenance.auto`, `fetch.writeCommitGraph`, `core.untrackedCache`
- `diff.algorithm = histogram`, `colorMoved`, `renames = copies`, `mnemonicPrefix`
- Safety: `pull.ff = only`, fsck on transfer and receive
- Worktree aliases (`wt`, `wtl`, `wta`, `wtr`) to pair with `ccw`
- [difftastic](https://github.com/Wilfred/difftastic) behind `git dft` / `git dfts`
- `wip` / `unwip` for scratch commits, plus `recent`, `staged`, `unstage`, `discard`, `fixup`

</details>

## 🧪 Testing

```bash
make test           # local: syntax, zsh parse, config validity, shellcheck
make test-docker    # install into throwaway containers and verify
```

`make test-docker` installs the working tree into clean containers. Each one
gets passwordless `sudo` **and** passwordless `chsh`, so the shell switch is
exercised rather than silently skipped.

| Image | Covers |
| ----- | ------ |
| `debian:trixie-slim` | `install.sh` end to end, from a base with no zsh, git or curl |
| `ubuntu:24.04` | the same apt path on a different base |

```bash
./test-docker.sh            # everything
./test-docker.sh debian     # a subset
KEEP=1 ./test-docker.sh     # keep containers to poke at
```

## 📋 Requirements

- Debian, Ubuntu, or Pop!_OS — the installers are apt-only
- sudo access
- [Homebrew](https://brew.sh/) for the modern CLI toolchain (`make goodies` tells you if it is missing)

## License

MIT
