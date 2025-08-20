import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.btnPrimary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyle.body,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          textStyle: AppTextStyle.body,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon!, SizedBox(width: 8), Text(text)],
              )
            : Text(text),
      ),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? icon;

  const TertiaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          textStyle: AppTextStyle.bodyBold,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
          side: BorderSide(color: AppColors.btnPrimary, width: 2),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon!, SizedBox(width: 8), Text(text)],
              )
            : Text(text),
      ),
    );
  }
}

class QuaternaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? icon;

  const QuaternaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          textStyle: AppTextStyle.bodyBold,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon!, SizedBox(width: 8), Text(text)],
              )
            : Text(text),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.text = 'Entrar com o Google',
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        // Define the linear gradient.
        gradient: LinearGradient(
          // Provide a list of colors.
          colors: [
            Color(0xFFAC213B),
            Color(0xFFAC2180),
          ], // Example: Google's blue and green
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // Match the button's shape for smooth corners.
        borderRadius: BorderRadius.circular(100),
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          // Make the button's background transparent to show the gradient.
          backgroundColor: Colors.transparent,
          // Remove the shadow that might appear under the button.
          // Ensure the text color is visible against the gradient.
          foregroundColor: textColor ?? Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // It's better to place assets in a dedicated container for styling.
            Container(
              decoration: BoxDecoration(),
              child: Image.asset(
                'assets/google.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.g_mobiledata,
                    size: 32,
                    color: Colors.black,
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CodeInputDialog extends StatefulWidget {
  final Function(String) onCodeSubmitted;

  const CodeInputDialog({super.key, required this.onCodeSubmitted});

  @override
  State<CodeInputDialog> createState() => _CodeInputDialogState();
}

class _CodeInputDialogState extends State<CodeInputDialog> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trigger the bottom sheet when this widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        backgroundColor: Colors.white,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 4,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Código de Check-in',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Digite o código de 6 dígitos fornecido pelo palestrante:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 16,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _focusNode.unfocus();
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.btnPrimary, width: 2),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Remove this widget from the tree after dismissing
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: AppColors.btnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.btnPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_codeController.text.length == 6) {
                          widget.onCodeSubmitted(_codeController.text);
                          Navigator.of(context).pop();
                          // Remove this widget from the tree after submitting
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Por favor, digite um código de 6 dígitos',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Confirmar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ).then((_) {
        // Remove this widget from the tree when the bottom sheet is dismissed
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });

    return const SizedBox.shrink(); // Return an empty widget
  }
}
