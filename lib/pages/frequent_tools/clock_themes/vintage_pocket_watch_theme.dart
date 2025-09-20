import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古怀表时钟主题
class VintagePocketWatchTheme extends BaseClockTheme {
  @override
  String get id => 'vintage_pocket_watch';

  @override
  String get name => '复古怀表';

  @override
  bool get isAnalog => true;

  @override
  Color get backgroundColor => const Color(0xFF2B1B17); // 深棕色

  @override
  Color get textColor => const Color(0xFFC0C0C0); // 银色

  @override
  Color get accentColor => const Color(0xFF8B4513); // 棕色

  @override
  Color get dateColor => const Color(0xFFC0C0C0).withOpacity(0.8);

  @override
  Color get clockFaceColor => const Color(0xFF1A1A1A); // 深黑色

  @override
  Color get borderColor => const Color(0xFFC0C0C0); // 银色

  @override
  Color get boxShadowColor => Colors.black.withOpacity(0.8);

  @override
  Color get buttonColor => const Color(0xFF3B2F2F);

  @override
  Color get hourHandColor => const Color(0xFFC0C0C0);

  @override
  Color get minuteHandColor => const Color(0xFFC0C0C0).withOpacity(0.9);

  @override
  String get fontFamily => 'Times New Roman';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2B1B17),
          Color(0xFF1A1A1A),
          Color(0xFF2B1B17),
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
        // 怀表外框（银色）
        Container(
          width: clockSize * 1.3,
          height: clockSize * 1.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFC0C0C0),
            border: Border.all(
              color: Colors.white,
              width: 8,
            ),
            boxShadow: [
              BoxShadow(
                color: boxShadowColor,
                blurRadius: 20,
                offset: const Offset(10, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
        ),
        // 怀表内框（金色装饰）
        Container(
          width: clockSize * 1.2,
          height: clockSize * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700),
            border: Border.all(
              color: const Color(0xFFFFE4B5),
              width: 4,
            ),
          ),
        ),
        // 怀表主体
        Container(
          width: clockSize * 1.1,
          height: clockSize * 1.1,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2B1B17),
            border: Border.all(
              color: const Color(0xFF3B2F2F),
              width: 3,
            ),
          ),
        ),
        // 时钟表盘
        Container(
          width: clockSize,
          height: clockSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: clockFaceColor,
            border: Border.all(
              color: borderColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          // 表盘刻度和装饰
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 外圈装饰
              Container(
                width: clockSize * 0.95,
                height: clockSize * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC0C0C0).withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              // 主刻度（罗马数字）
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
                        offset: const Offset(0, 20),
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
                          height: 8,
                          color: textColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
              // 内圈装饰
              Container(
                width: clockSize * 0.7,
                height: clockSize * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC0C0C0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              // 品牌标识
              Positioned(
                top: clockSize * 0.25,
                child: Text(
                  "POCKET",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    letterSpacing: 2,
                    shadows: textShadows,
                  ),
                ),
              ),
              Positioned(
                top: clockSize * 0.32,
                child: Text(
                  "WATCH",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    letterSpacing: 2,
                    shadows: textShadows,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 时针（银色）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: hourRotation,
          child: Container(
            width: 8,
            height: clockSize * 0.28, // 增加长度
            decoration: BoxDecoration(
              color: hourHandColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: hourHandColor.withOpacity(0.3),
                  blurRadius: 3,
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
                height: clockSize * 0.1, // 短边长度
                decoration: BoxDecoration(
                  color: hourHandColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // 分针（银色）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: minuteRotation,
          child: Container(
            width: 6,
            height: clockSize * 0.38, // 增加长度
            decoration: BoxDecoration(
              color: minuteHandColor,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: minuteHandColor.withOpacity(0.3),
                  blurRadius: 2,
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
                height: clockSize * 0.09, // 短边长度
                decoration: BoxDecoration(
                  color: minuteHandColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        // 秒针（蓝色）- 修改为指向一边更长的设计
        Transform.rotate(
          angle: secondRotation,
          child: Container(
            width: 2,
            height: clockSize * 0.42, // 增加长度
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(1),
            ),
            alignment: Alignment.bottomCenter,
            // 添加一个小的反向短边
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 2,
                height: clockSize * 0.07, // 短边长度
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
        // 中心装饰（蓝色宝石）
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
        ),
        // 顶部表链连接处
        Positioned(
          top: -clockSize * 0.1,
          child: Container(
            width: 30,
            height: 15,
            decoration: BoxDecoration(
              color: const Color(0xFFC0C0C0),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
        // 底部装饰
        Positioned(
          bottom: -clockSize * 0.05,
          child: Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(10),
            ),
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B2F2F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFC0C0C0),
            width: 1,
          ),
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

  /// 将数字转换为罗马数字
  String _romanNumeral(int number) {
    const romanNumerals = [
      'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'
    ];
    return romanNumerals[number - 1];
  }
}