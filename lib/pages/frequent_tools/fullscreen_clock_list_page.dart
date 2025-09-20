import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'fullscreen_clock_page.dart';
import 'dart:math';
import 'clock_themes/theme_factory.dart';

class FullscreenClockListPage extends StatelessWidget {
  const FullscreenClockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ClockTheme> themes = [
      ClockTheme(
        id: 'classic',
        name: '经典数字',
        description: '简洁的数字时钟，带有蓝色光效',
        previewColor: Colors.cyanAccent,
        accentColor: Colors.blueGrey,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'analog',
        name: '模拟时钟',
        description: '传统的指针式时钟，带有刻度和数字',
        previewColor: Colors.blue,
        accentColor: Colors.green,
        isAnalog: true,
      ),
      ClockTheme(
        id: 'neon',
        name: '霓虹光效',
        description: '动感十足的霓虹风格，适合夜环境',
        previewColor: Colors.pinkAccent,
        accentColor: Colors.deepPurple,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'minimal',
        name: '极简风格',
        description: '简约的黑白设计，干净利落',
        previewColor: Colors.black,
        accentColor: Colors.grey,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'retro',
        name: '复古终端',
        description: '老式计算机终端风格，带有科技感',
        previewColor: Colors.green.shade400,
        accentColor: Colors.grey,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'gradient',
        name: '渐变色彩',
        description: '平滑的色彩渐变，视觉效果丰富',
        previewColor: Colors.purple,
        accentColor: Colors.pink,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'digital',
        name: '数字面板',
        description: '经典的7段数码管风格显示',
        previewColor: Colors.yellowAccent,
        accentColor: Colors.blue,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'artistic',
        name: '艺术风格',
        description: '富有艺术感的配色和排版',
        previewColor: Colors.orange,
        accentColor: Colors.teal,
        isAnalog: false,
      ),
      ClockTheme(
        id: 'futuristic',
        name: '未来科技',
        description: '科技感十足的设计，适合现代化环境',
        previewColor: Colors.cyan,
        accentColor: Colors.blue,
        isAnalog: false,
      ),
      // 新增的复古时钟主题
      ClockTheme(
        id: 'vintage_gold',
        name: '复古金色',
        description: '奢华的金色复古时钟，带有罗马数字',
        previewColor: const Color(0xFFFFD700),
        accentColor: const Color(0xFF8B4513),
        isAnalog: true,
      ),
      ClockTheme(
        id: 'retro_arcade',
        name: '复古街机',
        description: '经典街机风格，绿色像素显示',
        previewColor: const Color(0xFF00FF00),
        accentColor: const Color(0xFFFF00FF),
        isAnalog: false,
      ),
      ClockTheme(
        id: 'vintage_typewriter',
        name: '复古打字机',
        description: '模拟老式打字机风格，带有机械感',
        previewColor: const Color(0xFFE0E0E0),
        accentColor: const Color(0xFF4A4A4A),
        isAnalog: false,
      ),
      ClockTheme(
        id: 'retro_radio',
        name: '复古收音机',
        description: '木质外壳收音机风格时钟',
        previewColor: const Color(0xFFFFD700),
        accentColor: const Color(0xFF8B0000),
        isAnalog: true,
      ),
      ClockTheme(
        id: 'vintage_pocket_watch',
        name: '复古怀表',
        description: '经典怀表设计，精致的细节',
        previewColor: const Color(0xFFC0C0C0),
        accentColor: const Color(0xFF8B4513),
        isAnalog: true,
      ),
      // 添加诺基亚风格时钟主题
      ClockTheme(
        id: 'nokia',
        name: '诺基亚风格',
        description: '经典诺基亚手机时钟风格，绿色像素显示',
        previewColor: const Color(0xFF00FF00),
        accentColor: const Color(0xFF000000),
        isAnalog: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('全屏时钟主题'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 240, 240, 240),
              Color.fromARGB(255, 220, 220, 220),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: themes.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            final theme = themes[index];
            return ClockThemeCard(
              theme: theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullscreenClockPage(themeId: theme.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ClockTheme {
  final String id;
  final String name;
  final String description;
  final Color previewColor;
  final Color accentColor;
  final bool isAnalog;

  ClockTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColor,
    required this.accentColor,
    required this.isAnalog,
  });
}

class ClockThemeCard extends StatelessWidget {
  final ClockTheme theme;
  final VoidCallback onTap;

  const ClockThemeCard({
    super.key,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 预览区域
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  color: theme.accentColor.withOpacity(0.95),
                  border: Border.all(
                    color: theme.previewColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.previewColor.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildPreviewClock(theme),
                ),
              ),
              const SizedBox(width: 20),
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.previewColor,
                              shadows: [
                                Shadow(
                                  color: theme.previewColor.withOpacity(0.5),
                                  blurRadius: 3,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (theme.isAnalog)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.previewColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.previewColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '指针式',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.previewColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      theme.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.color_lens,
                          size: 16,
                          color: theme.previewColor,
                        ),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.previewColor,
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.accentColor,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: theme.previewColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewClock(ClockTheme theme) {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);

    if (theme.isAnalog) {
      return SizedBox(
        width: 110,
        height: 110,
        child: Stack(children: [
          // 时钟背景
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: theme.previewColor.withOpacity(0.7),
                width: 3,
              ),
            ),
          ),
          // 完整的刻度系统 (每分钟一个刻度)
          for (int i = 0; i < 60; i++)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.rotate(
                angle: i * 6 * pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: i % 5 == 0 ? 2 : 1, // 主刻度更宽
                    height: i % 5 == 0 ? 10 : 5, // 主刻度更长
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: i % 5 == 0 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(i % 5 == 0 ? 1 : 0.5),
                    ),
                  ),
                ),
              ),
            ),
          // 小时刻度数字 (每3小时显示一个数字)
          for (int i = 1; i <= 12; i++)
            if (i % 3 == 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Transform.rotate(
                  angle: i * 30 * pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: const Offset(0, 20),
                      child: Text(
                        '${i == 12 ? 12 : i}',
                        style: TextStyle(
                          color: theme.previewColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          // 时针
          Positioned.fill(
            child: Transform.rotate(
              angle: (now.hour % 12) * 30 * pi / 180 + 
                     now.minute * 0.5 * pi / 180,
              alignment: Alignment.center,
              child: Container(
                width: 4,
                height: 25,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: theme.previewColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // 分针
          Positioned.fill(
            child: Transform.rotate(
              angle: now.minute * 6 * pi / 180,
              alignment: Alignment.center,
              child: Container(
                width: 3,
                height: 35,
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          // 秒针
          Positioned.fill(
            child: Transform.rotate(
              angle: now.second * 6 * pi / 180,
              alignment: Alignment.center,
              child: Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(0.5),
                ),
              ),
            ),
          ),
          // 中心点
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.previewColor,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        ]),
      );
    } else {
      // 针对诺基亚主题的特殊处理
      if (theme.id == 'nokia') {
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00AA00),
              width: 1,
            ),
          ),
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF00),
              fontFamily: 'Courier New',
              letterSpacing: 2,
            ),
          ),
        );
      } else {
        // 将时间格式改为中文格式
        final chineseTime = DateFormat('HH点mm分').format(now);
        return Text(
          chineseTime,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.previewColor,
            fontFamily: 'Courier',
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: theme.previewColor.withOpacity(0.7),
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        );
      }
    }
  }
}