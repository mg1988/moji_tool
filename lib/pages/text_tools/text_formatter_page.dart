import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextFormatterPage extends StatefulWidget {
  const TextFormatterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextFormatterPageState createState() => _TextFormatterPageState();
}

class _TextFormatterPageState extends State<TextFormatterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  bool _removeExtraSpaces = true;
  bool _trimLines = true;
  bool _normalizeLineBreaks = true;
  bool _removeEmptyLines = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _formatText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    String result = text;
    
    // 去除多余空格
    if (_removeExtraSpaces) {
      // 替换多个连续空格为单个空格
      result = result.replaceAll(RegExp(r'\s+'), ' ');
    }
    
    // 去除每行前后空格
    if (_trimLines) {
      final lines = result.split('\n');
      result = lines.map((line) => line.trim()).join('\n');
    }
    
    // 规范化换行符（统一使用\n）
    if (_normalizeLineBreaks) {
      result = result.replaceAll(RegExp(r'\r\n|\r'), '\n');
    }
    
    // 去除空行
    if (_removeEmptyLines) {
      final lines = result.split('\n');
      result = lines.where((line) => line.isNotEmpty).join('\n');
    }

    _outputController.text = result;
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
      title: '文本格式化',
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
                                value: _removeExtraSpaces,
                                onChanged: (value) {
                                  setState(() {
                                    _removeExtraSpaces = value ?? true;
                                  });
                                },
                              ),
                              const Text('去除多余空格'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _trimLines,
                                onChanged: (value) {
                                  setState(() {
                                    _trimLines = value ?? true;
                                  });
                                },
                              ),
                              const Text('去除行首尾空格'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _normalizeLineBreaks,
                                onChanged: (value) {
                                  setState(() {
                                    _normalizeLineBreaks = value ?? true;
                                  });
                                },
                              ),
                              const Text('规范化换行符'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: _removeEmptyLines,
                                onChanged: (value) {
                                  setState(() {
                                    _removeEmptyLines = value ?? false;
                                  });
                                },
                              ),
                              const Text('去除空行'),
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
              inputLabel: '输入要格式化的文本',
              outputLabel: '格式化结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行格式化',
                    onPressed: _formatText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.secondary(
                    text: '复制结果',
                    onPressed: _copyToClipboard,
                  ),
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
                '此工具可帮助您格式化文本，包括去除多余空格、整理行首尾空格、规范化换行符和去除空行等功能。',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}