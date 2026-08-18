# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for Debian/Ubuntu/Pop!_OS, installed by symlinking files from this repo into `$HOME`. The repo is the source of truth; `$HOME` holds only links back here.

## Commands

```bash
make install      # install.sh: essentials + symlinks + chsh to zsh
make goodies      # bin/install_goodies.sh: apt packages + Homebrew CLI tools
make test         # full suite: bash -n, zsh -n, config validity, shellcheck
make lint         # shellcheck only
make completions  # regenerate zfunc/ from installed tools
make update       # pull oh-my-zsh, p10k, custom plugins, brew upgrade
make uninstall    # restore backups, remove symlinks (interactive)
make clean        # wipe backup/ (destroys pre-install originals — prompts first)

shellcheck -x install.sh       # single check; -x is required (install.sh sources bin/)
zsh -n zsh/30-tools.zsh        # single zsh module parse check
```

`make test` runs locally and must be green before committing. `make test-docker`
additionally installs the tree into clean containers — use it for anything
touching `install.sh`, the module load order, or a tool guard, since those
failure modes only appear on a machine that lacks the tools.

Container tests live in `test/docker/`: one `Dockerfile.<distro>` per image and
`assert.sh`, which runs inside and has a single path — every image is apt-based,
because the installers support nothing else. Adding a non-apt distro means
adding real package-manager support first, not a test. Containers get
passwordless `chsh` via a `pam_permit` line, without which the shell switch
silently no-ops and goes untested. Note `test-docker.sh` lives at the top level,
not in `bin/` — `install.sh` symlinks everything in `bin/` into `~/bin`.

## Architecture

### Shell config is a loader plus modules

`.zshrc` is a thin loader. It sets up oh-my-zsh, shell options, and then sources `zsh/*.zsh` in lexical order. Real configuration lives in the modules:

| Module | Holds | Depends on |
| --- | --- | --- |
| `00-path.zsh` | `add_to_path` helper, brew shellenv, all PATH entries | — |
| `10-env.zsh` | locale, `EDITOR`, pager/`MANPAGER`, tool env vars | — |
| `20-aliases.zsh` | aliases, incl. modern command replacements | 00 (tools must be on PATH) |
| `30-tools.zsh` | fzf, zoxide, atuin, direnv, mise, completions, keybindings | 00 |
| `40-ai.zsh` | Claude Code helpers, local-model routing | 00 |
| `50-motd.zsh` | once-a-day cool-apps reminder | 20 (uses `command cat`) |

**Ordering is load-bearing.** `00-path.zsh` runs brew shellenv first because `fd`, `rg`, `fzf`, `zoxide`, `eza` and `delta` all live in Homebrew — every later `command -v` probe depends on it. Modules load *after* `source $ZSH/oh-my-zsh.sh`, so repo aliases deliberately win over oh-my-zsh's (this is how `ls`→eza beats omz's `ls --color=tty`, and how `duf` gets unaliased from `common-aliases`).

Two things must stay in `.zshrc` itself and cannot move into a module:

- **`fpath+=zfunc`** — oh-my-zsh runs `compinit` during its own sourcing, so custom completion dirs must join `fpath` before that line.
- **p10k instant prompt** — must be the first thing that could produce output.

`zsh-syntax-highlighting` must remain last in the `plugins` array; it wraps widgets defined by everything before it.

### Everything is presence-guarded

Every alias and integration is wrapped in `has <tool>` — the helper defined in `00-path.zsh`, which tests `$commands` and therefore matches **only real external binaries**. A machine with none of the modern tools still gets a working shell with the original commands, which is what makes the repo safe to clone onto a bare server. Preserve this pattern when adding anything.

Do **not** guard with `command -v`: in zsh it also matches aliases and functions, and oh-my-zsh's `common-aliases` plugin defines `fd` and `duf` as fallback aliases precisely when those binaries are absent. Probing with `command -v` reported them as installed and aliased `find`/`df` to commands that did not exist. `test.sh` fails if a `command -v` probe reappears in the modules.

