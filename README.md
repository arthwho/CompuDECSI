# compudecsi

Discentes: Arthur Silva Ferreira Coelho, Mateus Diniz Gottardi

[Link do protótipo FIGMA](https://www.figma.com/design/VrL7db0UBdOPjbiu1UHzX2/CompuDECSI?node-id=0-1&t=F3a37Z8v0MHwGlHG-1)

## Como executar (Android/Emulador)

### Pré‑requisitos
- Flutter SDK instalado e configurado (`flutter doctor` deve estar sem erros)
- Android Studio (SDK, AVD/Emulador e Platform Tools)
- Java 11 (o projeto usa `JavaVersion.VERSION_11`)

### Passo a passo
1) Abra o projeto nesta pasta (`CompuDECSI/`) e instale as dependências:
```bash
flutter pub get
```

2) Crie e inicie um emulador Android (via Android Studio):
- Abra o Device Manager → Create Virtual Device → escolha um Pixel/qualquer, API 33+ → Finish
- Inicie o emulador criado

3) Rode o app no emulador:
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
  - Opcional (para Google Sign-In): cadastre SHA-1 do app no Firebase (Project Settings → Your apps → Android) e ative o provedor Google em Authentication.

Se você só quer visualizar as telas sem autenticar, basta não pressionar o botão “Continuar com o Google” na tela de onboarding. Caso encontre erro de inicialização do Firebase, confira a seção acima e o passo do arquivo `google-services.json`.

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

---

## Firebase Configuration

This project uses Firebase for backend services. To set up Firebase:

1. Add `android/app/google-services.json` downloaded from your Firebase project
2. Ensure the Android app is registered with the same `applicationId` (`com.example.compudecsi` by default)
3. For iOS, add `ios/Runner/GoogleService-Info.plist`

**Important**: Never commit the actual `google-services.json` or `GoogleService-Info.plist` files to version control as they contain sensitive API keys. These files are already added to `.gitignore`.

## Security Notes

- Firebase configuration files containing API keys have been removed from Git history
- Template files are provided for reference
- Always use environment variables or secure storage for sensitive data in production
