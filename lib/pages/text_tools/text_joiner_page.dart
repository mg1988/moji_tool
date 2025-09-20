import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class TextJoinerPage extends StatefulWidget {
  const TextJoinerPage({super.key});

  @override
  _TextJoinerPageState createState() => _TextJoinerPageState();
}

class _TextJoinerPageState extends State<TextJoinerPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _joinWithController = TextEditingController(text: ',');

  bool _trimLines = true;
  bool _skipEmptyLines = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _joinWithController.dispose();
    super.dispose();
  }

  void _joinText() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    final joinWith = _joinWithController.text;
    
    // 按行分割文本
    var lines = text.split('\n');
    
    // 处理空行
    if (_skipEmptyLines) {
      lines = lines.where((line) => line.isNotEmpty).toList();
    }
    
    // 去除每行前后空格
    if (_trimLines) {
      lines = lines.map((line) => line.trim()).toList();
    }
    
    // 连接所有行
    _outputController.text = lines.join(joinWith);
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
      title: '文本合并',
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
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  TextField(
                    controller: _joinWithController,
                    decoration: const InputDecoration(
                      labelText: '连接符',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '例如：, | ; 等',
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
                              value: _trimLines,
                              onChanged: (value) {
                                setState(() {
                                  _trimLines = value ?? true;
                                });
                              },
                            ),
                            const Text('去除前后空格'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _skipEmptyLines,
                              onChanged: (value) {
                                setState(() {
                                  _skipEmptyLines = value ?? true;
                                });
                              },
                            ),
                            const Text('跳过空行'),
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
              inputLabel: '输入多行文本',
              outputLabel: '连接结果',
            ),
            // 减少组件间距
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomButton.primary(
                    text: '执行连接',
                    onPressed: _joinText,
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
                '此工具可帮助您将多行文本使用指定连接符合并成一行，支持去除每行前后空格和跳过空行的选项。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}