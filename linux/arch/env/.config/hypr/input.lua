-- ============================================================
-- Input Configuration
-- Source: hyprlang → Lua migration of input/device blocks
-- See: https://wiki.hypr.land/Configuring/Basics/Variables/
-- ============================================================

hl.config({
    input = {
        sensitivity            = -0.50,
        kb_layout              = "de,us",
        kb_variant             = "",
        kb_model               = "",
        kb_options             = "grp:alt_shift_toggle",
        kb_rules               = "",
        repeat_rate            = 50,
        repeat_delay           = 300,
        numlock_by_default     = true,
        left_handed            = false,
        follow_mouse           = 1,
        float_switch_override_focus = 0,

        touchpad = {
            disable_while_typing  = true,
            natural_scroll        = false,
            clickfinger_behavior  = 0,
            middle_button_emulation = true,
            tap_to_click          = true,   -- hyprlang: tap-to-click
            drag_lock             = false,
        },
    },
})

-- Per-device overrides
-- Use `hyprctl devices` for exact device names.
hl.device({
    name        = "uniw0001:00-093a:0255-touchpad",
    sensitivity = 0.50,
})
