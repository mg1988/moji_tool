import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class TouchTestPage extends StatefulWidget {
  const TouchTestPage({super.key});

  @override
  State<TouchTestPage> createState() => _TouchTestPageState();
}

class _TouchTestPageState extends State<TouchTestPage> {
  // 存储触摸点信息
  final List<TouchPoint> touchPoints = [];
  
  // 最大同时触摸点数
  int maxTouchPoints = 0;
  
  // 是否已重置
  bool hasReset = false;
  
  // 是否全屏模式
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '触摸检测',
      isFullscreen: isFullScreen,
      child: isFullScreen 
          ? _buildFullScreenView() 
          : Column(
              children: [
                // 说明文本
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
                  child: const Text(
                    '触摸检测可以帮助您测试设备的触摸屏是否正常工作。在下方区域内进行单指、多指触摸测试，观察触摸点是否能准确显示。',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // 触摸统计信息
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBox('当前触摸点', '${touchPoints.length}'),
                      const SizedBox(width: 20.0),
                      _buildInfoBox('最大同时点数', '$maxTouchPoints'),
                    ],
                  ),
                ),
                
                // 触摸检测区域
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _buildTouchArea(),
                  ),
                ),
                
                // 操作按钮
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _resetTest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          '重置',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          _showTestResult();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          '测试结果',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFullScreen = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // 构建信息显示框
  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 触摸点计数器
  int touchIdCounter = 0;

  // 构建触摸区域
  Widget _buildTouchArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          // 处理触摸事件
          onPanStart: (details) {
            _addTouchPoint(details.localPosition, details.sourceTimeStamp.hashCode);
          },
          onPanUpdate: (details) {
            _updateTouchPoint(details.localPosition, details.sourceTimeStamp.hashCode);
          },
          onPanEnd: (details) {
            // 处理多指触摸结束事件
            setState(() {
              touchPoints.clear();
            });
          },
          onTapDown: (details) {
            // 为点击事件生成唯一ID
            touchIdCounter++;
            _addTouchPoint(details.localPosition, touchIdCounter);
          },
          onTapUp: (details) {
            // 使用最新的触摸ID
            _removeTouchPoint(touchIdCounter);
          },
          onTapCancel: () {
            // 清除所有触摸点
            setState(() {
              touchPoints.clear();
            });
          },
          // 绘制触摸点
          child: Stack(
            children: [
              // 背景图案
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/banner1.png'), // 使用应用中的示例图片
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  ),
                ),
              ),
              
              // 网格背景
              _buildGridBackground(constraints),
              
              // 触摸点
              ...touchPoints.map((point) {
                return Positioned(
                  left: point.position.dx - 25,
                  top: point.position.dy - 25,
                  child: _buildTouchPointVisual(point),
                );
              }),
              
              // 提示文本
              if (touchPoints.isEmpty && !hasReset) 
                const Center(
                  child: Text(
                    '请在区域内进行触摸测试',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 构建网格背景（使用简单的自定义实现替代GridPaper）
  Widget _buildGridBackground(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      decoration: const BoxDecoration(
        // 使用简单的网格背景图或颜色渐变代替GridPaper
        color: Colors.white,
      ),
    );
  }

  // 构建触摸点视觉效果
  Widget _buildTouchPointVisual(TouchPoint point) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: point.color.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: point.color,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: point.color.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              point.pointer.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'ID: ${point.pointer}',
          style: TextStyle(
            color: point.color,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 添加触摸点
  void _addTouchPoint(Offset position, int pointer) {
    setState(() {
      // 检查是否已存在相同指针的触摸点
      int existingIndex = touchPoints.indexWhere((point) => point.pointer == pointer);
      if (existingIndex < 0) {
        // 创建新的触摸点
        touchPoints.add(TouchPoint(
          position: position,
          pointer: pointer,
          color: _getTouchColor(pointer),
        ));
        
        // 更新最大同时触摸点数
        maxTouchPoints = touchPoints.length > maxTouchPoints 
            ? touchPoints.length 
            : maxTouchPoints;
      }
    });
  }

  // 更新触摸点位置
  void _updateTouchPoint(Offset position, int pointer) {
    setState(() {
      int index = touchPoints.indexWhere((point) => point.pointer == pointer);
      if (index >= 0) {
        touchPoints[index] = TouchPoint(
          position: position,
          pointer: pointer,
          color: touchPoints[index].color,
        );
      }
    });
  }

  // 移除触摸点
  void _removeTouchPoint(int pointer) {
    setState(() {
      touchPoints.removeWhere((point) => point.pointer == pointer);
    });
  }

  // 根据指针ID获取触摸点颜色
  Color _getTouchColor(int pointer) {
    // 预定义一组颜色，循环使用
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.cyan,
      Colors.orange,
      Colors.pink,
    ];
    
    return colors[pointer % colors.length];
  }

  // 重置测试
  void _resetTest() {
    setState(() {
      touchPoints.clear();
      maxTouchPoints = 0;
      hasReset = true;
      touchIdCounter = 0;
    });
    
    // 显示重置成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('测试已重置'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 显示测试结果
  void _showTestResult() {
    String result = maxTouchPoints > 1 
        ? '触摸屏多点触控功能正常，可以同时识别 $maxTouchPoints 个触摸点。' 
        : '触摸屏基本功能正常，请尝试使用多点触控以测试更多功能。';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试结果'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 全屏模式下的视图
  Widget _buildFullScreenView() {
    return Stack(
      children: [
        // 全屏触摸区域
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                // 处理触摸事件
                onPanStart: (details) {
                  _addTouchPoint(details.localPosition, details.sourceTimeStamp.hashCode);
                },
                onPanUpdate: (details) {
                  _updateTouchPoint(details.localPosition, details.sourceTimeStamp.hashCode);
                },
                onPanEnd: (details) {
                  // 处理多指触摸结束事件
                  _removeAllTouchPoints();
                },
                onTapDown: (details) {
                  // 为点击事件生成唯一ID
                  touchIdCounter++;
                  _addTouchPoint(details.localPosition, touchIdCounter);
                },
                onTapUp: (details) {
                  // 使用最新的触摸ID
                  _removeTouchPoint(touchIdCounter);
                },
                onTapCancel: () {
                  _removeAllTouchPoints();
                },
                onDoubleTap: () {
                  // 双击退出全屏
                  setState(() {
                    isFullScreen = false;
                  });
                },
                // 绘制触摸点
                child: Stack(
                  children: [
                    // 背景
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                    ),
                    
                    // 网格背景
                    _buildGridBackground(constraints),
                    
                    // 触摸点
                    ...touchPoints.map((point) {
                      return Positioned(
                        left: point.position.dx - 25,
                        top: point.position.dy - 25,
                        child: _buildTouchPointVisual(point),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        
        // 顶部统计信息（半透明背景）
        Positioned(
          top: 20.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoBox('当前触摸点', '${touchPoints.length}'),
                const SizedBox(width: 20.0),
                _buildInfoBox('最大同时点数', '$maxTouchPoints'),
              ],
            ),
          ),
        ),
        
        // 退出全屏按钮
        Positioned(
          bottom: 20.0,
          left: 0.0,
          right: 0.0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isFullScreen = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                '退出全屏',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
        
        // 双击退出全屏提示
        Positioned(
          bottom: 80.0,
          left: 0.0,
          right: 0.0,
          child: Center(
            child: Text(
              '双击屏幕退出全屏模式',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.5),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 移除所有触摸点
  void _removeAllTouchPoints() {
    setState(() {
      touchPoints.clear();
    });
  }
  }

// 触摸点数据类
class TouchPoint {
  final Offset position;
  final int pointer;
  final Color color;
  final DateTime timestamp;

  TouchPoint({
    required this.position,
    required this.pointer,
    required this.color,
  }) : timestamp = DateTime.now();
}