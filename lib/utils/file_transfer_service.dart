import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_selector/file_selector.dart'; // 添加file_selector导入
import 'package:path_provider/path_provider.dart';
import '../models/file_transfer_device.dart';
import '../models/received_file.dart';
import '../utils/received_file_manager.dart';
import '../utils/network_utils.dart'; // 添加网络工具类
import 'package:flutter/services.dart' show rootBundle;

class FileTransferService {
  static const int _discoveryPort = 8888;
  static const int _transferPort = 8889;
  static const String _broadcastMessage = 'FILE_TRANSFER_DISCOVERY';
  static const String _responseMessage = 'FILE_TRANSFER_RESPONSE';
  
  dynamic _discoverySocket; // 使用dynamic类型以兼容不同平台
  dynamic _transferServer; // 使用dynamic类型以兼容不同平台
  Timer? _discoveryTimer;
  Timer? _deviceCleanupTimer;
  
  // 发现的设备列表
  final Map<String, FileTransferDevice> _discoveredDevices = {};
  
  // 回调函数
  Function(FileTransferDevice)? onDeviceDiscovered;
  Function(FileTransferDevice)? onDeviceRemoved;
  
  String? _deviceName;
  String? _deviceId;
  String? _deviceType;

  FileTransferService() {
    _initializeDeviceInfo();
    _startDeviceCleanup();
  }

