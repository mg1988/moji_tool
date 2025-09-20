import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextPadderPage extends StatefulWidget {
  const TextPadderPage({super.key});

  @override
  _TextPadderPageState createState() => _TextPadderPageState();
}

class _TextPadderPageState extends State<TextPadderPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _padCharController = TextEditingController(text: ' ');
  final TextEditingController _targetLengthController = TextEditingController(text: '20');

  String _padPosition = '左侧补全';
  final List<String> _positions = [
    '左侧补全',
    '右侧补全',
    '两侧补全',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _padCharController.dispose();
    _targetLengthController.dispose();
    super.dispose();
  }

  void _padText() {
    final text = _inputController.text;
    final padChar = _padCharController.text;
    final targetLength = int.tryParse(_targetLengthController.text) ?? 20;
    
    if (text.isEmpty || padChar.isEmpty || targetLength <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的文本、补全字符和目标长度')),
      );
      return;
    }
    
    if (padChar.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('补全字符只能是单个字符')),
      );
      return;
    }

    String result = text;
    final charToPad = padChar[0];
    
    switch (_padPosition) {
      case '左侧补全':
        if (text.length < targetLength) {
          final padding = List.filled(targetLength - text.length, charToPad).join();
          result = padding + text;
        }
        break;
      case '右侧补全':
        if (text.length < targetLength) {
          final padding = List.filled(targetLength - text.length, charToPad).join();
          result = text + padding;
        }
        break;
      case '两侧补全':
        if (text.length < targetLength) {
          final totalPadding = targetLength - text.length;
          final leftPadding = totalPadding ~/ 2;
          final rightPadding = totalPadding - leftPadding;
          result = List.filled(leftPadding, charToPad).join() + 
                   text + 
                   List.filled(rightPadding, charToPad).join();
        }
        break;
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
      title: '文本补全',
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
                  DropdownButtonFormField<String>(
                    value: _padPosition,
                    items: _positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _padPosition = value ?? _padPosition;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: '补全位置',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _padCharController,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            labelText: '补全字符',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                            hintText: '默认为空格',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _targetLengthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '目标长度',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                            hintText: '输入目标总长度',
                          ),
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
              inputLabel: '输入要补全的文本',
              outputLabel: '补全结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行补全',
                    onPressed: _padText,
                  ),
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
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具可帮助您在文本的左侧、右侧或两侧添加指定字符，使文本达到指定的总长度，常用于对齐和格式化数据。',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}