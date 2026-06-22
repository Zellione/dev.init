-- ============================================================
-- Monitor Configuration
-- Source: hyprlang → Lua migration of monitor config
-- See: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- ============================================================
-- Use `hyprctl monitors` to list connected displays.

-- Fallback rule: any monitor not matched below gets preferred
-- resolution, auto-positioned, scale 1.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Bind workspace 1 to the internal display by default
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })

-- ============================================================
-- Laptop internal display (uncomment and adjust as needed)
-- hl.monitor({ output = "eDP-1", mode = "preferred",           position = "auto",   scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "2560x1600@240.00Hz", position = "1920x0", scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165",       position = "0x0",    scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1800@90",        position = "0x0",    scale = 2 })

-- External displays (uncomment and adjust as needed)
-- hl.monitor({ output = "desc:Acer Technologies XV270 TQJEE0068524",
--              mode = "1920x1080@165.00Hz", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-3",    mode = "1920x1080@240", position = "auto", scale = 1 })
-- hl.monitor({ output = "DP-1",    mode = "preferred",     position = "auto", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1",mode = "preferred",     position = "auto", scale = 1 })

-- QEMU/KVM virtual display
-- hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = 1 })

-- High-refresh-rate preset
-- hl.monitor({ output = "", mode = "highrr",  position = "auto", scale = 1 })

-- High-resolution preset
-- hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

-- Disable a monitor
-- hl.monitor({ output = "name", disabled = true })

-- Mirror DP-3 onto DP-2
-- hl.monitor({ output = "DP-3",    mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "DP-2" })
-- hl.monitor({ output = "",        mode = "preferred",    position = "auto",scale = 1, mirror = "eDP-1" })
-- ============================================================
