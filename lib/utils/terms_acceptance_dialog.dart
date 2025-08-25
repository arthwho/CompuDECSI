import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/pages/privacy_policy_page.dart';
import 'package:compudecsi/pages/terms_of_use_page.dart';

class TermsAcceptanceDialog extends StatefulWidget {
  final VoidCallback onAccept;

  const TermsAcceptanceDialog({super.key, required this.onAccept});

  @override
  State<TermsAcceptanceDialog> createState() => _TermsAcceptanceDialogState();
}

class _TermsAcceptanceDialogState extends State<TermsAcceptanceDialog> {
  bool _privacyAccepted = false;
  bool _termsAccepted = false;

  bool get _bothAccepted => _privacyAccepted && _termsAccepted;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Termos e Privacidade',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para continuar, você precisa aceitar nossos termos de uso e política de privacidade.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Privacy Policy Checkbox
            Row(
              children: [
                Checkbox(
                  value: _privacyAccepted,
                  onChanged: (value) {
                    setState(() {
                      _privacyAccepted = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Li e aceito a ',
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Terms of Use Checkbox
            Row(
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Li e aceito os ',
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsOfUsePage(),
                            ),
                          );
                        },
                        child: Text(
                          'Termos de Uso',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você pode revisar os termos completos clicando nos links acima.',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _bothAccepted
              ? () {
                  Navigator.of(context).pop();
                  widget.onAccept();
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Aceitar e Continuar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
