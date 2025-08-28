# Funcionalidade QR Code - CompuDECSI

## Visão Geral

A funcionalidade QR Code foi implementada para substituir os códigos de inscrição em forma de número por códigos QR para facilitar o gerenciamento de check-in. Isso permite que administradores e membros adicionais de Staff escaneiem rapidamente códigos QR para fazer o check-in dos participantes em vez de digitar códigos manualmente.

## Funcionalidades

### Para Usuários (Estudantes)
- **Geração de QR Code**: Quando um usuário se inscreve em um evento, um QR code único é gerado em vez de um código literal
- **Exibição do QR Code**: Os usuários podem visualizar seu QR code em um diálogo modal com design limpo e profissional
- **Funcionalidade de Cópia**: Os usuários ainda podem copiar seu código de inscrição como texto se necessário
- **Instruções**: Instruções claras sobre como usar o QR code para check-in

### Para Administradores e Staff
- **Scanner de QR Code**: Página dedicada ao scanner acessível pelo painel administrativo
- **Escaneamento em Tempo Real**: Feed de câmera ao vivo com detecção de QR code
- **Verificação do Usuário**: Mostra detalhes do usuário e do evento antes de confirmar o check-in
- **Check-in Automático**: Processa o check-in automaticamente após confirmação
- **Tratamento de Erros**: Mensagens de erro apropriadas para códigos inválidos ou expirados

## Implementação Técnica

### Dependências Adicionadas
- `qr_flutter: ^4.1.0` - Para gerar códigos QR
- `mobile_scanner: ^3.5.6` - Para escanear códigos QR (substitui qr_code_scanner para melhor compatibilidade)

### Arquivos Criados/Modificados

#### Novos Arquivos
- `lib/widgets/qr_code_widget.dart` - Widget reutilizável para exibição de QR code
- `lib/widgets/qr_code_dialog.dart` - Diálogo modal para exibir códigos QR
- `lib/admin/qr_scanner_page.dart` - Página do scanner administrativo
- `test/widgets/qr_code_widget_test.dart` - Testes para o widget de QR code

#### Arquivos Modificados
- `lib/pages/detail_page.dart` - Atualizado o card de inscrição para mostrar botão de QR code
- `lib/admin/admin_panel.dart` - Adicionada opção de scanner QR ao painel administrativo
- `pubspec.yaml` - Adicionadas dependências de QR code
- `android/app/src/main/AndroidManifest.xml` - Adicionadas permissões de câmera
- `ios/Runner/Info.plist` - Adicionada descrição de uso da câmera

### Estrutura do Banco de Dados
O sistema de inscrição permanece o mesmo, com códigos de inscrição armazenados na coleção `enrollments`:
```json
{
  "userId": "user_id",
  "eventId": "event_id", 
  "enrollmentCode": "123456",
  "enrolledAt": "timestamp"
}
```

## Instruções de Uso

### Para Usuários
1. Inscreva-se em um evento como de costume
2. Em vez de ver um código literal, você verá um botão "Mostrar QR Code"
3. Toque no botão para abrir o diálogo do QR code
4. Apresente o QR code ao administrador para check-in
5. Opcionalmente, você pode copiar o código como texto usando o botão "Copiar código"

### Para Administradores
1. Acesse o painel administrativo
2. Toque na opção "Scanner QR Code"
3. Conceda permissões de câmera quando solicitado
4. Aponte a câmera para o QR code do usuário
5. Revise os detalhes do usuário e do evento no diálogo de confirmação
6. Toque em "Confirmar Check-in" para completar o processo

## Recursos de Segurança
- Cada código de inscrição é único por usuário por evento
- Os códigos QR contêm apenas o código de inscrição, não dados sensíveis do usuário
- A verificação administrativa mostra detalhes do usuário antes do check-in
- O tratamento de erros impede check-ins inválidos

## Permissões Necessárias
- **Android**: Permissão de câmera para escaneamento de QR
- **iOS**: Descrição de uso da câmera para escaneamento de QR

## Testes
Execute os testes do widget de QR code:
```bash
flutter test test/widgets/qr_code_widget_test.dart
```

## Melhorias Futuras
- Funcionalidade de expiração de QR code
- Geração em lote de códigos QR para eventos
- Validação offline de códigos QR
- Análises e rastreamento de códigos QR
