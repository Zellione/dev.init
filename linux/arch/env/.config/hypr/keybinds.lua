-- ============================================================
-- Keybindings
-- Source: hyprlang → Lua migration of keybinds
-- See: https://wiki.hypr.land/Configuring/Basics/Binds/
--      https://wiki.hypr.land/Configuring/Basics/Dispatchers/
--
-- Bind-type mapping from hyprlang:
--   bind  → (no flags)
--   binde → { repeating = true }
--   bindr → { release   = true }
--   bindm → { mouse     = true }
-- ============================================================

local mainMod    = "SUPER"
local home       = os.getenv("HOME")
local scriptsDir = home .. "/.config/hypr/scripts"
local userScripts = home .. "/.config/hypr/scripts"   -- same dir in this config
local term       = "kitty"
local files      = "thunar"

local rofi_cmd = "pkill rofi || rofi -show drun -modi drun,filebrowser,run,window" ..
                 " -config " .. home .. "/.config/rofi/config-compact.rasi"

-- ---- Launchers ---------------------------------------------

-- Open rofi on key release (bindr); also on plain SUPER+D press
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(rofi_cmd), { release = true })
hl.bind(mainMod .. " + D",       hl.dsp.exec_cmd(rofi_cmd))

-- Terminal + file manager
hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + T",       hl.dsp.exec_cmd(files))

-- ---- Session / WM control -----------------------------------

hl.bind("CTRL + ALT + Delete",   hl.dsp.exit())
hl.bind(mainMod .. " + Q",       hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F",       hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M",       hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
-- NOTE: workspaceopt allfloat was removed in 0.55; toggle_active window only.
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("CTRL + ALT + L",        hl.dsp.exec_cmd(scriptsDir .. "/lock_screen.sh"))
hl.bind("CTRL + ALT + P",        hl.dsp.exec_cmd(scriptsDir .. "/wlogout.sh"))

-- ---- Features / Extras -------------------------------------

hl.bind(mainMod .. " + H",            hl.dsp.exec_cmd(scriptsDir .. "/key_hints.sh"))
hl.bind(mainMod .. " + ALT + R",      hl.dsp.exec_cmd(scriptsDir .. "/refresh.sh"))
hl.bind(mainMod .. " + ALT + E",      hl.dsp.exec_cmd(scriptsDir .. "/rofi_emoji.sh"))
hl.bind(mainMod .. " + SHIFT + B",    hl.dsp.exec_cmd(scriptsDir .. "/change_blur.sh"))
hl.bind(mainMod .. " + SHIFT + G",    hl.dsp.exec_cmd(scriptsDir .. "/game_mode.sh"))
-- hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd(scriptsDir .. "/change_layout.sh"))
hl.bind(mainMod .. " + ALT + V",      hl.dsp.exec_cmd(scriptsDir .. "/clip_manager.sh"))
hl.bind(mainMod .. " + SHIFT + N",    hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SHIFT + ALT_L",              hl.dsp.exec_cmd(scriptsDir .. "/switch_keyboard_layout.sh"))

-- User scripts
hl.bind(mainMod .. " + SHIFT + M",    hl.dsp.exec_cmd(userScripts .. "/rofi_beats.sh"))
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd(userScripts .. "/wallpaper_select.sh"))

-- Waybar toggle
hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- ---- Groups (tabbed windows) --------------------------------

hl.bind(mainMod .. " + G",  hl.dsp.group.toggle())
hl.bind("ALT + Tab",        hl.dsp.group.next())

