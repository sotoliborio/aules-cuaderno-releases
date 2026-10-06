$ErrorActionPreference='Stop'
Set-Location $PSScriptRoot
docker compose exec -T cuaderno python /opt/cuaderno/outputs/aules-evaluacion/web_maintenance.py backup
if ($LASTEXITCODE -ne 0) { throw 'Actualización detenida. Espera a que terminen las tareas activas.' }
& (Join-Path $PSScriptRoot 'iniciar.ps1')
