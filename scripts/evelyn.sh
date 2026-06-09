#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/israel/Downloads/proyectos de github/odysseus/odysseus"
PORT=7000

cd "$PROJECT_DIR"

if ! docker compose ps odysseus 2>/dev/null | grep -q "Up"; then
    docker compose up -d odysseus
    sleep 2
fi

brave "http://localhost:$PORT"
