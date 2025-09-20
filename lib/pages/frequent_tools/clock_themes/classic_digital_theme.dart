import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 经典数字时钟主题
class ClassicDigitalTheme extends BaseClockTheme {
  final bool isDarkMode;

  ClassicDigitalTheme({this.isDarkMode = false});

  @override
  String get id => 'classic';

  @override
  String get name => '经典数字';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;

  @override
  Color get textColor => isDarkMode ? Colors.cyanAccent : Colors.blueGrey;

  @override
  Color get accentColor => isDarkMode ? Colors.cyan : Colors.blue;

  @override
  Color get dateColor =>
      isDarkMode ? Colors.cyanAccent.withOpacity(0.8) : Colors.blueGrey.withOpacity(0.8);

  @override
  Color get clockFaceColor => isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;

  @override
  Color get borderColor => isDarkMode ? Colors.cyanAccent : Colors.blueGrey;

  @override
  Color get boxShadowColor =>
      isDarkMode ? Colors.cyan.withOpacity(0.3) : Colors.blue.withOpacity(0.3);

  @override
  Color get buttonColor => isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

  @override
  Color get hourHandColor => isDarkMode ? Colors.cyanAccent : Colors.blueGrey;

  @override
  Color get minuteHandColor =>
      isDarkMode ? Colors.cyanAccent.withOpacity(0.8) : Colors.blueGrey.withOpacity(0.8);

  @override
  String get fontFamily => 'Courier';

  @override
  List<Shadow>? get textShadows => isDarkMode
      ? [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ]
      : [];

  @override
  Gradient? get gradient => isDarkMode
      ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[900]!, Colors.black],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[100]!],
        );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    return Text(
      formattedTime,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
        color: textColor,
        fontWeight: FontWeight.bold,
        shadows: textShadows,
      ),
      textAlign: TextAlign.center, // 确保居中显示
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