import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../components/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 是否已经执行过预加载
  bool _hasPreloadedImages = false;
  
  @override
  void initState() {
    super.initState();
    
    // 优先渲染UI，然后在UI渲染完成后执行初始化任务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _initializeApp() async {
    try {
      // 移除不必要的初始化，改为懒加载
      // await initializeDateFormatting('zh_CN', null); // 移动到实际使用时再加载
      
      // 移除图片预加载，避免启动阻塞
      // if (!_hasPreloadedImages) {
      //   Future.microtask(() {
      //     _preloadImages();
      //   });
      //   _hasPreloadedImages = true;
      // }
      
      // 减少启动延迟，提升用户体验
      await Future.delayed(const Duration(milliseconds: 200)); // 从500ms减少到200ms
      
    } catch (e) {
      print('启动初始化失败: $e');
    } finally {
      // 无论初始化是否成功，都导航到主页面
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
  
  // 移除图片预加载功能，减少启动时间
  // void _preloadImages() {
  //   try {
  //     // 这里可以预加载应用中常用的图片资源
  //     // 例如：预加载轮播图图片
  //     precacheImage(AssetImage('images/banner1.png'), context);
  //     precacheImage(AssetImage('images/banner2.png'), context);
  //     precacheImage(AssetImage('images/banner3.png'), context);
  //     precacheImage(AssetImage('images/banner4.png'), context);
  //   } catch (e) {
  //     // 图片预加载失败不影响应用启动
  //     print('预加载图片失败: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 应用Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.build,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // 应用名称
            const Text(
              '默记工具箱',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            // 加载指示器
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}