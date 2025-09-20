import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../components/base_tool_page.dart';
import '../../utils/file_transfer_service.dart';
import '../../models/file_transfer_device.dart';
import 'received_files_page.dart';


class FileTransferPage extends StatefulWidget {
  const FileTransferPage({super.key});

  @override
  State<FileTransferPage> createState() => _FileTransferPageState();
}

class _FileTransferPageState extends State<FileTransferPage>
    with TickerProviderStateMixin {
  final FileTransferService _fileTransferService = FileTransferService();
  late AnimationController _scanAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isScanning = false;
  bool _isReceiveMode = false;
  String? _serverUrl;
  final List<FileTransferDevice> _discoveredDevices = [];
  String _deviceName = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDeviceName();
    _fileTransferService.onDeviceDiscovered = _onDeviceDiscovered;
  }

  void _initAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimationController.repeat(reverse: true);
  }

  void _loadDeviceName() async {
    final name = await _fileTransferService.getDeviceName();
    setState(() {
      _deviceName = name;
    });
  }

  void _onDeviceDiscovered(FileTransferDevice device) {
    setState(() {
      _discoveredDevices.removeWhere((d) => d.id == device.id);
      _discoveredDevices.add(device);
    });
  }

  void _startScanning() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _discoveredDevices.clear();
    });
    
    _scanAnimationController.repeat();
    HapticFeedback.lightImpact();
    
    try {
      // 自动启动接收服务器，优化发送文件流程
      if (_isReceiveMode) {
        await _fileTransferService.autoStartServerIfNeeded();
      }
      await _fileTransferService.startDiscovery();
    } catch (e) {
      _showError('启动设备发现失败: $e');
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _scanAnimationController.stop();
    _fileTransferService.stopDiscovery();
  }

  void _startReceiveMode() async {
    try {
      final url = await _fileTransferService.startServer();
      setState(() {
        _isReceiveMode = true;
        _serverUrl = url;
      });
      HapticFeedback.mediumImpact();
      
      // 启动扫描以发现其他设备
      if (!_isScanning) {
        _startScanning();
      }
    } catch (e) {
      _showError('启动接收模式失败: $e');
    }
  }

  void _stopReceiveMode() {
    _fileTransferService.stopServer();
    setState(() {
      _isReceiveMode = false;
      _serverUrl = null;
    });
  }

  void _connectToDevice(FileTransferDevice device) async {
    HapticFeedback.lightImpact();
    
    // 自动启动接收服务器以优化发送流程
    try {
      await _fileTransferService.autoStartServerIfNeeded();
    } catch (e) {
      debugPrint('自动启动服务器失败: $e');
    }
    
    // 直接导航到文件发送页面，不需要连接设备
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _FileSendPage(
            device: device,
            fileTransferService: _fileTransferService,
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5), // 显示更长时间
        ),
      );
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _pulseAnimationController.dispose();
    _fileTransferService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '文件快传',
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReceivedFilesPage(),
              ),
            );
          },
          icon: const Icon(Icons.folder_open, color: Colors.black),
          tooltip: '接收文件',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDeviceInfoCard(),
              const SizedBox(height: 20),
              _buildUsageGuide(),
              const SizedBox(height: 20),
              _buildModeButtons(),
              const SizedBox(height: 30),
              if (_isReceiveMode) ...[
                _buildReceiveModeCard(),
                const SizedBox(height: 20),
              ],
              if (!_isReceiveMode) ...[
                _buildScanSection(),
                const SizedBox(height: 20),
                if (_discoveredDevices.isNotEmpty)
                  _buildDeviceList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.devices,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前设备',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _deviceName.isEmpty ? '加载中...' : _deviceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建使用说明指引
  Widget _buildUsageGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.black),
              SizedBox(width: 8),
              Text(
                '使用说明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 发送文件：选择目标设备直接发送文件，接收方会自动启动接收服务\n'
            '• 接收文件：启动接收模式后，其他设备可通过浏览器或APP发送文件\n'
            '• 设备发现：自动扫描附近可连接的设备\n'
            '• 文件管理：点击右上角文件夹图标查看和管理已接收的文件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showDetailedGuide,
            child: const Text(
              '查看详情使用说明 →',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示详细使用说明
  void _showDetailedGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许弹窗高度超过默认值
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet( // 使用DraggableScrollableSheet
          expand: false,
          initialChildSize: 0.6, // 初始高度为屏幕的60%
          minChildSize: 0.3, // 最小高度为屏幕的30%
          maxChildSize: 0.9, // 最大高度为屏幕的90%
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '详细使用说明',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController, // 使用传入的scrollController
                      children: [
                        _buildGuideSection(
                          icon: Icons.upload_file,
                          title: '发送文件',
                          content: 
                            '1. 确保发送方和接收方设备连接同一WiFi网络\n'
                            '2. 在发送方设备上选择"发送文件"模式\n'
                            '3. 点击扫描按钮，自动搜索附近可接收文件的设备\n'
                            '4. 选择目标设备，选择要发送的文件\n'
                            '5. 发送方会自动通知接收方启动接收服务，文件将自动传输',
                        ),
                        const SizedBox(height: 15),
                        _buildGuideSection(
                          icon: Icons.download,
                          title: '接收文件',
                          content: 
                            '1. 在接收方设备上选择"接收文件"模式\n'
                            '2. 系统自动启动接收服务，显示Web地址\n'
                            '3. 其他设备可通过APP或浏览器访问该地址发送文件\n'
                            '4. 发送的文件会自动保存并在"接收文件"页面中显示\n'
                            '5. 也可直接通过APP扫描发现设备进行文件传输',
                        ),
                        const SizedBox(height: 15),
                        _buildGuideSection(
                          icon: Icons.folder_open,
                          title: '文件管理',
                          content: 
                            '1. 点击右上角文件夹图标进入接收文件页面\n'
                            '2. 可按文件类型筛选查看文件\n'
                            '3. 支持预览图片、视频、音频等文件\n'
                            '4. 可分享、删除或生成压缩包导出文件',
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('知道了'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 构建指南部分
  Widget _buildGuideSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            icon: Icons.upload_file,
            label: '发送文件',
            isActive: !_isReceiveMode,
            onTap: () {
              if (_isReceiveMode) {
                _stopReceiveMode();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModeButton(
            icon: Icons.download,
            label: '接收文件',
            isActive: _isReceiveMode,
            onTap: () {
              if (_isReceiveMode) {
                _stopReceiveMode();
              } else {
                _startReceiveMode();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiveModeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '接收模式已启动',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '其他设备可以通过以下地址发送文件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          if (_serverUrl != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _serverUrl!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _serverUrl!));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('地址已复制到剪贴板'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 20, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showQrCodePopup(),
            icon: const Icon(Icons.qr_code, color: Colors.white),
            label: const Text('显示二维码'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // 显示二维码弹窗
  void _showQrCodePopup() {
    if (_serverUrl == null) return;
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                '扫描二维码发送文件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _serverUrl!, 
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _serverUrl!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                '请使用其他设备扫描上方二维码进行文件传输',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('关闭'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanSection() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Center(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isScanning)
                      Transform.scale(
                        scale: 1.0 + (_scanAnimation.value * 0.5),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withOpacity(
                                1.0 - _scanAnimation.value,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    // 中心按钮
                    GestureDetector(
                      onTap: _isScanning ? _stopScanning : _startScanning,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isScanning ? Colors.red.shade700 : Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: (_isScanning ? Colors.red : Colors.black).withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isScanning ? Icons.stop : Icons.radar,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isScanning ? '正在扫描设备...' : '点击开始扫描',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '发现的设备 (${_discoveredDevices.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 限制设备列表的最大高度，防止溢出
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(), // 使用ClampingScrollPhysics而不是NeverScrollableScrollPhysics
            itemCount: _discoveredDevices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final device = _discoveredDevices[index];
              return _buildDeviceCard(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(FileTransferDevice device) {
    return GestureDetector(
      onTap: () => _connectToDevice(device),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDeviceIcon(device.type),
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.ip} • ${device.type}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
        return Icons.phone_android;
      case 'desktop':
        return Icons.computer;
      case 'laptop':
        return Icons.laptop;
      default:
        return Icons.device_unknown;
    }
  }
}

// 文件发送页面
class _FileSendPage extends StatefulWidget {
  final FileTransferDevice device;
  final FileTransferService fileTransferService;

  const _FileSendPage({
    required this.device,
    required this.fileTransferService,
  });

  @override
  State<_FileSendPage> createState() => _FileSendPageState();
}

class _FileSendPageState extends State<_FileSendPage> {
  bool _isTransferring = false;
  double _progress = 0.0;
  XFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发送到 ${widget.device.name}', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_android,
                    color: Colors.black,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.device.ip,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '端口: ${widget.device.port}',
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (!_isTransferring) ...[
              ElevatedButton.icon(
                onPressed: _selectFile,
                icon: const Icon(Icons.folder_open, color: Colors.white),
                label: const Text('选择文件'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 20),
                Text(
                  '已选择: ${_selectedFile!.name}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('发送文件'),
                ),
              ],
            ],
            if (_isTransferring) ...[
              const CircularProgressIndicator(color: Colors.black),
              const SizedBox(height: 20),
              Text(
                '正在发送... ${(_progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _progress, color: Colors.black, backgroundColor: Colors.grey.shade300),
            ],
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '提示：接收方设备会自动启动接收服务，无需手动操作',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFile() async {
    try {
      // 使用 file_selector 选择文件
      final file = await openFile();
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      _showError('选择文件失败: $e');
    }
  }

  void _sendFile() async {
    if (_selectedFile == null) return;
    
    setState(() {
      _isTransferring = true;
      _progress = 0.0;
    });
    
    try {
      // 实际的文件发送逻辑
      await widget.fileTransferService.sendFile(
        _selectedFile!, 
        widget.device,
        (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('文件发送成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = '发送失败: $e';
      // 提供更具体的错误提示
      if (e.toString().contains('Connection refused')) {
        errorMessage = '连接被拒绝：目标设备可能未准备好接收文件，请稍后重试';
      } else if (e.toString().contains('无法连接到目标设备')) {
        errorMessage = '无法连接到目标设备：请确保两台设备连接在同一WiFi网络中';
      } else if (e.toString().contains('网络连接错误')) {
        errorMessage = '网络连接错误：请检查WiFi连接状态';
      } else if (e.toString().contains('timed out') || e.toString().contains('Timeout')) {
        errorMessage = '连接超时：请确保目标设备在线且网络稳定';
      }
      
      _showError(errorMessage);
    } finally {
      setState(() {
        _isTransferring = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5), // 显示更长时间
        ),
      );
    }
  }
}