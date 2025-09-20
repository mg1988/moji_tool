import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../utils/file_transfer_service.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final FileTransferService _fileTransferService = FileTransferService();
  String _logText = '';
  
  void _addLog(String message) {
    setState(() {
      _logText = '[$currentTime] $message\n$_logText';
    });
  }
  
  String get currentTime {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '调试工具',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文件传输调试工具',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addLog('启动设备发现');
                    _fileTransferService.startDiscovery().then((_) {
                      _addLog('设备发现已启动');
                    }).catchError((e) {
                      _addLog('启动设备发现失败: $e');
                    });
                  },
                  child: const Text('启动发现'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addLog('停止设备发现');
                    _fileTransferService.stopDiscovery().then((_) {
                      _addLog('设备发现已停止');
                    }).catchError((e) {
                      _addLog('停止设备发现失败: $e');
                    });
                  },
                  child: const Text('停止发现'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addLog('启动接收服务');
                    _fileTransferService.startServer().then((url) {
                      _addLog('接收服务已启动: $url');
                    }).catchError((e) {
                      _addLog('启动接收服务失败: $e');
                    });
                  },
                  child: const Text('启动接收'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addLog('停止接收服务');
                    _fileTransferService.stopServer().then((_) {
                      _addLog('接收服务已停止');
                    }).catchError((e) {
                      _addLog('停止接收服务失败: $e');
                    });
                  },
                  child: const Text('停止接收'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logText,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}