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
Write-Host "Windows: $((Resolve-Path $exe).Path)"

Write-Host 'Build Android APK Release...'
flutter build apk --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = 'build\app\outputs\flutter-apk\app-release.apk'
Write-Host "Android: $((Resolve-Path $apk).Path)"
