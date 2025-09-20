import 'package:flutter/material.dart';
import '../utils/share_service.dart';

/// 分享功能助手类
/// 提供统一的分享功能接口和用户体验
class ShareHelper {
  /// 显示分享结果提示
  static void showShareResult(BuildContext context, bool success, [String? errorMessage]) {
    if (success) {
      if (!ShareService.isNativeShareSupported()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('内容已${ShareService.getShareMethodDescription()}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? '分享失败'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 检查内容并分享文本
  static Future<void> shareTextWithValidation(
    BuildContext context,
    String text, {
    String? subject,
    String emptyMessage = '没有内容可分享',
  }) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emptyMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ShareService.shareText(text.trim(), subject: subject);
      showShareResult(context, true);
    } catch (e) {
      showShareResult(context, false, '分享失败: $e');
    }
  }

  /// 检查文件并分享
  static Future<void> shareFileWithValidation(
    BuildContext context,
    String filePath, {
    String emptyMessage = '文件路径无效',
  }) async {
    if (filePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emptyMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ShareService.shareFile(filePath.trim());
      showShareResult(context, true);
    } catch (e) {
      showShareResult(context, false, '分享失败: $e');
    }
  }

  /// 检查文件列表并分享
  static Future<void> shareMultipleFilesWithValidation(
    BuildContext context,
    List<String> filePaths, {
    String emptyMessage = '没有文件可分享',
  }) async {
    final validPaths = filePaths.where((path) => path.trim().isNotEmpty).toList();
    
    if (validPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emptyMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await ShareService.shareMultipleFiles(validPaths);
      showShareResult(context, true);
    } catch (e) {
      showShareResult(context, false, '分享失败: $e');
    }
  }

  /// 显示分享选项对话框
  static Future<void> showShareDialog(
    BuildContext context, {
    required String text,
    String? title,
    String? subject,
  }) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有内容可分享'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? '分享内容'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择分享方式:'),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    text.length > 100 ? '${text.substring(0, 100)}...' : text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await shareTextWithValidation(context, text, subject: subject);
              },
              child: const Text('分享'),
            ),
          ],
        );
      },
    );
  }

  /// 获取分享按钮
  static Widget buildShareButton({
    required VoidCallback onPressed,
    String text = '分享',
    IconData icon = Icons.share,
    Color? backgroundColor,
    Color? foregroundColor,
    bool enabled = true,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }

  /// 获取分享图标按钮
  static Widget buildShareIconButton({
    required VoidCallback onPressed,
    String tooltip = '分享',
    IconData icon = Icons.share,
    Color? color,
    bool enabled = true,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color,
    );
  }
}