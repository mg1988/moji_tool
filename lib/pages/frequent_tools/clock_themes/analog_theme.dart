import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 模拟时钟主题
class AnalogTheme extends BaseClockTheme {
  final bool isDarkMode;

  AnalogTheme({this.isDarkMode = false});

  @override
  String get id => 'analog';

  @override
  String get name => '模拟时钟';

  @override
  bool get isAnalog => true;

  @override
  Color get backgroundColor => isDarkMode ? Colors.grey[900]! : Colors.white;

  @override
  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  @override
  Color get accentColor => isDarkMode ? Colors.red : Colors.blue;

  @override
  Color get dateColor =>
      isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8);

  @override
  Color get clockFaceColor => isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;

  @override
  Color get borderColor => isDarkMode ? Colors.white : Colors.black;

  @override
  Color get boxShadowColor =>
      isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.5);

  @override
  Color get buttonColor => isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

  @override
  Color get hourHandColor => isDarkMode ? Colors.white : Colors.black;

  @override
  Color get minuteHandColor =>
      isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8);

  @override
  String get fontFamily => 'Arial';

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
          colors: [Colors.grey[800]!, Colors.grey[900]!],
        )
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[100]!, Colors.white],
        );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 此主题为模拟时钟，不实现数字时钟
    return const SizedBox.shrink();
  }

  @override
  Widget buildAnalogClock(BuildContext context, DateTime currentTime) {
    final double clockSize = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.7;
    
    // 计算时针、分针、秒针的角度
    final double hourRotation = (currentTime.hour % 12 + currentTime.minute / 60) * 30 * pi / 180;
    final double minuteRotation = (currentTime.minute + currentTime.second / 60) * 6 * pi / 180;
    final double secondRotation = currentTime.second * 6 * pi / 180;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 时钟表盘
        Container(
          width: clockSize,
          height: clockSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: clockFaceColor,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: boxShadowColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: boxShadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          // 表盘刻度和数字
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 小时刻度和数字
              for (int i = 1; i <= 12; i++)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: i * 30 * pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 2,
                        height: 15,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              // 小时数字
              for (int i = 1; i <= 12; i++)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: i * 30 * pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: const Offset(0, 25),
                        child: Text(
                          i.toString(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 时针 - 修改为指向一边更长的设计
        Transform.rotate(
          angle: hourRotation,
          child: Container(
            width: 6,
            height: clockSize * 0.3, // 增加长度
            decoration: BoxDecoration(
              color: hourHandColor,
              borderRadius: BorderRadius.circular(3),
            ),
            // 调整对齐方式，使指针指向的一边更长
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 6,
                height: clockSize * 0.1, // 短边长度
                decoration: BoxDecoration(
                  color: hourHandColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        // 分针 - 修改为指向一边更长的设计
        Transform.rotate(
          angle: minuteRotation,
          child: Container(
            width: 4,
            height: clockSize * 0.4, // 增加长度
            decoration: BoxDecoration(
              color: minuteHandColor,
              borderRadius: BorderRadius.circular(2),
            ),
            // 调整对齐方式，使指针指向的一边更长
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 4,
                height: clockSize * 0.08, // 短边长度
                decoration: BoxDecoration(
                  color: minuteHandColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        // 秒针 - 修改为指向一边更长的设计
        Transform.rotate(
          angle: secondRotation,
          child: Container(
            width: 2,
            height: clockSize * 0.45, // 增加长度
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(1),
            ),
            // 调整对齐方式，使指针指向的一边更长
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 2,
                height: clockSize * 0.06, // 短边长度
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        // 中心点
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor,
          ),
        ),
      ],
    );
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