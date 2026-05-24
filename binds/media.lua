-- ╔══════════════════════════════════════╗
-- ║               MEDIA                  ║
-- ╚══════════════════════════════════════╝

local mainMod = "SUPER"

-- ── Volumen (teclas multimedia) ──────────────────────────
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("swayosd-client --output-volume +5"),
    { repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("swayosd-client --output-volume -5"),
    { repeating = true }
)
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))

-- ── Silenciar con teclado ─────────────────────────────────
-- SUPER+A       → mute/unmute altavoz
-- SUPER+SHIFT+A → mute/unmute micrófono
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/toggle-mute.sh"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))

-- ── Volumen con teclado ───────────────────────────────────
hl.bind(
    mainMod .. " + ALT + Up",
    hl.dsp.exec_cmd("swayosd-client --output-volume +5 --max-volume 255"),
    { repeating = true }
)
hl.bind(
    mainMod .. " + ALT + Down",
    hl.dsp.exec_cmd("swayosd-client --output-volume -5 --max-volume 255"),
    { repeating = true }
)
-- ── Brillo ───────────────────────────────────────────────
-- brightnessctl cambia el brillo real, swayosd-client muestra el OSD
-- Son dos pasos necesarios: uno no hace lo del otro para brillo
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("bash -c 'brightnessctl -d intel_backlight set +5% && swayosd-client --brightness raise'"),
    { repeating = true }
)
hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("bash -c 'brightnessctl -d intel_backlight set 5%- --min-value=1 && swayosd-client --brightness lower'"),
    { repeating = true }
)

-- ── Reproducción ─────────────────────────────────────────
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))