Debian/Ubuntu binary-name skew is handled explicitly: `bat` is `batcat`, `fd` is `fdfind`. Blocks probe for both. Homebrew is preferred in `install_goodies.sh` precisely because it avoids this skew.

### Path resolution

`.zshrc` derives the repo location from its own symlink:

```zsh
DOTFILES="${${(%):-%N}:A:h}"
```

`%N` is the sourced file, `:A` resolves the symlink, `:h` takes the directory. The repo therefore works from any location — do not reintroduce hardcoded `~/.dotfiles` or `/home/<user>` paths. `test.sh` asserts this (the only permitted `/home/` literal is `/home/linuxbrew`, a fixed system path).

### Install layers

`install.sh` applies three layers in order:

1. **`bin/install_essentials.sh`** — *sourced*, not executed, so its `set -euo pipefail` and log functions apply to the caller. Installs apt packages, oh-my-zsh (downloaded to a temp file then run `--unattended`, never `curl | sh`), powerlevel10k, and the custom zsh plugins.
2. **Symlinking** — three mechanisms, each with its own list:
   - `DOTFILES=(.zshrc)` in `install.sh` → `~/.zshrc`
   - `APPS=(ghostty)` in `install.sh` → `~/.config/ghostty`
   - everything in `bin/` → `~/bin/` (auto-globbed, no list to maintain)

   Adding a new dotfile means editing the array in **both** `install.sh` and `uninstall.sh` — they duplicate the lists and will silently fail to clean up otherwise. The `zsh/` directory is *not* symlinked; `.zshrc` sources it from the repo directly.
3. **`.gitconfig`** is not symlinked. `install.sh` runs `git config --global include.path <repo>/.gitconfig`, so the user's own `~/.gitconfig` keeps identity and credentials while this file layers on top. `uninstall.sh` unsets `include.path` unconditionally, which would clobber an unrelated include if one existed.

**Backups.** Originals move to `backup/` before being replaced. The first backup is treated as the pristine original and is never overwritten; if a second, diverged file appears later it is preserved with a timestamp suffix rather than dropped. `make clean` deletes all of it permanently and now prompts before doing so.

**OS detection** lives only in `install_goodies.sh`: it sources `/etc/os-release` and maps `ID=pop` → `ubuntu` for apt repo URLs (Pop!_OS has no upstream repos of its own). `install_essentials.sh` only checks that `apt-get` exists.

## Conventions

- Installers are `#!/usr/bin/env bash` + `set -euo pipefail` (`test.sh` omits `-e` deliberately — it must survive failing assertions to print a summary). They stay bash, not zsh, because they run during bootstrap before zsh is guaranteed present. The `zsh/` modules are the only zsh files.
- The colour constants and `log_info`/`log_warn`/`log_error` trio are redefined per script rather than shared. `install.sh` and `uninstall.sh` carry `# shellcheck disable=SC2317` above them because sourcing makes them look unreachable.
- Everything is idempotent: check for the symlink, keyring, directory or brew formula before acting, and log "already …" otherwise.

## Gotchas

- **`.gitignore` is a single `*`.** Every untracked file is ignored. New files must be added with `git add -f` and never appear in `git status`. This is intentional — generated artifacts like `zfunc/_ruff` and `backup/` contents stay out of the repo for free — but it means new source files are easy to forget.
- **`~/.zshrc` is a symlink into this repo**, so any installer that appends to it writes into the working tree. `~/.zshrc.local` exists to absorb that; it is sourced last and untracked. When `git diff .zshrc` shows something unexpected, it was probably an installer — move it to `~/.zshrc.local`.
- **`core.pager` and `interactive.diffFilter` use shell fallback forms** (`delta 2>/dev/null || less -FRX`). Do not simplify them to a bare `delta` — that breaks git on any machine where delta is not installed.
