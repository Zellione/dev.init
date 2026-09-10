-------------------
--- KEYBINDINGS ---
-------------------

local mainMod = "SUPER"

-- General
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/powermenu.sh"))

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(
    mainMod .. " + D",
    hl.dsp.exec_cmd(
        'rofi -show drun -show-icons -display-drun "Apps" -theme ~/.config/rofi/themes/launcher.rasi'
    )
)

-- Window management
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M",         hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Focus windows
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move windows
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize windows
hl.bind(
    mainMod .. " + SHIFT + left",
    hl.dsp.window.resize({ x = -50, y = 0, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + right",
    hl.dsp.window.resize({ x = 50, y = 0, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + up",
    hl.dsp.window.resize({ x = 0, y = -50, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + down",
    hl.dsp.window.resize({ x = 0, y = 50, relative = true }),
    { repeating = true }
)

-- Workspaces 1-10
--
-- Physical key codes are used so the bindings don't depend on the
-- active keyboard layout.
--
-- SUPER + 1..0         -> switch workspace
-- SUPER + SHIFT + 1..0 -> move window and follow
-- SUPER + CTRL + 1..0  -> move window without following

for i = 1, 10 do
    local code = "code:" .. (9 + i)

    hl.bind(
        mainMod .. " + " .. code,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. code,
        hl.dsp.window.move({ workspace = i, follow = true })
    )

    hl.bind(
        mainMod .. " + CTRL + " .. code,
        hl.dsp.window.move({ workspace = i, follow = false })
    )
end

-- Mouse window management
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Screenshots 
hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-area.sh")
)

-- Clipboard
hl.bind(
   mainMod .. " + V",
   hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh")
)

-- Notifications
hl.bind(
    mainMod .. " + N",
    hl.dsp.exec_cmd("~/.local/bin/notification-history")
)

hl.bind(
    mainMod .. " + SHIFT + N",
    hl.dsp.exec_cmd("~/.local/bin/notification-history critical")
)

hl.bind(
    mainMod .. " + CTRL + N",
    hl.dsp.exec_cmd("~/.local/bin/notification-history normal")
)
