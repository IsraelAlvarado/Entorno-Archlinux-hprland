#!/usr/bin/env bash

ACCENT="#89b4fa"

SERVICES=(
    "docker|Docker Daemon|Motor de contenedores"
    "mongodb|MongoDB|Base de datos"
    "ollama|Ollama AI|Modelos IA locales (~1-2 GiB)"
    "waydroid-container|Waydroid|Contenedor Android"
    "warp-svc|Cloudflare WARP|VPN en segundo plano"
    "bluetooth|Bluetooth|Dispositivos BT"
    "cups|Impresión CUPS|Impresora"
    "cpupower|CPU Power|Frecuencia CPU"
    "tlp|TLP Batería|Optimización de batería"
    "NetworkManager|NetworkManager|Red (mantener activo)"
)

# ── Auth ─────────────────────────────────────────────────

auth_sudo() {
    local pass askpass
    pass=$(yad --entry \
        --title="Autenticación" \
        --width=360 --center --hide-text \
        --image="dialog-password" \
        --text="<b>Contraseña de administrador</b>" \
        --entry-label="Contraseña:" \
        --button="󰄬 Autorizar:0" \
        --button="󰈆 Cancelar:1" \
        2>/dev/null) || return 1

    askpass="/tmp/sm_askpass_$$.sh"
    printf '#!/usr/bin/env bash\necho "%s"\n' "$pass" > "$askpass"
    chmod 700 "$askpass"
    export SUDO_ASKPASS="$askpass"
    export _SM_ASKPASS="$askpass"

    if ! sudo -A -v >/dev/null 2>&1; then
        yad --error --width=300 --center \
            --text="<b>Contraseña incorrecta.</b>" 2>/dev/null
        rm -f "$askpass"
        unset SUDO_ASKPASS _SM_ASKPASS
        return 1
    fi
}

cleanup_auth() {
    [ -n "${_SM_ASKPASS:-}" ] && rm -f "$_SM_ASKPASS"
    unset SUDO_ASKPASS _SM_ASKPASS
}

# ── Estado ───────────────────────────────────────────────

is_enabled() { systemctl is-enabled "$1" 2>/dev/null | grep -q "^enabled$"; }
is_active()  { systemctl is-active  "$1" 2>/dev/null | grep -q "^active$";  }

enabled_label() { is_enabled "$1" && echo "󰄬 Arranque ON"  || echo "󰅖 Arranque OFF"; }
active_label()  { is_active  "$1" && echo "▶ Corriendo"    || echo "■ Detenido";     }

# ── Acciones ─────────────────────────────────────────────

toggle_startup() {
    local svc="$1"
    auth_sudo || return
    if is_enabled "$svc"; then
        sudo -A systemctl disable "$svc" 2>/dev/null \
            && notify-send "Startup Manager" "󰅖 $svc deshabilitado del arranque"
    else
        sudo -A systemctl enable "$svc" 2>/dev/null \
            && notify-send "Startup Manager" "󰄬 $svc habilitado en el arranque"
    fi
    cleanup_auth
}

toggle_now() {
    local svc="$1"
    auth_sudo || return
    if is_active "$svc"; then
        sudo -A systemctl stop "$svc" 2>/dev/null \
            && notify-send "Startup Manager" "■ $svc detenido"
    else
        sudo -A systemctl start "$svc" 2>/dev/null \
            && notify-send "Startup Manager" "▶ $svc iniciado"
    fi
    cleanup_auth
}

# ── GUI ──────────────────────────────────────────────────

build_rows() {
    for entry in "${SERVICES[@]}"; do
        IFS="|" read -r svc name desc <<< "$entry"
        printf "%s\n%s\n%s\n%s\n%s\n" \
            "$name" \
            "$svc" \
            "$(enabled_label "$svc")" \
            "$(active_label  "$svc")" \
            "$desc"
    done
}

show_gui() {
    local tmpfile
    tmpfile=$(mktemp)

    build_rows | yad --list \
        --title="Gestor de Arranque del Sistema" \
        --width=980 \
        --height=420 \
        --center \
        --borders=12 \
        --separator="|" \
        --print-column=2 \
        --column="Servicio":TEXT \
        --column="ID":TEXT \
        --column="Arranque":TEXT \
        --column="Estado actual":TEXT \
        --column="Descripción":TEXT \
        --text="<b><span color='${ACCENT}' size='large'>Servicios del sistema</span></b>\n<span color='#bbbbbb'>Selecciona una fila y usa los botones para controlarlo</span>" \
        --button="󰒓 Toggle Arranque:0" \
        --button="⏯ Iniciar/Detener:2" \
        --button="󰈆 Cerrar:1" \
        2>/dev/null > "$tmpfile"

    local exit_code=$?
    local selected
    selected=$(cat "$tmpfile" | tr -d '|' | xargs)
    rm -f "$tmpfile"

    printf "%d\n%s" "$exit_code" "$selected"
}

# ── Loop principal ────────────────────────────────────────

while true; do
    RESULT=$(show_gui)
    EXIT_CODE="${RESULT%%$'\n'*}"
    SVC="${RESULT#*$'\n'}"

    case "$EXIT_CODE" in
        1|252)
            exit 0
            ;;
        0)
            if [ -z "$SVC" ]; then
                yad --info --width=320 --center \
                    --text="<b>Selecciona un servicio primero.</b>" \
                    --button="󰄬 OK:0" 2>/dev/null
                continue
            fi
            toggle_startup "$SVC"
            ;;
        2)
            if [ -z "$SVC" ]; then
                yad --info --width=320 --center \
                    --text="<b>Selecciona un servicio primero.</b>" \
                    --button="󰄬 OK:0" 2>/dev/null
                continue
            fi
            toggle_now "$SVC"
            ;;
    esac
done