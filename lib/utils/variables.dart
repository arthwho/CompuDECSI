import 'package:flutter/material.dart';

class AppColors {
  static Color primary = AppColors.purple;
  static Color btnPrimary = AppColors.purpleDark;
  static Color accent = AppColors.purple;
  static Color destructive = AppColors.red;
  static Color red = Color(0xffAC213B);
  static Color purple = Color(0xffAC2180);
  static Color purpleLight = Color(0xffE5DFF2);
  static Color purpleDark = Color(0xff841e73);
  static Color black = Color(0xff262628);
  static Color white = Color(0xffFDFCFA);
  static Color blue = Color(0xff274560);
  static Color lightBlue = Color(0xff007AFF);
  static Color textFieldBackground = Color(0xffE5E5E5);
  static Color genderTextColor = Color(0xffA6A6A6);
  static Color border = Color(0xffC4C4C4);
  static Color circle = Color(0xffE2E2E2);
  static Color whitegrey = Color(0xffC3C2C2);
  static Color grey = Color(0xff918F8F);
  static Color greychat = Color(0xffE8E8E8);
}

class AppSpacing {
  static double sm = 8;
  static double md = 16;
  static double lg = 24;
  static double xl = 32;
  static double xxl = 64;
  static double viewPortSide = 16;
  static double viewPortSideOnboarding = 32;
  static double viewPortTop = 64;
  static double viewPortBottom = 64;
}

class AppSize {
  static double sm = 8;
  static double md = 16;
  static double lg = 24;
  static double xl = 32;
  static double xxl = 64;
}

class AppBorderRadius {
  static BorderRadius sm = BorderRadius.circular(8);
  static BorderRadius md = BorderRadius.circular(16);
  static BorderRadius lg = BorderRadius.circular(24);
  static BorderRadius xl = BorderRadius.circular(32);
  static BorderRadius xxl = BorderRadius.circular(64);
}

class AppTextStyle {
  static TextStyle title = TextStyle(
    color: Colors.black,
    fontSize: AppSize.xl,
    fontWeight: FontWeight.bold,
  );

  static TextStyle heading1 = TextStyle(
    fontSize: AppSize.lg,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static TextStyle subheading1 = TextStyle(
    fontSize: AppSize.md,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: AppSize.md,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static TextStyle body = TextStyle(
    fontSize: AppSize.md,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static TextStyle bodyBold = TextStyle(
    fontSize: AppSize.md,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
}

class AppButtonStyle {
  static ButtonStyle btnPrimary = FilledButton.styleFrom(
    backgroundColor: AppColors.btnPrimary,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyle.body,
    shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.md),
  );
}
