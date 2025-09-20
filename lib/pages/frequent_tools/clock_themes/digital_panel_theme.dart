import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 数字面板时钟主题（7段数码管风格）
class DigitalPanelTheme extends BaseClockTheme {
  @override
  String get id => 'digital';

  @override
  String get name => '数字面板';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => const Color(0xFF000000);

  @override
  Color get textColor => const Color(0xFF00FF00); // 经典绿色

  @override
  Color get accentColor => Colors.green;

  @override
  Color get dateColor => Colors.green.withOpacity(0.8);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.green.withOpacity(0.5);

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
          color: Colors.green.withOpacity(0.9),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000000),
          Color(0xFF0A0A0A),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 模拟7段数码管显示效果
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: textColor,
          fontWeight: FontWeight.bold,
          shadows: textShadows,
          letterSpacing: 5, // 增加字符间距模拟数码管
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
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
      ),
    );
  }
}