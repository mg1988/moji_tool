import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_extend/share_extend.dart';

/// 通用分享服务类
/// 使用 share_extend 模块实现文本、文件等内容的分享功能
class ShareService {
  /// 分享文本内容
  /// [text] 要分享的文本内容
  /// [subject] 分享标题（可选）
  static Future<void> shareText(String text, {String? subject}) async {
    if (text.isEmpty) return;
    
    try {
      if (kIsWeb) {
        // Web平台：复制到剪贴板
        await Clipboard.setData(ClipboardData(text: text));
      } else if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用share_extend分享
        await ShareExtend.share(text, "text", subject: subject ?? '分享文本');
      } else {
        // 桌面平台：复制到剪贴板
        await Clipboard.setData(ClipboardData(text: text));
      }
      
      debugPrint('成功分享文本内容');
    } catch (e) {
      debugPrint('分享文本失败: $e');
      // 备用方案：复制到剪贴板
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  /// 分享文件
  /// [filePath] 文件路径
  static Future<void> shareFile(String filePath) async {
    if (filePath.isEmpty) return;
    
    try {
      if (kIsWeb) {
        // Web平台：复制文件路径
        await Clipboard.setData(ClipboardData(text: filePath));
      } else if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用share_extend分享文件
        await ShareExtend.share(filePath, "file");
      } else {
        // 桌面平台：复制文件路径
        await Clipboard.setData(ClipboardData(text: filePath));
      }
      
      debugPrint('成功分享文件: $filePath');
    } catch (e) {
      debugPrint('分享文件失败: $e');
      // 备用方案：复制文件路径到剪贴板
      await Clipboard.setData(ClipboardData(text: filePath));
    }
  }

  /// 分享多个文件
  /// [filePaths] 文件路径列表
  static Future<void> shareMultipleFiles(List<String> filePaths) async {
    if (filePaths.isEmpty) return;
    
    try {
      if (kIsWeb) {
        // Web平台：复制文件路径列表
        final pathsText = filePaths.join('\n');
        await Clipboard.setData(ClipboardData(text: pathsText));
      } else if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用share_extend分享多个文件
        await ShareExtend.shareMultiple(filePaths, "file");
      } else {
        // 桌面平台：复制文件路径列表
        final pathsText = filePaths.join('\n');
        await Clipboard.setData(ClipboardData(text: pathsText));
      }
      
      debugPrint('成功分享 ${filePaths.length} 个文件');
    } catch (e) {
      debugPrint('分享多个文件失败: $e');
      // 备用方案：复制文件路径列表到剪贴板
      final pathsText = filePaths.join('\n');
      await Clipboard.setData(ClipboardData(text: pathsText));
    }
  }

  /// 分享图片
  /// [imagePath] 图片路径
  static Future<void> shareImage(String imagePath) async {
    if (imagePath.isEmpty) return;
    
    try {
      if (kIsWeb) {
        // Web平台：复制图片路径
        await Clipboard.setData(ClipboardData(text: imagePath));
      } else if (Platform.isAndroid || Platform.isIOS) {
        // 移动平台：使用share_extend分享图片
        await ShareExtend.share(imagePath, "image");
      } else {
        // 桌面平台：复制图片路径
        await Clipboard.setData(ClipboardData(text: imagePath));
      }
      
      debugPrint('成功分享图片: $imagePath');
    } catch (e) {
      debugPrint('分享图片失败: $e');
      // 备用方案：复制图片路径到剪贴板
      await Clipboard.setData(ClipboardData(text: imagePath));
    }
  }

  /// 检查是否支持原生分享
  static bool isNativeShareSupported() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 获取分享方式描述
  static String getShareMethodDescription() {
    if (kIsWeb) {
      return '复制到剪贴板';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return '系统分享';
    } else {
      return '复制到剪贴板';
    }
  }
}