$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
Set-Location $PSScriptRoot
$version = '0.2.13'

# Docker escribe avisos en stderr; en Windows PowerShell 5.1 eso no debe detener el lanzador.
# Solo cuenta el código de salida del comando.
function Invoke-DockerQuiet {
 $previous = $ErrorActionPreference
 $ErrorActionPreference = 'Continue'
 try { & docker @args 2>&1 | Out-Null; return $LASTEXITCODE } finally { $ErrorActionPreference = $previous }
}
function Invoke-DockerOutput {
 $previous = $ErrorActionPreference
 $ErrorActionPreference = 'Continue'
 try {
  $output = & docker @args 2>$null
  $script:DockerExit = $LASTEXITCODE
  return (@($output) | ForEach-Object { "$_" }) -join "`n"
 } finally { $ErrorActionPreference = $previous }
}
function Invoke-DockerVisible {
 $previous = $ErrorActionPreference
 $ErrorActionPreference = 'Continue'
 try { & docker @args 2>&1 | ForEach-Object { Write-Host "$_" }; return $LASTEXITCODE } finally { $ErrorActionPreference = $previous }
}

if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
 throw 'No se encuentra Docker Desktop. Instálalo desde docker.com, ábrelo una vez y vuelve a abrir iniciar.bat.'
}
if ((Invoke-DockerQuiet info) -ne 0) {
 $desktop = @("$env:ProgramFiles\Docker\Docker\Docker Desktop.exe", "$env:LOCALAPPDATA\Docker\Docker Desktop.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
 if ($desktop) {
  Write-Host 'Docker Desktop no está en marcha. Abriéndolo; puede tardar un par de minutos la primera vez…'
  Start-Process $desktop | Out-Null
 } else {
  Write-Host 'Docker Desktop no está en marcha. Ábrelo desde el menú Inicio; este lanzador esperará.'
 }
 $ready = $false
 for ($i = 0; $i -lt 90; $i++) {
  Start-Sleep 2
  if ((Invoke-DockerQuiet info) -eq 0) { $ready = $true; break }
  if ($i % 10 -eq 9) { Write-Host 'Esperando a Docker Desktop…' }
 }
 if (!$ready) { throw 'Docker Desktop no ha respondido en 3 minutos. Ábrelo, espera a que indique «Engine running» y vuelve a abrir iniciar.bat.' }
}

$container = (Invoke-DockerOutput compose ps -a -q cuaderno).Trim()
if ($script:DockerExit -ne 0) { throw 'No se ha podido consultar la instalación local de Docker.' }
$installed = ''
if ($container) {
 $image = (Invoke-DockerOutput inspect --format '{{.Config.Image}}' $container).Trim()
 if ($script:DockerExit -ne 0 -or $image -notmatch '^cuaderno-aules:(\d+\.\d+\.\d+)$') { throw 'La instalación existente no es compatible.' }
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
if ((Invoke-DockerQuiet image inspect "cuaderno-aules:$version") -ne 0) {
 $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'amd64' }
 $asset = "cuaderno-aules-web-$version-$arch.tar.gz"
 $base = "https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v$version"
 $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
 New-Item -ItemType Directory $cache | Out-Null
 try {
  Write-Host "Descargando la versión ${version} (unos 320 MB la primera vez)…"
  $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest "$base/$asset" -OutFile (Join-Path $cache $asset) -UseBasicParsing
  Invoke-WebRequest "$base/SHA256SUMS.txt" -OutFile (Join-Path $cache 'SHA256SUMS.txt') -UseBasicParsing
  $expected = ((Get-Content (Join-Path $cache 'SHA256SUMS.txt') | Where-Object { $_.EndsWith("  $asset") }) -split ' ')[0]
  if ($expected -notmatch '^[a-f0-9]{64}$' -or (Get-FileHash (Join-Path $cache $asset) -Algorithm SHA256).Hash.ToLower() -ne $expected) { throw 'La descarga no supera la comprobación SHA256.' }
  Write-Host 'Cargando la imagen en Docker…'
  if ((Invoke-DockerVisible load -i (Join-Path $cache $asset)) -ne 0) { throw 'No se ha podido cargar la imagen en Docker.' }
 } finally { Remove-Item $cache -Recurse -Force -ErrorAction SilentlyContinue }
}
if ($installed -and $installed -ne $version) {
 Write-Host "Actualizando de $installed a $version. Conservando los datos…"
 $running = (Invoke-DockerOutput inspect --format '{{.State.Running}}' $container).Trim()
 if ($script:DockerExit -ne 0) { throw 'No se ha podido comprobar el cuaderno.' }
 if ($running -ne 'true') {
  if ((Invoke-DockerQuiet start $container) -ne 0) { throw 'No se pudo iniciar la versión anterior.' }
  $ready = $false
  for ($i = 0; $i -lt 90; $i++) {
   if ((Invoke-DockerQuiet exec $container python /opt/cuaderno/healthcheck.py) -eq 0) { $ready = $true; break }
   Start-Sleep 2
  }
  if (!$ready) { throw 'No se pudo preparar la copia de seguridad de la versión anterior.' }
 }
 if ((Invoke-DockerVisible exec $container python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py backup) -ne 0) { throw 'Actualización detenida. Espera a que terminen las tareas IA y vuelve a iniciar.' }
}
$settings = @(if (Test-Path .env) { Get-Content .env | Where-Object { $_ -notmatch '^CUADERNO_IMAGE=' } })
$settings += "CUADERNO_IMAGE=cuaderno-aules:$version"
[System.IO.File]::WriteAllLines((Join-Path $PSScriptRoot '.env'), $settings, (New-Object System.Text.UTF8Encoding($false)))
$env:CUADERNO_IMAGE = "cuaderno-aules:$version"
if ($installed -and $installed -eq $version) { $started = Invoke-DockerQuiet start $container } else { $started = Invoke-DockerVisible compose up -d }
if ($started -ne 0) { throw 'No se ha podido iniciar el cuaderno. Comprueba que ninguna otra aplicación usa el puerto 3000.' }
for ($i = 0; $i -lt 90; $i++) {
 if ((Invoke-DockerQuiet compose exec -T cuaderno python /opt/cuaderno/healthcheck.py) -eq 0) {
  Write-Host "Cuaderno $version preparado. Abriendo el navegador…"
  Start-Process 'http://localhost:3000'
  exit 0
 }
 Start-Sleep 2
}
throw 'No se ha confirmado el arranque. Ejecuta «docker compose logs» en esta carpeta y comparte el mensaje sin credenciales.'
