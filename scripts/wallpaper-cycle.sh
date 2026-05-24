#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CONFIG_FILE="$HOME/.config/hypr/scripts/wallpaper.conf"

pgrep awww-daemon >/dev/null || awww-daemon &
sleep 1

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))
[ ${#WALLPAPERS[@]} -eq 0 ] && exit 1

# =========================================================
# FUNCIONES NÚCLEO
# =========================================================
pick_different() {
    local last="$1"; shift; local array=("$@"); local new=""
    while true; do
        new=${array[$RANDOM % ${#array[@]}]}
        [[ "$new" != "$last" ]] && break
    done
    echo "$new"
}

# =========================================================
# COLLAGE REESCRITO
# =========================================================
create_collage() {
    local MIN_IMG=$1
    local MAX_IMG=$2
    local TMP="/tmp/awww-collage.png"

    local COUNT=$(( MIN_IMG + RANDOM % (MAX_IMG - MIN_IMG + 1) ))
    mapfile -t PICKS < <(printf "%s\n" "${WALLPAPERS[@]}" | shuf -n "$COUNT")

    local W=2560
    local H=1600

    # Layouts disponibles: grid, scatter, cascade, strip_h, strip_v, fan
    local LAYOUTS=(grid scatter cascade strip_h strip_v fan)
    local LAYOUT=${LAYOUTS[$RANDOM % ${#LAYOUTS[@]}]}

    # --- Calcular posiciones según layout ---
    declare -a POS_X POS_Y SIZES ROTATIONS SHAPES

    case "$LAYOUT" in

        grid)
            # Cuadrícula uniforme con leve rotación
            local COLS=$(( (COUNT + 1) / 2 ))
            local ROWS=2
            [ $COUNT -le 2 ] && COLS=$COUNT && ROWS=1
            local CELL_W=$(( W / COLS ))
            local CELL_H=$(( H / ROWS ))
            local PAD=30
            for (( i=0; i<COUNT; i++ )); do
                local col=$(( i % COLS ))
                local row=$(( i / COLS ))
                SIZES[$i]=$(( CELL_W < CELL_H ? CELL_W - PAD*2 : CELL_H - PAD*2 ))
                POS_X[$i]=$(( col * CELL_W + PAD ))
                POS_Y[$i]=$(( row * CELL_H + PAD ))
                ROTATIONS[$i]=$(( -8 + RANDOM % 17 ))   # -8 a +8 grados
            done
            ;;

        scatter)
            # Dispersión libre pero con margen de seguridad expandido por rotación
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 350 + RANDOM % 550 ))
                SIZES[$i]=$sz
                # El margen seguro considera la diagonal del bbox rotado: sz * 0.72 (sqrt(2)/2 aprox)
                local safe=$(( sz * 72 / 100 ))
                local max_x=$(( W - safe * 2 ))
                local max_y=$(( H - safe * 2 ))
                POS_X[$i]=$(( safe + RANDOM % max_x ))
                POS_Y[$i]=$(( safe + RANDOM % max_y ))
                ROTATIONS[$i]=$(( -35 + RANDOM % 71 ))   # -35 a +35
            done
            ;;

        cascade)
            # En diagonal de esquina a esquina
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 500 + RANDOM % 400 ))
                SIZES[$i]=$sz
                local safe=$(( sz * 72 / 100 ))
                local step_x=$(( (W - safe*2) / (COUNT > 1 ? COUNT-1 : 1) ))
                local step_y=$(( (H - safe*2) / (COUNT > 1 ? COUNT-1 : 1) ))
                local jitter_x=$(( -60 + RANDOM % 121 ))
                local jitter_y=$(( -60 + RANDOM % 121 ))
                POS_X[$i]=$(( safe + i * step_x + jitter_x ))
                POS_Y[$i]=$(( safe + i * step_y + jitter_y ))
                # Clamp para no salirse
                [[ ${POS_X[$i]} -lt $safe ]] && POS_X[$i]=$safe
                [[ ${POS_Y[$i]} -lt $safe ]] && POS_Y[$i]=$safe
                [[ ${POS_X[$i]} -gt $(( W - safe )) ]] && POS_X[$i]=$(( W - safe ))
                [[ ${POS_Y[$i]} -gt $(( H - safe )) ]] && POS_Y[$i]=$(( H - safe ))
                ROTATIONS[$i]=$(( -20 + RANDOM % 41 ))
            done
            ;;

        strip_h)
            # Franja horizontal, imágenes apiladas verticalmente centradas
            local CELL_W=$(( W / COUNT ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( CELL_W - 40 ))
                [[ $sz -gt $(( H - 80 )) ]] && sz=$(( H - 80 ))
                SIZES[$i]=$sz
                POS_X[$i]=$(( i * CELL_W + (CELL_W - sz) / 2 ))
                POS_Y[$i]=$(( (H - sz) / 2 + (-40 + RANDOM % 81) ))
                ROTATIONS[$i]=$(( -12 + RANDOM % 25 ))
            done
            ;;

        strip_v)
            # Franja vertical
            local CELL_H=$(( H / COUNT ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( CELL_H - 40 ))
                [[ $sz -gt $(( W - 80 )) ]] && sz=$(( W - 80 ))
                SIZES[$i]=$sz
                POS_X[$i]=$(( (W - sz) / 2 + (-40 + RANDOM % 81) ))
                POS_Y[$i]=$(( i * CELL_H + (CELL_H - sz) / 2 ))
                ROTATIONS[$i]=$(( -12 + RANDOM % 25 ))
            done
            ;;

        fan)
            # En abanico desde un punto central-inferior
            local cx=$(( W / 2 ))
            local cy=$(( H + 100 ))   # Punto de origen debajo de la pantalla
            local radius=$(( 600 + RANDOM % 400 ))
            local arc_start=$(( 200 ))   # Grados de inicio del arco
            local arc_end=$(( 340 ))
            local arc_range=$(( arc_end - arc_start ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 400 + RANDOM % 400 ))
                SIZES[$i]=$sz
                local angle_deg=$(( arc_start + arc_range * i / (COUNT > 1 ? COUNT-1 : 1) ))
                # Convertir a radianes con awk
                local px py
                px=$(awk "BEGIN { printf \"%d\", $cx + $radius * cos($angle_deg * 3.14159 / 180) }")
                py=$(awk "BEGIN { printf \"%d\", $cy + $radius * sin($angle_deg * 3.14159 / 180) }")
                # El margen de rotación sigue la dirección del arco
                local safe=$(( sz * 72 / 100 ))
                [[ $px -lt $safe ]] && px=$safe
                [[ $py -lt $safe ]] && py=$safe
                [[ $px -gt $(( W - safe )) ]] && px=$(( W - safe ))
                [[ $py -gt $(( H - safe )) ]] && py=$(( H - safe ))
                POS_X[$i]=$px
                POS_Y[$i]=$py
                ROTATIONS[$i]=$(( angle_deg - 270 + (-10 + RANDOM % 21) ))
            done
            ;;
    esac

    # --- Formas disponibles para cada imagen ---
    # circle, landscape (16:9), portrait (9:16), square, wide (2:1), tall (1:2)
    local SHAPE_LIST=(circle landscape portrait square wide tall)

    for (( i=0; i<COUNT; i++ )); do
        SHAPES[$i]=${SHAPE_LIST[$RANDOM % ${#SHAPE_LIST[@]}]}
    done

    # =========================================================
    # CONSTRUIR EL COLLAGE CON IMAGEMAGICK
    # =========================================================
    magick -size ${W}x${H} xc:"#0e0e0e" "$TMP"

    for (( i=0; i<COUNT; i++ )); do
        local img="${PICKS[$i]}"
        local sz=${SIZES[$i]}
        local px=${POS_X[$i]}
        local py=${POS_Y[$i]}
        local rot=${ROTATIONS[$i]}
        local shape=${SHAPES[$i]}
        local opacity=$(( 70 + RANDOM % 31 ))   # 70–100%

        # Calcular dimensiones según forma
        local iw ih
        case "$shape" in
            circle)
                iw=$sz; ih=$sz
                ;;
            landscape)
                iw=$(( sz * 16 / 9 ))
                # Asegura que no supere el ancho útil
                [[ $iw -gt $(( W - 100 )) ]] && iw=$(( W - 100 ))
                ih=$(( iw * 9 / 16 ))
                ;;
            portrait)
                ih=$sz
                iw=$(( sz * 9 / 16 ))
                ;;
            square)
                iw=$sz; ih=$sz
                ;;
            wide)
                iw=$(( sz * 2 ))
                [[ $iw -gt $(( W - 100 )) ]] && iw=$(( W - 100 ))
                ih=$(( iw / 2 ))
                ;;
            tall)
                ih=$sz
                iw=$(( sz / 2 ))
                ;;
        esac

        # Calcular safe después de conocer el tamaño real
        local diag=$(awk "BEGIN { printf \"%d\", sqrt($iw*$iw + $ih*$ih) / 2 + 5 }")
        local clamped_px=$px
        local clamped_py=$py
        [[ $clamped_px -lt $diag ]] && clamped_px=$diag
        [[ $clamped_py -lt $diag ]] && clamped_py=$diag
        [[ $clamped_px -gt $(( W - diag )) ]] && clamped_px=$(( W - diag ))
        [[ $clamped_py -gt $(( H - diag )) ]] && clamped_py=$(( H - diag ))

        if [[ "$shape" == "circle" ]]; then
            # Máscara circular
            local MASK="/tmp/awww-mask-${i}.png"
            magick -size ${iw}x${ih} xc:none \
                -fill white -draw "circle $(( iw/2 )),$(( ih/2 )) $(( iw/2 )),0" \
                "$MASK"

            magick "$TMP" \
                \( "$img" -resize "${iw}x${ih}^" -gravity center -extent "${iw}x${ih}" \
                   "$MASK" -alpha off -compose copy_opacity -composite \
                   -alpha set -channel A -evaluate multiply "$(awk "BEGIN{printf \"%.2f\", $opacity/100}")" \
                   -background none -rotate "$rot" \) \
                -gravity None -geometry +${clamped_px}+${clamped_py} -composite "$TMP"

            rm -f "$MASK"
        else
            # Formas rectangulares con esquinas redondeadas suaves
            local MASK="/tmp/awww-mask-${i}.png"
            local RADIUS=$(( iw < ih ? iw / 12 : ih / 12 ))
            magick -size ${iw}x${ih} xc:none \
                -fill white \
                -draw "roundrectangle 0,0,${iw},${ih},${RADIUS},${RADIUS}" \
                "$MASK"

            magick "$TMP" \
                \( "$img" -resize "${iw}x${ih}^" -gravity center -extent "${iw}x${ih}" \
                   "$MASK" -alpha off -compose copy_opacity -composite \
                   -alpha set -channel A -evaluate multiply "$(awk "BEGIN{printf \"%.2f\", $opacity/100}")" \
                   -background none -rotate "$rot" \) \
                -gravity None -geometry +${clamped_px}+${clamped_py} -composite "$TMP"

            rm -f "$MASK"
        fi
    done

    echo "$TMP"
}

# =========================================================
# BUCLE PRINCIPAL
# =========================================================
SKIP_WALLPAPER=0
trap 'SKIP_WALLPAPER=1' USR1

LAST_TRANSITION=""
LAST_POSITION=""
LAST_ANGLE=""
LAST_COLLAGE=0
INDEX=999999

TRANSITIONS=(fade wipe wave grow outer simple)
POSITIONS=(center top bottom left right)

while true; do
    SKIP_WALLPAPER=0

    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

    INTERVAL=${INTERVAL:-30}
    ENABLE_COLLAGE=${ENABLE_COLLAGE:-1}
    COLLAGE_CHANCE=${COLLAGE_CHANCE:-35}
    COLLAGE_MIN=${COLLAGE_MIN:-3}
    COLLAGE_MAX=${COLLAGE_MAX:-5}
    RANDOM_ORDER=${RANDOM_ORDER:-1}
    SMART_TRANSITIONS=${SMART_TRANSITIONS:-1}
    CONF_TRANSITION=${TRANSITION:-random}
    CONF_DURATION=${DURATION:-2}
    CONF_FPS=${FPS:-60}

    if [ $INDEX -ge ${#PLAYLIST[@]} ]; then
        if [ "$RANDOM_ORDER" -eq 1 ]; then
            mapfile -t PLAYLIST < <(printf "%s\n" "${WALLPAPERS[@]}" | shuf)
        else
            mapfile -t PLAYLIST < <(printf "%s\n" "${WALLPAPERS[@]}" | sort)
        fi
        INDEX=0
    fi
    CURRENT="${PLAYLIST[$INDEX]}"

    USE_COLLAGE=0
    if [[ "$ENABLE_COLLAGE" -eq 1 ]] && (( RANDOM % 100 < COLLAGE_CHANCE )) && [[ "$LAST_COLLAGE" -eq 0 ]]; then
        USE_COLLAGE=1
        LAST_COLLAGE=1
        CURRENT=$(create_collage "$COLLAGE_MIN" "$COLLAGE_MAX")
    else
        LAST_COLLAGE=0
    fi

    if [[ "$CONF_TRANSITION" == "random" ]]; then
        if [[ "$SMART_TRANSITIONS" -eq 1 ]]; then
            active_trans=$(pick_different "$LAST_TRANSITION" "${TRANSITIONS[@]}")
        else
            active_trans=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}
        fi
    else
        active_trans="$CONF_TRANSITION"
    fi

    position=$(pick_different "$LAST_POSITION" "${POSITIONS[@]}")
    angle=$((RANDOM % 360))
    while [[ "$angle" == "$LAST_ANGLE" ]]; do angle=$((RANDOM % 360)); done

    LAST_TRANSITION="$active_trans"
    LAST_POSITION="$position"
    LAST_ANGLE="$angle"

    if [[ "$USE_COLLAGE" -eq 1 ]]; then
        active_dur=$((CONF_DURATION + 2)); active_fps=120
    else
        active_dur=$CONF_DURATION; active_fps=$CONF_FPS
    fi

    awww img "$CURRENT" \
        --transition-type "$active_trans" \
        --transition-duration "$active_dur" \
        --transition-fps "$active_fps" \
        --transition-angle "$angle" \
        --transition-pos "$position"

    INDEX=$((INDEX + 1))

    count=0
    while [ $count -lt "$INTERVAL" ]; do
        [ "$SKIP_WALLPAPER" -eq 1 ] && break
        sleep 1
        count=$((count + 1))
    done
done