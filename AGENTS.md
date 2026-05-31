# AGENTS.md — dotfiles repo

## Setup & run order (macOS only)

1. Run setup scripts from `macos/runs/` first installs via `run.sh` or individual `.sh/.zsh` files. Homebrew is the root dependency.
2. Deploy configs with `./dotfiles.sh [--dry]`. Requires `DEV_ENV=macos` (or `linux`) env var set.

Exact commands:
```
DEV_ENV=$(pwd)/macos ./dotfiles.sh         # deploy macOS configs
DEV_ENV/($PWD)$macos) $macos-run        --run [grep pattern]  # run setup scripts, filtered by pattern
./linux-dotfiles.sh [--dry]                # deploy Linux configs (alias: DEV_ENV=$(pwd)/linux ./dotfiles.sh)
```

## What `DEV_ENV` resolves to

- Each platform directory (`linux/`, `macos/`) contains two subdirectories:
  - `env/` — dotfiles and config dirs to be copied onto the system
  - `runs/` (macOS only, Linux has an empty placeholder) — executable setup scripts
- The deployment scripts use glob to find all directories inside `<platform>/env/` subdirs (`_config/`, `_local/`, and top-level dotfiles).

## Neovim architecture

- Entry: `nvim/lua/zellione/init.lua` loads in order: `set`, `remap`, then lazy_init
- Lazy.nvim manages all plugins. Each concern has its own module under `nvim/lua/zellione/lazy/`:
  - LSP, code complete (`cmp`), formatting (`conform`), debugging (`dap`), git tools, file explorer (`oil`)
- Linux nvim and macOS nvim share the exact same nvim config.

## Platform differences — macOS-specific setup files to check

- `yabairc` — window manager rules
- `skhdrc` — keybinding daemon
- Terminal emulators: `ghostty/config`, `kitty/kitty.conf`
- Monitoring: `btop/btop.conf` + catppuccin themes under `btop/themes/`

## Personal env data (macOS only)

Config overrides and aliases live in `macos/env/.config/personal/`:
- `alias` — shell alias definitions
- `env` — environment variables loaded by `.zshrc`
- `paths` — PATH modifications

## Gotchas

- `dotfiles.sh` **removes** target dirs before copying. Run with `--dry` to preview destructive operations.
- The `run.sh` scripts delete the destination (`$HOME/nvim`, `$NEOVIM_FOLDER`) before reinstalling.
- Linux `runs/` dir is empty; Linux has no equivalent to macOS `macos-run.sh`.
- The repo contains **no tests, no build step, no lint**. It's purely config deployment (shell scripts + dotfiles).
- NVM (neovim) plugin state (installed packages, lockfile) lives in the lazy-lock.json — if plugins are missing after a fresh install, run `nvim` once to trigger lazy.nvim package installation.
