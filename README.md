# compudecsi

Discentes: Arthur Silva Ferreira Coelho, Mateus Diniz Gottardi

[Link do protótipo FIGMA](https://www.figma.com/design/VrL7db0UBdOPjbiu1UHzX2/CompuDECSI?node-id=0-1&t=F3a37Z8v0MHwGlHG-1)

## Como executar (Android/Emulador)

### Pré‑requisitos
- **Flutter SDK 3.32.4+** instalado e configurado (`flutter doctor` deve estar sem erros)
- **Android Studio** (SDK, AVD/Emulador e Platform Tools)
- **Java 11** (o projeto usa `JavaVersion.VERSION_11`)
- **Android SDK API 33+** (recomendado para compatibilidade)

### Passo a passo
1) **Clone e abra o projeto** nesta pasta (`CompuDECSI/`) e instale as dependências:
```bash
flutter pub get
```

2) **Crie e inicie um emulador Android** (via Android Studio):
- Abra o Device Manager → Create Virtual Device → escolha um Pixel/qualquer, API 33+ → Finish
- Inicie o emulador criado

3) **Rode o app no emulador**:
```bash
flutter devices
flutter run
```
Se houver múltiplos dispositivos, selecione o emulador na lista ou rode: `flutter run -d <id-do-emulador>`.

### Observação importante sobre autenticação Google/Firebase
- O login com Google depende do arquivo sensível `android/app/google-services.json` (e, no iOS, `ios/Runner/GoogleService-Info.plist`). Esses arquivos não ficam no repositório.
- Sem esse arquivo, o app pode abrir, mas recursos do Firebase (como autenticação) podem falhar. Para habilitar login:
  - Crie um projeto no Firebase e adicione um app Android com o `applicationId` do projeto: `com.example.compudecsi` (veja em `android/app/build.gradle.kts`).
  - Baixe o `google-services.json` e coloque em `android/app/`.
  - **IMPORTANTE**: Para Google Sign-In funcionar, você DEVE adicionar o SHA-1 do app no Firebase:
    - Vá para Firebase Console → Project Settings → Your apps → Android
    - Clique em "Add fingerprint" e adicione o SHA-1 do seu projeto

#### Como obter o SHA-1 do projeto:

**Opção 1 - Via Android Studio:**
1. Abra o projeto no Android Studio
2. Vá para View → Tool Windows → Gradle
3. Expanda: YourApp → Tasks → android → signingReport
4. Clique duas vezes em "signingReport"
5. Copie o valor SHA-1 do debug variant

**Opção 2 - Via linha de comando:**
```bash
# No diretório do projeto (CompuDECSI/)
cd android
./gradlew signingReport
```
Procure pela linha que contém "SHA1:" no debug variant.

**Opção 3 - Via keytool (se você tiver o keystore):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Após obter o SHA-1, adicione-o no Firebase Console e ative o provedor Google em Authentication → Sign-in method.

Se você só quer visualizar as telas sem autenticar, basta não pressionar o botão "Continuar com o Google" na tela de onboarding. Caso encontre erro de inicialização do Firebase, confira a seção acima e o passo do arquivo `google-services.json`.

### Como mudar a tela inicial para visualização
A tela inicial está definida em `lib/main.dart` no parâmetro `home` do `MaterialApp`. Altere para a tela que deseja visualizar:
```dart
// Em lib/main.dart
// importações já existentes...

return MaterialApp(
  title: 'CompuDECSI',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(/* ... */),
  // Troque aqui:
  home: Onboarding(),     // padrão atual
  // Exemplos:
  // home: BottomNav(),
  // home: Home(),
  // home: SignUp(),
);
```
Telas disponíveis (todas com construtor sem parâmetros): `Onboarding` (`lib/pages/onboarding_page.dart`), `BottomNav` (`lib/pages/bottom_nav.dart`), `Home` (`lib/pages/home.dart`), `SignUp` (`lib/pages/signup.dart`). Salve o arquivo e use Hot Reload/Restart para aplicar.

### Troubleshooting

#### Erros comuns e soluções:

1. **"Gradle build failed"**
   - Verifique se o Java 11 está instalado: `java -version`
   - Limpe o cache: `flutter clean && flutter pub get`

2. **"Firebase not initialized"**
   - Adicione o arquivo `google-services.json` em `android/app/`
   - Verifique se o `applicationId` no Firebase corresponde ao do projeto

3. **"Multiple devices connected"**
   - Use `flutter devices` para listar dispositivos
   - Especifique o dispositivo: `flutter run -d <device-id>`

4. **"Dependencies outdated"**
   - Execute `flutter pub outdated` para ver atualizações disponíveis
   - Atualize com cuidado: `flutter pub upgrade`

---

**Importante**: Nunca faça commit dos arquivos `google-services.json` ou `GoogleService-Info.plist` no controle de versão, pois eles contêm chaves de API sensíveis. Esses arquivos já estão adicionados ao `.gitignore`.

### Índice do Firestore (filtro por categoria)
- Para o filtro por categoria funcionar bem, crie um índice simples no Firestore para a coleção `events` no campo `category`.
- Acesse Firebase Console → Firestore Database → Indexes → Create Index → Single field → Collection `events` → Field `category` (Ascending) → Save.
- Se o Firestore sugerir um link de criação de índice ao rodar a consulta pela primeira vez, basta clicar no link sugerido.

## Estrutura do Projeto

```
lib/
├── admin/           # Funcionalidades específicas do administrador
├── models/          # Modelos de dados (User, Question, Feedback)
├── pages/           # Telas principais do app
├── services/        # Lógica de negócio e chamadas de API
├── utils/           # Funções utilitárias e helpers
├── widgets/         # Componentes de UI reutilizáveis
└── main.dart        # Ponto de entrada do app
```

## Notas de Segurança

- Arquivos de configuração do Firebase contendo chaves de API foram removidos do histórico do Git
- Arquivos de template são fornecidos para referência
- Sempre use variáveis de ambiente ou armazenamento seguro para dados sensíveis em produção

## Documentação Adicional

Para informações mais detalhadas sobre configurações específicas, consulte os guias na pasta `docs/`:

- **[Guia de Configuração de Notificações](docs/GUIA_CONFIGURACAO_NOTIFICACOES.md)** - Como configurar notificações push
- **[Guia de Configuração do ProGuard](docs/GUIA_CONFIGURACAO_PROGUARD.md)** - Configuração de ofuscação de código
- **[Guia de Release Automatizado](docs/GUIA_RELEASE_AUTOMATIZADO.md)** - Processo de release com GitHub Actions
- **[Guia de Assinatura Android](docs/GUIA_ASSINATURA_ANDROID.md)** - Configuração de chaves de assinatura para produção
