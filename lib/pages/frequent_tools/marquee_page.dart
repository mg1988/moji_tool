import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_to_text_app/components/colors.dart';

class MarqueePage extends StatefulWidget {
  const MarqueePage({Key? key}) : super(key: key);

  @override
  State<MarqueePage> createState() => _MarqueePageState();
}

// 定义滚动方向枚举
enum ScrollDirection {
  left,
  right,
}

// 定义主题模式枚举
enum ThemeMode {
  light,
  dark,
}

// 定义字体枚举
enum FontFamily {
  defaultFont,
  arial,
  sansSerif,
  serif,
  monospace,
}

class _MarqueePageState extends State<MarqueePage> {
  final TextEditingController _textController = TextEditingController(text: '欢迎使用手持弹幕');
  double _fontSize = 60;
  Color _fontColor = AppColors.primary;
  Color _backgroundColor = AppColors.white; // 默认白色背景
  double _scrollSpeed = 50.0; // 默认设置为慢速
  bool _isScrolling = false;
  bool _isGlowing = false;
  bool _isFullscreen = false;
  ScrollDirection _scrollDirection = ScrollDirection.left;
  ThemeMode _themeMode = ThemeMode.light;
  FontFamily _fontFamily = FontFamily.defaultFont;
  ScrollController? _scrollController;
  Timer? _scrollTimer;
  Timer? _buttonVisibilityTimer;
  bool _isButtonVisible = true; // 控制横屏退出按钮的可见性

  // 简化的颜色选择列表（8种常用颜色）
  final List<Color> _availableColors = [
    Colors.red, Colors.blue, Colors.green, Colors.yellow,
    Colors.purple, Colors.orange, Colors.white, Colors.black
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 添加文本控制器监听器
    _textController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    // 支持多种屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController?.dispose();
    _scrollTimer?.cancel();
    _buttonVisibilityTimer?.cancel();
    // 恢复默认屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _toggleScrolling() {
    setState(() {
      _isScrolling = !_isScrolling;
      if (_isScrolling) {
        _startScrolling();
      } else {
        _stopScrolling();
      }
    });
  }

