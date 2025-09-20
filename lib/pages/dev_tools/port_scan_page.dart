import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class PortScanPage extends StatefulWidget {
  const PortScanPage({super.key});

  @override
  State<PortScanPage> createState() => _PortScanPageState();
}

class _PortScanPageState extends State<PortScanPage> {
  // IP地址控制器
  final TextEditingController _ipController = TextEditingController(text: '127.0.0.1');
  
  // 端口范围控制器
  final TextEditingController _startPortController = TextEditingController(text: '1');
  final TextEditingController _endPortController = TextEditingController(text: '1024');
  
  // 扫描结果
  List<String> _scanResults = [];
  
  // 扫描状态
  bool _isScanning = false;
  int _totalPorts = 0;
  int _scannedPorts = 0;
  String _currentStatus = '';
  
  // 扫描控制器（用于取消扫描）
  late StreamController<int> _scanController;
  late StreamSubscription<int> _scanSubscription;
  
  @override
  void initState() {
    super.initState();
    _scanController = StreamController<int>();
    _scanSubscription = _scanController.stream.listen((_) {});
  }

  // 开始扫描端口
  void _startScan() async {
    if (_isScanning) return;
    
    setState(() {
      _scanResults.clear();
      _isScanning = true;
      _scannedPorts = 0;
      _currentStatus = '准备扫描...';
    });
    
    try {
      String ip = _ipController.text.trim();
      int startPort = int.parse(_startPortController.text.trim());
      int endPort = int.parse(_endPortController.text.trim());
      
      // 验证输入范围
      if (startPort < 1 || startPort > 65535 || endPort < 1 || endPort > 65535 || startPort > endPort) {
        _showError('请输入有效的端口范围（1-65535）');
        setState(() {
          _isScanning = false;
        });
        return;
      }
      
      _totalPorts = endPort - startPort + 1;
      
      // 创建新的流控制器和订阅
      _scanController.close();
      _scanSubscription.cancel();
      _scanController = StreamController<int>();
      _scanSubscription = _scanController.stream.listen((port) {
        if (mounted) {
          setState(() {
            _scannedPorts = port - startPort + 1;
          });
        }
      });
      
      // 扫描端口
      await _scanPorts(ip, startPort, endPort);
      
    } catch (e) {
      _showError('扫描出错: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _currentStatus = _scanResults.isEmpty ? '未发现开放端口' : '扫描完成';
        });
      }
    }
  }
  
  // 扫描端口的实现
  Future<void> _scanPorts(String ip, int startPort, int endPort) async {
    // 存储扫描结果
    List<String> tempResults = [];
    
    // 并发扫描的端口数
    int concurrency = 50;
    // 延迟时间（毫秒）
    int timeout = 500;
    
    // 创建端口列表
    List<int> ports = List.generate(endPort - startPort + 1, (i) => startPort + i);
    
    // 分批扫描
    for (int i = 0; i < ports.length; i += concurrency) {
      if (!_isScanning) break;
      
      List<int> batch = ports.sublist(i, i + concurrency > ports.length ? ports.length : i + concurrency);
      List<Future<void>> futures = batch.map((port) async {
        if (!_isScanning) return;
        
        try {
          // 更新当前扫描状态
          if (mounted) {
            setState(() {
              _currentStatus = '正在扫描端口 $port...';
            });
          }
          
          // 尝试连接端口
          Socket socket = await Socket.connect(ip, port, timeout: Duration(milliseconds: timeout));
          socket.close();
          
          // 端口开放
          String result = '端口 $port: 开放';
          tempResults.add(result);
          
          if (mounted) {
            setState(() {
              _scanResults.add(result);
            });
          }
          
        } catch (_) {
          // 端口关闭或连接超时
        } finally {
          // 通知扫描进度
          _scanController.add(port);
        }
      }).toList();
      
      // 等待当前批次扫描完成
      await Future.wait(futures);
    }
    
    // 按端口号排序结果
    tempResults.sort((a, b) {
      int portA = int.parse(a.split(':')[0].split(' ')[1]);
      int portB = int.parse(b.split(':')[0].split(' ')[1]);
      return portA.compareTo(portB);
    });
    
    // 更新排序后的结果
    if (mounted && _isScanning) {
      setState(() {
        _scanResults = tempResults;
      });
    }
  }
  
  // 停止扫描
  void _stopScan() {
    setState(() {
      _isScanning = false;
      _currentStatus = '扫描已停止';
    });
  }
  
  // 清空结果
  void _clearResults() {
    setState(() {
      _scanResults.clear();
      _currentStatus = '';
    });
  }
  
  // 复制结果到剪贴板
  void _copyResults() {
    if (_scanResults.isEmpty) return;
    
    String text = _scanResults.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫描结果已复制到剪贴板')),
    );
  }
  
  // 显示错误信息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '端口扫描',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 参数设置卡片
            ToolCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('扫描参数:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    // IP地址输入
                    TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: '目标IP地址',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // 端口范围输入
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startPortController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '起始端口',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('到', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endPortController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '结束端口',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _clearResults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('清空结果'),
                        ),
                        ElevatedButton(
                          onPressed: _isScanning ? _stopScan : _startScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isScanning ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_isScanning ? '停止扫描' : '开始扫描'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 扫描状态卡片
            ToolCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('扫描状态:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    
                    // 进度条
                    if (_totalPorts > 0) 
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _isScanning && _totalPorts > 0 ? _scannedPorts / _totalPorts : 0,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text('已扫描: $_scannedPorts / $_totalPorts 端口'),
                        ],
                      ),
                    
                    // 当前状态
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _currentStatus,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 扫描结果卡片
            ToolCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('扫描结果:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (_scanResults.isNotEmpty) 
                          ElevatedButton(
                            onPressed: _copyResults,
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
                                Text('复制结果'),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 结果显示区域
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _scanResults.isEmpty ? 
                        Center(child: Text(_isScanning ? '正在扫描...' : '暂无结果')) :
                        ListView.builder(
                          itemCount: _scanResults.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(_scanResults[index], style: const TextStyle(fontFamily: 'Courier')),
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
                    Text('1. 输入目标IP地址（默认为本地主机127.0.0.1）'),
                    Text('2. 设置要扫描的端口范围（1-65535）'),
                    Text('3. 点击"开始扫描"按钮开始扫描端口'),
                    Text('4. 扫描过程中可以点击"停止扫描"中止扫描'),
                    Text('5. 扫描完成后，可以查看开放的端口并复制结果'),
                    Text('6. 注意：扫描大量端口可能需要较长时间'),
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
  
  @override
  void dispose() {
    _scanController.close();
    _scanSubscription.cancel();
    _ipController.dispose();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }
}