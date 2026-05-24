#!/usr/bin/env bash

# Evita que se abran múltiples ventanas si haces varios clics
pkill -f "yad --list --title=Binds de Hyprland"

hyprctl -j binds | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)

rows = []
for b in data:
    mods = b.get('modmask', 0)
    key  = b.get('key', '')
    disp = b.get('dispatcher', '')
    arg  = b.get('arg', '')

    if not key:
        continue

    # 1. Calcular teclas exactas usando bits (A prueba de errores)
    mod_names = []
    if mods & 64: mod_names.append('SUPER')
    if mods & 4:  mod_names.append('CTRL')
    if mods & 8:  mod_names.append('ALT')
    if mods & 1:  mod_names.append('SHIFT')

    combo = ' + '.join(mod_names + [key.upper()])

    # 2. Limpiar la basura de Lua y estructurar el comando
    if disp.startswith('__lua'):
        comando = 'Acción nativa de Lua'
    else:
        comando = disp
        if arg:
            comando += f' {arg}'

    rows.append((combo, comando))

# Ordenar alfabéticamente
rows.sort(key=lambda x: x[0])

# 3. Imprimir línea por línea (YAD lee la línea 1 como Col1, línea 2 como Col2)
for combo, comando in rows:
    print(combo)
    print(comando)
" | yad \
    --list \
    --title="Binds de Hyprland" \
    --width=950 \
    --height=650 \
    --center \
    --borders=10 \
    --no-buttons \
    --column="Atajo de teclado":TEXT \
    --column="Acción o Comando":TEXT \
    --search-column=1 \
    >/dev/null 2>&1 &