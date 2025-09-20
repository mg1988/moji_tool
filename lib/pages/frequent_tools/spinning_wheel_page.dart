import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_to_text_app/components/base_tool_page.dart';
import 'package:voice_to_text_app/components/colors.dart';

class SpinningWheelPage extends StatefulWidget {
  const SpinningWheelPage({super.key});

  @override
  State<SpinningWheelPage> createState() => _SpinningWheelPageState();
}

class _SpinningWheelPageState extends State<SpinningWheelPage> with TickerProviderStateMixin {
  List<String> _wheelSections = [];
  double _rotation = 0.0;
  bool _isSpinning = false;
  String _result = '';
  final TextEditingController _sectionController = TextEditingController();
  int? _selectedIndex; // 选中的扇区索引
  List<Map<String, dynamic>> _savedPresets = []; // 保存的预设选项
  final TextEditingController _presetNameController = TextEditingController(); // 预设名称输入
  AnimationController? _animationController; // 当前正在运行的动画控制器
  
  // 设置相关变量
  int _spinSpeed = 4; // 旋转速度：1-慢, 2-中, 3-快, 4-非常快
  int _spinDuration = 4; // 旋转持续时间：1-短, 2-中, 3-长, 4-非常长
  int _spinRounds = 3; // 旋转圈数：1-少, 2-中, 3-多, 4-非常多
  bool _showHapticFeedback = true; // 是否显示触觉反馈

  // 简约风格的颜色列表 - 使用更柔和的灰色和蓝色调
  final List<Color> _colors = [
    Colors.grey.shade700,
    Colors.blue.shade700,
    Colors.grey.shade600,
    Colors.blue.shade600,
    Colors.grey.shade500,
    Colors.blue.shade500,
  ];

  void _addSection() {
    String section = _sectionController.text.trim();
    if (section.isNotEmpty && !_wheelSections.contains(section)) {
      setState(() {
        _wheelSections.add(section);
        _sectionController.clear();
      });
    }
  }

  void _removeSection(String section) {
    if (_wheelSections.length <= 2) return; // 至少保留2个选项
    setState(() {
      _wheelSections.remove(section);
    });
  }

