-- ╔══════════════════════════════════════════════════════╗
-- ║               HYPRLAND CONFIG — ISRAEL               ║
-- ║         Arch Linux · Hyprland Lua API                ║
-- ╚══════════════════════════════════════════════════════╝
-- /home/israel/.config/hypr/hyprland.lua

local config_dir = os.getenv("HOME") .. "/.config/hypr/"

-- ── Config ──────────────────────────────────────────────
dofile(config_dir .. "config/general.lua")
dofile(config_dir .. "config/keyboard.lua")   -- ← nuevo: layouts de teclado
dofile(config_dir .. "config/animations.lua")
dofile(config_dir .. "config/rules.lua")

-- ── Environment (NVIDIA) ─────────────────────────────────
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND",               "direct")
hl.env("GBM_BACKEND",               "nvidia-drm")
hl.env("XDG_SESSION_TYPE",          "wayland")
hl.env("WLR_DRM_NO_ATOMIC",         "1")

-- ── Autostart ────────────────────────────────────────────
hl.on("hyprland.start", function()
    os.execute("awww-daemon &")
    os.execute("sleep 0.5")
    os.execute(config_dir .. "scripts/wallpaper-cycle.sh &")
    os.execute("waybar &")
    os.execute("nm-applet --indicator >/dev/null 2>&1 &")
    os.execute("swayosd-server &")
    os.execute("wl-paste --watch cliphist store &")
    os.execute("swaync &")
end)

-- ── Binds ────────────────────────────────────────────────
dofile(config_dir .. "binds/apps.lua")
dofile(config_dir .. "binds/windows.lua")
dofile(config_dir .. "binds/workspaces.lua")
dofile(config_dir .. "binds/screenshots.lua")
dofile(config_dir .. "binds/media.lua")
dofile(config_dir .. "binds/keyboard.lua")   