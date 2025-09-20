import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/colors.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({Key? key}) : super(key: key);

  @override
  State<JsonFormatterPage> createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  void _formatJson() {
    try {
      // 先解析JSON以验证格式
      final dynamic parsed = json.decode(_inputController.text);
      // 重新格式化JSON，使用2个空格缩进
      final String formatted = const JsonEncoder.withIndent('  ').convert(parsed);
      _outputController.text = formatted;
    } catch (e) {
      _outputController.text = 'JSON格式错误：\n${e.toString()}';
    }
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _clearInput() {
    _inputController.clear();
    _outputController.clear();
  }

  void _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _inputController.text = data!.text!;
      _formatJson();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'JSON格式化',
      actions: [
        IconButton(
          icon: Icon(Icons.paste, color: AppColors.primaryBtn),
          onPressed: _pasteFromClipboard,
          tooltip: '从剪贴板粘贴',
          splashRadius: 20,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: InputOutputCard(
                inputController: _inputController,
                outputController: _outputController,
                inputLabel: '输入JSON',
                outputLabel: '格式化结果',
                onClear: _clearInput,
                onCopy: _copyOutput,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _formatJson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBtn,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('格式化', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
