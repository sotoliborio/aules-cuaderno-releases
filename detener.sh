#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
docker compose exec -T cuaderno python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py check
docker compose down
