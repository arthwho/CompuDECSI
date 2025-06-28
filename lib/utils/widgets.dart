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

class PixelArtButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const PixelArtButton({Key? key, required this.onPressed, required this.text})
    : super(key: key);

  @override
  _PixelArtButtonState createState() => _PixelArtButtonState();
}

class _PixelArtButtonState extends State<PixelArtButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The 3D effect is created with a custom border
    // Unpressed state: Black on top/left, Dark Grey on bottom/right
    // Pressed state: Inverted colors and slightly shifted text
    final Border border = Border(
      top: BorderSide(
        color: _isPressed ? const Color(0xFF808080) : Colors.black,
        width: 4.0,
      ),
      left: BorderSide(
        color: _isPressed ? const Color(0xFF808080) : Colors.black,
        width: 4.0,
      ),
      right: BorderSide(
        color: _isPressed ? Colors.black : const Color(0xFF808080),
        width: 4.0,
      ),
      bottom: BorderSide(
        color: _isPressed ? Colors.black : const Color(0xFF808080),
        width: 4.0,
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        padding: EdgeInsets.only(
          // Shift text down and right when pressed
          top: _isPressed ? 10.0 : 8.0,
          left: 8.0,
          right: 8.0,
          bottom: _isPressed ? 8.0 : 10.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFD3D3D3), // Light grey background
          border: border,
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.pressStart2p(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.text = 'Entrar com o Google',
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/google.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
