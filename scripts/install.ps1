$ErrorActionPreference = 'Stop'

Write-Host 'Instalando dependencias do RPG Sheet Builder...'
Set-Location (Split-Path $PSScriptRoot -Parent)

flutter pub get
flutter doctor

Write-Host 'Concluido.'
