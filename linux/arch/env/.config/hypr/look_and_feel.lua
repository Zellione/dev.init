-- ============================================================
-- Look & Feel: General, Decoration, Animations, Layout,
--              Group, Misc, Render, Binds, Debug, XWayland
-- Source: hyprlang → Lua migration of general/decoration/layout vars
-- Colors sourced from: colors.lua  (wallust-generated)
-- See: https://wiki.hypr.land/Configuring/Basics/Variables/
-- ============================================================

local colors = require("colors")

-- ---- General + Decoration + Layout --------------------------

hl.config({
    general = {
        gaps_in           = 4,
        gaps_out          = 8,
        border_size       = 2,
        resize_on_border  = true,
        allow_tearing     = false,
        layout            = "master",

        col = {
            -- 2-color gradient (Lua API restricts to 2 colors)
            active_border   = {
                colors = {
                    colors.color0,
                    colors.color8,
                },
                angle = 90,
            },
            -- Old config: $backgroundCol  →  colors.background
            inactive_border = colors.background,
        },
    },

    decoration = {
        rounding           = 8,
        active_opacity     = 1.0,
        inactive_opacity   = 0.9,
        fullscreen_opacity  = 1.0,
        dim_inactive       = true,
        dim_strength       = 0.1,

        blur = {
            enabled            = true,
            size               = 5,
            passes             = 2,
            ignore_opacity     = true,
            new_optimizations  = true,  -- strongly recommended for perf
        },

        shadow = {
            enabled       = true,
            range         = 6,
            render_power  = 1,
            color         = colors.color2,
            color_inactive = 0x50000000,
        },
    },

    dwindle = {
        preserve_split        = true,
        special_scale_factor  = 0.8,
    },

    master = {
        new_status  = "master",
        new_on_top  = true,
        mfact       = 0.5,
    },

    group = {
        col = {
            border_active = colors.color15,
        },
    },

    cursor = {
        no_hardware_cursors = false,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        -- vrr = 0,  -- uncomment to enable variable refresh rate
        enable_swallow           = true,
        focus_on_activate        = false,
        swallow_regex            = "^(kitty)$",
        -- disable_autoreload    = true,  -- manual hyprctl reload only
    },

    render = {
        direct_scanout = true,  -- for fullscreen games
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },

    debug = {
        overlay = false,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- ---- Bezier Curves ------------------------------------------
-- See: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Design tool: https://cssportal.com/css-cubic-bezier-generator/
-- Format: hl.curve(name, { type="bezier", points={{X1,Y1},{X2,Y2}} })
-- hyprlang: bezier = NAME, X1, Y1, X2, Y2

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("linear",   { type = "bezier", points = { {0.0,  0.0},  {1.0, 1.0}   } })
hl.curve("wind",     { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}  } })
hl.curve("winIn",    { type = "bezier", points = { {0.1,  1.1},  {0.1, 1.1}   } })
hl.curve("winOut",   { type = "bezier", points = { {0.3,  -0.3}, {0,   1}     } })
hl.curve("slow",     { type = "bezier", points = { {0,    0.85}, {0.3, 1}     } })
hl.curve("overshot", { type = "bezier", points = { {0.7,  0.6},  {0.1, 1.1}   } })
hl.curve("bounce",   { type = "bezier", points = { {1.1,  1.6},  {0.1, 0.85}  } })
-- Defined in old config but not actively used by any animation:
hl.curve("sligshot", { type = "bezier", points = { {1,    -1},   {0.15, 1.25} } })

-- ---- Animations ---------------------------------------------
-- Format: hl.animation({ leaf, enabled, speed, bezier|spring, style? })
-- NOTE: borderangle with style="loop" forces constant re-rendering at your
-- monitor's refresh rate — impacts CPU/GPU and battery on laptops.

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,   bezier = "slow",    style = "popin" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,   bezier = "winOut",  style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,   bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 10,  bezier = "linear"   })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear",  style = "loop"  })
hl.animation({ leaf = "fade",        enabled = true, speed = 5,   bezier = "overshot" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,   bezier = "wind"     })
hl.animation({ leaf = "windows",     enabled = true, speed = 5,   bezier = "bounce",  style = "popin" })
