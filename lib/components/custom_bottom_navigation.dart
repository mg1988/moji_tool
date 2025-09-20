import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// 自定义底部导航栏组件
/// 支持深色背景、圆角设计和选中项发光效果
class CustomBottomNavigation extends StatefulWidget {
  /// 当前选中的索引
  final int currentIndex;

  /// 点击导航项的回调函数
  final ValueChanged<int> onTabChange;

  /// 导航项数据
  final List<Map<String, dynamic>> items;

  /// 背景色，默认为深色背景
  final Color backgroundColor;

  /// 选中项的图标和文字颜色
  final Color selectedColor;

  /// 未选中项的图标和文字颜色
  final Color unselectedColor;

  /// 选中项的背景色透明度
  final double selectedBackgroundColorOpacity;

  /// 圆角大小
  final double borderRadius;
  final Color selectedBackColor;
  
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    required this.items,
    this.backgroundColor = const Color.fromARGB(255, 30, 30, 30),
    this.selectedColor = AppColors.primary,
    this.unselectedColor = AppColors.textHint,
    this.selectedBackgroundColorOpacity = 0.3,
    this.borderRadius = 20.0,
    this.selectedBackColor = Colors.transparent,
  });

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  late AnimationController _positionController; // 位移动画控制器
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _positionAnimation; // 位移动画
  
  int _previousIndex = 0;
  int _rippleIndex = -1; // 记录当前涟漪的索引
  double _containerWidth = 0; // 容器宽度
  double _itemWidth = 0; // 单项宽度

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    
    // 缩放动画控制器
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // 滑动动画控制器
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // 发光动画控制器
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // 涟漪动画控制器
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // 位移动画控制器 - 遵循项目规范
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // 500ms持续时间
    );
    
    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // 滑动动画
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // 发光动画
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // 涟漪动画
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // 位移动画 - 使用easeInOutCubic曲线
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInOutCubic, // easeInOutCubic曲线
    ));
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      // 同时触发所有动画
      _triggerAllAnimations();
    }
  }
  
  // 智能位置计算和位移动画
  void _triggerPositionAnimation() {
    if (_containerWidth > 0 && _itemWidth > 0) {
      // 重置位移动画
      _positionController.reset();
      // 启动位移动画
      _positionController.forward();
    }
  }
  
  // 计算选中背景的水平位置
  double _calculateBackgroundPosition() {
    if (_itemWidth <= 0) return 0.0;
    
    // 从之前的位置动画到当前位置
    final fromPosition = _previousIndex * _itemWidth;
    final toPosition = widget.currentIndex * _itemWidth;
    
    // 使用动画插值计算当前位置
    return fromPosition + (toPosition - fromPosition) * _positionAnimation.value;
  }
  
  // 统一触发所有动画
  void _triggerAllAnimations() async {
    // 添加触觉反馈
    HapticFeedback.lightImpact();
    
    // 设置涟漪索引
    _rippleIndex = widget.currentIndex;
    
    // 重置所有动画
    _scaleController.reset();
    _slideController.reset();
    _glowController.reset();
    _rippleController.reset();
    _positionController.reset();
    
    // 同时启动位移动画和其他动画
    _positionController.forward(); // 立即开始位移动画
    
    // 其他动画的序列效果
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 20));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 30));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 50));
    _glowController.forward();
    
    // 等待发光动画达到高峰
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 柔和的回弹效果
    _scaleController.animateTo(0.7, 
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
    _slideController.animateTo(0.6,
      duration: const Duration(milliseconds: 200), 
      curve: Curves.easeOutBack,
    );
    
    // 保持发光效果稳定
    await Future.delayed(const Duration(milliseconds: 100));
    
    // 最终稳定状态
    _scaleController.animateTo(0.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    _slideController.animateTo(0.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
    
    // 清空涟漪索引
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _rippleIndex = -1;
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算容器宽度和单项宽度
        _containerWidth = constraints.maxWidth - 32; // 减去左右margin
        _itemWidth = _containerWidth / widget.items.length;
        
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 6, top: 4),
          height: 72, // 遵循项目规范的72px高度
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 移动的选中背景
              AnimatedBuilder(
                animation: _positionController,
                builder: (context, child) {
                  final backgroundPosition = _calculateBackgroundPosition();
                  return Positioned(
                    left: backgroundPosition,
                    top: 14, // 垂直居中
                    width: _itemWidth,
                    height: 44,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius - 8),
                        color: widget.selectedBackColor.withOpacity(
                          widget.selectedBackgroundColorOpacity,
                        ),
                        // 动画发光效果
                        boxShadow: [
                          BoxShadow(
                            color: widget.selectedColor.withOpacity(0.4 * _glowAnimation.value),
                            blurRadius: 12 * _glowAnimation.value,
                            spreadRadius: 3 * _glowAnimation.value,
                          ),
                          BoxShadow(
                            color: widget.selectedColor.withOpacity(0.2 * _glowAnimation.value),
                            blurRadius: 6 * _glowAnimation.value,
                            spreadRadius: 1 * _glowAnimation.value,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1 * _glowAnimation.value),
                            blurRadius: 2,
                            offset: const Offset(0, -1),
                          ),
                        ],
                        border: Border.all(
                          color: widget.selectedColor.withOpacity(0.3 + (0.4 * _glowAnimation.value)),
                          width: 1 + (0.5 * _glowAnimation.value),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 导航项内容
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = widget.currentIndex == index;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.currentIndex != index) {
                            widget.onTabChange(index);
                          }
                        },
                        borderRadius: BorderRadius.circular(widget.borderRadius - 4),
                        highlightColor: widget.selectedColor.withOpacity(0.1),
                        splashColor: widget.selectedColor.withOpacity(0.2),
                        child: Container(
                          width: double.infinity,
                          height: 72, // 与导航栏总高度一致
                          child: Center( // 直接使用Center组件实现垂直居中
                            child: AnimatedBuilder(
                              animation: Listenable.merge([
                                _scaleController,
                                _slideController,
                                _glowController,
                                _rippleController,
                                _positionController, // 添加位移动画
                              ]),
                              builder: (context, child) {
                                final scale = isSelected
                                    ? _scaleAnimation.value
                                    : 1.0;
                                final slide = isSelected ? _slideAnimation.value : Offset.zero;
                                final ripple = (index == _rippleIndex) ? _rippleAnimation.value : 0.0;

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 涟漪扩散效果
                                    if (ripple > 0)
                                      AnimatedContainer(
                                        duration: Duration.zero,
                                        width: 60 * ripple,
                                        height: 60 * ripple,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.selectedColor.withOpacity(0.2 * (1 - ripple)),
                                          border: Border.all(
                                            color: widget.selectedColor.withOpacity(0.4 * (1 - ripple)),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    
                                    // 文字内容 - 简化结构确保垂直居中
                                    Transform.scale(
                                      scale: scale,
                                      child: Transform.translate(
                                        offset: slide,
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          style: TextStyle(
                                            color: isSelected 
                                              ? Color.lerp(
                                                  widget.selectedColor,
                                                  widget.selectedColor.withOpacity(0.8),
                                                  1 - _glowAnimation.value,
                                                )
                                              : widget.unselectedColor,
                                            fontSize: isSelected 
                                              ? 12 + (1 * _glowAnimation.value) 
                                              : 12,
                                            fontWeight: isSelected 
                                              ? FontWeight.lerp(
                                                  FontWeight.w500,
                                                  FontWeight.w700,
                                                  _glowAnimation.value,
                                                )
                                              : FontWeight.normal,
                                            letterSpacing: isSelected 
                                              ? 0.2 + (0.3 * _glowAnimation.value) 
                                              : 0.2,
                                            shadows: isSelected ? [
                                              Shadow(
                                                color: widget.selectedColor.withOpacity(0.5 * _glowAnimation.value),
                                                blurRadius: 4 * _glowAnimation.value,
                                              ),
                                            ] : null,
                                          ),
                                          child: Text(
                                            item['title'],
                                            textAlign: TextAlign.center, // 水平居中
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}