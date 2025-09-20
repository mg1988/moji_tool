import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:math';

class TimeScreenPage extends StatefulWidget {
  const TimeScreenPage({super.key});

  @override
  State<TimeScreenPage> createState() => _TimeScreenPageState();
}

class _TimeScreenPageState extends State<TimeScreenPage> {
  late DateTime _currentTime;
  late Timer _timer;
  bool _is24HourFormat = true;
  bool _showSeconds = true;
  bool _showDate = true;
  bool _isFullscreen = false;
  bool _isClockDisplay = false; // 控制是数字显示还是时钟显示

  @override
  void initState() {
    super.initState();
    // 初始化中文语言支持
    initializeDateFormatting('zh_CN', null);
    _currentTime = DateTime.now();
    // 每秒更新时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime() {
    // 指定中文区域
    final format = DateFormat.yMd('zh_CN');
    
    if (_is24HourFormat) {
      return _showSeconds 
          ? DateFormat('HH:mm:ss', 'zh_CN').format(_currentTime)
          : DateFormat('HH:mm', 'zh_CN').format(_currentTime);
    } else {
      return _showSeconds
          ? DateFormat('hh:mm:ss a', 'zh_CN').format(_currentTime)
          : DateFormat('hh:mm a', 'zh_CN').format(_currentTime);
    }
  }
  
  // 切换全屏模式
  void _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  
  // 渲染时钟显示 - 完全手动绘制，不使用任何图片资源
  Widget _buildClockDisplay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 减小时钟尺寸比例以避免溢出
    final clockSize = min(size.width * 0.6, size.height * 0.6);
    
