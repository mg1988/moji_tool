import 'package:flutter/material.dart';
import '../models/menu_category.dart';

// 常用工具页面导入
import '../pages/frequent_tools/time_screen_page.dart';
import '../pages/frequent_tools/marquee_page.dart';
import '../pages/frequent_tools/food_decision_page.dart';
import '../pages/frequent_tools/decision_maker_page.dart';
import '../pages/frequent_tools/wooden_fish_page.dart';
import '../pages/frequent_tools/spinning_wheel_page.dart';
import '../pages/frequent_tools/fullscreen_clock_list_page.dart';

// 设备工具页面导入
import '../pages/device_tools/device_info_page.dart';
import '../pages/device_tools/screen_bad_point_page.dart';
import '../pages/device_tools/touch_test_page.dart';

// 图片工具页面导入
import '../pages/image_tools/image_grid_cutter_page.dart';
import '../pages/image_tools/image_merger_page.dart';
import '../pages/image_tools/image_converter_page.dart';
import '../pages/image_tools/image_watermark_page.dart';
import '../pages/image_tools/image_dev_page.dart';
import '../pages/image_tools/image_resizer_page.dart';
import '../pages/image_tools/image_filter_page.dart';

// 开发工具页面导入
import '../pages/dev_tools/color_picker_page.dart';
import '../pages/dev_tools/ascii_table_page.dart';
import '../pages/dev_tools/random_number_generator_page.dart';
import '../pages/dev_tools/uuid_generator_page.dart';
import '../pages/dev_tools/base64_converter_page.dart';
import '../pages/dev_tools/hash_calculator_page.dart';
import '../pages/dev_tools/icon_preview_page.dart';
import '../pages/dev_tools/ip_query_page.dart';
import '../pages/dev_tools/json_formatter_page.dart';
import '../pages/dev_tools/qr_generator_page.dart';
import '../pages/dev_tools/regex_test_page.dart';
import '../pages/dev_tools/text_diff_page.dart';
import '../pages/dev_tools/timestamp_converter_page.dart';
import '../pages/dev_tools/unit_convert_page.dart';

// 文本处理页面导入
import '../pages/text_tools/case_converter_page.dart';
import '../pages/text_tools/text_counter_page.dart';
import '../pages/text_tools/text_duplicate_remover_page.dart';
import '../pages/text_tools/text_replacer_page.dart';
import '../pages/text_tools/text_encryption_page.dart';
import '../pages/text_tools/text_sorter_page.dart';
import '../pages/text_tools/text_splitter_page.dart';
import '../pages/text_tools/text_joiner_page.dart';
import '../pages/text_tools/text_extractor_page.dart';
import '../pages/text_tools/text_formatter_page.dart';
import '../pages/text_tools/text_padder_page.dart';
import '../pages/text_tools/text_filter_page.dart';
import '../pages/text_tools/number_to_chinese_page.dart';
import '../pages/text_tools/chinese_to_pinyin_page.dart';
import '../pages/text_tools/simplified_to_traditional_page.dart';
import '../pages/text_tools/traditional_to_simplified_page.dart';

import '../pages/frequent_tools/world_clock_page.dart';
import '../pages/frequent_tools/file_transfer_page.dart';
import '../pages/frequent_tools/business_card_qr_page.dart';

class MenuData {
  // 优化的分类数据，使用Flutter内置图标
  static final List<MenuCategory> categories = [
    const MenuCategory(
      id: 'frequent',
      name: '常用工具',
      icon: Icons.star,
    ),
    const MenuCategory(
      id: 'image',
      name: '图片工具',
      icon: Icons.image,
    ),
    const MenuCategory(
      id: 'text',
      name: '文本处理',
      icon: Icons.text_snippet,
    ),
    const MenuCategory(
      id: 'dev',
      name: '开发工具',
      icon: Icons.developer_mode,
    ),
    const MenuCategory(
      id: 'device',
      name: '设备工具',
      icon: Icons.devices,
    ),
  ];

