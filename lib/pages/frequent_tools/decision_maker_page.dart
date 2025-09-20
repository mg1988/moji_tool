import 'package:flutter/material.dart';
import 'package:voice_to_text_app/components/base_tool_page.dart';
import 'dart:math';
import 'dart:async';
import 'package:voice_to_text_app/components/colors.dart';

class DecisionMakerPage extends StatefulWidget {
  const DecisionMakerPage({super.key});

  @override
  State<DecisionMakerPage> createState() => _DecisionMakerPageState();
}

class _DecisionMakerPageState extends State<DecisionMakerPage> {
  final List<String> _options = [];
  String _result = '';
  bool _isDeciding = false;
  final TextEditingController _optionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 添加10个默认选项
    _options.addAll([
      '去健身房运动',
      '看一部电影',
      '阅读一小时',
      '学习新技能',
      '外出散步',
      '烹饪一顿美食',
      '和朋友聚会',
      '听音乐放松',
      '玩游戏娱乐',
      '早点休息'
    ]);
  }

  void _addOption() {
    String option = _optionController.text.trim();
    if (option.isNotEmpty && !_options.contains(option)) {
      setState(() {
        _options.add(option);
        _optionController.clear();
      });
    }
  }

  void _removeOption(String option) {
    setState(() {
      _options.remove(option);
    });
  }

  void _makeDecision() {
    if (_isDeciding || _options.isEmpty) return;

    setState(() {
      _isDeciding = true;
      _result = '';
    });

    // 模拟决策过程的动画
    int randomIndex = 0;
    int decisionCount = 0;
    int totalDecisions = 20; // 总共进行20次随机选择

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        randomIndex = Random().nextInt(_options.length);
        _result = _options[randomIndex];
      });

      decisionCount++;
      if (decisionCount >= totalDecisions) {
        timer.cancel();
        setState(() {
          _isDeciding = false;
        });
      }
    });
  }

  void _clearAll() {
    setState(() {
      _options.clear();
      _result = '';
      _optionController.clear();
    });
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '做个决定',
      actions: [IconButton(
            icon: const Icon(Icons.clear_all, color: AppColors.black),
            onPressed: _clearAll,
          ),],
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 结果显示区域
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.white,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Text(
                        _result.isEmpty ? '还没有结果' : _result,
                        key: ValueKey(_result),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Arial',
                          letterSpacing: 1,
                        ).merge(AppTextStyles.pageTitle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // 选项管理区域
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '添加选项',
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _optionController,
                              style: AppTextStyles.body,
                              decoration: InputDecoration(
                                labelText: '输入选项内容',
                                labelStyle: AppTextStyles.caption,
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
                            onPressed: _addOption,
                            style: AppButtonStyles.primaryButton,
                            child: const Icon(Icons.add, color: AppColors.white),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // 选项列表
                      Expanded(
                        child: _options.isEmpty
                            ? const Center(
                                child: Text(
                                  '还没有添加选项',
                                  style: AppTextStyles.caption,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _options.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: AppColors.white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary.withOpacity(0.1),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(color: AppColors.primary),
                                        ),
                                      ),
                                      title: Text(
                                        _options[index],
                                        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle, color: AppColors.accent),
                                        onPressed: () => _removeOption(_options[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 15),

                      // 决策按钮
                      ElevatedButton(
                        onPressed: _makeDecision,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDeciding ? Colors.grey : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ).merge(AppButtonStyles.primaryButton),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lightbulb, size: 24, color: AppColors.white),
                            const SizedBox(width: 10),
                            Text(_isDeciding ? '决定中...' : '随机决定'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}