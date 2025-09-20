import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _selectedCity = '北京';
  final TextEditingController _cityController = TextEditingController();
  
  // 模拟天气数据
  final Map<String, dynamic> _weatherData = {
    'city': '北京',
    'temperature': '22°C',
    'condition': '晴',
    'icon': Icons.wb_sunny,
    'humidity': '45%',
    'wind': '西北风 3-4级',
    'visibility': '10km',
    'airQuality': '良',
    'airQualityIndex': '75',
    'date': '${DateTime.now().toString().substring(0, 4)}年${DateTime.now().toString().substring(5, 7)}月${DateTime.now().toString().substring(8, 10)}日 ${DateTime.now().toString().substring(11, 16)}',
    'forecast': [
      {'day': '今天', 'condition': '晴', 'tempRange': '15°C - 25°C', 'icon': Icons.wb_sunny},
      {'day': '明天', 'condition': '多云', 'tempRange': '16°C - 24°C', 'icon': Icons.cloud},
      {'day': '后天', 'condition': '小雨', 'tempRange': '14°C - 20°C', 'icon': Icons.grain},
      {'day': '周四', 'condition': '阴', 'tempRange': '13°C - 19°C', 'icon': Icons.cloud},
      {'day': '周五', 'condition': '晴', 'tempRange': '15°C - 23°C', 'icon': Icons.wb_sunny},
    ],
  };

  // 支持的城市列表
  final List<String> _supportedCities = [
    '北京', '上海', '广州', '深圳', '杭州', '成都', '武汉', '西安', 
    '南京', '重庆', '天津', '苏州', '长沙', '青岛', '郑州', '大连'
  ];

  void _searchWeather() {
    if (_cityController.text.isNotEmpty) {
      if (_supportedCities.contains(_cityController.text)) {
        setState(() {
          _selectedCity = _cityController.text;
          // 模拟更新天气数据
          _weatherData['city'] = _selectedCity;
          _weatherData['date'] = '${DateTime.now().toString().substring(0, 4)}年${DateTime.now().toString().substring(5, 7)}月${DateTime.now().toString().substring(8, 10)}日 ${DateTime.now().toString().substring(11, 16)}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('暂不支持查询$_selectedCity的天气')),
        );
      }
    }
  }

  Widget _buildWeatherIcon(IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(16),
      child: Icon(iconData, size: 48, color: Colors.blue.shade500),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData iconData) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children:
            [
            Icon(iconData, color: Colors.blue.shade500, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '天气预报',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 城市搜索
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: '输入城市名称',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchWeather,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _supportedCities.take(8).map((city) {
                        return FilterChip(
                          label: Text(city),
                          selected: _selectedCity == city,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCity = city;
                                _cityController.text = city;
                                _weatherData['city'] = city;
                                _weatherData['date'] = '${DateTime.now().toString().substring(0, 4)}年${DateTime.now().toString().substring(5, 7)}月${DateTime.now().toString().substring(8, 10)}日 ${DateTime.now().toString().substring(11, 16)}';
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 当前天气
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children:
                    [
                    Text(
                      _weatherData['city'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _weatherData['date'],
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWeatherIcon(_weatherData['icon']),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                            [
                            Text(
                              _weatherData['temperature'],
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _weatherData['condition'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 天气详情
            const Text('天气详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildWeatherDetail('湿度', _weatherData['humidity'], Icons.opacity),
            _buildWeatherDetail('风向风速', _weatherData['wind'], Icons.air),
            _buildWeatherDetail('能见度', _weatherData['visibility'], Icons.visibility),
            _buildWeatherDetail('空气质量', '${_weatherData['airQuality']} (${_weatherData['airQualityIndex']})', Icons.filter_drama),

            const SizedBox(height: 16),

            // 天气预报
            const Text('未来5天预报', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _weatherData['forecast'].length,
              itemBuilder: (context, index) {
                final forecast = _weatherData['forecast'][index];
                return Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children:
                        [
                        Text(forecast['day'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Icon(forecast['icon'], color: Colors.blue.shade500),
                        const SizedBox(width: 16),
                        Text(forecast['condition']),
                        const Spacer(),
                        Text(forecast['tempRange']),
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