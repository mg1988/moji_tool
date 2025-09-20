import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextExtractorPage extends StatefulWidget {
  const TextExtractorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextExtractorPageState createState() => _TextExtractorPageState();
}

class _TextExtractorPageState extends State<TextExtractorPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _extractMethod = '提取URL';
  final List<String> _methods = [
    '提取URL',
    '提取邮箱地址',
    '提取数字',
    '提取英文单词',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _extractText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    List<String> results = [];
    
    try {
      switch (_extractMethod) {
        case '提取URL':
          // 简单的URL匹配正则
          final urlRegex = RegExp(r'https?://[^\s]+');
          results = urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
          break;
        case '提取邮箱地址':
          // 简单的邮箱匹配正则
          final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
          results = emailRegex.allMatches(text).map((match) => match.group(0)!).toList();
          break;
        case '提取数字':
          // 提取所有数字
          final numberRegex = RegExp(r'\d+');
          results = numberRegex.allMatches(text).map((match) => match.group(0)!).toList();
          break;
        case '提取英文单词':
          // 提取所有英文单词
          final wordRegex = RegExp(r'\b[a-zA-Z]+\b');
          results = wordRegex.allMatches(text).map((match) => match.group(0)!).toList();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提取失败: ${e.toString()}')),
      );
      return;
    }

    _outputController.text = results.join('\n');
  }

  void _clearAll() {
    _inputController.clear();
    _outputController.clear();
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
      title: '文本提取',
      child: SingleChildScrollView(
        // 统一页面内边距为12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: _extractMethod,
                items: _methods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method, style: TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _extractMethod = value ?? _extractMethod;
                  });
                },
                decoration: InputDecoration(
                  labelText: '选择提取内容',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入文本',
              outputLabel: '提取结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行提取',
                    onPressed: _extractText,
                  )),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.secondary(
                    text: '复制结果',
                    onPressed: _copyToClipboard,
                  )
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomButton.secondary(
                  text: '清空所有',
                  onPressed: _clearAll,
                ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具可帮助您从文本中提取特定内容，包括URL、邮箱地址、数字和英文单词等。',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}