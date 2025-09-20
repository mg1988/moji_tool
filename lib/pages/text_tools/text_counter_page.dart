import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextCounterPage extends StatefulWidget {
  const TextCounterPage({super.key});

  @override
  _TextCounterPageState createState() => _TextCounterPageState();
}

class _TextCounterPageState extends State<TextCounterPage> {
  final TextEditingController _textController = TextEditingController();
  int _charCount = 0;
  int _wordCount = 0;
  int _lineCount = 0;
  int _sentenceCount = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _countText() {
    final text = _textController.text;
    
    // 字符计数（包括空格和标点）
    final charCount = text.length;
    
    // 单词计数（以空格分隔）
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    final wordCount = words.length;
    
    // 行数
    final lines = text.split('\n');
    final lineCount = lines.length;
    
    // 句子数（简单的句号、问号、感叹号分隔）
    final sentences = text.split(RegExp(r'[.!?]\s+')).where((sentence) => sentence.isNotEmpty).toList();
    final sentenceCount = sentences.length;

    setState(() {
      _charCount = charCount;
      _wordCount = wordCount;
      _lineCount = lineCount;
      _sentenceCount = sentenceCount;
    });
  }

  void _clearText() {
    _textController.clear();
    setState(() {
      _charCount = 0;
      _wordCount = 0;
      _lineCount = 0;
      _sentenceCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '文本计数',
      child: SingleChildScrollView(
        // 统一页面内边距为12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: '输入要统计的文本',
                      labelStyle: AppTextStyles.body,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.primaryBtn),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: AppTextStyles.body,
                    onChanged: (_) => _countText(),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Text('字符数：$_charCount', style: AppTextStyles.body),
                          Text('单词数：$_wordCount', style: AppTextStyles.body),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Text('行数：$_lineCount', style: AppTextStyles.body),
                          Text('句子数：$_sentenceCount', style: AppTextStyles.body),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 减少按钮间距
            const SizedBox(height: 10),
            CustomButton.primary(
              text: '计算',
              onPressed: _countText,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            CustomButton.secondary(
              text: '清空文本',
              onPressed: _clearText,
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
                '此工具可统计文本的字符数、字数、行数、空格数等信息。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}