import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/storage_item.dart';
import '../models/storage_stats.dart';

/// 存储服务类，用于处理存储空间的扫描、统计和管理操作
class StorageService {
  /// 获取应用文档目录路径
  static Future<String> getDocumentsDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// 获取应用临时目录路径
  static Future<String> getTemporaryDirectoryPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// 扫描指定目录下的所有文件和目录
  static Future<List<StorageItem>> scanDirectory(String directoryPath) async {
    final items = <StorageItem>[];
    
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: false)) {
          try {
            final item = StorageItem.fromFileSystemEntity(entity);
            items.add(item);
          } catch (e) {
            debugPrint('扫描文件时出错: ${entity.path}, 错误: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('扫描目录时出错: $directoryPath, 错误: $e');
    }
    
    // 按修改时间排序，最新的在前
    items.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    return items;
  }

  /// 递归扫描目录并计算统计信息
  static Future<StorageStats> calculateStorageStats(String directoryPath) async {
    int totalFiles = 0;
    int totalDirectories = 0;
    int totalSize = 0;
    final fileTypeStats = <String, int>{};

    try {
      await _scanAndCalculateStats(
        directoryPath, 
        (item) {
          if (item.isDirectory) {
            totalDirectories++;
          } else {
            totalFiles++;
            totalSize += item.size;
            
            // 统计文件类型
            fileTypeStats.update(
              item.fileType, 
              (value) => value + 1, 
              ifAbsent: () => 1
            );
          }
        }
      );
    } catch (e) {
      debugPrint('计算存储统计时出错: $directoryPath, 错误: $e');
    }

    return StorageStats(
      totalFiles: totalFiles,
      totalDirectories: totalDirectories,
      totalSize: totalSize,
      fileTypeStats: fileTypeStats,
    );
  }

  /// 递归扫描并计算统计信息的辅助方法
  static Future<void> _scanAndCalculateStats(
    String directoryPath, 
    Function(StorageItem) onItem
  ) async {
    final dir = Directory(directoryPath);
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: false)) {
        try {
          final item = StorageItem.fromFileSystemEntity(entity);
          onItem(item);
          
          // 如果是目录，递归扫描
          if (item.isDirectory) {
            await _scanAndCalculateStats(entity.path, onItem);
          }
        } catch (e) {
          debugPrint('扫描文件时出错: ${entity.path}, 错误: $e');
        }
      }
    }
  }

  /// 搜索文件（按名称）
  static Future<List<StorageItem>> searchFiles(
    String directoryPath, 
    String searchTerm
  ) async {
    final results = <StorageItem>[];
    
    if (searchTerm.isEmpty) {
      return scanDirectory(directoryPath);
    }

    try {
      await _searchRecursive(
        directoryPath, 
        searchTerm.toLowerCase(), 
        results
      );
    } catch (e) {
      debugPrint('搜索文件时出错: $directoryPath, 错误: $e');
    }
    
    return results;
  }

  /// 递归搜索文件的辅助方法
  static Future<void> _searchRecursive(
    String directoryPath, 
    String searchTerm, 
    List<StorageItem> results
  ) async {
    final dir = Directory(directoryPath);
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: false)) {
        try {
          final itemName = entity.path.split(Platform.pathSeparator).last.toLowerCase();
          
          // 匹配文件名
          if (itemName.contains(searchTerm)) {
            final item = StorageItem.fromFileSystemEntity(entity);
            results.add(item);
          }
          
          // 如果是目录，递归搜索
          if (entity is Directory) {
            await _searchRecursive(entity.path, searchTerm, results);
          }
        } catch (e) {
          debugPrint('搜索文件时出错: ${entity.path}, 错误: $e');
        }
      }
    }
  }

  /// 删除文件或目录
  static Future<bool> deleteItem(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      if (entity == FileSystemEntityType.notFound) {
        return true; // 文件不存在，认为删除成功
      }
      
      if (entity == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else {
        await File(path).delete();
      }
      
      return true;
    } catch (e) {
      debugPrint('删除文件时出错: $path, 错误: $e');
      return false;
    }
  }

  /// 批量删除文件或目录
  static Future<int> deleteItems(List<String> paths) async {
    int successCount = 0;
    
    for (final path in paths) {
      if (await deleteItem(path)) {
        successCount++;
      }
    }
    
    return successCount;
  }

  /// 获取目录大小（递归计算）
  static Future<int> getDirectorySize(String directoryPath) async {
    int totalSize = 0;
    
    try {
      await _scanAndCalculateStats(
        directoryPath, 
        (item) {
          if (!item.isDirectory) {
            totalSize += item.size;
          }
        }
      );
    } catch (e) {
      debugPrint('计算目录大小时出错: $directoryPath, 错误: $e');
    }
    
    return totalSize;
  }
}