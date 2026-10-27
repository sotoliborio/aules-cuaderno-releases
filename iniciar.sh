#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
command -v docker >/dev/null 2>&1 || { echo 'No se encuentra Docker Desktop. Instálalo y ábrelo antes de iniciar.'; exit 1; }
docker info >/dev/null 2>&1 || { echo 'Abre Docker Desktop antes de continuar.'; exit 1; }
version=0.2.7
container=$(docker compose ps -a -q cuaderno)
installed=''
if [ -n "$container" ]; then
 installed=$(docker inspect --format '{{.Config.Image}}' "$container")
 case "$installed" in cuaderno-aules:*) installed=${installed#cuaderno-aules:};; *) echo 'La instalación existente no es compatible con este lanzador.';exit 1;; esac
fi
cache=$(mktemp -d)
trap 'rm -rf "$cache"' EXIT
echo 'Buscando actualizaciones de Cuaderno AULES…'
if curl --silent --show-error --fail --location --proto '=https' --connect-timeout 10 --max-time 20 https://api.github.com/repos/sotoliborio/aules-cuaderno-releases/releases/latest -o "$cache/latest.json"; then
 latest=$(sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' "$cache/latest.json" | head -1)
 if [ -n "$latest" ]; then version=$latest;else echo 'No se reconoce la versión pública; se conserva la disponible.';version=${installed:-$version};fi
else
 echo 'No se pudo consultar GitHub. Se iniciará la versión disponible sin actualizar.'
 version=${installed:-$version}
fi
if [ -n "$installed" ] && awk -v old="$installed" -v new="$version" 'BEGIN {split(old,a,".");split(new,b,".");for(i=1;i<=3;i++){if(a[i]>b[i])exit 0;if(a[i]<b[i])exit 1}exit 1}'; then version=$installed;fi
if ! docker image inspect "cuaderno-aules:$version" >/dev/null 2>&1; then
 case "$(uname -m)" in arm64|aarch64) arch=arm64;; x86_64|amd64) arch=amd64;; *) echo 'Arquitectura no compatible';exit 1;; esac
 asset="cuaderno-aules-web-$version-$arch.tar.gz"
 base="https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v$version"
 echo "Descargando la versión ${version}…"
 curl --fail --location --proto '=https' "$base/$asset" -o "$cache/$asset"
 curl --fail --location --proto '=https' "$base/SHA256SUMS.txt" -o "$cache/SHA256SUMS.txt"
 expected=$(awk -v name="$asset" '$2==name {print $1}' "$cache/SHA256SUMS.txt")
 [ ${#expected} -eq 64 ] || { echo 'No se encuentra una suma SHA256 válida.';exit 1; }
 (cd "$cache"; printf '%s  %s\n' "$expected" "$asset" | shasum -a 256 -c -)
 docker load -i "$cache/$asset"
fi
if [ -n "$installed" ] && [ "$installed" != "$version" ]; then
 echo "Actualizando de $installed a $version. Conservando los datos…"
 running=$(docker inspect --format '{{.State.Running}}' "$container")
 if [ "$running" != true ]; then
  docker start "$container" >/dev/null
  ready=false
  for i in $(seq 1 90); do
   if docker exec "$container" python /opt/cuaderno/healthcheck.py >/dev/null 2>&1; then ready=true;break;fi
   sleep 2
  done
  [ "$ready" = true ] || { echo 'No se pudo iniciar la versión anterior para proteger sus datos.';exit 1; }
 fi
 # Uses the existing container, independently of the newly downloaded compose file.
 docker exec "$container" python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py backup || { echo 'Actualización detenida. Espera a que terminen las tareas IA y vuelve a abrir iniciar.command.';exit 1; }
fi
# Preserve all existing settings; only the selected Docker image changes.
[ ! -e .env ] || cat .env > "$cache/env-old"
if [ -f "$cache/env-old" ]; then awk '!/^CUADERNO_IMAGE=/' "$cache/env-old" > "$cache/env-new";else : > "$cache/env-new";fi
printf '\nCUADERNO_IMAGE=cuaderno-aules:%s\n' "$version" >> "$cache/env-new"
cp "$cache/env-new" .env
chmod 600 .env
CUADERNO_IMAGE="cuaderno-aules:$version"
export CUADERNO_IMAGE
if [ -n "$installed" ] && [ "$installed" = "$version" ]; then
 # Starting an existing container avoids recreating it during active corrections.
 docker start "$container" >/dev/null
else
 docker compose up -d
fi
for i in $(seq 1 90); do
 if docker compose exec -T cuaderno python /opt/cuaderno/healthcheck.py >/dev/null 2>&1; then echo "Cuaderno $version preparado. Abriendo el navegador…"; if command -v open >/dev/null 2>&1; then open http://localhost:3000; fi;exit 0;fi
 sleep 2
done
echo 'No se ha confirmado el arranque. Revisa docker compose logs.';exit 1
