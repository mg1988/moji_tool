import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';
import '../../components/colors.dart';

class Base64ConverterPage extends StatefulWidget {
  const Base64ConverterPage({super.key});

  @override
  State<Base64ConverterPage> createState() => _Base64ConverterPageState();
}

class _Base64ConverterPageState extends State<Base64ConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isEncoding = true;
  String? _imagePreview;
  bool _isImageBase64 = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isEncoding = !_isEncoding;
      // 清空输入输出
      _inputController.clear();
      _outputController.clear();
      _imagePreview = null;
      _isImageBase64 = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _inputController.text = base64String;
          _imagePreview = base64String;
          _isImageBase64 = true;
        });
        _convert();
      }
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  void _convert() {
    setState(() {
      try {
        if (_inputController.text.isEmpty) {
          _outputController.clear();
          _imagePreview = null;
          _isImageBase64 = false;
          return;
        }

        if (_isEncoding) {
          // 编码模式
          final String result = base64Encode(utf8.encode(_inputController.text));
          _outputController.text = result;
          _imagePreview = null;
          _isImageBase64 = false;
        } else {
          // 解码模式
          try {
            final String input = _inputController.text.trim();
            // 尝试解码为文本
            final List<int> decoded = base64Decode(input);
            
            // 检查是否为图片数据
            if (_isImageData(decoded)) {
              _imagePreview = input;
              _isImageBase64 = true;
              _outputController.text = '[图片数据]';
            } else {
              // 尝试解码为文本
              _outputController.text = utf8.decode(decoded);
              _imagePreview = null;
              _isImageBase64 = false;
            }
          } catch (e) {
            _outputController.text = '解码失败: 无效的 Base64 字符串';
            _imagePreview = null;
            _isImageBase64 = false;
          }
        }
      } catch (e) {
        _outputController.text = '转换失败: $e';
        _imagePreview = null;
        _isImageBase64 = false;
      }
    });
  }

  bool _isImageData(List<int> bytes) {
    if (bytes.length < 4) return false;
    
    // 检查常见图片格式的魔数
    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    // PNG
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    // GIF
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
    
    return false;
  }

  void _copyResult() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'Base64 转换',
      child: SingleChildScrollView(
        // 减少页面整体内边距
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeSelector(),
            // 减少卡片间距
            const SizedBox(height: 10),
            _buildInputSection(),
            const SizedBox(height: 10),
            _buildOutputSection(),
            if (_imagePreview != null && _isImageBase64) ...[
              const SizedBox(height: 10),
              _buildImagePreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return ToolCard(
      child: Row(
        children: [
          Text('转换模式：', style: AppTextStyles.caption),
          const SizedBox(width: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('编码'),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('解码'),
              ),
            ],
            selected: {_isEncoding},
            onSelectionChanged: (Set<bool> newValue) {
              _toggleMode();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryBtn;
                }
                return AppColors.white;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return AppColors.textPrimary;
              }),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.border),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEncoding ? '要编码的文本' : '要解码的 Base64',
                style: AppTextStyles.pageTitle,
              ),
              if (!_isEncoding)
                IconButton(
                  icon: const Icon(Icons.image, color: AppColors.primaryBtn),
                  onPressed: _pickImage,
                  tooltip: '选择图片',
                  splashRadius: 20,
                ),
            ],
          ),
          // 减少标签和输入框之间的间距
          const SizedBox(height: 6),
          TextField(
            controller: _inputController,
            maxLines: 5,
            decoration: InputDecoration(
              // 更简约的边框样式
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.primaryBtn),
              ),
              hintText: _isEncoding ? '输入要编码的文本' : '输入要解码的 Base64 字符串',
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: AppTextStyles.body,
            onChanged: (_) => _convert(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return ToolCard(
      // 为输出区域设置轻微不同的背景色，提供视觉区分
      backgroundColor: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEncoding ? 'Base64 结果' : '解码结果',
                style: AppTextStyles.pageTitle,
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: AppColors.primaryBtn),
                onPressed: _copyResult,
                tooltip: '复制结果',
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _outputController,
            maxLines: 5,
            readOnly: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              hintText: '转换结果将显示在这里',
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagePreview == null) return const SizedBox();

    return ToolCard(
      backgroundColor: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '图片预览',
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(
                base64Decode(_imagePreview!),
                height: 180, // 略微减少高度，使布局更紧凑
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('图片加载失败'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
