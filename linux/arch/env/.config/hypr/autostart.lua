-- ============================================================
-- Autostart / Startup Applications
-- Source: hyprlang → Lua migration of exec-once entries
-- See: https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- hl.exec_cmd() is always asynchronous — no need for '& disown'.
-- ============================================================

local home       = os.getenv("HOME")
local scriptsDir = home .. "/.config/hypr/scripts"

hl.on("hyprland.start", function()
    -- Initial boot script: applies wallpaper, theming, new settings.
    hl.exec_cmd(home .. "/.config/hypr/initial-boot.sh")

    -- Wallpaper daemon
    hl.exec_cmd("awww query || awww-daemon")

    -- Systemd / dbus environment propagation
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && && systemctl --user start hypridle.service")

    -- Status bar + tray applets
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("swaync")
    -- hl.exec_cmd("blueman-applet")

    -- Clipboard manager (cliphist)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Idle daemon: managed by hypridle.service (systemd user unit)
    -- hl.exec_cmd("hypridle")
end)

-- ============================================================
-- Idle / lock examples (uncomment as desired):
--
-- Lock only (900s idle):
-- hl.on("hyprland.start", function()
--   hl.exec_cmd("swayidle -w timeout 900 '" .. scriptsDir .. "/lock_screen.sh'")
-- end)
--
-- Lock + sleep (900s lock, 1200s dpms off):
-- hl.on("hyprland.start", function()
--   hl.exec_cmd(
--     "swayidle -w" ..
--     " timeout 900  '" .. scriptsDir .. "/lock_screen.sh'" ..
--     " timeout 1200 'hyprctl dispatch dpms off'" ..
--     " resume       'hyprctl dispatch dpms on'" ..
--     " before-sleep '" .. scriptsDir .. "/lock_screen.sh'"
--   )
-- end)
--
-- No lock, dpms only:
-- hl.on("hyprland.start", function()
--   hl.exec_cmd(
--     "swayidle -w" ..
--     " timeout 900 'hyprctl dispatch dpms off'" ..
--     " resume      'hyprctl dispatch dpms on'"
--   )
-- end)
-- ============================================================