  void _spinWheel() {
    if (_isSpinning) return;
    
    // 检查选项数量是否足够
    if (_wheelSections.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少添加2个选项后再旋转'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 如果已有控制器在运行，先取消并释放
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }

    setState(() {
      _isSpinning = true;
      _result = '';
    });

    // 根据设置的旋转圈数计算随机旋转角度
    double spinRounds = _spinRounds + Random().nextDouble();
    double randomSpin = 360 * spinRounds;
    
    // 随机偏移量，使结果随机
    double randomOffset = Random().nextDouble() * 360;
    double totalRotation = randomSpin + randomOffset;
    double startRotation = _rotation; // 保存初始旋转角度

    // 根据设置的旋转持续时间计算动画持续时间
    int baseDuration = 2000 + (4 - _spinSpeed) * 500;
    int durationVariation = (5 - _spinDuration) * 500;
    int duration = baseDuration + Random().nextInt(durationVariation);

    // 使用动画控制器实现平滑旋转
    _animationController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: duration)
    );

    Animation<double> animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut)
    );

    animation.addListener(() {
      setState(() {
        // 正确的计算方式：从初始角度开始，根据动画进度计算新的旋转角度
        _rotation = startRotation + totalRotation * animation.value;
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _calculateResult();
        setState(() {
          _isSpinning = false;
        });
        _animationController?.dispose();
        _animationController = null;
      }
    });

    _animationController?.forward();
  }

  void _calculateResult() {
    // 计算当前旋转角度对应的扇区
    double normalizedRotation = _rotation % 360;
    double anglePerSection = 360 / _wheelSections.length;
    int resultIndex = ((360 - normalizedRotation) / anglePerSection).floor() % _wheelSections.length;
    
    setState(() {
      _result = _wheelSections[resultIndex];
      _selectedIndex = resultIndex;
    });
  }

  void _resetWheel() {
    setState(() {
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // 加载用户保存的预设选项
    _loadSavedPresets();
  }

  // 加载用户保存的预设选项
  Future<void> _loadSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = prefs.getString('wheel_presets') ?? '[]';
    setState(() {
      _savedPresets = List<Map<String, dynamic>>.from(
          (jsonDecode(presetsJson) as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
      );
      // 如果没有保存的预设，加载默认骰子选项
      if (_savedPresets.isEmpty) {
        _loadDefaultOptions();
      } else {
        // 加载第一个预设作为默认选项
        _loadPreset(_savedPresets[0]['options']);
      }
    });
  }

  // 保存当前选项作为自定义预设
  Future<void> _saveCurrentAsPreset(String name) async {
    if (name.isEmpty || _wheelSections.length < 2) return;

    final newPreset = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'options': _wheelSections,
      'createdAt': DateTime.now().toIso8601String()
    };

    setState(() {
      _savedPresets.add(newPreset);
    });

    // 保存到本地存储
    await _savePresetsToStorage();
    _presetNameController.clear();
  }

  // 删除自定义预设
  Future<void> _deletePreset(String id) async {
    setState(() {
      _savedPresets.removeWhere((preset) => preset['id'] == id);
    });
    await _savePresetsToStorage();
  }

  // 保存预设到本地存储
  Future<void> _savePresetsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = jsonEncode(_savedPresets);
    await prefs.setString('wheel_presets', presetsJson);
  }

  // 加载预设选项
  void _loadPreset(List<String> options) {
    // 先取消并释放可能正在运行的动画控制器
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
    
    setState(() {
      _wheelSections = List.from(options);
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
      _isSpinning = false; // 确保旋转状态被重置
    });
  }

  // 显示保存预设对话框
  void _showSavePresetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('保存当前选项为预设', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _presetNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: '预设名称',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _presetNameController.clear();
              },
              child: const Text('取消', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _saveCurrentAsPreset(_presetNameController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('保存', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  void _loadDefaultOptions() {
    // 默认加载骰子选项
    setState(() {
      _wheelSections = ['1', '2', '3', '4', '5', '6'];
    });
  }

  void _loadCoinTossOptions() {
    setState(() {
      _wheelSections = ['正面', '反面'];
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  void _loadFoodOptions() {
    setState(() {
      _wheelSections = ['中餐', '西餐', '日料', '韩餐', '快餐', '火锅', '烧烤', '海鲜'];
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _presetNameController.dispose();
    // 确保在dispose时释放动画控制器
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
    super.dispose();
  }

  // 显示设置对话框
  void _showSettingsDialog() {
    // 创建局部变量来保存设置值，这样用户取消时不会应用更改
    int tempSpinSpeed = _spinSpeed;
    int tempSpinDuration = _spinDuration;
    int tempSpinRounds = _spinRounds;
    bool tempShowHapticFeedback = _showHapticFeedback;

    showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('转盘设置', style: TextStyle(color: Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 旋转速度设置
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('旋转速度', style: TextStyle(color: Colors.black)),
                        Slider(
                          value: tempSpinSpeed.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: ['非常慢', '慢', '中', '快', '非常快'][tempSpinSpeed],
                          onChanged: (value) {
                            setStateDialog(() {
                              tempSpinSpeed = value.toInt();
                            });
                          },
                          activeColor: Colors.black,
                          inactiveColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  
                  // 旋转持续时间设置
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('旋转持续时间', style: TextStyle(color: Colors.black)),
                        Slider(
                          value: tempSpinDuration.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: ['非常短', '短', '中', '长', '非常长'][tempSpinDuration],
                          onChanged: (value) {
                            setStateDialog(() {
                              tempSpinDuration = value.toInt();
                            });
                          },
                          activeColor: Colors.black,
                          inactiveColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  
                  // 旋转圈数设置
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('旋转圈数', style: TextStyle(color: Colors.black)),
                        Slider(
                          value: tempSpinRounds.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: ['非常少', '少', '中', '多', '非常多'][tempSpinRounds],
                          onChanged: (value) {
                            setStateDialog(() {
                              tempSpinRounds = value.toInt();
                            });
                          },
                          activeColor: Colors.black,
                          inactiveColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  
                  // 触觉反馈设置
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('触觉反馈', style: TextStyle(color: Colors.black)),
                        Switch(
                          value: tempShowHapticFeedback,
                          onChanged: (value) {
                            setStateDialog(() {
                              tempShowHapticFeedback = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    // 确认按钮 - 应用更改
                    setState(() {
                      _spinSpeed = tempSpinSpeed;
                      _spinDuration = tempSpinDuration;
                      _spinRounds = tempSpinRounds;
                      _showHapticFeedback = tempShowHapticFeedback;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('确认', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 新加预设：星期选择
  void _loadWeekdayOptions() {
    setState(() {
      _wheelSections = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  // 新加预设：天气选择
  void _loadWeatherOptions() {
    setState(() {
      _wheelSections = ['晴天', '阴天', '雨天', '雪天', '多云', '大风', '雾天', '雷暴'];
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  // 新加预设：运动选择
  void _loadExerciseOptions() {
    setState(() {
      _wheelSections = ['跑步', '游泳', '瑜伽', '健身', '篮球', '足球', '羽毛球', '乒乓球'];
      _rotation = 0.0;
      _result = '';
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '指尖轮盘',
      actions: [ IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: _showSettingsDialog,
          ),],
      child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 轮盘显示区域
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 轮盘
                        GestureDetector(
                          onTap: _spinWheel,
                          child: Transform.rotate(
                            angle: _rotation * pi / 180,
                            alignment: Alignment.center,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.width * 0.75,
                              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: CustomPaint(
                                painter: WheelPainter(
                                sections: _wheelSections,
                                colors: _colors,
                                selectedIndex: _selectedIndex,
                              ),
                              ),
                            ),
                          ),
                        ),
                        // 中心圆点
                           Container(
                          width: 30,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_upward, 
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_upward,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                        ),
                      // 改进的轮盘指针 - 更加明显的结果指示器
                     
                      ],
                    ),
                  ),
                ),

                // 结果显示
                if (_result.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '结果: $_result',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                // 轮盘选项管理
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       

                      // 旋转按钮
                      ElevatedButton(
                        onPressed: _spinWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpinning ? Colors.grey : AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh, size: 20, color:AppColors.textPrimary),
                            const SizedBox(width: 8),
                            Text(_isSpinning ? '旋转中...' : '开始旋转'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '管理轮盘选项',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // 预设选项按钮组 - 第一行
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _loadDefaultOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('骰子'),
                            ),
                            ElevatedButton(
                              onPressed: _loadCoinTossOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('抛硬币'),
                            ),
                            ElevatedButton(
                              onPressed: _loadFoodOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('美食选择'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // 新增预设选项按钮组 - 第二行
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _loadWeekdayOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('星期选择'),
                            ),
                            ElevatedButton(
                              onPressed: _loadWeatherOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('天气选择'),
                            ),
                            ElevatedButton(
                              onPressed: _loadExerciseOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('运动选择'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // 保存当前选项为预设
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '自定义预设',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showSavePresetDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              child: const Text('保存当前预设'),
                            ),
                          ],
                        ),
                        // 已保存的预设列表
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            itemCount: _savedPresets.length,
                            itemBuilder: (context, index) {
                              final preset = _savedPresets[index];
                              return Card(
                                  color: AppColors.white,
                                  margin: const EdgeInsets.only(bottom: 4),
                                child: ListTile(
                                  title: Text(
                                    preset['name'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_circle, color: AppColors.textPrimary),
                                        onPressed: () => _loadPreset(List<String>.from(preset['options'])),
                                        iconSize: 18,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red.shade500),
                                        onPressed: () => _deletePreset(preset['id']),
                                        iconSize: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // 添加选项的输入框
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _sectionController,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: '输入选项内容',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.primary),
                                    ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addSection,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      // 选项列表
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          itemCount: _wheelSections.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: _colors[index % _colors.length].withOpacity(0.2),
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _colors[index % _colors.length],
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                ),
                                title: Text(
                                  _wheelSections[index],
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                                trailing: IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red.shade500),
                                  onPressed: () => _removeSection(_wheelSections[index]),
                                  iconSize: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                     
                    ],
                  ),
                ),
                
                // 底部间距
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 轮盘绘制器
class WheelPainter extends CustomPainter {
  final List<String> sections;
  final List<Color> colors;
  final int? selectedIndex;

  WheelPainter({required this.sections, required this.colors, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final double anglePerSection = 2 * pi / sections.length;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < sections.length; i++) {
      // 绘制扇区
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * anglePerSection - pi / 2,
        anglePerSection,
        true,
        paint,
      );

      // 如果是选中的扇区，添加高亮效果
      if (selectedIndex != null && i == selectedIndex) {
        paint.color = Colors.white.withOpacity(0.3);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 4.0;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * anglePerSection - pi / 2,
          anglePerSection,
          true,
          paint,
        );
        paint.style = PaintingStyle.fill;
      }

      // 绘制文字
      final double textAngle = i * anglePerSection + anglePerSection / 2;
      final double textRadius = radius * 0.7;
      final textOffset = Offset(
        center.dx + cos(textAngle - pi / 2) * textRadius,
        center.dy + sin(textAngle - pi / 2) * textRadius,
      );

      // 创建文字段落
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(text: sections[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      // 布局和绘制文字
      textPainter.layout(minWidth: 0, maxWidth: radius * 0.5);
      
      // 保存当前画布状态
      canvas.save();
      
      // 移动到文字位置并旋转
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle);
      
      // 绘制文字
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      
      // 恢复画布状态
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}