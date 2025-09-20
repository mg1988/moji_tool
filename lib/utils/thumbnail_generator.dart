import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailGenerator {
  static const int _thumbnailSize = 200;
  static const String _thumbnailCacheDir = 'thumbnails';
  
  // 生成文件缩略图
  static Future<String?> generateThumbnail(String filePath, String fileType) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      
      // 生成缓存文件路径
      final cacheDir = await _getThumbnailCacheDirectory();
      final fileHash = filePath.hashCode.toString();
      final thumbnailPath = '${cacheDir.path}/$fileHash.png';
      final thumbnailFile = File(thumbnailPath);
      
      // 如果缩略图已存在，直接返回
      if (thumbnailFile.existsSync()) {
        return thumbnailPath;
      }
      
      switch (fileType.toLowerCase()) {
        case 'image':
          return await _generateImageThumbnail(filePath, thumbnailPath);
        case 'video':
          return await _generateVideoThumbnail(filePath, thumbnailPath);
        case 'document':
          return await _generateDocumentThumbnail(filePath, thumbnailPath);
        default:
          return null;
      }
    } catch (e) {
      debugPrint('生成缩略图失败: $e');
      return null;
    }
  }
  
  // 获取缩略图缓存目录
  static Future<Directory> _getThumbnailCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_thumbnailCacheDir');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    return cacheDir;
  }
  
  // 生成图片缩略图
  static Future<String?> _generateImageThumbnail(String imagePath, String thumbnailPath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // 解码图片
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: _thumbnailSize,
        targetHeight: _thumbnailSize,
      );
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      
      // 转换为PNG字节
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      
      // 保存缩略图
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());
      
      return thumbnailPath;
    } catch (e) {
      debugPrint('生成图片缩略图失败: $e');
      return null;
    }
  }
  
  // 生成视频缩略图（暂时返回null，可以后续集成video_thumbnail插件）
  static Future<String?> _generateVideoThumbnail(String videoPath, String thumbnailPath) async {
    // TODO: 集成video_thumbnail插件来生成视频缩略图
    return null;
  }
  
  // 生成文档缩略图（创建一个简单的文档图标）
  static Future<String?> _generateDocumentThumbnail(String documentPath, String thumbnailPath) async {
    try {
      // 创建一个简单的文档图标作为缩略图
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(_thumbnailSize.toDouble(), _thumbnailSize.toDouble());
      
      // 绘制背景
      final bgPaint = Paint()..color = Colors.blue.shade50;
      canvas.drawRect(Offset.zero & size, bgPaint);
      
      // 绘制文档图标
      final iconPaint = Paint()
        ..color = Colors.blue.shade600
        ..style = PaintingStyle.fill;
      
      // 绘制简单的文档形状
      final path = Path();
      path.moveTo(size.width * 0.2, size.height * 0.15);
      path.lineTo(size.width * 0.7, size.height * 0.15);
      path.lineTo(size.width * 0.8, size.height * 0.25);
      path.lineTo(size.width * 0.8, size.height * 0.85);
      path.lineTo(size.width * 0.2, size.height * 0.85);
      path.close();
      
      canvas.drawPath(path, iconPaint);
      
      // 绘制折角
      final cornerPath = Path();
      cornerPath.moveTo(size.width * 0.7, size.height * 0.15);
      cornerPath.lineTo(size.width * 0.7, size.height * 0.25);
      cornerPath.lineTo(size.width * 0.8, size.height * 0.25);
      cornerPath.close();
      
      final cornerPaint = Paint()..color = Colors.blue.shade300;
      canvas.drawPath(cornerPath, cornerPaint);
      
      // 转换为图片
      final picture = recorder.endRecording();
      final image = await picture.toImage(_thumbnailSize, _thumbnailSize);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      // 保存缩略图
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(byteData.buffer.asUint8List());
      
      return thumbnailPath;
    } catch (e) {
      debugPrint('生成文档缩略图失败: $e');
      return null;
    }
  }
  
  // 清理缩略图缓存
  static Future<void> clearThumbnailCache() async {
    try {
      final cacheDir = await _getThumbnailCacheDirectory();
      if (cacheDir.existsSync()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('清理缩略图缓存失败: $e');
    }
  }
  
  // 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getThumbnailCacheDirectory();
      if (!cacheDir.existsSync()) return 0;
      
      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('获取缓存大小失败: $e');
      return 0;
    }
  }
  
  // 格式化缓存大小
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}