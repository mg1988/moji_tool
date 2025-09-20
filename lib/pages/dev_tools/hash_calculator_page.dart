import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class HashCalculatorPage extends StatefulWidget {
  const HashCalculatorPage({Key? key}) : super(key: key);

  @override
  State<HashCalculatorPage> createState() => _HashCalculatorPageState();
}

class _HashCalculatorPageState extends State<HashCalculatorPage> {
  final TextEditingController _inputController = TextEditingController();
  final Map<String, String> _hashResults = {};
  bool _upperCase = true;
  
  final List<HashAlgorithm> _algorithms = [
    HashAlgorithm('MD5', (input) => md5.convert(utf8.encode(input)).toString()),
    HashAlgorithm('SHA-1', (input) => sha1.convert(utf8.encode(input)).toString()),
    HashAlgorithm('SHA-224', (input) => sha224.convert(utf8.encode(input)).toString()),
    HashAlgorithm('SHA-256', (input) => sha256.convert(utf8.encode(input)).toString()),
    HashAlgorithm('SHA-384', (input) => sha384.convert(utf8.encode(input)).toString()),
    HashAlgorithm('SHA-512', (input) => sha512.convert(utf8.encode(input)).toString()),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _calculateHashes() {
    setState(() {
      final input = _inputController.text;
      for (var algorithm in _algorithms) {
        try {
          var result = algorithm.calculate(input);
          if (_upperCase) {
            result = result.toUpperCase();
          }
          _hashResults[algorithm.name] = result;
        } catch (e) {
          _hashResults[algorithm.name] = '计算出错: $e';
        }
      }
    });
  }

  void _copyHash(String algorithmName) {
    final hash = _hashResults[algorithmName];
    if (hash != null && hash.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: hash));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制 $algorithmName 哈希值')),
      );
    }
  }

  void _clearInput() {
    setState(() {
      _inputController.clear();
      _hashResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'Hash 计算',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputSection(),
                  const SizedBox(height: 12),
                  _buildOptionsSection(),
                  const SizedBox(height: 12),
                  _buildResultsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '输入文本',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _inputController.text.isEmpty ? null : _clearInput,
                tooltip: '清空',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _inputController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: '输入要计算哈希值的文本',
              isDense: true,
            ),
            onChanged: (_) => _calculateHashes(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return ToolCard(
      child: Row(
        children: [
          const Text(
            '哈希值格式：',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('大写', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('小写', style: TextStyle(fontSize: 13)),
              ),
            ],
            selected: {_upperCase},
            onSelectionChanged: (Set<bool> newValue) {
              setState(() {
                _upperCase = newValue.first;
                if (_inputController.text.isNotEmpty) {
                  _calculateHashes();
                }
              });
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: _algorithms.map((algorithm) {
        final result = _hashResults[algorithm.name];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ToolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      algorithm.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (result != null && result.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyHash(algorithm.name),
                        tooltip: '复制哈希值',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 12),
                SelectableText(
                  result ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HashAlgorithm {
  final String name;
  final String Function(String) calculate;

  const HashAlgorithm(this.name, this.calculate);
}
