# AGENTS.md — dotfiles repo

## Architecture overview

Libraries define functions; wrappers set `DEV_ENV`, source the library, then call its main function.

| Library | Wrapper(s) | Main function called |
|---|---|---|
| `dotfiles.sh` | `macos-dotfiles.sh`, `linux-dotfiles.sh` | `deploy_dotfiles "$@"` |
| `run.sh` | `macos-run.sh`, `linux-run.sh` | `run_scripts "<pattern>"` |

Libraries have source guards — they refuse to run if executed directly. They only become useful when sourced by a wrapper.

## Setup & run order (macOS only)

1. Run setup scripts from `macos/runs/` first — they install via Homebrew (the root dependency).
2. Deploy configs after that.

Exact commands:
```bash
./macos-dotfiles.sh [--dry]     # deploy macOS configs
./linux-dotfiles.sh [--dry]      # deploy Linux configs
./macos-run.sh [--dry] [grep]    # run macOS setup scripts, filtered by grep pattern

# Or use absolute paths from anywhere in the repo:
/home/zellione/dev\.init/macos-dotfiles.sh --dry
```

## Tool path gotcha — escaping `.` in file tool paths

**File tools (glob/read/write/grep) treat `.` as a glob wildcard, breaking paths containing it.**
The repo itself is named `dev.init`, so:

- ❌ `read`/`glob` on `/home/zellione/dev.init/foo.sh` — may fail silently or match wrong files
- ✅ Use `bash` commands for all `.sh` file I/O — they handle unescaped paths correctly

If you need to search the repo, prefer `_bash_` (not glob/read) when the path includes `dev\.init`:
```bash
cat /home/zellione/dev.init/macos-dotfiles.sh   # works fine in bash
grep -r "pattern" /home/zellione/dev.init/      # works fine in bash
find /home/zellione/dev.init -name "*.sh"       # works fine in bash
```

## What `DEV_ENV` resolves to

- Each platform directory (`linux/`, `macos/`) contains two subdirectories:
  - `env/` — dotfiles and config dirs to be copied onto the system
  - `runs/` (macOS only, Linux has empty) — executable setup scripts
- The deployment scripts find all directories inside `<platform>/env/` (`_config/`, `_local/`, and top-level dotfiles).

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

## Testing Linux Arch changes

**Always test Linux Arch script changes in the Docker container** — never run `linux-arch-dotfiles.sh` or `linux-arch-run.sh` directly on the host.

```bash
docker build -t devinit-arch -f docker/Dockerfile .
docker run --rm devinit-arch
```

Or use docker compose:
```bash
cd docker && docker compose run --rm test
```

The container runs as `testuser` (non-root), tests both dry-run and real deploy, and verifies all expected config dirs exist under `$HOME/.config/`.

## Gotchas

- `dotfiles.sh` **removes** target dirs before copying. Run with `--dry` to preview destructive operations.
- The `run.sh` scripts delete the destination (`$HOME/nvim`, `$NEOVIM_FOLDER`) before reinstalling.
- Linux `runs/` dir is empty; `linux-run.sh` exits with an error if called directly.
- The repo contains **no tests, no build step, no lint**. It's purely config deployment (shell scripts + dotfiles).
- Neovim plugin state (installed packages, lockfile) lives in the lazy-lock.json — if plugins are missing after a fresh install, run `nvim` once to trigger lazy.nvim package installation.
- **Never execute `dotfiles.sh` or `run.sh` directly** — they will refuse with an error because of source guards. Always use the wrapper scripts (`./macos-dotfiles.sh`, etc.).
- **Never execute any of the `dotfiles-macos.sh` or `run-macos.sh`** without asking.
- **Always** use DRY_RUN if trying to execute a script.
