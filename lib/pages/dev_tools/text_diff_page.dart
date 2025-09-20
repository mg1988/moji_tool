import 'package:flutter/material.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class TextDiffPage extends StatefulWidget {
  const TextDiffPage({super.key});


  @override
  State<TextDiffPage> createState() => _TextDiffPageState();
}

class _TextDiffPageState extends State<TextDiffPage> {
  final TextEditingController _text1Controller = TextEditingController();
  final TextEditingController _text2Controller = TextEditingController();
  final ScrollController _diffScrollController = ScrollController();
  List<Diff> _diffs = [];
  bool _showLineNumbers = true;
  bool _ignoreWhitespace = false;
  bool _ignoreCase = false;

  @override
  void dispose() {
    _text1Controller.dispose();
    _text2Controller.dispose();
    _diffScrollController.dispose();
    super.dispose();
  }

  void _calculateDiff() {
    final dmp = DiffMatchPatch();
    String text1 = _text1Controller.text;
    String text2 = _text2Controller.text;

    if (_ignoreWhitespace) {
      text1 = text1.replaceAll(RegExp(r'\s+'), ' ').trim();
      text2 = text2.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    if (_ignoreCase) {
      text1 = text1.toLowerCase();
      text2 = text2.toLowerCase();
    }

    setState(() {
      _diffs = dmp.diff(text1, text2);
    });
  }

  void _clearTexts() {
    setState(() {
      _text1Controller.clear();
      _text2Controller.clear();
      _diffs = [];
    });
  }

  void _swapTexts() {
    final temp = _text1Controller.text;
    setState(() {
      _text1Controller.text = _text2Controller.text;
      _text2Controller.text = temp;
      _calculateDiff();
    });
  }

  String _getLineNumber(int index, int totalLines) {
    return index.toString().padLeft(totalLines.toString().length);
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '文本对比',
      child: Column(
        children: [
          // 工具栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildToolbar(),
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // 输入区域 - 响应式布局
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // 小屏幕：垂直排列
                        return Column(
                          children: [
                            _buildInputSection(
                              title: '原文本',
                              controller: _text1Controller,
                              onChanged: (_) => _calculateDiff(),
                            ),
                            const SizedBox(height: 16),
                            _buildInputSection(
                              title: '对比文本',
                              controller: _text2Controller,
                              onChanged: (_) => _calculateDiff(),
                            ),
                          ],
                        );
                      } else {
                        // 大屏幕：水平排列
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInputSection(
                                title: '原文本',
                                controller: _text1Controller,
                                onChanged: (_) => _calculateDiff(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputSection(
                                title: '对比文本',
                                controller: _text2Controller,
                                onChanged: (_) => _calculateDiff(),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  
                  // 对比结果区域
                  const SizedBox(height: 20),
                  _buildDiffView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Tooltip(
            message: '交换文本',
            child: MaterialButton(
              onPressed: _swapTexts,
              minWidth: 40,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.grey.shade100,
              elevation: 0,
              child: const Icon(Icons.swap_horiz, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: '清空文本',
            child: MaterialButton(
              onPressed: _clearTexts,
              minWidth: 40,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.grey.shade100,
              elevation: 0,
              child: const Icon(Icons.clear_all, color: Colors.blue),
            ),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [_showLineNumbers, _ignoreWhitespace, _ignoreCase],
            onPressed: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    _showLineNumbers = !_showLineNumbers;
                    break;
                  case 1:
                    _ignoreWhitespace = !_ignoreWhitespace;
                    _calculateDiff();
                    break;
                  case 2:
                    _ignoreCase = !_ignoreCase;
                    _calculateDiff();
                    break;
                }
              });
            },
            constraints: const BoxConstraints(
              minHeight: 36,
              minWidth: 40,
            ),
            borderRadius: BorderRadius.circular(8.0),
            selectedColor: Colors.white,
            selectedBorderColor: Colors.blue,
            fillColor: Colors.blue.shade500,
            borderColor: Colors.grey.shade300,
            children: const [
              Tooltip(
                message: '显示行号',
                child: Icon(Icons.format_list_numbered, size: 18),
              ),
              Tooltip(
                message: '忽略空格',
                child: Icon(Icons.space_bar, size: 18),
              ),
              Tooltip(
                message: '忽略大小写',
                child: Text('Aa', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: controller.text.isEmpty ? null : () {
                  controller.clear();
                  onChanged('');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                tooltip: '清空',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300, // 增加输入框高度
            child: TextField(
              controller: controller,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                isDense: true,
                hintText: '在此输入文本',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffView() {
    if (_diffs.isEmpty) {
      return ToolCard(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.compare_arrows, 
                size: 48, 
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                '请输入要对比的文本',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final lines = <Widget>[];
    int lineNumber = 1;
    String currentLine = '';
    List<TextSpan> currentSpans = [];

    void addLine() {
      if (currentLine.isNotEmpty || currentSpans.isNotEmpty) {
        lines.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              color: lineNumber % 2 == 0 ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                if (_showLineNumbers) ...[
                  Container(
                    width: 50,
                    padding: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      _getLineNumber(lineNumber, lines.length + 1),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'monospace',
                        color: Colors.black,
                      ),
                      children: currentSpans,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        lineNumber++;
        currentLine = '';
        currentSpans = [];
      }
    }

    for (final diff in _diffs) {
      final lines = diff.text.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (i > 0) {
          addLine();
        }
        final text = i < lines.length - 1 ? '${lines[i]}\n' : lines[i];
        if (text.isNotEmpty) {
          Color? backgroundColor;
          Color? textColor;
          switch (diff.operation) {
            case DIFF_DELETE:
              backgroundColor = const Color(0xFFFFEBEE);
              textColor = const Color(0xFFB71C1C);
              break;
            case DIFF_INSERT:
              backgroundColor = const Color(0xFFE8F5E9);
              textColor = const Color(0xFF1B5E20);
              break;
            default:
              backgroundColor = null;
              textColor = null;
          }
          currentSpans.add(
            TextSpan(
              text: text,
              style: TextStyle(
                backgroundColor: backgroundColor,
                color: textColor,
                decorationColor: textColor?.withOpacity(0.4),
                decoration: backgroundColor != null ? TextDecoration.underline : null,
                fontWeight: backgroundColor != null ? FontWeight.w500 : null,
              ),
            ),
          );
          currentLine += text;
        }
      }
    }
    addLine();

    return ToolCard(
      child: SingleChildScrollView(
        controller: _diffScrollController,
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '对比结果',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: const Text(
                      '删除',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                    ),
                    child: const Text(
                      '新增',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),
            ...lines,
          ],
        ),
      ),
    );
  }
}
