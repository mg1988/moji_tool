import 'package:flutter/material.dart';
import 'package:pinyin/pinyin.dart';
import '../../utils/pinyin_converter.dart'; // 使用我们自定义的拼音转换工具
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class ChineseToPinyinPage extends StatefulWidget {
  const ChineseToPinyinPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChineseToPinyinPageState createState() => _ChineseToPinyinPageState();
}

class _ChineseToPinyinPageState extends State<ChineseToPinyinPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _withToneMarks = true;
  bool _capitalizeFirstLetter = false;
  String _separator = ' ';

  // 将中文转换为拼音
  void _convertToPinyin() {
    final String input = _inputController.text.trim();
    if (input.isEmpty) {
      _outputController.clear();
      return;
    }

    
    String result =PinyinHelper.getPinyinE(input, separator: _separator, defPinyin: '#', format: _withToneMarks?PinyinFormat.WITH_TONE_MARK:PinyinFormat.WITHOUT_TONE);
    // 首字母大写处理
    if (_capitalizeFirstLetter && result.isNotEmpty) {
      final List<String> words = result.split(_separator);
      for (int i = 0; i < words.length; i++) {
        if (words[i].isNotEmpty) {
          words[i] = words[i][0].toUpperCase() + words[i].substring(1);
        }
      }
      result = words.join(_separator);
    }

    setState(() {
      _outputController.text = result;
    });
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
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '中文转拼音',
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
                  Row(
                    children: [
                      Checkbox(
                        value: _withToneMarks,
                        onChanged: (value) {
                          setState(() {
                            _withToneMarks = value ?? true;
                            if (_inputController.text.isNotEmpty) {
                              _convertToPinyin();
                            }
                          });
                        },
                      ),
                      const Text('显示声调'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _capitalizeFirstLetter,
                        onChanged: (value) {
                          setState(() {
                            _capitalizeFirstLetter = value ?? false;
                            if (_inputController.text.isNotEmpty) {
                              _convertToPinyin();
                            }
                          });
                        },
                      ),
                      const Text('首字母大写'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _separator = value.isEmpty ? ' ' : value;
                        if (_inputController.text.isNotEmpty) {
                          _convertToPinyin();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: '拼音分隔符',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '默认空格',
                    ),
                  ),
                ],
              ),
            ),
            // 减少与卡片间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入中文文本',
              outputLabel: '拼音结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少与按钮间距
            const SizedBox(height: 10),
            CustomButton.primary(
              text: '转换',
              onPressed: _convertToPinyin,
              width: double.infinity,
            ),
            // 减少与信息卡片间距
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '此工具可将中文文本转换为拼音，支持带声调、不带声调和首字母大写等多种格式。适用于中文学习、文字处理等场景。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}