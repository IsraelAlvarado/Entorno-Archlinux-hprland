#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CONFIG_FILE="$HOME/.config/hypr/scripts/wallpaper.conf"

pgrep awww-daemon >/dev/null || awww-daemon &
sleep 1

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
       -o -iname "*.webp" -o -iname "*.mp4" \))
[[ ${#WALLPAPERS[@]} -eq 0 ]] && exit 1

# =========================================================
# FUNCIONES NÚCLEO
# =========================================================

is_video() { [[ "${1,,}" =~ \.mp4$ ]]; }

pick_different() {
    local last="$1"; shift; local arr=("$@"); local val
    while true; do
        val=${arr[$RANDOM % ${#arr[@]}]}
        [[ "$val" != "$last" ]] && break
    done
    echo "$val"
}

set_wallpaper() {
    local file="$1"
    if is_video "$file"; then
        command -v mpvpaper &>/dev/null || return
        pkill mpvpaper 2>/dev/null
        mpvpaper -o "--loop --no-audio" "*" "$file" &
        return
    fi
    pkill mpvpaper 2>/dev/null
    awww img "$file" \
        --transition-type     "$active_trans" \
        --transition-duration "$active_dur" \
        --transition-fps      "$active_fps" \
        --transition-angle    "$angle" \
        --transition-pos      "$position"
}

# Bounding box exacto de IW×IH rotado ROT grados (normaliza a 0-90)
rotated_bbox() {
    awk -v iw="$1" -v ih="$2" -v rot="$3" 'BEGIN {
        pi = 3.14159265358979
        r  = rot % 360
        if (r < 0) r += 360
        r  = r % 180
        if (r > 90) r = 180 - r
        r  = r * pi / 180
        printf "%d %d", int(iw*cos(r) + ih*sin(r)) + 4, int(iw*sin(r) + ih*cos(r)) + 4
    }' /dev/null
}

# =========================================================
# COLLAGE
# =========================================================
create_collage() {
    local MIN_IMG=$1 MAX_IMG=$2
    local TMP="/tmp/awww-collage.png"
    local W=2560 H=1600

    mapfile -t STATIC < <(printf "%s\n" "${WALLPAPERS[@]}" | grep -vEi '\.mp4$')
    [[ ${#STATIC[@]} -lt $MIN_IMG ]] && return 1

    local COUNT=$(( MIN_IMG + RANDOM % (MAX_IMG - MIN_IMG + 1) ))
    mapfile -t PICKS < <(printf "%s\n" "${STATIC[@]}" | shuf -n "$COUNT")

    local LAYOUTS=(grid scatter cascade strip_h strip_v fan)
    local LAYOUT=${LAYOUTS[$RANDOM % ${#LAYOUTS[@]}]}
    local SHAPE_LIST=(circle landscape portrait square wide tall)

    declare -a POS_X POS_Y SIZES ROTATIONS SHAPES

    case "$LAYOUT" in
        grid)
            local COLS=$(( (COUNT + 1) / 2 )) ROWS=2
            [[ $COUNT -le 2 ]] && COLS=$COUNT && ROWS=1
            local CW=$(( W / COLS )) CH=$(( H / ROWS ))
            for (( i=0; i<COUNT; i++ )); do
                local col=$(( i % COLS )) row=$(( i / COLS ))
                local cell_min=$(( CW < CH ? CW : CH ))
                SIZES[$i]=$(( cell_min - 60 ))
                POS_X[$i]=$(( col * CW + CW/2 ))
                POS_Y[$i]=$(( row * CH + CH/2 ))
                ROTATIONS[$i]=$(( -8 + RANDOM % 17 ))
            done
            ;;
        scatter)
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 350 + RANDOM % 550 ))
                local safe=$(( sz * 72 / 100 ))
                SIZES[$i]=$sz
                POS_X[$i]=$(( safe + RANDOM % (W - safe*2) ))
                POS_Y[$i]=$(( safe + RANDOM % (H - safe*2) ))
                ROTATIONS[$i]=$(( -35 + RANDOM % 71 ))
            done
            ;;
        cascade)
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 500 + RANDOM % 400 ))
                local safe=$(( sz * 72 / 100 ))
                local step_x=$(( (W - safe*2) / (COUNT > 1 ? COUNT-1 : 1) ))
                local step_y=$(( (H - safe*2) / (COUNT > 1 ? COUNT-1 : 1) ))
                local px=$(( safe + i*step_x + (-60 + RANDOM % 121) ))
                local py=$(( safe + i*step_y + (-60 + RANDOM % 121) ))
                [[ $px -lt $safe       ]] && px=$safe
                [[ $py -lt $safe       ]] && py=$safe
                [[ $px -gt $((W-safe)) ]] && px=$((W-safe))
                [[ $py -gt $((H-safe)) ]] && py=$((H-safe))
                SIZES[$i]=$sz; POS_X[$i]=$px; POS_Y[$i]=$py
                ROTATIONS[$i]=$(( -20 + RANDOM % 41 ))
            done
            ;;
        strip_h)
            local CW=$(( W / COUNT ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( CW - 40 ))
                [[ $sz -gt $((H-80)) ]] && sz=$((H-80))
                SIZES[$i]=$sz
                POS_X[$i]=$(( i*CW + CW/2 ))
                POS_Y[$i]=$(( H/2 + (-40 + RANDOM % 81) ))
                ROTATIONS[$i]=$(( -12 + RANDOM % 25 ))
            done
            ;;
        strip_v)
            local CH=$(( H / COUNT ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( CH - 40 ))
                [[ $sz -gt $((W-80)) ]] && sz=$((W-80))
                SIZES[$i]=$sz
                POS_X[$i]=$(( W/2 + (-40 + RANDOM % 81) ))
                POS_Y[$i]=$(( i*CH + CH/2 ))
                ROTATIONS[$i]=$(( -12 + RANDOM % 25 ))
            done
            ;;
        fan)
            local fcx=$(( W/2 )) fcy=$(( H + 100 ))
            local radius=$(( 600 + RANDOM % 400 ))
            for (( i=0; i<COUNT; i++ )); do
                local sz=$(( 400 + RANDOM % 400 ))
                local adeg=$(( 200 + 140*i / (COUNT > 1 ? COUNT-1 : 1) ))
                local px py safe
                px=$(awk -v cx="$fcx" -v r="$radius" -v a="$adeg" \
                    'BEGIN{printf "%d", cx + r*cos(a*3.14159/180)}' /dev/null)
                py=$(awk -v cy="$fcy" -v r="$radius" -v a="$adeg" \
                    'BEGIN{printf "%d", cy + r*sin(a*3.14159/180)}' /dev/null)
                safe=$(( sz * 72 / 100 ))
                [[ $px -lt $safe       ]] && px=$safe
                [[ $py -lt $safe       ]] && py=$safe
                [[ $px -gt $((W-safe)) ]] && px=$((W-safe))
                [[ $py -gt $((H-safe)) ]] && py=$((H-safe))
                SIZES[$i]=$sz; POS_X[$i]=$px; POS_Y[$i]=$py
                ROTATIONS[$i]=$(( adeg - 270 + (-10 + RANDOM % 21) ))
            done
            ;;
    esac

    for (( i=0; i<COUNT; i++ )); do
        SHAPES[$i]=${SHAPE_LIST[$RANDOM % ${#SHAPE_LIST[@]}]}
    done

    magick -size ${W}x${H} xc:"#0e0e0e" "$TMP"

    for (( i=0; i<COUNT; i++ )); do
        local img="${PICKS[$i]}"
        local sz=${SIZES[$i]} cx=${POS_X[$i]} cy=${POS_Y[$i]}
        local rot=${ROTATIONS[$i]} shape=${SHAPES[$i]}
        local opacity=$(( 70 + RANDOM % 31 ))
        local opacity_f; opacity_f=$(awk -v v="$opacity" 'BEGIN{printf "%.2f", v/100}' /dev/null)
        local iw ih

        case "$shape" in
            circle|square) iw=$sz; ih=$sz ;;
            landscape)
                iw=$(( sz * 16 / 9 ))
                [[ $iw -gt $((W-100)) ]] && iw=$((W-100))
                ih=$(( iw * 9 / 16 ))
                ;;
            portrait)  ih=$sz; iw=$(( sz * 9 / 16 )) ;;
            wide)
                iw=$(( sz * 2 ))
                [[ $iw -gt $((W-100)) ]] && iw=$((W-100))
                ih=$(( iw / 2 ))
                ;;
            tall) ih=$sz; iw=$(( sz / 2 )) ;;
        esac

        local MASK="/tmp/awww-mask-${i}.png"
        local RADIUS=$(( iw < ih ? iw/12 : ih/12 ))
        [[ $RADIUS -lt 10 ]] && RADIUS=10

        # Máscara: xc:none = alpha=0, dibujo blanco = alpha=255 en la forma
        if [[ "$shape" == "circle" ]]; then
            magick -size ${iw}x${ih} xc:none \
                -fill white \
                -draw "circle $((iw/2)),$((ih/2)) $((iw/2)),0" \
                "$MASK"
        else
            magick -size ${iw}x${ih} xc:none \
                -fill white \
                -draw "roundrectangle 0,0,$((iw-1)),$((ih-1)),${RADIUS},${RADIUS}" \
                "$MASK"
        fi

        # Bbox rotado para centrar la pieza en (cx, cy) — sin depender de magick identify
        local rw rh ox oy
        read -r rw rh < <(rotated_bbox "$iw" "$ih" "$rot")
        ox=$(( cx - rw/2 ))
        oy=$(( cy - rh/2 ))

        # Pieza inline: DstIn aplica la máscara, Over final evita filtrar el estado DstIn
        magick "$TMP" \
            \( "$img" \
               -resize "${iw}x${ih}^" -gravity center -extent "${iw}x${ih}" \
               -alpha on \
               "$MASK" -compose DstIn -composite \
               -channel Alpha -evaluate multiply "$opacity_f" +channel \
               -background none -rotate "$rot" \) \
            -compose Over -gravity None \
            -geometry "$(printf '%+d%+d' "$ox" "$oy")" \
            -composite "$TMP"

        rm -f "$MASK"
    done

    echo "$TMP"
}

# =========================================================
# BUCLE PRINCIPAL
# =========================================================
SKIP_WALLPAPER=0
trap 'SKIP_WALLPAPER=1' USR1

LAST_TRANSITION="" LAST_POSITION="" LAST_ANGLE="" LAST_COLLAGE=0
INDEX=999999
PLAYLIST=()
TRANSITIONS=(fade wipe wave grow outer simple)
POSITIONS=(center top bottom left right)

while true; do
    SKIP_WALLPAPER=0
    [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

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

    if [[ $INDEX -ge ${#PLAYLIST[@]} ]]; then
        if [[ "$RANDOM_ORDER" -eq 1 ]]; then
            mapfile -t PLAYLIST < <(printf "%s\n" "${WALLPAPERS[@]}" | shuf)
        else
            mapfile -t PLAYLIST < <(printf "%s\n" "${WALLPAPERS[@]}" | sort)
        fi
        INDEX=0
    fi
    CURRENT="${PLAYLIST[$INDEX]}"
    INDEX=$(( INDEX + 1 ))

    USE_COLLAGE=0
    if ! is_video "$CURRENT" && [[ "$ENABLE_COLLAGE" -eq 1 ]] && \
       (( RANDOM % 100 < COLLAGE_CHANCE )) && [[ "$LAST_COLLAGE" -eq 0 ]]; then
        if COLLAGE_PATH=$(create_collage "$COLLAGE_MIN" "$COLLAGE_MAX") && \
           [[ -f "$COLLAGE_PATH" ]]; then
            CURRENT="$COLLAGE_PATH"; USE_COLLAGE=1; LAST_COLLAGE=1
        else
            LAST_COLLAGE=0
        fi
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
    angle=$(( RANDOM % 360 ))
    while [[ "$angle" == "$LAST_ANGLE" ]]; do angle=$(( RANDOM % 360 )); done

    LAST_TRANSITION="$active_trans"
    LAST_POSITION="$position"
    LAST_ANGLE="$angle"

    if [[ "$USE_COLLAGE" -eq 1 ]]; then
        active_dur=$(( CONF_DURATION + 2 )); active_fps=120
    else
        active_dur=$CONF_DURATION; active_fps=$CONF_FPS
    fi

    set_wallpaper "$CURRENT"

    count=0
    while [[ $count -lt $INTERVAL ]]; do
        [[ "$SKIP_WALLPAPER" -eq 1 ]] && break
        sleep 1
        (( count++ ))
    done
done
SCRIPT