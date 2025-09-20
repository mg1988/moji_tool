import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(String name) {
    switch (name) {
      case 'mic':
        return Icons.mic;
      case 'speaker':
        return Icons.speaker;
      case 'code':
        return Icons.code;
      case 'color_lens':
        return Icons.color_lens;
      case 'qr_code':
        return Icons.qr_code;
      case 'timer':
        return Icons.timer;
      case 'transform':
        return Icons.transform;
      case 'security':
        return Icons.security;
      case 'compare':
        return Icons.compare;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'link':
        return Icons.link;
      case 'text_format':
        return Icons.text_format;
      case 'regex':
        return Icons.search;  // 使用搜索图标代替正则
      case 'microphone':
        return Icons.mic;
      default:
        return Icons.widgets;  // 默认图标
    }
  }
}
