import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_extend/share_extend.dart';
import '../models/received_file.dart';

class FileShareService {
  static const _platform = MethodChannel('file_share');
  
  // 分享单个或多个文件
  Future<void> shareFiles(List<ReceivedFile> files) async {
    if (files.isEmpty) return;
    
    try {
      // 检查文件是否存在
      final existingFiles = files.where((file) => file.exists).toList();
      if (existingFiles.isEmpty) {
        throw Exception('没有可分享的文件');
      }
      
      final filePaths = existingFiles.map((file) => file.path).toList();
      
      if (kIsWeb) {
        // Web平台：下载文件
        await _shareFilesWeb(existingFiles);
      } else if (Platform.isAndroid || Platform.isIOS || Platform.isOhos) {
        // 移动平台：使用系统分享
        await _shareFilesMobile(filePaths, existingFiles);
      } else {
        // 桌面平台：复制到剪贴板或打开文件夹
        await _shareFilesDesktop(existingFiles);
      }
      
      debugPrint('成功分享 ${existingFiles.length} 个文件');
    } catch (e) {
      debugPrint('分享文件失败: $e');
      rethrow;
    }
  }
  
  // Web平台文件分享（下载）
  Future<void> _shareFilesWeb(List<ReceivedFile> files) async {
    // 由于Web安全限制，这里只能提供文件信息
    // 实际下载需要通过其他方式实现
    final fileInfo = files.map((file) => '${file.name} (${file.formattedSize})').join('\n');
    await Clipboard.setData(ClipboardData(
      text: '文件列表：\n$fileInfo\n\n注意：Web版本暂不支持直接分享文件，请使用桌面版本。',
    ));
  }
  
  // 移动平台文件分享
  Future<void> _shareFilesMobile(List<String> filePaths, List<ReceivedFile> files) async {
    try {
      if (filePaths.length == 1) {
        // 单个文件使用share_extend分享
        await ShareExtend.share(filePaths.first, "file");
      } else {
        // 多个文件使用share_extend分享
        await ShareExtend.shareMultiple(filePaths, "file");
      }
    } catch (e) {
      // 如果分享失败，使用备用方案
      debugPrint('share_extend分享失败，使用备用方案: $e');
      await _shareFilesAlternative(files);
    }
  }
  
  // 桌面平台文件分享
  Future<void> _shareFilesDesktop(List<ReceivedFile> files) async {
    if (files.length == 1) {
      // 单个文件：复制路径到剪贴板
      await Clipboard.setData(ClipboardData(text: files.first.path));
    } else {
      // 多个文件：复制文件列表信息
      final fileInfo = files.map((file) => 
        '${file.name}\n路径: ${file.path}\n大小: ${file.formattedSize}\n发送者: ${file.senderName}'
      ).join('\n\n');
      
      await Clipboard.setData(ClipboardData(
        text: '接收文件列表 (${files.length} 个文件):\n\n$fileInfo',
      ));
    }
  }
  
  // 备用分享方案
  Future<void> _shareFilesAlternative(List<ReceivedFile> files) async {
    // 生成分享文本
    final shareText = _generateShareText(files);
    await Clipboard.setData(ClipboardData(text: shareText));
  }
  
  // 生成分享文本
  String _generateShareText(List<ReceivedFile> files) {
    if (files.length == 1) {
      final file = files.first;
      return '''文件分享：${file.name}
大小：${file.formattedSize}
接收时间：${_formatDateTime(file.receivedTime)}
发送者：${file.senderName} (${file.senderIp})
文件路径：${file.path}''';
    } else {
      final totalSize = files.fold(0, (sum, file) => sum + file.size);
      final formattedTotalSize = _formatFileSize(totalSize);
      
      final fileList = files.map((file) => 
        '• ${file.name} (${file.formattedSize})'
      ).join('\n');
      
      return '''文件分享列表 (共 ${files.length} 个文件，$formattedTotalSize)：

$fileList

接收时间：${_formatDateTime(files.first.receivedTime)}''';
    }
  }
  
  // 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // 打开文件所在文件夹（桌面平台）
  Future<void> openFileLocation(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        final directory = File(filePath).parent.path;
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      debugPrint('打开文件位置失败: $e');
      // 备用方案：复制路径到剪贴板
      await Clipboard.setData(ClipboardData(text: filePath));
    }
  }
  
  // 检查是否支持原生分享
  Future<bool> isNativeShareSupported() async {
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid || Platform.isIOS || Platform.isOhos) {
        final result = await _platform.invokeMethod('isShareSupported');
        return result as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}