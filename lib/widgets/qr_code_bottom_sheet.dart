import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:compudecsi/widgets/qr_code_widget.dart';
import 'package:compudecsi/utils/variables.dart';

class QRCodeBottomSheet extends StatelessWidget {
  final String enrollmentCode;
  final String eventName;

  const QRCodeBottomSheet({
    Key? key,
    required this.enrollmentCode,
    required this.eventName,
  }) : super(key: key);

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: enrollmentCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado para a área de transferência'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'QR Code de Inscrição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  eventName,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // QR Code Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                QRCodeWidget(data: enrollmentCode, size: 200),
                const SizedBox(height: 20),

                // Copy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyCode(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Código'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.purpleDark,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instruções:',
                            style: TextStyle(
                              color: AppColors.purpleDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Apresente este QR Code para o administrador\n'
                        '• O administrador irá escaneá-lo para confirmar sua presença\n'
                        '• Mantenha este código seguro',
                        style: TextStyle(
                          color: AppColors.purpleDark,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
