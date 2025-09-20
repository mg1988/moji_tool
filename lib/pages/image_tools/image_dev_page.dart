import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:archive/archive.dart';

import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';
import '../../utils/image_processor.dart';

// 添加用于临时存储生成图片的模型
class GeneratedImage {
  final String name;
  final Uint8List data;

  GeneratedImage(this.name, this.data);
}

class ImageDevPage extends StatefulWidget {
  const ImageDevPage({super.key});

  @override
  State<ImageDevPage> createState() => _ImageDevPageState();
}

class _ImageDevPageState extends State<ImageDevPage> {
  XFile? _selectedImage;
  final List<String> _platforms = ['Android', 'iOS'];
  String _selectedPlatform = 'Android';
  final List<String> _sizes = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
  final Map<String, bool> _selectedSizes = {
    'mdpi': true,
    'hdpi': true,
    'xhdpi': true,
    'xxhdpi': true,
    'xxxhdpi': true,
  };
  Map<String, Uint8List> _devImages = {};
  bool _isGenerating = false;
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _devImages = {}; // 重置生成的图片
      });
    }
  }

  Future<void> _generateDevImages() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先选择图片')),
        );
      }
      return;
    }

    // 获取选中的尺寸
    final selectedSizeList = _selectedSizes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSizeList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请至少选择一个分辨率')),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // 显示进度对话框
      final result = await showDialog<Map<String, Uint8List>?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _GenerationProgressDialog(
          imageFile: _selectedImage!,
          platform: _selectedPlatform,
          sizes: selectedSizeList,
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _devImages = result;
          _isGenerating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('开发图生成完成')),
          );
        }
      } else {
        setState(() {
          _isGenerating = false;
        });
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  Future<void> _saveDevImages() async {
    if (_devImages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先生成开发图')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 请求存储权限
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要存储权限才能保存图片')),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      int savedCount = 0;
      for (final entry in _devImages.entries) {
        final result = await ImageGallerySaver.saveImage(entry.value,
            name: 'dev_${entry.key}_${DateTime.now().millisecondsSinceEpoch}');
        if (result['isSuccess'] == true) {
          savedCount++;
        }
      }

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存$savedCount张开发图到相册')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存过程中出现错误: $e')),
        );
      }
    }
  }

  /// 分享生成的开发图作为压缩包
  Future<void> _shareDevImagesAsArchive() async {
    if (_devImages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先生成开发图')),
        );
      }
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      // 创建临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final archiveDir = Directory('${tempDir.path}/dev_images_$timestamp');
      await archiveDir.create(recursive: true);

      // 将生成的图片保存到临时目录
      final generatedImages = <GeneratedImage>[];
      for (final entry in _devImages.entries) {
        final fileName = 'dev_${entry.key}.png';
        final filePath = '${archiveDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(entry.value);
        generatedImages.add(GeneratedImage(fileName, entry.value));
      }

      // 显示压缩进度对话框，传递临时目录路径
      final archivePath = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ArchiveProgressDialog(
          imageCount: _devImages.length,
          archiveName: 'dev_images',
          tempDirPath: archiveDir.path, // 传递临时目录路径
        ),
      );
      setState(() {
         _isSharing = false;
      });
      if (archivePath != null && mounted) {
        // 创建一个临时文件用于分享
        final tempFile = File(archivePath);

        if (await tempFile.exists()) {
          // 使用 share_extend 分享压缩包
          await ShareExtend.share(archivePath, "file");
         
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('压缩包已分享'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      // 清理临时目录
      try {
        await archiveDir.delete(recursive: true);
      } catch (e) {
        debugPrint('清理临时目录失败: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '开发图生成',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null) ...[
              // 原图预览卡片
              _buildImageCard(
                title: '原图预览',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 设置选项卡片
              _buildSettingsCard(),
              const SizedBox(height: 20),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: _isGenerating
                        ? const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text('生成中...', style: AppTextStyles.caption),
                              ],
                            ),
                          )
                        : CustomButton.secondary(
                            text: '生成开发图',
                            icon: Icons.code,
                            onPressed: _generateDevImages,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isSaving
                        ? const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text('保存中...', style: AppTextStyles.caption),
                              ],
                            ),
                          )
                        : CustomButton.secondary(
                            text: _isSharing ? '打包分享中...' : '打包分享',
                            icon: _isSharing ? null : Icons.archive,
                            onPressed: () => {
                                  // 分享按钮
                                  if (_devImages.isNotEmpty)
                                   {
                                     if (_isSharing == false)
                                        {_shareDevImagesAsArchive()}
                                   }
                                  else
                                    {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('请选择图片...')),
                                    )
                                    }
                                }),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 生成结果预览
              if (_devImages.isNotEmpty) ...[
                _buildImageCard(
                  title: '生成结果',
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _devImages.length,
                    itemBuilder: (context, index) {
                      final entry = _devImages.entries.elementAt(index);
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.memory(
                                  entry.value,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8)),
                              ),
                              child: Text(
                                entry.key,
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ] else ...[
              // 空状态视图 - 可点击选择图片
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '点击选择图片开始生成开发图',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建统一的图片卡片组件
  Widget _buildImageCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// 构建设置选项卡片
  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置选项',
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: 16),
          const Text(
            '平台选择:',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _platforms.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      _platforms[index],
                      style: TextStyle(
                        color: _selectedPlatform == _platforms[index]
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: _selectedPlatform == _platforms[index],
                    selectedColor: AppColors.primaryBtn,
                    backgroundColor: AppColors.background,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPlatform = _platforms[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '分辨率选择:',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sizes.map((size) {
              return ChoiceChip(
                label: Text(
                  size,
                  style: TextStyle(
                    color: (_selectedSizes[size] ?? false)
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: _selectedSizes[size] ?? false,
                selectedColor: AppColors.primaryBtn,
                backgroundColor: AppColors.background,
                onSelected: (selected) {
                  setState(() {
                    _selectedSizes[size] = selected;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// 生成进度对话框
class _GenerationProgressDialog extends StatefulWidget {
  final XFile imageFile;
  final String platform;
  final List<String> sizes;

  const _GenerationProgressDialog({
    required this.imageFile,
    required this.platform,
    required this.sizes,
  });

  @override
  State<_GenerationProgressDialog> createState() =>
      _GenerationProgressDialogState();
}

class _GenerationProgressDialogState extends State<_GenerationProgressDialog> {
  double _progress = 0.0;
  String _currentSize = '';
  Map<String, Uint8List>? _result;
  bool _isCompleted = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    try {
      final result = await ImageProcessor.generateDevImages(
        widget.imageFile,
        widget.platform,
        widget.sizes,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isCompleted = true;
          _progress = 1.0;
        });

        // 等待一秒后自动关闭并返回结果
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(result);
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
      title: const Text('生成开发图'),
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
            Text(_currentSize.isEmpty ? '正在生成...' : '正在生成 $_currentSize'),
            const SizedBox(height: 8),
            Text(
                '${((_progress >= 0 ? _progress : 0) * 100).toStringAsFixed(1)}%'),
          ] else if (_isCompleted) ...[
            const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              '生成完成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('共生成 ${_result?.length ?? 0} 张图片'),
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

// 压缩包生成进度对话框
class _ArchiveProgressDialog extends StatefulWidget {
  final int imageCount;
  final String archiveName;
  final String tempDirPath; // 添加临时目录路径参数

  const _ArchiveProgressDialog({
    required this.imageCount,
    required this.archiveName,
    required this.tempDirPath, // 添加临时目录路径参数
  });

  @override
  State<_ArchiveProgressDialog> createState() => _ArchiveProgressDialogState();
}

class _ArchiveProgressDialogState extends State<_ArchiveProgressDialog> {
  double _progress = 0.0;
  String _status = '准备生成...';
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
      // 创建临时目录用于存储压缩包
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final archivePath = '${tempDir.path}/${widget.archiveName}_$timestamp.zip';
      
      // 创建归档对象
      final archive = Archive();
      
      // 获取临时目录中的所有图片文件
      final tempDirInstance = Directory(widget.tempDirPath);
      if (await tempDirInstance.exists()) {
        final files = tempDirInstance.listSync();
        final totalFiles = files.length;
        
        for (int i = 0; i < totalFiles; i++) {
          final fileEntity = files.elementAt(i);
          if (fileEntity is File) {
            // 更新进度和状态
            _progress = (i + 1) / totalFiles;
            _status = '正在压缩文件...';
            
            if (mounted) {
              setState(() {});
            }
            
            try {
              // 读取文件内容
              final fileContent = await fileEntity.readAsBytes();
              final fileName = fileEntity.uri.pathSegments.last;
              
              // 添加到归档
              archive.addFile(ArchiveFile(fileName, fileContent.length, fileContent));
            } catch (e) {
              debugPrint('读取文件失败 ${fileEntity.path}: $e');
            }
          }
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
      
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _progress = 1.0;
          _status = '压缩包生成完成';
          _archivePath = archivePath;
        });

        // 等待一秒后自动关闭并返回结果
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(archivePath);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _progress = -1.0;
          _status = '生成失败';
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
            Text(_status),
            const SizedBox(height: 8),
            Text(
                '${((_progress >= 0 ? _progress : 0) * 100).toStringAsFixed(1)}%'),
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
            Text('包含 ${widget.imageCount} 张图片'),
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
