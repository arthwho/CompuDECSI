import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Termos de Uso'),
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
              'Termos de Uso do CompuDECSI',
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
              '1. Aceitação dos Termos',
              'Ao acessar e usar o aplicativo CompuDECSI, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deve usar nosso aplicativo.\n\n'
                  'Estes termos constituem um acordo legal entre você e o CompuDECSI. Recomendamos que você leia cuidadosamente todos os termos antes de usar o aplicativo.',
            ),

            _buildSection(
              '2. Descrição do Serviço',
              'O CompuDECSI é um aplicativo móvel que permite:\n\n'
                  '• Visualizar eventos acadêmicos e científicos\n'
                  '• Inscrever-se em eventos e palestras\n'
                  '• Gerenciar perfil de usuário\n'
                  '• Receber notificações sobre eventos\n'
                  '• Acessar códigos de inscrição\n'
                  '• Personalizar experiência com emojis\n\n'
                  'O aplicativo é destinado principalmente à comunidade acadêmica da Universidade Federal de Ouro Preto - UFOP.',
            ),

            _buildSection(
              '3. Elegibilidade e Registro',
              'Para usar o aplicativo, você deve:\n\n'
                  '• Ter pelo menos 13 anos de idade\n'
                  '• Possuir capacidade legal para celebrar contratos\n'
                  '• Fornecer informações verdadeiras e precisas\n'
                  '• Manter a confidencialidade de suas credenciais\n'
                  '• Notificar imediatamente sobre uso não autorizado\n\n'
                  'O registro é feito através do Google Sign-In, garantindo autenticação segura.',
            ),

            _buildSection(
              '4. Uso Aceitável',
              'Você concorda em usar o aplicativo apenas para fins legais e de acordo com estes termos. Você pode:\n\n'
                  '• Navegar pelos eventos disponíveis\n'
                  '• Inscrever-se em eventos de seu interesse\n'
                  '• Gerenciar suas informações de perfil\n'
                  '• Receber notificações relevantes\n'
                  '• Personalizar suas preferências\n\n'
                  'O uso deve ser feito de forma respeitosa e ética.',
            ),

            _buildSection(
              '5. Conduta Proibida',
              'Você concorda em NÃO:\n\n'
                  '• Usar o aplicativo para fins ilegais ou fraudulentos\n'
                  '• Tentar acessar contas de outros usuários\n'
                  '• Interferir no funcionamento do aplicativo\n'
                  '• Transmitir vírus ou código malicioso\n'
                  '• Usar bots ou scripts automatizados\n'
                  '• Violar direitos de propriedade intelectual\n'
                  '• Assediar ou intimidar outros usuários\n'
                  '• Fazer inscrições falsas em eventos\n'
                  '• Compartilhar códigos de inscrição indevidamente',
            ),

            _buildSection(
              '6. Propriedade Intelectual',
              'Todo o conteúdo do aplicativo, incluindo mas não se limitando a:\n\n'
                  '• Texto, gráficos, imagens e logotipos\n'
                  '• Software e código fonte\n'
                  '• Design e layout\n'
                  '• Marcas registradas e nomes comerciais\n\n'
                  'É propriedade do CompuDECSI ou de seus licenciadores e está protegido por leis de propriedade intelectual.\n\n'
                  'Você recebe uma licença limitada, não exclusiva e revogável para usar o aplicativo conforme estes termos.',
            ),

            _buildSection(
              '7. Privacidade e Dados',
              'O uso de suas informações pessoais é regido pela nossa Política de Privacidade, que faz parte integrante destes termos.\n\n'
                  'Ao usar o aplicativo, você consente com a coleta, uso e compartilhamento de suas informações conforme descrito na Política de Privacidade.',
            ),

            _buildSection(
              '8. Disponibilidade do Serviço',
              'Nos esforçamos para manter o aplicativo disponível 24/7, mas não garantimos:\n\n'
                  '• Disponibilidade ininterrupta\n'
                  '• Ausência de erros ou bugs\n'
                  '• Compatibilidade com todos os dispositivos\n'
                  '• Velocidade específica de conexão\n\n'
                  'Podemos realizar manutenção programada com aviso prévio quando possível.',
            ),

            _buildSection(
              '9. Limitação de Responsabilidade',
              'Em nenhuma circunstância o CompuDECSI será responsável por:\n\n'
                  '• Danos indiretos, incidentais ou consequenciais\n'
                  '• Perda de dados ou informações\n'
                  '• Interrupção do serviço\n'
                  '• Danos causados por terceiros\n'
                  '• Problemas de conectividade do usuário\n\n'
                  'Nossa responsabilidade total será limitada ao valor pago por você pelo serviço, se houver.',
            ),

            _buildSection(
              '10. Indenização',
              'Você concorda em indenizar e isentar o CompuDECSI de qualquer reclamação, dano, perda ou despesa (incluindo honorários advocatícios) decorrentes de:\n\n'
                  '• Seu uso do aplicativo\n'
                  '• Violação destes termos\n'
                  '• Violação de direitos de terceiros\n'
                  '• Conduta inadequada ou ilegal',
            ),

            _buildSection(
              '11. Modificações dos Termos',
              'Reservamo-nos o direito de modificar estes termos a qualquer momento. As modificações entrarão em vigor imediatamente após a publicação.\n\n'
                  'Continuar usando o aplicativo após as modificações constitui aceitação dos novos termos. Recomendamos revisar periodicamente estes termos.',
            ),

            _buildSection(
              '12. Rescisão',
              'Podemos suspender ou encerrar sua conta a qualquer momento por:\n\n'
                  '• Violação destes termos\n'
                  '• Conduta inadequada\n'
                  '• Uso fraudulento\n'
                  '• Inatividade prolongada\n\n'
                  'Você também pode encerrar sua conta a qualquer momento através das configurações do perfil.',
            ),

            _buildSection(
              '13. Lei Aplicável',
              'Estes termos são regidos pelas leis brasileiras. Qualquer disputa será resolvida nos tribunais competentes de Ouro Preto, Minas Gerais, Brasil.',
            ),

            _buildSection(
              '14. Disposições Gerais',
              '• Se qualquer disposição destes termos for considerada inválida, as demais permanecerão em vigor\n'
                  '• Estes termos constituem o acordo completo entre as partes\n'
                  '• A falha em fazer cumprir qualquer direito não constitui renúncia\n'
                  '• Os títulos das seções são apenas para referência',
            ),

            _buildSection(
              '15. Contato',
              'Para dúvidas sobre estes termos de uso, entre em contato conosco:\n\n'
                  '• E-mail: termos@compudecsi.com\n'
                  '• Telefone: (31) 3559-1234\n'
                  '• Endereço: Universidade Federal de Ouro Preto - UFOP, Ouro Preto - MG\n\n'
                  'Horário de atendimento: Segunda a sexta, das 8h às 18h.',
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
                        Icons.warning_amber_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Aviso Legal',
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
                    'Ao usar o aplicativo CompuDECSI, você confirma que leu, entendeu e concorda com todos os termos e condições aqui apresentados. Se você não concordar com qualquer parte destes termos, não deve usar nosso aplicativo.',
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
