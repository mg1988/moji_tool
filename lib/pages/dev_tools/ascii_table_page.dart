import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class AsciiTablePage extends StatefulWidget {
  const AsciiTablePage({super.key});

  @override
  State<AsciiTablePage> createState() => _AsciiTablePageState();
}

class _AsciiTablePageState extends State<AsciiTablePage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  // 筛选后的ASCII列表
  List<Map<String, dynamic>> _filteredAsciiList = [];
  // 当前选中的ASCII字符
  Map<String, dynamic>? _selectedAscii;
  // 搜索类型（'decimal', 'hex', 'char'）
  String _searchType = 'decimal';

  @override
  void initState() {
    super.initState();
    // 生成完整的ASCII表
    _generateAsciiTable();
    // 监听搜索输入
    _searchController.addListener(_onSearchChanged);
  }

  // 生成ASCII表数据
  void _generateAsciiTable() {
    List<Map<String, dynamic>> asciiList = [];
    
    for (int i = 0; i <= 127; i++) {
      // 跳过不可打印字符，除了空格和换行符
      bool isPrintable = i >= 32 && i <= 126 || i == 9 || i == 10 || i == 13;
      
      if (i < 32 || i == 127) {
        // 控制字符
        String name = _getControlCharName(i);
        asciiList.add({
          'decimal': i,
          'hex': i.toRadixString(16).toUpperCase().padLeft(2, '0'),
          'binary': i.toRadixString(2).padLeft(8, '0'),
          'char': isPrintable ? String.fromCharCode(i) : '',
          'name': name,
          'type': 'control',
        });
      } else {
        // 可打印字符
        asciiList.add({
          'decimal': i,
          'hex': i.toRadixString(16).toUpperCase().padLeft(2, '0'),
          'binary': i.toRadixString(2).padLeft(8, '0'),
          'char': String.fromCharCode(i),
          'name': 'Printable Character',
          'type': 'printable',
        });
      }
    }
    
    setState(() {
      _filteredAsciiList = asciiList;
    });
  }

  // 获取控制字符的名称
  String _getControlCharName(int code) {
    const Map<int, String> controlCharNames = {
      0: 'NUL (Null character)',
      1: 'SOH (Start of Heading)',
      2: 'STX (Start of Text)',
      3: 'ETX (End of Text)',
      4: 'EOT (End of Transmission)',
      5: 'ENQ (Enquiry)',
      6: 'ACK (Acknowledgment)',
      7: 'BEL (Bell)',
      8: 'BS (Backspace)',
      9: 'HT (Horizontal Tab)',
      10: 'LF (Line Feed)',
      11: 'VT (Vertical Tab)',
      12: 'FF (Form Feed)',
      13: 'CR (Carriage Return)',
      14: 'SO (Shift Out)',
      15: 'SI (Shift In)',
      16: 'DLE (Data Link Escape)',
      17: 'DC1 (Device Control 1)',
      18: 'DC2 (Device Control 2)',
      19: 'DC3 (Device Control 3)',
      20: 'DC4 (Device Control 4)',
      21: 'NAK (Negative Acknowledgment)',
      22: 'SYN (Synchronize)',
      23: 'ETB (End of Transmission Block)',
      24: 'CAN (Cancel)',
      25: 'EM (End of Medium)',
      26: 'SUB (Substitute)',
      27: 'ESC (Escape)',
      28: 'FS (File Separator)',
      29: 'GS (Group Separator)',
      30: 'RS (Record Separator)',
      31: 'US (Unit Separator)',
      127: 'DEL (Delete)',
    };
    
    return controlCharNames[code] ?? 'Control Character';
  }

  // 搜索功能
  void _onSearchChanged() {
    String query = _searchController.text.trim().toLowerCase();
    
    if (query.isEmpty) {
      _generateAsciiTable();
      return;
    }

    List<Map<String, dynamic>> filteredList = [];
    
    for (var ascii in _filteredAsciiList) {
      bool match = false;
      
      if (_searchType == 'decimal') {
        match = ascii['decimal'].toString().contains(query);
      } else if (_searchType == 'hex') {
        match = ascii['hex'].toLowerCase().contains(query);
      } else if (_searchType == 'char') {
        match = ascii['char'].toLowerCase().contains(query);
      }
      
      if (match) {
        filteredList.add(ascii);
      }
    }
    
    setState(() {
      _filteredAsciiList = filteredList;
    });
  }

  // 复制到剪贴板
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  // 设置搜索类型
  void _setSearchType(String type) {
    setState(() {
      _searchType = type;
      _searchController.clear();
      _generateAsciiTable();
    });
  }

  // 构建ASCII字符卡片
  Widget _buildAsciiCard(Map<String, dynamic> ascii) {
    bool isSelected = _selectedAscii != null && _selectedAscii!['decimal'] == ascii['decimal'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAscii = ascii;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 字符显示
            ascii['type'] == 'printable' || (ascii['type'] == 'control' && ascii['char'].isNotEmpty)
                ? Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      ascii['char'] == ' ' ? '[空格]' : ascii['char'],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      ascii['name'].split(' ')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
            // 十进制值
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: 'ASCII码表',
      child: Column(
        children: [
          // 搜索栏
          ToolCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 搜索类型选择
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSearchTypeButton('十进制', 'decimal'),
                      _buildSearchTypeButton('十六进制', 'hex'),
                      _buildSearchTypeButton('字符', 'char'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 搜索输入框
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: _searchType == 'decimal' ? '搜索十进制值' : 
                                _searchType == 'hex' ? '搜索十六进制值' : '搜索字符',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 选中的ASCII字符详情
          if (_selectedAscii != null) _buildSelectedAsciiDetail(),

          // ASCII码表网格
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _filteredAsciiList.isEmpty
                  ? const Center(child: Text('未找到匹配的ASCII字符'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // 每行显示8个字符
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: _filteredAsciiList.length,
                      itemBuilder: (context, index) {
                        return _buildAsciiCard(_filteredAsciiList[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建搜索类型按钮
  Widget _buildSearchTypeButton(String label, String type) {
    bool isActive = _searchType == type;
    
    return ElevatedButton(
      onPressed: () => _setSearchType(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }

  // 构建选中的ASCII字符详情卡片
  Widget _buildSelectedAsciiDetail() {
    if (_selectedAscii == null) return Container();
    
    return ToolCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '字符详情',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 字符预览
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: _selectedAscii!['type'] == 'printable' || 
                         (_selectedAscii!['type'] == 'control' && _selectedAscii!['char'].isNotEmpty)
                      ? Text(
                          _selectedAscii!['char'] == ' ' ? '[空格]' : _selectedAscii!['char'],
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          _selectedAscii!['name'].split(' ')[0],
                          style: const TextStyle(fontSize: 24, color: Colors.blue),
                        ),
                ),
                
                // 字符信息
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('十进制', '${_selectedAscii!['decimal']}'),
                        _buildInfoRow('十六进制', '0x${_selectedAscii!['hex']}'),
                        _buildInfoRow('二进制', _selectedAscii!['binary']),
                        _buildInfoRow('名称', _selectedAscii!['name']),
                      ],
                    ),
                  ),
                ),
                
                // 复制按钮
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCopyButton('十进制', '${_selectedAscii!['decimal']}'),
                    _buildCopyButton('十六进制', '0x${_selectedAscii!['hex']}'),
                    _buildCopyButton('字符', _selectedAscii!['char']),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 构建复制按钮
  Widget _buildCopyButton(String label, String value) {
    return ElevatedButton(
      onPressed: () => _copyToClipboard(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: const Size(60, 28),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}