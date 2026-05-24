-- ╔══════════════════════════════════════╗
-- ║         KEYBOARD LAYOUT BINDS        ║
-- ╚══════════════════════════════════════╝
-- /home/israel/.config/hypr/binds/keyboard.lua
--
-- SUPER+SPACE         → siguiente idioma (cicla en orden)
-- SUPER+SHIFT+SPACE   → idioma anterior
-- SUPER+ALT+0         → forzar inglés (layout 0)
-- SUPER+ALT+9         → forzar español (layout 1)

local mainMod = "SUPER"

-- "all" aplica el cambio a todos los teclados conectados
-- Si tienes un teclado externo y el interno y quieres solo uno,
-- reemplaza "all" por el nombre del dispositivo de:
--   hyprctl -j devices | python3 -c "import json,sys; [print(k['name']) for k in json.load(sys.stdin)['keyboards']]"

hl.bind(mainMod .. " + SPACE",         hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all prev"))

-- Acceso directo por índice (0 = primer layout en LAYOUTS, 1 = segundo, etc.)
hl.bind(mainMod .. " + ALT + 0", hl.dsp.exec_cmd("hyprctl switchxkblayout all 0"))
hl.bind(mainMod .. " + ALT + 1", hl.dsp.exec_cmd("hyprctl switchxkblayout all 1"))
-- Agrega más si tienes más layouts:
-- hl.bind(mainMod .. " + ALT + 2", hl.dsp.exec_cmd("hyprctl switchxkblayout all 2"))