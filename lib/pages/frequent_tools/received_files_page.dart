import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import '../../components/base_tool_page.dart';
import '../../models/received_file.dart';
import '../../utils/received_file_manager.dart';
import '../../utils/file_share_service.dart';
import '../../utils/archive_generator.dart';
import 'file_detail_page.dart';
import '../../components/fullscreen_image_preview.dart';

class ReceivedFilesPage extends StatefulWidget {
  const ReceivedFilesPage({super.key});

  @override
  State<ReceivedFilesPage> createState() => _ReceivedFilesPageState();
}

class _ReceivedFilesPageState extends State<ReceivedFilesPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ReceivedFileManager _fileManager = ReceivedFileManager.instance;
  final FileShareService _shareService = FileShareService();
  
  List<ReceivedFile> _files = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedFiles = {};

  final Map<String, String> _filterLabels = {
    'all': '全部',
    'image': '图片',
    'video': '视频',
    'audio': '音频',
    'document': '文档',
    'archive': '压缩包',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFileManager();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initFileManager() async {
    await _fileManager.initialize();
    _fileManager.addListener(_onFilesChanged);
    _loadFiles();
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _onFilesChanged() {
    if (mounted) {
      _loadFiles();
    }
  }

  void _loadFiles() {
    setState(() {
      _isLoading = true;
    });

    // 添加轻微延迟以显示加载动画
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (_selectedFilter == 'all') {
            _files = _fileManager.files;
          } else {
            _files = _fileManager.getFilesByType(_selectedFilter);
          }
          _isLoading = false;
        });
      }
    });
  }

  void _changeFilter(String filter) {
    if (_selectedFilter != filter) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedFilter = filter;
        _selectedFiles.clear();
        _isSelectionMode = false;
      });
      _loadFiles();
    }
  }

  void _toggleSelectionMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedFiles.clear();
    });
  }

  void _toggleFileSelection(String fileId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedFiles.contains(fileId)) {
        _selectedFiles.remove(fileId);
      } else {
        _selectedFiles.add(fileId);
      }
    });
  }

  void _selectAllFiles() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedFiles.length == _files.length) {
        _selectedFiles.clear();
      } else {
        _selectedFiles.clear();
        _selectedFiles.addAll(_files.map((f) => f.id));
      }
    });
  }

  Future<void> _shareSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    HapticFeedback.lightImpact();
    
    try {
      final filesToShare = _files.where((f) => _selectedFiles.contains(f.id)).toList();
      await _shareService.shareFiles(filesToShare);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已分享 ${filesToShare.length} 个文件'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        setState(() {
          _isSelectionMode = false;
          _selectedFiles.clear();
        });
      }
    } catch (e) {
      _showError('分享失败: $e');
    }
  }

  /// 生成压缩包并分享
  Future<void> _generateAndShareArchive() async {
    if (_selectedFiles.isEmpty) return;

    HapticFeedback.lightImpact();
    
    try {
      final filesToArchive = _files.where((f) => _selectedFiles.contains(f.id)).toList();
      
      if (mounted) {
        // 显示进度对话框
        final archivePath = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _ArchiveProgressDialog(
            files: filesToArchive,
            archiveName: 'files_archive',
          ),
        );
        
        if (archivePath != null) {
          // 创建一个虚拟的ReceivedFile对象用于分享
          final archiveFile = ReceivedFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'files_archive.zip',
            path: archivePath,
            size: File(archivePath).lengthSync(),
            receivedTime: DateTime.now(),
            senderName: '本地生成',
            senderIp: 'local',
            fileType: 'archive',
          );
          
          // 分享压缩包
          await _shareService.shareFiles([archiveFile]);
          
          // 删除临时压缩包文件
          try {
            await File(archivePath).delete();
          } catch (e) {
            debugPrint('删除临时压缩包失败: $e');
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已分享压缩包: ${archiveFile.name}'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            setState(() {
              _isSelectionMode = false;
              _selectedFiles.clear();
            });
          }
        }
      }
    } catch (e) {
      _showError('生成压缩包失败: $e');
    }
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    final confirmed = await _showDeleteConfirmDialog(_selectedFiles.length);
    if (!confirmed) return;

    HapticFeedback.mediumImpact();
    
    try {
      for (final fileId in _selectedFiles) {
        await _fileManager.deleteFile(fileId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除 ${_selectedFiles.length} 个文件'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        setState(() {
          _isSelectionMode = false;
          _selectedFiles.clear();
        });
      }
    } catch (e) {
      _showError('删除失败: $e');
    }
  }

  Future<bool> _showDeleteConfirmDialog(int count) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 $count 个文件吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _shareFile(ReceivedFile file) async {
    HapticFeedback.lightImpact();
    
    try {
      await _shareService.shareFiles([file]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已分享文件: ${file.name}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('分享失败: $e');
    }
  }

  Future<void> _deleteFile(ReceivedFile file) async {
    final confirmed = await _showDeleteConfirmDialog(1);
    if (!confirmed) return;

    HapticFeedback.mediumImpact();
    
    try {
      await _fileManager.deleteFile(file.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除文件: ${file.name}'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('删除失败: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 导入单个文件
  Future<void> _importSingleFile() async {
    try {
      HapticFeedback.lightImpact();
      
      // 使用 file_selector 选择文件
      final file = await openFile();
      if (file == null) return;
      
      await _fileManager.importLocalFile(file.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件导入成功: ${file.name}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('导入文件失败: $e');
    }
  }

  // 导入多个文件
  Future<void> _importMultipleFiles() async {
    try {
      HapticFeedback.lightImpact();
      
      // 使用 file_selector 选择多个文件
      final files = await openFiles();
      if (files.isEmpty) return;
      
      final filePaths = files.map((f) => f.path).toList();
      
      // 显示进度对话框
      if (mounted) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _ImportProgressDialog(filePaths: filePaths),
        );
        
        // 显示结果
        if (result != null && mounted) {
          final successCount = result['successCount'] as int;
          final failCount = result['failCount'] as int;
          final failedFiles = result['failedFiles'] as List<String>;
          
          String message;
          Color backgroundColor;
          
          if (failCount == 0) {
            message = '所有文件导入成功！共 $successCount 个文件';
            backgroundColor = Colors.green.shade600;
          } else if (successCount == 0) {
            message = '所有文件导入失败！共 $failCount 个文件';
            backgroundColor = Colors.red.shade600;
          } else {
            message = '部分文件导入成功！成功: $successCount个，失败: $failCount个';
            backgroundColor = Colors.orange.shade600;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _showError('选择文件失败: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _fileManager.removeListener(_onFilesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '接收文件',
      actions: [
        if (!_isSelectionMode)
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import_single':
                  _importSingleFile();
                  break;
                case 'import_multiple':
                  _importMultipleFiles();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import_single',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 12),
                    Text('导入单个文件'),
                  ],
                ),
              ),
            //   const PopupMenuItem(
            //     value: 'import_multiple',
            //     child: Row(
            //       children: [
            //         Icon(Icons.library_add),
            //         SizedBox(width: 12),
            //         Text('导入多个文件'),
            //       ],
            //     ),
            //   ),
            ],
            icon: const Icon(Icons.add),
            tooltip: '添加本地文件',
          ),
        if (!_isSelectionMode && _files.isNotEmpty)
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.checklist),
            tooltip: '选择文件',
          ),
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectAllFiles,
            icon: Icon(
              _selectedFiles.length == _files.length 
                  ? Icons.deselect 
                  : Icons.select_all,
            ),
            tooltip: _selectedFiles.length == _files.length ? '取消全选' : '全选',
          ),
          IconButton(
            onPressed: _selectedFiles.isNotEmpty ? _generateAndShareArchive : null,
            icon: const Icon(Icons.archive),
            tooltip: '生成压缩包并分享',
          ),
          IconButton(
            onPressed: _selectedFiles.isNotEmpty ? _shareSelectedFiles : null,
            icon: const Icon(Icons.share),
            tooltip: '分享选中',
          ),
          IconButton(
            onPressed: _selectedFiles.isNotEmpty ? _deleteSelectedFiles : null,
            icon: const Icon(Icons.delete),
            tooltip: '删除选中',
          ),
        ],
      ],
      child: Column(
        children: [
          // 统计信息卡片
          _buildStatsCard(),
          const SizedBox(height: 16),
          
          // 筛选器
          _buildFilterTabs(),
          const SizedBox(height: 16),
          
          // 文件列表
          Expanded(
            child: _buildFilesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _fileManager.getFileStats();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade600,
              Colors.purple.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_open,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已接收文件',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats['total']} 个文件 • ${_fileManager.formattedTotalSize}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SlideTransition(
      position: _slideAnimation,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filterLabels.length,
          itemBuilder: (context, index) {
            final filter = _filterLabels.keys.elementAt(index);
            final label = _filterLabels[filter]!;
            final isSelected = _selectedFilter == filter;
            
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _filterLabels.length - 1 ? 0 : 0,
              ),
              child: GestureDetector(
                onTap: () => _changeFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_files.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return _buildFileItem(file, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' ? '暂无接收文件' : '暂无此类型文件',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '使用文件快传功能接收文件，或点击上方"+"按钮导入本地文件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _importSingleFile,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('导入文件'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _importMultipleFiles,
                icon: const Icon(Icons.library_add, size: 20),
                label: const Text('批量导入'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(ReceivedFile file, int index) {
    final isSelected = _selectedFiles.contains(file.id);
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 0.8),
          ((index * 0.1) + 0.2).clamp(0.2, 1.0),
          curve: Curves.easeOut,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleFileSelection(file.id),
                )
              : _buildFileThumbnail(file),
          title: Text(
            file.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  if (file.isLocalImport) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '本地',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      '${file.formattedSize} • 来自 ${file.senderName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${file.receivedTime.year}-${file.receivedTime.month.toString().padLeft(2, '0')}-${file.receivedTime.day.toString().padLeft(2, '0')} '
                '${file.receivedTime.hour.toString().padLeft(2, '0')}:${file.receivedTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          trailing: _isSelectionMode
              ? null
              : PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'share':
                        _shareFile(file);
                        break;
                      case 'delete':
                        _deleteFile(file);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share, size: 20),
                        title: Text('分享'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, size: 20, color: Colors.red),
                        title: Text('删除', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
          onTap: _isSelectionMode
              ? () => _toggleFileSelection(file.id)
              : () => _openFileDetail(file),
        ),
      ),
    );
  }

  // 构建文件缩略图
  Widget _buildFileThumbnail(ReceivedFile file) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildThumbnailContent(file),
      ),
    );
  }

  Widget _buildThumbnailContent(ReceivedFile file) {
    // 如果有缩略图，显示缩略图
    if (file.hasThumbnail) {
      return Image.file(
        File(file.thumbnailPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultThumbnail(file);
        },
      );
    }
    // 如果是图片文件且文件存在，直接显示图片
    else if (file.fileType == 'image' && file.exists) {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultThumbnail(file);
        },
      );
    }
    // 否则显示默认图标
    else {
      return _buildDefaultThumbnail(file);
    }
  }

  Widget _buildDefaultThumbnail(ReceivedFile file) {
    return Center(
      child: Text(
        file.fileIcon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  // 打开文件详情
  void _openFileDetail(ReceivedFile file) {
    HapticFeedback.lightImpact();
    
    // 如果是图片文件，使用全屏预览组件
    if (file.fileType == 'image' && file.exists) {
      FullscreenImagePreview.show(
        context,
        file.path,
        title: file.name,
      );
    } else {
      // 非图片文件使用原来的文件详情页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileDetailPage(file: file),
        ),
      );
    }
  }
}