  void _startScrolling() {
    if (_scrollController == null || !mounted) return;
    
    // 取消之前的所有定时器和动画
    _stopScrolling();
    
    // 检查滚动控制器是否已附加到滚动视图
    if (!_scrollController!.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isScrolling) {
          _startScrolling();
        }
      });
      return;
    }
    
    // 重置滚动位置
    if (_scrollDirection == ScrollDirection.left) {
      _scrollController!.jumpTo(0);
    } else {
      _scrollController!.jumpTo(_scrollController!.position.maxScrollExtent);
    }
    
    _continueScrolling();
  }

  void _continueScrolling() {
    if (_scrollController == null || !mounted || !_isScrolling) return;
    
    if (!_scrollController!.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isScrolling) {
          _continueScrolling();
        }
      });
      return;
    }
    
    // 计算滚动动画时长
    double animationDuration = 20000 / (_scrollSpeed / 100);
    
    if (_scrollDirection == ScrollDirection.left) {
      _scrollController!.animateTo(
        _scrollController!.position.maxScrollExtent,
        duration: Duration(milliseconds: animationDuration.round()),
        curve: Curves.linear,
      ).whenComplete(() {
        if (mounted && _isScrolling) {
          _scrollController!.jumpTo(0);
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _isScrolling) {
              _continueScrolling();
            }
          });
        }
      });
    } else {
      _scrollController!.animateTo(
        0,
        duration: Duration(milliseconds: animationDuration.round()),
        curve: Curves.linear,
      ).whenComplete(() {
        if (mounted && _isScrolling) {
          _scrollController!.jumpTo(_scrollController!.position.maxScrollExtent);
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _isScrolling) {
              _continueScrolling();
            }
          });
        }
      });
    }
  }

  void _stopScrolling() {
    // 取消所有定时器
    _scrollTimer?.cancel();
    _scrollTimer = null;
    
    // 停止所有正在进行的动画
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        _scrollDirection == ScrollDirection.left ? 0 : _scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 切换主题模式
  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      // 根据主题模式自动调整背景和字体颜色
      if (_themeMode == ThemeMode.dark) {
        _backgroundColor = Colors.black;
        _fontColor = Colors.white;
      } else {
        _backgroundColor = Colors.white;
        _fontColor = AppColors.primary;
      }
    });
  }

  // 显示设置弹窗
  void _showSettingsDialog() {
    // 复制当前设置到临时变量
    String tempText = _textController.text;
    double tempFontSize = _fontSize;
    double tempScrollSpeed = _scrollSpeed;
    Color tempFontColor = _fontColor;
    Color tempBackgroundColor = _backgroundColor;
    bool tempIsGlowing = _isGlowing;
    ScrollDirection tempScrollDirection = _scrollDirection;
    ThemeMode tempThemeMode = _themeMode;
    FontFamily tempFontFamily = _fontFamily;
    // 固定弹窗背景颜色为白色，不随主题改变
    const Color dialogBackgroundColor = Colors.white;
    // 根据背景色确定文字颜色
    final Color dialogTextColor = _fontColor == Colors.white ? Colors.black : _fontColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: dialogBackgroundColor,
          insetPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 内容区域
                Flexible(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                          // 标题
                          Center(
                            child: Text(
                              '弹幕设置', 
                              style: TextStyle(
                                color: tempFontColor, 
                                fontSize: 20, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                          const SizedBox(height: 16),
                           
                          // 文本输入
                          TextField(
                            onChanged: (value) {
                              tempText = value;
                            },
                            controller: TextEditingController(text: tempText),
                            style: TextStyle(color: tempFontColor == Colors.white ? Colors.black : Colors.white),
                            decoration: InputDecoration(
                              labelText: '输入弹幕内容',
                              labelStyle: TextStyle(color: tempFontColor.withOpacity(0.7)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: tempFontColor.withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: tempFontColor.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: tempFontColor, width: 2),
                              ),
                              filled: true,
                              fillColor: tempFontColor == Colors.white ? Colors.grey.shade200 : Colors.grey.shade800,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 字体大小和速度控制
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // 字体大小控制
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '字体大小: ${tempFontSize.round()}',
                                      style: TextStyle(color: tempFontColor),
                                    ),
                                    Slider(
                                      value: tempFontSize,
                                      min: 20,
                                      max: 120,
                                      divisions: 10,
                                      activeColor: tempFontColor,
                                      inactiveColor: tempFontColor.withOpacity(0.3),
                                      onChanged: (value) {
                                        setState(() {
                                          tempFontSize = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              // 滚动速度控制
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '滚动速度: ${tempScrollSpeed.round()}',
                                      style: TextStyle(color: tempFontColor),
                                    ),
                                    Slider(
                                      value: tempScrollSpeed,
                                      min: 50,
                                      max: 300,
                                      divisions: 5,
                                      activeColor: tempFontColor,
                                      inactiveColor: tempFontColor.withOpacity(0.3),
                                      onChanged: (value) {
                                        setState(() {
                                          tempScrollSpeed = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 字体颜色选择
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '字体颜色:',
                                style: TextStyle(color: tempFontColor),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _availableColors.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempFontColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: tempFontColor == color ? Colors.white : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 背景颜色选择
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '背景颜色:',
                                style: TextStyle(color: tempFontColor),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _availableColors.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempBackgroundColor = color;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: tempBackgroundColor == color ? Colors.white : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 其他设置选项
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // 发光效果
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    '发光效果:',
                                    style: TextStyle(color: dialogTextColor),
                                  ),
                                  Switch(
                                    value: tempIsGlowing,
                                    onChanged: (value) {
                                      setState(() {
                                        tempIsGlowing = value;
                                      });
                                    },
                                    activeColor: tempFontColor,
                                    inactiveTrackColor: tempFontColor.withOpacity(0.3),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 主题模式选择
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    '主题模式:',
                                    style: TextStyle(color: dialogTextColor),
                                  ),
                                  Switch(
                                    value: tempThemeMode == ThemeMode.dark,
                                    onChanged: (value) {
                                      setState(() {
                                        tempThemeMode = value ? ThemeMode.dark : ThemeMode.light;
                                        if (tempThemeMode == ThemeMode.dark) {
                                          tempBackgroundColor = Colors.black;
                                          tempFontColor = Colors.white;
                                        } else {
                                          tempBackgroundColor = Colors.white;
                                          tempFontColor = AppColors.primary;
                                        }
                                      });
                                    },
                                    activeColor: tempFontColor,
                                    inactiveTrackColor: tempFontColor.withOpacity(0.3),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 字体选择
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '字体选择:',
                                    style: TextStyle(color: dialogTextColor),
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: FontFamily.values.map((fontFamily) {
                                      String fontName = '';
                                      switch (fontFamily) {
                                        case FontFamily.defaultFont:
                                          fontName = '默认';
                                          break;
                                        case FontFamily.arial:
                                          fontName = 'Arial';
                                          break;
                                        case FontFamily.sansSerif:
                                          fontName = 'Sans Serif';
                                          break;
                                        case FontFamily.serif:
                                          fontName = 'Serif';
                                          break;
                                        case FontFamily.monospace:
                                          fontName = 'Monospace';
                                          break;
                                      }
                                      return ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            tempFontFamily = fontFamily;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: tempFontFamily == fontFamily ? dialogTextColor : Colors.transparent,
                                          foregroundColor: tempFontFamily == fontFamily ? (dialogTextColor == Colors.white ? Colors.black : Colors.white) : dialogTextColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: dialogTextColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Text(fontName),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 滚动方向选择
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '滚动方向:',
                                    style: TextStyle(color: dialogTextColor),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            tempScrollDirection = ScrollDirection.left;
                                          });
                                        },
                                        icon: Icon(Icons.arrow_left, color: tempScrollDirection == ScrollDirection.left ? (tempFontColor == Colors.white ? Colors.black : Colors.white) : tempFontColor),
                                        label: Text('向左', style: TextStyle(color: tempScrollDirection == ScrollDirection.left ? (tempFontColor == Colors.white ? Colors.black : Colors.white) : tempFontColor)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: tempScrollDirection == ScrollDirection.left ? dialogTextColor : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: dialogTextColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            tempScrollDirection = ScrollDirection.right;
                                          });
                                        },
                                        icon: Icon(Icons.arrow_right, color: tempScrollDirection == ScrollDirection.right ? (tempFontColor == Colors.white ? Colors.black : Colors.white) : tempFontColor),
                                        label: Text('向右', style: TextStyle(color: tempScrollDirection == ScrollDirection.right ? (tempFontColor == Colors.white ? Colors.black : Colors.white) : tempFontColor)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: tempScrollDirection == ScrollDirection.right ? dialogTextColor : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: dialogTextColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // 底部按钮区域
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    // 保存滚动状态
                    final bool wasScrolling = _isScrolling;
                    
                    // 确认设置更改，更新主页面状态
                    this.setState(() {
                      _fontSize = tempFontSize;
                      _scrollSpeed = tempScrollSpeed;
                      _fontColor = tempFontColor;
                      _backgroundColor = tempBackgroundColor;
                      _isGlowing = tempIsGlowing;
                      _scrollDirection = tempScrollDirection;
                      _themeMode = tempThemeMode;
                      _fontFamily = tempFontFamily;
                      _textController.text = tempText;
                    });
                    
                    // 关闭弹窗
                    Navigator.of(context).pop();
                    
                    // 在弹窗关闭后延迟处理滚动状态
                    Future.delayed(const Duration(milliseconds: 50), () {
                      // 如果原来正在滚动，重新启动滚动以应用新设置
                      if (mounted && wasScrolling) {
                        _startScrolling();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dialogTextColor,
                    foregroundColor: dialogTextColor == Colors.white ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: dialogTextColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('确认'),
                ),
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 切换横竖屏
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        // 进入全屏
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        // 允许横屏
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        // 进入横屏时显示按钮
        _isButtonVisible = true;
        // 设置3秒后隐藏按钮
        _scheduleButtonHide();
      } else {
        // 退出全屏
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        // 回到竖屏
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        // 取消定时器
        _buttonVisibilityTimer?.cancel();
      }
    });
  }

  // 设置按钮隐藏的定时器
  void _scheduleButtonHide() {
    // 先取消之前的定时器
    _buttonVisibilityTimer?.cancel();
    // 设置3秒后隐藏按钮
    _buttonVisibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isFullscreen) {
        setState(() {
          _isButtonVisible = false;
        });
      }
    });
  }

  // 触摸屏幕时显示按钮
  void _onScreenTap() {
    if (_isFullscreen) {
      setState(() {
        _isButtonVisible = true;
      });
      // 重新设置3秒后隐藏按钮
      _scheduleButtonHide();
    } else {
      // 非全屏模式下直接切换
      _toggleFullscreen();
    }
  }

  // 获取当前选择的字体名称
  String? _getFontFamilyName() {
    switch (_fontFamily) {
      case FontFamily.defaultFont:
        return null; // 使用默认字体
      case FontFamily.arial:
        return 'Arial';
      case FontFamily.sansSerif:
        return 'sans-serif';
      case FontFamily.serif:
        return 'serif';
      case FontFamily.monospace:
        return 'monospace';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据是否全屏决定显示模式
    if (_isFullscreen) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          color: _backgroundColor, // 确保横屏时背景色与竖屏一致
          child: _isScrolling
              ? GestureDetector(
                  onTap: _onScreenTap,
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Row(
                      children: List.generate(
                        20, // 重复显示多次，实现无缝滚动
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Center(
                            child: Text(
                              _textController.text,
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                                color: _fontColor,
                                fontFamily: _getFontFamilyName(),
                                shadows: _isGlowing
                                    ? [
                                        Shadow(
                                          blurRadius: 8.0,
                                          color: _fontColor.withOpacity(0.7),
                                          offset: const Offset(0, 0),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _onScreenTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      _textController.text,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                        color: _fontColor,
                        fontFamily: _getFontFamilyName(),
                        shadows: _isGlowing
                            ? [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: _fontColor.withOpacity(0.7),
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
        ),
        floatingActionButton: _isButtonVisible
            ? FloatingActionButton(
                onPressed: _toggleFullscreen,
                backgroundColor: _themeMode == ThemeMode.dark ? Colors.white : AppColors.primaryBtn,
                foregroundColor: _themeMode == ThemeMode.dark ? Colors.black : Colors.white,
                child: const Icon(Icons.screen_rotation),
                tooltip: '退出横屏',
              )
            : null,
      );
    }

    return Scaffold(
      // 设置AppBar颜色
      appBar: AppBar(
        title: const Text('手持弹幕'),
        backgroundColor: _themeMode == ThemeMode.dark ? Colors.black : AppColors.background,
        foregroundColor: _themeMode == ThemeMode.dark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleThemeMode,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
        ),
      ),
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // 弹幕显示区域
            Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _fontColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _fontColor.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _onScreenTap,
                  behavior: HitTestBehavior.opaque,
                child: _isScrolling
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _scrollController,
                        child: Row(
                          children: List.generate(
                            20, // 重复显示多次，实现无缝滚动
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                height: MediaQuery.of(context).size.height * 0.55,
                                child: Text(
                                  _textController.text,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: _fontColor,
                                    fontFamily: _getFontFamilyName(),
                                    shadows: _isGlowing
                                        ? [
                                            Shadow(
                                              blurRadius: 8.0,
                                              color: _fontColor.withOpacity(0.7),
                                              offset: const Offset(0, 0),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _textController.text,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.bold,
                            color: _fontColor,
                            fontFamily: _getFontFamilyName(),
                            shadows: _isGlowing
                                ? [
                                    Shadow(
                                      blurRadius: 8.0,
                                      color: _fontColor.withOpacity(0.7),
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                ),
              ),
            ),

            // 控制按钮区域
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // 开始/停止按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleScrolling,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeMode == ThemeMode.dark ? Colors.white : AppColors.primaryBtn,
                        foregroundColor: _themeMode == ThemeMode.dark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _themeMode == ThemeMode.dark ? Colors.white.withOpacity(0.7) : AppColors.primaryBtn.withOpacity(0.7),
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      child: Text(_isScrolling ? '停止滚动' : '开始滚动'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 横竖屏切换按钮
                  ElevatedButton.icon(
                    onPressed: _toggleFullscreen,
                    icon: const Icon(Icons.screen_rotation),
                    label: const Text('横屏'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeMode == ThemeMode.dark ? Colors.white : AppColors.secondary,
                      foregroundColor: _themeMode == ThemeMode.dark ? Colors.black : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _themeMode == ThemeMode.dark ? Colors.white.withOpacity(0.7) : AppColors.secondary.withOpacity(0.7),
                          width: 1,
                        ),
                      ),
                      elevation: 2,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
}