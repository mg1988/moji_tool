import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double _firstOperand = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;

  void _onDigitPressed(String digit) {
    if (_display == '0' || _shouldResetDisplay) {
      setState(() {
        _display = digit;
        _shouldResetDisplay = false;
      });
    } else {
      setState(() {
        _display += digit;
      });
    }
  }

  void _onDecimalPressed() {
    if (_shouldResetDisplay) {
      setState(() {
        _display = '0.';
        _shouldResetDisplay = false;
      });
    } else if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _onOperatorPressed(String operator) {
    if (_operator.isNotEmpty) {
      _calculate();
    }
    _firstOperand = double.parse(_display);
    _operator = operator;
    _shouldResetDisplay = true;
  }

  void _calculate() {
    if (_operator.isEmpty) return;

    double secondOperand = double.parse(_display);
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand + secondOperand;
        break;
      case '-':
        result = _firstOperand - secondOperand;
        break;
      case '×':
        result = _firstOperand * secondOperand;
        break;
      case '÷':
        if (secondOperand != 0) {
          result = _firstOperand / secondOperand;
        } else {
          // 处理除零错误
          setState(() {
            _display = '错误';
            _operator = '';
            _shouldResetDisplay = true;
          });
          return;
        }
        break;
    }

    // 移除末尾的.0
    String resultStr = result.toString();
    if (resultStr.endsWith('.0')) {
      resultStr = resultStr.substring(0, resultStr.length - 2);
    }

    setState(() {
      _display = resultStr;
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _firstOperand = 0;
      _operator = '';
      _shouldResetDisplay = false;
    });
  }

  void _onDeletePressed() {
    if (_display.length > 1) {
      setState(() {
        _display = _display.substring(0, _display.length - 1);
      });
    } else {
      setState(() {
        _display = '0';
      });
    }
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(80, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '计算器',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 显示区域
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 按钮区域
            Column(
              children: [
                Row(
                  children: [
                    _buildButton('C', Colors.red.shade100, _onClearPressed),
                    _buildButton('DEL', Colors.orange.shade100, _onDeletePressed),
                    _buildButton('%', Colors.blue.shade100, () {}),
                    _buildButton('÷', Colors.blue.shade100, () => _onOperatorPressed('÷')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7', Colors.grey.shade100, () => _onDigitPressed('7')),
                    _buildButton('8', Colors.grey.shade100, () => _onDigitPressed('8')),
                    _buildButton('9', Colors.grey.shade100, () => _onDigitPressed('9')),
                    _buildButton('×', Colors.blue.shade100, () => _onOperatorPressed('×')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4', Colors.grey.shade100, () => _onDigitPressed('4')),
                    _buildButton('5', Colors.grey.shade100, () => _onDigitPressed('5')),
                    _buildButton('6', Colors.grey.shade100, () => _onDigitPressed('6')),
                    _buildButton('-', Colors.blue.shade100, () => _onOperatorPressed('-')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1', Colors.grey.shade100, () => _onDigitPressed('1')),
                    _buildButton('2', Colors.grey.shade100, () => _onDigitPressed('2')),
                    _buildButton('3', Colors.grey.shade100, () => _onDigitPressed('3')),
                    _buildButton('+', Colors.blue.shade100, () => _onOperatorPressed('+')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0', Colors.grey.shade100, () => _onDigitPressed('0')),
                    _buildButton('.', Colors.grey.shade100, _onDecimalPressed),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade100,
                            minimumSize: const Size(160, 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _calculate,
                          child: const Text('='),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}