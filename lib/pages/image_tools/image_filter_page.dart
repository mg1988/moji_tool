import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

import '../../components/base_tool_page.dart';
import '../../components/colors.dart';
import '../../utils/image_processor.dart';

class ImageFilterPage extends StatefulWidget {
  const ImageFilterPage({super.key});

  @override
  State<ImageFilterPage> createState() => _ImageFilterPageState();
}

class _ImageFilterPageState extends State<ImageFilterPage> {
  XFile? _selectedImage;
  String _selectedFilter = '原图';
  Uint8List? _filteredImageBytes;
  bool _isProcessing = false;
  
  // 增加更多滤镜选项
  final List<String> _filters = [
    '原图', '黑白', '复古', '鲜艳', '柔和', '冷色调', '暖色调', '模糊', '锐化', '亮度+', '亮度-', '对比度+', '对比度-'
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _filteredImageBytes = null;
      });
      // 自动应用当前选中的滤镜
      _applyFilter();
    }
  }

  Future<void> _applyFilter() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 应用滤镜处理
      final filteredBytes = await ImageProcessor.applyFilter(_selectedImage!, _selectedFilter);
      
      setState(() {
        _filteredImageBytes = filteredBytes;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('滤镜应用失败: $e')),
        );
      }
    }
  }

  Future<void> _shareFilteredImage() async {
    if (_filteredImageBytes == null) return;

    try {
      // 将处理后的图片保存为临时文件
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/filtered_image_$timestamp.jpg');
      await tempFile.writeAsBytes(_filteredImageBytes!);
      
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

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '图片滤镜',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 点击区域上传图片
                GestureDetector(
                  onTap: _pickImage,
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
                    child: Stack(
                      children: [
                        // 使用Center组件确保占位图和文字居中
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedImage != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Center(
                                    child: _filteredImageBytes != null
                                        ? Image.memory(
                                            _filteredImageBytes!,
                                            height: 180,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.file(
                                            File(_selectedImage!.path),
                                            height: 180,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '请选择一张图片开始应用滤镜',
                                  style: AppTextStyles.caption,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 右上角分享按钮，仅在有处理结果时显示
                        if (_filteredImageBytes != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                onPressed: _shareFilteredImage,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedImage != null) ...[
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
                          '滤镜选择',
                          style: AppTextStyles.pageTitle,
                        ),
                        const SizedBox(height: 16),
                        // 使用网格布局而非水平滚动
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 每行4个滤镜
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.0, // 调整宽高比，使文字更好地显示
                          ),
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            return ChoiceChip(
                              label: Text(
                                _filters[index],
                                style: TextStyle(
                                  color: _selectedFilter == _filters[index] 
                                    ? AppColors.white 
                                    : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14, // 增大字体大小
                                ),
                              ),
                              selected: _selectedFilter == _filters[index],
                              selectedColor: AppColors.primaryBtn,
                              backgroundColor: AppColors.background,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = _filters[index];
                                });
                                // 自动应用滤镜
                                _applyFilter();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 全屏加载圈，防止卡顿
          if (_isProcessing)
            Container(
              color: AppColors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}