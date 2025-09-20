import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  String _fromCurrency = 'CNY';
  String _toCurrency = 'USD';
  double _inputAmount = 0;
  double _convertedAmount = 0;
  TextEditingController _inputController = TextEditingController();

  // 模拟汇率数据（以人民币为基准）
  Map<String, double> _exchangeRates = {
    'CNY': 1.0, // 人民币
    'USD': 0.14, // 美元
    'EUR': 0.13, // 欧元
    'JPY': 20.0, // 日元
    'GBP': 0.11, // 英镑
    'AUD': 0.21, // 澳元
    'CAD': 0.19, // 加元
    'CHF': 0.13, // 瑞士法郎
    'HKD': 1.09, // 港币
    'SGD': 0.19, // 新加坡元
  };

  // 货币信息
  final Map<String, Map<String, String>> _currencyInfo = {
    'CNY': {'name': '人民币', 'symbol': '¥'},
    'USD': {'name': '美元', 'symbol': '\$'},
    'EUR': {'name': '欧元', 'symbol': '€'},
    'JPY': {'name': '日元', 'symbol': '¥'},
    'GBP': {'name': '英镑', 'symbol': '£'},
    'AUD': {'name': '澳元', 'symbol': 'A\$'},
    'CAD': {'name': '加元', 'symbol': 'C\$'},
    'CHF': {'name': '瑞士法郎', 'symbol': 'CHF'},
    'HKD': {'name': '港币', 'symbol': 'HK\$'},
    'SGD': {'name': '新加坡元', 'symbol': 'S\$'},
  };

  @override
  void initState() {
    super.initState();
    _inputController.text = '100';
    _updateConversion();
  }

  void _updateConversion() {
    try {
      _inputAmount = double.parse(_inputController.text);
      _convertCurrency();
    } catch (e) {
      setState(() {
        _convertedAmount = 0;
      });
    }
  }

  void _convertCurrency() {
    // 先将输入货币转换为人民币
    double amountInCNY = _inputAmount / _exchangeRates[_fromCurrency]!;
    // 再将人民币转换为目标货币
    double convertedAmount = amountInCNY * _exchangeRates[_toCurrency]!;
    
    setState(() {
      _convertedAmount = convertedAmount;
    });
  }

  void _swapCurrencies() {
    setState(() {
      final tempCurrency = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tempCurrency;
      _convertCurrency();
    });
  }

  void _updateRates() {
    // 模拟更新汇率
    // 在实际应用中，这里应该调用API获取最新汇率
    setState(() {
      // 随机微调汇率以模拟更新
      _exchangeRates = _exchangeRates.map((key, value) {
        if (key != 'CNY') { // 保持人民币为基准
          double change = (1 + (0.1 - 0.2 * (value % 1))); // 简单的随机变化
          return MapEntry(key, value * change);
        }
        return MapEntry(key, value);
      });
      _convertCurrency();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('汇率已更新')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '汇率转换',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _updateRates,
          tooltip: '更新汇率',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 输入金额
                    TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '输入金额',
                        border: const OutlineInputBorder(),
                        prefixText: '${_currencyInfo[_fromCurrency]?['symbol']} ',
                      ),
                      onChanged: (value) => _updateConversion(),
                    ),
                    const SizedBox(height: 8),

                    // 货币选择和交换
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            items: _currencyInfo.keys.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text('$currency - ${_currencyInfo[currency]?['name']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _fromCurrency = value ?? '';
                                _convertCurrency();
                              });
                            },
                            decoration: const InputDecoration(labelText: '从'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: _swapCurrencies,
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            items: _currencyInfo.keys.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text('$currency - ${_currencyInfo[currency]?['name']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _toCurrency = value ?? '';
                                _convertCurrency();
                              });
                            },
                            decoration: const InputDecoration(labelText: '到'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 转换结果
            Card(
              elevation: 0,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '转换结果',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currencyInfo[_fromCurrency]?['symbol']} ${_inputAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.arrow_downward),
                    const SizedBox(height: 8),
                    Text(
                      '${_currencyInfo[_toCurrency]?['symbol']} ${_convertedAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 $_fromCurrency = ${(_exchangeRates[_toCurrency]! / _exchangeRates[_fromCurrency]!).toStringAsFixed(4)} ${_toCurrency}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 常用金额快捷按钮
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('常用金额', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '100';
                            _updateConversion();
                          },
                          child: const Text('100'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '500';
                            _updateConversion();
                          },
                          child: const Text('500'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '1000';
                            _updateConversion();
                          },
                          child: const Text('1000'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '5000';
                            _updateConversion();
                          },
                          child: const Text('5000'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '10000';
                            _updateConversion();
                          },
                          child: const Text('10000'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}