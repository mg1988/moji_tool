import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'dart:ui' as ui;
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';
import '../dev_tools/qr_style_settings.dart';

class BusinessCardQRPage extends StatefulWidget {
  const BusinessCardQRPage({super.key});

  @override
  State<BusinessCardQRPage> createState() => _BusinessCardQRPageState();
}

class _BusinessCardQRPageState extends State<BusinessCardQRPage> {
  final GlobalKey _qrKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  
  // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  // 样式设置
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  File? _logoFile;
  final double _logoSize = 60;
  QrDataModuleShape _dataModuleShape = QrDataModuleShape.square;
  double _eyeRadius = 0;
  QrEyeShape _eyeShape = QrEyeShape.square;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 生成 vCard 字符串
  String _generateVCard() {
    final vcard = StringBuffer();
    vcard.writeln('BEGIN:VCARD');
    vcard.writeln('VERSION:3.0');
    
    if (_nameController.text.isNotEmpty) {
      vcard.writeln('FN:${_nameController.text}');
      vcard.writeln('N:${_nameController.text};;;;');
    }
    
    if (_companyController.text.isNotEmpty) {
      vcard.writeln('ORG:${_companyController.text}');
    }
    
    if (_jobTitleController.text.isNotEmpty) {
      vcard.writeln('TITLE:${_jobTitleController.text}');
    }
    
    if (_phoneController.text.isNotEmpty) {
      vcard.writeln('TEL;TYPE=CELL:${_phoneController.text}');
    }
    
    if (_emailController.text.isNotEmpty) {
      vcard.writeln('EMAIL:${_emailController.text}');
    }
    
    if (_websiteController.text.isNotEmpty) {
      String website = _websiteController.text;
      if (!website.startsWith('http://') && !website.startsWith('https://')) {
        website = 'https://$website';
      }
      vcard.writeln('URL:$website');
    }
    
    if (_addressController.text.isNotEmpty) {
      vcard.writeln('ADR:;;${_addressController.text};;;;');
    }
    
    if (_noteController.text.isNotEmpty) {
      vcard.writeln('NOTE:${_noteController.text}');
    }
    
    vcard.writeln('END:VCARD');
    return vcard.toString();
  }

  // 检查是否有内容
  bool _hasContent() {
    return _nameController.text.isNotEmpty ||
           _companyController.text.isNotEmpty ||
           _jobTitleController.text.isNotEmpty ||
           _phoneController.text.isNotEmpty ||
           _emailController.text.isNotEmpty ||
           _websiteController.text.isNotEmpty ||
           _addressController.text.isNotEmpty ||
           _noteController.text.isNotEmpty;
  }

  // 选择 Logo
  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  // 移除 Logo
  void _removeLogo() {
    setState(() {
      _logoFile = null;
    });
  }

  // 更新样式
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
        name: "business_card_qr_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('二维码已保存到相册'),
              backgroundColor: AppColors.primary,
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

  // 复制 vCard 内容
  void _copyVCard() {
    final vcard = _generateVCard();
    Clipboard.setData(ClipboardData(text: vcard));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('名片信息已复制到剪贴板'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 构建输入表单
  Widget _buildInputForm() {
    return ToolCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '名片信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // 姓名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名 *',
                hintText: '请输入姓名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 公司
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: '公司/组织',
                hintText: '请输入公司或组织名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 职位
            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: '职位',
                hintText: '请输入职位',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 手机号
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 邮箱
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱地址',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 网站
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: '网站',
                hintText: '请输入网站地址',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 地址
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '地址',
                hintText: '请输入地址',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            // 备注
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '请输入备注信息',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  // 构建二维码显示
  Widget _buildQRCode() {
    if (!_hasContent()) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                '请填写名片信息生成二维码',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: QrImageView(
          data: _generateVCard(),
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
    );
  }

  // 构建操作按钮
  Widget _buildActionButtons() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasContent() ? _saveQRCode : null,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('保存图片'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasContent() ? _copyVCard : null,
                  icon: const Icon(Icons.copy),
                  label: const Text('复制名片'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '名片二维码',
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
              // 输入表单
              _buildInputForm(),
              const SizedBox(height: 16),
              
              // 二维码显示
              ToolCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '二维码预览',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: _buildQRCode()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 样式设置
              QRStyleSettings(
                qrColor: _qrColor,
                backgroundColor: _backgroundColor,
                hasLogo: _logoFile != null,
                dataModuleShape: _dataModuleShape,
                eyeRadius: _eyeRadius,
                eyeShape: _eyeShape,
                onStyleChanged: _updateQRStyle,
                onPickLogo: _pickLogo,
                onRemoveLogo: _removeLogo,
              ),
              const SizedBox(height: 16),
              
              // 操作按钮
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}