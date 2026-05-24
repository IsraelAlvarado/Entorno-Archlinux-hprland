#!/usr/bin/env bash

LOGFILE="/tmp/arch-update.log"
ACCENT="#89b4fa"

# === CONFIGURACIÓN DE ASKPASS PARA SUDO ===
# Creamos un script temporal para pasar la contraseña a sudo en segundo plano
export SUDO_ASKPASS="/tmp/arch_yad_askpass.sh"
echo '#!/usr/bin/env bash' > "$SUDO_ASKPASS"
echo 'echo "$YAD_SUDO_PASS"' >> "$SUDO_ASKPASS"
chmod 700 "$SUDO_ASKPASS"

# Limpieza automática al cerrar el script
cleanup() {
    rm -f "$SUDO_ASKPASS"
    unset YAD_SUDO_PASS
}
trap cleanup EXIT
# ==========================================

get_updates() {

    OFFICIAL=$(checkupdates 2>/dev/null)
    AUR=$(yay -Qua 2>/dev/null)

    N_OFF=$(printf "%s\n" "$OFFICIAL" | grep -c .)
    N_AUR=$(printf "%s\n" "$AUR" | grep -c .)

    N_TOTAL=$((N_OFF + N_AUR))

    CRITICAL=$(printf "%s\n" "$OFFICIAL" | \
        grep -E "^(linux|nvidia|systemd|glibc|mesa|pipewire|hyprland) ")

    N_CRIT=$(printf "%s\n" "$CRITICAL" | grep -c .)

    NEEDS_REBOOT=0
    [ "$N_CRIT" -gt 0 ] && NEEDS_REBOOT=1
}

auth_sudo() {

    local PASS=$(yad --entry \
        --title="Autenticación" \
        --width=360 \
        --center \
        --hide-text \
        --image="dialog-password" \
        --text="<b>Ingrese contraseña de administrador</b>" \
        --entry-label="Contraseña:" \
        --button="󰄬 Autorizar!0" \
        --button="󰈆 Cancelar!1" \
        2>/dev/null)

    [ $? -ne 0 ] && return 1

    # Guardamos la contraseña en memoria para que el ASKPASS la lea
    export YAD_SUDO_PASS="$PASS"

    # Validamos la contraseña usando el método ASKPASS (-A)
    sudo -A -v >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        yad --error \
            --width=320 \
            --center \
            --text="<b>Contraseña incorrecta.</b>" \
            2>/dev/null
        
        unset YAD_SUDO_PASS
        return 1
    fi

    return 0
}

run_with_progress() {

    local title="$1"
    local cmd="$2"

    (
        echo "5"
        echo "# Iniciando..."

        bash -c "$cmd" > "$LOGFILE" 2>&1 &
        PID=$!

        i=5

        while kill -0 "$PID" 2>/dev/null; do

            i=$((i + 2))

            [ "$i" -gt 94 ] && i=15

            LAST=$(tail -1 "$LOGFILE" 2>/dev/null | \
                sed 's/\x1b\[[0-9;]*m//g' | cut -c1-70)

            echo "$i"
            echo "# ${LAST:-Procesando...}"

            sleep 0.35
        done

        wait "$PID"
        EXIT=$?

        echo "100"

        if [ "$EXIT" -eq 0 ]; then
            echo "# ✓ Completado"
        else
            echo "# ✗ Error detectado"
        fi

        sleep 0.7

    ) | yad --progress \
        --title="$title" \
        --width=520 \
        --height=110 \
        --center \
        --borders=10 \
        --auto-close \
        --no-cancel \
        --bar-color="$ACCENT" \
        --text="<b>$title</b>" \
        2>/dev/null

    if grep -qiE "error|failed|fatal" "$LOGFILE"; then

        yad --error \
            --title="Errores detectados" \
            --width=340 \
            --center \
            --text="<b>Se detectaron errores.</b>" \
            --button="󱝩 Ver logs!0" \
            2>/dev/null

        show_log

    else

        yad --info \
            --title="Completado" \
            --width=300 \
            --center \
            --text="<b>Operación finalizada correctamente.</b>" \
            --button="󰄬 OK!0" \
            2>/dev/null
    fi
}

show_log() {

    [ ! -f "$LOGFILE" ] && \
        echo "Sin logs disponibles." > "$LOGFILE"

    yad --text-info \
        --title="Logs del sistema" \
        --width=900 \
        --height=540 \
        --center \
        --fontname="JetBrainsMono Nerd Font 10" \
        --button="󰈆 Cerrar!0" \
        < <(sed 's/\x1b\[[0-9;]*m//g' "$LOGFILE") \
        2>/dev/null
}