// 导入进度对话框
class _ImportProgressDialog extends StatefulWidget {
  final List<String> filePaths;
  
  const _ImportProgressDialog({required this.filePaths});
  
  @override
  State<_ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<_ImportProgressDialog> {
  int _currentIndex = 0;
  int _successCount = 0;
  int _failCount = 0;
  bool _isCompleted = false;
  String _currentFileName = '';
  final List<String> _failedFiles = [];
  
  @override
  void initState() {
    super.initState();
    _startImporting();
  }
  
  Future<void> _startImporting() async {
    final fileManager = ReceivedFileManager.instance;
    
    for (int i = 0; i < widget.filePaths.length; i++) {
      final filePath = widget.filePaths[i];
      final fileName = filePath.split('/').last;
      
      setState(() {
        _currentIndex = i;
        _currentFileName = fileName;
      });
      
      try {
        await fileManager.importLocalFile(filePath);
        _successCount++;
      } catch (e) {
        _failCount++;
        _failedFiles.add(fileName);
        debugPrint('导入文件失败 $fileName: $e');
      }
      
      // 模拟进度显示
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    setState(() {
      _isCompleted = true;
    });
    
    // 等待一秒后自动关闭并返回结果
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop({
        'successCount': _successCount,
        'failCount': _failCount,
        'failedFiles': _failedFiles,
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = widget.filePaths.isEmpty ? 0.0 : (_currentIndex + 1) / widget.filePaths.length;
    
    return AlertDialog(
      title: const Text('导入文件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isCompleted) ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 16),
            Text('正在导入: $_currentFileName'),
            const SizedBox(height: 8),
            Text('${_currentIndex + 1} / ${widget.filePaths.length}'),
          ] else ...[
            Icon(
              _failCount == 0 ? Icons.check_circle : Icons.warning,
              size: 48,
              color: _failCount == 0 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '导入完成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('成功: $_successCount 个文件'),
            if (_failCount > 0) Text('失败: $_failCount 个文件'),
            if (_failedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('失败文件:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(_failedFiles.take(3).map((file) => Text('• $file'))),
              if (_failedFiles.length > 3)
                Text('• 及其他 ${_failedFiles.length - 3} 个文件...'),
            ],
          ],
        ],
      ),
      actions: [
        // 自动关闭，不需要手动关闭按钮
      ],
    );
  }
}

// 压缩包生成进度对话框
class _ArchiveProgressDialog extends StatefulWidget {
  final List<ReceivedFile> files;
  final String archiveName;
  
  const _ArchiveProgressDialog({
    required this.files,
    required this.archiveName,
  });
  
  @override
  State<_ArchiveProgressDialog> createState() => _ArchiveProgressDialogState();
}

class _ArchiveProgressDialogState extends State<_ArchiveProgressDialog> {
  double _progress = 0.0;
  String _currentFile = '';
  String? _archivePath;
  bool _isCompleted = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _startArchiving();
  }
  
  Future<void> _startArchiving() async {
    try {
      final path = await ArchiveGenerator.generateArchive(
        widget.files,
        widget.archiveName,
        (progress, currentFile) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _currentFile = currentFile;
            });
          }
        },
      );
      
      if (mounted) {
        setState(() {
          _archivePath = path;
          _isCompleted = true;
          _progress = 1.0;
        });
        
        // 等待一秒后自动关闭并返回结果
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(path);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _progress = -1.0;
        });
        
        // 等待两秒后自动关闭
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('生成压缩包'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isCompleted && !_hasError) ...[
            LinearProgressIndicator(
              value: _progress >= 0 ? _progress : null,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress >= 0 ? Colors.blue.shade600 : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentFile.isNotEmpty)
              Text('正在处理: $_currentFile'),
            const SizedBox(height: 8),
            Text('${( (_progress >= 0 ? _progress : 0) * 100).toStringAsFixed(1)}%'),
          ] else if (_isCompleted) ...[
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              '压缩包生成完成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('文件数量: ${widget.files.length}'),
          ] else if (_hasError) ...[
            const Icon(
              Icons.error,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '生成失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        // 自动关闭，不需要手动关闭按钮
      ],
    );
  }
}
