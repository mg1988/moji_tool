import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';
import '../../utils/image_processor.dart';

class ImageConverterPage extends StatefulWidget {
  const ImageConverterPage({super.key});

  @override
  State<ImageConverterPage> createState() => _ImageConverterPageState();
}

class _ImageConverterPageState extends State<ImageConverterPage> {
  XFile? _selectedImage;
  String _targetFormat = 'jpg';
  Uint8List? _convertedImageBytes;
  bool _isConverting = false;
  bool _isSaving = false;
  bool _isSavingToGallery = false;
  final List<String> _formats = ['jpg', 'png', 'bmp', 'webp'];
  String? _tempImagePath; // 临时图片路径
  double _imageQuality = 90.0; // 图片质量控制

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _convertedImageBytes = null; // 重置转换结果
        _tempImagePath = null; // 重置临时文件路径
      });
    }
  }

  Future<void> _convertImage() async {
    if (_selectedImage == null) return;

    // 显示进度弹窗
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('正在转换...', style: AppTextStyles.caption),
            ],
          ),
        );
      },
    );

    try {
      final convertedBytes = await ImageProcessor.convertFormat(_selectedImage!, _targetFormat, quality: _imageQuality.toInt());
      
      // 关闭进度弹窗
      Navigator.of(context).pop();
      
      setState(() {
        _convertedImageBytes = convertedBytes;
        _isConverting = false;
        _tempImagePath = null; // 重置临时文件路径
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片已成功转换为 $_targetFormat 格式')),
        );
      }
    } catch (e) {
      // 关闭进度弹窗
      Navigator.of(context).pop();
      
      setState(() {
        _isConverting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('转换失败: $e')),
        );
      }
    }
  }

  /// 将 Uint8List 保存为临时文件并返回文件路径
  Future<String> _saveToTempFile(Uint8List bytes, String format) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/converted_image_$timestamp.$format';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<void> _shareConvertedImage() async {
    if (_convertedImageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先执行转换操作')),
        );
      }
      return;
    }

    try {
      // 如果还没有临时文件，创建一个
      if (_tempImagePath == null) {
        _tempImagePath = await _saveToTempFile(_convertedImageBytes!, _targetFormat);
      }
      
      // 使用 share_extend 分享图片文件
      await ShareExtend.share(_tempImagePath!, "image");
    } catch (e) {      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  /// 保存图片到相册
  Future<void> _saveToGallery() async {
    if (_convertedImageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先执行转换操作')),
        );
      }
      return;
    }

    setState(() {
      _isSavingToGallery = true;
    });

    try {
      // 请求存储权限
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要存储权限才能保存图片到相册')),
          );
        }
        setState(() {
          _isSavingToGallery = false;
        });
        return;
      }

      // 保存到相册
      final result = await ImageGallerySaver.saveImage(
        _convertedImageBytes!,
        quality: _imageQuality.toInt(),
        name: "converted_image_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      setState(() {
        _isSavingToGallery = false;
      });

      if (result['isSuccess'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图片已保存到相册')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存到相册失败')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSavingToGallery = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存到相册失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '格式转换',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 点击区域上传/更换图片
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImage!.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.contain,
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
                        '请选择一张图片开始转换',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null) ...[
              // 格式选择卡片
              _buildImageCard(
                title: '选择目标格式',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _formats.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(
                                _formats[index].toUpperCase(),
                                style: TextStyle(
                                  color: _targetFormat == _formats[index] 
                                    ? AppColors.white 
                                    : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: _targetFormat == _formats[index],
                              selectedColor: AppColors.primaryBtn,
                              backgroundColor: AppColors.background,
                              onSelected: (selected) {
                                setState(() {
                                  _targetFormat = _formats[index];
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 图片质量控制滑块
                    Text('图片质量: ${_imageQuality.toInt()}%', style: AppTextStyles.caption),
                    Slider(
                      value: _imageQuality,
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: _imageQuality.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _imageQuality = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton.secondary(
                      text: '执行转换',
                      icon: Icons.transform,
                      onPressed: _convertImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 转换结果卡片
              if (_convertedImageBytes != null) ...[
                _buildImageCard(
                  title: '转换结果',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _convertedImageBytes!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 操作按钮行
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.secondary(
                              text: '分享',
                              icon: Icons.share,
                              onPressed: _shareConvertedImage,
                            ),
                          ),
                        ],
                      ),
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
}