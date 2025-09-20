import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_to_text_app/models/storage_item.dart';
import 'package:voice_to_text_app/models/storage_stats.dart';
import 'package:voice_to_text_app/utils/storage_service.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'package:voice_to_text_app/utils/file_share_service.dart';
import 'package:voice_to_text_app/utils/archive_generator.dart';
import 'package:voice_to_text_app/models/received_file.dart';
import 'package:voice_to_text_app/components/fullscreen_image_preview.dart';

/// 存储管理页面
class StorageManagerPage extends StatefulWidget {
  const StorageManagerPage({super.key});

  @override
  State<StorageManagerPage> createState() => _StorageManagerPageState();
}

class _StorageManagerPageState extends State<StorageManagerPage> {
  /// 存储项列表
  List<StorageItem> _storageItems = [];

  /// 搜索过滤后的存储项列表
  List<StorageItem> _filteredItems = [];

  /// 存储统计信息
  StorageStats? _storageStats;

  /// 是否正在加载
  bool _isLoading = true;

  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 选中的项目路径集合
  final Set<String> _selectedItems = {};

  /// 是否处于多选模式
  bool _isMultiSelectMode = false;

  /// 文档目录路径
  String? _documentsDirectoryPath;

  /// 当前目录路径
  String? _currentPath;

  @override
  void initState() {
    super.initState();
    _initStorageManager();
  }

