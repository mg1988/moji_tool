import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/received_file.dart';
import 'thumbnail_generator.dart';

class ReceivedFileManager {
  static const String _storageKey = 'received_files';
  static ReceivedFileManager? _instance;
  
  static ReceivedFileManager get instance {
    _instance ??= ReceivedFileManager._();
    return _instance!;
  }
  
  ReceivedFileManager._();
  
  List<ReceivedFile> _files = [];
  final List<VoidCallback> _listeners = [];

  List<ReceivedFile> get files => List.unmodifiable(_files);

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // 初始化，加载已保存的文件列表
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesData = prefs.getStringList(_storageKey) ?? [];
      
      _files = filesData
          .map((data) => ReceivedFile.fromJson(jsonDecode(data)))
          .where((file) => file.exists) // 只保留存在的文件
          .toList();
      
      // 按接收时间倒序排列
      _files.sort((a, b) => b.receivedTime.compareTo(a.receivedTime));
      
      _notifyListeners();
    } catch (e) {
      debugPrint('加载接收文件列表失败: $e');
    }
  }

  // 添加新接收的文件
  Future<void> addReceivedFile(ReceivedFile file) async {
    try {
      debugPrint('添加接收文件: ${file.name}, 路径: ${file.path}, 大小: ${file.formattedSize}');
      _files.insert(0, file); // 插入到列表开头
      await _saveToStorage();
      _notifyListeners();
      debugPrint('接收文件添加成功: ${file.name}');
    } catch (e) {
      debugPrint('添加接收文件失败: $e');
    }
  }

  // 删除文件记录和实际文件
  Future<bool> deleteFile(String fileId) async {
    try {
      final fileIndex = _files.indexWhere((f) => f.id == fileId);
      if (fileIndex == -1) return false;
      
      final file = _files[fileIndex];
      
      // 删除实际文件
      final actualFile = File(file.path);
      if (actualFile.existsSync()) {
        await actualFile.delete();
      }
      
      // 从列表中移除
      _files.removeAt(fileIndex);
      await _saveToStorage();
      _notifyListeners();
      
      debugPrint('删除文件: ${file.name}');
      return true;
    } catch (e) {
      debugPrint('删除文件失败: $e');
      return false;
    }
  }

  // 清理所有文件
  Future<void> clearAllFiles() async {
    try {
      for (final file in _files) {
        final actualFile = File(file.path);
        if (actualFile.existsSync()) {
          try {
            await actualFile.delete();
          } catch (e) {
            debugPrint('删除文件 ${file.name} 失败: $e');
          }
        }
      }
      
      _files.clear();
      await _saveToStorage();
      _notifyListeners();
      
      debugPrint('清理所有接收文件');
    } catch (e) {
      debugPrint('清理文件失败: $e');
    }
  }

  // 获取指定类型的文件
  List<ReceivedFile> getFilesByType(String type) {
    return _files.where((file) {
      final extension = file.name.split('.').last.toLowerCase();
      switch (type.toLowerCase()) {
        case 'image':
          return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
        case 'video':
          return ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv'].contains(extension);
        case 'audio':
          return ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(extension);
        case 'document':
          return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension);
        case 'archive':
          return ['zip', 'rar', '7z', 'tar', 'gz'].contains(extension);
        default:
          return true;
      }
    }).toList();
  }

  // 获取文件统计信息
  Map<String, int> getFileStats() {
    final stats = <String, int>{
      'total': _files.length,
      'image': 0,
      'video': 0,
      'audio': 0,
      'document': 0,
      'archive': 0,
      'other': 0,
    };

    for (final file in _files) {
      final extension = file.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
        stats['image'] = stats['image']! + 1;
      } else if (['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv'].contains(extension)) {
        stats['video'] = stats['video']! + 1;
      } else if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(extension)) {
        stats['audio'] = stats['audio']! + 1;
      } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
        stats['document'] = stats['document']! + 1;
      } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
        stats['archive'] = stats['archive']! + 1;
      } else {
        stats['other'] = stats['other']! + 1;
      }
    }

    return stats;
  }

  // 计算总大小
  int get totalSize {
    return _files.fold(0, (sum, file) => sum + file.size);
  }

  // 获取总大小的友好显示
  String get formattedTotalSize {
    final total = totalSize;
    if (total < 1024) return '$total B';
    if (total < 1024 * 1024) return '${(total / 1024).toStringAsFixed(1)} KB';
    if (total < 1024 * 1024 * 1024) return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 保存到本地存储
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesData = _files.map((file) => jsonEncode(file.toJson())).toList();
      await prefs.setStringList(_storageKey, filesData);
    } catch (e) {
      debugPrint('保存接收文件列表失败: $e');
    }
  }

  // 获取下载目录
  static Future<Directory> getDownloadDirectory() async {
    Directory downloadDir;
    
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      downloadDir = Directory('${externalDir!.path}/Download/FileTransfer');
    } else if (Platform.isIOS) {
      final documentsDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${documentsDir.path}/FileTransfer');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${documentsDir.path}/FileTransfer');
    }
    
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }
    
    return downloadDir;
  }

  // 导入本地文件到文件管理中
  Future<void> importLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('文件不存在');
      }

      // 获取文件信息
      final filename = file.path.split('/').last;
      final fileSize = await file.length();
      final stats = await file.stat();
      final fileType = _getFileType(filename);
      
      // 检查是否已经导入过这个文件
      final existingFiles = _files.where((f) => f.path == filePath);
      if (existingFiles.isNotEmpty) {
        throw Exception('文件已存在于管理列表中');
      }

      // 生成缩略图（在后台异步进行）
      String? thumbnailPath;
      try {
        thumbnailPath = await ThumbnailGenerator.generateThumbnail(filePath, fileType);
      } catch (e) {
        debugPrint('生成缩略图失败: $e');
        // 缩略图生成失败不影响文件导入
      }

      // 创建接收文件记录
      final receivedFile = ReceivedFile(
        id: _generateRandomId(),
        name: filename,
        path: filePath,
        size: fileSize,
        receivedTime: stats.modified,
        senderName: '本地导入',
        senderIp: 'local',
        fileType: fileType,
        thumbnailPath: thumbnailPath,
      );
      
      // 添加到列表
      _files.insert(0, receivedFile);
      await _saveToStorage();
      _notifyListeners();
      
      debugPrint('导入本地文件: $filename');
    } catch (e) {
      debugPrint('导入本地文件失败: $e');
      rethrow;
    }
  }

  // 批量导入本地文件
  Future<List<String>> importMultipleLocalFiles(List<String> filePaths) async {
    final failedFiles = <String>[];
    
    for (final filePath in filePaths) {
      try {
        await importLocalFile(filePath);
      } catch (e) {
        debugPrint('导入文件失败 $filePath: $e');
        failedFiles.add(filePath.split('/').last);
      }
    }
    
    return failedFiles;
  }

  // 生成随机ID
  String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  // 获取文件类型
  String _getFileType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
      return 'document';
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return 'archive';
    } else {
      return 'other';
    }
  }

  // 清理不存在的文件记录
  Future<void> cleanupMissingFiles() async {
    try {
      final existingFiles = _files.where((file) => file.exists).toList();
      if (existingFiles.length != _files.length) {
        _files = existingFiles;
        await _saveToStorage();
        _notifyListeners();
        debugPrint('清理了 ${_files.length - existingFiles.length} 个丢失的文件记录');
      }
    } catch (e) {
      debugPrint('清理丢失文件失败: $e');
    }
  }
}