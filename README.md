# dev.init

Dotfiles and setup scripts for macOS and Linux (Arch).

## Structure

```
├── linux-arch-dotfiles.sh   # Deploy Arch Linux configs
├── linux-arch-run.sh        # Run Arch Linux setup scripts
├── linux-dotfiles.sh        # Deploy generic Linux configs
├── linux-run.sh             # Run generic Linux setup scripts
├── macos-dotfiles.sh        # Deploy macOS configs
├── macos-run.sh             # Run macOS setup scripts
├── dotfiles.sh              # Shared deployment library
├── run.sh                   # Shared script runner library
├── linux/
│   ├── arch/env/            # Arch-specific Hyprland configs
│   ├── common/env/          # Shared Linux dotfiles
│   └── wsl/                 # WSL configs (placeholder)
├── macos/
│   ├── env/                 # macOS configs
│   └── runs/                # macOS setup scripts
└── docker/                  # Docker test environment
```

## Quick Start

```bash
# macOS
./macos-dotfiles.sh [--dry]
./macos-run.sh [--dry]

# Linux Arch
./linux-arch-dotfiles.sh [--dry]
./linux-arch-run.sh [--dry]
```

## Docker Testing

Test the Linux Arch scripts in an isolated Arch Linux container.

### Run tests

```bash
docker buildx build -t devinit-arch -f docker/Dockerfile .
docker run --rm devinit-arch
```

### Or use docker compose

```bash
cd docker

# Run test suite
docker compose run --rm test

# Interactive shell
docker compose run --rm shell
```

### Cleanup

```bash
docker rmi devinit-arch
```

### What the tests verify

1. `linux-arch-run.sh --dry` — exits cleanly (runs/ is empty)
2. `linux-arch-dotfiles.sh --dry` — no filesystem changes
3. `linux-arch-dotfiles.sh` — real deploy to non-root user
4. File verification — checks all expected dirs exist (`~/.config/hypr/`, `~/.config/waybar/`, etc.)

## Notes

- Run with `--dry` to preview changes without applying them.
- Never run `dotfiles.sh` or `run.sh` directly — use the wrapper scripts.
- Linux `runs/` is empty; `linux-run.sh` is a no-op.
