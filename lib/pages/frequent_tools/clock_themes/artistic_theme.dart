import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 艺术风格时钟主题
class ArtisticTheme extends BaseClockTheme {
  @override
  String get id => 'artistic';

  @override
  String get name => '艺术风格';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.orange;

  @override
  Color get dateColor => Colors.white.withOpacity(0.9);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.teal.withOpacity(0.3);

  @override
  Color get buttonColor => Colors.teal.withOpacity(0.3);

  @override
  Color get hourHandColor => Colors.white;

  @override
  Color get minuteHandColor => Colors.white.withOpacity(0.8);

  @override
  String get fontFamily => 'Georgia';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.teal,
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
        Shadow(
          color: Colors.orange,
          blurRadius: 5,
          offset: const Offset(2, 2),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.teal, Colors.orange],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加艺术字体效果
    return Transform.rotate(
      angle: -0.05, // 轻微倾斜创造艺术感
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic, // 斜体
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
          fontStyle: FontStyle.italic,
          shadows: [
            Shadow(
              color: Colors.teal.withOpacity(0.7),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}