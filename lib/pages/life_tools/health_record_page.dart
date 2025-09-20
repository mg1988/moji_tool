import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../components/base_tool_page.dart';

class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});

  @override
  _HealthRecordPageState createState() => _HealthRecordPageState();
}

class HealthRecord {
  final String id;
  final DateTime date;
  final double weight;
  final double height;
  final int steps;
  final double sleepHours;
  final double waterIntake;
  final String notes;

  HealthRecord({
    required this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.steps,
    required this.sleepHours,
    required this.waterIntake,
    required this.notes,
  });

  // 计算BMI
  double get bmi => weight / (height * height);
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  List<HealthRecord> _healthRecords = [];
  
  // 表单控制器
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _stepsController = TextEditingController();
  TextEditingController _sleepController = TextEditingController();
  TextEditingController _waterController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  
  // 图表数据类型选择
  String _chartType = 'weight'; // 'weight', 'bmi', 'steps', 'sleep', 'water'

  @override
  void initState() {
    super.initState();
    // 初始化一些示例健康记录数据
    _addSampleHealthRecords();
  }

  void _addSampleHealthRecords() {
    _healthRecords = [
      HealthRecord(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 7)),
        weight: 68.5,
        height: 1.75,
        steps: 8500,
        sleepHours: 7,
        waterIntake: 1.8,
        notes: '今天感觉不错，走了很多路',
      ),
      HealthRecord(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 6)),
        weight: 68.3,
        height: 1.75,
        steps: 6200,
        sleepHours: 6,
        waterIntake: 1.5,
        notes: '睡得有点少，需要早点休息',
      ),
      HealthRecord(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 5)),
        weight: 68.0,
        height: 1.75,
        steps: 10500,
        sleepHours: 8,
        waterIntake: 2.0,
        notes: '运动很多，喝了足够的水',
      ),
      HealthRecord(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 4)),
        weight: 67.8,
        height: 1.75,
        steps: 7800,
        sleepHours: 7,
        waterIntake: 1.7,
        notes: '正常的一天',
      ),
      HealthRecord(
        id: '5',
        date: DateTime.now().subtract(const Duration(days: 3)),
        weight: 67.5,
        height: 1.75,
        steps: 9200,
        sleepHours: 7,
        waterIntake: 1.9,
        notes: '感觉精力充沛',
      ),
      HealthRecord(
        id: '6',
        date: DateTime.now().subtract(const Duration(days: 2)),
        weight: 67.3,
        height: 1.75,
        steps: 5800,
        sleepHours: 8,
        waterIntake: 1.6,
        notes: '休息得很好',
      ),
      HealthRecord(
        id: '7',
        date: DateTime.now().subtract(const Duration(days: 1)),
        weight: 67.0,
        height: 1.75,
        steps: 7500,
        sleepHours: 7,
        waterIntake: 1.8,
        notes: '继续保持',
      ),
    ];
  }

  void _addHealthRecord() {
    // 验证输入
    if (_weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _stepsController.text.isEmpty ||
        _sleepController.text.isEmpty ||
        _waterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填字段')),
      );
      return;
    }

    try {
      setState(() {
        _healthRecords.add(HealthRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: _selectedDate,
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text) / 100, // 转换为米
          steps: int.parse(_stepsController.text),
          sleepHours: double.parse(_sleepController.text),
          waterIntake: double.parse(_waterController.text),
          notes: _notesController.text,
        ));
        // 清空表单
        _clearForm();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('健康记录添加成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的数值')),
      );
    }
  }

  void _clearForm() {
    _weightController.clear();
    _heightController.clear();
    _stepsController.clear();
    _sleepController.clear();
    _waterController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 获取BMI分类
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }

  // 获取BMI颜色
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24) return Colors.green;
    if (bmi < 28) return Colors.orange;
    return Colors.red;
  }

  // 绘制简单的趋势图
  Widget _buildTrendChart() {
    // 排序记录（按日期升序）
    List<HealthRecord> sortedRecords = List.from(_healthRecords);
    sortedRecords.sort((a, b) => a.date.compareTo(b.date));

    // 确定图表的最大和最小值
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    List<double> chartValues = [];

    for (var record in sortedRecords) {
      double value;
      switch (_chartType) {
        case 'weight': value = record.weight; break;
        case 'bmi': value = record.bmi; break;
        case 'steps': value = record.steps.toDouble(); break;
        case 'sleep': value = record.sleepHours.toDouble(); break;
        case 'water': value = record.waterIntake; break;
        default: value = 0;
      }
      chartValues.add(value);
      minValue = value < minValue ? value : minValue;
      maxValue = value > maxValue ? value : maxValue;
    }

    // 添加一些边距
    double margin = (maxValue - minValue) * 0.1;
    minValue -= margin;
    maxValue += margin;

    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: TrendChartPainter(
          values: chartValues,
          minValue: minValue,
          maxValue: maxValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 按日期倒序排序记录
    List<HealthRecord> sortedRecords = List.from(_healthRecords);
    sortedRecords.sort((a, b) => b.date.compareTo(a.date));

    return BaseToolPage(
      title: '健康记录',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 添加健康记录表单
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('添加健康记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _showDatePicker,
                            child: Text(
                              '日期: ${intl.DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '体重（kg）'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '身高（cm）'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _stepsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '步数'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _sleepController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '睡眠（小时）'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _waterController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '饮水量（升）'),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: '备注（可选）'),
                      maxLines: 2,
                    ),
                    ElevatedButton(
                      onPressed: _addHealthRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade100,
                      ),
                      child: const Text('添加记录'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 健康趋势图表
            if (_healthRecords.length > 1) ...[
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('健康趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilterChip(
                            label: const Text('体重'),
                            selected: _chartType == 'weight',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _chartType = 'weight';
                                });
                              }
                            },
                          ),
                          FilterChip(
                            label: const Text('BMI'),
                            selected: _chartType == 'bmi',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _chartType = 'bmi';
                                });
                              }
                            },
                          ),
                          FilterChip(
                            label: const Text('步数'),
                            selected: _chartType == 'steps',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _chartType = 'steps';
                                });
                              }
                            },
                          ),
                          FilterChip(
                            label: const Text('睡眠'),
                            selected: _chartType == 'sleep',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _chartType = 'sleep';
                                });
                              }
                            },
                          ),
                          FilterChip(
                            label: const Text('饮水'),
                            selected: _chartType == 'water',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _chartType = 'water';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTrendChart(),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 健康记录列表
            const Text('健康记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            sortedRecords.isEmpty
                ? const Center(child: Text('暂无健康记录'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedRecords.length,
                    itemBuilder: (context, index) {
                      final record = sortedRecords[index];
                      
                      return Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                intl.DateFormat('yyyy年MM月dd日').format(record.date),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('体重: ${record.weight} kg'),
                                        Text('身高: ${(record.height * 100).toStringAsFixed(1)} cm'),
                                        Text(
                                          'BMI: ${record.bmi.toStringAsFixed(1)} (${_getBMICategory(record.bmi)})',
                                          style: TextStyle(color: _getBMIColor(record.bmi)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('步数: ${record.steps} 步'),
                                        Text('睡眠: ${record.sleepHours} 小时'),
                                        Text('饮水: ${record.waterIntake} 升'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (record.notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('备注: ${record.notes}'),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// 自定义绘制趋势图的Painter
class TrendChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;

  TrendChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // 绘制坐标轴
    Paint axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    // 绘制水平线
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // 绘制数据点和连线
    Paint linePaint = Paint()
      ..color = Colors.teal.shade500
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint pointPaint = Paint()
      ..color = Colors.teal.shade500
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    // 计算每个点的位置
    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      double x = (i / (values.length - 1)) * size.width;
      // 将值映射到Y轴（反转，因为Canvas的Y轴是向下的）
      double y = size.height - ((values[i] - minValue) / (maxValue - minValue)) * size.height;
      points.add(Offset(x, y));
    }

    // 绘制连线
    if (points.length > 1) {
      Path path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 绘制数据点
    for (Offset point in points) {
      canvas.drawCircle(point, 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}