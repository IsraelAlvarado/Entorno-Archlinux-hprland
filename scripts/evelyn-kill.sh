#!/usr/bin/env bash
PROJECT_DIR="/home/israel/Downloads/proyectos de github/odysseus/odysseus"

cd "$PROJECT_DIR"
docker compose stop odysseus
docker compose rm -f odysseus
notify-send "Evelyn" "Servicio detenido y contenedor eliminado"
