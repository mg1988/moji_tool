import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/input_output_card.dart';
import '../../components/custom_button.dart';
import '../../components/colors.dart';

class NumberToChinesePage extends StatefulWidget {
  const NumberToChinesePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NumberToChinesePageState createState() => _NumberToChinesePageState();
}

class _NumberToChinesePageState extends State<NumberToChinesePage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _useFinancialFormat = false;

  // 将数字转换为中文表示
  void _convertNumber() {
    final String input = _inputController.text.trim();
    if (input.isEmpty) {
      _outputController.clear();
      return;
    }

    try {
      final BigInt number = BigInt.parse(input);
      final String chineseNumber = _numberToChinese(number, _useFinancialFormat);
      setState(() {
        _outputController.text = chineseNumber;
      });
    } catch (e) {
      _outputController.text = '请输入有效的数字';
    }
  }

  // 核心转换逻辑
  String _numberToChinese(BigInt number, bool useFinancialFormat) {
    if (number == BigInt.zero) {
      return '零';
    }

    const List<String> digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    const List<String> units = ['', '十', '百', '千'];
    const List<String> bigUnits = ['', '万', '亿', '兆', '京', '垓', '秭', '穰', '沟', '涧', '正', '载'];
    
    // 财务格式的字符
    const List<String> financialDigits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];
    const List<String> financialUnits = ['', '拾', '佰', '仟'];
    const List<String> financialBigUnits = ['', '万', '亿', '兆', '京', '垓', '秭', '穰', '沟', '涧', '正', '载'];

    final List<String> selectedDigits = useFinancialFormat ? financialDigits : digits;
    final List<String> selectedUnits = useFinancialFormat ? financialUnits : units;
    final List<String> selectedBigUnits = useFinancialFormat ? financialBigUnits : bigUnits;

    String result = '';
    String temp = '';
    int zeroCount = 0;
    int unitIndex = 0;

    while (number > BigInt.zero) {
      final BigInt section = number % BigInt.from(10000);
      number = number ~/ BigInt.from(10000);

      if (section > BigInt.zero) {
        if (zeroCount > 0 && temp.isNotEmpty) {
          temp = selectedDigits[0] + temp;
          zeroCount = 0;
        }
        temp = _convertSection(section, selectedDigits, selectedUnits) + selectedBigUnits[unitIndex] + temp;
      } else {
        zeroCount++;
      }
      unitIndex++;
    }

    // 处理特殊情况：一十 -> 十
    if (!useFinancialFormat && result.startsWith('一') && temp.length > 1 && temp[1] == '十') {
      result = temp.substring(1);
    } else {
      result = temp;
    }

    return result;
  }

  String _convertSection(BigInt section, List<String> digits, List<String> units) {
    String result = '';
    int zeroCount = 0;
    BigInt tempSection = section;

    for (int i = 0; i < 4; i++) {
      final BigInt digit = tempSection % BigInt.from(10);
      tempSection = tempSection ~/ BigInt.from(10);

      if (digit > BigInt.zero) {
        if (zeroCount > 0) {
          result = digits[0] + result;
          zeroCount = 0;
        }
        result = digits[digit.toInt()] + units[i] + result;
      } else {
        zeroCount++;
      }
    }

    return result;
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
      title: '数字转中文',
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
              child: Row(
                children: [
                  Checkbox(
                    value: _useFinancialFormat,
                    onChanged: (value) {
                      setState(() {
                        _useFinancialFormat = value ?? false;
                        if (_inputController.text.isNotEmpty) {
                          _convertNumber();
                        }
                      });
                    },
                  ),
                  const Text('使用财务格式（壹贰叁肆）'),
                ],
              ),
            ),
            // 减少间距
            const SizedBox(height: 10),
            InputOutputCard(
              inputController: _inputController,
              outputController: _outputController,
              inputLabel: '输入数字',
              outputLabel: '中文结果',
              onClear: _clearAll,
              onCopy: _copyToClipboard,
            ),
            // 减少按钮与卡片间距
            const SizedBox(height: 10),
            CustomButton.primary(
              text: '转换',
              onPressed: _convertNumber,
              width: double.infinity,
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
              child: const Text(
                '此工具可将阿拉伯数字转换为中文表示，支持普通格式和财务格式（大写数字）。适用于金额、日期等需要中文数字表示的场景。',
                style: AppTextStyles.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}