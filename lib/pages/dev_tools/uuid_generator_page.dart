import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class UuidGeneratorPage extends StatefulWidget {
  const UuidGeneratorPage({super.key});

  @override
  State<UuidGeneratorPage> createState() => _UuidGeneratorPageState();
}

class _UuidGeneratorPageState extends State<UuidGeneratorPage> {
  // UUID生成器实例
  final Uuid _uuid = Uuid();
  
  // 生成的UUID
  String _generatedUuid = '';
  
  // UUID版本选择
  String _selectedVersion = 'v4';
  
  // 是否添加连字符
  bool _includeHyphens = true;
  
  // 是否大写输出
  bool _uppercaseOutput = false;
  
  // 生成历史记录
  List<String> _history = [];
  
  // 生成数量控制器
  final TextEditingController _countController = TextEditingController(text: '1');
  
  // 自定义命名空间和名称输入（用于v3和v5）
  final TextEditingController _namespaceController = TextEditingController(text: '6ba7b810-9dad-11d1-80b4-00c04fd430c8'); // 标准DNS命名空间
  final TextEditingController _nameController = TextEditingController(text: 'example.com');
  
  @override
  void initState() {
    super.initState();
    _generateUuid();
  }
  
  // 生成UUID
  void _generateUuid() {
    String uuid = '';
    
    try {
      int count = int.parse(_countController.text.trim());
      if (count < 1) count = 1;
      if (count > 100) count = 100; // 限制最大生成数量，防止性能问题
      
      setState(() {
        _history.clear();
        
        for (int i = 0; i < count; i++) {
          String newUuid = _generateSingleUuid();
          if (count == 1) {
            _generatedUuid = newUuid;
          }
          _history.add(newUuid);
        }
      });
    } catch (e) {
      // 输入非数字时默认生成1个UUID
      setState(() {
        uuid = _generateSingleUuid();
        _generatedUuid = uuid;
        _history = [uuid];
      });
    }
  }
  
  // 生成单个UUID
  String _generateSingleUuid() {
    String uuid = '';
    
    switch (_selectedVersion) {
      case 'v1':
        uuid = const Uuid().v1();
        break;
      case 'v4':
        uuid = const Uuid().v4();
        break;
      case 'v5':
        // v5需要namespace和name
        final namespace = _namespaceController.text.trim().isNotEmpty ? _namespaceController.text.trim() : Uuid.NAMESPACE_URL;
        uuid = const Uuid().v5(namespace, _nameController.text.trim());
        break;
    }
    
    // 处理连字符和大小写
    if (!_includeHyphens) {
      uuid = uuid.replaceAll('-', '');
    }
    
    if (_uppercaseOutput) {
      uuid = uuid.toUpperCase();
    }
    
    return uuid;
  }
  
  // 复制UUID到剪贴板
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }
  
  // 生成并复制多个UUID
  void _copyAllHistory() {
    if (_history.isEmpty) return;
    
    String allUuids = _history.join('\n');
    Clipboard.setData(ClipboardData(text: allUuids));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('所有UUID已复制到剪贴板')),
    );
  }
  
  // UUID版本说明
  String _getVersionDescription(String version) {
    switch (version) {
      case 'v1':
        return '基于时间戳和MAC地址生成';
      case 'v4':
        return '基于随机数生成（最常用）';
      case 'v5':
        return '基于命名空间和名称的SHA-1哈希';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'UUID生成器',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 结果显示卡片
            ToolCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                      [
                        const Text('生成结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: () => _copyToClipboard(_generatedUuid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy, size: 16),
                              SizedBox(width: 4),
                              Text('复制'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _generatedUuid,
                          key: ValueKey(_generatedUuid),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 生成设置卡片
            ToolCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    const Text('生成设置:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    // UUID版本选择
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        const Text('UUID版本:'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildVersionButton('v1'),
                            _buildVersionButton('v4'),
                            _buildVersionButton('v5'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getVersionDescription(_selectedVersion),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 生成数量
                    TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '生成数量',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 自定义选项
                    Row(
                      children:
                      [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('包含连字符'),
                            value: _includeHyphens,
                            onChanged: (bool? value) {
                              setState(() {
                                _includeHyphens = value ?? true;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('大写输出'),
                            value: _uppercaseOutput,
                            onChanged: (bool? value) {
                              setState(() {
                                _uppercaseOutput = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 生成按钮
                    ElevatedButton(
                      onPressed: _generateUuid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('重新生成', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // v3/v5设置卡片（仅在选择对应版本时显示）
            if (_selectedVersion == 'v3' || _selectedVersion == 'v5')
              ToolCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text('$_selectedVersion 设置:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      
                      // 命名空间输入
                      TextField(
                        controller: _namespaceController,
                        decoration: const InputDecoration(
                          labelText: '命名空间UUID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 名称输入
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '名称',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // 生成历史卡片
            if (_history.length > 1)
              ToolCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Text('生成历史 (${_history.length}):', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            onPressed: _copyAllHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('复制全部'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _history[index],
                                style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => _copyToClipboard(_history[index]),
                                tooltip: '复制此UUID',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // 使用说明卡片
            const ToolCard(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  [
                    Text('使用说明:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('1. 选择需要的UUID版本（v1, v4, v5）'),
                    Text('2. 可选择是否包含连字符和是否使用大写输出'),
                    Text('3. 如需生成多个UUID，可修改生成数量'),
                    Text('4. 对于v5版本，需要输入命名空间和名称'),
                    Text('5. 点击"重新生成"按钮生成新的UUID'),
                    Text('6. 点击"复制"按钮将UUID复制到剪贴板'),
                    Text('7. 生成多个UUID时，可查看历史记录并复制全部'),
                  ],
                ),
              ),
            ),
            
            // 添加底部间距，确保所有内容都能完全显示
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  
  // 构建版本选择按钮
  Widget _buildVersionButton(String version) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedVersion = version;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedVersion == version ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(version),
    );
  }
  
  @override
  void dispose() {
    _countController.dispose();
    _namespaceController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}