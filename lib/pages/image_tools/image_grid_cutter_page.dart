import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image/image.dart' as img;
import '../../utils/image_processor.dart';

import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class ImageGridCutterPage extends StatefulWidget {
  const ImageGridCutterPage({super.key});

  @override
  State<ImageGridCutterPage> createState() => _ImageGridCutterPageState();
}

class _ImageGridCutterPageState extends State<ImageGridCutterPage> {
  XFile? _selectedImage;
  List<XFile> _gridImages = [];
  int _rows = 3;
  int _columns = 3;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _gridImages = [];
      });
      _cutImageToGrid();
    }
  }

  Future<void> _cutImageToGrid() async {
    if (_selectedImage == null) return;

    try {
      // 显示处理中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在处理图片...')),
      );

      // 使用我们之前实现的 ImageProcessor 来处理九宫格切图
      final gridImages = await ImageProcessor.gridCut(_selectedImage!, _rows, _columns);
      
      // 将 Uint8List 转换为 XFile 格式用于显示
      final List<XFile> xFiles = [];
      for (int i = 0; i < gridImages.length; i++) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/grid_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await file.writeAsBytes(gridImages[i]);
        xFiles.add(XFile(file.path));
      }
      
      setState(() {
        _gridImages = xFiles;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('九宫格切图完成')),
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

  /// 分享所有图片
  Future<void> _shareAllImages() async {
    if (_gridImages.isEmpty) return;

    try {
      // 收集所有图片路径
      final List<String> imagePaths = [];
      for (var i = 0; i < _gridImages.length; i++) {
        imagePaths.add(_gridImages[i].path);
      }

      // 使用 share_extend 分享多张图片
      await ShareExtend.shareMultiple(imagePaths, "image");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已分享')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享过程中出现错误: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '九宫格切图',
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
                        '请选择一张图片开始切图',
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
                      '参数设置',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('行数', style: AppTextStyles.caption),
                            DropdownButton<int>(
                              value: _rows,
                              items: List.generate(5, (index) => index + 1)
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('$e'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _rows = value!;
                                  _cutImageToGrid();
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('列数', style: AppTextStyles.caption),
                            DropdownButton<int>(
                              value: _columns,
                              items: List.generate(5, (index) => index + 1)
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text('$e'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _columns = value!;
                                  _cutImageToGrid();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_gridImages.isNotEmpty) ...[
                Text(
                  '九宫格预览',
                  style: AppTextStyles.pageTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
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
                    children: [
                      // 使用自定义的网格布局来确保按比例显示
                      _buildGridPreview(),
                      const SizedBox(height: 20),
                      Center(
                        // 移除了加载圈，直接显示分享按钮
                        child: CustomButton.secondary(
                          text: '分享所有图片',
                          icon: Icons.share,
                          onPressed: _shareAllImages,
                        ),
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

  /// 构建按比例显示的网格预览
  Widget _buildGridPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<Size>(
          future: _getImageOriginalSize(_selectedImage!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final originalSize = snapshot.data!;
              // 计算原始图片的宽高比
              final originalAspectRatio = originalSize.width / originalSize.height;
              
              // 计算每个格子的理论宽高比
              final cellAspectRatio = originalAspectRatio * _columns / _rows;
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: cellAspectRatio,
                ),
                itemCount: _gridImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedBorderPainter(),
                      child: Image.file(
                        File(_gridImages[index].path),
                        // 使用 contain 模式确保图片完整显示并按比例缩放
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            } else {
              // 如果无法获取原始尺寸，使用默认的网格
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1.0,
                ),
                itemCount: _gridImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedBorderPainter(),
                      child: Image.file(
                        File(_gridImages[index].path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  /// 获取图片的原始尺寸
  Future<Size> _getImageOriginalSize(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      return Size(image.width.toDouble(), image.height.toDouble());
    } else {
      // 如果无法解码图片，返回默认尺寸
      return const Size(1.0, 1.0);
    }
  }
}

// 虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 3.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
          Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}