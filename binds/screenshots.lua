-- ╔══════════════════════════════════════╗
-- ║           SCREENSHOTS                ║
-- ╚══════════════════════════════════════╝

-- ── Guardar en disco ─────────────────────────────────────
-- Print             → región (seleccionar área)
-- SHIFT+Print       → pantalla completa
-- SUPER+Print       → ventana activa
hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window"))

-- ── Copiar al portapapeles (sin guardar archivo) ─────────
-- CTRL+Print             → región → portapapeles
-- CTRL+SHIFT+Print       → pantalla completa → portapapeles
-- CTRL+SUPER+Print       → ventana activa → portapapeles
hl.bind("CTRL + Print",         hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind("CTRL + SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))