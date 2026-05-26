# Implementacao Final — RPG Sheet Builder

## Status do projeto

| Modulo | Status |
|--------|--------|
| Arquitetura 4 camadas | Concluido |
| Motor de regras V1 | Concluido |
| Tela reativa | Concluido |
| Ficha visual estilo Livro do Jogador | Concluido |
| Campos editaveis + persistencia SQLite | Concluido |
| 9 racas / 12 classes / 12 antecedentes (PHB base) | Concluido |
| Textos em portugues | Concluido |
| SQLite + salvar/abrir ficha | Concluido |
| Autosave (2s debounce) | Concluido |
| Exportacao PDF (layout ficha oficial A4 paisagem) | Concluido |
| Slots de magia nv.1 (basico) | Concluido |
| Assets spells/items (base) | Concluido |
| Login / conta | Pendente |
| Importacao PDF | Pendente |
| Inventario na UI | Pendente |
| Combate | Pendente |
| Subclasses / magias completas / talentos | Pendente (dados) |

## Como executar

```powershell
cd D:\rpg_sheet_builder
flutter pub get
flutter run -d windows
```

Build de entrega:

```powershell
.\scripts\build_release.ps1
```

## Estrutura gerada

```text
lib/
  core/          database, theme, routing, errors
  domain/        entities, rules, usecases, repositories
  data/          datasources, repositories, services
  presentation/  screens, widgets, providers
assets/data/     races, classes, backgrounds, proficiencies, spells, items
scripts/         install e build
test/            regras e widget
```

## O que ainda precisa de voce

1. **Conteudo completo do Livro do Jogador**  
   Expandir `assets/data/*.json` com todas as racas, classes, magias e itens.  
   Caminho de referencia informado:  
   `C:\Users\ryans\Downloads\PDF's\Livro do jogador D&D.pdf`  
   Para extrair automaticamente, confirme permissao de leitura desse arquivo.

2. **Login local**  
   Definir se sera PIN simples, usuario/senha local ou sem login.

3. **Importacao de PDF**  
   Exige formato padrao do PDF exportado pelo proprio app (metadados JSON embutidos).

4. **Publicacao GitHub**  
   Criar repositorio remoto e executar `git push` (permissao de rede + credenciais).

## Comandos de validacao

```powershell
flutter analyze
flutter test
flutter build windows
```

## Entregaveis ja gerados

- App executavel: `build\windows\x64\runner\Release\rpg_sheet_builder.exe`
- PDF codigo (se existir): `entrega_codigo_rpg_sheet_builder_v1.pdf`
- Documentacao V1: `d:\documentacao_v_1_rpg_sheet_builder.md`
