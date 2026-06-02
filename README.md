# dev.init

Personal dotfiles and machine setup for macOS (and Linux). See [AGENTS.md](AGENTS.md) for repo architecture and deployment instructions.

---

## macOS shell startup performance

New terminal windows and tmux panes were slow to become interactive (~1–2s) due to blocking operations in `.zshrc` and `.zsh_profile`.

### Fixes applied

**`macos/env/.zshrc`** — Disabled Angular CLI autocompletion on startup:
```zsh
# source <(ng completion script)
```
This was spawning a full Node.js + Angular CLI process on every shell open. If you need `ng` tab-completion, run once to bake the static output into your live `~/.zshrc`:
```bash
ng completion script >> ~/.zshrc
```

**`macos/env/.zsh_profile`** — Replaced `find` loop with explicit sources:
```zsh
# Before (re-sourced env a second time, tried to source the directory itself):
for i in `find -L $PERSONAL`; do source $i; done

# After:
source $PERSONAL/alias
source $PERSONAL/paths
```

Also replaced dynamic fzf path discovery with the stable Homebrew opt symlink:
```zsh
# Before:
fzf_dir=`ls -d /opt/homebrew/Cellar/fzf/* | head -n 1`/shell

# After:
fzf_dir=/opt/homebrew/opt/fzf/shell
```

### Measuring startup time

```bash
time zsh -i -c exit
```

---

## nvim-treesitter v1.0+ migration notes

Neovim 0.12+ is not compatible with the frozen `master` branch of nvim-treesitter. The `main` branch is the v1.0 rewrite that tracks current Neovim.

### What changed in v1.0+

| Concern | `master` (old) | `main` (v1.0+) |
|---|---|---|
| Parser install location | `<plugin>/parser/` | `~/.local/share/nvim/site/parser/` |
| Query install location | `<plugin>/queries/` | `~/.local/share/nvim/site/queries/` |
| Highlighting | `highlight = { enable = true }` module | Native `vim.treesitter.start()` |
| `ensure_installed` option | Supported | **Removed** |
| Build tool | `gcc`/`clang` | `tree-sitter` CLI (required) |
| `require("nvim-treesitter.configs")` | Required | **Removed** |

### Required system dependency

`tree-sitter` CLI must be installed. The Homebrew `tree-sitter` formula is **library-only** and does not include the CLI:

```bash
npm install -g tree-sitter-cli
```

### Plugin spec (lazy.nvim)

```lua
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.install").install({
            "bash", "cpp", "html", "rust",
            "javascript", "typescript", "jsdoc",
            "go", "json",
        })
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                pcall(vim.treesitter.start, ev.buf)
            end,
        })
    end,
}
```

Key points:
- `install()` replaces `ensure_installed` — it is idempotent (no-op if already installed)
- `build = ":TSUpdate"` handles updates after `:Lazy update`
- The `FileType` autocmd activates native Neovim highlighting for every buffer
- Do **not** pass `opts` to `require("nvim-treesitter").setup()` with `ensure_installed` — the option does not exist in v1.0+

### Parsers to exclude from `install()`

Neovim 0.12+ ships these parsers as bundled binaries. Installing them via nvim-treesitter overrides the bundled versions and causes query mismatches:

```
c, lua, vim, vimdoc, markdown, markdown_inline
```

### Errors and their fixes

**`attempt to call method 'range' (a nil value)` in `languagetree.lua`**
Caused by `highlight = { enable = true }` in the config — that module is gone in v1.0+. Fix: remove it and use the `FileType` autocmd above.

**`nvim-treesitter[gomod]: mv: rename ... No such file or directory`**
The `tree-sitter-go-mod` repo switched its default branch from `master` to `main`. The install script extracts the wrong archive name. Fix: remove `gomod`, `gosum`, `gotmpl` from the install list.

**`query.lua: Invalid field name "operator"` for Lua files**
Neovim's bundled `lua` parser is newer than the one nvim-treesitter installs. The installed parser takes rtp precedence and lacks the `operator` field that Neovim's built-in queries expect. Fix: exclude `lua` (and the other bundled parsers above) from the install list, and delete any stale `.so` files from `~/.local/share/nvim/lazy/nvim-treesitter/parser/`.

**Plain-text highlighting (no colors) for all file types**
After migrating from `master`, old parsers linger at `<plugin>/parser/` but queries are never installed to `site/queries/`. `:TSUpdate` with no args reports "all up to date" because it only updates what is already in `site/` (nothing). Fix: delete the stale `.so` files from `<plugin>/parser/` and run `:TSInstall <lang>` (or let the `install()` call in config handle it on next startup).

**`ENOENT: no such file or directory (cmd): 'tree-sitter'`**
The `tree-sitter` CLI is not on PATH. `brew install tree-sitter` installs only the C library. Fix: `npm install -g tree-sitter-cli`.
