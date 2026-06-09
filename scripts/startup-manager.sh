```bash
#!/usr/bin/env bash

ACCENT="#89b4fa"

# ── Umbrales RAM (KB) ─────────────────────────────────────
RAM_HIGH=102400   # > 100 MB
RAM_MED=20480     # > 20 MB

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

# ── RAM ──────────────────────────────────────────────────

get_ram_kb() {
    local svc="$1"
    local kb
    kb=$(systemctl show "${svc}.service" --property=MemoryCurrent --no-pager 2>/dev/null \
        | cut -d= -f2-)
    # MemoryCurrent devuelve bytes o "[not set]" / "infinity" si no está activo
    if [[ "$kb" =~ ^[0-9]+$ ]]; then
        echo $(( kb / 1024 ))
    else
        echo 0
    fi
}

ram_label() {
    local kb="$1"
    if [ "$kb" -eq 0 ]; then
        echo "— N/D"
    elif [ "$kb" -gt "$RAM_HIGH" ]; then
        local mb=$(( kb / 1024 ))
        echo "▲ Alto  ${mb} MB"
    elif [ "$kb" -gt "$RAM_MED" ]; then
        local mb=$(( kb / 1024 ))
        echo "● Medio  ${mb} MB"
    else
        echo "▼ Bajo  ${kb} KB"
    fi
}

# ── Descubrimiento de servicios ───────────────────────────

get_services() {
    local filter="${1:-all}"
    case "$filter" in
        active)
            systemctl list-units --type=service --state=active --no-legend --no-pager \
                | awk '{print $1}' | sed 's/\.service$//' | sort
            ;;
        inactive)
            systemctl list-units --type=service --state=inactive --no-legend --no-pager \
                | awk '{print $1}' | sed 's/\.service$//' | sort
            ;;
        *)
            systemctl list-unit-files --type=service --no-legend --no-pager \
                | awk '{print $1}' | sed 's/\.service$//' | sort
            ;;
    esac
}

get_description() {
    systemctl show "${1}.service" --property=Description --no-pager 2>/dev/null \
        | cut -d= -f2-
}

get_display_name() {
    local desc
    desc=$(get_description "$1")
    [ -n "$desc" ] && echo "$desc" || echo "$1"
}

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
    local filter="${1:-all}"
    while IFS= read -r svc; do
        local ram_kb
        ram_kb=$(get_ram_kb "$svc")
        printf "%s\n%s\n%s\n%s\n%s\n%s\n" \
            "$(get_display_name "$svc")" \
            "$svc" \
            "$(enabled_label "$svc")" \
            "$(active_label  "$svc")" \
            "$(ram_label "$ram_kb")" \
            "$(get_description "$svc")"
    done < <(get_services "$filter")
}

show_gui() {
    local filter="${1:-all}"
    local tmpfile
    tmpfile=$(mktemp)

    case "$filter" in
        active)   filter_label="Mostrando: <b>Corriendo</b>" ;;
        inactive) filter_label="Mostrando: <b>Detenidos</b>" ;;
        *)        filter_label="Mostrando: <b>Todos</b>"     ;;
    esac

    build_rows "$filter" | yad --list \
        --title="Gestor de Arranque del Sistema" \
        --width=1100 \
        --height=420 \
        --center \
        --borders=12 \
        --separator="|" \
        --print-column=2 \
        --column="Servicio":TEXT \
        --column="ID":TEXT \
        --column="Arranque":TEXT \
        --column="Estado actual":TEXT \
        --column="RAM":TEXT \
        --column="Descripción":TEXT \
        --text="<b><span color='${ACCENT}' size='large'>Servicios del sistema</span></b>  <span color='#bbbbbb'>${filter_label}</span>\n<span color='#bbbbbb'>Selecciona una fila y usa los botones para controlarlo</span>" \
        --button="󰒓 Toggle Arranque:0" \
        --button="⏯ Iniciar/Detener:2" \
        --button="󱃝 Corriendo:4" \
        --button="󰝦 Detenidos:6" \
        --button="󰋚 Todos:8" \
        --button="󰈆 Cerrar:1" \
        2>/dev/null > "$tmpfile"

    local exit_code=$?
    local selected
    selected=$(cat "$tmpfile" | tr -d '|' | xargs)
    rm -f "$tmpfile"

    printf "%d\n%s" "$exit_code" "$selected"
}

# ── Loop principal ────────────────────────────────────────

CURRENT_FILTER="all"

while true; do
    RESULT=$(show_gui "$CURRENT_FILTER")
    EXIT_CODE="${RESULT%%$'\n'*}"
    SVC="${RESULT#*$'\n'}"

    case "$EXIT_CODE" in
        1|252)
            exit 0
            ;;
        4)
            CURRENT_FILTER="active"
            continue
            ;;
        6)
            CURRENT_FILTER="inactive"
            continue
            ;;
        8)
            CURRENT_FILTER="all"
            continue
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
```