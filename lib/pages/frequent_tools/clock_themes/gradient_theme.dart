import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 渐变色彩时钟主题
class GradientTheme extends BaseClockTheme {
  @override
  String get id => 'gradient';

  @override
  String get name => '渐变色彩';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.purple;

  @override
  Color get dateColor => Colors.white.withOpacity(0.9);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.purple.withOpacity(0.3);

  @override
  Color get buttonColor => Colors.purple.withOpacity(0.3);

  @override
  Color get hourHandColor => Colors.white;

  @override
  Color get minuteHandColor => Colors.white.withOpacity(0.8);

  @override
  String get fontFamily => 'Arial';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.purple.withOpacity(0.8),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6A11CB),
          Color(0xFF2575FC),
          Color(0xFF00F2FE),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加颜色变化动画
    return AnimatedContainer(
      duration: const Duration(milliseconds: 2000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.cyan.withOpacity(0.9),
            Colors.pink.withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: Colors.transparent,
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
              color: Colors.purple.withOpacity(0.7),
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