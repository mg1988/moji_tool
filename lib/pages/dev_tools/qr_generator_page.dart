import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';
import './qr_style_settings.dart';
import './qr_type_selector.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final GlobalKey _qrKey = GlobalKey();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'text';
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  File? _logoFile;
  double _logoSize = 60;
  QrDataModuleShape _dataModuleShape = QrDataModuleShape.square;
  double _eyeRadius = 0;
  QrEyeShape _eyeShape = QrEyeShape.square;

  @override
  void initState() {
    super.initState();
    _loadGlobalSettings();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 加载全局样式设置
  Future<void> _loadGlobalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _qrColor = Color(prefs.getInt('qr_global_color') ?? Colors.black.value);
      _backgroundColor = Color(prefs.getInt('qr_global_bg_color') ?? Colors.white.value);
      _logoSize = prefs.getDouble('qr_global_logo_size') ?? 60;
      final dataShape = prefs.getString('qr_global_data_shape') ?? 'square';
      _dataModuleShape = dataShape == 'circle' ? QrDataModuleShape.circle : QrDataModuleShape.square;
      final eyeShapeStr = prefs.getString('qr_global_eye_shape') ?? 'square';
      _eyeShape = eyeShapeStr == 'circle' ? QrEyeShape.circle : QrEyeShape.square;
    });
  }

  // 保存全局样式设置
  Future<void> _saveGlobalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('qr_global_color', _qrColor.value);
    await prefs.setInt('qr_global_bg_color', _backgroundColor.value);
    await prefs.setDouble('qr_global_logo_size', _logoSize);
    await prefs.setString('qr_global_data_shape', _dataModuleShape == QrDataModuleShape.circle ? 'circle' : 'square');
    await prefs.setString('qr_global_eye_shape', _eyeShape == QrEyeShape.circle ? 'circle' : 'square');
  }

  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _logoFile = null;
    });
  }

  void _updateQRStyle({
    Color? qrColor,
    Color? backgroundColor,
    QrDataModuleShape? dataModuleShape,
    double? eyeRadius,
    QrEyeShape? eyeShape,
  }) {
    setState(() {
      if (qrColor != null) _qrColor = qrColor;
      if (backgroundColor != null) _backgroundColor = backgroundColor;
      if (dataModuleShape != null) _dataModuleShape = dataModuleShape;
      if (eyeRadius != null) _eyeRadius = eyeRadius;
      if (eyeShape != null) _eyeShape = eyeShape;
    });
  }

  // 保存二维码到相册
  Future<void> _saveQRCode() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先输入内容生成二维码'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 获取二维码 widget
      RenderRepaintBoundary boundary = 
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 转换为图片
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      // 使用 image_gallery_saver 保存到相册
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: "qr_code_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('二维码已保存到相册'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: ${result['message'] ?? '未知错误'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 显示全局样式设置弹窗
  void _showGlobalStyleSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('全局样式设置'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: QRStyleSettings(
                    qrColor: _qrColor,
                    backgroundColor: _backgroundColor,
                    hasLogo: _logoFile != null,
                    dataModuleShape: _dataModuleShape,
                    eyeRadius: _eyeRadius,
                    eyeShape: _eyeShape,
                    onStyleChanged: ({
                      Color? qrColor,
                      Color? backgroundColor,
                      QrDataModuleShape? dataModuleShape,
                      double? eyeRadius,
                      QrEyeShape? eyeShape,
                    }) {
                      setState(() {
                        if (qrColor != null) _qrColor = qrColor;
                        if (backgroundColor != null) _backgroundColor = backgroundColor;
                        if (dataModuleShape != null) _dataModuleShape = dataModuleShape;
                        if (eyeRadius != null) _eyeRadius = eyeRadius;
                        if (eyeShape != null) _eyeShape = eyeShape;
                      });
                      setDialogState(() {});
                    },
                    onPickLogo: _pickLogo,
                    onRemoveLogo: _removeLogo,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _saveGlobalSettings();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('全局样式设置已保存'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQRCode() {
    return Center(
      child: Column(
        children: [
          RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: _contentController.text.isEmpty ? 'Hello World!' : _contentController.text,
                version: QrVersions.auto,
                size: 280,
                backgroundColor: _backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: _eyeShape,
                  color: _qrColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: _dataModuleShape,
                  color: _qrColor,
                ),
                embeddedImage: _logoFile != null ? FileImage(_logoFile!) : null,
                embeddedImageStyle: _logoFile != null ? QrEmbeddedImageStyle(
                  size: Size(_logoSize, _logoSize),
                ) : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveQRCode,
            icon: const Icon(Icons.save_alt),
            label: const Text('保存到相册'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '二维码生成',
      actions: [
        IconButton(
          onPressed: _showGlobalStyleSettings,
          icon: const Icon(Icons.settings),
          tooltip: '样式设置',
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QRTypeSelector(
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    _contentController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              ToolCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: _getInputLabel(),
                        border: const OutlineInputBorder(),
                        helperText: _getHelperText(),
                      ),
                      maxLines: null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (_contentController.text.isNotEmpty)
                      _buildQRCode(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInputLabel() {
    switch (_selectedType) {
      case 'website':
        return '网址';
      case 'text':
        return '文本内容';
      case 'vcard':
        return '名片信息';
      default:
        return '内容';
    }
  }

  String _getHelperText() {
    switch (_selectedType) {
      case 'website':
        return '请输入完整的网址，例如：https://www.example.com';
      case 'text':
        return '请输入要转换为二维码的文本内容';
      case 'vcard':
        return '请输入联系人信息';
      default:
        return '';
    }
  }
}
