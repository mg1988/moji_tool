import 'package:flutter/material.dart';
import 'colors.dart';
import '../utils/share_service.dart';

// 自定义按钮组件 - 根据UI设计规范定义
class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isPrimary;
  final bool isIconButton;
  final bool isTextButton;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const CustomButton.primary({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.width = 160,
    this.height = 60,
  })  : isPrimary = true,
        isIconButton = false,
        isTextButton = false;

  const CustomButton.secondary({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.width = 160,
    this.height = 60,
  })  : isPrimary = false,
        isIconButton = false,
        isTextButton = false;

  const CustomButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.width = 44,
    this.height = 44,
  })  : text = '',
        isPrimary = false,
        isIconButton = true,
        isTextButton = false;

  const CustomButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 44,
  })  : icon = null,
        isPrimary = false,
        isIconButton = false,
        isTextButton = true,
        width = null;

  // 新增：分享按钮
  const CustomButton.share({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 160,
    this.height = 60,
  })  : icon = Icons.share,
        isPrimary = false,
        isIconButton = false,
        isTextButton = false;

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle;
    Widget child;

    if (isIconButton) {
      buttonStyle = AppButtonStyles.iconButton;
      child = Icon(icon, size: 24);
    } else if (isTextButton) {
      buttonStyle = AppButtonStyles.textButton;
      child = Text(text, style: AppTextStyles.body);
    } else {
      buttonStyle = isPrimary
          ? AppButtonStyles.primaryButton
          : AppButtonStyles.secondaryButton;

      child = icon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: 8),
                Text(text, style: AppTextStyles.body),
              ],
            )
          : Text(text, style: AppTextStyles.body);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}