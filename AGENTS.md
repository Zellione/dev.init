# AGENTS.md — dotfiles repo

## Architecture overview

Libraries (`lib/`) define functions; root-level wrappers set `DEV_ENV`, source the library, then call its main function. Library files live in `lib/` so it's obvious they're not meant to be executed directly.

| Library | Wrapper(s) | Main function called |
|---|---|---|
| `lib/dotfiles.sh` | `macos-dotfiles.sh`, `linux-dotfiles.sh`, `linux-arch-dotfiles.sh` | `deploy_dotfiles "$@"` |
| `lib/run.sh` | `macos-run.sh`, `linux-run.sh`, `linux-arch-run.sh` | `run_scripts "<pattern>"` |
| `lib/tags.sh` | (sourced by both lib/dotfiles.sh and lib/run.sh) | tag matching helpers |

Libraries have source guards — they refuse to run if executed directly. They only become useful when sourced by a wrapper.

## Setup & run order (macOS only)

1. Run setup scripts from `macos/runs/` first — they install via Homebrew (the root dependency).
2. Deploy configs after that.

Exact commands:
```bash
./macos-dotfiles.sh [--dry] [--tags tag1,tag2]     # deploy macOS configs
./linux-dotfiles.sh [--dry] [--tags tag1,tag2]      # deploy Linux configs
./linux-arch-dotfiles.sh [--dry] [--tags tag1,tag2] # deploy Arch-specific configs
./macos-run.sh [--dry] [--tags tag1,tag2] [grep]    # run macOS setup scripts
./linux-arch-run.sh [--dry] [--tags tag1,tag2]       # run Arch setup scripts

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

- Entry: `common/env/.config/nvim/lua/zellione/init.lua` loads in order: `set`, `remap`, then `lazy_init`
- Lazy.nvim manages all plugins. Each concern has its own module under `common/env/.config/nvim/lua/zellione/lazy/`:
  - LSP, code complete (`cmp`), formatting (`conform`), debugging (`dap`), git tools, file explorer (`oil`)
- Linux nvim and macOS nvim share the exact same nvim config (lives under `common/env/.config/nvim/` and is deployed to both platforms).

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

Full integration test (installs packages, verifies configs):
```bash
docker buildx build -t devinit-arch -f docker/Dockerfile .
docker run --rm devinit-arch
```

Tag filtering test (minimal container, dry-run only):
```bash
docker buildx build -t devinit-tags -f docker/Dockerfile.tags .
docker run --rm devinit-tags
```

Or use docker compose:
```bash
cd docker && docker compose run --rm test
```

The full container runs as `testuser` (non-root), tests both dry-run and real deploy, and verifies all expected config dirs exist under `$HOME/.config/`.

After testing, clean up the build image:
```bash
docker rmi devinit-arch devinit-tags
```

## Tag filtering

Config dirs, run scripts, and standalone files can be tagged to control what gets deployed/executed.

### How tags work

- **Config dir** (`env/.config/` subdirs): a `.tag` file inside the directory lists its tags
- **Run script** (`runs/`): a sidecar `.tag` file or a `# TAGS:` header on line 3
- **Standalone file** (deployed via `deploy_file`): a sidecar `.tag` file beside it

Tag format: comma-separated, e.g. `hyprland,ui`.

### CLI usage

```bash
./linux-arch-dotfiles.sh --dry --tags hyprland        # only hyprland items
./linux-arch-dotfiles.sh --dry --tags hyprland,screenshot  # OR matching
./linux-arch-dotfiles.sh --dry                         # everything (backward compat)
```

- No `--tags` → everything deploys/runs (backward compatible)
- `--tags hyprland` → only items tagged `hyprland`
- `--tags hyprland,screenshot` → items matching **any** tag (OR logic)

### Adding a .tag file

```bash
echo "hyprland,ui" > linux/arch/env/.config/waybar/.tag
echo "packages" > linux/arch/runs/02-packages.sh.tag
echo "shell" > linux/arch/env/.zshrc.tag
```

## Gotchas

- `dotfiles.sh` **removes** target dirs before copying. Run with `--dry` to preview destructive operations.
- The `run.sh` scripts delete the destination (`$HOME/nvim`, `$NEOVIM_FOLDER`) before reinstalling.
- Linux `runs/` dir is empty; `linux-run.sh` exits with an error if called directly.
- The repo contains **no tests, no build step, no lint**. It's purely config deployment (shell scripts + dotfiles).
- Neovim plugin state (installed packages, lockfile) lives in the lazy-lock.json — if plugins are missing after a fresh install, run `nvim` once to trigger lazy.nvim package installation.
- **Never execute `dotfiles.sh` or `run.sh` directly** — they will refuse with an error because of source guards. Always use the wrapper scripts (`./macos-dotfiles.sh`, etc.).
- **Never execute any of the `dotfiles-macos.sh` or `run-macos.sh`** without asking.
- **Always** use DRY_RUN if trying to execute a script.
