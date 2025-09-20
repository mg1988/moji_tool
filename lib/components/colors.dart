import 'package:flutter/material.dart';

// 颜色系统 - 根据UI设计规范定义
class AppColors {
  // 主色
  static const Color primary = Color(0xFF000000);
  static const Color primaryBtn = Color(0xFF0072FF);
  // 辅助色
  static const Color secondary = Color(0xFF00C6FF);

  // 强调色
  static const Color accent = Color(0xFFFF00AA);
  
  // 错误提示色
  static const Color error = Color(0xFFFF4D4F);
  
  // 成功提示色
  static const Color success = Color(0xFF52C41A);

  // 中性色 - 背景
  static const Color background = Color(0xFFF5F7FA);

  // 中性色 - 边框
  static const Color border = Color(0xFFE0E0E0);

  // 中性色 - 文字
  static const Color textPrimary = Color(0xFF333333);

  // 中性色 - 次要文字
  static const Color textSecondary = Color(0xFF666666);

  // 中性色 - 提示文字
  static const Color textHint = Color(0xFF999999);

  // 阴影色
  static const Color shadow = Color(0xFF000000);

  // 白色
  static const Color white = Color(0xFFFFFFFF);

  // 黑色
  static const Color black = Color(0xFF000000);

  // 透明色
  static const Color transparent = Color(0x00000000);
}

// 文本样式 - 根据UI设计规范定义
class AppTextStyles {
  // 页面标题
  static const TextStyle pageTitle = TextStyle(
    fontSize: 18,
    height: 24/18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // 副标题
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    height: 22/16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // 正文文字、按钮文字
  static const TextStyle body = TextStyle(
    fontSize: 13,
    height: 22/16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // 辅助说明文字
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    height: 20/14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // 底部提示文字
  static const TextStyle hint = TextStyle(
    fontSize: 12,
    height: 16/12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
}

// 按钮样式 - 根据UI设计规范定义
class AppButtonStyles {
  // 主要功能按钮
  static ButtonStyle primaryButton = ButtonStyle(
    shape: WidgetStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    )),
    backgroundColor: WidgetStateProperty.all(AppColors.primaryBtn),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
    textStyle: WidgetStateProperty.all(AppTextStyles.body),
    elevation: WidgetStateProperty.all(0),
  );

  // 次要功能按钮
  static ButtonStyle secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.white),
    foregroundColor: WidgetStateProperty.all(AppColors.primary),
    textStyle: WidgetStateProperty.all(AppTextStyles.body),
    elevation: WidgetStateProperty.all(0),
  );

  // 图标按钮
  static ButtonStyle iconButton = ButtonStyle(
    shape: WidgetStateProperty.all(const CircleBorder()),
    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.withOpacity(0.1);
      }
      return AppColors.transparent;
    }),
    foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
    elevation: WidgetStateProperty.all(0),
  );

  // 文字按钮
  static ButtonStyle textButton = ButtonStyle(
    shape: WidgetStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    )),
    backgroundColor: WidgetStateProperty.all(AppColors.transparent),
    foregroundColor: WidgetStateProperty.all(AppColors.primary),
    textStyle: WidgetStateProperty.all(AppTextStyles.body),
    elevation: WidgetStateProperty.all(0),
  );
}

// 卡片样式 - 根据UI设计规范定义
class AppCardStyles {
  // 基础卡片
  static BoxDecoration basicCard = BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(16),
  );

  // 功能卡片
  static BoxDecoration featureCard = BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}