show_search() {

    QUERY=$(yad --entry \
        --title="Buscar paquetes" \
        --width=460 \
        --center \
        --image="system-search" \
        --text="<b>Buscar paquetes</b>" \
        --entry-label="Buscar:" \
        --button="󰍉 Buscar!0" \
        --button="󰈆 Cancelar!1" \
        2>/dev/null)

    [ $? -ne 0 ] || [ -z "$QUERY" ] && return

    TMP=$(mktemp)

    yay -Ss "$QUERY" 2>/dev/null | awk '
    BEGIN { OFS="\n" }

    /^[a-zA-Z0-9_.+-]+\// {

        split($1,a,"/")

        repo=a[1]
        pkg=a[2]
        ver=$2

        getline desc

        gsub(/^[ \t]+/, "", desc)

        state=""

        cmd="pacman -Q " pkg " 2>/dev/null"

        if ((cmd | getline line) > 0) {

            split(line,b," ")

            if(b[2]==ver)
                state="✓ instalado"
            else
                state="󰚰 " b[2]
        }

        close(cmd)

        icon="󰣇"
        tipo="🛡️ Oficial"

        if(repo=="aur") {
            icon="󰮯"
            
            # Clasificación inteligente de paquetes AUR
            if (pkg ~ /-bin$/) {
                tipo="⚡ Binario (Rápido)"
            } else if (pkg ~ /-(git|svn|hg|bzr|nightly)$/) {
                tipo="🚧 Git/Dev (Inestable)"
            } else {
                tipo="📦 Fuente (Lento)"
            }
        }

        desc=substr(desc,1,85)

        # Se añade "tipo" a la salida
        print icon, repo, pkg, ver, state, tipo, desc
    }' | head -900 > "$TMP"

    [ ! -s "$TMP" ] && {

        yad --info \
            --width=320 \
            --center \
            --text="<b>No se encontraron resultados.</b>" \
            2>/dev/null

        rm -f "$TMP"
        return
    }

    # Se ajustan las columnas (se añade --column="Tipo de Paquete")
    SELECTED=$(yad --list \
        --title="Resultados: $QUERY" \
        --width=1280 \
        --height=680 \
        --center \
        --multiple \
        --separator=" " \
        --search-column=3 \
        --print-column=3 \
        --column="" \
        --column="Repo" \
        --column="Paquete" \
        --column="Versión" \
        --column="Estado" \
        --column="Tipo de Paquete" \
        --column="Descripción" \
        < "$TMP" \
        --button="󰄬 Instalar!0" \
        --button="󱓞 Copiar!2" \
        --button="󰈆 Cerrar!1" \
        2>/dev/null)

    EXIT_CODE=$?

    rm -f "$TMP"

    [ "$EXIT_CODE" -eq 1 ] || [ -z "$SELECTED" ] && return

    SELECTED_CLEAN=$(echo "$SELECTED" | xargs)

    [ -z "$SELECTED_CLEAN" ] && return

    if [ "$EXIT_CODE" -eq 2 ]; then
        echo "$SELECTED_CLEAN" | wl-copy
        return
    fi

    COUNT=$(echo "$SELECTED_CLEAN" | wc -w)

    yad --question \
        --title="Confirmar instalación" \
        --width=430 \
        --center \
        --text="¿Instalar <b>$COUNT</b> paquete(s)?\n\n<span color='#89b4fa'>$SELECTED_CLEAN</span>" \
        --button="󰄬 Sí!0" \
        --button="󰈆 No!1" \
        2>/dev/null

    [ $? -ne 0 ] && return

    auth_sudo || return

    run_with_progress \
        "Instalando paquetes" \
        "yay -S --needed --noconfirm --sudoflags \"-A\" -- $SELECTED_CLEAN"
}

show_installed_apps() {

    TMP=$(mktemp)

    pacman -Qe | while read -r pkg ver; do

        if pacman -Qi "$pkg" 2>/dev/null | grep -q "Repository.*None"; then
            repo="AUR"
            icon="󰮯"
        else
            repo="Repo"
            icon="󰣇"
        fi

        printf "%s|%s|%s|%s\n" \
            "$icon" \
            "$repo" \
            "$pkg" \
            "$ver"

    done | sort -t'|' -k3 > "$TMP"

    [ ! -s "$TMP" ] && {
        rm -f "$TMP"
        return
    }

    SELECTED=$(cat "$TMP" | tr '|' '\n' | yad --list \
        --title="Aplicaciones instaladas" \
        --width=1000 \
        --height=680 \
        --center \
        --multiple \
        --separator=" " \
        --search-column=3 \
        --print-column=3 \
        --column="" \
        --column="Origen" \
        --column="Paquete" \
        --column="Versión" \
        --button="󰆴 Desinstalar!0" \
        --button="󱓞 Copiar!2" \
        --button="󰈆 Cerrar!1" \
        2>/dev/null)

    EXIT_CODE=$?

    rm -f "$TMP"

    [ "$EXIT_CODE" -eq 1 ] || [ -z "$SELECTED" ] && return

    SELECTED_CLEAN=$(echo "$SELECTED" | xargs)

    [ -z "$SELECTED_CLEAN" ] && return

    if [ "$EXIT_CODE" -eq 2 ]; then
        echo "$SELECTED_CLEAN" | wl-copy
        return
    fi

    COUNT=$(echo "$SELECTED_CLEAN" | wc -w)

    yad --question \
        --title="Confirmar desinstalación" \
        --width=430 \
        --center \
        --text="¿Desinstalar <b>$COUNT</b> paquete(s)?\n\n<span color='#f38ba8'>$SELECTED_CLEAN</span>" \
        --button="󰆴 Sí!0" \
        --button="󰈆 No!1" \
        2>/dev/null

    [ $? -ne 0 ] && return

    auth_sudo || return

    run_with_progress \
        "Desinstalando paquetes" \
        "yay -Rns --noconfirm --sudoflags \"-A\" -- $SELECTED_CLEAN"
}

