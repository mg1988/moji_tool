import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古金色时钟主题
class VintageGoldTheme extends BaseClockTheme {
  @override
  String get id => 'vintage_gold';

  @override
  String get name => '复古金色';

  @override
  bool get isAnalog => true;

  @override
  Color get backgroundColor => const Color(0xFF1a1a1a);

  @override
  Color get textColor => const Color(0xFFFFD700); // 金色

  @override
  Color get accentColor => const Color(0xFFFFD700);

  @override
  Color get dateColor => const Color(0xFFFFD700).withOpacity(0.8);

  @override
  Color get clockFaceColor => const Color(0xFF2a2a2a);

  @override
  Color get borderColor => const Color(0xFFFFD700);

  @override
  Color get boxShadowColor => const Color(0xFFFFD700).withOpacity(0.3);

  @override
  Color get buttonColor => const Color(0xFF3a3a3a);

  @override
  Color get hourHandColor => const Color(0xFFFFD700);

  @override
  Color get minuteHandColor => const Color(0xFFFFD700).withOpacity(0.8);

  @override
  String get fontFamily => 'Times New Roman';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: const Color(0xFFFFD700).withOpacity(0.7),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1a1a1a),
          Color(0xFF0a0a0a),
        ],
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
        // 外层装饰环
        Container(
          width: clockSize,
          height: clockSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              width: 8,
            ),
          ),
        ),
        // 装饰环内侧
        Container(
          width: clockSize * 0.9,
          height: clockSize * 0.9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              width: 4,
            ),
          ),
        ),
        // 时钟表盘
        Container(
          width: clockSize * 0.8,
          height: clockSize * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: clockFaceColor,
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: boxShadowColor,
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          // 表盘刻度和装饰
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 主刻度
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
                        width: 3,
                        height: 20,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              // 小时数字（罗马数字）
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
                        offset: const Offset(0, 35),
                        child: Text(
                          _romanNumeral(i),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                            shadows: textShadows,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // 装饰性花纹
              for (int i = 1; i <= 60; i++)
                if (i % 5 != 0) // 避免与主刻度重叠
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: i * 6 * pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 1,
                          height: 10,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        // 时针（金色装饰）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: hourRotation,
          child: Container(
            width: 8,
            height: clockSize * 0.8 * 0.3, // 增加长度
            decoration: BoxDecoration(
              color: hourHandColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: hourHandColor.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 8,
                height: clockSize * 0.8 * 0.12, // 短边长度
                decoration: BoxDecoration(
                  color: hourHandColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // 分针（金色装饰）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: minuteRotation,
          child: Container(
            width: 6,
            height: clockSize * 0.8 * 0.4, // 增加长度
            decoration: BoxDecoration(
              color: minuteHandColor,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: minuteHandColor.withOpacity(0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 6,
                height: clockSize * 0.8 * 0.1, // 短边长度
                decoration: BoxDecoration(
                  color: minuteHandColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        // 秒针（红色装饰）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: secondRotation,
          child: Container(
            width: 2,
            height: clockSize * 0.8 * 0.45, // 增加长度
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 2,
                height: clockSize * 0.8 * 0.08, // 短边长度
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        // 中心装饰
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
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

  /// 将数字转换为罗马数字
  String _romanNumeral(int number) {
    const romanNumerals = [
      'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'
    ];
    return romanNumerals[number - 1];
  }
}