import 'dart:io';

/// 存储项模型类，表示单个文件或目录
class StorageItem {
  /// 文件/目录路径
  final String path;

  /// 文件/目录名称
  final String name;

  /// 文件大小（字节），目录为-1
  final int size;

  /// 修改时间
  final DateTime modifiedTime;

  /// 是否为目录
  final bool isDirectory;

  /// 文件类型（用于图标显示）
  final String fileType;

  const StorageItem({
    required this.path,
    required this.name,
    required this.size,
    required this.modifiedTime,
    required this.isDirectory,
    required this.fileType,
  });

  /// 从文件系统实体创建StorageItem
  factory StorageItem.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    final isDir = entity is Directory;
    
    return StorageItem(
      path: entity.path,
      name: entity.path.split(Platform.pathSeparator).last,
      size: isDir ? -1 : stat.size,
      modifiedTime: stat.modified,
      isDirectory: isDir,
      fileType: _getFileType(entity.path, isDir),
    );
  }

  /// 获取文件类型（用于图标显示）
  static String _getFileType(String path, bool isDirectory) {
    if (isDirectory) return 'folder';
    
    try {
      final extension = path.split('.').last.toLowerCase();
      switch (extension) {
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
        case 'bmp':
        case 'webp':
          return 'image';
        case 'mp4':
        case 'avi':
        case 'mov':
        case 'mkv':
        case 'wmv':
          return 'video';
        case 'mp3':
        case 'wav':
        case 'flac':
        case 'aac':
        case 'm4a':
          return 'audio';
        case 'pdf':
          return 'pdf';
        case 'doc':
        case 'docx':
          return 'document';
        case 'xls':
        case 'xlsx':
          return 'spreadsheet';
        case 'ppt':
        case 'pptx':
          return 'presentation';
        case 'zip':
        case 'rar':
        case '7z':
        case 'tar':
        case 'gz':
          return 'archive';
        case 'txt':
        case 'md':
          return 'text';
        default:
          return 'file';
      }
    } catch (e) {
      return 'file';
    }
  }

  /// 获取文件大小的友好显示
  String get formattedSize {
    if (isDirectory) return '文件夹';
    if (size < 0) return '未知';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 获取文件类型图标
  String get fileIcon {
    switch (fileType) {
      case 'folder':
        return '📁';
      case 'image':
        return '🖼️';
      case 'video':
        return '🎥';
      case 'audio':
        return '🎵';
      case 'pdf':
        return '📄';
      case 'document':
        return '📝';
      case 'spreadsheet':
        return '📊';
      case 'presentation':
        return '📽️';
      case 'archive':
        return '📦';
      case 'text':
        return '📋';
      default:
        return '📁';
    }
  }

  /// 检查文件/目录是否存在
  bool get exists {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  @override
  String toString() {
    return 'StorageItem(path: $path, name: $name, size: $formattedSize, isDirectory: $isDirectory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StorageItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}