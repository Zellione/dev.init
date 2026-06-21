# dev.init

Dotfiles and setup scripts for macOS, Arch Linux, and WSL-Ubuntu.

## Structure

```
├── linux-arch-dotfiles.sh           # Deploy Arch Linux configs
├── linux-arch-run.sh                # Run Arch Linux setup scripts
├── linux-wsl-ubuntu-dotfiles.sh     # Deploy WSL-Ubuntu configs
├── linux-wsl-ubuntu-run.sh          # Run WSL-Ubuntu setup scripts
├── linux-dotfiles.sh                # Deploy generic Linux configs
├── linux-run.sh                     # Run generic Linux setup scripts
├── macos-dotfiles.sh                # Deploy macOS configs
├── macos-run.sh                     # Run macOS setup scripts
├── lib/
│   ├── dotfiles.sh                  # Shared deployment library
│   ├── run.sh                       # Shared script runner library
│   └── tags.sh                      # Tag filtering helpers
├── common/env/                      # Cross-platform dotfiles (nvim, btop, …)
├── linux/
│   ├── arch/env/                    # Arch-specific Hyprland configs
│   ├── arch/runs/                   # Arch setup scripts
│   ├── common/env/                  # Shared Linux dotfiles
│   └── wsl/ubuntu/                  # WSL-Ubuntu configs
│       ├── env/                     # Ubuntu dotfiles
│       └── runs/                    # Ubuntu setup scripts
├── macos/
│   ├── env/                         # macOS configs
│   └── runs/                        # macOS setup scripts
└── docker/                          # Docker test environments
    ├── Dockerfile.arch              # Arch integration test
    ├── Dockerfile.arch-tags         # Arch tag filtering test
    ├── Dockerfile.ubuntu-wsl        # Ubuntu integration test
    ├── Dockerfile.ubuntu-wsl-tags   # Ubuntu tag filtering test
    ├── test-entrypoint-arch.sh      # Arch test suite
    ├── test-entrypoint-ubuntu-wsl.sh# Ubuntu test suite
    ├── test-tags-arch.sh            # Arch tag tests
    ├── test-tags-ubuntu-wsl.sh      # Ubuntu tag tests
    └── docker-compose.yml           # Compose orchestrator
```

## Quick Start

```bash
# macOS
./macos-dotfiles.sh [--dry] [--tags tag1,tag2]
./macos-run.sh [--dry] [--tags tag1,tag2]

# Linux Arch
./linux-arch-dotfiles.sh [--dry] [--tags tag1,tag2]
./linux-arch-run.sh [--dry] [--tags tag1,tag2]

# WSL-Ubuntu
./linux-wsl-ubuntu-dotfiles.sh [--dry] [--tags tag1,tag2]
./linux-wsl-ubuntu-run.sh [--dry] [--tags tag1,tag2]
```

## Docker Testing

Test scripts in isolated Docker containers before running on your host.

### Arch Linux

```bash
# Full integration test
docker buildx build -t devinit-arch -f docker/Dockerfile.arch .
docker run --rm devinit-arch

# Tag filtering test
docker buildx build -t devinit-arch-tags -f docker/Dockerfile.arch-tags .
docker run --rm devinit-arch-tags
```

Or use docker compose:

```bash
cd docker

# Run test suite
docker compose run --rm test-arch

# Interactive shell for debugging
docker compose run --rm shell-arch

# Tag filtering test
docker compose run --rm test-arch-tags
```

### WSL-Ubuntu

```bash
# Full integration test
docker buildx build -t devinit-ubuntu-wsl -f docker/Dockerfile.ubuntu-wsl .
docker run --rm devinit-ubuntu-wsl

# Tag filtering test
docker buildx build -t devinit-ubuntu-wsl-tags -f docker/Dockerfile.ubuntu-wsl-tags .
docker run --rm devinit-ubuntu-wsl-tags
```

Or use docker compose:

```bash
cd docker

# Run test suite
docker compose run --rm test-ubuntu

# Interactive shell for debugging
docker compose run --rm shell-ubuntu

# Tag filtering test
docker compose run --rm test-ubuntu-tags
```

### Cleanup

```bash
docker rmi devinit-arch devinit-arch-tags devinit-ubuntu-wsl devinit-ubuntu-wsl-tags
```

### What the tests verify

**Arch Linux:**
1. `linux-arch-run.sh --dry` — exits cleanly
2. `linux-arch-dotfiles.sh --dry` — no filesystem changes
3. `linux-arch-dotfiles.sh` — real deploy to non-root user
4. File verification — checks all expected dirs (`~/.config/hypr/`, `~/.config/waybar/`, etc.)
5. Binary verification — checks installed packages (Hyprland, neovim, kitty, etc.)

**WSL-Ubuntu:**
1. `linux-wsl-ubuntu-run.sh --dry` — exits cleanly
2. `linux-wsl-ubuntu-dotfiles.sh --dry` — no filesystem changes
3. `linux-wsl-ubuntu-dotfiles.sh` — real deploy to non-root user
4. File verification — checks configs (`~/.zshrc`, `~/.tmux.conf`, `~/.config/nvim/`, etc.)
5. Binary verification — checks installed packages (zsh, tmux, neovim, Go, Rust, etc.)
6. Font verification — Fira Code and JetBrains Mono installed

## Notes

- Run with `--dry` to preview changes without applying them.
- Never run `dotfiles.sh` or `run.sh` directly — use the wrapper scripts.
- Linux `runs/` is empty; `linux-run.sh` is a no-op.
