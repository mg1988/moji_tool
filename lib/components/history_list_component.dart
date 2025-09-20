import 'package:flutter/material.dart';
import 'package:voice_to_text_app/models/pdf_file.dart';
import 'history_item_component.dart';

// 历史记录列表组件
class HistoryListComponent extends StatelessWidget {
  final List<PdfFile> savedTexts;
  final ValueChanged<String> onPlayText;
  final ValueChanged<int> onDeleteText;

  const HistoryListComponent({
    super.key,
    required this.savedTexts,
    required this.onPlayText,
    required this.onDeleteText,
  });

  @override
  Widget build(BuildContext context) {
    if (savedTexts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history, 
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无历史记录',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: savedTexts.length,
      itemBuilder: (context, index) {
        return HistoryItemComponent(
          text: savedTexts[index].fileName,
          index: index,
          onPlay: () => onPlayText(savedTexts[index].filePath),
          onDelete: () => onDeleteText(index),
        );
      },
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}