import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextEncryptionPage extends StatefulWidget {
  const TextEncryptionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextEncryptionPageState createState() => _TextEncryptionPageState();
}

class _TextEncryptionPageState extends State<TextEncryptionPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  String _selectedMethod = 'Base64编码';
  final List<String> _methods = [
    'Base64编码',
    'Base64解码',
    'URL编码',
    'URL解码',
    'SHA256哈希',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _processText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    String result = '';
    try {
      switch (_selectedMethod) {
        case 'Base64编码':
          result = base64Encode(utf8.encode(text));
          break;
        case 'Base64解码':
          result = utf8.decode(base64Decode(text));
          break;
        case 'URL编码':
          result = Uri.encodeFull(text);
          break;
        case 'URL解码':
          result = Uri.decodeFull(text);
          break;
        case 'SHA256哈希':
          final bytes = utf8.encode(text);
          final digest = sha256.convert(bytes);
          result = digest.toString();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理失败: ${e.toString()}')),
      );
      return;
    }

    _outputController.text = result;
  }

  void _clearAll() {
    _inputController.clear();
    _outputController.clear();
    _keyController.clear();
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '文本加密解密',
      child: SingleChildScrollView(
        // 统一页面内边距为12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  items: _methods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value ?? _selectedMethod;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: '选择加密解密方式',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入文本',
              outputLabel: '处理结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                  text: '执行加密/解密',
                  onPressed: _processText,
                )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.secondary(
                  text: '复制结果',
                  onPressed: _copyToClipboard,
                )
                ),
              ],
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            CustomButton.secondary(
              text: '清空所有',
              onPressed: _clearAll,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具提供多种文本加密解密方式，包括Base64编解码、URL编解码和SHA256哈希计算等功能。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}