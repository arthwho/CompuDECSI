import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:compudecsi/utils/variables.dart';

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