  // 清理过期设备
  void _startDeviceCleanup() {
    _deviceCleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      final expiredDevices = <String>[];
      
      _discoveredDevices.forEach((id, device) {
        if (now.difference(device.lastSeen).inSeconds > 60) {
          expiredDevices.add(id);
        }
      });
      
      for (final id in expiredDevices) {
        final device = _discoveredDevices.remove(id);
        if (device != null) {
          onDeviceRemoved?.call(device);
          debugPrint('设备离线: ${device.name}');
        }
      }
    });
  }

  Future<void> _initializeDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;
        _deviceId = androidInfo.id;
        _deviceType = 'mobile';
      } else if (!kIsWeb && Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.name;
        _deviceId = iosInfo.identifierForVendor ?? '';
        _deviceType = 'mobile';
      } else if (!kIsWeb && Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        _deviceName = windowsInfo.computerName;
        _deviceId = windowsInfo.deviceId;
        _deviceType = 'desktop';
      } else if (!kIsWeb && Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        _deviceName = macInfo.computerName;
        _deviceId = macInfo.systemGUID ?? '';
        _deviceType = 'desktop';
      } else if (!kIsWeb && Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        _deviceName = linuxInfo.name;
        _deviceId = linuxInfo.machineId ?? '';
        _deviceType = 'desktop';
      } else if (!kIsWeb && Platform.operatingSystem == 'ohos') {
        // 鸿蒙平台设备信息获取
        try {
          // 尝试获取鸿蒙设备信息
          final ohosInfo = await deviceInfo.deviceInfo;
          _deviceName = ohosInfo.data['productModel'] ?? ohosInfo.data['displayVersion'] ?? '鸿蒙设备';
          _deviceId = ohosInfo.data['UDID'] ?? ohosInfo.data['udid'] ?? _generateRandomId();
          _deviceType = 'mobile'; // 鸿蒙设备统一标记为mobile类型，便于与其他移动设备兼容
          debugPrint('鸿蒙设备信息: name=$_deviceName, id=$_deviceId, type=$_deviceType');
        } catch (e) {
          debugPrint('获取鸿蒙设备信息失败: $e');
          // 如果无法获取鸿蒙设备信息，使用默认值
          _deviceName = '鸿蒙设备';
          _deviceId = _generateRandomId();
          _deviceType = 'mobile';
        }
      } else {
        _deviceName = kIsWeb ? 'Web Browser' : 'Unknown Device';
        _deviceId = _generateRandomId();
        _deviceType = kIsWeb ? 'web' : 'unknown';
      }
    } catch (e) {
      _deviceName = kIsWeb ? 'Web Browser' : 'Unknown Device';
      _deviceId = _generateRandomId();
      _deviceType = kIsWeb ? 'web' : 'unknown';
    }
  }

  String _generateRandomId() {
    final random = Random();
    return List.generate(16, (index) => random.nextInt(16).toRadixString(16)).join();
  }

  Future<String> getDeviceName() async {
    if (_deviceName == null) {
      await _initializeDeviceInfo();
    }
    return _deviceName ?? 'Unknown Device';
  }

  // 获取本机IP地址
  Future<String> _getLocalIpAddress() async {
    // Web平台不支持网络接口，返回localhost
    if (kIsWeb) return '127.0.0.1';
    
    // 使用网络工具类获取IP地址
    return await NetworkUtils.getLocalIpAddress();
  }

  // 缓存本机IP地址
  String? _cachedLocalIpAddress;
  DateTime? _lastIpFetchTime;

  // 获取本机IP地址并缓存
  Future<String> _getCachedLocalIpAddress() async {
    // 如果缓存的IP地址在10秒内，则直接返回
    if (_cachedLocalIpAddress != null && 
        _lastIpFetchTime != null && 
        DateTime.now().difference(_lastIpFetchTime!).inSeconds < 10) {
      return _cachedLocalIpAddress!;
    }
    
    // 获取实际的IP地址并缓存
    _cachedLocalIpAddress = await _getLocalIpAddress();
    _lastIpFetchTime = DateTime.now();
    return _cachedLocalIpAddress!;
  }

  // 开始设备发现
  Future<void> startDiscovery() async {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb) {
      debugPrint('Web平台不支持设备发现功能');
      return;
    }
    
    debugPrint('开始设备发现');
    await stopDiscovery();
    
    try {
      // 创建UDP Socket用于广播
      _discoverySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _discoverySocket!.broadcastEnabled = true;
      debugPrint('创建UDP Socket成功，本地端口: ${_discoverySocket!.port}');
      
      // 监听响应
      _discoverySocket!.listen(_handleDiscoveryResponse);
      debugPrint('开始监听发现响应');
      
      // 定期发送广播
      _discoveryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        debugPrint('定时发送发现广播');
        _sendDiscoveryBroadcast();
      });
      
      // 立即发送一次广播
      debugPrint('立即发送发现广播');
      _sendDiscoveryBroadcast();
      
      // 同时启动响应服务
      debugPrint('启动发现响应服务');
      await _startDiscoveryResponse();
      
    } catch (e) {
      debugPrint('启动设备发现失败: $e');
      throw Exception('启动设备发现失败: $e');
    }
  }

  // 发送发现广播
  void _sendDiscoveryBroadcast() {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb || _discoverySocket == null) return;
    
    try {
      // 获取本机IP地址
      _getCachedLocalIpAddress().then((localIp) {
        debugPrint('获取本机IP地址用于广播: $localIp');
        final deviceInfo = {
          'id': _deviceId,
          'name': _deviceName,
          'type': _deviceType,
          'port': _transferPort,
          'ip': localIp, // 添加IP地址信息
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        final message = '$_broadcastMessage:${jsonEncode(deviceInfo)}';
        final data = utf8.encode(message);
        
        debugPrint('发送发现广播: $message');
        debugPrint('本机IP: $localIp, 传输端口: $_transferPort');
        
        // 发送广播到标准广播地址
        if (Platform.isIOS) {
          _discoverySocket.send(data, InternetAddress("${localIp.split('.')[0]}.${localIp.split('.')[1]}.${localIp.split('.')[2]}.255"), _discoveryPort);
        } else {
          _discoverySocket.send(data, InternetAddress('255.255.255.255'), _discoveryPort);
        }
        
        // 同时发送到本地地址，确保本地网络设备能收到
        _discoverySocket.send(data, InternetAddress('127.0.0.1'), _discoveryPort);
        
        // 发送到更多可能的广播地址
        _getNetworkBroadcastAddresses().then((broadcastAddresses) {
          debugPrint('获取到 ${broadcastAddresses.length} 个广播地址');
          for (final address in broadcastAddresses) {
            debugPrint('发送广播到地址: ${address.address}:$_discoveryPort');
            _discoverySocket.send(data, address, _discoveryPort);
          }
        });
      });
    } catch (e) {
      debugPrint('发送广播失败: $e');
    }
  }

  // 获取网络广播地址
  Future<List<InternetAddress>> _getNetworkBroadcastAddresses() async {
    // Web平台不支持网络接口，直接返回空列表
    if (kIsWeb) return [];
    
    final broadcastAddresses = <InternetAddress>[];
    
    try {
      final networkInterfaces = await NetworkInterface.list();
      debugPrint('获取到 ${networkInterfaces.length} 个网络接口');
      for (final interface in networkInterfaces) {
        debugPrint('处理接口: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('  地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // 计算广播地址
            final ip = addr.address.split('.');
            if (ip.length == 4) {
              final broadcastIp = '${ip[0]}.${ip[1]}.${ip[2]}.255';
              broadcastAddresses.add(InternetAddress(broadcastIp));
              debugPrint('  添加广播地址: $broadcastIp');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('获取网络接口失败: $e');
    }
    
    debugPrint('总共获取到 ${broadcastAddresses.length} 个广播地址');
    return broadcastAddresses;
  }

  // 启动发现响应服务
  Future<void> _startDiscoveryResponse() async {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb) return;
    
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort);
      debugPrint('启动发现响应服务，监听端口: $_discoveryPort');
      
      socket.listen((event) {
        debugPrint('发现响应服务收到事件: $event');
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            debugPrint('收到发现请求来自: ${datagram.address.address}:${datagram.port}');
            _handleDiscoveryRequest(datagram, socket);
          } else {
            debugPrint('未收到有效的数据包');
          }
        } else {
          debugPrint('收到非读取事件: $event');
        }
      });
    } catch (e) {
      debugPrint('启动发现响应服务失败: $e');
    }
  }

  // 处理发现请求
  void _handleDiscoveryRequest(dynamic datagram, dynamic socket) {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb) return;
    
    try {
      final message = utf8.decode(datagram.data);
      debugPrint('收到发现请求数据: $message');
      
      if (message.startsWith(_broadcastMessage)) {
        debugPrint('处理发现广播请求来自: ${datagram.address.address}:${datagram.port}');
        // 这是一个发现请求，发送响应
        // 获取本机IP地址
        _getCachedLocalIpAddress().then((localIp) {
          debugPrint('获取本机IP地址: $localIp');
          final deviceInfo = {
            'id': _deviceId,
            'name': _deviceName,
            'type': _deviceType,
            'port': _transferPort, // 确保使用正确的端口号
            'ip': localIp, // 添加IP地址信息
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          
          final response = '$_responseMessage:${jsonEncode(deviceInfo)}';
          final responseData = utf8.encode(response);
          
          debugPrint('准备发送响应: $response');
          debugPrint('准备发送响应到: ${datagram.address.address}:${datagram.port}');
          // 确保响应发送到正确的地址和端口
          socket.send(responseData, datagram.address, datagram.port);
          debugPrint('发送发现响应到: ${datagram.address.address}:${datagram.port}, 本机IP: $localIp, 端口: $_transferPort');
        });
      } else {
        debugPrint('不是发现广播请求');
      }
    } catch (e) {
      debugPrint('处理发现请求失败: $e');
    }
  }

  // 处理发现响应
  void _handleDiscoveryResponse(dynamic event) {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb || event != RawSocketEvent.read || _discoverySocket == null) return;
    
    try {
      final datagram = _discoverySocket!.receive();
      if (datagram == null) return;
      
      final message = utf8.decode(datagram.data);
      debugPrint('收到发现响应数据: $message');
      
      if (message.startsWith(_broadcastMessage) || message.startsWith(_responseMessage)) {
        debugPrint('处理发现响应来自: ${datagram.address.address}:${datagram.port}');
        final parts = message.split(':');
        if (parts.length >= 2) {
          final deviceData = jsonDecode(parts.sublist(1).join(':'));
          debugPrint('解析设备数据: $deviceData');
          
          // 不添加自己的设备
          if (deviceData['id'] == _deviceId) {
            debugPrint('收到自己的设备信息，忽略');
            return;
          }
          
          // 使用设备信息中的IP地址，如果没有则使用数据包来源IP
          String deviceIp = deviceData['ip'] as String? ?? datagram.address.address;
          debugPrint('设备IP地址: $deviceIp (来自设备信息: ${deviceData['ip']}, 数据包来源: ${datagram.address.address})');
          
          // 验证IP地址是否有效，如果无效则使用数据包来源IP
          if (!NetworkUtils.isValidIpAddress(deviceIp)) {
            deviceIp = datagram.address.address;
            debugPrint('设备IP地址无效，使用数据包来源IP: $deviceIp');
          }
          
          // 获取端口号，确保使用正确的端口
          int devicePort = deviceData['port'] as int? ?? _transferPort;
          // 验证端口号是否有效
          if (devicePort <= 0 || devicePort > 65535) {
            devicePort = _transferPort;
            debugPrint('设备端口无效，使用默认端口: $devicePort');
          }
          
          // 强制使用我们期望的端口，忽略设备报告的端口
          // 这是为了解决设备报告错误端口的问题
          if (devicePort != _transferPort) {
            debugPrint('警告: 设备报告端口 $devicePort 与期望端口 $_transferPort 不匹配，强制使用期望端口');
            devicePort = _transferPort;
          }
          
          final device = FileTransferDevice(
            id: deviceData['id'],
            name: deviceData['name'],
            ip: deviceIp,
            port: devicePort, // 使用验证后的端口号
            type: deviceData['type'],
            lastSeen: DateTime.now(),
          );
          
          final existingDevice = _discoveredDevices[device.id];
          if (existingDevice == null) {
            _discoveredDevices[device.id] = device;
            onDeviceDiscovered?.call(device);
            debugPrint('发现新设备: ${device.name} (${device.ip}:${device.port})');
          } else {
            // 更新最后见到时间
            _discoveredDevices[device.id] = FileTransferDevice(
              id: device.id,
              name: device.name,
              ip: device.ip,
              port: device.port,
              type: device.type,
              lastSeen: DateTime.now(),
            );
            debugPrint('更新设备信息: ${device.name} (${device.ip}:${device.port})');
          }
        }
      } else {
        debugPrint('不是发现响应消息');
      }
    } catch (e) {
      debugPrint('处理发现响应失败: $e');
    }
  }

  // 停止设备发现
  Future<void> stopDiscovery() async {
    // Web平台不支持UDP Socket，直接返回
    if (kIsWeb) return;
    
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    
    _discoverySocket?.close();
    _discoverySocket = null;
    
    _discoveredDevices.clear();
  }

  // 启动文件传输服务器
  Future<String> startServer() async {
    // Web平台不支持HttpServer，直接抛出异常
    if (kIsWeb) {
      throw Exception('Web平台不支持文件传输服务器功能');
    }
    
    await stopServer();
    
    // 初始化接收文件管理器
    await ReceivedFileManager.instance.initialize();
    
    try {
      // 明确绑定到指定端口，如果端口被占用则抛出异常
      _transferServer = await HttpServer.bind(InternetAddress.anyIPv4, _transferPort);
      debugPrint('文件传输服务器绑定到端口: $_transferPort');
      
      // 打印服务器绑定的地址信息
      debugPrint('服务器监听地址: ${_transferServer!.address.address}:${_transferServer!.port}');
      
      _transferServer!.listen((request) async {
        debugPrint('收到请求: ${request.method} ${request.uri.path} 来自 ${request.connectionInfo?.remoteAddress.address}:${request.connectionInfo?.remotePort}');
        await _handleFileTransferRequest(request);
      });
      
      // 获取本机IP地址
      final ip = await _getLocalIpAddress();
      final url = 'http://$ip:$_transferPort';
      
      debugPrint('文件传输服务器启动成功: $url');
      return url;
      
    } catch (e) {
      debugPrint('启动文件传输服务器失败: $e');
      throw Exception('启动文件传输服务器失败: $e');
    }
  }

  // 自动启动服务器（用于优化发送文件流程）
  Future<void> autoStartServerIfNeeded() async {
    try {
      // 如果服务器未启动，则自动启动
      if (_transferServer == null) {
        await startServer();
        debugPrint('自动启动文件传输服务器');
      }
    } catch (e) {
      debugPrint('自动启动文件传输服务器失败: $e');
    }
  }

  // 处理文件传输请求
  Future<void> _handleFileTransferRequest(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      if (request.method == 'POST' && request.uri.path == '/upload') {
        await _handleFileUpload(request);
      } else if (request.method == 'GET' && request.uri.path == '/') {
        await _handleWebInterface(request);
      } else if (request.method == 'GET' && request.uri.path == '/files') {
        await _handleFileList(request);
      } else if (request.method == 'GET' && request.uri.path.startsWith('/download/')) {
        await _handleFileDownload(request);
      } else if (request.method == 'POST' && request.uri.path == '/send') {
        await _handleSendToClient(request);
      } else if (request.method == 'POST' && request.uri.path == '/start-server') {
        await _handleStartServerRequest(request);
      } else {
        request.response
          ..statusCode = 404
          ..write('Not Found')
          ..close();
      }
    } catch (e) {
      debugPrint('处理文件传输请求失败: $e');
      request.response
        ..statusCode = 500
        ..write('Internal Server Error')
        ..close();
    }
  }

  // 处理文件上传
  Future<void> _handleFileUpload(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      debugPrint('开始处理文件上传请求');
      final contentType = request.headers.contentType;
      debugPrint('Content-Type: $contentType');
      
      if (contentType == null || !contentType.mimeType.startsWith('multipart/')) {
        debugPrint('无效的Content-Type: $contentType');
        request.response
          ..statusCode = 400
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'success': false, 'message': 'Expected multipart/form-data'}))
          ..close();
        return;
      }

      final boundary = contentType.parameters['boundary'];
      if (boundary == null) {
        debugPrint('未找到boundary参数');
        request.response
          ..statusCode = 400
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'success': false, 'message': 'No boundary specified'}))
          ..close();
        return;
      }

      debugPrint('Boundary: $boundary');
      
      // 获取下载目录
      final downloadDir = await _getDownloadDirectory();
      debugPrint('下载目录: ${downloadDir.path}');
      
      // 读取所有请求数据
      final List<int> bytes = [];
      await for (final data in request) {
        bytes.addAll(data);
      }
      
      debugPrint('接收到数据大小: ${bytes.length} 字节');

      // 解析multipart数据
      await _parseMultipartData(bytes, boundary, downloadDir, request);

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': true, 'message': '文件上传成功'}))
        ..close();
        
      debugPrint('文件上传处理完成');
    } catch (e) {
      debugPrint('处理文件上传失败: $e');
      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': false, 'message': '上传失败: $e'}))
        ..close();
    }
  }

  // 解析multipart数据
  Future<void> _parseMultipartData(List<int> bytes, String boundary, Directory downloadDir, HttpRequest request) async {
    final boundaryBytes = utf8.encode('--$boundary');
    final endBoundaryBytes = utf8.encode('--$boundary--');
    
    int start = 0;
    while (start < bytes.length) {
      // 查找下一个boundary
      int boundaryIndex = _findBytes(bytes, boundaryBytes, start);
      if (boundaryIndex == -1) break;
      
      start = boundaryIndex + boundaryBytes.length;
      
      // 跳过CRLF
      if (start + 1 < bytes.length && bytes[start] == 13 && bytes[start + 1] == 10) {
        start += 2;
      }
      
      // 查找下一个boundary的开始
      int nextBoundaryIndex = _findBytes(bytes, boundaryBytes, start);
      if (nextBoundaryIndex == -1) {
        // 查找结束boundary
        nextBoundaryIndex = _findBytes(bytes, endBoundaryBytes, start);
        if (nextBoundaryIndex == -1) break;
      }
      
      // 提取这个part的数据
      final partBytes = bytes.sublist(start, nextBoundaryIndex);
      await _processPart(partBytes, downloadDir, request);
      
      start = nextBoundaryIndex;
    }
  }
  
  // 在字节数组中查找子序列
  int _findBytes(List<int> haystack, List<int> needle, int startIndex) {
    for (int i = startIndex; i <= haystack.length - needle.length; i++) {
      bool found = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }
  
  // 处理单个part
  Future<void> _processPart(List<int> partBytes, Directory downloadDir, HttpRequest request) async {
    // 查找头部和主体的分界（空行）
    const separatorBytes = [13, 10, 13, 10]; // \r\n\r\n

    int separatorIndex = _findBytes(partBytes, separatorBytes, 0);
    if (separatorIndex == -1) return;
    
    final headerBytes = partBytes.sublist(0, separatorIndex);
    final bodyBytes = partBytes.sublist(separatorIndex + 4);
    
    // 解析头部
    final headerString = utf8.decode(headerBytes);
    final lines = headerString.split('\r\n');
    
    String? filename;
    for (final line in lines) {
      if (line.toLowerCase().contains('content-disposition')) {
        final filenameMatch = RegExp(r'filename="([^"]*?)"').firstMatch(line);
        filename = filenameMatch?.group(1);
        break;
      }
    }
    
    if (filename != null && filename.isNotEmpty) {
      // 安全处理文件名
      filename = _sanitizeFilename(filename);
      
      final file = File('${downloadDir.path}/$filename');
      await file.writeAsBytes(bodyBytes);
      
      // 获取发送者信息
      final senderIp = request.connectionInfo?.remoteAddress.address ?? 'Unknown';
      final senderName = request.headers.value('X-Sender-Name') ?? 'Unknown Device';
      
      // 记录接收的文件
      final receivedFile = ReceivedFile(
        id: _generateRandomId(),
        name: filename,
        path: file.path,
        size: bodyBytes.length,
        receivedTime: DateTime.now(), // 使用当前时间而不是文件修改时间
        senderName: senderName,
        senderIp: senderIp,
        fileType: _getFileType(filename),
      );
      
      // 添加到接收文件管理器
      await ReceivedFileManager.instance.addReceivedFile(receivedFile);
      
      debugPrint('文件保存成功: ${file.path}, 大小: ${receivedFile.formattedSize}');
    }
  }
  
  // 清理文件名
  String _sanitizeFilename(String filename) {
    // 移除或替换不安全的字符
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll('..', '_')
        .trim();
  }

  // 获取下载目录
  Future<dynamic> _getDownloadDirectory() async {
    // Web平台不支持文件系统操作
    if (kIsWeb) {
      throw Exception('Web平台不支持文件系统操作');
    }
    
    Directory downloadDir;
    
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      downloadDir = Directory('${externalDir!.path}/Download/FileTransfer');
    } else if (Platform.isIOS) {
      final documentsDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${documentsDir.path}/FileTransfer');
    } else if (Platform.operatingSystem == 'ohos') {
      // 鸿蒙平台使用应用文档目录
      final documentsDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${documentsDir.path}/FileTransfer');
      debugPrint('鸿蒙平台下载目录: ${downloadDir.path}');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      downloadDir = Directory('${documentsDir.path}/FileTransfer');
    }
    
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
      debugPrint('创建下载目录: ${downloadDir.path}');
    }
    
    return downloadDir;
  }

  // 处理Web界面
  Future<void> _handleWebInterface(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      // 从文件加载HTML内容
      final htmlContent = await rootBundle.loadString('lib/assets/file_transfer_page.html');
      
      request.response
        ..headers.contentType = ContentType.html
        ..write(htmlContent)
        ..close();
    } catch (e) {
      debugPrint('加载HTML文件失败: $e');
      // 如果加载文件失败，使用默认的简单HTML
      const defaultHtml = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>文件快传</title>
</head>
<body>
    <h1>文件快传服务</h1>
    <p>服务正在运行中...</p>
</body>
</html>
      ''';
      
      request.response
        ..headers.contentType = ContentType.html
        ..write(defaultHtml)
        ..close();
    }
  }

  // 处理文件列表请求
  Future<void> _handleFileList(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      // 获取本地文件列表（可以发送给客户端的文件）
      final receivedFiles = ReceivedFileManager.instance.files;
      
      final fileList = receivedFiles.map((file) => {
        'id': file.id,
        'name': file.name,
        'size': file.size,
        'formattedSize': file.formattedSize,
        'type': file.fileType,
        'receivedTime': file.receivedTime.millisecondsSinceEpoch,
      }).toList();
      
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'files': fileList}))
        ..close();
    } catch (e) {
      debugPrint('获取文件列表失败: $e');
      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': '获取文件列表失败'}))
        ..close();
    }
  }
  
  // 处理文件下载请求
  Future<void> _handleFileDownload(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      final pathSegments = request.uri.pathSegments;
      if (pathSegments.length < 2) {
        request.response
          ..statusCode = 400
          ..write('Invalid file ID')
          ..close();
        return;
      }
      
      final fileId = pathSegments[1];
      final receivedFiles = ReceivedFileManager.instance.files;
      final targetFiles = receivedFiles.where((file) => file.id == fileId);
      final targetFile = targetFiles.isNotEmpty ? targetFiles.first : null;
      
      if (targetFile == null || !targetFile.exists) {
        request.response
          ..statusCode = 404
          ..write('File not found')
          ..close();
        return;
      }
      
      final file = File(targetFile.path);
      final fileBytes = await file.readAsBytes();
      
      // 设置响应头
      request.response.headers.set('Content-Type', 'application/octet-stream');
      request.response.headers.set('Content-Disposition', 'attachment; filename="${targetFile.name}"');
      request.response.headers.set('Content-Length', fileBytes.length.toString());
      
      request.response.add(fileBytes);
      await request.response.close();
      
      debugPrint('文件下载成功: ${targetFile.name}');
    } catch (e) {
      debugPrint('处理文件下载失败: $e');
      request.response
        ..statusCode = 500
        ..write('Download failed')
        ..close();
    }
  }
  
  // 处理发送文件到客户端请求
  Future<void> _handleSendToClient(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      // 读取请求参数
      final body = await utf8.decoder.bind(request).join();
      final data = jsonDecode(body);
      
      final fileId = data['fileId'] as String?;
      final clientIp = data['clientIp'] as String?;
      final clientPort = data['clientPort'] as int?;
      
      if (fileId == null || clientIp == null || clientPort == null) {
        request.response
          ..statusCode = 400
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': '参数不完整'}))
          ..close();
        return;
      }
      
      // 查找文件
      final receivedFiles = ReceivedFileManager.instance.files;
      final targetFiles = receivedFiles.where((file) => file.id == fileId);
      final targetFile = targetFiles.isNotEmpty ? targetFiles.first : null;
      
      if (targetFile == null || !targetFile.exists) {
        request.response
          ..statusCode = 404
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': '文件不存在'}))
          ..close();
        return;
      }
      
      // 发送文件到指定客户端
      await _sendFileToClient(targetFile, clientIp, clientPort);
      
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': true, 'message': '文件发送成功'}))
        ..close();
        
    } catch (e) {
      debugPrint('处理发送文件到客户端失败: $e');
      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': '发送文件失败: $e'}))
        ..close();
    }
  }
  
  // 发送文件到客户端
  Future<void> _sendFileToClient(ReceivedFile file, String clientIp, int clientPort) async {
    // Web平台不支持HttpClient，直接返回
    if (kIsWeb) return;
    
    try {
      final fileObj = File(file.path);
      if (!fileObj.existsSync()) {
        throw Exception('文件不存在: ${file.path}');
      }
      
      final client = HttpClient();
      // 设置超时时间
      client.connectionTimeout = const Duration(seconds: 10);
      client.idleTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse('http://$clientIp:$clientPort/upload');
      debugPrint('准备发送文件到: $uri');
      
      final request = await client.postUrl(uri);
      
      final boundary = 'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
      
      request.headers.set('content-type', 'multipart/form-data; boundary=$boundary');
      request.headers.set('X-Sender-Name', await getDeviceName());
      request.headers.set('Connection', 'close'); // 发送完毕后关闭连接

      // 构建 multipart 数据
      final header = '--$boundary\r\n'
          'Content-Disposition: form-data; name="file"; filename="${file.name}"\r\n'
          'Content-Type: application/octet-stream\r\n\r\n';
      
      final footer = '\r\n--$boundary--\r\n';
      
      final headerBytes = utf8.encode(header);
      final footerBytes = utf8.encode(footer);
      final fileBytes = await fileObj.readAsBytes();
      
      final totalBytes = headerBytes.length + fileBytes.length + footerBytes.length;
      request.headers.contentLength = totalBytes;
      
      debugPrint('发送文件大小: ${file.formattedSize}, 总大小: ${totalBytes}字节');

      // 发送数据
      request.add(headerBytes);
      request.add(fileBytes);
      request.add(footerBytes);
      
      final response = await request.close();
      
      // 读取响应内容
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint('客户端响应状态: ${response.statusCode}, 响应内容: $responseBody');
      
      if (response.statusCode == 200) {
        debugPrint('文件发送成功: ${file.name} -> $clientIp:$clientPort');
      } else {
        throw Exception('客户端返回错误: ${response.statusCode}, 响应: $responseBody');
      }
      
      client.close();
    } catch (e) {
      debugPrint('发送文件到客户端失败: $e');
      rethrow;
    }
  }

  // 停止文件传输服务器
  Future<void> stopServer() async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    await _transferServer?.close();
    _transferServer = null;
  }

  // 释放资源
  void dispose() {
    stopDiscovery();
    stopServer();
    _deviceCleanupTimer?.cancel();
    _deviceCleanupTimer = null;
  }

  // 获取文件类型
  String _getFileType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
      return 'document';
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) {
      return 'archive';
    } else {
      return 'other';
    }
  }

  // 发送文件到指定设备
  Future<void> sendFile(XFile file, FileTransferDevice device, Function(double) onProgress) async {
    // Web平台不支持HttpClient，直接返回
    if (kIsWeb) return;
    try {
      debugPrint('准备发送文件到设备: ${device.name} (${device.ip}:${device.port})');
      // 检查端口是否为期望的端口
      if (device.port != _transferPort) {
        debugPrint('警告: 目标设备端口 ${device.port} 与期望端口 $_transferPort 不匹配');
      }
      
      // 首先发送请求通知目标设备启动接收服务
      await _requestRemoteServerStart(device);
      
      final client = HttpClient();
      // 设置超时时间
      client.connectionTimeout = const Duration(seconds: 10);
      client.idleTimeout = const Duration(seconds: 10);
      
      final uri = Uri.parse('http://${device.ip}:${device.port}/upload');
      debugPrint('准备发送文件到: $uri');
      
      final request = await client.postUrl(uri);
      
      final boundary = 'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
      
      request.headers.set('content-type', 'multipart/form-data; boundary=$boundary');
      request.headers.set('X-Sender-Name', await getDeviceName());
      request.headers.set('Connection', 'close'); // 发送完毕后关闭连接

      // 构建 multipart 数据
      final header = '--$boundary\r\n'
          'Content-Disposition: form-data; name="file"; filename="${file.name}"\r\n'
          'Content-Type: application/octet-stream\rr\n';
      
      final footer = '\r\n--$boundary--\r\n';
      
      final headerBytes = utf8.encode(header);
      final footerBytes = utf8.encode(footer);
      
      // 读取文件内容
      final fileStream = file.openRead();
      final fileLength = await file.length();
      
      // 计算总大小
      final totalBytes = headerBytes.length + fileLength + footerBytes.length;
      request.headers.contentLength = totalBytes.toInt(); // 修复类型错误
      
      debugPrint('发送文件大小: ${fileLength}字节, 总大小: ${totalBytes}字节');

      // 发送数据
      request.add(headerBytes);
      
      // 发送文件内容并报告进度
      int bytesSent = headerBytes.length;
      await for (final data in fileStream) {
        request.add(data);
        bytesSent += data.length;
        final progress = bytesSent / totalBytes;
        onProgress(progress.clamp(0.0, 1.0));
      }
      
      request.add(footerBytes);
      
      debugPrint('文件数据发送完成，等待响应...');
      final response = await request.close();
      
      // 读取响应内容
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint('客户端响应状态: ${response.statusCode}, 响应内容: $responseBody');
      
      if (response.statusCode == 200) {
        debugPrint('文件发送成功: ${file.name} -> ${device.ip}:${device.port}');
      } else {
        throw Exception('文件发送失败，目标设备返回错误: ${response.statusCode} - $responseBody');
      }
      
      client.close();
    } on SocketException catch (e) {
      debugPrint('网络连接错误: $e');
      if (e.message.contains('Connection refused')) {
        throw Exception('连接被拒绝：目标设备可能未开启接收模式或不在同一网络中，请检查以下几点：\n1. 目标设备是否已开启接收模式\n2. 两台设备是否连接在同一WiFi网络\n3. 防火墙设置是否阻止了连接\n4. 目标设备是否正确监听端口 ${device.port}');
      } else {
        throw Exception('网络连接错误: $e');
      }
    } catch (e) {
      debugPrint('发送文件到设备失败: $e');
      rethrow;
    }
  }
  
  // 请求远程设备启动文件传输服务
  Future<void> _requestRemoteServerStart(FileTransferDevice device) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      client.idleTimeout = const Duration(seconds: 5);
      
      // 发送启动请求到远程设备的特定端点
      final uri = Uri.parse('http://${device.ip}:${device.port}/start-server');
      debugPrint('发送启动服务器请求到: $uri');
      
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('X-Device-Name', await getDeviceName());
      request.headers.set('X-Device-Id', _deviceId ?? '');
      
      // 发送请求体
      final requestBody = jsonEncode({
        'action': 'start_server',
        'requester': {
          'id': _deviceId,
          'name': await getDeviceName(),
          'type': _deviceType,
        }
      });
      
      request.write(requestBody);
      final response = await request.close();
      
      // 读取响应
      final responseBody = await response.transform(utf8.decoder).join();
      debugPrint('远程启动响应状态: ${response.statusCode}, 内容: $responseBody');
      
      if (response.statusCode == 200) {
        debugPrint('远程设备服务器启动请求成功');
      } else {
        debugPrint('远程设备服务器启动请求失败: ${response.statusCode}');
      }
      
      client.close();
    } catch (e) {
      debugPrint('请求远程设备启动服务器失败: $e');
      // 不抛出异常，因为即使请求失败，我们仍然尝试发送文件
    }
  }
  
  // 处理启动服务器请求
  Future<void> _handleStartServerRequest(dynamic request) async {
    // Web平台不支持HttpServer，直接返回
    if (kIsWeb) return;
    
    try {
      // 读取请求体
      final body = await utf8.decoder.bind(request).join();
      final data = jsonDecode(body);
      
      final action = data['action'] as String?;
      final requester = data['requester'] as Map<String, dynamic>?;
      
      debugPrint('收到启动服务器请求: action=$action, requester=$requester');
      
      // 如果是启动服务器请求，则确保服务器已启动
      if (action == 'start_server') {
        await autoStartServerIfNeeded();
        
        // 返回成功响应
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'success': true,
            'message': '服务器已启动',
            'serverUrl': 'http://${await _getLocalIpAddress()}:$_transferPort'
          }))
          ..close();
          
        debugPrint('响应启动服务器请求成功');
      } else {
        request.response
          ..statusCode = 400
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'success': false,
            'message': '无效的请求操作'
          }))
          ..close();
      }
    } catch (e) {
      debugPrint('处理启动服务器请求失败: $e');
      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'success': false,
          'message': '处理请求失败: $e'
        }))
        ..close();
    }
  }
}
