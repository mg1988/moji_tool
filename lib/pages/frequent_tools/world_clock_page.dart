import 'package:flutter/material.dart';
import 'dart:async';
import '../../components/base_tool_page.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class ClockCity {
  final String name;
  final String timeZone;
  final String flagEmoji;

  ClockCity({
    required this.name,
    required this.timeZone,
    required this.flagEmoji,
  });
}

class _WorldClockPageState extends State<WorldClockPage> {
  List<ClockCity> _cities = [];
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // 初始化时区数据
    tz_data.initializeTimeZones();
    
    // 初始化一些主要城市
    _cities = [
      ClockCity(name: '北京', timeZone: 'Asia/Shanghai', flagEmoji: '🇨🇳'),
      ClockCity(name: '纽约', timeZone: 'America/New_York', flagEmoji: '🇺🇸'),
      ClockCity(name: '伦敦', timeZone: 'Europe/London', flagEmoji: '🇬🇧'),
      ClockCity(name: '东京', timeZone: 'Asia/Tokyo', flagEmoji: '🇯🇵'),
      ClockCity(name: '悉尼', timeZone: 'Australia/Sydney', flagEmoji: '🇦🇺'),
    ];
    
    // 启动定时器每秒更新时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 获取指定时区的时间
  DateTime _getTimeForCity(ClockCity city) {
    try {
      // 使用timezone库正确处理时区
      final location = tz.getLocation(city.timeZone);
      final now = tz.TZDateTime.now(location);
      return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
    } catch (e) {
      // 如果时区不存在，返回本地时间
      print('时区解析失败: ${city.timeZone}, 错误: $e');
      return _currentTime;
    }
  }

