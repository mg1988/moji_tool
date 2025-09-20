import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextSorterPage extends StatefulWidget {
  const TextSorterPage({super.key});

  @override
  _TextSorterPageState createState() => _TextSorterPageState();
}

class _TextSorterPageState extends State<TextSorterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _isAscending = true;
  bool _isCaseSensitive = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _sortText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    // 按行分割文本
    final lines = text.split('\n').where((line) => line.isNotEmpty).toList();

    // 排序
    if (_isCaseSensitive) {
      lines.sort(_isAscending ? (a, b) => a.compareTo(b) : (a, b) => b.compareTo(a));
    } else {
      lines.sort(_isAscending 
        ? (a, b) => a.toLowerCase().compareTo(b.toLowerCase()) 
        : (a, b) => b.toLowerCase().compareTo(a.toLowerCase())
      );
    }

    // 将排序后的行重新组合为文本
    _outputController.text = lines.join('\n');
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
      title: '文本排序',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAscending,
                                onChanged: (value) {
                                  setState(() {
                                    _isAscending = value ?? true;
                                  });
                                },
                              ),
                              Text(_isAscending ? '升序排序' : '降序排序'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isCaseSensitive,
                                onChanged: (value) {
                                  setState(() {
                                    _isCaseSensitive = value ?? false;
                                  });
                                },
                              ),
                              const Text('区分大小写'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入文本（每行一条）',
              outputLabel: '排序结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行排序',
                    onPressed: _sortText,
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
                '此工具可帮助您对文本进行排序处理，支持升序和降序排序，以及是否区分大小写的选项。请确保每条内容单独一行。',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}