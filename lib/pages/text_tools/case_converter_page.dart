import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class CaseConverterPage extends StatefulWidget {
  const CaseConverterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CaseConverterPageState createState() => _CaseConverterPageState();
}

class _CaseConverterPageState extends State<CaseConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convertToUppercase() {
    _outputController.text = _inputController.text.toUpperCase();
  }

  void _convertToLowercase() {
    _outputController.text = _inputController.text.toLowerCase();
  }

  void _convertToTitleCase() {
    final words = _inputController.text.toLowerCase().split(' ');
    final titleCaseWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    _outputController.text = titleCaseWords.join(' ');
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
      title: '文本大小写转换',
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
              outputLabel: '转换结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少按钮组与卡片间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '转换为大写',
                    onPressed: _convertToUppercase,
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.primary(
                    text: '转换为小写',
                    onPressed: _convertToLowercase,
                  )
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '转换为标题格式',
                    onPressed: _convertToTitleCase,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton.secondary(
                    text: '清空全部',
                    onPressed: _clearAll,
                  )
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
                '此工具可将文本转换为大写、小写或标题格式，适用于各种文本编辑场景。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}