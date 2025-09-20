import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:voice_to_text_app/components/base_tool_page.dart';
class WoodenFishPage extends StatefulWidget {
  const WoodenFishPage({super.key});

  @override
  State<WoodenFishPage> createState() => _WoodenFishPageState();
}

class _WoodenFishPageState extends State<WoodenFishPage> {
  int _hitCount = 0;
  bool _isHitting = false;
  final List<CircleWave> _waves = [];
  double _fishSize = 200.0;
  final List<Timer> _waveTimers = []; // 存储波纹定时器引用，用于清理
  final GlobalKey _fishContainerKey = GlobalKey(); // 用于获取容器位置

  // 模拟播放敲击声音的方法
  Future<void> _playHitSound() async {
    // 在实际应用中，可以使用AudioCache播放真实的木鱼声音
    // 这里简单模拟声音效果
    try {
      // 使用系统提示音
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // 忽略声音播放错误
    }
  }

  // 处理敲击事件
  void _handleHit(Offset position) {
    if (_isHitting) return;

    setState(() {
      _isHitting = true;
      _hitCount++;
      _fishSize = 180.0; // 木鱼暂时变小

      // 获取木鱼容器的位置和大小
      RenderBox? renderBox = _fishContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // 获取木鱼中心点位置（相对于容器）
        Offset centerPosition = Offset(
          renderBox.size.width / 2,
          renderBox.size.height / 2
        );
        
        // 添加波纹效果 - 从木鱼中心点开始
        CircleWave wave = CircleWave(position: centerPosition);
        _waves.add(wave);
      }

      // 播放声音
      _playHitSound();

      // 恢复木鱼大小
      Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _fishSize = 200.0;
            _isHitting = false;
          });
        }
      });

    });
    
    // 启动波纹动画
    _initializeWaveAnimation();
  }

  @override
  void dispose() {
    // 清理所有定时器，防止内存泄漏
    for (var timer in _waveTimers) {
      timer.cancel();
    }
    super.dispose();
  }
  
  // 初始化波纹动画
  void _initializeWaveAnimation() {
    // 清理之前的定时器
    for (var timer in _waveTimers) {
      timer.cancel();
    }
    _waveTimers.clear();
    
    // 为每个波纹创建一个定时器更新状态
    for (var i = 0; i < _waves.length; i++) {
      Timer timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (mounted) {
          setState(() {
            if (i < _waves.length) {
              _waves[i].progress += 0.01;
              _waves[i].radius += 5;
              
              // 移除完成的波纹
              if (_waves[i].progress >= 1.0) {
                _waves.removeAt(i);
                timer.cancel();
              }
            } else {
              timer.cancel();
            }
          });
        }
      });
      _waveTimers.add(timer);
    }
  }

  // 重置计数
  void _resetCount() {
    setState(() {
      _hitCount = 0;
      _waves.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '敲木鱼',
      actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetCount,
          ),
        ],
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景波纹效果 - 使用ListView.builder正确构建Widget列表
                  Positioned.fill(
                    child: Stack(
                      children: _waves.map((wave) {
                        // 限制波纹的半径，防止过大导致渲染问题
                        double limitedRadius = min(wave.radius, 300.0);
                        double opacity = max(0.0, 0.8 - wave.progress);
                        
                        // 只显示有效的波纹
                        if (wave.progress < 1.0 && opacity > 0) {
                          // 获取木鱼容器的位置和大小以正确定位波纹
                          RenderBox? renderBox = _fishContainerKey.currentContext?.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            // 获取容器在屏幕上的位置
                            Offset containerPosition = renderBox.localToGlobal(Offset.zero);
                            
                            // 计算波纹在屏幕上的实际位置（从容器中心开始）
                            double screenX = containerPosition.dx + wave.position.dx - limitedRadius;
                            double screenY = containerPosition.dy + wave.position.dy - limitedRadius;
                            
                            // 确保位置值有效，避免渲染断言失败
                            double safeTop = max(0.0, screenY);
                            double safeLeft = max(0.0, screenX);
                            
                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 30),
                              top: safeTop,
                              left: safeLeft,
                              width: limitedRadius * 2,
                              height: limitedRadius * 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.amberAccent.withOpacity(opacity),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink(); // 返回空widget
                      }).toList(),
                    ),
                  ),

            // 主要内容
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 计数器显示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 40,top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.amberAccent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '敲击次数: $_hitCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                ),

                // 木鱼图标
                Expanded(
                  child: Center(
                    child: Container(
                    key: _fishContainerKey, // 应用GlobalKey
                    child: GestureDetector(
                      onTapDown: (details) {
                        _handleHit(details.globalPosition);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: _fishSize,
                        height: _fishSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amberAccent.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        // 使用网络木鱼图片
                        child: ClipOval(
                          child: Image.network(
                            'https://i.imgur.com/8jMZqWX.jpg', // 木鱼图片URL
                            width: _fishSize,
                            height: _fishSize,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: _fishSize,
                                height: _fishSize,
                                color: Colors.brown,
                                child: const Center(
                                  child: Icon(
                                    Icons.hourglass_empty,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: _fishSize,
                                height: _fishSize,
                                color: Colors.brown,
                                child: const Center(
                                  child: Text(
                                    '木鱼',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ),

                // 说明文字
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const Text(
                        '敲木鱼可以帮助你放松心情，专注冥想',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '累计敲击: $_hitCount 次',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 波纹效果类 - 简化为纯数据类
class CircleWave {
  final Offset position;
  double radius = 100.0;
  double progress = 0.0;

  CircleWave({required this.position});
}