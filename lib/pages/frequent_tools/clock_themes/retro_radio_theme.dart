import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古收音机时钟主题
class RetroRadioTheme extends BaseClockTheme {
  @override
  String get id => 'retro_radio';

  @override
  String get name => '复古收音机';

  @override
  bool get isAnalog => true;

  @override
  Color get backgroundColor => const Color(0xFF8B4513); // 木质棕色

  @override
  Color get textColor => const Color(0xFFFFD700); // 金色

  @override
  Color get accentColor => const Color(0xFF8B0000); // 深红色

  @override
  Color get dateColor => const Color(0xFFFFD700).withOpacity(0.9);

  @override
  Color get clockFaceColor => const Color(0xFF2F1B14); // 深棕色

  @override
  Color get borderColor => const Color(0xFF3B2F2F); // 深褐色

  @override
  Color get boxShadowColor => Colors.black.withOpacity(0.6);

  @override
  Color get buttonColor => const Color(0xFF5D4037);

  @override
  Color get hourHandColor => const Color(0xFFFFD700);

  @override
  Color get minuteHandColor => const Color(0xFFFFD700).withOpacity(0.8);

  @override
  String get fontFamily => 'Georgia';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: Colors.black.withOpacity(0.8),
          blurRadius: 3,
          offset: const Offset(1, 1),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8B4513),
          Color(0xFF5D2906),
          Color(0xFF8B4513),
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
        // 收音机外壳
        Container(
          width: clockSize * 1.2,
          height: clockSize * 1.2,
          decoration: BoxDecoration(
            color: const Color(0xFF5D2906),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B2F2F),
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: boxShadowColor,
                blurRadius: 15,
                offset: const Offset(8, 8),
              ),
            ],
          ),
        ),
        // 木质纹理装饰
        Container(
          width: clockSize * 1.15,
          height: clockSize * 1.15,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF5D4037),
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
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
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
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                ),
              ),
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
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: textColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
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
                        offset: const Offset(0, 35),
                        child: Text(
                          i.toString(),
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
              // 装饰性小刻度
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
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
              // 品牌标识
              Positioned(
                top: clockSize * 0.3,
                child: Text(
                  "RADIO",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    letterSpacing: 3,
                    shadows: textShadows,
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
            width: 8,
            height: clockSize * 0.28, // 增加长度
            decoration: BoxDecoration(
              color: hourHandColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: hourHandColor.withOpacity(0.5),
                  blurRadius: 5,
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
                height: clockSize * 0.12, // 短边长度
                decoration: BoxDecoration(
                  color: hourHandColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        // 分针 - 修改为指向一边更长的设计
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
                  color: minuteHandColor.withOpacity(0.5),
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
                width: 6,
                height: clockSize * 0.1, // 短边长度
                decoration: BoxDecoration(
                  color: minuteHandColor,
                  borderRadius: BorderRadius.circular(3),
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
            height: clockSize * 0.43, // 增加长度
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.7),
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
                width: 2,
                height: clockSize * 0.08, // 短边长度
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
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        // 顶部天线
        Positioned(
          top: -clockSize * 0.15,
          child: Container(
            width: 2,
            height: clockSize * 0.2,
            color: Colors.grey,
          ),
        ),
        Positioned(
          top: -clockSize * 0.15,
          child: Container(
            width: 20,
            height: 3,
            color: Colors.grey,
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF5D2906),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF3B2F2F),
            width: 2,
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
}