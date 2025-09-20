import 'package:flutter/material.dart';
import 'dart:math';

/// 基础时钟主题抽象类
/// 所有时钟主题都需要继承此类并实现相应的方法
abstract class BaseClockTheme {
  /// 主题ID
  String get id;

  /// 主题名称
  String get name;

  /// 是否为模拟时钟
  bool get isAnalog;

  /// 构建数字时钟显示组件
  Widget buildDigitalClock(BuildContext context, DateTime currentTime);

  /// 构建模拟时钟显示组件
  Widget buildAnalogClock(BuildContext context, DateTime currentTime);

  /// 构建日期显示组件
  Widget buildDateDisplay(BuildContext context, DateTime currentTime);

  /// 获取背景颜色
  Color get backgroundColor;

  /// 获取文本颜色
  Color get textColor;

  /// 获取装饰颜色
  Color get accentColor;

  /// 获取日期颜色
  Color get dateColor;

  /// 获取时钟表面颜色
  Color get clockFaceColor;

  /// 获取边框颜色
  Color get borderColor;

  /// 获取阴影颜色
  Color get boxShadowColor;

  /// 获取按钮颜色
  Color get buttonColor;

  /// 获取时针颜色
  Color get hourHandColor;

  /// 获取分针颜色
  Color get minuteHandColor;

  /// 获取字体族
  String get fontFamily;

  /// 获取文本阴影效果
  List<Shadow>? get textShadows;

  /// 获取背景渐变效果
  Gradient? get gradient;

  /// 获取时针高度
  double getHourHandHeight(BuildContext context) => 
      min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.7 * 0.35;

  /// 获取分针高度
  double getMinuteHandHeight(BuildContext context) => 
      min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.7 * 0.45;

  /// 获取秒针高度
  double getSecondHandHeight(BuildContext context) => 
      min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.7 * 0.5;
}