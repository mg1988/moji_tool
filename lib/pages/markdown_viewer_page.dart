import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_to_text_app/components/colors.dart';

/// Markdown 文档查看器
class MarkdownViewerPage extends StatefulWidget {
  final String fileName;
  final String title;

  const MarkdownViewerPage({
    super.key,
    required this.fileName,
    required this.title,
  });

  @override
  State<MarkdownViewerPage> createState() => _MarkdownViewerPageState();
}

class _MarkdownViewerPageState extends State<MarkdownViewerPage> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content = await rootBundle.loadString('lib/assets/${widget.fileName}');
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = '文件加载失败：$e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 内容已复制到剪贴板'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // 字体大小调节
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            tooltip: '调节字体大小',
            onSelected: (fontSize) {
              // 这里可以实现字体大小调节功能
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('字体大小: ${fontSize.toInt()}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 12.0,
                child: Text('小'),
              ),
              const PopupMenuItem(
                value: 15.0,
                child: Text('中'),
              ),
              const PopupMenuItem(
                value: 18.0,
                child: Text('大'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: '复制内容',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Container(
              margin: const EdgeInsets.all(16),
              decoration: AppCardStyles.featureCard,
              child: _MarkdownRenderer(content: _content),
            ),
    );
  }
}

/// 简化的 Markdown 渲染器
class _MarkdownRenderer extends StatelessWidget {
  final String content;

  const _MarkdownRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      widgets.add(_renderLine(line));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _renderLine(String line) {
    // 空行
    if (line.trim().isEmpty) {
      return const SizedBox(height: 8);
    }

    // 一级标题 #
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          line.substring(2),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
      );
    }

    // 二级标题 ##
    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          line.substring(3),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      );
    }

    // 三级标题 ###
    if (line.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          line.substring(4),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      );
    }

    // 四级标题 ####
    if (line.startsWith('#### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          line.substring(5),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      );
    }

    // 无序列表 -
    if (line.trim().startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• ',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                line.trim().substring(2),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 有序列表 1. 2. 3.
    final numberListMatch = RegExp(r'^\d+\.\s+').firstMatch(line.trim());
    if (numberListMatch != null) {
      final number = numberListMatch.group(0)!;
      final content = line.trim().substring(number.length);
      
      return Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 引用块 >
    if (line.trim().startsWith('> ')) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          border: const Border(
            left: BorderSide(
              color: AppColors.primary,
              width: 4,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Text(
          line.trim().substring(2),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      );
    }

    // 代码块 ```
    if (line.trim().startsWith('```')) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '代码块内容',
          style: TextStyle(
            fontSize: 14,
            color: Colors.green,
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
      );
    }

    // 行内代码 `code`
    if (line.contains('`') && line.split('`').length > 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: _renderInlineCode(line),
      );
    }

    // 粗体 **text**
    if (line.contains('**')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: _renderBoldText(line),
      );
    }

    // 普通段落
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        line,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _renderInlineCode(String line) {
    final parts = <TextSpan>[];
    final segments = line.split('`');
    
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        // 普通文本
        parts.add(TextSpan(
          text: segments[i],
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ));
      } else {
        // 代码文本
        parts.add(TextSpan(
          text: segments[i],
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontFamily: 'monospace',
            backgroundColor: Color(0xFFF5F5F5),
            height: 1.6,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }

  Widget _renderBoldText(String line) {
    final parts = <TextSpan>[];
    final segments = line.split('**');
    
    for (int i = 0; i < segments.length; i++) {
      if (i % 2 == 0) {
        // 普通文本
        parts.add(TextSpan(
          text: segments[i],
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ));
      } else {
        // 粗体文本
        parts.add(TextSpan(
          text: segments[i],
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }
}