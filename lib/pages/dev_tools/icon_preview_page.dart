import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class IconPreviewPage extends StatefulWidget {
  const IconPreviewPage({Key? key}) : super(key: key);

  @override
  State<IconPreviewPage> createState() => _IconPreviewPageState();
}

class _IconPreviewPageState extends State<IconPreviewPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, IconData> _iconCategories = {};
  List<MapEntry<String, IconData>> _filteredIcons = [];
  String? _selectedIconName;
  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterIcons();
      });
    });
  }

  void _loadIcons() {
    // 加载Flutter内置图标
    _iconCategories = {
      // Material Icons - 常用图标
      'add': Icons.add,
      'arrow_back': Icons.arrow_back,
      'arrow_forward': Icons.arrow_forward,
      'check': Icons.check,
      'close': Icons.close,
      'delete': Icons.delete,
      'edit': Icons.edit,
      'home': Icons.home,
      'info': Icons.info,
      'list': Icons.list,
      'menu': Icons.menu,
      'search': Icons.search,
      'settings': Icons.settings,
      'share': Icons.share,
      'star': Icons.star,
      'user': Icons.person,
      'warning': Icons.warning,
      'wifi': Icons.wifi,
      'bell': Icons.notifications,
      'camera': Icons.camera,
      'calendar': Icons.calendar_today,
      'map': Icons.map,
      'message': Icons.message,
      'phone': Icons.phone,
      'lock': Icons.lock,
      'unlock': Icons.lock_open,
      'cloud': Icons.cloud,
      'download': Icons.download,
      'upload': Icons.upload,
      'refresh': Icons.refresh,
      'play': Icons.play_arrow,
      'pause': Icons.pause,
      'stop': Icons.stop,
      'volume_up': Icons.volume_up,
      'volume_off': Icons.volume_off,
      'image': Icons.image,
      'video': Icons.video_library,
      'music': Icons.music_note,
      'book': Icons.book,
      'file': Icons.file_copy,
      'folder': Icons.folder,
      'link': Icons.link,
      'copy': Icons.copy,
      'cut': Icons.cut,
      'paste': Icons.paste,
      'save': Icons.save,
      'filter': Icons.filter_list,
      'sort': Icons.sort,
      'filter_alt': Icons.filter_alt,
      'more_vert': Icons.more_vert,
      'more_horiz': Icons.more_horiz,
      'expand_less': Icons.expand_less,
      'expand_more': Icons.expand_more,
      'chevron_left': Icons.chevron_left,
      'chevron_right': Icons.chevron_right,
      'circle': Icons.circle,
      'circle_outline': Icons.circle_outlined,
      'square': Icons.square,
      'square_outline': Icons.square_outlined,
      'check_circle': Icons.check_circle,
      'check_circle_outline': Icons.check_circle_outlined,
      'radio_button_checked': Icons.radio_button_checked,
      'radio_button_unchecked': Icons.radio_button_unchecked,
      'favorite': Icons.favorite,
      'favorite_border': Icons.favorite_border,
      'heart': Icons.favorite,
      'thumbs_up': Icons.thumb_up,
      'thumbs_down': Icons.thumb_down,
      'star_rate': Icons.star_rate,
      'star_half': Icons.star_half,
      'star_border': Icons.star_border,
      'star_outline': Icons.star_outline,
      'star_half_outline': Icons.star_half_outlined,
      'email': Icons.email,
      'send': Icons.send,
      'reply': Icons.reply,
      'forward': Icons.forward,
      'attach_file': Icons.attach_file,
      'attachment': Icons.attachment,
      'insert_drive_file': Icons.insert_drive_file,
      'insert_photo': Icons.insert_photo,
      'mic': Icons.mic,
      'mic_off': Icons.mic_off,
      'speaker': Icons.volume_up,
      'speaker_phone': Icons.speaker_phone,
      'headphones': Icons.headphones,
      'earbuds': Icons.hearing,
      'plus_one': Icons.plus_one,
      'minus_one': Icons.exposure_neg_1,
      'number_0': Icons.numbers,
      'number_1': Icons.looks_one,
      'number_2': Icons.looks_two,
      'number_3': Icons.looks_3,
      'number_4': Icons.looks_4,
      'number_5': Icons.looks_5,
      'number_6': Icons.looks_6,
      'a': Icons.abc,
      'b': Icons.abc,
      'c': Icons.abc,
      'd': Icons.abc,
      'e': Icons.abc,
      'f': Icons.abc,
      'g': Icons.abc,
      'h': Icons.abc,
      'i': Icons.abc,
      'j': Icons.abc,
      'k': Icons.abc,
      'l': Icons.abc,
      'm': Icons.abc,
      'n': Icons.abc,
      'o': Icons.abc,
      'p': Icons.abc,
      'q': Icons.abc,
      'r': Icons.abc,
      's': Icons.abc,
      't': Icons.abc,
      'u': Icons.abc,
      'v': Icons.abc,
      'w': Icons.abc,
      'x': Icons.abc,
      'y': Icons.abc,
      'z': Icons.abc,
      'alpha_a': Icons.abc,
      'alpha_b': Icons.abc,
      'alpha_c': Icons.abc,
      'alpha_d': Icons.abc,
      'alpha_e': Icons.abc,
      'alpha_f': Icons.abc,
      'alpha_g': Icons.abc,
      'alpha_h': Icons.abc,
      'alpha_i': Icons.abc,
      'alpha_j': Icons.abc,
      'alpha_k': Icons.abc,
      'alpha_l': Icons.abc,
      'alpha_m': Icons.abc,
      'alpha_n': Icons.abc,
      'alpha_o': Icons.abc,
      'alpha_p': Icons.abc,
      'alpha_q': Icons.abc,
      'alpha_r': Icons.abc,
      'alpha_s': Icons.abc,
      'alpha_t': Icons.abc,
      'alpha_u': Icons.abc,
      'alpha_v': Icons.abc,
      'alpha_w': Icons.abc,
      'alpha_x': Icons.abc,
      'alpha_y': Icons.abc,
      'alpha_z': Icons.abc,
    };
    _filterIcons();
  }

  void _filterIcons() {
    if (_searchQuery.isEmpty) {
      _filteredIcons = _iconCategories.entries.toList();
    } else {
      _filteredIcons = _iconCategories.entries
          .where((entry) => entry.key.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'Flutter图标预览',
      child: Column(
        children: [
          // 搜索框
          ToolCard(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索图标名称...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // 选中的图标信息
          if (_selectedIcon != null && _selectedIconName != null) 
            ToolCard(
              child: Column(
                children: [
                  const Text(
                    '选中的图标',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(_selectedIcon, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text('图标名称: ${_selectedIconName!.replaceAllMapped(
                      RegExp(r'[A-Z]'), 
                      (match) => ' ${match.group(0)!.toLowerCase()}'
                    ).trim()}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _copyToClipboard('Icons.$_selectedIconName'),
                        child: const Text('复制引用代码'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _copyToClipboard(_selectedIconName!),
                        child: const Text('复制图标名称'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('使用方法:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Icon(Icons.$_selectedIconName, size: 24)'),
                  ),
                ],
              ),
            ),

          // 图标网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: _filteredIcons.length,
              itemBuilder: (context, index) {
                final iconEntry = _filteredIcons[index];
                return ToolCard(
                  onTap: () {
                    setState(() {
                      _selectedIconName = iconEntry.key;
                      _selectedIcon = iconEntry.value;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconEntry.value, size: 32, color: Colors.blue),
                      Text(
                        iconEntry.key,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,

                      ),
                    ],
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}