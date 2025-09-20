import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class RandomNumberGeneratorPage extends StatefulWidget {
  const RandomNumberGeneratorPage({super.key});

  @override
  State<RandomNumberGeneratorPage> createState() => _RandomNumberGeneratorPageState();
}

class _RandomNumberGeneratorPageState extends State<RandomNumberGeneratorPage> {
  // 随机数类型选择
  String _selectedType = 'integer';
  
  // 整数范围控制器
  final TextEditingController _minIntController = TextEditingController(text: '0');
  final TextEditingController _maxIntController = TextEditingController(text: '100');
  
  // 浮点数范围控制器
  final TextEditingController _minDoubleController = TextEditingController(text: '0.0');
  final TextEditingController _maxDoubleController = TextEditingController(text: '1.0');
  final TextEditingController _decimalPlacesController = TextEditingController(text: '2');
  
  // 字符串控制器
  final TextEditingController _stringLengthController = TextEditingController(text: '10');
  
  // 生成的结果
  String _result = '';
  
  // 字符集选择
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = false;
  
  // 随机数生成器
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRandomNumber();
  }

  // 生成随机数
  void _generateRandomNumber() {
    setState(() {
      switch (_selectedType) {
        case 'integer':
          _generateRandomInteger();
          break;
        case 'double':
          _generateRandomDouble();
          break;
        case 'string':
          _generateRandomString();
          break;
      }
    });
  }

  // 生成随机整数
  void _generateRandomInteger() {
    try {
      int min = int.parse(_minIntController.text);
      int max = int.parse(_maxIntController.text);
      
      if (min > max) {
        // 交换最小值和最大值
        int temp = min;
        min = max;
        max = temp;
        _minIntController.text = min.toString();
        _maxIntController.text = max.toString();
      }
      
      int randomNum = min + _random.nextInt(max - min + 1);
      _result = randomNum.toString();
    } catch (e) {
      _showError('请输入有效的整数范围');
    }
  }

  // 生成随机浮点数
  void _generateRandomDouble() {
    try {
      double min = double.parse(_minDoubleController.text);
      double max = double.parse(_maxDoubleController.text);
      int decimalPlaces = int.parse(_decimalPlacesController.text);
      
      if (decimalPlaces < 0 || decimalPlaces > 10) {
        decimalPlaces = 2;
        _decimalPlacesController.text = '2';
      }
      
      if (min > max) {
        double temp = min;
        min = max;
        max = temp;
        _minDoubleController.text = min.toString();
        _maxDoubleController.text = max.toString();
      }
      
      double randomNum = min + _random.nextDouble() * (max - min);
      _result = randomNum.toStringAsFixed(decimalPlaces);
    } catch (e) {
      _showError('请输入有效的浮点数范围和小数位数');
    }
  }

  // 生成随机字符串
  void _generateRandomString() {
    try {
      int length = int.parse(_stringLengthController.text);
      
      if (length <= 0 || length > 100) {
        length = 10;
        _stringLengthController.text = '10';
      }
      
      // 检查是否至少选择了一个字符集
      if (!_includeUppercase && !_includeLowercase && !_includeNumbers && !_includeSymbols) {
        _showError('请至少选择一个字符集');
        return;
      }
      
      // 构建字符集
      String chars = '';
      if (_includeUppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      if (_includeLowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
      if (_includeNumbers) chars += '0123456789';
      if (_includeSymbols) chars += '!@#\$%^&*()-_=+[]{}|;:,.<>?';
      
      // 生成随机字符串
      StringBuffer result = StringBuffer();
      for (int i = 0; i < length; i++) {
        int randomIndex = _random.nextInt(chars.length);
        result.write(chars[randomIndex]);
      }
      
      _result = result.toString();
    } catch (e) {
      _showError('请输入有效的字符串长度');
    }
  }

  // 复制结果到剪贴板
  void _copyToClipboard() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  // 显示错误信息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 切换随机数类型
  void _changeType(String type) {
    setState(() {
      _selectedType = type;
      _generateRandomNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '随机数生成器',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          // 结果显示卡片
          ToolCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  const Text('生成结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _result,
                        key: ValueKey(_result),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                    [
                      ElevatedButton(
                        onPressed: _copyToClipboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.copy, size: 16),
                            SizedBox(width: 4),
                            Text('复制结果'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _generateRandomNumber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh, size: 16),
                            SizedBox(width: 4),
                            Text('重新生成'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 类型选择
          ToolCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  const Text('选择类型:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                    [
                      _buildTypeButton('随机整数', 'integer'),
                      _buildTypeButton('随机浮点数', 'double'),
                      _buildTypeButton('随机字符串', 'string'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 参数设置卡片
          ToolCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildParameterPanel(),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            ),
          ),

          // 说明卡片
          const ToolCard(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  Text('使用说明:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('1. 选择要生成的随机数类型（整数、浮点数或字符串）'),
                  Text('2. 设置相应的参数（范围、小数位数、字符串长度等）'),
                  Text('3. 点击"重新生成"按钮获取随机结果'),
                  Text('4. 点击"复制结果"按钮将结果复制到剪贴板'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 200,)
        ]),
      ),
    );
  }

  // 构建类型选择按钮
  Widget _buildTypeButton(String label, String type) {
    bool isActive = _selectedType == type;
    
    return ElevatedButton(
      onPressed: () => _changeType(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  // 构建参数设置面板
  Widget _buildParameterPanel() {
    switch (_selectedType) {
      case 'integer':
        return _buildIntegerPanel();
      case 'double':
        return _buildDoublePanel();
      case 'string':
        return _buildStringPanel();
      default:
        return Container();
    }
  }

  // 构建整数参数面板
  Widget _buildIntegerPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        const Text('设置整数范围:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children:
          [
            Expanded(
              child: TextField(
                controller: _minIntController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '最小值',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('到', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxIntController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '最大值',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建浮点数参数面板
  Widget _buildDoublePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        const Text('设置浮点数范围:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children:
          [
            Expanded(
              child: TextField(
                controller: _minDoubleController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '最小值',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('到', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxDoubleController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '最大值',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _decimalPlacesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '小数位数',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // 构建字符串参数面板
  Widget _buildStringPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        const Text('设置字符串选项:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _stringLengthController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '字符串长度',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('包含字符:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children:
          [
            _buildCheckbox('大写字母', _includeUppercase, (value) {
              setState(() => _includeUppercase = value ?? false);
            }),
            _buildCheckbox('小写字母', _includeLowercase, (value) {
              setState(() => _includeLowercase = value ?? false);
            }),
            _buildCheckbox('数字', _includeNumbers, (value) {
              setState(() => _includeNumbers = value ?? false);
            }),
            _buildCheckbox('特殊字符', _includeSymbols, (value) {
              setState(() => _includeSymbols = value ?? false);
            }),
          ],
        ),
      ],
    );
  }

  // 构建复选框
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children:
      [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }

  @override
  void dispose() {
    _minIntController.dispose();
    _maxIntController.dispose();
    _minDoubleController.dispose();
    _maxDoubleController.dispose();
    _decimalPlacesController.dispose();
    _stringLengthController.dispose();
    super.dispose();
  }
}