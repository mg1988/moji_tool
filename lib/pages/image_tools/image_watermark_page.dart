import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:image/image.dart' as img;
import 'package:voice_to_text_app/utils/image_processor.dart';

import '../../components/base_tool_page.dart';
import '../../components/colors.dart';

class ImageWatermarkPage extends StatefulWidget {
  const ImageWatermarkPage({super.key});

  @override
  State<ImageWatermarkPage> createState() => _ImageWatermarkPageState();
}

class _ImageWatermarkPageState extends State<ImageWatermarkPage> {
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // 用于Web平台显示图片
  List<WatermarkItem> _watermarkItems = [];
  Uint8List? _watermarkedImageBytes;
  bool _hasWatermarked = false;
  final GlobalKey _imageContainerKey = GlobalKey();
  bool _isWatermarkDoubleTapped = false; // 用于防止双击事件冒泡

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // 读取图片字节数据，用于Web平台显示
      final Uint8List? imageBytes = await image.readAsBytes();
      
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = imageBytes;
        // 清空之前的水印和结果
        _watermarkItems.clear();
        _watermarkedImageBytes = null;
        _hasWatermarked = false;
      });
    }
  }

  void _addWatermark() {
    setState(() {
      _watermarkItems.add(WatermarkItem(
        id: DateTime.now().millisecondsSinceEpoch,
        text: '水印文字',
        position: const Offset(100, 100),
        angle: 0,
        scale: 1.0,
        color: AppColors.black,
        fontSize: 24.0,
        opacity: 0.5,
      ));
    });
  }

  void _addWatermarkAtPosition(Offset position) {
    setState(() {
      _watermarkItems.add(WatermarkItem(
        id: DateTime.now().millisecondsSinceEpoch,
        text: '水印文字',
        position: position,
        angle: 0,
        scale: 1.0,
        color: AppColors.black,
        fontSize: 24.0,
        opacity: 0.5,
      ));
    });
  }

  void _updateWatermark(WatermarkItem? item) {
    // 特殊标记：水印双击事件
    if (item == null) {
      setState(() {
        _isWatermarkDoubleTapped = true;
      });
      return;
    }
    
    // 检查是否是删除操作（通过文本是否为空判断）
    if (item.text.isEmpty) {
      setState(() {
        _watermarkItems.removeWhere((element) => element.id == item.id);
      });
      return;
    }
    
    // 检查是否是复制操作（通过ID是否在现有列表中判断）
    final index = _watermarkItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // 更新现有水印
      setState(() {
        _watermarkItems[index] = item;
      });
    } else {
      // 添加新水印（复制操作）
      setState(() {
        _watermarkItems.add(item);
      });
    }
  }

  void _removeWatermark(WatermarkItem item) {
    setState(() {
      _watermarkItems.removeWhere((element) => element.id == item.id);
    });
  }

  void _duplicateWatermark(WatermarkItem item) {
    setState(() {
      _watermarkItems.add(WatermarkItem(
        id: DateTime.now().millisecondsSinceEpoch,
        text: item.text,
        position: Offset(item.position.dx + 20, item.position.dy + 20),
        angle: item.angle,
        scale: item.scale,
        color: item.color,
        fontSize: item.fontSize,
        opacity: item.opacity,
      ));
    });
  }

  Future<void> _showWatermarkSettings(WatermarkItem item) async {
    await showDialog(
      context: context,
      builder: (context) => WatermarkSettingsDialog(
        item: item,
        onUpdate: _updateWatermark,
      ),
    );
  }

  Future<void> _showGlobalSettings() async {
    // 这里可以实现全局水印设置
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全局设置功能待实现')),
      );
    }
  }

  Future<void> _applyWatermarks() async {
    if (_selectedImage == null || _watermarkItems.isEmpty){
      // 显示处理中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置水印...')),
      );
      return;
    }

    try {
      // 显示处理中提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在处理图片...')),
      );

      // 获取设备像素比，确保高清输出
      final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      // 为确保水印清晰，使用较高的像素比例（至少2.0）
      final double capturePixelRatio = devicePixelRatio > 2.0 ? devicePixelRatio : 2.0;

      // 使用RenderRepaintBoundary捕获当前视图
      RenderRepaintBoundary boundary = _imageContainerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: capturePixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      setState(() {
        _watermarkedImageBytes = pngBytes;
        _hasWatermarked = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('水印已添加')),
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


  Future<void> _shareWatermarkedImage() async {
    if (_watermarkedImageBytes == null) return;

    try {
      // 将处理后的图片保存为临时文件
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/watermarked_image_$timestamp.jpg');
      await tempFile.writeAsBytes(_watermarkedImageBytes!);
      
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
      title: '图片水印',
      actions: [
        // 右上角的按钮根据状态显示不同功能
        if (_hasWatermarked)
          // 更换图片按钮
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          )
        ,
        // 如果有处理结果，显示分享按钮
        if (_hasWatermarked)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWatermarkedImage,
          ),
      ],
      child: Column(
        children: [
          // 图片显示区域 - 解决滚动和手势冲突问题
          Expanded(
            child: _selectedImage != null
                ? RepaintBoundary(
                    key: _imageContainerKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // 如果已经应用了水印，显示预览图；否则显示原图和可编辑水印
                            if (_hasWatermarked && _watermarkedImageBytes != null)
                              Image.memory(
                                _watermarkedImageBytes!,
                                width: constraints.maxWidth,
                                fit: BoxFit.contain,
                              )
                            else
                              GestureDetector(
                                onDoubleTapDown: (details) {
                                  // 检查是否是水印双击事件
                                  if (_isWatermarkDoubleTapped) {
                                    // 重置标志
                                    setState(() {
                                      _isWatermarkDoubleTapped = false;
                                    });
                                    return;
                                  }
                                  // 双击添加水印
                                  _addWatermarkAtPosition(details.localPosition);
                                },
                                child: Stack(
                                  children: [
                                    // 根据平台选择合适的图片加载方式
                                    // Web平台不支持Image.file，使用Image.memory替代
                                    if (kIsWeb && _selectedImageBytes != null)
                                      Image.memory(
                                        _selectedImageBytes!,
                                        width: constraints.maxWidth,
                                        fit: BoxFit.contain,
                                      )
                                    else
                                      // 非Web平台继续使用Image.file
                                      Image.file(
                                        File(_selectedImage!.path),
                                        width: constraints.maxWidth,
                                        fit: BoxFit.contain,
                                      ),
                                    // 水印直接叠放在图片上方
                                    for (final item in _watermarkItems)
                                      WatermarkWidget(
                                        item: item,
                                        onUpdate: _updateWatermark,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  )
                : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: AppColors.textHint,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '点击选择图片开始添加水印',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '操作指引：',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '1. 点击上方选择图片\n'
                              '2. 双击图片添加水印\n'
                              '3. 拖拽移动水印位置\n'
                              '4. 双击水印复制，双指旋转调整角度\n'
                              '5. 单击水印编辑属性\n'
                              '6. 点击底部应用水印',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          // 底部操作按钮
          if (_selectedImage != null && !_hasWatermarked)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
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
                  onPressed: _applyWatermarks,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '应用水印',
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
            ),
        ],
      ),
    );
  }
}

// 水印项数据类
class WatermarkItem {
  final int id;
  final String text;
  final Offset position;
  final double angle;
  final double scale;
  final Color color;
  final double fontSize;
  final double opacity;

  WatermarkItem({
    required this.id,
    required this.text,
    required this.position,
    required this.angle,
    required this.scale,
    required this.color,
    required this.fontSize,
    required this.opacity,
  });

  WatermarkItem copyWith({
    int? id,
    String? text,
    Offset? position,
    double? angle,
    double? scale,
    Color? color,
    double? fontSize,
    double? opacity,
  }) {
    return WatermarkItem(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      angle: angle ?? this.angle,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      opacity: opacity ?? this.opacity,
    );
  }
}

// 水印Widget
class WatermarkWidget extends StatefulWidget {
  final WatermarkItem item;
  final Function(WatermarkItem?) onUpdate;

  const WatermarkWidget({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<WatermarkWidget> createState() => _WatermarkWidgetState();
}

class _WatermarkWidgetState extends State<WatermarkWidget> {
  late WatermarkItem _item;
  late Offset _dragPosition;
  late double _initialAngle;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _dragPosition = _item.position;
    _initialAngle = _item.angle;
  }

  // 添加修改水印属性的方法
  Future<void> _editWatermarkProperties() async {
    await showDialog(
      context: context,
      builder: (context) => WatermarkSettingsDialog(
        item: _item,
        onUpdate: (updatedItem) {
          setState(() {
            _item = updatedItem!;
            widget.onUpdate(_item);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dragPosition.dx,
      top: _dragPosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // 单击编辑水印属性
        onTap: _editWatermarkProperties,
        // 双击复制水印
        onDoubleTapDown: (details) {
          // 阻止事件冒泡到父级组件
          // 通过设置标志来防止父组件的双击事件触发
          widget.onUpdate(null); // 传递null作为特殊标记
          
          final copiedItem = WatermarkItem(
            id: DateTime.now().millisecondsSinceEpoch,
            text: _item.text,
            position: Offset(_dragPosition.dx + 20, _dragPosition.dy + 20),
            angle: _item.angle,
            scale: _item.scale,
            color: _item.color,
            fontSize: _item.fontSize,
            opacity: _item.opacity,
          );
          widget.onUpdate(copiedItem);
        },
        // 禁用onDoubleTap以避免与onDoubleTapDown冲突
        // 使用Scale手势处理拖拽和旋转
        onScaleStart: (details) {
          _initialAngle = _item.angle;
        },
        onScaleUpdate: (details) {
          setState(() {
            // 处理拖拽
            _dragPosition = Offset(
              _dragPosition.dx + details.focalPointDelta.dx,
              _dragPosition.dy + details.focalPointDelta.dy,
            );
            
            // 处理旋转 - 使用正确的旋转计算
            if (details.rotation != 0.0) {
              _item = _item.copyWith(angle: _initialAngle + details.rotation);
            }
            
            // 更新位置
            _item = _item.copyWith(position: _dragPosition);
            widget.onUpdate(_item);
          });
        },
        child: Container(
          color: Colors.transparent, // 透明背景，但确保有足够的点击区域
          padding: const EdgeInsets.all(20), // 增加点击区域
          child: Transform.rotate(
            angle: _item.angle,
            child: Text(
              _item.text,
              style: TextStyle(
                color: _item.color.withOpacity(_item.opacity),
                fontSize: _item.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 水印设置对话框
class WatermarkSettingsDialog extends StatefulWidget {
  final WatermarkItem item;
  final Function(WatermarkItem?) onUpdate;

  const WatermarkSettingsDialog({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<WatermarkSettingsDialog> createState() => _WatermarkSettingsDialogState();
}

class _WatermarkSettingsDialogState extends State<WatermarkSettingsDialog> {
  late WatermarkItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('水印设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '水印文字',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _item.text),
              onChanged: (value) {
                _item = _item.copyWith(text: value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('文字大小:'),
                Expanded(
                  child: Slider(
                    value: _item.fontSize,
                    min: 10,
                    max: 100,
                    divisions: 90,
                    label: _item.fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _item = _item.copyWith(fontSize: value);
                      });
                    },
                  ),
                ),
                Text('${_item.fontSize.round()}'),
              ],
            ),
            Row(
              children: [
                const Text('透明度:'),
                Expanded(
                  child: Slider(
                    value: _item.opacity,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: _item.opacity.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _item = _item.copyWith(opacity: value);
                      });
                    },
                  ),
                ),
                Text(_item.opacity.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('文字颜色:'),
            Wrap(
              spacing: 8,
              children: [
                for (final color in [Colors.white, Colors.black, Colors.red, Colors.blue, Colors.green])
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _item = _item.copyWith(color: color);
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: _item.color == color ? AppColors.primaryBtn : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 删除水印
            widget.onUpdate(_item.copyWith(text: '')); // 通过传递空文本来表示删除
            Navigator.of(context).pop();
          },
          child: const Text('删除'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onUpdate(_item);
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}