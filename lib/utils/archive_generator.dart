import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../models/received_file.dart';

class ArchiveGenerator {
  /// 生成压缩包并显示进度
  static Future<String> generateArchive(
    List<ReceivedFile> files,
    String archiveName,
    void Function(double progress, String currentFile)? onProgress,
  ) async {
    try {
      // 创建临时目录用于存储压缩包
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final archivePath = '${tempDir.path}/${archiveName}_$timestamp.zip';
      
      // 创建归档对象
      final archive = Archive();
      
      // 读取文件并添加到归档中
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        
        // 检查文件是否存在
        if (!file.exists) {
          debugPrint('文件不存在，跳过: ${file.name}');
          continue;
        }
        
        // 报告进度
        final progress = (i + 1) / files.length;
        onProgress?.call(progress, file.name);
        
        try {
          // 读取文件内容
          final fileContent = await File(file.path).readAsBytes();
          
          // 添加到归档
          archive.addFile(ArchiveFile(file.name, 1, fileContent));
        } catch (e) {
          debugPrint('读取文件失败 ${file.name}: $e');
          // 继续处理其他文件
        }
      }
      
      // 生成ZIP格式的归档数据
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      
      if (zipData == null) {
        throw Exception('压缩包生成失败');
      }
      
      // 写入文件
      final file = File(archivePath);
      await file.writeAsBytes(Uint8List.fromList(zipData));
      
      // 完成进度报告
      onProgress?.call(1.0, '完成');
      
      return archivePath;
    } catch (e) {
      // 错误进度报告
      onProgress?.call(-1.0, '错误');
      throw Exception('生成压缩包失败: $e');
    }
  }
  
  /// 生成包含进度回调的Future
  static Future<String> generateArchiveWithProgress(
    List<ReceivedFile> files,
    String archiveName,
  ) async {
    final completer = Completer<String>();
    
    unawaited(
      generateArchive(files, archiveName, (progress, currentFile) {
        // 这里可以添加更详细的进度处理逻辑
        debugPrint('压缩进度: ${(progress * 100).toStringAsFixed(1)}% - 当前文件: $currentFile');
      }).then((path) {
        if (!completer.isCompleted) {
          completer.complete(path);
        }
      }).catchError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }),
    );
    
    return completer.future;
  }
}