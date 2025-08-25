# Guia de Assinatura de App Android

Este guia explica como configurar chaves de assinatura adequadas para seu app Flutter para releases de produção.

## Por que as Chaves de Assinatura Importam

### Benefícios de Segurança:
- ✅ **Integridade do app** - Garante que o app não foi adulterado
- ✅ **Verificação de atualização** - Apenas atualizações assinadas podem ser instaladas
- ✅ **Requisito da loja** - Necessário para Google Play Store
- ✅ **Confiança do usuário** - Usuários sabem que o app é autêntico

### Tipos de Assinatura:

1. **Assinatura Debug** (Configuração atual)
   - Usada para desenvolvimento e testes
   - Gerada automaticamente pelo Android Studio
   - Não adequada para produção

2. **Assinatura Release** (O que vamos configurar)
   - Usada para releases de produção
   - Deve ser mantida segura e com backup
   - Necessária para distribuição na loja de apps

## Passo 1: Gerar Keystore de Release

### Usando Android Studio (Recomendado):

1. **Abra o Android Studio**
2. **Vá para**: Build → Generate Signed Bundle/APK
3. **Selecione**: APK
4. **Clique**: Create new keystore
5. **Preencha os detalhes**:
   ```
   Key store path: /caminho/para/seu/release-key.jks
   Password: [crie uma senha forte]
   Alias: [crie um alias, ex: "release-key"]
   Password: [crie uma senha forte para a chave]
   Validity: 25 anos (recomendado)
   Certificate: Preencha seus detalhes
   ```

### Usando Linha de Comando:

```bash
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release-key
```

## Passo 2: Configurar Assinatura no build.gradle.kts

### Criar arquivo keystore.properties:

Crie `android/keystore.properties`:
```properties
storePassword=sua_senha_keystore
keyPassword=sua_senha_chave
keyAlias=release-key
storeFile=../release-key.jks
```

### Atualizar build.gradle.kts:

```kotlin
android {
    // ... configuração existente ...
    
    signingConfigs {
        create("release") {
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }
            
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## Passo 3: Proteger Seu Keystore

### Estrutura de Arquivos:
```
seu-projeto/
├── android/
│   ├── keystore.properties    # Configuração do keystore
│   └── app/
│       └── build.gradle.kts   # Configuração de build
├── release-key.jks           # Seu arquivo keystore
└── .gitignore               # Adicione arquivos keystore aqui
```

### Atualizar .gitignore:
```gitignore
# Arquivos keystore
*.jks
*.keystore
android/keystore.properties
```

## Passo 4: Integração com GitHub Actions

### Para Releases Automatizados:

1. **Adicionar keystore como GitHub Secret**:
   - Vá para seu repositório GitHub
   - Settings → Secrets and variables → Actions
   - Adicione os seguintes secrets:
     - `KEYSTORE_FILE` (keystore codificado em base64)
     - `KEYSTORE_PASSWORD`
     - `KEY_ALIAS`
     - `KEY_PASSWORD`

2. **Atualizar workflow do GitHub Actions**:
   ```yaml
   - name: Setup signing
     run: |
       echo "${{ secrets.KEYSTORE_FILE }}" | base64 -d > android/app/release-key.jks
       echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/keystore.properties
       echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/keystore.properties
       echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/keystore.properties
       echo "storeFile=release-key.jks" >> android/keystore.properties
   ```

## Passo 5: Comandos de Build

### Build de Release Local:
```bash
flutter build apk --release
```

### GitHub Actions:
O workflow automatizado usará automaticamente o keystore de release.

## Passo 6: Obter SHA-1 de Release

### Do Keystore:
```bash
keytool -list -v -keystore release-key.jks -alias release-key
```

### Do APK:
```bash
keytool -printcert -jarfile app-release.apk
```

## Melhores Práticas de Segurança

### 1. Segurança do Keystore:
- 🔒 **Mantenha keystore seguro** - Armazene em local seguro
- 💾 **Backup do keystore** - Múltiplos backups seguros
- 🔑 **Senhas fortes** - Use senhas complexas
- 🚫 **Nunca faça commit** - Mantenha fora do controle de versão

### 2. Gerenciamento de Senhas:
- 🔐 **Use gerenciador de senhas** - Armazene senhas com segurança
- 📝 **Documente tudo** - Mantenha registros de todos os detalhes
- 🔄 **Rotação regular** - Considere rotacionar chaves periodicamente

### 3. Acesso da Equipe:
- 👥 **Acesso limitado** - Apenas membros confiáveis da equipe
- 📋 **Logs de acesso** - Rastreie quem tem acesso
- 🔐 **Compartilhamento seguro** - Use canais seguros para compartilhar

## Solução de Problemas

### Problemas Comuns:

1. **"Arquivo keystore não encontrado"**:
   - Verifique o caminho do arquivo em keystore.properties
   - Certifique-se de que o arquivo keystore existe

2. **"Formato de keystore inválido"**:
   - Regenerar keystore com formato adequado
   - Verificar integridade do arquivo keystore

3. **"Senha incorreta"**:
   - Verificar senhas em keystore.properties
   - Verificar erros de digitação ou problemas de codificação

### Comandos de Verificação:

```bash
# Verificar keystore
keytool -list -v -keystore release-key.jks

# Verificar assinatura do APK
jarsigner -verify -verbose -certs app-release.apk

# Obter SHA-1 do APK
keytool -printcert -jarfile app-release.apk
```

## Migração de Debug para Release

### Estado Atual:
- Usando keystore debug para releases
- Não adequado para produção

### Estado Alvo:
- Usando keystore release para todos os releases
- Assinatura adequada para distribuição na loja

### Passos de Migração:
1. Gerar keystore release
2. Configurar build.gradle.kts
3. Atualizar GitHub Actions
4. Testar com nova assinatura
5. Atualizar SHA-1 no Firebase

## Próximos Passos

1. **Gere seu keystore release**
2. **Configure build.gradle.kts** com assinatura
3. **Atualize workflow do GitHub Actions**
4. **Teste o processo** de assinatura
5. **Atualize Firebase** com novo SHA-1
6. **Faça deploy para produção** com assinatura adequada

## Notas Importantes

- ⚠️ **Nunca perca seu keystore** - Você não pode atualizar seu app sem ele
- 🔄 **Mantenha backups** - Múltiplos locais seguros
- 📱 **Teste exaustivamente** - Certifique-se de que a assinatura funciona corretamente
- 🔐 **Armazenamento seguro** - Use armazenamento criptografado para keystore

## Configuração para Firebase

### Atualizar SHA-1:
Após gerar o keystore release, você precisará atualizar o SHA-1 no Firebase:

1. **Obter SHA-1 do keystore release**:
   ```bash
   keytool -list -v -keystore release-key.jks -alias release-key
   ```

2. **Adicionar no Firebase Console**:
   - Vá para Firebase Console → Project Settings
   - Selecione seu app Android
   - Adicione o novo SHA-1 na seção "SHA certificate fingerprints"

3. **Baixar google-services.json atualizado**:
   - O Firebase gerará um novo google-services.json
   - Substitua o arquivo existente

## Troubleshooting Avançado

### Problemas de Assinatura:

1. **"Assinatura não válida"**:
   - Verifique se o keystore está correto
   - Confirme se as senhas estão corretas

2. **"APK não pode ser instalado"**:
   - Verifique se o APK foi assinado corretamente
   - Teste em dispositivo limpo

3. **"Erro de verificação"**:
   - Use `jarsigner -verify` para verificar assinatura
   - Verifique se o APK não foi corrompido
