-- ============================================================
-- Window Rules
-- Source: hyprlang → Lua migration of window rules (all originally commented)
-- See: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Rules are evaluated top-to-bottom. Named rules run before anonymous ones.
-- ============================================================

-- ---- Float rules -------------------------------------------
-- hl.window_rule({ match = { class = "org.kde.polkit-kde-authentication-agent-1" }, float = true })
-- hl.window_rule({ match = { class = "nm-connection-editor"  }, float = true })
-- hl.window_rule({ match = { class = "blueman-manager"       }, float = true })
-- hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
-- hl.window_rule({ match = { class = "nwg-look"  }, float = true })
-- hl.window_rule({ match = { class = "qt5ct"     }, float = true })
-- hl.window_rule({ match = { class = "mpv"       }, float = true })
-- hl.window_rule({ match = { class = "onedriver"          }, float = true })
-- hl.window_rule({ match = { class = "onedriver-launcher" }, float = true })
-- hl.window_rule({ match = { class = "eog"  }, float = true })
-- hl.window_rule({ match = { class = "zoom" }, float = true })
-- hl.window_rule({ match = { class = "rofi" }, float = true })
-- hl.window_rule({ match = { class = "gnome-system-monitor" }, float = true })
hl.window_rule({ match = { class = "yad"  }, float = true })

-- ---- Gamescope ---------------------------------------------
-- hl.window_rule({ match = { class = "gamescope" }, no_blur   = true   })
-- hl.window_rule({ match = { class = "gamescope" }, fullscreen = true  })
-- hl.window_rule({ match = { class = "^(gamescope)$" }, workspace = "6 silent" })

-- ---- Center ------------------------------------------------
-- hl.window_rule({ match = { title = "^(pavucontrol)$" }, center = true })

-- ---- Workspace assignments ---------------------------------
-- hl.window_rule({ match = { class = "^(thunderbird)$"                }, workspace = "1"         })
-- hl.window_rule({ match = { class = "^(firefox)$"                    }, workspace = "2"         })
-- hl.window_rule({ match = { class = "^(Firefox-esr)$"                }, workspace = "2"         })
-- hl.window_rule({ match = { class = "^(Microsoft-edge-beta)$"        }, workspace = "2"         })
-- hl.window_rule({ match = { class = "^([Tt]hunar)$"                  }, workspace = "3"         })
-- hl.window_rule({ match = { class = "^(com.obsproject.Studio)$"      }, workspace = "4"         })
-- hl.window_rule({ match = { class = "^([Ss]team)$",
--                             title = "^([Ss]team)$"                  }, workspace = "5 silent"  })
-- hl.window_rule({ match = { class = "^(lutris)$"                     }, workspace = "5 silent"  })
-- hl.window_rule({ match = { class = "^(virt-manager)$"               }, workspace = "6"         })
-- hl.window_rule({ match = { class = "^(discord)$"                    }, workspace = "7 silent"  })
-- hl.window_rule({ match = { class = "^(WebCord)$"                    }, workspace = "7 silent"  })
-- hl.window_rule({ match = { class = "^([Aa]udacious)$"               }, workspace = "9 silent"  })

-- ---- Opacity -----------------------------------------------
-- hl.window_rule({ match = { class = "^([Rr]ofi)$"             }, opacity = "0.9 0.6" })
-- hl.window_rule({ match = { class = "^(Brave-browser)$"        }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(Brave-browser-dev)$"    }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(Firefox-esr)$"          }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^([Tt]hunar)$"            }, opacity = "0.9 0.8" })
-- hl.window_rule({ match = { class = "^(pcmanfm-qt)$"           }, opacity = "0.8 0.6" })
-- hl.window_rule({ match = { class = "^(gedit)$"                }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(kitty)$"                }, opacity = "0.9 0.8" })
-- hl.window_rule({ match = { class = "^(mousepad)$"             }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(codium-url-handler)$"   }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(VSCodium)$"             }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(yad)$"                  }, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^(com.obsproject.Studio)$"}, opacity = "0.9 0.7" })
-- hl.window_rule({ match = { class = "^([Aa]udacious)$"         }, opacity = "0.9 0.7" })
-- Border color for fullscreen windows:
-- hl.window_rule({ match = { fullscreen = true }, border_color = "rgb(EE4B55) rgb(880808)" })
-- Border color for floating windows:
-- hl.window_rule({ match = { float = true      }, border_color = "rgb(282737) rgb(1E1D2D)" })
-- Opacity for pinned windows:
-- hl.window_rule({ match = { pin = true        }, opacity = "0.8 0.8" })

-- ---- Layer rules -------------------------------------------
-- Frosted glass for launcher / power menu surfaces.
--
-- Note: wlogout hardcodes its layer namespace to "logout_dialog"
-- (see ArtsyMacaw/wlogout main.c: gtk_layer_set_namespace(win, "logout_dialog")),
-- not "wlogout". If a layer rule doesn't seem to apply, run
-- `hyprctl layers` while the surface is open to confirm the namespace.
hl.layer_rule({ match = { namespace = "^([Rr]ofi)$"      }, blur         = true })
hl.layer_rule({ match = { namespace = "^([Rr]ofi)$"      }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "^logout_dialog$"  }, blur         = true })
hl.layer_rule({ match = { namespace = "^logout_dialog$"  }, ignore_alpha = 0 })

-- ---- Picture-in-Picture ------------------------------------
-- NOTE: PIP window changes class/title after first launch;
-- duplicate rules may be needed for both initial and settled state.
-- hl.window_rule({
--     match   = { title = "^(Picture-in-Picture)$" },
--     float   = true,
--     pin     = true,
--     size    = { "25% 25%" },           -- TODO: verify size table format
--     move    = "72% 7%",
--     opacity = "0.95 0.75",
-- })
