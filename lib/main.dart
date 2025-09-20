import 'package:flutter/material.dart';
import 'pages/main_page.dart';
import 'components/colors.dart';
import 'utils/startup_optimizer.dart';

void main() async {
  // 启用Flutter的性能优化选项
  WidgetsFlutterBinding.ensureInitialized();
  
  // 优化渲染性能 - 针对鸿蒙平台调整
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 50; // 减少到50MB避免内存压力
  PaintingBinding.instance.imageCache.maximumSize = 100; // 限制缓存图片数量
  
  // 应用鸿蒙平台专用优化
  StartupOptimizer.optimizeForOHOS();
  
  runApp(const MyApp());
  
  // 应用启动后执行延迟初始化任务
  WidgetsBinding.instance.addPostFrameCallback((_) {
    StartupOptimizer.performDelayedInitialization();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '默记工具箱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        useMaterial3: true,
        // 优化页面切换性能
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // 使用路由生成器进行懒加载
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
              transitionDuration: const Duration(milliseconds: 200), // 减少动画时间
            );
          default:
            return null;
        }
      },
      initialRoute: '/',
    );
  }
}
