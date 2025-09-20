import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古终端时钟主题
class RetroTheme extends BaseClockTheme {
  final bool isDarkMode;

  RetroTheme({this.isDarkMode = false});

  @override
  String get id => 'retro';

  @override
  String get name => '复古终端';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFF0A0A0A);

  @override
  Color get textColor => isDarkMode ? Colors.greenAccent : Colors.green;

  @override
  Color get accentColor => isDarkMode ? Colors.green : Colors.green;

  @override
  Color get dateColor =>
      isDarkMode ? Colors.greenAccent.withOpacity(0.8) : Colors.green.withOpacity(0.8);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.green.withOpacity(0.3);

  @override
  Color get buttonColor => Colors.green.withOpacity(0.3);

  @override
  Color get hourHandColor => Colors.green;

  @override
  Color get minuteHandColor => Colors.green.withOpacity(0.8);

  @override
  String get fontFamily => 'Courier';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.green.withOpacity(0.7),
          blurRadius: 5,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A0A0A),
          Color(0xFF121212),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加复古闪烁效果
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: textColor,
          fontWeight: FontWeight.bold,
          shadows: textShadows,
          height: 1.2, // 增加行高以模拟终端显示
        ),
        textAlign: TextAlign.center, // 确保居中显示
      ),
    );
  }

  @override
  Widget buildAnalogClock(BuildContext context, DateTime currentTime) {
    // 此主题为数字时钟，不实现模拟时钟
    return const SizedBox.shrink();
  }

  @override
  Widget buildDateDisplay(BuildContext context, DateTime currentTime) {
    // 确保显示中文年月日星期，格式统一
    String formattedDate = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(currentTime);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        formattedDate,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.05,
          color: dateColor,
          shadows: textShadows,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}