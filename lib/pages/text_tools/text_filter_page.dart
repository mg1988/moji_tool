import 'package:flutter/material.dart';
import 'package:voice_to_text_app/components/colors.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';

class TextFilterPage extends StatefulWidget {
  const TextFilterPage({super.key});

  @override
  _TextFilterPageState createState() => _TextFilterPageState();
}

class _TextFilterPageState extends State<TextFilterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();

  String _filterMethod = '包含关键词';
  final List<String> _methods = [
    '包含关键词',
    '不包含关键词',
    '以关键词开头',
    '以关键词结尾',
    '正则表达式匹配',
  ];

  bool _matchCase = false;
  bool _wholeWord = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _filterText() {
    final text = _inputController.text;
    final filter = _filterController.text;
    
    if (text.isEmpty || filter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入文本和过滤条件')),
      );
      return;
    }

    final lines = text.split('\n');
    List<String> resultLines = [];
    
    try {
      for (var line in lines) {
        var lineToCheck = line;
        var filterToCheck = filter;
        
        if (!_matchCase) {
          lineToCheck = lineToCheck.toLowerCase();
          filterToCheck = filterToCheck.toLowerCase();
        }
        
        bool shouldKeep = false;
        
        switch (_filterMethod) {
          case '包含关键词':
            if (_wholeWord) {
              final wordRegex = RegExp('\\b$filterToCheck\\b');
              shouldKeep = wordRegex.hasMatch(lineToCheck);
            } else {
              shouldKeep = lineToCheck.contains(filterToCheck);
            }
            break;
          case '不包含关键词':
            if (_wholeWord) {
              final wordRegex = RegExp('\\b$filterToCheck\\b');
              shouldKeep = !wordRegex.hasMatch(lineToCheck);
            } else {
              shouldKeep = !lineToCheck.contains(filterToCheck);
            }
            break;
          case '以关键词开头':
            shouldKeep = lineToCheck.startsWith(filterToCheck);
            break;
          case '以关键词结尾':
            shouldKeep = lineToCheck.endsWith(filterToCheck);
            break;
          case '正则表达式匹配':
            final regex = RegExp(filter, caseSensitive: _matchCase);
            shouldKeep = regex.hasMatch(line);
            break;
        }
        
        if (shouldKeep) {
          resultLines.add(line);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('过滤失败: ${e.toString()}')),
      );
      return;
    }

    _outputController.text = resultLines.join('\n');
  }

  void _clearAll() {
    _inputController.clear();
    _outputController.clear();
    _filterController.clear();
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
      title: '文本过滤',
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _filterMethod,
                    items: _methods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filterMethod = value ?? _filterMethod;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: '过滤方式',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      labelText: _filterMethod == '正则表达式匹配' ? '正则表达式' : '关键词',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(12),
                      hintText: _filterMethod == '正则表达式匹配' ? '输入正则表达式' : '输入过滤关键词',
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _matchCase,
                              onChanged: (value) {
                                setState(() {
                                  _matchCase = value ?? false;
                                });
                              },
                            ),
                            const Text('区分大小写'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _wholeWord,
                              onChanged: (value) {
                                setState(() {
                                  _wholeWord = value ?? false;
                                });
                              },
                            ),
                            const Text('整词匹配'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入文本',
              outputLabel: '过滤结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行过滤',
                    onPressed: _filterText,
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
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '此工具可帮助您根据指定条件过滤文本行，支持包含/不包含关键词、开头/结尾匹配以及正则表达式匹配等多种过滤方式。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}