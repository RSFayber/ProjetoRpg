# Relatório de Desenvolvimento — RPG Sheet Builder

Aplicativo Flutter para criação, edição e exportação de fichas de personagem D&D 5e (Player's Handbook), com layout visual inspirado na ficha oficial, persistência local e geração de PDF.

**Plataformas suportadas:** Windows (desktop) e Android (mobile).

---

## 1. Bibliotecas e APIs externas

| Biblioteca | Versão | Função no projeto |
|------------|--------|-------------------|
| **Flutter SDK** | 3.x | Framework UI multiplataforma; widgets Material, roteamento e ciclo de vida do app. |
| **flutter_riverpod** | ^3.3.1 | Gerenciamento de estado reativo (`Provider`, `NotifierProvider`, `AsyncValue`) para catálogo, personagem e estatísticas derivadas. |
| **go_router** | ^17.2.3 | Navegação declarativa (`MaterialApp.router`) entre telas do construtor de ficha. |
| **sqflite** | ^2.4.2+1 | Banco SQLite nativo no Android para persistir personagens. |
| **sqflite_common_ffi** | ^2.4.0+3 | Implementação FFI do SQLite no Windows (desktop), permitindo o mesmo código de repositório em ambas as plataformas. |
| **path** | ^1.9.1 | Resolução de caminhos do arquivo de banco (`join`, `documents` directory). |
| **pdf** | ^3.12.0 | Construção programática do PDF da ficha oficial (layout, tabelas, texto). |
| **printing** | ^5.14.3 | Visualização e impressão do PDF gerado (`Printing.layoutPdf`). |
| **file_picker** | ^8.1.7 | Diálogo nativo para escolher arquivo na importação e definir destino na exportação (`.rpgsheet`). |
| **dart:io** | SDK | Leitura/gravação explícita de bytes no disco após o diálogo de exportação (correção do bug no Windows). |
| **cupertino_icons** | ^1.0.8 | Ícones opcionais da biblioteca Cupertino. |

### APIs Dart/Flutter utilizadas

- **`WidgetsFlutterBinding.ensureInitialized()`** — inicialização antes de SQLite e assets.
- **`Timer` / `Future`** — autosave com debounce de 2 segundos no `CharacterController`.
- **`rootBundle.loadString`** — leitura de JSON em `assets/data/` e fontes em `assets/fonts/`.
- **`File.writeAsBytes` / `File.readAsBytes`** — I/O de arquivos `.rpgsheet`.
- **`Platform.isWindows` / `Platform.isAndroid`** — detecção de plataforma em `app_platform.dart`.

---

## 2. Arquitetura em camadas

```
lib/
├── core/           # Infraestrutura transversal (DB, tema, rotas, erros, constantes)
├── domain/         # Entidades, regras de jogo, casos de uso, contratos de repositório
├── data/           # Implementações concretas (SQLite, assets JSON, PDF)
└── presentation/   # UI, providers Riverpod, serviços de arquivo
```

Fluxo principal: **UI → Controller (Riverpod) → Use Case → Repository → SQLite / Assets**.

---

## 3. Função de cada classe e módulo

### 3.1 Entrada e infraestrutura (`core/`)

| Classe / arquivo | Responsabilidade |
|------------------|------------------|
| **`main.dart` → `RpgSheetBuilderApp`** | Ponto de entrada; inicializa SQLite nas plataformas suportadas e monta `MaterialApp.router` ou tela de plataforma não suportada. |
| **`app_platform.dart`** | Define `isSupportedPlatform`, `isDesktopPlatform` (Windows/Android apenas). |
| **`database_bootstrap.dart`** | Configura factory FFI no Windows e abre o banco via `LocalDatabase`. |
| **`local_database.dart`** | Cria/abre SQLite, schema da tabela `characters` (id, name, payload JSON, updated_at). |
| **`app_router.dart`** | Rotas `go_router` para a tela do construtor de ficha. |
| **`app_theme.dart`** | Tema Material global do aplicativo. |
| **`sheet_theme.dart`** | Cores e estilos da ficha (pergaminho, marrom, bordas). |
| **`app_exception.dart`** | Exceção de domínio com mensagem amigável para export/import e erros de negócio. |
| **`attribute_keys.dart`** | Lista fixa dos seis atributos D&D (FOR, DES, CON, INT, SAB, CAR). |
| **`dnd_skills.dart`** | Catálogo de perícias com atributo associado e rótulos em português. |
| **`dnd_alignments.dart`** | Lista de alinhamentos para dropdown na ficha. |

### 3.2 Domínio — entidades (`domain/entities/`)

| Classe | Responsabilidade |
|--------|------------------|
| **`Character`** | Agregado principal: identidade (id, nome), raça/classe/antecedente, nível, atributos base e `CharacterSheetDetails`. Serialização JSON para SQLite e exportação. |
| **`CharacterSheetDetails`** | Campos editáveis da ficha: PV, CA, equipamento, ataques, moedas, roleplay, overrides de perícia, escolhas de equipamento PHB, itens de antecedente selecionados. |
| **`AttributeSet`** | Valores numéricos dos seis atributos; mapa JSON e factory `standard()` (10 em todos). |
| **`CharacterStats`** | Estatísticas calculadas (atributos finais, modificadores, PV, CA, proficiências, idiomas, slots de magia, deslocamento). |
| **`Race`** | Raça PHB: bônus raciais, proficiências, idiomas, deslocamento. |
| **`CharacterClass`** | Classe PHB: dado de vida, saving throws, proficiências de classe. |
| **`Background`** | Antecedente PHB: perícias e equipamento inicial. |
| **`GameCatalog`** | Agregação de listas de raças, classes e antecedentes com busca por `id`. |
| **`ClassBuildData`** | Dados de construção por classe (dicas de atributos, escolhas de equipamento, habilidades por nível) carregados de `class_build.json`. |
| **`CharacterExportDocument`** | Metadados do formato portátil `.rpgsheet` (`format`, `version`, `character`). |

### 3.3 Domínio — regras (`domain/rules/`)

| Arquivo / funções | Responsabilidade |
|-------------------|------------------|
| **`attribute_modifier_rule.dart`** | Fórmula D&D: modificador = floor((valor − 10) / 2). |
| **`racial_bonus_rule.dart`** | Aplica bônus raciais sobre `AttributeSet`. |
| **`hit_points_rule.dart`** | PV de 1º nível = dado de vida máximo + modificador de CON. |
| **`armor_class_rule.dart`** | CA base 10 + modificador de DES (sem armadura equipada). |
| **`proficiency_rule.dart`** | Bônus de proficiência por nível; fusão de listas de proficiências. |
| **`spell_slot_rule.dart`** | Slots de magia de 1º nível para classes conjuradoras (nível 1). |
| **`sheet_proficiency_rule.dart`** | Perícias/saving throws na ficha: overrides manuais, bônus, percepção passiva. |
| **`class_build_rule.dart`** | Resolve equipamento inicial a partir de escolhas PHB; defaults de seleção. |

### 3.4 Domínio — casos de uso e serviços

| Classe | Responsabilidade |
|--------|------------------|
| **`CalculateCharacterStatsUseCase`** | Orquestra regras e catálogo para produzir `CharacterStats` a partir de um `Character`. |
| **`SaveCharacterUseCase`** | Persiste personagem via `CharacterRepository`. |
| **`ExportCharacterFileUseCase`** | Serializa personagem para bytes UTF-8 do formato `.rpgsheet`. |
| **`ImportCharacterFileUseCase`** | Desserializa arquivo importado e remove `id` para nova gravação local. |
| **`CharacterExportCodec`** | Encode/decode JSON com validação de formato e versão. |

### 3.5 Domínio — contratos de repositório

| Interface | Responsabilidade |
|-----------|------------------|
| **`CharacterRepository`** | Contrato: listar, buscar por id, salvar, excluir personagens. |
| **`GameCatalogRepository`** | Contrato: carregar `GameCatalog` completo. |

### 3.6 Camada de dados (`data/`)

| Classe | Responsabilidade |
|--------|------------------|
| **`AssetJsonDatasource`** | Carrega listas JSON de `assets/data/` via `rootBundle`. |
| **`AssetGameCatalogRepository`** | Implementa `GameCatalogRepository` a partir de races/classes/backgrounds JSON. |
| **`SqliteCharacterRepository`** | CRUD de personagens; payload JSON na coluna `payload`. |
| **`CharacterPdfService`** | Orquestra geração do PDF da ficha. |
| **`OfficialCharacterSheetPdfBuilder`** | Layout PDF espelhando a ficha visual (3 colunas, perícias, ataques). |
| **`PdfFontLoader`** | Carrega fontes Arial dos assets para o pacote `pdf`. |

### 3.7 Apresentação — providers (`presentation/providers/`)

| Provider / classe | Responsabilidade |
|-------------------|------------------|
| **`gameCatalogProvider`** | `FutureProvider` do catálogo PHB. |
| **`classBuildCatalogProvider`** | `FutureProvider` do mapa classe → `ClassBuildData`. |
| **`characterControllerProvider`** | `CharacterController`: estado do personagem, autosave, seleções PHB, patches na ficha. |
| **`characterStatsProvider`** | Deriva `CharacterStats` quando personagem ou catálogo mudam. |
| **`characterRepositoryProvider`** | Injeta `SqliteCharacterRepository`. |
| **`persistence_providers.dart`** | Providers de banco e repositório. |

### 3.8 Apresentação — telas e widgets

| Classe | Responsabilidade |
|--------|------------------|
| **`CharacterBuilderScreen`** | Tela principal: barra de ações, painel de construção PHB e ficha oficial. |
| **`UnsupportedPlatformScreen`** | Aviso quando a plataforma não é Windows/Android. |
| **`CharacterActionsBar`** | Botões: salvar, PDF, exportar/importar `.rpgsheet`, novo personagem. |
| **`OfficialCharacterSheet`** | Ficha visual editável em 3 colunas (atributos, combate, roleplay). |
| **`SheetControlledTextField`** | Campo de texto com `TextEditingController` estável (evita perda de foco). |
| **`SheetPrimitives`** | Caixas, rótulos e componentes visuais reutilizáveis da ficha. |
| **`ClassBuildPanel`** | Seletores de raça/classe/antecedente/nível, dicas de atributos, equipamento PHB. |
| **`ClassAbilitiesDialog`** | Diálogo consultável de habilidades de classe por nível. |
| **`CharacterFilePickerService`** | Pick de importação e gravação confirmada na exportação (bytes + verificação de arquivo). |

---

## 4. Assets

| Arquivo | Conteúdo |
|---------|----------|
| `assets/data/races.json` | 9 raças PHB |
| `assets/data/classes.json` | 12 classes PHB |
| `assets/data/backgrounds.json` | 12 antecedentes PHB |
| `assets/data/class_build.json` | Equipamento escolhível e habilidades por classe/nível |
| `assets/fonts/` | Arial Regular/Bold/Italic para PDF |

---

## 5. Formato de exportação `.rpgsheet`

JSON UTF-8 com estrutura:

```json
{
  "format": "rpg_sheet_builder",
  "version": 1,
  "character": { "...": "..." }
}
```

Na importação, o `id` é descartado para que o SQLite gere um novo registro local.

---

## 6. Correções e limpeza desta entrega

### Bug corrigido: exportação sem gravação

No Windows, `FilePicker.platform.saveFile(bytes: ...)` pode retornar o caminho escolhido **sem** escrever os bytes no disco. A correção em `CharacterFilePickerService`:

1. Abre o diálogo `saveFile` apenas para obter o caminho.
2. Grava com `File(path).writeAsBytes(bytes, flush: true)`.
3. Garante extensão `.rpgsheet`.
4. Valida existência e tamanho do arquivo antes de exibir sucesso.

### Código removido (não utilizado)

- Widgets legados: `attribute_editor.dart`, `results_panel.dart`
- Use cases substituídos pelas regras/controller: `create_character`, `apply_race/class/background`, `calculate_hitpoints`, `calculate_attribute_modifier`, `load_characters`
- Entidade `Proficiency` e `proficiencies.json` (proficiências já vêm em raça/classe como strings)
- Assets não referenciados: `items.json`, `spells.json`
- Funções mortas em regras: `displayProficiencies`, `displayLanguages`, `formatClassAbilitiesSummary`

---

## 7. Testes automatizados

| Arquivo | Cobertura |
|---------|-----------|
| `rules_test.dart` | Modificadores e estatísticas D&D |
| `class_build_test.dart` | Equipamento PHB e habilidades por nível |
| `character_export_test.dart` | Roundtrip export/import e validação de formato |
| `character_pdf_service_test.dart` | Geração de PDF válido (`%PDF`) |
| `character_file_picker_service_test.dart` | Gravação de bytes em disco |
| `widget_test.dart` | Renderização da ficha oficial |

---

## 8. Comandos úteis

```powershell
cd D:\rpg_sheet_builder
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter run -d android
```

---

*Documento gerado em maio/2026 — RPG Sheet Builder v1.0.0*
