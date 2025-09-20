import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextSplitterPage extends StatefulWidget {
  const TextSplitterPage({super.key});

  @override
  _TextSplitterPageState createState() => _TextSplitterPageState();
}

class _TextSplitterPageState extends State<TextSplitterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _splitByController = TextEditingController(text: ',');
  final TextEditingController _maxLengthController = TextEditingController(text: '50');

  String _splitMethod = '按分隔符';
  final List<String> _methods = [
    '按分隔符',
    '按固定长度',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _splitByController.dispose();
    _maxLengthController.dispose();
    super.dispose();
  }

  void _splitText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    List<String> result = [];
    
    try {
      if (_splitMethod == '按分隔符') {
        final splitBy = _splitByController.text;
        if (splitBy.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('分隔符不能为空')),
          );
          return;
        }
        result = text.split(splitBy);
      } else {
        final maxLength = int.tryParse(_maxLengthController.text) ?? 50;
        if (maxLength <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('长度必须大于0')),
          );
          return;
        }
        
        for (int i = 0; i < text.length; i += maxLength) {
          final end = i + maxLength > text.length ? text.length : i + maxLength;
          result.add(text.substring(i, end));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分割失败: ${e.toString()}')),
      );
      return;
    }

    _outputController.text = result.join('\n');
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
      title: '文本分割',
      child: SingleChildScrollView(
        // 统一页面内边距为12
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 替换Card为Container并应用统一样式
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
                    value: _splitMethod,
                    items: _methods.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method, style: AppTextStyles.body),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _splitMethod = value ?? _splitMethod;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: '选择分割方式',
                      labelStyle: AppTextStyles.body,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  // 减少间距
                  const SizedBox(height: 10),
                  if (_splitMethod == '按分隔符')
                    TextField(
                      controller: _splitByController,
                      decoration: InputDecoration(
                        labelText: '分隔符',
                        labelStyle: AppTextStyles.body,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                        hintText: '例如：, | ; 等',
                        hintStyle: AppTextStyles.hint,
                      ),
                    )
                  else
                    TextField(
                      controller: _maxLengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '最大长度',
                        labelStyle: AppTextStyles.body,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                        hintText: '输入每个部分的最大字符数',
                        hintStyle: AppTextStyles.hint,
                      ),
                    ),
                ],
              ),
            ),
            // 减少间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入要分割的文本',
              outputLabel: '分割结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行分割',
                    onPressed: _splitText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton.secondary(
                    text: '复制结果',
                    onPressed: _copyToClipboard,
                  ),
                )
              ],
            ),
            // 减少间距
            const SizedBox(height: 8),
            CustomButton.secondary(
                  text: '清空所有',
                  onPressed: _clearAll,
                ),
            // 减少间距
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具可帮助您将长文本按分隔符或固定长度进行分割，方便处理大型文本数据。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}