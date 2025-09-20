import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';

class UnitConvertPage extends StatefulWidget {
  const UnitConvertPage({Key? key}) : super(key: key);

  @override
  State<UnitConvertPage> createState() => _UnitConvertPageState();
}

class _UnitConvertPageState extends State<UnitConvertPage> {
  // 定义单位转换数据
  final Map<String, List<Map<String, dynamic>>> unitData = {
    '长度': [
      {'name': '毫米', 'symbol': 'mm', 'toBase': 0.001, 'fromBase': 1000},
      {'name': '厘米', 'symbol': 'cm', 'toBase': 0.01, 'fromBase': 100},
      {'name': '米', 'symbol': 'm', 'toBase': 1, 'fromBase': 1},
      {'name': '千米', 'symbol': 'km', 'toBase': 1000, 'fromBase': 0.001},
      {'name': '英寸', 'symbol': 'in', 'toBase': 0.0254, 'fromBase': 39.3701},
      {'name': '英尺', 'symbol': 'ft', 'toBase': 0.3048, 'fromBase': 3.28084},
      {'name': '码', 'symbol': 'yd', 'toBase': 0.9144, 'fromBase': 1.09361},
      {'name': '英里', 'symbol': 'mi', 'toBase': 1609.344, 'fromBase': 0.000621371},
      {'name': '里', 'symbol': '里', 'toBase': 500, 'fromBase': 0.002},
      {'name': '丈', 'symbol': '丈', 'toBase': 3.333333, 'fromBase': 0.3},
      {'name': '尺', 'symbol': '尺', 'toBase': 0.333333, 'fromBase': 3},
      {'name': '寸', 'symbol': '寸', 'toBase': 0.033333, 'fromBase': 30},
      {'name': '分', 'symbol': '分', 'toBase': 0.003333, 'fromBase': 300},
    ],
    '重量': [
      {'name': '毫克', 'symbol': 'mg', 'toBase': 0.000001, 'fromBase': 1000000},
      {'name': '克', 'symbol': 'g', 'toBase': 0.001, 'fromBase': 1000},
      {'name': '千克', 'symbol': 'kg', 'toBase': 1, 'fromBase': 1},
      {'name': '吨', 'symbol': 't', 'toBase': 1000, 'fromBase': 0.001},
      {'name': '盎司', 'symbol': 'oz', 'toBase': 0.0283495, 'fromBase': 35.274},
      {'name': '磅', 'symbol': 'lb', 'toBase': 0.453592, 'fromBase': 2.20462},
      {'name': '斤', 'symbol': '斤', 'toBase': 0.5, 'fromBase': 2},
      {'name': '两', 'symbol': '两', 'toBase': 0.05, 'fromBase': 20},
      {'name': '钱', 'symbol': '钱', 'toBase': 0.005, 'fromBase': 200},
    ],
    '面积': [
      {'name': '平方毫米', 'symbol': 'mm²', 'toBase': 0.000001, 'fromBase': 1000000},
      {'name': '平方厘米', 'symbol': 'cm²', 'toBase': 0.0001, 'fromBase': 10000},
      {'name': '平方米', 'symbol': 'm²', 'toBase': 1, 'fromBase': 1},
      {'name': '公顷', 'symbol': 'ha', 'toBase': 10000, 'fromBase': 0.0001},
      {'name': '平方千米', 'symbol': 'km²', 'toBase': 1000000, 'fromBase': 0.000001},
      {'name': '平方英寸', 'symbol': 'in²', 'toBase': 0.00064516, 'fromBase': 1550},
      {'name': '平方英尺', 'symbol': 'ft²', 'toBase': 0.092903, 'fromBase': 10.7639},
      {'name': '平方码', 'symbol': 'yd²', 'toBase': 0.836127, 'fromBase': 1.19599},
      {'name': '英亩', 'symbol': 'ac', 'toBase': 4046.86, 'fromBase': 0.000247105},
      {'name': '平方英里', 'symbol': 'mi²', 'toBase': 2589988.11, 'fromBase': 3.86102e-7},
      {'name': '亩', 'symbol': '亩', 'toBase': 666.6667, 'fromBase': 0.0015},
    ],
    '体积': [
      {'name': '立方厘米', 'symbol': 'cm³', 'toBase': 0.000001, 'fromBase': 1000000},
      {'name': '立方米', 'symbol': 'm³', 'toBase': 1, 'fromBase': 1},
      {'name': '升', 'symbol': 'L', 'toBase': 0.001, 'fromBase': 1000},
      {'name': '毫升', 'symbol': 'mL', 'toBase': 0.000001, 'fromBase': 1000000},
      {'name': '加仑(美)', 'symbol': 'gal', 'toBase': 0.00378541, 'fromBase': 264.172},
      {'name': '加仑(英)', 'symbol': 'gal(UK)', 'toBase': 0.00454609, 'fromBase': 219.969},
      {'name': '立方英寸', 'symbol': 'in³', 'toBase': 0.0000163871, 'fromBase': 61023.7},
      {'name': '立方英尺', 'symbol': 'ft³', 'toBase': 0.0283168, 'fromBase': 35.3147},
      {'name': '斗', 'symbol': '斗', 'toBase': 0.001, 'fromBase': 1000},
      {'name': '石', 'symbol': '石', 'toBase': 0.1, 'fromBase': 10},
    ],
    '温度': [
      {'name': '摄氏度', 'symbol': '°C', 'toBase': 1, 'fromBase': 1, 'offset': 0},
      {'name': '华氏度', 'symbol': '°F', 'toBase': 1, 'fromBase': 1, 'offset': 1},
      {'name': '开尔文', 'symbol': 'K', 'toBase': 1, 'fromBase': 1, 'offset': 2},
    ],
    '时间': [
      {'name': '毫秒', 'symbol': 'ms', 'toBase': 0.001, 'fromBase': 1000},
      {'name': '秒', 'symbol': 's', 'toBase': 1, 'fromBase': 1},
      {'name': '分钟', 'symbol': 'min', 'toBase': 60, 'fromBase': 1/60},
      {'name': '小时', 'symbol': 'h', 'toBase': 3600, 'fromBase': 1/3600},
      {'name': '天', 'symbol': 'd', 'toBase': 86400, 'fromBase': 1/86400},
      {'name': '周', 'symbol': 'wk', 'toBase': 604800, 'fromBase': 1/604800},
      {'name': '月(30天)', 'symbol': 'mo', 'toBase': 2592000, 'fromBase': 1/2592000},
      {'name': '年(365天)', 'symbol': 'yr', 'toBase': 31536000, 'fromBase': 1/31536000},
    ],
    '速度': [
      {'name': '米/秒', 'symbol': 'm/s', 'toBase': 1, 'fromBase': 1},
      {'name': '千米/小时', 'symbol': 'km/h', 'toBase': 1/3.6, 'fromBase': 3.6},
      {'name': '英里/小时', 'symbol': 'mph', 'toBase': 0.44704, 'fromBase': 2.23694},
      {'name': '节', 'symbol': 'kn', 'toBase': 0.514444, 'fromBase': 1.94384},
    ],
    '数据存储': [
      {'name': '字节', 'symbol': 'B', 'toBase': 1, 'fromBase': 1},
      {'name': '千字节', 'symbol': 'KB', 'toBase': 1024, 'fromBase': 1/1024},
      {'name': '兆字节', 'symbol': 'MB', 'toBase': 1024*1024, 'fromBase': 1/(1024*1024)},
      {'name': '吉字节', 'symbol': 'GB', 'toBase': 1024*1024*1024, 'fromBase': 1/(1024*1024*1024)},
      {'name': '太字节', 'symbol': 'TB', 'toBase': 1024*1024*1024*1024, 'fromBase': 1/(1024*1024*1024*1024)},
    ],
  };

