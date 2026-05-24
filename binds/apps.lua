-- ╔══════════════════════════════════════╗
-- ║             APP BINDS                ║
-- ╚══════════════════════════════════════╝
-- /home/israel/.config/hypr/binds/apps.lua

local mainMod    = "SUPER"
local altMod     = "ALT"
local terminal   = "kitty"
local fileManager = "dolphin"
local menu       = "hyprlauncher"

-- ── Apps principales ─────────────────────────────────────
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F",         hl.dsp.exec_cmd("kitty --title fastfetch -e bash -c 'fastfetch; read'"))
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))

-- ── Waydroid ──────────────────────────────────────────────
hl.bind(mainMod .. " + " .. altMod .. " + W", hl.dsp.exec_cmd("pkexec systemctl start waydroid-container && notify-send 'Waydroid' 'Contenedor iniciado con éxito'"))
hl.bind(mainMod .. " + " .. altMod .. " + K", hl.dsp.exec_cmd("waydroid session stop ; sleep 1 ; pkexec systemctl stop waydroid-container && notify-send 'Waydroid' 'Sesión y contenedor detenidos'"))

-- ── Sistema ───────────────────────────────────────────────
-- Bloqueo de pantalla (evita múltiples instancias)
hl.bind(mainMod .. " + CTRL + L",  hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + " .. altMod .. " + R", hl.dsp.exec_cmd("hyprctl reload && notify-send 'Hyprland' 'Configuración recargada'"))

-- ── Utilidades ────────────────────────────────────────────
-- Selector de color (hyprpicker instalado, sin bind hasta ahora)
-- SUPER+ALT+C → copia el color al portapapeles automáticamente
hl.bind(mainMod .. " + " .. altMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a && notify-send 'Color' 'Copiado al portapapeles'"))

-- Portapapeles: historial con cliphist + wofi  
-- (requiere ejecutar: wl-paste --watch cliphist store  en el autostart)
hl.bind(mainMod .. " + " .. altMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + " .. altMod .. " + D", hl.dsp.exec_cmd("cliphist wipe && notify-send 'Portapapeles' 'Historial borrado'"))

-- ── Notificaciones (SwayNC) ───────────────────────────────
-- CTRL+SPACE            → cerrar notificación más reciente
-- CTRL+SHIFT+SPACE      → cerrar todas
-- CTRL+SHIFT+PERIOD     → abrir/cerrar panel de historial
hl.bind("CTRL + SPACE",          hl.dsp.exec_cmd("swaync-client -C"))
hl.bind("CTRL + SHIFT + SPACE",  hl.dsp.exec_cmd("swaync-client -d"))
hl.bind("CTRL + SHIFT + PERIOD", hl.dsp.exec_cmd("swaync-client -t"))