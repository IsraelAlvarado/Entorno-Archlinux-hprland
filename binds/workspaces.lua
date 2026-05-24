-- ╔══════════════════════════════════════╗
-- ║            WORKSPACES                ║
-- ╚══════════════════════════════════════╝

local mainMod = "SUPER"

-- ── Workspaces 1-5 ────────────────────────────────────────
-- SUPER+1-5       → ir al workspace
-- SUPER+SHIFT+1-5 → mover ventana al workspace
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

-- ── Navegación ────────────────────────────────────────────
hl.bind(mainMod .. " + N",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.focus({ workspace = "e-1" }))

-- Scroll sobre waybar para cambiar workspace
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ── Scratchpad (workspace especial flotante) ──────────────
-- SUPER+grave         → mostrar/ocultar el scratchpad
-- SUPER+SHIFT+grave   → mandar ventana activa al scratchpad
-- SUPER+CTRL+grave    → sacar ventana del scratchpad al workspace actual
hl.bind(mainMod .. " + grave",           hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. " + SHIFT + grave",   hl.dsp.window.move({ workspace = "special:scratch" }))
hl.bind(mainMod .. " + CTRL + grave",    hl.dsp.window.move({ workspace = "e+0" }))