  void _addCity() {
    // 预定义的全球主要城市
    List<ClockCity> availableCities = [
      // 亚洲城市
      ClockCity(name: '迪拜', timeZone: 'Asia/Dubai', flagEmoji: '🇦🇪'),
      ClockCity(name: '新加坡', timeZone: 'Asia/Singapore', flagEmoji: '🇸🇬'),
      ClockCity(name: '首尔', timeZone: 'Asia/Seoul', flagEmoji: '🇰🇷'),
      ClockCity(name: '曼谷', timeZone: 'Asia/Bangkok', flagEmoji: '🇹🇭'),
      ClockCity(name: '雅加达', timeZone: 'Asia/Jakarta', flagEmoji: '🇮🇩'),
      ClockCity(name: '马尼拉', timeZone: 'Asia/Manila', flagEmoji: '🇵🇭'),
      ClockCity(name: '孟买', timeZone: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      ClockCity(name: '德里', timeZone: 'Asia/Kolkata', flagEmoji: '🇮🇳'),
      ClockCity(name: '达卡', timeZone: 'Asia/Dhaka', flagEmoji: '🇧🇩'),
      ClockCity(name: '加德满都', timeZone: 'Asia/Kathmandu', flagEmoji: '🇳🇵'),
      ClockCity(name: '伊斯兰堡', timeZone: 'Asia/Karachi', flagEmoji: '🇵🇰'),
      ClockCity(name: '台北', timeZone: 'Asia/Taipei', flagEmoji: '🇹🇼'),
      ClockCity(name: '香港', timeZone: 'Asia/Hong_Kong', flagEmoji: '🇭🇰'),
      ClockCity(name: '澳门', timeZone: 'Asia/Macau', flagEmoji: '🇲🇴'),
      ClockCity(name: '吉隆坡', timeZone: 'Asia/Kuala_Lumpur', flagEmoji: '🇲🇾'),
      ClockCity(name: '河内', timeZone: 'Asia/Ho_Chi_Minh', flagEmoji: '🇻🇳'),
      ClockCity(name: '金边', timeZone: 'Asia/Phnom_Penh', flagEmoji: '🇰🇭'),
      ClockCity(name: '万象', timeZone: 'Asia/Vientiane', flagEmoji: '🇱🇦'),
      ClockCity(name: '仰光', timeZone: 'Asia/Yangon', flagEmoji: '🇲🇲'),
      ClockCity(name: '科伦坡', timeZone: 'Asia/Colombo', flagEmoji: '🇱🇰'),
      ClockCity(name: '德黑兰', timeZone: 'Asia/Tehran', flagEmoji: '🇮🇷'),
      ClockCity(name: '巴格达', timeZone: 'Asia/Baghdad', flagEmoji: '🇮🇶'),
      ClockCity(name: '利雅得', timeZone: 'Asia/Riyadh', flagEmoji: '🇸🇦'),
      ClockCity(name: '多哈', timeZone: 'Asia/Qatar', flagEmoji: '🇶🇦'),
      ClockCity(name: '科威特', timeZone: 'Asia/Kuwait', flagEmoji: '🇰🇼'),
      ClockCity(name: '马斯喀特', timeZone: 'Asia/Muscat', flagEmoji: '🇴🇲'),
      ClockCity(name: '阿布扎比', timeZone: 'Asia/Dubai', flagEmoji: '🇦🇪'),
      ClockCity(name: '巴林', timeZone: 'Asia/Bahrain', flagEmoji: '🇧🇭'),
      ClockCity(name: '安曼', timeZone: 'Asia/Amman', flagEmoji: '🇯🇴'),
      ClockCity(name: '大马士革', timeZone: 'Asia/Damascus', flagEmoji: '🇸🇾'),
      ClockCity(name: '贝鲁特', timeZone: 'Asia/Beirut', flagEmoji: '🇱🇧'),
      ClockCity(name: '耶路撒冷', timeZone: 'Asia/Jerusalem', flagEmoji: '🇮🇱'),
      ClockCity(name: '塔什干', timeZone: 'Asia/Tashkent', flagEmoji: '🇺🇿'),
      ClockCity(name: '阿拉木图', timeZone: 'Asia/Almaty', flagEmoji: '🇰🇿'),
      ClockCity(name: '比什凯克', timeZone: 'Asia/Bishkek', flagEmoji: '🇰🇬'),
      ClockCity(name: '杜尚别', timeZone: 'Asia/Dushanbe', flagEmoji: '🇹🇯'),
      ClockCity(name: '阿什哈巴德', timeZone: 'Asia/Ashgabat', flagEmoji: '🇹🇲'),
      ClockCity(name: '喀布尔', timeZone: 'Asia/Kabul', flagEmoji: '🇦🇫'),
      ClockCity(name: '乌兰巴托', timeZone: 'Asia/Ulaanbaatar', flagEmoji: '🇲🇳'),
      ClockCity(name: '平壤', timeZone: 'Asia/Pyongyang', flagEmoji: '🇰🇵'),
      
      // 欧洲城市
      ClockCity(name: '巴黎', timeZone: 'Europe/Paris', flagEmoji: '🇫🇷'),
      ClockCity(name: '柏林', timeZone: 'Europe/Berlin', flagEmoji: '🇩🇪'),
      ClockCity(name: '罗马', timeZone: 'Europe/Rome', flagEmoji: '🇮🇹'),
      ClockCity(name: '马德里', timeZone: 'Europe/Madrid', flagEmoji: '🇪🇸'),
      ClockCity(name: '阿姆斯特丹', timeZone: 'Europe/Amsterdam', flagEmoji: '🇳🇱'),
      ClockCity(name: '布鲁塞尔', timeZone: 'Europe/Brussels', flagEmoji: '🇧🇪'),
      ClockCity(name: '苏黎世', timeZone: 'Europe/Zurich', flagEmoji: '🇨🇭'),
      ClockCity(name: '维也纳', timeZone: 'Europe/Vienna', flagEmoji: '🇦🇹'),
      ClockCity(name: '布拉格', timeZone: 'Europe/Prague', flagEmoji: '🇨🇿'),
      ClockCity(name: '华沙', timeZone: 'Europe/Warsaw', flagEmoji: '🇵🇱'),
      ClockCity(name: '布达佩斯', timeZone: 'Europe/Budapest', flagEmoji: '🇭🇺'),
      ClockCity(name: '布加勒斯特', timeZone: 'Europe/Bucharest', flagEmoji: '🇷🇴'),
      ClockCity(name: '索菲亚', timeZone: 'Europe/Sofia', flagEmoji: '🇧🇬'),
      ClockCity(name: '贝尔格莱德', timeZone: 'Europe/Belgrade', flagEmoji: '🇷🇸'),
      ClockCity(name: '雅典', timeZone: 'Europe/Athens', flagEmoji: '🇬🇷'),
      ClockCity(name: '伊斯坦布尔', timeZone: 'Europe/Istanbul', flagEmoji: '🇹🇷'),
      ClockCity(name: '莫斯科', timeZone: 'Europe/Moscow', flagEmoji: '🇷🇺'),
      ClockCity(name: '基辅', timeZone: 'Europe/Kiev', flagEmoji: '🇺🇦'),
      ClockCity(name: '明斯克', timeZone: 'Europe/Minsk', flagEmoji: '🇧🇾'),
      ClockCity(name: '里加', timeZone: 'Europe/Riga', flagEmoji: '🇱🇻'),
      ClockCity(name: '维尔纽斯', timeZone: 'Europe/Vilnius', flagEmoji: '🇱🇹'),
      ClockCity(name: '塔林', timeZone: 'Europe/Tallinn', flagEmoji: '🇪🇪'),
      ClockCity(name: '赫尔辛基', timeZone: 'Europe/Helsinki', flagEmoji: '🇫🇮'),
      ClockCity(name: '斯德哥尔摩', timeZone: 'Europe/Stockholm', flagEmoji: '🇸🇪'),
      ClockCity(name: '奥斯陆', timeZone: 'Europe/Oslo', flagEmoji: '🇳🇴'),
      ClockCity(name: '哥本哈根', timeZone: 'Europe/Copenhagen', flagEmoji: '🇩🇰'),
      ClockCity(name: '雷克雅维克', timeZone: 'Atlantic/Reykjavik', flagEmoji: '🇮🇸'),
      ClockCity(name: '都柏林', timeZone: 'Europe/Dublin', flagEmoji: '🇮🇪'),
      ClockCity(name: '里斯本', timeZone: 'Europe/Lisbon', flagEmoji: '🇵🇹'),
      
      // 北美洲城市
      ClockCity(name: '洛杉矶', timeZone: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      ClockCity(name: '旧金山', timeZone: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      ClockCity(name: '芝加哥', timeZone: 'America/Chicago', flagEmoji: '🇺🇸'),
      ClockCity(name: '丹佛', timeZone: 'America/Denver', flagEmoji: '🇺🇸'),
      ClockCity(name: '费城', timeZone: 'America/New_York', flagEmoji: '🇺🇸'),
      ClockCity(name: '波士顿', timeZone: 'America/New_York', flagEmoji: '🇺🇸'),
      ClockCity(name: '华盛顿', timeZone: 'America/New_York', flagEmoji: '🇺🇸'),
      ClockCity(name: '迈阿密', timeZone: 'America/New_York', flagEmoji: '🇺🇸'),
      ClockCity(name: '拉斯维加斯', timeZone: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      ClockCity(name: '西雅图', timeZone: 'America/Los_Angeles', flagEmoji: '🇺🇸'),
      ClockCity(name: '安克雷奇', timeZone: 'America/Anchorage', flagEmoji: '🇺🇸'),
      ClockCity(name: '檀香山', timeZone: 'Pacific/Honolulu', flagEmoji: '🇺🇸'),
      ClockCity(name: '多伦多', timeZone: 'America/Toronto', flagEmoji: '🇨🇦'),
      ClockCity(name: '温哥华', timeZone: 'America/Vancouver', flagEmoji: '🇨🇦'),
      ClockCity(name: '蒙特利尔', timeZone: 'America/Montreal', flagEmoji: '🇨🇦'),
      ClockCity(name: '墨西哥城', timeZone: 'America/Mexico_City', flagEmoji: '🇲🇽'),
      
      // 南美洲城市
      ClockCity(name: '圣保罗', timeZone: 'America/Sao_Paulo', flagEmoji: '🇧🇷'),
      ClockCity(name: '里约热内卢', timeZone: 'America/Sao_Paulo', flagEmoji: '🇧🇷'),
      ClockCity(name: '布宜诺斯艾利斯', timeZone: 'America/Argentina/Buenos_Aires', flagEmoji: '🇦🇷'),
      ClockCity(name: '圣地亚哥', timeZone: 'America/Santiago', flagEmoji: '🇨🇱'),
      ClockCity(name: '利马', timeZone: 'America/Lima', flagEmoji: '🇵🇪'),
      ClockCity(name: '波哥大', timeZone: 'America/Bogota', flagEmoji: '🇨🇴'),
      ClockCity(name: '加拉加斯', timeZone: 'America/Caracas', flagEmoji: '🇻🇪'),
      ClockCity(name: '基多', timeZone: 'America/Guayaquil', flagEmoji: '🇪🇨'),
      ClockCity(name: '拉巴斯', timeZone: 'America/La_Paz', flagEmoji: '🇧🇴'),
      ClockCity(name: '亚松森', timeZone: 'America/Asuncion', flagEmoji: '🇵🇾'),
      ClockCity(name: '蒙得维的亚', timeZone: 'America/Montevideo', flagEmoji: '🇺🇾'),
      ClockCity(name: '乔治敦', timeZone: 'America/Guyana', flagEmoji: '🇬🇾'),
      ClockCity(name: '苏里南', timeZone: 'America/Paramaribo', flagEmoji: '🇸🇷'),
      
      // 非洲城市
      ClockCity(name: '开罗', timeZone: 'Africa/Cairo', flagEmoji: '🇪🇬'),
      ClockCity(name: '约翰内斯堡', timeZone: 'Africa/Johannesburg', flagEmoji: '🇿🇦'),
      ClockCity(name: '开普敦', timeZone: 'Africa/Johannesburg', flagEmoji: '🇿🇦'),
      ClockCity(name: '拉各斯', timeZone: 'Africa/Lagos', flagEmoji: '🇳🇬'),
      ClockCity(name: '内罗毕', timeZone: 'Africa/Nairobi', flagEmoji: '🇰🇪'),
      ClockCity(name: '阿尔及尔', timeZone: 'Africa/Algiers', flagEmoji: '🇩🇿'),
      ClockCity(name: '卡萨布兰卡', timeZone: 'Africa/Casablanca', flagEmoji: '🇲🇦'),
      ClockCity(name: '突尼斯', timeZone: 'Africa/Tunis', flagEmoji: '🇹🇳'),
      ClockCity(name: '的黎波里', timeZone: 'Africa/Tripoli', flagEmoji: '🇱🇾'),
      ClockCity(name: '喀土穆', timeZone: 'Africa/Khartoum', flagEmoji: '🇸🇩'),
      ClockCity(name: '亚的斯亚贝巴', timeZone: 'Africa/Addis_Ababa', flagEmoji: '🇪🇹'),
      ClockCity(name: '阿克拉', timeZone: 'Africa/Accra', flagEmoji: '🇬🇭'),
      ClockCity(name: '阿比让', timeZone: 'Africa/Abidjan', flagEmoji: '🇨🇮'),
      ClockCity(name: '达喀尔', timeZone: 'Africa/Dakar', flagEmoji: '🇸🇳'),
      ClockCity(name: '金沙萨', timeZone: 'Africa/Kinshasa', flagEmoji: '🇨🇩'),
      ClockCity(name: '达累斯萨拉姆', timeZone: 'Africa/Dar_es_Salaam', flagEmoji: '🇹🇿'),
      ClockCity(name: '坎帕拉', timeZone: 'Africa/Kampala', flagEmoji: '🇺🇬'),
      ClockCity(name: '基加利', timeZone: 'Africa/Kigali', flagEmoji: '🇷🇼'),
      ClockCity(name: '哈拉雷', timeZone: 'Africa/Harare', flagEmoji: '🇿🇼'),
      ClockCity(name: '路沙卡', timeZone: 'Africa/Lusaka', flagEmoji: '🇿🇲'),
      ClockCity(name: '马普托', timeZone: 'Africa/Maputo', flagEmoji: '🇲🇿'),
      
      // 大洋洲城市
      ClockCity(name: '墨尔本', timeZone: 'Australia/Melbourne', flagEmoji: '🇦🇺'),
      ClockCity(name: '珀斯', timeZone: 'Australia/Perth', flagEmoji: '🇦🇺'),
      ClockCity(name: '布里斯班', timeZone: 'Australia/Brisbane', flagEmoji: '🇦🇺'),
      ClockCity(name: '阿德莱德', timeZone: 'Australia/Adelaide', flagEmoji: '🇦🇺'),
      ClockCity(name: '达尔文', timeZone: 'Australia/Darwin', flagEmoji: '🇦🇺'),
      ClockCity(name: '堪培拉', timeZone: 'Australia/Sydney', flagEmoji: '🇦🇺'),
      ClockCity(name: '奥克兰', timeZone: 'Pacific/Auckland', flagEmoji: '🇳🇿'),
      ClockCity(name: '惠灵顿', timeZone: 'Pacific/Auckland', flagEmoji: '🇳🇿'),
      ClockCity(name: '苏瓦', timeZone: 'Pacific/Fiji', flagEmoji: '🇫🇯'),
      ClockCity(name: '努库阿洛法', timeZone: 'Pacific/Tongatapu', flagEmoji: '🇹🇴'),
      ClockCity(name: '阿皮亚', timeZone: 'Pacific/Apia', flagEmoji: '🇼🇸'),
      ClockCity(name: '维拉港', timeZone: 'Pacific/Efate', flagEmoji: '🇻🇺'),
      ClockCity(name: '努美阿', timeZone: 'Pacific/Noumea', flagEmoji: '🇳🇨'),
      ClockCity(name: '帕皮提', timeZone: 'Pacific/Tahiti', flagEmoji: '🇵🇫'),
      ClockCity(name: '关岛', timeZone: 'Pacific/Guam', flagEmoji: '🇬🇺'),
      ClockCity(name: '塞班', timeZone: 'Pacific/Saipan', flagEmoji: '🇲🇵'),
      ClockCity(name: '帕劳', timeZone: 'Pacific/Palau', flagEmoji: '🇵🇼'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // 筛选未添加的城市
            final filteredCities = availableCities.where((city) {
              final isNotAdded = !_cities.any((c) => c.name == city.name);
              final matchesSearch = _searchQuery.isEmpty ||
                  city.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  city.timeZone.toLowerCase().contains(_searchQuery.toLowerCase());
              return isNotAdded && matchesSearch;
            }).toList();
            
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 拖拽指示器
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // 头部区域
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('添加城市', 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.black54),
                                  onPressed: () {
                                    _searchQuery = '';
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: '搜索城市名称或时区...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.black),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                setModalState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Text('共 ${filteredCities.length} 个可添加的城市',
                              style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      
                      // 分割线
                      Container(
                        height: 1,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      
                      // 城市列表
                      Expanded(
                        child: filteredCities.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text('没有找到匹配的城市',
                                      style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredCities.length,
                                itemBuilder: (context, index) {
                                  final city = filteredCities[index];
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: Text(city.flagEmoji, style: const TextStyle(fontSize: 24)),
                                      title: Text(city.name, 
                                        style: const TextStyle(
                                          fontSize: 16, 
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        )),
                                      subtitle: Text(city.timeZone, 
                                        style: const TextStyle(
                                          fontSize: 12, 
                                          color: Colors.grey,
                                        )),
                                      trailing: const Icon(Icons.add, color: Colors.black54),
                                      onTap: () {
                                        setState(() {
                                          _cities.add(city);
                                        });
                                        _searchQuery = '';
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _removeCity(int index) {
    setState(() {
      _cities.removeAt(index);
    });
  }

  String _formatTime(DateTime time) {
    // 需要导入 intl 库才能使用 DateFormat
    // 首先在文件顶部添加 import 'package:intl/intl.dart';
    // 这里假设已完成导入
    return intl.DateFormat('HH:mm:ss').format(time);
  }

  String _formatDate(DateTime time) {
    try {
      return intl.DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(time);
    } catch (e) {
      // 如果中文本地化失败，使用英文格式
      return intl.DateFormat('yyyy-MM-dd EEEE').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '世界时钟',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addCity,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 本地时间显示
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '本地时间',
                      style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_currentTime),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(_formatDate(_currentTime)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 世界时钟列表
            const Text('世界时钟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _cities.isEmpty
                ? const Center(child: Text('暂无添加的城市时钟'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      final cityTime = _getTimeForCity(city);
                      final isDayTime = cityTime.hour >= 6 && cityTime.hour < 18;

                      return Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(city.flagEmoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(city.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(
                                      isDayTime ? '白天' : '夜晚',
                                      style: TextStyle(
                                        color: isDayTime ? Colors.amber.shade600 : Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(cityTime),
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  Text(_formatDate(cityTime)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeCity(index),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}