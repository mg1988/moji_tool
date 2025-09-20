import 'package:flutter/material.dart';
import 'package:voice_to_text_app/components/base_tool_page.dart';
import 'dart:math';
import 'dart:async';
import '../../components/colors.dart';

class FoodDecisionPage extends StatefulWidget {
  const FoodDecisionPage({super.key});

  @override
  State<FoodDecisionPage> createState() => _FoodDecisionPageState();
}

class _FoodDecisionPageState extends State<FoodDecisionPage> {
  final List<String> _foodList = [
    '火锅', '烧烤', '炒菜', '快餐', '寿司', '披萨', '汉堡', '炸鸡',
    '日料', '西餐', '韩料', '中餐', '小吃', '甜点', '水果', '粥',
    '面条', '米饭', '饺子', '包子', '馒头', '米线', '麻辣烫', '烤肉',
    '海鲜', '素食', '火锅', '烧烤', '炒菜', '快餐', '寿司', '披萨',
    '汉堡', '炸鸡', '日料', '西餐', '韩料', '中餐', '小吃', '甜点',
    '水果', '粥', '面条', '米饭', '饺子', '包子', '馒头', '米线',
    '麻辣烫', '烤肉', '海鲜', '素食'
  ];

  final List<String> _customFoodList = [];
  String _result = '';
  bool _isSpinning = false;
  final TextEditingController _customFoodController = TextEditingController();

  void _spinFoodWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _result = '';
    });

    // 合并默认食物和自定义食物
    List<String> allFoods = [..._foodList, ..._customFoodList];
    if (allFoods.isEmpty) {
      setState(() {
        _isSpinning = false;
        _result = '没有可用的食物选项';
      });
      return;
    }

    // 模拟转盘动画
    int randomIndex = 0;
    int spinCount = 0;
    int totalSpins = 20; // 总共转20次

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (spinCount >= totalSpins) {
        timer.cancel();
        setState(() {
          _isSpinning = false;
        });
        return;
      }

      setState(() {
        randomIndex = Random().nextInt(allFoods.length);
        _result = allFoods[randomIndex];
      });

      spinCount++;
    });
  }

  void _addCustomFood() {
    String food = _customFoodController.text.trim();
    if (food.isNotEmpty && !_customFoodList.contains(food)) {
      setState(() {
        _customFoodList.add(food);
        _customFoodController.clear();
      });
    }
  }

  void _removeCustomFood(String food) {
    setState(() {
      _customFoodList.remove(food);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '今天吃点啥',
      child:Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 结果显示区域
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: AppCardStyles.featureCard,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          _result.isEmpty ? '点击下方按钮选择' : _result,
                          key: ValueKey(_result),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Arial',
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // 旋转按钮
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ElevatedButton(
                        onPressed: _spinFoodWheel,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            _isSpinning ? AppColors.border : AppColors.primary
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            )
                          ),
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            )
                          ),
                          elevation: WidgetStateProperty.all(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20, color: _isSpinning ? AppColors.textHint : AppColors.white),
                            const SizedBox(width: 10),
                            Text(
                              _isSpinning ? '选择中...' : '随机选择',
                              style: TextStyle(color: _isSpinning ? AppColors.textHint : AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 自定义食物区域
              Expanded(
                flex: 1,
                child: Container(
                  decoration: AppCardStyles.basicCard,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '自定义食物',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customFoodController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: '输入食物名称',
                                labelStyle: const TextStyle(color: AppColors.textHint),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addCustomFood,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(AppColors.primary),
                              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 15, vertical: 15)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            child: const Icon(Icons.add, color: AppColors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 自定义食物列表
                      if (_customFoodList.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: _customFoodList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: AppCardStyles.basicCard,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    _customFoodList[index],
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: AppColors.accent),
                                    onPressed: () => _removeCustomFood(_customFoodList[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}