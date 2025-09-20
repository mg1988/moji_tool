/// 存储统计信息模型类
class StorageStats {
  /// 总文件数
  final int totalFiles;

  /// 总目录数
  final int totalDirectories;

  /// 总大小（字节）
  final int totalSize;

  /// 各类型文件统计
  final Map<String, int> fileTypeStats;

  const StorageStats({
    required this.totalFiles,
    required this.totalDirectories,
    required this.totalSize,
    required this.fileTypeStats,
  });

  /// 获取总大小的友好显示
  String get formattedTotalSize {
    if (totalSize < 0) return '未知';
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    if (totalSize < 1024 * 1024 * 1024) return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 获取指定类型的文件数量
  int getFileCountByType(String fileType) {
    return fileTypeStats[fileType] ?? 0;
  }

  /// 获取指定类型的文件大小统计
  String getFileSizeByType(String fileType) {
    final count = getFileCountByType(fileType);
    if (count == 0) return '0 B';
    
    // 这里需要存储每个类型的总大小才能准确显示
    // 简化处理，只显示数量
    return '$count 个文件';
  }

  @override
  String toString() {
    return 'StorageStats(totalFiles: $totalFiles, totalDirectories: $totalDirectories, totalSize: $formattedTotalSize)';
  }
}