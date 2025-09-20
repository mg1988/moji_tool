import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class ScreenBadPointPage extends StatefulWidget {
  const ScreenBadPointPage({super.key});

  @override
  State<ScreenBadPointPage> createState() => _ScreenBadPointPageState();
}

class _ScreenBadPointPageState extends State<ScreenBadPointPage> {
  // 定义检测颜色列表
  final List<Color> colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.cyan,
  ];

  // 当前显示的颜色索引
  int currentColorIndex = 0;
  
  // 是否全屏模式
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '屏幕坏点检测',
      isFullscreen: isFullScreen,
      child: isFullScreen 
          ? _buildFullScreenView() 
          : _buildNormalView(),
    );
  }

  // 普通视图（非全屏）
  Widget _buildNormalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 说明文本
          Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            child: const Text(
              '屏幕坏点检测可以帮助您发现屏幕上的坏点、亮点或暗点。点击下方颜色按钮切换颜色，点击"全屏检测"进入全屏模式进行更仔细的检查。',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 预览区域
          Container(
            height: 300,
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: colors[currentColorIndex],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          
          // 颜色选择按钮
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentColorIndex = index;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors[index],
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide.none,
                  ),
                ),
                child: const SizedBox.shrink(),
              );
            },
          ),
          
          // 全屏按钮
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFullScreen = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    '全屏检测',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
          ),
          
          // 使用提示
          const SizedBox(height: 20.0),
          const Text(
            '提示：在全屏模式下，点击屏幕切换颜色，双击退出全屏模式。',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 全屏视图
  Widget _buildFullScreenView() {
    return Container(
      color: colors[currentColorIndex],
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        // 单击切换颜色
        onTap: () {
          setState(() {
            currentColorIndex = (currentColorIndex + 1) % colors.length;
          });
        },
        // 双击退出全屏
        onDoubleTap: () {
          setState(() {
            isFullScreen = false;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '点击切换颜色 (${currentColorIndex + 1}/${colors.length}) | 双击退出',
              style: TextStyle(
                color: _getContrastColor(colors[currentColorIndex]),
                fontSize: 14.0,
                backgroundColor: Colors.black38,
              ),
            ),
            const SizedBox(height: 40.0), // 底部留出一些空间
          ],
        ),
      ),
    );
  }

  // 根据背景色获取对比度高的文本颜色
  Color _getContrastColor(Color backgroundColor) {
    // 计算颜色亮度
    double luminance = (backgroundColor.red * 0.299 + 
                        backgroundColor.green * 0.587 + 
                        backgroundColor.blue * 0.114) / 255;
    // 亮度大于0.5使用黑色，否则使用白色
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}