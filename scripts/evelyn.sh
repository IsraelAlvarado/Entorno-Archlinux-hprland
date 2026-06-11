#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/israel/Downloads/proyectos de github/odysseus/odysseus"
PORT=7000

if ! systemctl is-active --quiet docker.service; then
    sudo -n systemctl start docker.service
fi

cd "$PROJECT_DIR"

if ! docker compose ps odysseus 2>/dev/null | grep -q "Up"; then
    docker compose up -d odysseus
    sleep 2
fi

brave "http://localhost:$PORT"