  /// 初始化存储管理器
  Future<void> _initStorageManager() async {
    try {
      // 获取文档目录路径
      _documentsDirectoryPath = await StorageService.getDocumentsDirectoryPath();
      // 设置当前目录为文档目录
      _currentPath = _documentsDirectoryPath;
      
      // 加载存储项和统计信息
      await _loadStorageData();
    } catch (e) {
      debugPrint('初始化存储管理器时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初始化失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 加载存储数据（文件列表和统计信息）
  Future<void> _loadStorageData() async {
    if (_currentPath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 并行加载文件列表和统计信息
      final itemsFuture = StorageService.scanDirectory(_currentPath!);
      final statsFuture = StorageService.calculateStorageStats(_currentPath!);
      
      final items = await itemsFuture;
      final stats = await statsFuture;
      
      setState(() {
        _storageItems = items;
        _filteredItems = List.from(items);
        _storageStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载存储数据时出错: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 处理搜索文本变化
  void _onSearchChanged(String value) {
    if (_storageItems.isEmpty) return;
    
    if (value.isEmpty) {
      setState(() {
        _filteredItems = List.from(_storageItems);
      });
    } else {
      final filtered = _storageItems.where((item) {
        return item.name.toLowerCase().contains(value.toLowerCase());
      }).toList();
      
      setState(() {
        _filteredItems = filtered;
      });
    }
  }

  /// 切换多选模式
  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedItems.clear();
      }
    });
  }

  /// 选择/取消选择项目
  void _toggleItemSelected(String path) {
    setState(() {
      if (_selectedItems.contains(path)) {
        _selectedItems.remove(path);
      } else {
        _selectedItems.add(path);
      }
    });
  }

  /// 全选/取消全选
  void _toggleSelectAll() {
    setState(() {
      if (_selectedItems.length == _filteredItems.length) {
        // 当前全选，取消全选
        _selectedItems.clear();
      } else {
        // 当前未全选，全选
        _selectedItems.addAll(_filteredItems.map((item) => item.path));
      }
    });
  }

  /// 删除选中的项目
  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    final confirm = await _showConfirmDialog(
      '删除确认',
      '确定要删除选中的 ${_selectedItems.length} 个项目吗？此操作不可撤销。',
    );

    if (confirm != true) return;

    try {
      final successCount = await StorageService.deleteItems(_selectedItems.toList());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功删除 $successCount 个项目'),
            backgroundColor: successCount > 0 ? AppColors.success : AppColors.error,
          ),
        );
      }
      
      // 重新加载数据
      await _loadStorageData();
      
      // 退出多选模式
      setState(() {
        _isMultiSelectMode = false;
        _selectedItems.clear();
      });
    } catch (e) {
      debugPrint('删除项目时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 分享选中的项目
  Future<void> _shareSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    try {
      // 转换为ReceivedFile对象以便使用现有的分享服务
      final receivedFiles = <ReceivedFile>[];
      
      for (final path in _selectedItems) {
        final file = File(path);
        if (await file.exists()) {
          final stat = await file.stat();
          final name = file.path.split(Platform.pathSeparator).last;
          
          receivedFiles.add(
            ReceivedFile(
              id: path.hashCode.toString(),
              name: name,
              path: path,
              size: stat.size,
              receivedTime: stat.modified,
              senderName: '本地文件',
              senderIp: 'local',
              fileType: _getFileTypeFromPath(path),
            ),
          );
        }
      }
      
      if (receivedFiles.isNotEmpty) {
        final shareService = FileShareService();
        await shareService.shareFiles(receivedFiles);
      }
    } catch (e) {
      debugPrint('分享项目时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 压缩选中的项目
  Future<void> _compressSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    try {
      // 转换为ReceivedFile对象以便使用现有的压缩服务
      final receivedFiles = <ReceivedFile>[];
      
      for (final path in _selectedItems) {
        final file = File(path);
        if (await file.exists()) {
          final stat = await file.stat();
          final name = file.path.split(Platform.pathSeparator).last;
          
          receivedFiles.add(
            ReceivedFile(
              id: path.hashCode.toString(),
              name: name,
              path: path,
              size: stat.size,
              receivedTime: stat.modified,
              senderName: '本地文件',
              senderIp: 'local',
              fileType: _getFileTypeFromPath(path),
            ),
          );
        }
      }
      
      if (receivedFiles.isNotEmpty) {
        // 显示进度对话框
        final progressDialog = _showProgressDialog();
        
        try {
          final archivePath = await ArchiveGenerator.generateArchiveWithProgress(
            receivedFiles,
            '压缩文件_${DateTime.now().millisecondsSinceEpoch}',
          );
          
          // 关闭进度对话框
          if (progressDialog is BuildContext) {
            Navigator.of(progressDialog).pop();
          }
          
          if (mounted) {
            // 显示成功消息和文件路径
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('压缩完成: $archivePath'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          // 关闭进度对话框
          if (progressDialog is BuildContext) {
            Navigator.of(progressDialog).pop();
          }
          
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('压缩项目时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('压缩失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 根据路径获取文件类型
  String _getFileTypeFromPath(String path) {
    final item = StorageItem.fromFileSystemEntity(File(path));
    return item.fileType;
  }

  /// 显示确认对话框
  Future<bool?> _showConfirmDialog(String title, String content) async {
    if (!mounted) return false;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(AppColors.primaryBtn),
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 显示进度对话框
  BuildContext _showProgressDialog() {
    final progressContext = Completer<BuildContext>();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          progressContext.complete(context);
          return const AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBtn),
                ),
                SizedBox(height: 16),
                Text(
                  '正在处理中...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    return progressContext.future as BuildContext;
  }

  /// 构建顶部应用栏
  PreferredSizeWidget _buildAppBar() {
    final isRootDirectory = _documentsDirectoryPath == _currentPath;
    
    return AppBar(
      title: const Text('空间管理'),
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      leading: isRootDirectory
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: Icon(Icons.arrow_upward, color: AppColors.primary),
              onPressed: () {
                // 返回上一级目录
                final parentPath = Directory(_currentPath!).parent.path;
                setState(() {
                  _currentPath = parentPath;
                  _searchController.clear();
                });
                _loadStorageData();
              },
            ),
      actions: [
        // 多选模式下的操作按钮
        if (_isMultiSelectMode) ...[
          IconButton(
            icon: const Icon(Icons.select_all, color: AppColors.primary),
            onPressed: _toggleSelectAll,
            tooltip: '全选',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _deleteSelectedItems,
            tooltip: '删除',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: _shareSelectedItems,
            tooltip: '分享',
          ),
          IconButton(
            icon: const Icon(Icons.archive, color: AppColors.primary),
            onPressed: _compressSelectedItems,
            tooltip: '压缩',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: _toggleMultiSelectMode,
            tooltip: '取消',
          ),
        ] else ...[
          // 普通模式下的操作按钮
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadStorageData,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: AppColors.primary),
            onPressed: _toggleMultiSelectMode,
            tooltip: '多选',
          ),
        ],
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: '搜索文件...',
          hintStyle: AppTextStyles.hint,
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatsCard() {
    if (_storageStats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppCardStyles.featureCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('存储统计', style: AppTextStyles.pageTitle),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('文件', _storageStats!.totalFiles.toString()),
              _buildStatItem('目录', _storageStats!.totalDirectories.toString()),
              _buildStatItem('大小', _storageStats!.formattedTotalSize),
            ],
          ),
          const SizedBox(height: 12),
          // 文件类型统计
          const Text('文件类型分布', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildFileTypeStat('📁 文件夹', _storageStats!.getFileCountByType('folder').toString()),
              _buildFileTypeStat('🖼️ 图片', _storageStats!.getFileCountByType('image').toString()),
              _buildFileTypeStat('🎥 视频', _storageStats!.getFileCountByType('video').toString()),
              _buildFileTypeStat('🎵 音频', _storageStats!.getFileCountByType('audio').toString()),
              _buildFileTypeStat('📄 文档', _storageStats!.getFileCountByType('document').toString()),
              _buildFileTypeStat('📦 压缩包', _storageStats!.getFileCountByType('archive').toString()),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  /// 构建文件类型统计项
  Widget _buildFileTypeStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无文件',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '文档目录中还没有文件',
            style: AppTextStyles.hint,
          ),
        ],
      ),
    );
  }

  /// 构建加载状态视图
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBtn),
          ),
          SizedBox(height: 16),
          Text(
            '正在加载文件...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildStatsCard(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _StorageItemCard(
                              item: item,
                              isSelected: _selectedItems.contains(item.path),
                              isMultiSelectMode: _isMultiSelectMode,
                              onTap: () {
                                if (_isMultiSelectMode) {
                                  _toggleItemSelected(item.path);
                                } else {
                                  // 如果是目录，进入下一级目录
                                  if (item.isDirectory) {
                                    setState(() {
                                      _currentPath = item.path;
                                      _searchController.clear();
                                    });
                                    _loadStorageData();
                                  }
                                  // 如果是图片文件，则显示全屏预览
                                  else if (item.fileType == 'image') {
                                    FullscreenImagePreview.show(
                                      context,
                                      item.path,
                                      title: item.name,
                                    );
                                  }
                                  // TODO: 对于非图片文件，可以打开文件详情或其他操作
                                }
                              },
                              onLongPress: () {
                                if (!_isMultiSelectMode) {
                                  _toggleMultiSelectMode();
                                  _toggleItemSelected(item.path);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 存储项卡片组件
class _StorageItemCard extends StatelessWidget {
  final StorageItem item;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _StorageItemCard({
    required this.item,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 文件图标
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.fileIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // 文件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            item.formattedSize,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateTime(item.modifiedTime),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 多选指示器
                if (isMultiSelectMode) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                ] else ...[
                  // 普通模式下的箭头
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }
}