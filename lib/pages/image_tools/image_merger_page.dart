import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';
import '../../utils/image_processor.dart';

class ImageMergerPage extends StatefulWidget {
  const ImageMergerPage({super.key});

  @override
  State<ImageMergerPage> createState() => _ImageMergerPageState();
}

class _ImageMergerPageState extends State<ImageMergerPage> {
  List<XFile> _selectedImages = [];
  String _mergeMode = 'horizontal'; // horizontal, vertical
  Uint8List? _mergedImageBytes;
  bool _hasMerged = false;
  int _spacing = 0; // 添加间距参数

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        // 每次添加图片后清空拼接结果
        _mergedImageBytes = null;
        _hasMerged = false;
      });
    }
  }

  Future<void> _mergeImages() async {
    if (_selectedImages.isEmpty) return;

    try {
      // 显示处理中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在拼接图片...')),
      );

      bool isVertical = _mergeMode == 'vertical';
      
      // 使用我们之前实现的 ImageProcessor 来处理图片拼接，传入间距参数
      final mergedBytes = await ImageProcessor.mergeImages(_selectedImages, isVertical, spacing: _spacing);
      
      setState(() {
        _mergedImageBytes = mergedBytes;
        _hasMerged = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片拼接完成')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拼接失败: $e')),
        );
      }
    }
  }

  Future<void> _shareMergedImage() async {
    if (_mergedImageBytes == null) return;

    try {
      // 将处理后的图片保存为临时文件
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/merged_image_$timestamp.jpg');
      await tempFile.writeAsBytes(_mergedImageBytes!);
      
      // 使用 share_extend 分享图片
      await ShareExtend.share(tempFile.path, "image");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已分享')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
    });
  }

  // 新增：清空所有已选图片
  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
      _mergedImageBytes = null;
      _hasMerged = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '图片拼接',
      // 只有执行了拼接动作后才显示分享按钮
      actions: _hasMerged
          ? [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareMergedImage,
              ),
            ]
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 点击区域上传图片（移除了选择图片按钮）
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '点击选择多张图片开始拼接',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 拼接模式选择（只保留水平和垂直拼接）
            if (_selectedImages.isNotEmpty) ...[
              Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '拼接模式',
                          style: AppTextStyles.pageTitle,
                        ),
                        TextButton(
                          onPressed: _clearAllImages,
                          child: const Text('清空图片'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModeButton('horizontal', '水平拼接', Icons.horizontal_rule),
                        _buildModeButton('vertical', '垂直拼接', Icons.vertical_align_bottom),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 添加间距设置
                    Row(
                      children: [
                        const Text('间距: ', style: AppTextStyles.body),
                        Expanded(
                          child: Slider(
                            value: _spacing.toDouble(),
                            min: 0,
                            max: 50,
                            divisions: 50,
                            label: _spacing.toString(),
                            onChanged: (value) {
                              setState(() {
                                _spacing = value.toInt();
                                // 更改间距时清空拼接结果
                                _mergedImageBytes = null;
                                _hasMerged = false;
                              });
                            },
                          ),
                        ),
                        Text('$_spacing px', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 已选图片预览（支持拖拽排序）
              Container(
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
                      '已选图片 (${_selectedImages.length}张)',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: 16),
                    // 水平/垂直拼接模式 - 支持拖拽排序
                    SizedBox(
                      height: 150,
                      child: ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            key: ValueKey(_selectedImages[index].path),
                            margin: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // 拖拽手柄
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.drag_handle,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                // 删除按钮
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                        // 每次删除图片后清空拼接结果
                                        _mergedImageBytes = null;
                                        _hasMerged = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onReorder: _reorderImages,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 修改执行拼接按钮样式：占满一行，黑色背景，白色文字和图标
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black, // 黑色背景
                          foregroundColor: AppColors.white, // 白色文字
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _mergeImages,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.merge_type,
                              color: AppColors.white, // 白色图标
                            ),
                            SizedBox(width: 8),
                            Text(
                              '执行拼接',
                              style: TextStyle(
                                color: AppColors.white, // 白色文字
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 拼接结果预览
              if (_mergedImageBytes != null) ...[
                Container(
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
                        '拼接结果',
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: 16),
                      // 根据拼接模式显示不同的结果
                      if (_mergeMode == 'vertical') ...[
                        // 垂直拼接：宽度为容器宽度，高度自适应
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _mergedImageBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        // 水平拼接：高度为固定值，宽度自适应并允许滚动
                        SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _mergedImageBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 构建拼接模式按钮
  Widget _buildModeButton(String mode, String label, IconData icon) {
    final isSelected = _mergeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // 更换拼接模式时清空拼接内容
            if (_mergeMode != mode) {
              _mergedImageBytes = null;
              _hasMerged = false;
            }
            _mergeMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBtn : AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}