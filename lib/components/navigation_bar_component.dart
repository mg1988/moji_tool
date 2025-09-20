import 'package:flutter/material.dart';
import 'colors.dart';

// 导航栏组件
class NavigationBarComponent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;

  const NavigationBarComponent({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChange,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.hint,
      unselectedLabelStyle: AppTextStyles.hint,
      iconSize: 24,
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.mic),
          label: '语音转文字',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: '历史',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }
}