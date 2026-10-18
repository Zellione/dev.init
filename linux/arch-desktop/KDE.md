

# KDE desktop settings

## Color scheme

Custom color scheme:
`env/.local/share/color-schemes/ZellDark.colors`

Activate with:

```bash
plasma-apply-colorscheme ZellDark
```

## Dolphin Places

Bookmarks:
`env/.local/share/user-places.xbel`

Contains machine-specific paths and should be reviewed before restoring on another system.

## External terminal

Use Kitty for KDE applications instead of Konsole.

```bash
kwriteconfig6 \
  --file kdeglobals \
  --group General \
  --key TerminalApplication \
  kitty
```

Dolphin's embedded F4 terminal is intentionally unused.
Use "Open Terminal Here" to launch Kitty in the current directory.
