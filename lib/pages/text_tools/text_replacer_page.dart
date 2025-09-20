import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextReplacerPage extends StatefulWidget {
  const TextReplacerPage({super.key});

  @override
  _TextReplacerPageState createState() => _TextReplacerPageState();
}

class _TextReplacerPageState extends State<TextReplacerPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _isRegex = false;

  @override
  void dispose() {
    _textController.dispose();
    _findController.dispose();
    _replaceController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _replaceText() {
    final text = _textController.text;
    final find = _findController.text;
    final replace = _replaceController.text;

    if (text.isEmpty || find.isEmpty) return;

    String result;
    if (_isRegex) {
      try {
        result = text.replaceAll(RegExp(find), replace);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正则表达式格式错误')),
        );
        return;
      }
    } else {
      result = text.replaceAll(find, replace);
    }

    _outputController.text = result;
  }

  void _clearAll() {
    _textController.clear();
    _findController.clear();
    _replaceController.clear();
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
      title: '文本替换',
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
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '输入要处理的文本',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _findController,
                          decoration: const InputDecoration(
                            labelText: '查找内容',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('→', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _replaceController,
                          decoration: const InputDecoration(
                            labelText: '替换为',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _isRegex,
                        onChanged: (value) {
                          setState(() {
                            _isRegex = value ?? false;
                          });
                        },
                      ),
                      const Text('使用正则表达式'),
                    ],
                  ),
                ],
              ),
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
              child: TextField(
                controller: _outputController,
                maxLines: 3,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '替换结果',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行替换',
                    onPressed: _replaceText,
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
            const SizedBox(height: 8),
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
                '此工具可帮助您批量替换文本中的特定内容，支持普通文本替换和正则表达式替换。',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}