import 'package:flutter/material.dart';
import 'dart:math';

/// 颜色扩展类，提供一些常用的颜色操作方法
extension ColorExtension on Color {
  /// 使颜色变暗
  /// [factor] - 变暗的程度，取值范围为0-1，默认0.1
  Color darken([double factor = 0.1]) {
    assert(factor >= 0 && factor <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// 使颜色变亮
  /// [factor] - 变亮的程度，取值范围为0-1，默认0.1
  Color lighten([double factor = 0.1]) {
    assert(factor >= 0 && factor <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + factor).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// 调整颜色的饱和度
  /// [factor] - 饱和度调整因子，大于1增加饱和度，小于1减少饱和度
  Color saturate(double factor) {
    assert(factor > 0);
    final hsl = HSLColor.fromColor(this);
    final hslSaturated = hsl.withSaturation((hsl.saturation * factor).clamp(0.0, 1.0));
    return hslSaturated.toColor();
  }
  
  /// 计算颜色的对比度
  /// 参考WCAG标准计算两个颜色之间的对比度
  double contrast(Color other) {
    final luminance1 = computeLuminance();
    final luminance2 = other.computeLuminance();
    final brightest = max<double>(luminance1, luminance2);
    final darkest = min<double>(luminance1, luminance2);
    return (brightest + 0.05) / (darkest + 0.05);
  }
  
  /// 混合两个颜色
  /// [other] - 要混合的另一个颜色
  /// [factor] - 混合比例，0表示完全是this，1表示完全是other
  Color mix(Color other, double factor) {
    assert(factor >= 0 && factor <= 1);
    return Color.lerp(this, other, factor) ?? this;
  }
  
  /// 创建一个透明度不同的颜色
  /// [opacity] - 新的透明度，取值范围为0-1
  Color withOpacity(double opacity) {
    return Color.fromARGB(
      (opacity * 255).round(),
      red,
      green,
      blue,
    );
  }
}