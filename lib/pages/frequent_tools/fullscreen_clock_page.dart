import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

import 'clock_themes/theme_factory.dart';
import 'clock_themes/base_clock_theme.dart';

class FullscreenClockPage extends StatefulWidget {
  final String themeId;

  const FullscreenClockPage({super.key, required this.themeId});

  @override
  State<FullscreenClockPage> createState() => _FullscreenClockPageState();
}

class _FullscreenClockPageState extends State<FullscreenClockPage> with TickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  bool _isFullscreen = false;
  bool _showControls = true;
  bool _isDarkMode = false;
  late BaseClockTheme _currentTheme;
  Timer? _timer;
  Timer? _hideControlsTimer;
  
  // 动画控制器
  late AnimationController _hourHandController;
  late AnimationController _minuteHandController;
  late AnimationController _secondHandController;
  late AnimationController _digitalClockController;
  late Animation<double> _hourHandAnimation;
  late Animation<double> _minuteHandAnimation;
  late Animation<double> _secondHandAnimation;
  late Animation<double> _digitalClockScaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    
    // 初始化动画控制器
    _hourHandController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _minuteHandController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _secondHandController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _digitalClockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // 设置动画曲线 - 确保动画变量已完全初始化
    _hourHandAnimation = Tween<double>(
      begin: _getHourRotation(_currentTime),
      end: _getHourRotation(_currentTime),
    ).animate(_hourHandController);
    _minuteHandAnimation = Tween<double>(
      begin: _getMinuteRotation(_currentTime),
      end: _getMinuteRotation(_currentTime),
    ).animate(_minuteHandController);
    _secondHandAnimation = Tween<double>(
      begin: _getSecondRotation(_currentTime),
      end: _getSecondRotation(_currentTime),
    ).animate(_secondHandController);
    _digitalClockScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _digitalClockController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 先确保动画已经初始化，然后再加载主题和启动定时器
    _loadTheme();
    
    // 设置支持所有方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _updateAnimations();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideControlsTimer?.cancel();
    _hourHandController.dispose();
    _minuteHandController.dispose();
    _secondHandController.dispose();
    _digitalClockController.dispose();
    
    // 恢复系统UI模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // 恢复屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    super.dispose();
  }

  void _loadTheme() {
    _currentTheme = ClockThemeFactory.createTheme(widget.themeId, isDarkMode: _isDarkMode);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateAnimations();
      });
    });
  }

  void _updateAnimations() {
    // 更新指针动画
    _hourHandAnimation = Tween<double>(
      begin: _hourHandAnimation.value,
      end: _getHourRotation(_currentTime),
    ).animate(_hourHandController);
    _minuteHandAnimation = Tween<double>(
      begin: _minuteHandAnimation.value,
      end: _getMinuteRotation(_currentTime),
    ).animate(_minuteHandController);
    _secondHandAnimation = Tween<double>(
      begin: _secondHandAnimation.value,
      end: _getSecondRotation(_currentTime),
    ).animate(_secondHandController);
    
    // 启动动画
    _hourHandController.forward(from: 0);
    _minuteHandController.forward(from: 0);
    _secondHandController.forward(from: 0);
    _digitalClockController.forward(from: 0);
    _digitalClockController.reverse(from: 1);
  }

  double _getHourRotation(DateTime time) {
    return (time.hour % 12 + time.minute / 60) * 30 * pi / 180;
  }

  double _getMinuteRotation(DateTime time) {
    return (time.minute + time.second / 60) * 6 * pi / 180;
  }

  double _getSecondRotation(DateTime time) {
    return time.second * 6 * pi / 180;
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _currentTheme = ClockThemeFactory.createTheme(widget.themeId, isDarkMode: _isDarkMode);
      _showControls = true;
      _scheduleHideControls();
    });
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _onScreenTap() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _scheduleHideControls();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScreenTap,
      child: Scaffold(
        backgroundColor: _currentTheme.backgroundColor,
        // 移除全屏相关的AppBar逻辑
        appBar: _showControls ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            _currentTheme.name,
            style: TextStyle(color: _currentTheme.textColor),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _currentTheme.textColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              color: _currentTheme.textColor,
              onPressed: _toggleDarkMode,
            ),
          ],
        ) : null,
        // 移除SafeArea以实现真正的全屏显示
        body: Container(
          decoration: _currentTheme.gradient != null
              ? BoxDecoration(gradient: _currentTheme.gradient)
              : null,
          child: Stack(
            children: [
              // 时钟显示区域
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 数字时钟显示
                    if (!_currentTheme.isAnalog)
                      _buildDigitalClock(),
                    // 模拟时钟显示
                    if (_currentTheme.isAnalog)
                      _buildAnalogClock(),
                    // 日期显示
                    _buildDateDisplay(),
                  ],
                ),
              ),
              // 移除全屏按钮
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalClock() {
    return ScaleTransition(
      scale: _digitalClockScaleAnimation,
      child: Column(
        children: [
          // 时间显示
          _currentTheme.buildDigitalClock(context, _currentTime),
        ],
      ),
    );
  }

  Widget _buildAnalogClock() {
    final double clockSize = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.7;
    return Stack(
      alignment: Alignment.center,
      children: [
        // 时钟表盘
        Container(
          width: clockSize,
          height: clockSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentTheme.clockFaceColor,
            border: Border.all(
              color: _currentTheme.borderColor,
              width: 2,
            ),
            boxShadow: _currentTheme.boxShadowColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: _currentTheme.boxShadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          // 表盘刻度
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(12, (index) {
              return Transform.rotate(
                angle: index * 30 * pi / 180,
                child: SizedBox(
                  width: clockSize,
                  height: clockSize,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      height: 10,
                      color: _currentTheme.textColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // 时针
        AnimatedBuilder(
          animation: _hourHandAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _hourHandAnimation.value,
              child: Container(
                width: 4,
                height: _currentTheme.getHourHandHeight(context),
                decoration: BoxDecoration(
                  color: _currentTheme.hourHandColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.bottomCenter,
              ),
            );
          },
        ),
        // 分针
        AnimatedBuilder(
          animation: _minuteHandAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _minuteHandAnimation.value,
              child: Container(
                width: 3,
                height: _currentTheme.getMinuteHandHeight(context),
                decoration: BoxDecoration(
                  color: _currentTheme.minuteHandColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
                alignment: Alignment.bottomCenter,
              ),
            );
          },
        ),
        // 秒针
        AnimatedBuilder(
          animation: _secondHandAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _secondHandAnimation.value,
              child: Container(
                width: 2,
                height: _currentTheme.getSecondHandHeight(context),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(1),
                ),
                alignment: Alignment.bottomCenter,
              ),
            );
          },
        ),
        // 中心点
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateDisplay() {
    return _currentTheme.buildDateDisplay(context, _currentTime);
  }
}