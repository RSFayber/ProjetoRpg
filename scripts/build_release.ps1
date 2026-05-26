$ErrorActionPreference = 'Stop'

Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host 'Analisando...'
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'Testes...'
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'Build Windows Release...'
flutter build windows --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$exe = 'build\windows\x64\runner\Release\rpg_sheet_builder.exe'
Write-Host "Executavel: $((Resolve-Path $exe).Path)"