    // 计算刻度和数字位置的辅助方法
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // 使用最小主轴尺寸避免溢出
        children: [
          Container(
            width: clockSize,
            height: clockSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(
                color: Colors.cyanAccent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(children: [
              // 时钟外圈装饰
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      width: clockSize * 0.01,
                    ),
                  ),
                ),
              ),
              
              // 时钟内圈装饰
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(clockSize * 0.02),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
              
              // 小时刻度和数字
              for (int i = 1; i <= 12; i++)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: i * 30 * pi / 180,
                    child: Column(
                      children: [
                        // 长刻度线（小时）
                        Container(
                          width: i % 3 == 0 ? 3 : 2,
                          height: clockSize * 0.08,
                          color: Colors.cyanAccent,
                        ),
                        // 中间间隔
                        SizedBox(height: clockSize * 0.01),
                        // 数字显示
                        if (i % 3 == 0) // 只显示3的倍数的数字，避免拥挤
                          Text(
                            '$i',
                            style: TextStyle(
                              fontSize: clockSize * 0.06,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              
              // 分钟刻度
              for (int i = 1; i <= 60; i++)
                if (i % 5 != 0) // 跳过小时刻度的位置
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: i * 6 * pi / 180,
                      child: Column(
                        children: [
                          // 短刻度线（分钟）
                          Container(
                            width: 1,
                            height: clockSize * 0.04,
                            color: Colors.cyanAccent.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
              
              // 时针 - 带尾部设计
              Positioned.fill(
                child: Transform.rotate(
                  angle: (_currentTime.hour % 12) * 30 * pi / 180 + 
                         (_currentTime.minute) * 0.5 * pi / 180,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 1,
                    height: clockSize * 0.5,
                    child: Stack(children: [
                      // 指针主体
                      Positioned(
                        bottom: clockSize * 0.25,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: clockSize * 0.35,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular( 0.02),
                              bottom: Radius.circular(0.01),
                            ),
                            color: Colors.green,
                          ),
                        ),
                      ),
                      // 指针尾部
                      Positioned(
                        top: clockSize * 0.25,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: clockSize * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(clockSize * 0.01),
                              bottom: Radius.circular(clockSize * 0.02),
                            ),
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              
              // 分针 - 带尾部设计
              Positioned.fill(
                child: Transform.rotate(
                  angle: _currentTime.minute * 6 * pi / 180 + 
                         (_currentTime.second) * 0.1 * pi / 180, // 轻微跟随秒针移动
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: clockSize * 0.03,
                    height: clockSize * 0.5,
                    child: Stack(children: [
                      // 指针主体
                      Positioned(
                        bottom: clockSize * 0.25,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: clockSize * 0.45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(clockSize * 0.015),
                              bottom: Radius.circular(clockSize * 0.01),
                            ),
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                      // 指针尾部
                      Positioned(
                        top: clockSize * 0.25,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: clockSize * 0.05,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(clockSize * 0.01),
                              bottom: Radius.circular(clockSize * 0.015),
                            ),
                            color: Colors.cyanAccent.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              
              // 秒针 - 带尾部设计
              if (_showSeconds)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: _currentTime.second * 6 * pi / 180,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 1,
                      height: clockSize * 0.5,
                      child: Stack(children: [
                        // 指针主体
                        Positioned(
                          bottom: clockSize * 0.25,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: clockSize * 0.5,
                            width: 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(clockSize * 0.0075),
                              color: Colors.red,
                            ),
                          ),
                        ),
                        // 指针尾部
                        Positioned(
                          top: clockSize * 0.25,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: clockSize * 0.07,
                            width: 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.0075),
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              
              // 中心点 - 多层次设计
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: clockSize * 0.06,
                    height: clockSize * 0.06,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyanAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: clockSize * 0.03,
                        height: clockSize * 0.03,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          
          // 日期显示
          if (_showDate)
            Padding(
              padding: EdgeInsets.only(top: clockSize * 0.1),
              child: Text(
                _formatDate(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ),
          
          // 当前时间的数字显示 - 调整字体大小和间距以适应不同屏幕
              Padding(
                padding: EdgeInsets.only(top: clockSize * 0.03),
                child: Text(
                  _formatTime(),
                  style: TextStyle(
                    fontSize: min(24.0, clockSize * 0.06), // 根据时钟尺寸动态调整字体大小
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _formatDate() {
    // 确保使用中文区域显示日期和星期
    return DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(_currentTime);
  }

  @override
  Widget build(BuildContext context) {
    // 全屏模式下隐藏AppBar
    return Scaffold(
       backgroundColor: Colors.grey[50],
      appBar: _isFullscreen ? null : AppBar(
        title: const Text('时间屏幕'),
         backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'format') {
                  _is24HourFormat = !_is24HourFormat;
                } else if (value == 'seconds') {
                  _showSeconds = !_showSeconds;
                } else if (value == 'date') {
                  _showDate = !_showDate;
                } else if (value == 'display') {
                  _isClockDisplay = !_isClockDisplay;
                } else if (value == 'fullscreen') {
                  _toggleFullscreen();
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'format',
                child: Text(_is24HourFormat ? '切换12小时制' : '切换24小时制'),
              ),
              PopupMenuItem(
                value: 'seconds',
                child: Text(_showSeconds ? '隐藏秒数' : '显示秒数'),
              ),
              PopupMenuItem(
                value: 'date',
                child: Text(_showDate ? '隐藏日期' : '显示日期'),
              ),
              PopupMenuItem(
                value: 'fullscreen',
                child: Text(_isFullscreen ? '退出全屏' : '全屏显示'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: _isClockDisplay 
          ? _buildClockDisplay(context) 
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 时间显示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.cyanAccent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      _formatTime(),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        fontFamily: 'Courier',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // 日期显示
                  if (_showDate)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _formatDate(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
      // 在全屏模式下显示退出全屏按钮
      floatingActionButton: _isFullscreen ? FloatingActionButton(
        onPressed: _toggleFullscreen,
        foregroundColor: Colors.black,
        tooltip: '退出全屏',
        child: const Icon(Icons.fullscreen_exit),
      ) : null,
    );
  }
}