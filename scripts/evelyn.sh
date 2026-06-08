#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/israel/Downloads/proyectos de github/odysseus/odysseus"
PORT=7000

cd "$PROJECT_DIR"

if ! docker compose ps odysseus | grep -q "Up"; then
    docker compose up -d odysseus
fi

xdg-open "http://localhost:$PORT" 2>/dev/null || \
    brave "http://localhost:$PORT" 2>/dev/null || \
    firefox "http://localhost:$PORT" 2>/dev/null