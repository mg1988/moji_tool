import 'dart:io';

class ReceivedFile {
  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime receivedTime;
  final String senderName;
  final String senderIp;
  final String fileType;
  final String? thumbnailPath; // 缩略图路径

  const ReceivedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.receivedTime,
    required this.senderName,
    required this.senderIp,
    required this.fileType,
    this.thumbnailPath, // 可选缩略图路径
  });

  factory ReceivedFile.fromJson(Map<String, dynamic> json) {
    return ReceivedFile(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      receivedTime: DateTime.fromMillisecondsSinceEpoch(json['receivedTime'] as int),
      senderName: json['senderName'] as String,
      senderIp: json['senderIp'] as String,
      fileType: json['fileType'] as String,
      thumbnailPath: json['thumbnailPath'] as String?, // 缩略图路径
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'receivedTime': receivedTime.millisecondsSinceEpoch,
      'senderName': senderName,
      'senderIp': senderIp,
      'fileType': fileType,
      'thumbnailPath': thumbnailPath, // 缩略图路径
    };
  }

  // 获取文件大小的友好显示
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 获取文件类型图标
  String get fileIcon {
    final extension = name.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return '🖼️';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return '🎥';
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return '🎵';
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      case 'zip':
      case 'rar':
      case '7z':
        return '📦';
      case 'txt':
        return '📋';
      default:
        return '📁';
    }
  }

  // 检查文件是否存在
  bool get exists {
    return File(path).existsSync();
  }

  // 检查是否为本地导入的文件
  bool get isLocalImport {
    return senderName == '本地导入' && senderIp == 'local';
  }

  // 检查是否有缩略图
  bool get hasThumbnail {
    return thumbnailPath != null && File(thumbnailPath!).existsSync();
  }

  // 是否支持缩略图生成
  bool get supportsThumbnail {
    return ['image', 'document'].contains(fileType);
  }

  @override
  String toString() {
    return 'ReceivedFile(id: $id, name: $name, size: $formattedSize, sender: $senderName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReceivedFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}