import 'package:flutter/material.dart';

/// 信息卡片组件
/// 用于展示键值对信息，支持复制功能
class InfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> infoMap;
  final bool showCopyButtons;
  final Function(String, String)? onCopy;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsets padding;

  const InfoCard({
    super.key,
    required this.title,
    required this.infoMap,
    this.showCopyButtons = true,
    this.onCopy,
    this.borderRadius = 12.0,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          // 标题
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          
          // 信息项
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: infoMap.entries.map((entry) {
              return InfoItem(
                label: entry.key,
                value: entry.value,
                onCopy: onCopy,
                showCopyButton: showCopyButtons,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 信息项组件
/// 用于展示单个键值对信息，支持复制功能
class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Function(String, String)? onCopy;
  final bool showCopyButton;

  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    required this.onCopy,
    this.showCopyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
          [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showCopyButton && onCopy != null)
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => onCopy!(value, label),
                tooltip: '复制$label',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
          ],
        ),
      ],
    );
  }
}