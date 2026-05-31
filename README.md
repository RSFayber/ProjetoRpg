# Construtor de Ficha RPG (D&D 5e)

Aplicativo Flutter academico para criacao assistida de fichas de D&D 5e.

## Plataformas suportadas

| Plataforma | Uso |
|------------|-----|
| **Windows** | Desktop (desenvolvimento e entrega `.exe`) |
| **Android** | Mobile (APK) |

Web, Linux, macOS e iOS **nao** fazem parte deste projeto.

## Funcionalidades

- Ficha visual estilo Livro do Jogador
- Calculo em tempo real (atributos, PV, CA, pericias)
- Salvar/abrir fichas (SQLite)
- Exportar/importar arquivo `.rpgsheet` (troca entre maquinas)
- Autosave e exportacao PDF

## Inicio rapido (Windows)

```powershell
cd D:\rpg_sheet_builder
.\scripts\install.ps1
flutter run -d windows
```

## Inicio rapido (Android)

```powershell
flutter devices
flutter run -d android
```

## Build de entrega

```powershell
.\scripts\build_release.ps1
```

Saidas:

- `build\windows\x64\runner\Release\rpg_sheet_builder.exe`
- `build\app\outputs\flutter-apk\app-release.apk`

## Testes

```powershell
flutter test
```

## Arquitetura

```text
presentation/ -> domain/ (regras) -> presentation/
                      \-> data/ (SQLite, assets, PDF)
```
