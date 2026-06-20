-- ============================================================
-- Environment Variables
-- Source: hyprlang → Lua migration of env vars
-- ============================================================

-- Wayland / toolkit backends
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Renderer
hl.env("WLR_RENDERER", "vulkan")

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Blank screen after wake-up workaround
hl.env("AQ_NO_MODIFIERS", "1")

-- ============================================================
-- NVIDIA (uncomment if applicable)
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
-- hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
-- hl.env("AQ_NO_ATOMIC", "1")   -- legacy DRM, NOT recommended
-- hl.env("NVD_BACKEND", "direct")
-- Firefox hardware accel on NVIDIA:
-- hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
-- hl.env("EGL_PLATFORM", "wayland")
-- ============================================================

-- ============================================================
-- VM / software render (uncomment if applicable)
-- hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
-- ============================================================
