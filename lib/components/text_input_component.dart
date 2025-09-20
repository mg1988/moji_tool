import 'package:flutter/material.dart';

// 文本输入组件
class TextInputComponent extends StatelessWidget {
  final TextEditingController controller;

  const TextInputComponent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: '请输入要转换的文本',
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}