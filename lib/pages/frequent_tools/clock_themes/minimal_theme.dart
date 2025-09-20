import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 极简风格时钟主题
class MinimalTheme extends BaseClockTheme {
  final bool isDarkMode;

  MinimalTheme({this.isDarkMode = false});

  @override
  String get id => 'minimal';

  @override
  String get name => '极简风格';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;

  @override
  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  @override
  Color get accentColor => isDarkMode ? Colors.grey : Colors.grey;

  @override
  Color get dateColor =>
      isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.transparent;

  @override
  Color get buttonColor => isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

  @override
  Color get hourHandColor => isDarkMode ? Colors.white : Colors.black;

  @override
  Color get minuteHandColor =>
      isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8);

  @override
  String get fontFamily => 'Helvetica';

  @override
  List<Shadow>? get textShadows => [];

  @override
  Gradient? get gradient => null;

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
        fontWeight: FontWeight.w300, // 极细字体
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
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}