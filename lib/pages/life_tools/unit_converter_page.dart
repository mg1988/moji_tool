import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  _UnitConverterPageState createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  String _selectedCategory = '长度';
  String _fromUnit = '米';
  String _toUnit = '厘米';
  double _inputValue = 0;
  double _resultValue = 0;
  TextEditingController _inputController = TextEditingController();

  // 单位转换配置
  final Map<String, List<String>> _unitCategories = {
    '长度': ['米', '厘米', '毫米', '千米', '英寸', '英尺', '码', '英里'],
    '重量': ['千克', '克', '毫克', '吨', '磅', '盎司'],
    '面积': ['平方米', '平方厘米', '平方毫米', '公顷', '英亩', '平方英尺'],
    '体积': ['立方米', '升', '毫升', '加仑', '立方英尺', '立方英寸'],
    '温度': ['摄氏度', '华氏度', '开尔文'],
    '时间': ['秒', '分钟', '小时', '天', '周', '月', '年'],
  };

  @override
  void initState() {
    super.initState();
    _inputController.text = '0';
    _updateResult();
  }

  void _updateResult() {
    try {
      _inputValue = double.parse(_inputController.text);
      _convertUnit();
    } catch (e) {
      setState(() {
        _resultValue = 0;
      });
    }
  }

  void _convertUnit() {
    double result = 0;
    
    switch (_selectedCategory) {
      case '长度':
        result = _convertLength();
        break;
      case '重量':
        result = _convertWeight();
        break;
      case '面积':
        result = _convertArea();
        break;
      case '体积':
        result = _convertVolume();
        break;
      case '温度':
        result = _convertTemperature();
        break;
      case '时间':
        result = _convertTime();
        break;
    }

    setState(() {
      _resultValue = result;
    });
  }

  double _convertLength() {
    // 先转换为米
    double meters;
    switch (_fromUnit) {
      case '米': meters = _inputValue; break;
      case '厘米': meters = _inputValue / 100; break;
      case '毫米': meters = _inputValue / 1000; break;
      case '千米': meters = _inputValue * 1000; break;
      case '英寸': meters = _inputValue * 0.0254; break;
      case '英尺': meters = _inputValue * 0.3048; break;
      case '码': meters = _inputValue * 0.9144; break;
      case '英里': meters = _inputValue * 1609.344; break;
      default: meters = 0;
    }

    // 再从米转换为目标单位
    switch (_toUnit) {
      case '米': return meters;
      case '厘米': return meters * 100;
      case '毫米': return meters * 1000;
      case '千米': return meters / 1000;
      case '英寸': return meters / 0.0254;
      case '英尺': return meters / 0.3048;
      case '码': return meters / 0.9144;
      case '英里': return meters / 1609.344;
      default: return 0;
    }
  }

  double _convertWeight() {
    // 先转换为千克
    double kilograms;
    switch (_fromUnit) {
      case '千克': kilograms = _inputValue; break;
      case '克': kilograms = _inputValue / 1000; break;
      case '毫克': kilograms = _inputValue / 1000000; break;
      case '吨': kilograms = _inputValue * 1000; break;
      case '磅': kilograms = _inputValue * 0.45359237; break;
      case '盎司': kilograms = _inputValue * 0.02834952; break;
      default: kilograms = 0;
    }

    // 再从千克转换为目标单位
    switch (_toUnit) {
      case '千克': return kilograms;
      case '克': return kilograms * 1000;
      case '毫克': return kilograms * 1000000;
      case '吨': return kilograms / 1000;
      case '磅': return kilograms / 0.45359237;
      case '盎司': return kilograms / 0.02834952;
      default: return 0;
    }
  }

  double _convertArea() {
    // 先转换为平方米
    double squareMeters;
    switch (_fromUnit) {
      case '平方米': squareMeters = _inputValue; break;
      case '平方厘米': squareMeters = _inputValue / 10000; break;
      case '平方毫米': squareMeters = _inputValue / 1000000; break;
      case '公顷': squareMeters = _inputValue * 10000; break;
      case '英亩': squareMeters = _inputValue * 4046.86; break;
      case '平方英尺': squareMeters = _inputValue * 0.092903; break;
      default: squareMeters = 0;
    }

    // 再从平方米转换为目标单位
    switch (_toUnit) {
      case '平方米': return squareMeters;
      case '平方厘米': return squareMeters * 10000;
      case '平方毫米': return squareMeters * 1000000;
      case '公顷': return squareMeters / 10000;
      case '英亩': return squareMeters / 4046.86;
      case '平方英尺': return squareMeters / 0.092903;
      default: return 0;
    }
  }

  double _convertVolume() {
    // 先转换为立方米
    double cubicMeters;
    switch (_fromUnit) {
      case '立方米': cubicMeters = _inputValue; break;
      case '升': cubicMeters = _inputValue / 1000; break;
      case '毫升': cubicMeters = _inputValue / 1000000; break;
      case '加仑': cubicMeters = _inputValue * 0.00378541; break;
      case '立方英尺': cubicMeters = _inputValue * 0.0283168; break;
      case '立方英寸': cubicMeters = _inputValue * 0.0000163871; break;
      default: cubicMeters = 0;
    }

    // 再从立方米转换为目标单位
    switch (_toUnit) {
      case '立方米': return cubicMeters;
      case '升': return cubicMeters * 1000;
      case '毫升': return cubicMeters * 1000000;
      case '加仑': return cubicMeters / 0.00378541;
      case '立方英尺': return cubicMeters / 0.0283168;
      case '立方英寸': return cubicMeters / 0.0000163871;
      default: return 0;
    }
  }

  double _convertTemperature() {
    // 先转换为摄氏度
    double celsius;
    switch (_fromUnit) {
      case '摄氏度': celsius = _inputValue; break;
      case '华氏度': celsius = (_inputValue - 32) * 5 / 9; break;
      case '开尔文': celsius = _inputValue - 273.15; break;
      default: celsius = 0;
    }

    // 再从摄氏度转换为目标单位
    switch (_toUnit) {
      case '摄氏度': return celsius;
      case '华氏度': return celsius * 9 / 5 + 32;
      case '开尔文': return celsius + 273.15;
      default: return 0;
    }
  }

  double _convertTime() {
    // 先转换为秒
    double seconds;
    switch (_fromUnit) {
      case '秒': seconds = _inputValue; break;
      case '分钟': seconds = _inputValue * 60; break;
      case '小时': seconds = _inputValue * 3600; break;
      case '天': seconds = _inputValue * 86400; break;
      case '周': seconds = _inputValue * 604800; break;
      case '月': seconds = _inputValue * 2592000; break; // 以30天计算
      case '年': seconds = _inputValue * 31536000; break; // 以365天计算
      default: seconds = 0;
    }

    // 再从秒转换为目标单位
    switch (_toUnit) {
      case '秒': return seconds;
      case '分钟': return seconds / 60;
      case '小时': return seconds / 3600;
      case '天': return seconds / 86400;
      case '周': return seconds / 604800;
      case '月': return seconds / 2592000; // 以30天计算
      case '年': return seconds / 31536000; // 以365天计算
      default: return 0;
    }
  }

  void _swapUnits() {
    setState(() {
      final tempUnit = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tempUnit;
      _convertUnit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = _unitCategories[_selectedCategory] ?? [];

    return BaseToolPage(
      title: '单位换算',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 单位类别选择
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('选择转换类别', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _unitCategories.keys.length,
                      itemBuilder: (context, index) {
                        final category = _unitCategories.keys.elementAt(index);
                        return FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                                // 重置单位选择
                                final newUnits = _unitCategories[category] ?? [];
                                _fromUnit = newUnits.isNotEmpty ? newUnits[0] : '';
                                _toUnit = newUnits.length > 1 ? newUnits[1] : '';
                                _convertUnit();
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输入区域
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 输入值
                    TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '输入值',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _updateResult(),
                    ),
                    const SizedBox(height: 8),

                    // 单位选择和交换
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromUnit,
                            items: units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _fromUnit = value ?? '';
                                _convertUnit();
                              });
                            },
                            decoration: const InputDecoration(labelText: '从'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_vert),
                          onPressed: _swapUnits,
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toUnit,
                            items: units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _toUnit = value ?? '';
                                _convertUnit();
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

            // 结果显示
            Card(
              elevation: 0,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('转换结果', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _resultValue.toStringAsFixed(6).replaceAll(RegExp(r'\.?0*$'), ''),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(_toUnit),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 快捷转换按钮
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('快捷转换', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '1';
                            _updateResult();
                          },
                          child: const Text('1'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '10';
                            _updateResult();
                          },
                          child: const Text('10'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '100';
                            _updateResult();
                          },
                          child: const Text('100'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _inputController.text = '1000';
                            _updateResult();
                          },
                          child: const Text('1000'),
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