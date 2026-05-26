# Construtor de Ficha RPG (D&D 5e)

Aplicativo Flutter academico para criacao assistida de fichas de D&D 5e, com motor de regras separado da interface.

## Funcionalidades

- Calculo em tempo real de atributos, modificadores, PV, CA e proficiencias
- Raças, classes e antecedentes iniciais via JSON local
- Salvar e abrir fichas (SQLite)
- Autosave local
- Exportacao de ficha em PDF
- Android e Windows (desktop)

## Stack

- Flutter + Riverpod + GoRouter
- Clean Architecture (`presentation`, `domain`, `data`, `core`)
- SQLite (`sqflite` / `sqflite_common_ffi` no desktop)
- PDF (`pdf` + `printing`)

## Inicio rapido

```powershell
cd D:\rpg_sheet_builder
.\scripts\install.ps1
flutter run -d windows
```

## Build de entrega

```powershell
.\scripts\build_release.ps1
```

Executavel:

`build\windows\x64\runner\Release\rpg_sheet_builder.exe`

## Documentacao

- `IMPLEMENTACAO_FINAL.md` — status e pendencias
- `CHECKLIST_ENTREGA.md` — checklist de entrega
- `d:\documentacao_v_1_rpg_sheet_builder.md` — especificacao tecnica V1

## Arquitetura

```text
Usuario -> presentation/ -> domain/ (regras) -> presentation/ (resultado)
                \-> data/ (SQLite, assets, PDF)
```

A interface nao contem regras de D&D; o `domain/` e o motor de calculo.

## Testes

```powershell
flutter test
```

## Licenciamento de conteudo

Projeto academico e sem fins lucrativos. Conteudos de D&D devem seguir a edicao de referencia adotada pelo grupo e permanecer em arquivos estruturados (`assets/data/`), nao hardcoded na UI.
