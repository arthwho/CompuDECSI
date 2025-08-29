# Contributing to CompuDECSI

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
A tela inicial está definida em `lib/main.dart` através do `AuthWrapper`. O app agora usa um sistema de autenticação automática que:

1. **Verifica o estado de autenticação** do usuário
2. **Redireciona automaticamente** baseado no estado:
   - Se **autenticado**: vai para `BottomNav()` (app principal)
   - Se **não autenticado**: vai para `Onboarding()` (tela de boas-vindas)

Para testar diferentes telas durante o desenvolvimento, você pode modificar o `AuthWrapper` em `lib/main.dart`:

```dart
// Em lib/main.dart - AuthWrapper class
@override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      // Para desenvolvimento: force uma tela específica
      // return const Onboarding(); // Força tela de onboarding
      // return const BottomNav();  // Força app principal
      
      // Comportamento normal (descomente para produção):
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasData && snapshot.data != null) {
        return const BottomNav();
      }

      return const Onboarding();
    },
  );
}
```

**Telas disponíveis** (todas com construtor sem parâmetros):
- `Onboarding()` (`lib/pages/onboarding_page.dart`) - Tela de boas-vindas
- `BottomNav()` (`lib/pages/bottom_nav.dart`) - Navegação principal do app
- `Home()` (`lib/pages/home.dart`) - Tela inicial
- `SignUp()` (`lib/pages/signup.dart`) - Tela de cadastro

Salve o arquivo e use Hot Reload/Restart para aplicar as mudanças.

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

5. **"AuthWrapper not working"**
   - Verifique se o Firebase está inicializado corretamente
   - Confirme que o `google-services.json` está no local correto
   - Verifique os logs do console para erros de autenticação

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
└── main.dart        # Ponto de entrada do app (contém AuthWrapper)
```

## Como Contribuir

1. **Fork o repositório**
2. **Crie uma branch** para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit suas mudanças** (`git commit -m 'Add some AmazingFeature'`)
4. **Push para a branch** (`git push origin feature/AmazingFeature`)
5. **Abra um Pull Request**

## Reportando Bugs

Se você encontrar um bug, por favor:

1. Verifique se o bug já foi reportado nas [Issues](../../issues)
2. Crie uma nova issue com:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs. atual
   - Screenshots (se aplicável)
   - Informações do ambiente (Flutter version, device, etc.)

## Documentação Adicional

Para informações mais detalhadas sobre configurações específicas, consulte a [documentação completa](docs/README.md).