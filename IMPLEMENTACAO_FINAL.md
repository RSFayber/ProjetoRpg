# Implementacao Final — RPG Sheet Builder

## Plataformas

- **Windows** — desktop, SQLite via `sqflite_common_ffi`
- **Android** — mobile, SQLite nativo (`sqflite`)
- Demais plataformas exibem tela de aviso e nao inicializam o app

## Status do projeto

| Modulo | Status |
|--------|--------|
| Windows + Android | Concluido |
| Ficha visual + PDF oficial | Concluido |
| Persistencia SQLite | Concluido |
| 9 racas / 12 classes / 12 antecedentes | Concluido |
| Exportacao/importacao arquivo .rpgsheet | Concluido (gravacao corrigida no Windows) |
| Limpeza de codigo legado | Concluido |
| Relatorio de desenvolvimento | `RELATORIO_DESENVOLVIMENTO.md` |

## Como executar

```powershell
cd D:\rpg_sheet_builder
flutter pub get
flutter run -d windows
flutter run -d android
```

## Build

```powershell
.\scripts\build_release.ps1
```

## Validacao

```powershell
flutter analyze
flutter test
flutter build windows
flutter build apk
```

## Documentacao

- **`RELATORIO_DESENVOLVIMENTO.md`** — bibliotecas, APIs, arquitetura e funcao de cada classe
