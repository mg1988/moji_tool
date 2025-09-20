import 'package:flutter/material.dart';

// 历史记录项组件
class HistoryItemComponent extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const HistoryItemComponent({
    super.key,
    required this.text,
    required this.index,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            (index + 1).toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
              onPressed: onPlay,
              tooltip: '播放',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }
}