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
    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.btnPrimary,
          foregroundColor: textColor ?? Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/google.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.g_mobiledata, size: 32);
              },
            ),
            SizedBox(width: 8),
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
    return AlertDialog(
      title: Text(
        'Código de Check-in',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Digite o código de 6 dígitos fornecido pelo palestrante:',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _codeController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
        ),
        PrimaryButton(
          text: 'Confirmar',
          onPressed: () {
            if (_codeController.text.length == 6) {
              widget.onCodeSubmitted(_codeController.text);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Por favor, digite um código de 6 dígitos'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
