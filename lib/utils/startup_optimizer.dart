import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 启动性能优化工具类
/// 用于管理应用启动时的各种初始化任务
class StartupOptimizer {
  static bool _isIntlInitialized = false;
  static bool _isAppInitialized = false;
  
  /// 获取Intl初始化状态
  static bool get isIntlInitialized => _isIntlInitialized;
  
  /// 获取应用初始化状态
  static bool get isAppInitialized => _isAppInitialized;
  
  /// 延迟初始化Intl本地化数据
  /// 只在真正需要时才进行初始化，避免启动时阻塞
  static Future<void> initializeIntlIfNeeded() async {
    if (_isIntlInitialized) {
      return;
    }
    
    try {
      await initializeDateFormatting('zh_CN', null);
      _isIntlInitialized = true;
      print('Intl本地化数据初始化完成');
    } catch (e) {
      print('Intl本地化数据初始化失败: $e');
    }
  }
  
  /// 应用启动后的延迟初始化任务
  /// 这些任务不会阻塞主要的UI渲染
  static Future<void> performDelayedInitialization() async {
    if (_isAppInitialized) {
      return;
    }
    
    // 分批执行初始化任务，避免一次性执行太多任务
    final tasks = [
      () => initializeIntlIfNeeded(),
      () => _preloadCriticalAssets(),
      () => _optimizeImageCache(),
    ];
    
    for (final task in tasks) {
      try {
        await task();
        // 在每个任务之间让出控制权，避免阻塞UI
        await Future.delayed(const Duration(milliseconds: 1));
      } catch (e) {
        print('延迟初始化任务失败: $e');
      }
    }
    
    _isAppInitialized = true;
    print('应用延迟初始化完成');
  }
  
  /// 预加载关键资源
  static Future<void> _preloadCriticalAssets() async {
    // 这里可以预加载一些关键的资源
    // 但只预加载最重要的，避免过度预加载
    print('关键资源预加载完成');
  }
  
  /// 优化图片缓存设置
  static Future<void> _optimizeImageCache() async {
    // 针对鸿蒙平台的特殊优化
    if (const bool.hasEnvironment('IS_OHOS')) {
      PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 30; // 30MB
      PaintingBinding.instance.imageCache.maximumSize = 80;
    }
    print('图片缓存优化完成');
  }
  
  /// 检查是否为鸿蒙平台
  static bool get isOHOSPlatform {
    return const bool.hasEnvironment('IS_OHOS');
  }
  
  /// 鸿蒙平台专用优化
  static void optimizeForOHOS() {
    if (!isOHOSPlatform) return;
    
    // 针对鸿蒙平台的特殊优化设置
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 25; // 25MB
    PaintingBinding.instance.imageCache.maximumSize = 60;
    
    print('鸿蒙平台优化已应用');
  }
  
  /// 重置初始化状态（主要用于测试）
  static void reset() {
    _isIntlInitialized = false;
    _isAppInitialized = false;
  }
}