  // 优化的菜单项数据，使用Flutter内置图标并优化布局
  static List<MenuItem> getMenuItems(BuildContext context) {
    return [
      // 常用工具分类
      MenuItem(
        id: 'time_screen',
        name: '时间屏幕',
        icon: Icons.schedule_outlined,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TimeScreenPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'marquee',
        name: '手持弹幕',
        icon: Icons.text_rotate_vertical,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MarqueePage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'fullscreen_clock',
        name: '全屏时钟',
        icon: Icons.access_time,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FullscreenClockListPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'food_decision',
        name: '今天吃点啥',
        icon: Icons.fastfood,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodDecisionPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'decision_maker',
        name: '做个决定',
        icon: Icons.question_mark,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DecisionMakerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'wooden_fish',
        name: '敲木鱼',
        icon: Icons.format_list_numbered,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WoodenFishPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'spinning_wheel',
        name: '指尖轮盘',
        icon: Icons.refresh_outlined,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpinningWheelPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'business_card_qr',
        name: '名片二维码',
        icon: Icons.contact_page,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BusinessCardQRPage(),
            ),
          );
        },
      ),
      // MenuItem(
      //   id: 'id_photo',
      //   name: '最美证件照',
      //   icon: Icons.photo_camera,
      //   categoryId: 'frequent',
      //   onTap: (BuildContext context) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const IdPhotoPage(),
      //       ),
      //     );
      //   },
      // ),

      MenuItem(
        id: 'image_grid_cutter',
        name: '九宫格切图',
        icon: Icons.grid_on,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageGridCutterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_merger',
        name: '图片拼接',
        icon: Icons.view_array,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageMergerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_converter',
        name: '格式转换',
        icon: Icons.transform,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageConverterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_watermark',
        name: '图片水印',
        icon: Icons.water_drop,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageWatermarkPage(),
            ),
          );
        },
      ),
      // MenuItem(
      //   id: 'image_dev',
      //   name: '开发图生成',
      //   icon: Icons.code,
      //   categoryId: 'image',
      //   onTap: (BuildContext context) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const ImageDevPage(),
      //       ),
      //     );
      //   },
      // ),
      MenuItem(
        id: 'image_resizer',
        name: '修改尺寸',
        icon: Icons.photo_size_select_large,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageResizerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_filter',
        name: '图片滤镜',
        icon: Icons.filter,
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageFilterPage(),
            ),
          );
        },
      ),

      // 语音工具分类
      // MenuItem(
      //   id: 'voice_to_text',
      //   name: '语音转文字',
      //   icon: Icons.mic_none,
      //   categoryId: 'voice',
      //   onTap: (BuildContext context) {/* 原有功能 */},
      // ),
      // MenuItem(
      //   id: 'text_to_voice',
      //   name: '文字转语音',
      //   icon: Icons.volume_up,
      //   categoryId: 'voice',
      //   onTap: (BuildContext context) {/* 原有功能 */},
      // ),
      
      // 开发工具分类
      MenuItem(
        id: 'json_format',
        name: 'JSON格式化',
        icon: Icons.code,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JsonFormatterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'color_picker',
        name: '颜色选择器',
        icon: Icons.color_lens,
        categoryId: 'dev',
        onTap: (BuildContext context) {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColorPickerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'regex_test',
        name: '正则测试',
        icon: Icons.find_in_page,
        categoryId: 'dev',
        onTap: (BuildContext context) {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegexTestPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'qr_code',
        name: '二维码生成',
        icon: Icons.qr_code_2,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRGeneratorPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'timestamp',
        name: '时间戳转换',
        icon: Icons.schedule,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TimestampConverterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'base64',
        name: 'Base64转换',
        icon: Icons.swap_vert,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Base64ConverterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'hash',
        name: 'Hash计算',
        icon: Icons.security,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HashCalculatorPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'diff',
        name: '文本对比',
        icon: Icons.compare_arrows,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextDiffPage(),
            ),
          );
        },
      ),
      // MenuItem(
      //   id: 'ip_query',
      //   name: 'IP地址查询',
      //   icon: Icons.lan,
      //   categoryId: 'dev',
      //   onTap: (BuildContext context) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const IPQueryPage(),
      //       ),
      //     );
      //   },
      // ),
      MenuItem(
        id: 'unit_convert',
        name: '单位转换',
        icon: Icons.change_circle,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UnitConvertPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'ascii_table',
        name: 'ASCII码表',
        icon: Icons.text_rotate_vertical,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AsciiTablePage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'uuid_generator',
        name: 'UUID生成器',
        icon: Icons.key,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UuidGeneratorPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'random_number',
        name: '随机数生成器',
        icon: Icons.casino,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RandomNumberGeneratorPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'icon_preview',
        name: '图标预览',
        icon: Icons.widgets,
        categoryId: 'dev',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IconPreviewPage(),
            ),
          );
        },
      ),

      // 文本处理分类
      MenuItem(
        id: 'case_converter',
        name: '文本大小写转换',
        icon: Icons.text_format,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CaseConverterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_counter',
        name: '文本字数统计',
        icon: Icons.format_list_numbered,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextCounterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'duplicate_remover',
        name: '文本去重',
        icon: Icons.clear_all,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextDuplicateRemoverPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_replacer',
        name: '文本替换',
        icon: Icons.find_replace,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextReplacerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_encryption',
        name: '文本加密解密',
        icon: Icons.lock,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextEncryptionPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_sorter',
        name: '文本排序',
        icon: Icons.sort,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextSorterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_splitter',
        name: '文本分割',
        icon: Icons.text_decrease,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextSplitterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_joiner',
        name: '文本连接',
        icon: Icons.link,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextJoinerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_extractor',
        name: '文本提取',
        icon: Icons.extension,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextExtractorPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_formatter',
        name: '文本格式化',
        icon: Icons.format_align_left,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextFormatterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_padder',
        name: '文本补全',
        icon: Icons.format_indent_increase,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextPadderPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'text_filter',
        name: '文本过滤',
        icon: Icons.filter_list_alt,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TextFilterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'number_to_chinese',
        name: '数字转中文',
        icon: Icons.numbers,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NumberToChinesePage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'chinese_to_pinyin',
        name: '中文转拼音',
        icon: Icons.abc,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChineseToPinyinPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'simplified_to_traditional',
        name: '中文转繁体',
        icon: Icons.language,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SimplifiedToTraditionalPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'traditional_to_simplified',
        name: '繁体转中文',
        icon: Icons.translate,
        categoryId: 'text',
        onTap: (BuildContext context) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const TraditionalToSimplifiedPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'world_clock',
        name: '世界时钟',
        icon: Icons.access_time_filled,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorldClockPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'file_transfer',
        name: '文件快传',
        icon: Icons.share,
        categoryId: 'frequent',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileTransferPage(),
            ),
          );
        },
      ),
      
      // 设备工具分类
      MenuItem(
        id: 'device_info',
        name: '设备信息',
        icon: Icons.info_outline,
        categoryId: 'device',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeviceInfoPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'screen_bad_point',
        name: '屏幕坏点检测',
        icon: Icons.smartphone_outlined,
        categoryId: 'device',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenBadPointPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'touch_test',
        name: '触摸检测',
        icon: Icons.fingerprint,
        categoryId: 'device',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TouchTestPage(),
            ),
          );
        },
      ),
    ];
  }
}