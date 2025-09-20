import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class BaseToolPage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool isFullscreen;
  
  const BaseToolPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.isFullscreen = false
  });

  @override
  Widget build(BuildContext context) {
    // 全屏模式下隐藏状态栏和导航栏
    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      return child; // 直接返回子组件，不使用Scaffold
    } else {
      // 非全屏模式恢复系统UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(title, style: AppTextStyles.pageTitle),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: Colors.black.withOpacity(0.05),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.all(12),
            splashRadius: 20,
          ),
          actions: actions,
        ),
        body: SafeArea(
          // 减少不必要的内边距，让内容更贴近边缘
          bottom: false,
          child: Container(
            child: child,
          ),
        ),
      );
    }
  }
}
