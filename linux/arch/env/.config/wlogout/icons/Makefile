# Makefile for wlogout icons
#
# Rasterizes SVG sources from _source/ to theme-colored PNGs.
# Colors are read from the wallust-generated colors-waybar.css so the
# icons follow the active wallpaper theme.
#
# Targets:
#   make         - generate all icons (default)
#   make regen   - same as `make`; alias for symmetry with wallust workflow
#   make clean   - remove generated PNGs
#
# Requirements: rsvg-convert (librsvg2-bin)
#
# Notes:
#   - SVGs use stroke="currentColor"; we substitute it with the target hex.
#   - Rendered at 256x256 — wlogout downscales them via background-size.
#   - Override colors at the command line, e.g.:
#       make COLOR_NORMAL=#ffffff COLOR_HOVER=#ffaa00

RSVG      ?= rsvg-convert
SIZE      ?= 256

# Color file (wallust output) — overridable. Resolved relative to this Makefile.
# MAKEFILE_LIST is the makefile's path; $(dir ...) yields the dir with trailing slash.
# From hypr/.config/wlogout/icons/ the wallust css is at ../../waybar/wallust/.
COLORS_CSS := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../../waybar/wallust/colors-waybar.css)

# Default colors (fallback when colors-waybar.css is missing a define)
DEFAULT_NORMAL := #B4BCD6
DEFAULT_HOVER  := #D0D6E8

# Resolved colors (can be overridden on the make command line)
# Use := so the shell function is evaluated at parse time with path correct.
COLOR_NORMAL := $(shell awk '/color7/ {print $$3}' '$(COLORS_CSS)' 2>/dev/null | tr -d ';' )
COLOR_HOVER  := $(shell awk '/foreground/ {print $$3}' '$(COLORS_CSS)' 2>/dev/null | tr -d ';' )

ifeq ($(COLOR_NORMAL),)
COLOR_NORMAL := $(DEFAULT_NORMAL)
endif
ifeq ($(COLOR_HOVER),)
COLOR_HOVER := $(DEFAULT_HOVER)
endif

ICONS := lock logout reboot shutdown suspend hibernate

# Generated PNGs: <icon>.png and <icon>-hover.png
PNGS := $(foreach i,$(ICONS),$(i).png $(i)-hover.png)

# Source SVGs in _source/
SVGS := $(foreach i,$(ICONS),_source/$(i).svg)

.PHONY: all regen clean print-colors
all: $(PNGS)

regen: all

print-colors:
	@echo "COLOR_NORMAL=$(COLOR_NORMAL)"
	@echo "COLOR_HOVER=$(COLOR_HOVER)"
	@echo "Source: $(COLORS_CSS)"

clean:
	rm -f $(PNGS)

# Generic rule: src=<name>.svg -> out=<name>.png (normal color)
%.png: _source/%.svg
	@echo "  rsvg  $*  ($(COLOR_NORMAL))"
	@sed 's/currentColor/$(COLOR_NORMAL)/g' $< | $(RSVG) -w $(SIZE) -h $(SIZE) - > $@

# Hover variant: <name>.svg -> <name>-hover.png
%-hover.png: _source/%.svg
	@echo "  rsvg  $*  ($(COLOR_HOVER))"
	@sed 's/currentColor/$(COLOR_HOVER)/g' $< | $(RSVG) -w $(SIZE) -h $(SIZE) - > $@
