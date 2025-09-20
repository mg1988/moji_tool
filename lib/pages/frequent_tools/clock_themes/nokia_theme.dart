import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 诺基亚风格时钟主题
/// 模拟经典诺基亚手机的时钟显示风格
class NokiaTheme extends BaseClockTheme {
  @override
  String get id => 'nokia';

  @override
  String get name => '诺基亚风格';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => const Color(0xFF000000); // 经典黑色背景

  @override
  Color get textColor => const Color(0xFF00FF00); // 经典绿色数字

  @override
  Color get accentColor => const Color(0xFF00AA00); // 辅助绿色

  @override
  Color get dateColor => const Color(0xFF00CC00); // 日期颜色

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => Colors.transparent;

  @override
  Color get buttonColor => const Color(0xFF333333);

  @override
  Color get hourHandColor => const Color(0xFF00FF00);

  @override
  Color get minuteHandColor => const Color(0xFF00FF00).withOpacity(0.8);

  @override
  String get fontFamily => 'Courier New'; // 等宽字体模拟像素风格

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: const Color(0xFF00FF00).withOpacity(0.8),
          blurRadius: 2,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => null;

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 格式化时间为 HH:MM:SS 格式
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00AA00),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部装饰线
          Container(
            height: 2,
            width: 200,
            color: const Color(0xFF00AA00),
          ),
          const SizedBox(height: 10),
          // 时间显示
          Text(
            formattedTime,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.18,
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 3, // 字符间距模拟像素风格
              shadows: textShadows,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // 底部装饰线
          Container(
            height: 2,
            width: 200,
            color: const Color(0xFF00AA00),
          ),
        ],
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
    // 使用中文格式显示日期
    String formattedDate = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(currentTime);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF00AA00),
            width: 1,
          ),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.04,
            color: dateColor,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: const Color(0xFF00FF00).withOpacity(0.5),
                blurRadius: 1,
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