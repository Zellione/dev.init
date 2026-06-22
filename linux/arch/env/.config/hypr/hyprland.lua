-- ============================================================
-- Modular Hyprland Lua config
-- All modules live flat in ~/.config/hypr/ (no lua/ subdir).
-- ============================================================

-- Absolute package.path so require() resolves regardless of how
-- Hyprland was launched.
local hypr_dir = os.getenv("HOME") .. "/.config/hypr"
package.path   = hypr_dir .. "/?.lua;" .. package.path

-- Each require() is a separate Lua scope: an error in one file
-- does NOT stop execution of the others.
require("env")
require("monitors")
require("input")
require("look_and_feel")
require("window_rules")
require("keybinds")
require("autostart")
