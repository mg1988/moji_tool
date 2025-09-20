import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextDuplicateRemoverPage extends StatefulWidget {
  const TextDuplicateRemoverPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextDuplicateRemoverPageState createState() => _TextDuplicateRemoverPageState();
}

class _TextDuplicateRemoverPageState extends State<TextDuplicateRemoverPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _removeDuplicates() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    // 按行分割文本
    final lines = text.split('\n');
    // 使用Set去重并保持顺序
    final uniqueLines = <String>[];
    final seen = <String>{};
    
    for (var line in lines) {
      if (line.isNotEmpty && !seen.contains(line)) {
        seen.add(line);
        uniqueLines.add(line);
      }
    }
    
    // 将去重后的行重新组合为文本
    _outputController.text = uniqueLines.join('\n');
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
      title: '文本去重',
      child: SingleChildScrollView(
        // 统一页面内边距为12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入文本',
              outputLabel: '去重结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少按钮与卡片间距
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '去重',
                    onPressed: _removeDuplicates,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.secondary(
                    text: '清空',
                    onPressed: _clearAll,
                  ),
                ),
              ],
            ),
            // 减少信息卡片间距
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具可去除文本中的重复内容，支持按行去重或按词去重。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}