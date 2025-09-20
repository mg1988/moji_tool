import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'package:voice_to_text_app/models/pdf_file.dart';
import '../components/history_list_component.dart';
import '../utils/Native.dart';
// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<PdfFile> savedTexts = [];

  @override
  void initState() {
    super.initState();
    loadSavedTexts();
  }

  Future<void> loadSavedTexts() async {
    Native.callNative("getPdfHistory", {}).then((value) {
      print("getPdfHistory===>$value");
      setState(() {
        savedTexts = List<PdfFile>.from(value);
      });
    });
  }

  Future<void> deleteText(int index) async {
    var file = savedTexts[index];
    setState(() {
      
      savedTexts.removeAt(index);
    });
     Native.callNative("deletePdfFile", {"id":file.id}).then((value) {
       // 删除文件
    });
  }


  Future<void> clearAllTexts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTexts = [];
    });
    await prefs.remove('savedTexts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (savedTexts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.primary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('清除所有历史记录'),
                    content: const Text('确定要清除所有历史记录吗？此操作不可恢复。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          clearAllTexts();
                        },
                        child: const Text('确定', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              tooltip: '清除所有',
            ),
        ],
      ),
      body: SafeArea(
        child: HistoryListComponent(
          savedTexts: savedTexts,
          onPlayText: (text) {
            // 播放文本
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('播放文本: $text')),
            );
          },
          onDeleteText: (index) {
            deleteText(index);
          },
        ),
      ),
    );
  }
}