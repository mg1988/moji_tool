import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static String? _cachedLocalIpAddress;
  static DateTime? _lastIpFetchTime;
  
  // 获取局域网IP地址
  static Future<String> getLocalIpAddress() async {
    debugPrint('开始获取本机IP地址');
    // 如果缓存的IP地址在30秒内，则直接返回
    if (_cachedLocalIpAddress != null && 
        _lastIpFetchTime != null && 
        DateTime.now().difference(_lastIpFetchTime!).inSeconds < 30) {
      debugPrint('使用缓存的IP地址: $_cachedLocalIpAddress');
      return _cachedLocalIpAddress!;
    }
    
    try {
      final interfaces = await NetworkInterface.list();
      debugPrint('获取到 ${interfaces.length} 个网络接口');
      
      // 打印所有网络接口信息用于调试
      for (final interface in interfaces) {
        debugPrint('接口名称: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('  地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
        }
      }
      
      // 根据不同平台选择合适的网络接口
      if (Platform.isIOS) {
        debugPrint('iOS平台IP地址获取');
        final ip = _getIOSLocalIpAddress(interfaces);
        if (ip != '127.0.0.1') {
          _cacheIpAddress(ip);
          debugPrint('iOS平台获取到IP地址: $ip');
          return ip;
        }
      } else if (Platform.operatingSystem == 'ohos') {
        debugPrint('鸿蒙平台IP地址获取');
        final ip = _getOhosLocalIpAddress(interfaces);
        if (ip != '127.0.0.1') {
          _cacheIpAddress(ip);
          debugPrint('鸿蒙平台获取到IP地址: $ip');
          return ip;
        }
      }
      
      debugPrint('通用IP地址获取');
      // 通用处理逻辑
      for (final interface in interfaces) {
        // 跳过虚拟接口和桥接接口
        if (_isVirtualInterface(interface.name)) {
          debugPrint('跳过虚拟接口: ${interface.name}');
          continue;
        }
        
        debugPrint('处理接口: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('  地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            _cacheIpAddress(addr.address);
            debugPrint('通用方式获取到IP地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('获取本机IP失败: $e');
    }
    
    // 如果所有方法都失败，返回127.0.0.1
    _cacheIpAddress('127.0.0.1');
    debugPrint('获取IP地址失败，返回默认值: 127.0.0.1');
    return '127.0.0.1';
  }
  
  // 缓存IP地址
  static void _cacheIpAddress(String ip) {
    _cachedLocalIpAddress = ip;
    _lastIpFetchTime = DateTime.now();
  }
  
  // iOS平台IP地址获取
  static String _getIOSLocalIpAddress(List<NetworkInterface> interfaces) {
    debugPrint('iOS平台网络接口信息:');
    
    // 对iOS设备，优先选择WiFi接口
    for (final interface in interfaces) {
      debugPrint('  接口: ${interface.name}');
      // iOS的WiFi接口通常命名为'en0'或包含'wlan'
      if ((interface.name.startsWith('en') || interface.name.contains('wlan')) && 
          !_isVirtualInterface(interface.name)) {
        for (final addr in interface.addresses) {
          debugPrint('    地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            debugPrint('    选择WiFi地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    }
    
    // 尝试移动数据接口
    for (final interface in interfaces) {
      debugPrint('  移动数据接口: ${interface.name}');
      if ((interface.name.startsWith('pdp_ip') || interface.name.startsWith('rmnet')) &&
          !_isVirtualInterface(interface.name)) {
        for (final addr in interface.addresses) {
          debugPrint('    地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            debugPrint('    选择移动数据地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    }
    
    debugPrint('    未找到合适的地址，返回默认值');
    return '127.0.0.1';
  }
  
  // 鸿蒙平台IP地址获取
  static String _getOhosLocalIpAddress(List<NetworkInterface> interfaces) {
    debugPrint('鸿蒙平台网络接口信息:');
    
    // 优先选择WiFi接口，明确排除虚拟接口
    for (final interface in interfaces) {
      debugPrint('  接口: ${interface.name}');
      // 鸿蒙设备的WiFi接口通常以'wlan'开头
      if (interface.name.startsWith('wlan') && 
          !_isVirtualInterface(interface.name)) {
        for (final addr in interface.addresses) {
          debugPrint('    地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            debugPrint('    选择WiFi地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    }
    
    // 如果没有找到wlan接口，尝试其他可能的物理接口
    for (final interface in interfaces) {
      debugPrint('  接口: ${interface.name}');
      // 排除虚拟接口和回环接口
      if (!_isVirtualInterface(interface.name) && 
          !interface.name.startsWith('lo') &&
          !interface.name.startsWith('rmnet')) {
        for (final addr in interface.addresses) {
          debugPrint('    地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            debugPrint('    选择地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    }
    
    // 最后的备选方案
    for (final interface in interfaces) {
      debugPrint('  接口: ${interface.name}');
      if (!_isVirtualInterface(interface.name)) {
        for (final addr in interface.addresses) {
          debugPrint('    地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
          if (addr.type == InternetAddressType.IPv4 && 
              !addr.isLoopback && 
              _isPrivateNetwork(addr.address)) {
            debugPrint('    选择地址: ${addr.address}');
            return addr.address;
          }
        }
      }
    }
    
    debugPrint('    未找到合适的地址，返回默认值');
    return '127.0.0.1';
  }
  
  // 判断是否为虚拟接口
  static bool _isVirtualInterface(String interfaceName) {
    return interfaceName.contains('bridge') || 
           interfaceName.contains('tun') || 
           interfaceName.contains('tap') ||
           interfaceName.contains('docker') ||
           interfaceName.contains('veth');
  }
  
  // 判断是否为私有网络地址
  static bool _isPrivateNetwork(String ipAddress) {
    if (ipAddress.startsWith('127.')) return false; // 回环地址
    if (ipAddress.startsWith('169.254.')) return false; // 链路本地地址
    
    // 私有网络地址范围
    if (ipAddress.startsWith('10.')) return true;     // 10.0.0.0/8
    if (ipAddress.startsWith('172.')) {               // 172.16.0.0/12
      final parts = ipAddress.split('.');
      if (parts.length >= 2) {
        final secondOctet = int.tryParse(parts[1]) ?? 0;
        return secondOctet >= 16 && secondOctet <= 31;
      }
    }
    if (ipAddress.startsWith('192.168.')) return true; // 192.168.0.0/16
    
    return false;
  }
  
  // 验证IP地址是否有效
  static bool isValidIpAddress(String? ip) {
    if (ip == null || ip.isEmpty) return false;
    if (ip == '127.0.0.1') return false; // 排除回环地址
    if (ip.startsWith('169.254.')) return false; // 排除链路本地地址
    
    // 简单的IP地址格式验证
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    
    return true;
  }
  
  // 测试网络接口
  static Future<void> testNetworkInterfaces() async {
    try {
      debugPrint('=== 网络接口测试 ===');
      final interfaces = await NetworkInterface.list();
      
      for (final interface in interfaces) {
        debugPrint('接口名称: ${interface.name}');
        for (final addr in interface.addresses) {
          debugPrint('  地址: ${addr.address}, 类型: ${addr.type}, 回环: ${addr.isLoopback}');
        }
      }
    } catch (e) {
      debugPrint('网络接口测试失败: $e');
    }
  }
}