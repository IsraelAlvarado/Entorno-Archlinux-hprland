#!/usr/bin/env bash

CONFIG="$HOME/.config/hypr/scripts/wallpaper.conf"
SCRIPT="$HOME/.config/hypr/scripts/wallpaper-cycle.sh"

export GTK_THEME=Adwaita:dark
mkdir -p "$(dirname "$CONFIG")"

# =========================================================
# CONFIG DEFAULT (Se crea si no existe)
# =========================================================
[ ! -f "$CONFIG" ] && cat > "$CONFIG" << EOF
INTERVAL=30
TRANSITION=random
DURATION=2
FPS=60
ENABLE_COLLAGE=1
COLLAGE_CHANCE=35
COLLAGE_MIN=3
COLLAGE_MAX=5
RANDOM_ORDER=1
SMART_TRANSITIONS=1
EOF

source "$CONFIG"

# =========================================================
# ADAPTAR VARIABLES PARA YAD (1/0 a TRUE/FALSE)
# =========================================================
[ "$ENABLE_COLLAGE" = "1" ] && YAD_COLLAGE="TRUE" || YAD_COLLAGE="FALSE"
[ "$RANDOM_ORDER" = "1" ] && YAD_RANDOM="TRUE" || YAD_RANDOM="FALSE"
[ "$SMART_TRANSITIONS" = "1" ] && YAD_SMART="TRUE" || YAD_SMART="FALSE"

# Para que el combobox muestre el actual primero sin duplicar feo
TRANS_OPTIONS="random!fade!wave!wipe!grow!outer!simple"

# =========================================================
# GUI
# =========================================================
FORM=$(yad --form \
    --title="Motor de Wallpapers - Ajustes" \
    --width=650 \
    --height=700 \
    --center \
    --borders=15 \
    --separator="|" \
    --columns=1 \
    --field="<span size='large' foreground='#89b4fa'><b>󰽚 Controles Rápidos</b></span>":LBL "" \
    --field="Saltar al siguiente Wallpaper:BTN" "pkill -USR1 -f wallpaper-cycle.sh" \
    --field="Reiniciar Servicio AWWW:BTN" "pkill -f wallpaper-cycle.sh && $SCRIPT &" \
    --field="":LBL "" \
    --field="<span size='large' foreground='#a6e3a1'><b>󰋑 Transiciones y Tiempos</b></span>":LBL "" \
    --field="Efecto visual (Random = Evita repetir):CB" "^${TRANSITION}!${TRANSOPTIONS}" \
    --field="Minutos/Segundos entre cambios (Segundos):NUM" "${INTERVAL}!5..3600!5" \
    --field="Duración del efecto de transición (Segundos):NUM" "${DURATION}!1..15!1" \
    --field="Suavidad del efecto (FPS - Mayor gasta más GPU):NUM" "${FPS}!30..240!10" \
    --field="Activar Inteligencia (No repetir efecto 2 veces):CHK" "$YAD_SMART" \
    --field="Modo Aleatorio (Desmarcar para orden alfabético):CHK" "$YAD_RANDOM" \
    --field="":LBL "" \
    --field="<span size='large' foreground='#f38ba8'><b>󰹹 Modo Collage (Composiciones automáticas)</b></span>":LBL "" \
    --field="Permitir que el sistema cree Collages:CHK" "$YAD_COLLAGE" \
    --field="Probabilidad de aparición de Collage (%):NUM" "${COLLAGE_CHANCE}!0..100!5" \
    --field="Cantidad mínima de fotos en el collage:NUM" "${COLLAGE_MIN}!2..12!1" \
    --field="Cantidad máxima de fotos en el collage:NUM" "${COLLAGE_MAX}!2..20!1" \
    --button="󰈆 Cancelar:1" \
    --button="󰄬 Guardar Cambios:0" \
    2>/dev/null)

EXIT=$?
[ "$EXIT" -ne 0 ] && exit 0

# =========================================================
# PARSEO DE DATOS
# =========================================================
IFS="|" read -r \
LBL1 BTN1 BTN2 LBL2 LBL3 \
NEW_TRANSITION \
NEW_INTERVAL \
NEW_DURATION \
NEW_FPS \
NEW_SMART \
NEW_RANDOM \
LBL4 LBL5 \
NEW_COLLAGE \
NEW_COLLAGE_CHANCE \
NEW_COLLAGE_MIN \
NEW_COLLAGE_MAX \
EXTRA <<< "$FORM"

# Limpieza del Combobox si trae "texto extra" de YAD
NEW_TRANSITION=$(echo "$NEW_TRANSITION" | cut -d'^' -f1)

# Validaciones
if [ "$NEW_COLLAGE_MIN" -gt "$NEW_COLLAGE_MAX" ]; then
    yad --error --title="Error" --width=300 --center --text="El mínimo de imágenes del collage no puede superar al máximo." 2>/dev/null
    exit 1
fi

# =========================================================
# RECONVERSIÓN DE YAD A BASH (TRUE/FALSE a 1/0)
# =========================================================
[ "$NEW_COLLAGE" = "TRUE" ] && VAL_COLLAGE=1 || VAL_COLLAGE=0
[ "$NEW_RANDOM" = "TRUE" ] && VAL_RANDOM=1 || VAL_RANDOM=0
[ "$NEW_SMART" = "TRUE" ] && VAL_SMART=1 || VAL_SMART=0

# =========================================================
# GUARDAR CONFIG
# =========================================================
cat > "$CONFIG" << EOF
INTERVAL=$NEW_INTERVAL
TRANSITION=$NEW_TRANSITION
DURATION=$NEW_DURATION
FPS=$NEW_FPS
ENABLE_COLLAGE=$VAL_COLLAGE
COLLAGE_CHANCE=$NEW_COLLAGE_CHANCE
COLLAGE_MIN=$NEW_COLLAGE_MIN
COLLAGE_MAX=$NEW_COLLAGE_MAX
RANDOM_ORDER=$VAL_RANDOM
SMART_TRANSITIONS=$VAL_SMART
EOF

# =========================================================
# APLICAR EN CALIENTE
# =========================================================
pkill -USR1 -f wallpaper-cycle.sh
notify-send "Wallpaper Engine" "Ajustes guardados y aplicados." -i "preferences-desktop-wallpaper"