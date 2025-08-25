# Guia de Configuração de Notificações Push

Este guia explica como configurar notificações push para o app CompuDECSI.

## Funcionalidades Implementadas

✅ **Notificações Locais**: Agendadas 30 minutos antes dos eventos  
✅ **Firebase Cloud Messaging (FCM)**: Para notificações push  
✅ **Página de Configurações de Notificação**: Usuário pode gerenciar preferências  
✅ **Agendamento Automático**: Quando usuários se inscrevem em eventos  
✅ **Cancelamento Automático**: Quando usuários cancelam inscrição em eventos  

## Instruções de Configuração

### 1. Configuração do Firebase

#### 1.1 Habilitar Firebase Cloud Messaging
1. Acesse o Firebase Console
2. Navegue para Project Settings > Cloud Messaging
3. Habilite Cloud Messaging se ainda não estiver habilitado
4. Anote sua Server Key (você precisará disso para Cloud Functions)

#### 1.2 Atualizar Arquivos de Configuração do Firebase

**Para Android (`android/app/google-services.json`):**
- Certifique-se de que o arquivo está atualizado com seu projeto Firebase
- Verifique se Cloud Messaging está habilitado no console Firebase

**Para iOS (`ios/Runner/GoogleService-Info.plist`):**
- Certifique-se de que o arquivo está atualizado com seu projeto Firebase
- Adicione o seguinte ao seu `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 2. Configuração Android

#### 2.1 Atualizar Android Manifest
Adicione as seguintes permissões ao `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

#### 2.2 Adicionar Ícones de Notificação (Opcional)
Crie ícones de notificação e coloque-os em:
- `android/app/src/main/res/drawable-hdpi/`
- `android/app/src/main/res/drawable-mdpi/`
- `android/app/src/main/res/drawable-xhdpi/`
- `android/app/src/main/res/drawable-xxhdpi/`

### 3. Configuração iOS

#### 3.1 Atualizar Projeto iOS
1. Abra `ios/Runner.xcworkspace` no Xcode
2. Selecione o target Runner
3. Vá para Signing & Capabilities
4. Adicione a capacidade "Push Notifications"
5. Adicione a capacidade "Background Modes" e marque:
   - Remote notifications
   - Background fetch

#### 3.2 Atualizar Info.plist
Adicione o seguinte ao `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 4. Configuração das Cloud Functions

#### 4.1 Instalar Firebase CLI
```bash
npm install -g firebase-tools
```

#### 4.2 Inicializar Firebase Functions
```bash
firebase login
firebase init functions
```

#### 4.3 Fazer Deploy das Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### 5. Testando a Implementação

#### 5.1 Testar Notificações Locais
1. Execute o app em um dispositivo (não emulador para melhores resultados)
2. Vá para Perfil > Notificações
3. Conceda permissões de notificação
4. Inscreva-se em um evento que começa em mais de 30 minutos
5. Aguarde a notificação (ou teste com um horário mais próximo)

#### 5.2 Testar Notificações Push
1. Use o Firebase Console para enviar uma mensagem de teste
2. Ou use as Cloud Functions para enviar notificações

## Como Funciona

### 1. Fluxo de Inscrição do Usuário
1. Usuário se inscreve em um evento
2. App agenda uma notificação local para 30 minutos antes do evento
3. Notificação inclui nome do evento, localização e descrição

### 2. Fluxo de Cancelamento de Inscrição
1. Usuário cancela inscrição
2. App cancela a notificação agendada para esse evento
3. Usuário não receberá o lembrete

### 3. Conteúdo da Notificação
- **Título**: "Lembrete: [Nome do Evento]"
- **Corpo**: Descrição do evento + localização
- **Horário**: 30 minutos antes do início do evento

### 4. Canais de Notificação
- **Lembretes de Eventos**: Para notificações agendadas de eventos
- **Notificações de Eventos**: Para notificações push

## Solução de Problemas

### Problemas Comuns

#### 1. Notificações Não Aparecem
- Verifique se as notificações estão habilitadas nas configurações do dispositivo
- Verifique se os arquivos de configuração do Firebase estão corretos
- Verifique se o app tem permissões de notificação

#### 2. Notificações Locais Não Funcionam
- Certifique-se de que o dispositivo não está em modo de otimização de bateria
- Verifique se o horário da notificação está no futuro
- Verifique as configurações de fuso horário

#### 3. Notificações Push Não Funcionam
- Verifique a configuração do Firebase Cloud Messaging
- Verifique se as Cloud Functions foram implantadas
- Verifique a geração do token FCM

#### 4. Problemas Específicos do iOS
- Certifique-se de que a capacidade Push Notifications foi adicionada
- Verifique a configuração do certificado APNs
- Verifique se os modos de background estão habilitados

### Comandos de Debug

```bash
# Verificar configuração do Firebase
firebase projects:list

# Fazer deploy das functions
firebase deploy --only functions

# Visualizar logs das functions
firebase functions:log

# Testar token FCM
# Use Firebase Console > Cloud Messaging > Send test message
```

## Considerações de Segurança

1. **Tokens FCM**: Armazenados com segurança no Firestore
2. **Permissões do Usuário**: Usuários podem controlar configurações de notificação
3. **Privacidade dos Dados**: Apenas informações necessárias do evento são incluídas
4. **Atualização de Token**: Gerenciada automaticamente pelo Firebase

## Considerações de Performance

1. **Notificações Locais**: Mais confiáveis que notificações push
2. **Otimização de Bateria**: Notificações são agendadas eficientemente
3. **Uso de Rede**: Mínimo - apenas para atualizações de token FCM
4. **Armazenamento**: Notificações são gerenciadas pelo sistema

## Melhorias Futuras

- [ ] Sons de notificação personalizados
- [ ] Notificações ricas com imagens
- [ ] Categorias de notificação
- [ ] Histórico de notificações
- [ ] Notificações em lote
- [ ] Melhorias no tratamento de fuso horário

## Suporte

Para problemas relacionados a:
- **Configuração do Firebase**: Consulte a documentação do Firebase
- **Implementação do App**: Verifique os comentários do código
- **Problemas do Dispositivo**: Verifique as configurações de notificação do dispositivo
- **Cloud Functions**: Verifique os logs do Firebase Functions
