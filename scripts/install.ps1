$ErrorActionPreference = 'Stop'

Write-Host 'Instalando dependencias do RPG Sheet Builder (Windows + Android)...'
Set-Location (Split-Path $PSScriptRoot -Parent)

flutter pub get
flutter doctor -v

Write-Host ''
Write-Host 'Plataformas suportadas: windows, android'
Write-Host 'Executar desktop: flutter run -d windows'
Write-Host 'Executar mobile:  flutter run -d android (emulador ou dispositivo USB)'
Write-Host 'Concluido.'
