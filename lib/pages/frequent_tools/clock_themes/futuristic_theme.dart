import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 未来科技时钟主题
class FuturisticTheme extends BaseClockTheme {
  final bool isDarkMode;

  FuturisticTheme({this.isDarkMode = true});

  @override
  String get id => 'futuristic';

  @override
  String get name => '未来科技';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => isDarkMode ? Colors.black : Colors.grey[900]!;

  @override
  Color get textColor => Colors.cyan;

  @override
  Color get accentColor => Colors.blue;

  @override
  Color get dateColor => Colors.cyan.withOpacity(0.8);

  @override
  Color get clockFaceColor => isDarkMode ? Colors.grey[900]! : Colors.grey[800]!;

  @override
  Color get borderColor => Colors.cyan;

  @override
  Color get boxShadowColor => Colors.cyan.withOpacity(0.2);

  @override
  Color get buttonColor => Colors.grey[800]!;

  @override
  Color get hourHandColor => Colors.cyan;

  @override
  Color get minuteHandColor => Colors.cyan.withOpacity(0.8);

  @override
  String get fontFamily => 'Helvetica Neue';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.cyan,
          blurRadius: 8,
          offset: const Offset(0, 0),
        ),
        Shadow(
          color: Colors.blue.withOpacity(0.5),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue[900]!, Colors.black],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加科技感动画效果
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.cyan.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.cyan.withOpacity(0.3),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.05,
            color: dateColor,
            shadows: [
              Shadow(
                color: Colors.cyan.withOpacity(0.7),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}