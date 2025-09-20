import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image/image.dart' as img;

import '../../components/base_tool_page.dart';
import '../../components/colors.dart';

class ImageResizerPage extends StatefulWidget {
  const ImageResizerPage({super.key});

  @override
  State<ImageResizerPage> createState() => _ImageResizerPageState();
}

class _ImageResizerPageState extends State<ImageResizerPage> {
  XFile? _selectedImage;
  double _width = 800;
  double _height = 600;
  bool _maintainAspectRatio = true;
  double _originalWidth = 0;
  double _originalHeight = 0;
  Uint8List? _resizedImageBytes;
  bool _hasResized = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _resizedImageBytes = null;
        _hasResized = false;
      });
      
      // 获取原图尺寸
      _getOriginalImageSize(image);
    }
  }

  Future<void> _getOriginalImageSize(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final imageObj = img.decodeImage(bytes);
      
      if (imageObj != null) {
        setState(() {
          _originalWidth = imageObj.width.toDouble();
          _originalHeight = imageObj.height.toDouble();
          _width = _originalWidth;
          _height = _originalHeight;
        });
      } else {
        // 如果无法解码图片，使用默认值但确保不超过Slider范围
        setState(() {
          _originalWidth = 800.0;
          _originalHeight = 600.0;
          _width = _originalWidth;
          _height = _originalHeight;
        });
      }
    } catch (e) {
      // 如果出现异常，使用默认值但确保不超过Slider范围
      setState(() {
        _originalWidth = 800.0;
        _originalHeight = 600.0;
        _width = _originalWidth;
        _height = _originalHeight;
      });
    }
  }

  Future<void> _resizeImage() async {
    if (_selectedImage == null) return;

    try {
      // 显示处理中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在处理图片...')),
      );

      // 读取图片
      final bytes = await _selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('无法解码图片');
      }
      
      // 调整图片尺寸
      img.Image resizedImage;
      if (_maintainAspectRatio) {
        resizedImage = img.copyResize(image, width: _width.toInt());
      } else {
        resizedImage = img.copyResize(image, width: _width.toInt(), height: _height.toInt());
      }
      
      // 编码为JPEG格式
      final encoded = img.encodeJpg(resizedImage);
      final resizedBytes = Uint8List.fromList(encoded);
      
      setState(() {
        _resizedImageBytes = resizedBytes;
        _hasResized = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片尺寸调整完成')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: $e')),
        );
      }
    }
  }

  Future<void> _shareResizedImage() async {
    if (_resizedImageBytes == null) return;

    try {
      // 将处理后的图片保存为临时文件
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/resized_image_$timestamp.jpg');
      await tempFile.writeAsBytes(_resizedImageBytes!);
      
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
      title: '修改尺寸',
      // 裁剪成功后右上角出现分享按钮
      actions: _hasResized
          ? [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareResizedImage,
              ),
            ]
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 去除选择图片按钮，使用图片占位图，占位图要居中
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_selectedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _resizedImageBytes != null
                              ? Image.memory(
                                  _resizedImageBytes!,
                                  height: 180,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '点击选择图片开始调整尺寸',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
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
                    const Text(
                      '尺寸设置:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('宽度:'),
                        Expanded(
                          child: Slider(
                            value: _width.clamp(100.0, 2000.0),
                            min: 100,
                            max: 2000,
                            divisions: 190,
                            label: _width.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _width = value;
                                if (_maintainAspectRatio && _originalWidth > 0) {
                                  _height = (_width / _originalWidth) * _originalHeight;
                                  // 确保高度也在有效范围内
                                  _height = _height.clamp(100.0, 2000.0);
                                }
                                // 每次调整参数后清空裁剪结果
                                _resizedImageBytes = null;
                                _hasResized = false;
                              });
                            },
                          ),
                        ),
                        Text('${_width.round()}px'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('高度:'),
                        Expanded(
                          child: Slider(
                            value: _height.clamp(100.0, 2000.0),
                            min: 100,
                            max: 2000,
                            divisions: 190,
                            label: _height.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _height = value;
                                if (_maintainAspectRatio && _originalHeight > 0) {
                                  _width = (_height / _originalHeight) * _originalWidth;
                                  // 确保宽度也在有效范围内
                                  _width = _width.clamp(100.0, 2000.0);
                                }
                                // 每次调整参数后清空裁剪结果
                                _resizedImageBytes = null;
                                _hasResized = false;
                              });
                            },
                          ),
                        ),
                        Text('${_height.round()}px'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('保持宽高比:'),
                        Switch(
                          value: _maintainAspectRatio,
                          onChanged: (value) {
                            setState(() {
                              _maintainAspectRatio = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _resizeImage,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_size_select_large,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '调整尺寸',
                              style: TextStyle(
                                color: AppColors.white,
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
            ],
          ],
        ),
      ),
    );
  }
}