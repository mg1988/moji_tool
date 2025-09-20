import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';
import '../../data/regex_rules.dart';

class RegexTestPage extends StatefulWidget {
  const RegexTestPage({Key? key}) : super(key: key);

  @override
  State<RegexTestPage> createState() => _RegexTestPageState();
}

class _RegexTestPageState extends State<RegexTestPage> {
  final TextEditingController _patternController = TextEditingController();
  final TextEditingController _testTextController = TextEditingController();
  List<RegExpMatch>? _matches;
  RegexRule? _selectedRule;
  String? _error;

  @override
  void dispose() {
    _patternController.dispose();
    _testTextController.dispose();
    super.dispose();
  }

  void _updateMatches() {
    setState(() {
      try {
        final pattern = _patternController.text;
        if (pattern.isEmpty) {
          _matches = null;
          _error = null;
          return;
        }

        final regex = RegExp(pattern);
        _matches = regex.allMatches(_testTextController.text).toList();
        _error = null;
      } catch (e) {
        _matches = null;
        _error = '正则表达式格式错误';
      }
    });
  }
  
  void _validateRegex() {
    if (_patternController.text.isEmpty) {
      _showResultDialog('请输入正则表达式');
      return;
    }
    if (_testTextController.text.isEmpty) {
      _showResultDialog('请输入测试文本');
      return;
    }

    try {
      final regex = RegExp(_patternController.text);
      final matches = regex.allMatches(_testTextController.text).toList();
      
      if (matches.isEmpty) {
        _showResultDialog('测试结果：不匹配\n\n该文本与正则表达式不匹配');
      } else {
        final matchesText = matches
            .map((m) => '• 匹配文本：${m.group(0)}\n  位置：${m.start}-${m.end}')
            .join('\n\n');
        _showResultDialog('测试结果：匹配成功\n\n找到 ${matches.length} 处匹配：\n\n$matchesText');
      }
    } catch (e) {
      _showResultDialog('正则表达式格式错误\n\n请检查正则表达式的语法');
    }
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('验证结果'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _copyPattern() {
    if (_patternController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _patternController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制正则表达式')),
      );
    }
  }

  void _selectRule(RegexRule rule) {
    setState(() {
      _selectedRule = rule;
      _patternController.text = rule.pattern;
      _updateMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '正则测试',
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRuleSelector(),
              const SizedBox(height: 16),
              _buildPatternInput(),
              const SizedBox(height: 16),
              _buildTestInput(),
              if (_matches != null && _matches!.isNotEmpty)
                _buildMatchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleSelector() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '常用正则',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: regexRules.map((rule) {
                final isSelected = _selectedRule == rule;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(rule.name),
                    selected: isSelected,
                    onSelected: (_) => _selectRule(rule),
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_selectedRule != null) ...[
            const SizedBox(height: 8),
            Text(
              _selectedRule!.description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternInput() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '正则表达式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _copyPattern,
                tooltip: '复制正则表达式',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _patternController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: _error,
              hintText: '输入正则表达式',
            ),
            onChanged: (_) => _updateMatches(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestInput() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '测试文本',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _testTextController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '输入要测试的文本',
            ),
            maxLines: 3,
            onChanged: (_) => _updateMatches(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateRegex,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('验证'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResults() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '匹配结果 (${_matches!.length}个)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _matches!.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final match = _matches![index];
              return ListTile(
                title: Text(
                  match.group(0) ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '位置: ${match.start}-${match.end}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: match.group(0) ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制匹配结果')),
                    );
                  },
                  tooltip: '复制匹配结果',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