  // 控制器
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  // 当前选择
  String _selectedCategory = '长度';
  int _selectedFromUnitIndex = 2; // 默认从米开始
  int _selectedToUnitIndex = 3;   // 默认到千米

  // 转换函数
  void _convertUnit() {
    if (_inputController.text.isEmpty) {
      _outputController.text = '';
      return;
    }

    try {
      double inputValue = double.parse(_inputController.text);
      double result;

      // 特殊处理温度转换
      if (_selectedCategory == '温度') {
        // 先转换到摄氏度
        double celsius;
        if (_selectedFromUnitIndex == 0) { // 摄氏度
          celsius = inputValue;
        } else if (_selectedFromUnitIndex == 1) { // 华氏度
          celsius = (inputValue - 32) * 5 / 9;
        } else { // 开尔文
          celsius = inputValue - 273.15;
        }

        // 再从摄氏度转换到目标单位
        if (_selectedToUnitIndex == 0) { // 摄氏度
          result = celsius;
        } else if (_selectedToUnitIndex == 1) { // 华氏度
          result = celsius * 9 / 5 + 32;
        } else { // 开尔文
          result = celsius + 273.15;
        }
      } else {
        // 其他单位转换
        var fromUnit = unitData[_selectedCategory]![_selectedFromUnitIndex];
        var toUnit = unitData[_selectedCategory]![_selectedToUnitIndex];

        // 先转换到基本单位，再转换到目标单位
        double baseValue = inputValue * fromUnit['toBase']!;
        result = baseValue * toUnit['fromBase']!;
      }

      // 格式化结果，避免过多小数位
      if (result.abs() < 0.000001 && result != 0) {
        _outputController.text = result.toStringAsExponential(6);
      } else if (result == result.roundToDouble()) {
        _outputController.text = result.round().toString();
      } else if (result.abs() > 1000000) {
        _outputController.text = result.toStringAsExponential(6);
      } else {
        // 动态保留小数位，最多10位
        String resultStr = result.toString();
        if (resultStr.contains('.') && resultStr.split('.')[1].length > 10) {
          _outputController.text = result.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        } else {
          _outputController.text = resultStr;
        }
      }
    } catch (e) {
      _outputController.text = '输入无效';
    }
  }

