import 'base_clock_theme.dart';
import 'classic_digital_theme.dart';
import 'neon_theme.dart';
import 'minimal_theme.dart';
import 'retro_theme.dart';
import 'gradient_theme.dart';
import 'digital_panel_theme.dart';
import 'artistic_theme.dart';
import 'futuristic_theme.dart';
import 'analog_theme.dart';
import 'vintage_gold_theme.dart';
import 'retro_arcade_theme.dart';
import 'vintage_typewriter_theme.dart';
import 'retro_radio_theme.dart';
import 'vintage_pocket_watch_theme.dart';
import 'nokia_theme.dart'; // 添加诺基亚主题导入

/// 时钟主题工厂类
/// 用于根据主题ID创建对应的时钟主题实例
class ClockThemeFactory {
  /// 根据主题ID创建对应的时钟主题实例
  static BaseClockTheme createTheme(String themeId, {bool isDarkMode = false}) {
    switch (themeId) {
      case 'classic':
        return ClassicDigitalTheme(isDarkMode: isDarkMode);
      case 'neon':
        return NeonTheme();
      case 'minimal':
        return MinimalTheme(isDarkMode: isDarkMode);
      case 'retro':
        return RetroTheme(isDarkMode: isDarkMode);
      case 'gradient':
        return GradientTheme();
      case 'digital':
        return DigitalPanelTheme();
      case 'artistic':
        return ArtisticTheme();
      case 'futuristic':
        return FuturisticTheme(isDarkMode: isDarkMode);
      case 'analog':
        return AnalogTheme(isDarkMode: isDarkMode);
      case 'vintage_gold':
        return VintageGoldTheme();
      case 'retro_arcade':
        return RetroArcadeTheme();
      case 'vintage_typewriter':
        return VintageTypewriterTheme();
      case 'retro_radio':
        return RetroRadioTheme();
      case 'vintage_pocket_watch':
        return VintagePocketWatchTheme();
      case 'nokia': // 添加诺基亚主题
        return NokiaTheme();
      default:
        return ClassicDigitalTheme(isDarkMode: isDarkMode);
    }
  }

  /// 获取所有可用的主题ID列表
  static List<String> getAllThemeIds() {
    return [
      'classic',
      'neon',
      'minimal',
      'retro',
      'gradient',
      'digital',
      'artistic',
      'futuristic',
      'analog',
      'vintage_gold',
      'retro_arcade',
      'vintage_typewriter',
      'retro_radio',
      'vintage_pocket_watch',
      'nokia', // 添加诺基亚主题ID
    ];
  }

  /// 获取主题名称映射
  static Map<String, String> getThemeNames() {
    return {
      'classic': '经典数字',
      'neon': '霓虹光效',
      'minimal': '极简风格',
      'retro': '复古终端',
      'gradient': '渐变色彩',
      'digital': '数字面板',
      'artistic': '艺术风格',
      'futuristic': '未来科技',
      'analog': '模拟时钟',
      'vintage_gold': '复古金色',
      'retro_arcade': '复古街机',
      'vintage_typewriter': '复古打字机',
      'retro_radio': '复古收音机',
      'vintage_pocket_watch': '复古怀表',
      'nokia': '诺基亚风格', // 添加诺基亚主题名称
    };
  }
}