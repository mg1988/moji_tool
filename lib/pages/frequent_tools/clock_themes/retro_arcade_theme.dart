import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_clock_theme.dart';
import 'dart:math';

/// 复古街机时钟主题
class RetroArcadeTheme extends BaseClockTheme {
  @override
  String get id => 'retro_arcade';

  @override
  String get name => '复古街机';

  @override
  bool get isAnalog => false;

  @override
  Color get backgroundColor => const Color(0xFF000033);

  @override
  Color get textColor => const Color(0xFF00FF00); // 经典绿色

  @override
  Color get accentColor => const Color(0xFFFF00FF); // 品红色

  @override
  Color get dateColor => const Color(0xFF00FFFF); // 青色

  @override
  Color get clockFaceColor => Colors.transparent;

  @override
  Color get borderColor => Colors.transparent;

  @override
  Color get boxShadowColor => const Color(0xFF00FF00).withOpacity(0.5);

  @override
  Color get buttonColor => const Color(0xFF330066);

  @override
  Color get hourHandColor => const Color(0xFF00FF00);

  @override
  Color get minuteHandColor => const Color(0xFF00FF00).withOpacity(0.8);

  @override
  String get fontFamily => 'Courier';

  @override
  List<Shadow>? get textShadows => [
        Shadow(
          color: const Color(0xFF00FF00),
          blurRadius: 15,
          offset: const Offset(0, 0),
        ),
      ];

  @override
  Gradient? get gradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF000033),
          Color(0xFF000066),
          Color(0xFF000033),
        ],
      );

  @override
  Widget buildDigitalClock(BuildContext context, DateTime currentTime) {
    // 修改为一行显示时分秒，不换行
    String formattedTime = DateFormat('HH:mm:ss').format(currentTime);
    
    // 添加像素化效果和闪烁动画
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00FF00),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000033).withOpacity(0.8),
            const Color(0xFF000066).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 主时间显示
          Text(
            formattedTime,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.2,
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
              shadows: textShadows,
            ),
            textAlign: TextAlign.center, // 确保居中显示
          ),
          // 扫描线效果
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: AlwaysStoppedAnimation(DateTime.now().millisecondsSinceEpoch % 2000),
              builder: (context, child) {
                final double position = (DateTime.now().millisecondsSinceEpoch % 2000) / 2000;
                return Transform.translate(
                  offset: Offset(0, position * MediaQuery.of(context).size.height * 0.2),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00FF00).withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF00FF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.05,
            color: dateColor,
            shadows: [
              Shadow(
                color: const Color(0xFFFF00FF),
                blurRadius: 10,
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