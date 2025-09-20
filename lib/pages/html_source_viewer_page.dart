import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_to_text_app/components/colors.dart';

/// HTML源码查看器页面
class HtmlSourceViewerPage extends StatefulWidget {
  final String sourceCode;
  final String? pageTitle;
  final String? pageUrl;

  const HtmlSourceViewerPage({
    super.key,
    required this.sourceCode,
    this.pageTitle,
    this.pageUrl,
  });

  @override
  State<HtmlSourceViewerPage> createState() => _HtmlSourceViewerPageState();
}

class _HtmlSourceViewerPageState extends State<HtmlSourceViewerPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showLineNumbers = true;
  double _fontSize = 12.0;
  bool _wordWrap = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 复制源码到剪贴板
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.sourceCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 源码已复制到剪贴板'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 保存源码到文件（暂时不实现）
  void _saveToFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 文件保存功能开发中...'),
        backgroundColor: AppColors.textSecondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 搜索功能
  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentSearchIndex = -1;
      });
      return;
    }

    final lines = widget.sourceCode.split('\n');
    final results = <int>[];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().contains(_searchQuery.toLowerCase())) {
        results.add(i);
      }
    }

    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isNotEmpty ? 0 : -1;
    });

    if (results.isNotEmpty) {
      _scrollToLine(results[0]);
    }
  }

  // 下一个搜索结果
  void _nextSearchResult() {
    if (_searchResults.isNotEmpty) {
      setState(() {
        _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
      });
      _scrollToLine(_searchResults[_currentSearchIndex]);
    }
  }

  // 上一个搜索结果
  void _previousSearchResult() {
    if (_searchResults.isNotEmpty) {
      setState(() {
        _currentSearchIndex = (_currentSearchIndex - 1 + _searchResults.length) % _searchResults.length;
      });
      _scrollToLine(_searchResults[_currentSearchIndex]);
    }
  }

  // 滚动到指定行
  void _scrollToLine(int lineNumber) {
    final double lineHeight = _fontSize * 1.4;
    final double targetOffset = lineNumber * lineHeight;
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 调整字体大小
  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(8.0, 24.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 状态栏适配 - 保留状态栏距离
          Container(
            height: safeAreaTop,
            color: AppColors.white, // 状态栏背景色
          ),
          // 自定义AppBar
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: SafeArea(
              top: false, // 已经手动处理了状态栏
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    // 返回按钮
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    // 标题区域
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'HTML 源码查看器',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (widget.pageTitle != null)
                            Text(
                              widget.pageTitle!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // 搜索按钮
                    IconButton(
                      icon: Icon(
                        _showSearchBar ? Icons.search_off : Icons.search,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSearchBar = !_showSearchBar;
                          if (!_showSearchBar) {
                            _searchQuery = '';
                            _searchController.clear();
                            _searchResults.clear();
                            _currentSearchIndex = -1;
                          }
                        });
                      },
                      tooltip: _showSearchBar ? '关闭搜索' : '搜索',
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    // 设置按钮
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      offset: const Offset(0, 45),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'line_numbers',
                          child: Row(
                            children: [
                              Icon(
                                _showLineNumbers ? Icons.format_list_numbered : Icons.format_list_numbered_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(_showLineNumbers ? '隐藏行号' : '显示行号'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'word_wrap',
                          child: Row(
                            children: [
                              Icon(
                                _wordWrap ? Icons.wrap_text : Icons.wrap_text_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(_wordWrap ? '取消换行' : '自动换行'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'font_increase',
                          child: Row(
                            children: [
                              Icon(Icons.zoom_in, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('放大字体'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'font_decrease',
                          child: Row(
                            children: [
                              Icon(Icons.zoom_out, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('缩小字体'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('复制源码'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.save, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('保存文件'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'line_numbers':
                            setState(() {
                              _showLineNumbers = !_showLineNumbers;
                            });
                            break;
                          case 'word_wrap':
                            setState(() {
                              _wordWrap = !_wordWrap;
                            });
                            break;
                          case 'font_increase':
                            _adjustFontSize(1.0);
                            break;
                          case 'font_decrease':
                            _adjustFontSize(-1.0);
                            break;
                          case 'copy':
                            _copyToClipboard();
                            break;
                          case 'save':
                            _saveToFile();
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 搜索栏
          if (_showSearchBar)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '搜索源码...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        _searchQuery = value;
                        _performSearch();
                      },
                      onSubmitted: (value) => _performSearch(),
                    ),
                  ),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${_currentSearchIndex + 1}/${_searchResults.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                        onPressed: _searchResults.isNotEmpty ? _previousSearchResult : null,
                        tooltip: '上一个',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        onPressed: _searchResults.isNotEmpty ? _nextSearchResult : null,
                        tooltip: '下一个',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // 源码显示区域
          Expanded(
            child: _buildSourceCodeViewer(),
          ),
          // 底部信息栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.code,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.pageUrl ?? '未知页面',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${widget.sourceCode.split('\n').length} 行 • ${_fontSize.toInt()}px',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCodeViewer() {
    final lines = widget.sourceCode.split('\n');
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行号区域
          if (_showLineNumbers)
            Container(
              width: 60,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border(
                  right: BorderSide(color: Color(0xFF444444), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lines.length, (index) {
                  final lineNumber = index + 1;
                  final isHighlighted = _searchResults.contains(index) &&
                      _currentSearchIndex >= 0 &&
                      _searchResults[_currentSearchIndex] == index;
                  
                  return Container(
                    height: _fontSize * 1.4,
                    alignment: Alignment.centerRight,
                    decoration: isHighlighted
                        ? BoxDecoration(
                            color: Colors.yellow.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: Text(
                      lineNumber.toString(),
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: _fontSize - 1,
                        color: isHighlighted 
                            ? Colors.yellow.shade800
                            : Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  );
                }),
              ),
            ),
          // 源码内容区域
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: _wordWrap
                  ? _buildWrappedSourceCode(lines)
                  : _buildNormalSourceCode(lines),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalSourceCode(List<String> lines) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines.length, (index) {
          final line = lines[index];
          final isHighlighted = _searchResults.contains(index) &&
              _currentSearchIndex >= 0 &&
              _searchResults[_currentSearchIndex] == index;
          
          return Container(
            height: _fontSize * 1.4,
            alignment: Alignment.centerLeft,
            decoration: isHighlighted
                ? BoxDecoration(
                    color: Colors.yellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: _buildSyntaxHighlightedText(line),
          );
        }),
      ),
    );
  }

  Widget _buildWrappedSourceCode(List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines.length, (index) {
        final line = lines[index];
        final isHighlighted = _searchResults.contains(index) &&
            _currentSearchIndex >= 0 &&
            _searchResults[_currentSearchIndex] == index;
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(vertical: 1),
          decoration: isHighlighted
              ? BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: _buildSyntaxHighlightedText(line),
        );
      }),
    );
  }

  Widget _buildSyntaxHighlightedText(String text) {
    return SelectableText(
      text.isEmpty ? ' ' : text, // 空行显示空格以保持行高
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: _fontSize,
        color: _getSyntaxColor(text),
        height: 1.4,
      ),
    );
  }

  Color _getSyntaxColor(String text) {
    final trimmed = text.trim();
    
    // HTML注释
    if (trimmed.startsWith('<!--') || trimmed.contains('<!--')) {
      return Colors.grey.shade400;
    }
    
    // HTML标签
    if (trimmed.startsWith('<') && trimmed.contains('>')) {
      if (trimmed.startsWith('<!DOCTYPE') || trimmed.startsWith('<!doctype')) {
        return Colors.purple.shade300;
      }
      return Colors.blue.shade300;
    }
    
    // CSS样式
    if (trimmed.contains('{') || trimmed.contains('}') || 
        (trimmed.contains(':') && trimmed.contains(';'))) {
      return Colors.cyan.shade300;
    }
    
    // JavaScript代码
    if (trimmed.contains('function') || trimmed.contains('var ') ||
        trimmed.contains('let ') || trimmed.contains('const ') ||
        trimmed.contains('=>') || trimmed.contains('console.')) {
      return Colors.yellow.shade300;
    }
    
    // 字符串内容（简单检测）
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      return Colors.green.shade300;
    }
    
    // 默认颜色
    return Colors.green.shade100;
  }
}