# Guia de Release Automatizado

Este projeto usa GitHub Actions para automaticamente construir e fazer release de APKs quando você envia uma nova tag de versão.

## Como Criar um Release

### 1. Atualizar Versão (Opcional)
Se você quiser atualizar a versão do app, modifique `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Mude isso para sua nova versão
```

### 2. Fazer Commit das Mudanças
```bash
git add .
git commit -m "Preparar para release v1.0.0"
git push origin main
```

### 3. Criar e Enviar uma Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 4. GitHub Actions Fará Automaticamente:
- ✅ Construir o APK em um ambiente limpo
- ✅ Executar todos os testes
- ✅ Criar um release no GitHub
- ✅ Fazer upload do arquivo APK
- ✅ Gerar notas de release

## O que Acontece Quando Você Envia uma Tag

1. **Gatilho**: Enviar uma tag como `v1.0.0` dispara o workflow
2. **Build**: Flutter constrói o APK de release
3. **Release**: Cria um release no GitHub com o APK anexado
4. **Download**: Usuários podem baixar o APK diretamente do release

## Convenção de Versionamento de Tags

Use versionamento semântico:
- `v1.0.0` - Release principal
- `v1.1.0` - Release secundário  
- `v1.0.1` - Release de correção
- `v1.0.0-beta.1` - Pré-release

## Release Manual (Alternativa)

Se você preferir construir manualmente:
```bash
flutter build apk --release
```
O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

## Solução de Problemas

- **Workflow falha**: Verifique a aba Actions no seu repositório GitHub
- **APK não gerado**: Certifique-se de que todas as dependências estão no `pubspec.yaml`
- **Problemas de permissão**: Certifique-se de que o repositório tem Actions habilitado

## Próximos Passos

1. Envie este workflow para seu repositório
2. Crie seu primeiro release fazendo tag: `git tag v1.0.0 && git push origin v1.0.0`
3. Verifique a aba Actions para monitorar o processo de build
4. Baixe o APK do release gerado

## Configuração do Workflow

### Arquivo `.github/workflows/release.yml`:
```yaml
name: Build and Release APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.4'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: build/app/outputs/flutter-apk/app-release.apk
        generate_release_notes: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Benefícios do Release Automatizado

### ✅ **Consistência**:
- Builds sempre feitos no mesmo ambiente
- Configuração padronizada
- Menos erros humanos

### ✅ **Eficiência**:
- Processo automatizado
- Sem necessidade de build manual
- Releases mais rápidos

### ✅ **Rastreabilidade**:
- Histórico de releases
- Logs de build disponíveis
- Fácil rollback se necessário

## Configuração de Segurança

### Secrets do GitHub:
- `GITHUB_TOKEN`: Token automático para releases
- `KEYSTORE_FILE`: Arquivo de keystore (se usando assinatura)
- `KEYSTORE_PASSWORD`: Senha do keystore
- `KEY_ALIAS`: Alias da chave
- `KEY_PASSWORD`: Senha da chave

## Monitoramento

### Verificar Status:
1. Vá para seu repositório no GitHub
2. Clique na aba "Actions"
3. Verifique o status do workflow mais recente

### Logs de Build:
- Clique no workflow para ver logs detalhados
- Verifique se há erros de compilação
- Confirme se o APK foi gerado

## Troubleshooting Avançado

### Problemas Comuns:

1. **Build falha por dependências**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Problemas de permissão**:
   - Verifique se o repositório tem Actions habilitado
   - Confirme se o token tem permissões adequadas

3. **APK não aparece no release**:
   - Verifique o caminho do arquivo no workflow
   - Confirme se o build foi bem-sucedido

### Comandos de Debug:
```bash
# Verificar versão do Flutter
flutter --version

# Verificar dependências
flutter pub deps

# Testar build local
flutter build apk --release
```
