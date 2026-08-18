# dotfiles

Modern development environment: zsh + [Oh My Zsh](https://ohmyz.sh/) with the
[Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme, a Rust-based CLI
toolchain, and shell integration for AI coding agents.

## Quick Start

```bash
git clone https://github.com/talpah/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install     # essentials, symlinks, shell switch
make goodies     # Docker, gh, glab, and the modern CLI tools
```

## Layout

```
.zshrc              thin loader - sources the modules below
zsh/00-path.zsh     PATH construction (Homebrew first)
zsh/10-env.zsh      environment, pager, locale
zsh/20-aliases.zsh  aliases, including modern command replacements
zsh/30-tools.zsh    fzf, zoxide, atuin, direnv, completions, keybindings
zsh/40-ai.zsh       Claude Code and local-model helpers
zsh/50-motd.zsh     once-a-day cool-apps reminder
zfunc/              static zsh completions (make completions)
config/ghostty/     terminal emulator config
.gitconfig          included into ~/.gitconfig, never symlinked over it
bin/                installers, symlinked into ~/bin
```

Machine-specific settings go in `~/.zshrc.local`, which is sourced last and is
never tracked. Anything an installer appends to your shell config belongs there.

## Commands

```bash
make help          # list targets
make install       # install dotfiles and essentials
make goodies       # optional packages and Homebrew CLI tools
make update        # update oh-my-zsh, p10k, zsh plugins, brew formulae
make completions   # regenerate zfunc/ completions
make test          # full suite: syntax, zsh parse, config validity, shellcheck
make test-docker   # install and verify in clean containers (needs docker)
make lint          # shellcheck only
make uninstall     # restore backups, remove symlinks
make clean         # delete backup/ (destroys pre-install originals - prompts)
```

## Container testing

`make test-docker` installs the working tree into throwaway containers and
verifies the result. Each container gets passwordless `sudo` **and**
passwordless `chsh`, so the shell switch is exercised rather than skipped.

| Image | Covers |
| ----- | ------ |
| `debian:trixie-slim` | `install.sh` end to end from a base with no zsh, git or curl |
| `ubuntu:24.04` | the same apt path on a different base |

```bash
./test-docker.sh            # everything
./test-docker.sh debian     # a subset
KEEP=1 ./test-docker.sh     # keep containers to poke at
```

## Modern CLI replacements

Every replacement is guarded on the binary being present, so a machine without
the tool keeps the original command. Escape any alias with a backslash: `\ls`.

| Command | Replaced by | Notes                                  |
| ------- | ----------- | -------------------------------------- |
| `ls`    | `eza`       | `l`, `ll`, `la`, `lt` (tree), `lm`     |
| `cd`    | `zoxide`    | frecency-ranked; `cdi` picks interactively |
| `cat`   | `bat`       | `catp` for unstyled output             |
| `grep`  | `ripgrep`   |                                        |
| `find`  | `fd`        |                                        |
| `rm`    | `trash-put` | `rml`, `rmr`, `rme` to list/restore/empty |
| `du`    | `dust`      | `dus` keeps the old `du -sh *`         |
| `df`    | `duf`       |                                        |
| `ps`    | `procs`     |                                        |
| `top`   | `btop`      |                                        |

## Shell integration

- **fzf** — `Ctrl+T` files (with bat preview), `Ctrl+R` history, `Alt+C` cd
  (with tree preview). Candidate lists come from `fd`, so `.gitignore` is respected.
- **atuin** — takes over `Ctrl+R` when installed; up-arrow stays with zsh history.
- **zsh-autosuggestions** — `Ctrl+Space` accepts the suggestion.
- **zsh-syntax-highlighting** — loaded last, as it requires.
- **direnv**, **mise** — activated when present.

## AI tooling

Claude Code helpers (all no-ops when `claude` is not installed):

| Alias / function | Does                                                    |
| ---------------- | ------------------------------------------------------- |
| `cc`             | `claude`                                                |
| `ccy`            | `--dangerously-skip-permissions`                        |
| `ccr` / `ccc`    | resume / continue                                       |
| `ccp`            | one-shot print mode                                     |
| `ccw <branch>`   | create a git worktree for the branch and open claude in it |
| `cx <file\|-> [prompt]` | pipe files or stdin into claude as context        |
| `gdc [args]`     | send `git diff` to claude for review                    |
| `cc-local`       | route claude at LM Studio (localhost:1234)              |
| `cc-ollama`      | route claude at Ollama (localhost:11434)                |
| `ai-models`      | list models the local backends currently serve          |

`ccw` keeps the main clone clean while an agent works — worktrees land in
`../<repo>-worktrees/<branch>/`.

## Git configuration

`install.sh` sets `include.path` rather than symlinking, so your own
`~/.gitconfig` keeps identity and credentials while this file layers on top.

- **delta** as pager, with a `less` fallback when delta is absent
- `rerere` — remembers conflict resolutions
- `rebase.updateRefs` — keeps stacked branches in sync
- `branch.sort = -committerdate`, `column.ui = auto`, `maintenance.auto`
- `diff.algorithm = histogram`, `colorMoved`, `mnemonicPrefix`
- Safety: `pull.ff = only`, fsck on transfer and receive
- Worktree aliases (`wt`, `wtl`, `wta`, `wtr`), difftastic (`dft`, `dfts`),
  and `wip` / `unwip` for scratch commits

## Requirements

- Debian, Ubuntu, or Pop!_OS
- sudo access
- Homebrew for the modern CLI tools (`make goodies` tells you if it is missing)

## License

MIT
