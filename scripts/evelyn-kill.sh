#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/israel/Downloads/proyectos de github/odysseus/odysseus"

cd "$PROJECT_DIR"

docker compose stop odysseus
docker compose rm -f odysseus

sudo -n systemctl stop docker.service
notify-send "Evelyn" "Servicio detenido y contenedor eliminado"