show_main() {

    get_updates

    if [ "$N_TOTAL" -eq 0 ]; then

        STATUS_TEXT="✓ Sistema actualizado"
        STATUS_COLOR="#a6e3a1"

    elif [ "$N_CRIT" -gt 0 ]; then

        STATUS_TEXT="⚠ Actualizaciones críticas"
        STATUS_COLOR="#f38ba8"

    else

        STATUS_TEXT="󰚰 Actualizaciones disponibles"
        STATUS_COLOR="#f9e2af"
    fi

    REBOOT_TEXT=""

    [ "$NEEDS_REBOOT" -eq 1 ] && \
        REBOOT_TEXT="\n<span color='#f38ba8'>Reinicio recomendado</span>"

    LIST=""

    if [ -n "$OFFICIAL" ]; then

        while IFS= read -r line; do

            pkg=$(echo "$line" | awk '{print $1}')
            from=$(echo "$line" | awk '{print $2}')
            to=$(echo "$line" | awk '{print $4}')

            badge="󰣇"
            echo "$CRITICAL" | grep -q "^$pkg " && badge="⚠ "

            LIST+="${badge}\n${pkg}\n${from}\n➜\n${to}\n"

        done <<< "$OFFICIAL"
    fi

    if [ -n "$AUR" ]; then

        while IFS= read -r line; do

            pkg=$(echo "$line" | awk '{print $1}')
            from=$(echo "$line" | awk '{print $2}')
            to=$(echo "$line" | awk '{print $4}')

            LIST+="󰮯\n${pkg}\n${from}\n➜\n${to}\n"

        done <<< "$AUR"
    fi

    [ -z "$LIST" ] && \
        LIST="✓\nSistema actualizado\n—\n\n—\n"

    HEADER="<b><span color='${STATUS_COLOR}' size='large'>${STATUS_TEXT}</span></b>"

    HEADER+="\n<span color='#bbbbbb'>"

    HEADER+="Repos: <b>${N_OFF}</b>     "
    HEADER+="AUR: <b>${N_AUR}</b>     "
    HEADER+="Críticos: <b>${N_CRIT}</b>     "
    HEADER+="Total: <b>${N_TOTAL}</b>"

    HEADER+="</span>${REBOOT_TEXT}"

    printf "%b" "$LIST" | yad --list \
        --title="Arch Update Manager" \
        --width=780 \
        --height=500 \
        --center \
        --borders=8 \
        --text="$HEADER" \
        --column="" \
        --column="Paquete" \
        --column="Actual" \
        --column="" \
        --column="Nueva" \
        --no-selection \
        --button="󰄬 Actualizar!0" \
        --button="󰣇 Repo!1" \
        --button="󰮯 AUR!2" \
        --button="󰍉 Buscar!3" \
        --button="󰏖 Apps!4" \
        --button="󰃢 Caché!5" \
        --button="󱝩 Logs!6" \
        --button="󰈆 Cerrar!7" \
        2>/dev/null

    echo "$?"
}

while true; do

    ACTION=$(show_main)

    case "$ACTION" in

        0)
            auth_sudo || continue
            run_with_progress \
                "Actualizando sistema" \
                "yay -Syu --noconfirm --sudoflags \"-A\""
        ;;

        1)
            auth_sudo || continue
            run_with_progress \
                "Actualizando repositorios" \
                "sudo -A pacman -Syu --noconfirm"
        ;;

        2)
            auth_sudo || continue
            run_with_progress \
                "Actualizando AUR" \
                "yay -Sua --noconfirm --sudoflags \"-A\""
        ;;

        3)
            show_search
        ;;

        4)
            show_installed_apps
        ;;

        5)
            auth_sudo || continue
            run_with_progress \
                "Limpiando caché" \
                "yay -Scc --noconfirm --sudoflags \"-A\""
        ;;

        6)
            show_log
        ;;

        *)
            exit 0
        ;;

    esac

done