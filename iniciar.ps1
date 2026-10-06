$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw 'Instala y abre Docker Desktop antes de continuar.' }
docker image inspect cuaderno-aules:0.2.2 *> $null
if ($LASTEXITCODE -ne 0) {
 $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq 'Arm64') { 'arm64' } else { 'amd64' }
 $asset = "cuaderno-aules-web-0.2.2-$arch.tar.gz"
 $base = 'https://github.com/sotoliborio/aules-cuaderno-releases/releases/download/v0.2.2'
 $cache = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
 New-Item -ItemType Directory $cache | Out-Null
 try {
  Invoke-WebRequest "$base/$asset" -OutFile (Join-Path $cache $asset) -UseBasicParsing
  Invoke-WebRequest "$base/SHA256SUMS.txt" -OutFile (Join-Path $cache 'SHA256SUMS.txt') -UseBasicParsing
  $expected = ((Get-Content (Join-Path $cache 'SHA256SUMS.txt') | Where-Object { $_.EndsWith("  $asset") }) -split ' ')[0]
  if (!$expected -or (Get-FileHash (Join-Path $cache $asset) -Algorithm SHA256).Hash.ToLower() -ne $expected) { throw 'La descarga no supera la comprobación SHA256.' }
  docker load -i (Join-Path $cache $asset)
  if ($LASTEXITCODE -ne 0) { throw 'No se ha podido cargar la imagen.' }
 } finally { Remove-Item $cache -Recurse -Force }
}
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw 'No se ha podido iniciar el cuaderno.' }
for ($i=0; $i -lt 90; $i++) {
 docker compose exec -T cuaderno python /opt/cuaderno/healthcheck.py *> $null
 if ($LASTEXITCODE -eq 0) { Write-Host 'Abre http://localhost:3000'; exit 0 }
 Start-Sleep 2
}
throw 'No se ha confirmado el arranque. Revisa docker compose logs.'
