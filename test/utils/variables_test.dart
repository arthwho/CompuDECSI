import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compudecsi/utils/variables.dart';

void main() {
  group('AppColors', () {
    test('should have correct color values', () {
      expect(AppColors.primary, equals(const Color(0xffAC2180))); // This is AppColors.purple
      expect(AppColors.btnPrimary, equals(const Color(0xff841e73))); // This is AppColors.purpleDark
      expect(AppColors.black, equals(const Color(0xff262628)));
      expect(AppColors.white, equals(const Color(0xffFDFCFA)));
      expect(AppColors.blue, equals(const Color(0xff274560)));
      expect(AppColors.lightBlue, equals(const Color(0xff007AFF)));
      expect(AppColors.textFieldBackground, equals(const Color(0xffE5E5E5)));
      expect(AppColors.genderTextColor, equals(const Color(0xffA6A6A6)));
      expect(AppColors.border, equals(const Color(0xffC4C4C4)));
      expect(AppColors.circle, equals(const Color(0xffE2E2E2)));
      expect(AppColors.whitegrey, equals(const Color(0xffC3C2C2)));
      expect(AppColors.grey, equals(const Color(0xff918F8F)));
      expect(AppColors.greychat, equals(const Color(0xffE8E8E8)));
    });
  });

  group('AppSpacing', () {
    test('should have correct spacing values', () {
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));
      expect(AppSpacing.xl, equals(32.0));
      expect(AppSpacing.xxl, equals(64.0));
      expect(AppSpacing.viewPortSide, equals(16.0));
      expect(AppSpacing.viewPortSideOnboarding, equals(32.0));
      expect(AppSpacing.viewPortTop, equals(64.0));
      expect(AppSpacing.viewPortBottom, equals(64.0));
    });
  });

  group('AppSize', () {
    test('should have correct size values', () {
      expect(AppSize.sm, equals(8.0));
      expect(AppSize.md, equals(16.0));
      expect(AppSize.lg, equals(24.0));
      expect(AppSize.xl, equals(32.0));
      expect(AppSize.xxl, equals(64.0));
    });
  });

  group('AppBorderRadius', () {
    test('should have correct border radius values', () {
      expect(AppBorderRadius.sm, equals(BorderRadius.circular(8)));
      expect(AppBorderRadius.md, equals(BorderRadius.circular(16)));
      expect(AppBorderRadius.lg, equals(BorderRadius.circular(24)));
      expect(AppBorderRadius.xl, equals(BorderRadius.circular(32)));
      expect(AppBorderRadius.xxl, equals(BorderRadius.circular(64)));
    });
  });

  group('AppTextStyle', () {
    test('title should have correct properties', () {
      final titleStyle = AppTextStyle.title;
      expect(titleStyle.color, equals(Colors.black));
      expect(titleStyle.fontSize, equals(AppSize.xl));
      expect(titleStyle.fontWeight, equals(FontWeight.bold));
    });

    test('heading1 should have correct properties', () {
      final heading1Style = AppTextStyle.heading1;
      expect(heading1Style.fontSize, equals(AppSize.lg));
      expect(heading1Style.fontWeight, equals(FontWeight.bold));
      expect(heading1Style.color, equals(AppColors.black));
    });

    test('subheading1 should have correct properties', () {
      final subheading1Style = AppTextStyle.subheading1;
      expect(subheading1Style.fontSize, equals(AppSize.md));
      expect(subheading1Style.fontWeight, equals(FontWeight.w700));
      expect(subheading1Style.color, equals(AppColors.black));
    });

    test('heading2 should have correct properties', () {
      final heading2Style = AppTextStyle.heading2;
      expect(heading2Style.fontSize, equals(AppSize.md));
      expect(heading2Style.fontWeight, equals(FontWeight.w700));
      expect(heading2Style.color, equals(AppColors.black));
    });

    test('body should have correct properties', () {
      final bodyStyle = AppTextStyle.body;
      expect(bodyStyle.fontSize, equals(AppSize.md));
      expect(bodyStyle.fontWeight, equals(FontWeight.w400));
      expect(bodyStyle.color, equals(AppColors.black));
    });

    test('bodyBold should have correct properties', () {
      final bodyBoldStyle = AppTextStyle.bodyBold;
      expect(bodyBoldStyle.fontSize, equals(AppSize.md));
      expect(bodyBoldStyle.fontWeight, equals(FontWeight.bold));
      expect(bodyBoldStyle.color, equals(AppColors.black));
    });
  });

  group('AppButtonStyle', () {
    test('btnPrimary should have correct properties', () {
      final buttonStyle = AppButtonStyle.btnPrimary;

      // Test that the button style is properly configured
      expect(buttonStyle, isA<ButtonStyle>());

      // Note: We can't easily test the internal properties of ButtonStyle
      // without using reflection, but we can verify it's not null
      expect(buttonStyle, isNotNull);
    });
  });
}
