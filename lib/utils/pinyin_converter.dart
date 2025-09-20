// 自定义拼音转换工具类，替代pinyin包
// 由于无法正确使用pinyin 3.3.0包，我们创建一个简单的自定义实现

import 'package:pinyin/pinyin.dart';

class PinyinConverter {
  // 判断字符是否为中文
  static bool isChinese(String char) {
    if (char.isEmpty || char.length != 1) {
      return false;
    }
    // Unicode中文字符范围
    final int code = char.codeUnitAt(0);
    return code >= 0x4e00 && code <= 0x9fff;
  }

  // 将中文字符转换为拼音
  // 注意：这是一个简化版本，只包含常用汉字的拼音
  // 完整实现需要更全面的汉字映射表
  static List<String> convert(String char) {
    if (!isChinese(char)) {
      return [char];
    }

    // 简单的汉字拼音映射表
    final Map<String, String> pinyinMap = {
      '你': 'nǐ',
      '好': 'hǎo',
      '世': 'shì',
      '界': 'jiè',
      '中': 'zhōng',
      '国': 'guó',
      '人': 'rén',
      '民': 'mín',
      '我': 'wǒ',
      '爱': 'ài',
      '他': 'tā',
      '她': 'tā',
      '它': 'tā',
      '一': 'yī',
      '二': 'èr',
      '三': 'sān',
      '四': 'sì',
      '五': 'wǔ',
      '六': 'liù',
      '七': 'qī',
      '八': 'bā',
      '九': 'jiǔ',
      '十': 'shí',
      // 可以根据需要添加更多常用汉字
    };
  PinyinHelper.getPinyin(char);
    // 如果字符在映射表中，返回其拼音；否则返回原字符
    return [pinyinMap[char] ?? char];
  }
}

// 创建一个Pinyin类，保持与原代码兼容的API
class Pinyin {
  static bool isChinese(String char) {
    return PinyinConverter.isChinese(char);
  }

  static List<String> convert(String char) {
    return PinyinConverter.convert(char);
  }
}