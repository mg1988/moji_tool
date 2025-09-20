import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古打字机时钟主题
class VintageTypewriterTheme extends BaseClockTheme {
  @override
  String get id => 'vintage_typewriter';

  @override
  String get name => '复古打字机';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => const Color(0xFF4A4A4A); // 深灰色

  @override
  Color get textColor => const Color(0xFFE0E0E0); // 米白色

  @override
  Color get accentColor => const Color(0xFF3A3A3A);

  @override
  Color get dateColor => const Color(0xFFB0B0B0);

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => const Color(0xFF2A2A2A);

  @override
  Color get boxShadowColor => Colors.black.withOpacity(0.5);

  @override
  Color get buttonColor => const Color(0xFF5A5A5A);

  @override
  Color get hourHandColor => const Color(0xFFE0E0E0);

  @override
  Color get minuteHandColor => const Color(0xFFE0E0E0).withOpacity(0.8);

  @override
  String get fontFamily => 'Courier New';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.black.withOpacity(0.7),
          blurRadius: 2,
          offset: const Offset(2, 2),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4A4A4A),
          Color(0xFF3A3A3A),
          Color(0xFF2A2A2A),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 模拟打字机效果
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: boxShadowColor,
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 打字机装饰元素
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) {
              return Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index % 5 == 0 ? accentColor : textColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          // 时间显示（模拟打字机字体）
          Text(
            formattedTime,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.18,
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 8, // 字符间距
              shadows: textShadows,
            ),
            textAlign: TextAlign.center, // 确保居中显示
          ),
          const SizedBox(height: 15),
          // 底部装饰
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) {
              return Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index % 5 == 0 ? accentColor : textColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
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
    // 确保显示中文年月日星期，格式统一
    String formattedDate = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(currentTime);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFF3A3A3A),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.045,
            color: dateColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 1,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}