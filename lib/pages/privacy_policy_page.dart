import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidade do CompuDECSI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${DateTime.now().year}',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Informações Coletadas',
              'Coletamos informações que você nos fornece diretamente, como:\n\n'
                  '• Nome completo\n'
                  '• Endereço de e-mail\n'
                  '• Foto do perfil (através do Google Sign-In)\n'
                  '• Preferências de emoji\n'
                  '• Histórico de inscrições em eventos\n\n'
                  'Essas informações são necessárias para fornecer nossos serviços e melhorar sua experiência no aplicativo.',
            ),

            _buildSection(
              '2. Como Usamos Suas Informações',
              'Utilizamos suas informações para:\n\n'
                  '• Gerenciar sua conta e perfil de usuário\n'
                  '• Permitir inscrições em eventos e gerenciar participações\n'
                  '• Enviar notificações sobre eventos e atualizações\n'
                  '• Personalizar sua experiência no aplicativo\n'
                  '• Melhorar nossos serviços e funcionalidades\n'
                  '• Garantir a segurança da plataforma\n'
                  '• Cumprir obrigações legais',
            ),

            _buildSection(
              '3. Compartilhamento de Dados',
              'Não vendemos, alugamos ou compartilhamos suas informações pessoais com terceiros, exceto:\n\n'
                  '• Com organizadores de eventos (apenas informações necessárias para o evento)\n'
                  '• Com provedores de serviços que nos ajudam a operar o aplicativo\n'
                  '• Quando exigido por lei ou para proteger nossos direitos\n'
                  '• Com seu consentimento explícito',
            ),

            _buildSection(
              '4. Segurança dos Dados',
              'Implementamos medidas de segurança apropriadas para proteger suas informações:\n\n'
                  '• Criptografia de dados em trânsito e em repouso\n'
                  '• Autenticação segura através do Google Sign-In\n'
                  '• Controle de acesso baseado em funções\n'
                  '• Monitoramento contínuo de segurança\n'
                  '• Backups regulares dos dados',
            ),

            _buildSection(
              '5. Retenção de Dados',
              'Mantemos suas informações pessoais apenas pelo tempo necessário para:\n\n'
                  '• Fornecer nossos serviços\n'
                  '• Cumprir obrigações legais\n'
                  '• Resolver disputas\n'
                  '• Fazer cumprir nossos acordos\n\n'
                  'Você pode solicitar a exclusão de seus dados a qualquer momento.',
            ),

            _buildSection(
              '6. Seus Direitos',
              'Você tem os seguintes direitos:\n\n'
                  '• Acessar suas informações pessoais\n'
                  '• Corrigir dados imprecisos\n'
                  '• Excluir suas informações\n'
                  '• Restringir o processamento\n'
                  '• Portabilidade dos dados\n'
                  '• Oposição ao processamento\n'
                  '• Retirar consentimento',
            ),

            _buildSection(
              '7. Cookies e Tecnologias Similares',
              'Utilizamos cookies e tecnologias similares para:\n\n'
                  '• Manter você conectado\n'
                  '• Lembrar suas preferências\n'
                  '• Analisar o uso do aplicativo\n'
                  '• Melhorar a funcionalidade\n\n'
                  'Você pode controlar o uso de cookies através das configurações do seu dispositivo.',
            ),

            _buildSection(
              '8. Menores de Idade',
              'Nosso aplicativo não é destinado a menores de 13 anos. Não coletamos intencionalmente informações pessoais de menores de 13 anos. Se você é pai ou responsável e acredita que seu filho nos forneceu informações pessoais, entre em contato conosco.',
            ),

            _buildSection(
              '9. Transferências Internacionais',
              'Suas informações podem ser transferidas e processadas em países diferentes do seu país de residência. Garantimos que essas transferências sejam feitas de acordo com as leis de proteção de dados aplicáveis.',
            ),

            _buildSection(
              '10. Alterações na Política',
              'Podemos atualizar esta política de privacidade periodicamente. Notificaremos você sobre mudanças significativas através do aplicativo ou por e-mail. Recomendamos que você revise esta política regularmente.',
            ),

            _buildSection(
              '11. Contato',
              'Se você tiver dúvidas sobre esta política de privacidade ou sobre como tratamos suas informações pessoais, entre em contato conosco:\n\n'
                  '• E-mail: privacidade@compudecsi.com\n'
                  '• Telefone: (31) 3559-1234\n'
                  '• Endereço: Universidade Federal de Ouro Preto, Ouro Preto - MG',
            ),

            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Importante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ao usar o aplicativo CompuDECSI, você concorda com esta política de privacidade. Se você não concordar com qualquer parte desta política, não deve usar nosso aplicativo.',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
