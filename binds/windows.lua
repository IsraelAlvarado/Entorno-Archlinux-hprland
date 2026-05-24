-- ╔══════════════════════════════════════╗
-- ║          WINDOW MANAGEMENT           ║
-- ╚══════════════════════════════════════╝

local mainMod = "SUPER"

-- ── Cerrar / flotar / pantalla completa ──────────────────
hl.bind(mainMod .. " + C", hl.dsp.window.close({}))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))   -- pantalla completa real
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.fullscreen({ mode = "maximized" }))     -- maximizar (sin ocultar waybar)

-- ── Mover foco entre ventanas ─────────────────────────────
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))

-- Alternativa con HJKL estilo vim
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))  -- OJO: colisiona con SUPER+L (lock); elige uno

-- ── Mover ventana en tiling ───────────────────────────────
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "down" }))

-- ── Ajustar ratio split tiling ────────────────────────────
hl.bind(mainMod .. " + EQUAL",         hl.dsp.layout("splitratio +0.1"))
hl.bind(mainMod .. " + MINUS",         hl.dsp.layout("splitratio -0.1"))
hl.bind(mainMod .. " + SHIFT + EQUAL", hl.dsp.layout("splitratio 1.0 exact"))

-- ── Submap de redimensionado (SUPER+ALT+M para entrar, ESC/Enter para salir) ──
hl.bind(mainMod .. " + ALT + M", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("Right",  hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
    hl.bind("Left",   hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
    hl.bind("Up",     hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
    hl.bind("Down",   hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- ── Arrastrar/redimensionar con mouse (SUPER + click) ────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Dwindle ───────────────────────────────────────────────
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())        -- pseudo tiling
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))  -- toggle split top/side
hl.bind(mainMod .. " + S", hl.dsp.layout("swapsplit"))    -- swap mitades del split
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.layout("movetoroot"))  -- mover a raíz del árbol