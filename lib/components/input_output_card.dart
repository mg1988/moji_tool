import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class InputOutputCard extends StatelessWidget {
  final TextEditingController? inputController;
  final TextEditingController? outputController;
  final String inputLabel;
  final String outputLabel;
  final int inputMaxLines;
  final int outputMaxLines;
  final bool readOnly;
  final VoidCallback? onClear;
  final VoidCallback? onCopy;

  const InputOutputCard({
    Key? key,
    this.inputController,
    this.outputController,
    this.inputLabel = '输入',
    this.outputLabel = '输出',
    this.inputMaxLines = 5,
    this.outputMaxLines = 5,
    this.readOnly = false,
    this.onClear,
    this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inputLabel,
                style: AppTextStyles.pageTitle,
              ),
              if (onClear != null)
                IconButton(
                  icon: Icon(Icons.clear, color: AppColors.primaryBtn),
                  onPressed: onClear,
                  tooltip: '清空',
                  splashRadius: 20,
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: inputController,
            maxLines: inputMaxLines,
            style: AppTextStyles.body,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.primaryBtn),
              ),
              hintText: '请输入内容...',
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                outputLabel,
                style: AppTextStyles.pageTitle,
              ),
              if (onCopy != null)
                IconButton(
                  icon: Icon(Icons.copy, color: AppColors.primaryBtn),
                  onPressed: onCopy,
                  tooltip: '复制',
                  splashRadius: 20,
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: outputController,
            maxLines: outputMaxLines,
            readOnly: true,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              hintText: '输出结果...',
              hintStyle: AppTextStyles.hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