-- ---- Media / Special Keys ----------------------------------

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scriptsDir .. "/volume.sh --inc"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scriptsDir .. "/volume.sh --dec"))
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(scriptsDir .. "/volume.sh --toggle-mic"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scriptsDir .. "/volume.sh --toggle"))
hl.bind("XF86Sleep",             hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("XF86Rfkill",            hl.dsp.exec_cmd(scriptsDir .. "/airplane_mode.sh"))

hl.bind("XF86AudioPause",        hl.dsp.exec_cmd(scriptsDir .. "/media_ctrl.sh --pause"))
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd(scriptsDir .. "/media_ctrl.sh --pause"))
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd(scriptsDir .. "/media_ctrl.sh --nxt"))
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd(scriptsDir .. "/media_ctrl.sh --prv"))
hl.bind("XF86AudioStop",         hl.dsp.exec_cmd(scriptsDir .. "/media_ctrl.sh --stop"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh --inc"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/brightness.sh --dec"))

-- ---- Screenshots -------------------------------------------

hl.bind(mainMod .. " + Print",          hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --now"))
hl.bind(mainMod .. " + SHIFT + Print",  hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --area"))
hl.bind(mainMod .. " + CTRL + Print",   hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --in5"))
hl.bind(mainMod .. " + ALT + Print",    hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --in10"))
hl.bind("ALT + Print",                  hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --active"))
-- Screenshot with swappy:
hl.bind(mainMod .. " + SHIFT + S",      hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh --swappy"))

-- ---- Resize Windows (binde → repeating) --------------------

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x =  50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y =  50, relative = true }), { repeating = true })

-- ---- Move Windows ------------------------------------------

hl.bind(mainMod .. " + CTRL + left",   hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + right",  hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + up",     hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + down",   hl.dsp.window.move({ direction = "d" }))

-- ---- Focus -------------------------------------------------

hl.bind(mainMod .. " + left",   hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right",  hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",     hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",   hl.dsp.focus({ direction = "d" }))

-- ---- Workspace Switching -----------------------------------

hl.bind(mainMod .. " + Tab",        hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + Tab",hl.dsp.focus({ workspace = "m-1" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period",     hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma",      hl.dsp.focus({ workspace = "e-1" }))

-- Workspaces 1–10 via key codes (code:10 = 1, code:19 = 0/10)
--   SUPER+<n>          → focus workspace n
--   SUPER+SHIFT+<n>    → move window to workspace n, follow
--   SUPER+CTRL+<n>     → move window to workspace n, silent (no follow)
for i = 1, 10 do
    local code = "code:" .. (9 + i)
    hl.bind(mainMod .. " + " .. code,
            hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. code,
            hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(mainMod .. " + CTRL + " .. code,
            hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Bracket navigation ([ / ]) — relative workspace move (strings required in Lua API)
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "-1", follow = true }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind(mainMod .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = "-1", follow = false }))
hl.bind(mainMod .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = "+1", follow = false }))

-- ---- Special Workspace (scratchpad) ------------------------

hl.bind(mainMod .. " + SHIFT + U",  hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + U",          hl.dsp.workspace.toggle_special())

-- ---- Move Workspace to Monitor -----------------------------

hl.bind(mainMod .. " + CTRL + SHIFT + comma",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + period", hl.dsp.workspace.move({ monitor = "r" }))

-- ---- Mouse Drag / Resize -----------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================
-- Master Layout (commented — layout is set to "master" in look_and_feel.lua)
-- Uncomment the layout-message binds if you want them.
--
-- hl.bind(mainMod .. " + CTRL + D",      hl.dsp.layout("removemaster"))
-- hl.bind(mainMod .. " + I",             hl.dsp.layout("addmaster"))
-- hl.bind(mainMod .. " + J",             hl.dsp.layout("cyclenext"))
-- hl.bind(mainMod .. " + K",             hl.dsp.layout("cycleprev"))
-- hl.bind(mainMod .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"))
-- hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())
-- ============================================================

-- ============================================================
-- VM keyboard passthrough submap (commented)
--
-- hl.bind(mainMod .. " + ALT + P", hl.dsp.submap("passthru"))
-- hl.define_submap("passthru", function()
--     hl.bind(mainMod .. " + ALT + P", hl.dsp.submap("reset"))
-- end)
-- ============================================================
