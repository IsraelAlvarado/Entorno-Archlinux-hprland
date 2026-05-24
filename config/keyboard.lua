-- ╔══════════════════════════════════════╗
-- ║         KEYBOARD LAYOUTS             ║
-- ╚══════════════════════════════════════╝
-- /home/israel/.config/hypr/config/keyboard.lua
--
-- ┌─────────────────────────────────────────────────────┐
-- │  AGREGAR / QUITAR IDIOMAS AQUÍ                      │
-- │                                                     │
-- │  Formato: "layout1,layout2,layout3"                 │
-- │  Variantes deben tener el mismo número de comas     │
-- │                                                     │
-- │  Códigos comunes:                                   │
-- │    us       → Inglés (QWERTY)                       │
-- │    es       → Español                               │
-- │    latam    → Español Latinoamérica                 │
-- │    ru       → Ruso                                  │
-- │    de       → Alemán                                │
-- │    fr       → Francés                               │
-- │    pt       → Portugués                             │
-- │    jp       → Japonés (romaji)                      │
-- │    ara      → Árabe                                 │
-- │                                                     │
-- │  Variantes comunes:                                 │
-- │    (vacío)  → default                               │
-- │    intl     → us con teclas muertas (ñ, á, ü...)   │
-- │    altgr-intl → us con AltGr para acentos          │
-- │    colemak  → layout Colemak                        │
-- │    dvorak   → layout Dvorak                         │
-- └─────────────────────────────────────────────────────┘

local LAYOUTS  = "us,es"      -- ← edita aquí para agregar/quitar
local VARIANTS = ","          -- ← mismo número de comas que LAYOUTS

-- Si solo usas un idioma pon:
--   local LAYOUTS  = "us"
--   local VARIANTS = ""

-- Tres idiomas ejemplo:
--   local LAYOUTS  = "us,es,ru"
--   local VARIANTS = ",,"

hl.config({
    input = {
        kb_layout  = LAYOUTS,
        kb_variant = VARIANTS,
        kb_model   = "pc105",
        kb_options = "",        -- vacío: solo se cambia con los binds
        -- kb_options = "grp:caps_toggle"  ← alternativa: CapsLock cambia idioma
    }
})