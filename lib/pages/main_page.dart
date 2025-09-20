import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'settings_page.dart';
import 'favorites_page.dart';
import '../components/colors.dart';
import '../components/custom_bottom_navigation.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  
  // 侧滑退出相关变量
  DateTime? _lastBackPressed;
  static const Duration _backPressInterval = Duration(seconds: 2);
  
  // 自定义底部导航菜单项
  final List<Map<String, dynamic>> _navItems = [
    {
      'title': '收藏',
      'icon': Icons.star,
      'route': '/favorites'
    },
     {
      'title': '首页',
      'icon': Icons.home,
      'route': '/home'
    },
    {
      'title': '设置',
      'icon': Icons.settings,
      'route': '/settings'
    },
  ];

  /// 处理返回按键事件
  /// 实现侧滑2次退回桌面功能
  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    
    // 如果当前不在首页，先回到首页
    if (_currentIndex != 1) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return false;
    }
    
    // 如果在首页，检查是否在2秒内连续按下返回键
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > _backPressInterval) {
      _lastBackPressed = now;
      
      // 显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '再次滑动返回桌面',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.black.withOpacity(0.8),
          duration: _backPressInterval,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      
      // 添加触觉反馈
      HapticFeedback.lightImpact();
      return false;
    }
    
    // 第二次按下，退出应用
    HapticFeedback.mediumImpact();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          // physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          // 优化性能：缓存所有页面，避免切换时重建
          allowImplicitScrolling: true,
          children: const [
            FavoritesPage(), // 收藏页面
            HomePage(), // 首页
            SettingsPage(), // 设置页面
          ],
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _currentIndex,
          onTabChange: (index) {
            // 使用平滑动画切换页面，提高用户体验
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: _navItems,
          // 可以通过参数自定义导航栏样式
          backgroundColor: AppColors.white,
          selectedColor: AppColors.white,
           selectedBackColor: AppColors.black,
           selectedBackgroundColorOpacity: 0.9,
          // selectedColor: Colors.white,
          borderRadius: 40.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}