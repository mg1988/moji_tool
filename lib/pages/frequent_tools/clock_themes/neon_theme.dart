import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 霓虹光效时钟主题
class NeonTheme extends BaseClockTheme {
  @override
  String get id => 'neon';

  @override
  String get name => '霓虹光效';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => const Color(0xFF0A0A2A);

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.pinkAccent;

  @override
  Color get dateColor => Colors.white.withOpacity(0.8);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.pinkAccent.withOpacity(0.3);

  @override
  Color get buttonColor => Colors.pinkAccent.withOpacity(0.3);

  @override
  Color get hourHandColor => Colors.white;

  @override
  Color get minuteHandColor => Colors.white.withOpacity(0.8);

  @override
  String get fontFamily => 'Helvetica Neue';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.pinkAccent.withOpacity(0.8),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
        Shadow(
          color: Colors.cyan.withOpacity(0.5),
          blurRadius: 25,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A0A2A),
          Color(0xFF1B1B3A),
          Color(0xFF2C2C4A),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加霓虹光效动画
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: textColor,
          fontWeight: FontWeight.bold,
          shadows: textShadows,
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
          shadows: [
            Shadow(
              color: Colors.pinkAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}