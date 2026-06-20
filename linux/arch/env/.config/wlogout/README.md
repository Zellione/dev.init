# wlogout

Wayland logout / power menu. Triggered by `CTRL + ALT + P` (see
`hypr/.config/hypr/keybinds.lua`); the launcher script lives at
`hypr/.config/hypr/scripts/wlogout.sh`.

## Files

```
wlogout/
├── layout          # Button list, keybinds, action commands, label position
├── style.css       # Glassmorphism surface + button states
├── README.md       # This file
└── icons/
    ├── Makefile    # Renders SVG sources into theme-colored PNGs
    ├── *.png       # Generated, gitignored-friendly (just re-run make)
    └── _source/    # Phosphor Regular SVGs (tracked)
```

## Visual design

- **Glass surface**: a translucent dark wash (`rgba(30, 30, 46, 0.72)`) with
  a soft diagonal gradient and a drop shadow. The actual frosted-blur is
  applied by Hyprland via a layer rule on the `logout_dialog` namespace —
  see `hypr/.config/hypr/window_rules.lua`. CSS `backdrop-filter` is
  unreliable in GTK3 layer-shell, so the compositor rule is what does the
  work.

> **Note:** wlogout hardcodes its layer namespace to `logout_dialog`
> (see `ArtsyMacaw/wlogout` `main.c`: `gtk_layer_set_namespace(win, "logout_dialog")`),
> *not* `wlogout`. If a layer rule doesn't seem to apply, run
> `hyprctl layers` while wlogout is open to confirm the namespace.
- **Buttons**: rounded tiles (`22px` radius), subtle 1px border, and a
  springy hover that scales to `1.06` with a colored glow. Reboot and
  Shutdown get a warm rose-tinted hover (`@color12`) to flag them as
  destructive.
- **Icons**: monochrome Phosphor line-art, colored to match the active
  wallust theme.
- **Labels**: each button shows its `text` from the layout file in the
  bottom band of the tile.

## Button order

Least → most destructive, left to right:

```
lock → logout → suspend → hibernate → reboot → shutdown
```

## Regenerating icons after a wallpaper / theme change

The PNGs in `icons/` are produced from the SVGs in `icons/_source/`.
Colors are read from `../waybar/wallust/colors-waybar.css` (regenerated
by `wallust` when the wallpaper changes).

```sh
cd hypr/.config/wlogout/icons
make            # generate PNGs
make print-colors   # sanity-check the resolved palette
make clean      # remove generated PNGs
```

Requirements: `rsvg-convert` (`librsvg2-bin`).

Override individual colors without editing the file:

```sh
make COLOR_NORMAL=#ffffff COLOR_HOVER=#ffaa00
```

## Adjusting the look

| Want to change…                | Edit…                                                                  |
| ------------------------------ | ---------------------------------------------------------------------- |
| Surface tint / blur strength   | `hypr/.config/wlogout/style.css` (`window` block) and `look_and_feel.lua` (`decoration.blur`) |
| Button shape / size / hover    | `style.css` (`button` block)                                           |
| Per-button hover accent color  | `style.css` (the `#reboot:hover, #shutdown:hover` rule)                |
| Button order / keybinds        | `layout`                                                               |
| Iconography                    | Replace the SVG in `icons/_source/<name>.svg`, then `make`             |
| Icon color                     | `style.css` (the `#lock` / `#logout` / … rules) — or regenerate PNGs  |

## Resolution scaling

The launcher script (`hypr/.config/hypr/scripts/wlogout.sh`) detects
monitor resolution + scale and passes appropriate `-T` / `-B` margins to
wlogout. CSS values are resolution-independent, so no per-resolution
tweaks are needed.
