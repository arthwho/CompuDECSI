# Suíte de Testes — CompuDECSI

Este diretório contém testes de unidade e de widgets do app Flutter CompuDECSI.

## Estrutura dos testes

```
test/
├── README.md                  # Este arquivo
├── widget_test.dart           # Testes básicos do app (MyApp/MaterialApp)
├── services/
│   └── shared_pref_test.dart  # Testes do helper de SharedPreferences
├── utils/
│   ├── variables_test.dart    # Testes de constantes e estilos
│   └── widgets_test.dart      # Testes de widgets utilitários
└── pages/
    ├── home_test.dart         # Testes da tela Home (widget)
    └── onboarding_test.dart   # Testes da tela Onboarding (widget)
```

## Como executar

- Executar todos os testes
```bash
flutter test
```

- Executar um arquivo específico
```bash
flutter test test/services/shared_pref_test.dart
```

- Executar com cobertura
```bash
flutter test --coverage
```

- Executar com saída verbosa
```bash
flutter test --verbose
```

## Notas importantes (alinhadas à abordagem oficial do Flutter)

- Inicialização do binding (necessário para testes que usam serviços de plataforma, como SharedPreferences):
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ... seus testes
}
```

- Mock de SharedPreferences (antes dos testes que leem/escrevem prefs):
```dart
import 'package:shared_preferences/shared_preferences.dart';

setUp(() async {
  SharedPreferences.setMockInitialValues({});
});
```

- Animações infinitas em testes de widget: evite `pumpAndSettle()` quando houver animações contínuas (por exemplo, `AnimationController.repeat`). Prefira `await tester.pump(const Duration(milliseconds: 100));` para avançar alguns frames.

- Assets em testes: utilize apenas assets presentes em `pubspec.yaml` (ex.: `assets/compudecsi_onboarding.png`, `assets/qanda_onboarding.svg`, `assets/Onboarding.gif`). Referências a `assets/test.png/.gif/.svg` irão falhar.

- Dependências de Firebase em testes de widget: como as telas podem chamar Firestore/Authentication no `initState`, é necessário mockar Firebase (por exemplo com libs de mock) ou isolar a lógica via injeção de dependência. Sem mocks, esses testes podem falhar em ambientes de CI. Alternativas:
  - Introduzir fakes/mocks de Firebase (ex.: `fake_cloud_firestore`) e injetar nos widgets.
  - Desacoplar a busca de dados do `initState` e testar a UI com dados estáticos.
  - Marcar temporariamente como `skip` os testes que dependem de Firebase até configurar os mocks.

## Categorias de testes

- Services (`test/services/`)
  - `shared_pref_test.dart`: salva/recupera dados do usuário em `SharedPreferences` usando mocks.

- Utils (`test/utils/`)
  - `variables_test.dart`: valida constantes (cores, espaçamentos, estilos).
  - `widgets_test.dart`: valida botões utilitários, `GoogleSignInButton` e `CodeInputDialog`.

- Pages (`test/pages/`)
  - `home_test.dart`: valida elementos principais da Home. Observação: evite dependência direta de Firebase sem mocks.
  - `onboarding_test.dart`: valida conteúdo, indicadores, swipe e componentes. Use `pump` com duração finita em vez de `pumpAndSettle` devido a animações contínuas.

- App principal (`test/widget_test.dart`)
  - Inicialização básica do app e configurações do `MaterialApp`.

## Boas práticas ao escrever novos testes

1) Use o padrão Arrange–Act–Assert
2) Nomeie os testes de forma descritiva
3) Agrupe testes relacionados com `group()`
4) Priorize cobertura de lógica de negócio
5) Mocke dependências externas (Firebase, rede, etc.)

Exemplo:
```dart
group('MinhaFuncionalidade', () {
  test('deve retornar valor esperado quando X', () async {
    // Arrange
    final dado = 'teste';

    // Act
    final resultado = await minhaFuncao(dado);

    // Assert
    expect(resultado, equals(valorEsperado));
  });
});
```

## Dicas de CI

Configurar mocks de plataforma (SharedPreferences) e Firebase antes de rodar a suíte em CI. Evitar dependências em animações infinitas (use `pump` com duração finita).

## Metas de cobertura (sugeridas)

- Services: 90%+
- Utils: 95%+
- Pages: 80%+
- Geral: 85%+

## Solução de problemas comuns

1) Falhas com Firebase: mocke os serviços ou isole a UI da camada de dados.
2) Falhas com assets: garanta que os arquivos foram declarados em `pubspec.yaml` e use apenas os existentes.
3) `Binding has not yet been initialized`: chame `TestWidgetsFlutterBinding.ensureInitialized()` no `main()` do arquivo de testes e/ou `SharedPreferences.setMockInitialValues({})` no `setUp`.
4) `pumpAndSettle timed out`: troque por `tester.pump(const Duration(...))` quando houver animações contínuas.