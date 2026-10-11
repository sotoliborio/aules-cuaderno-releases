$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (!(Get-Command docker -ErrorAction SilentlyContinue)) { throw 'No se encuentra Docker Desktop. Instálalo, ábrelo y vuelve a iniciar.' }
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw 'Abre Docker Desktop antes de continuar.' }
$version = '0.2.5'
$container = docker compose ps -a -q cuaderno
if ($LASTEXITCODE -ne 0) { throw 'No se ha podido consultar la instalación local.' }
$installed = ''
if ($container) {
 $image = docker inspect --format '{{.Config.Image}}' $container
 if ($LASTEXITCODE -ne 0 -or $image -notmatch '^cuaderno-aules:(\d+\.\d+\.\d+)$') { throw 'La instalación existente no es compatible.' }
 $installed = $Matches[1]
}
Write-Host 'Buscando actualizaciones de Cuaderno AULES…'
try {
 $release = Invoke-RestMethod 'https://api.github.com/repos/sotoliborio/aules-cuaderno-releases/releases/latest' -TimeoutSec 20
 if ($release.tag_name -notmatch '^v(\d+\.\d+\.\d+)$') { throw 'Versión pública no válida' }
 $version = $Matches[1]
} catch {
 Write-Host 'No se pudo consultar GitHub. Se iniciará la versión disponible sin actualizar.'
 if ($installed) { $version = $installed }
}
if ($installed -and [version]$installed -gt [version]$version) { $version = $installed }
docker image inspect "cuaderno-aules:$version" *> $null
if ($LASTEXITCODE -ne 0) {
 $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'amd64' }
 $asset = "cuaderno-aules-web-$version-$arch.tar.gz"
 $base = "https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v$version"
 $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
 New-Item -ItemType Directory $cache | Out-Null
 try {
  Write-Host "Descargando la versión ${version}…"
  Invoke-WebRequest "$base/$asset" -OutFile (Join-Path $cache $asset) -UseBasicParsing
  Invoke-WebRequest "$base/SHA256SUMS.txt" -OutFile (Join-Path $cache 'SHA256SUMS.txt') -UseBasicParsing
  $expected = ((Get-Content (Join-Path $cache 'SHA256SUMS.txt') | Where-Object { $_.EndsWith("  $asset") }) -split ' ')[0]
  if ($expected -notmatch '^[a-f0-9]{64}$' -or (Get-FileHash (Join-Path $cache $asset) -Algorithm SHA256).Hash.ToLower() -ne $expected) { throw 'La descarga no supera la comprobación SHA256.' }
  docker load -i (Join-Path $cache $asset)
  if ($LASTEXITCODE -ne 0) { throw 'No se ha podido cargar la imagen.' }
 } finally { Remove-Item $cache -Recurse -Force }
}
if ($installed -and $installed -ne $version) {
 Write-Host "Actualizando de $installed a $version. Conservando los datos…"
 $running = docker inspect --format '{{.State.Running}}' $container
 if ($LASTEXITCODE -ne 0) { throw 'No se ha podido comprobar el cuaderno.' }
 if ($running -ne 'true') {
  docker start $container *> $null
  if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar la versión anterior.' }
  $ready = $false
  for ($i=0; $i -lt 90; $i++) {
   docker exec $container python /opt/cuaderno/healthcheck.py *> $null
   if ($LASTEXITCODE -eq 0) { $ready=$true; break }
   Start-Sleep 2
  }
  if (!$ready) { throw 'No se pudo preparar la copia de seguridad de la versión anterior.' }
 }
 docker exec $container python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py backup
 if ($LASTEXITCODE -ne 0) { throw 'Actualización detenida. Espera a que terminen las tareas IA y vuelve a iniciar.' }
}
$settings = @(if (Test-Path .env) { Get-Content .env | Where-Object { $_ -notmatch '^CUADERNO_IMAGE=' } })
$settings += "CUADERNO_IMAGE=cuaderno-aules:$version"
[System.IO.File]::WriteAllLines((Join-Path $PSScriptRoot '.env'),$settings,(New-Object System.Text.UTF8Encoding($false)))
$env:CUADERNO_IMAGE="cuaderno-aules:$version"
if ($installed -and $installed -eq $version) { docker start $container *> $null } else { docker compose up -d }
if ($LASTEXITCODE -ne 0) { throw 'No se ha podido iniciar el cuaderno.' }
for ($i=0; $i -lt 90; $i++) {
 docker compose exec -T cuaderno python /opt/cuaderno/healthcheck.py *> $null
 if ($LASTEXITCODE -eq 0) { Write-Host "Cuaderno $version preparado. Abriendo el navegador…"; Start-Process 'http://localhost:3000'; exit 0 }
 Start-Sleep 2
}
throw 'No se ha confirmado el arranque. Revisa docker compose logs.'
