#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
docker info >/dev/null 2>&1 || { echo 'Instala y abre Docker Desktop antes de continuar.'; exit 1; }
if ! docker image inspect cuaderno-aules:0.2.3 >/dev/null 2>&1; then
 case "$(uname -m)" in arm64|aarch64) arch=arm64;; x86_64|amd64) arch=amd64;; *) echo 'Arquitectura no compatible';exit 1;; esac
 asset="cuaderno-aules-web-0.2.3-$arch.tar.gz"
 base=https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.2.3
 cache=$(mktemp -d)
 trap 'rm -rf "$cache"' EXIT
 curl --fail --location --proto '=https' "$base/$asset" -o "$cache/$asset"
 curl --fail --location --proto '=https' "$base/SHA256SUMS.txt" -o "$cache/SHA256SUMS.txt"
 (cd "$cache"; if command -v sha256sum >/dev/null 2>&1; then sha256sum --ignore-missing -c SHA256SUMS.txt; else grep "  $asset$" SHA256SUMS.txt | shasum -a 256 -c -; fi)
 docker load -i "$cache/$asset"
fi
docker compose up -d
for i in $(seq 1 90); do
 if docker compose exec -T cuaderno python /opt/cuaderno/healthcheck.py >/dev/null 2>&1; then echo 'Abre http://localhost:3000';exit 0;fi
 sleep 2
done
echo 'No se ha confirmado el arranque. Revisa docker compose logs.';exit 1