  // 复制结果到剪贴板
  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  // 交换单位
  void _swapUnits() {
    setState(() {
      int tempIndex = _selectedFromUnitIndex;
      _selectedFromUnitIndex = _selectedToUnitIndex;
      _selectedToUnitIndex = tempIndex;
      _convertUnit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '单位转换',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 单位类别选择器
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                  _selectedFromUnitIndex = 0;
                  _selectedToUnitIndex = 1;
                  _convertUnit();
                });
              },
              items: unitData.keys.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: '选择单位类别',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 输入区域
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedFromUnitIndex,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFromUnitIndex = newValue!;
                        _convertUnit();
                      });
                    },
                    items: unitData[_selectedCategory]!.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text('${entry.value['name']} (${entry.value['symbol']})'),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: '从单位',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  onPressed: _swapUnits,
                  color: Colors.blue,
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedToUnitIndex,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedToUnitIndex = newValue!;
                        _convertUnit();
                      });
                    },
                    items: unitData[_selectedCategory]!.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text('${entry.value['name']} (${entry.value['symbol']})'),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: '到单位',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 数值输入
            TextFormField(
              controller: _inputController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => _convertUnit(),
              decoration: InputDecoration(
                labelText: '输入数值',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 结果输出
            TextFormField(
              controller: _outputController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: '转换结果',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 转换信息提示
            if (_selectedCategory != '温度')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '1 ${unitData[_selectedCategory]![_selectedFromUnitIndex]['name']} = '
                    '${_getConversionRatio().toStringAsFixed(6)} ${unitData[_selectedCategory]![_selectedToUnitIndex]['name']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 获取转换比率
  double _getConversionRatio() {
    if (_selectedCategory == '温度') return 0; // 温度不是线性转换
    var fromUnit = unitData[_selectedCategory]![_selectedFromUnitIndex];
    var toUnit = unitData[_selectedCategory]![_selectedToUnitIndex];
    return fromUnit['toBase']! * toUnit['fromBase']!;
  }

  // 获取基本单位符号
  String _getBaseUnitSymbol() {
    switch (_selectedCategory) {
      case '长度':
        return 'm';
      case '重量':
        return 'kg';
      case '面积':
        return 'm²';
      case '体积':
        return 'm³';
      case '温度':
        return '°C';
      case '时间':
        return 's';
      case '速度':
        return 'm/s';
      case '数据存储':
        return 'B';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}