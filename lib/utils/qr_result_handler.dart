import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter/services.dart';
import '../components/colors.dart';
import '../pages/private_browser_page.dart';

/// 二维码扫描结果处理器
class QRResultHandler {
  /// 处理扫描结果的主要方法
  static Future<void> handleResult(BuildContext context, String result) async {
    if (result.isEmpty) return;

    // 判断扫描结果类型并处理
    if (_isURL(result)) {
      await _handleURL(context, result);
    } else if (_isWiFi(result)) {
      await _handleWiFi(context, result);
    } else if (_isContact(result)) {
      await _handleContact(context, result);
    } else if (_isPhone(result)) {
      await _handlePhone(context, result);
    } else if (_isEmail(result)) {
      await _handleEmail(context, result);
    } else if (_isSMS(result)) {
      await _handleSMS(context, result);
    } else {
      await _handleText(context, result);
    }
  }

  /// 判断是否为URL
  static bool _isURL(String text) {
    return text.toLowerCase().startsWith('http://') ||
           text.toLowerCase().startsWith('https://') ||
           text.toLowerCase().startsWith('www.') ||
           RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').hasMatch(text);
  }

  /// 判断是否为WiFi
  static bool _isWiFi(String text) {
    return text.startsWith('WIFI:');
  }

  /// 判断是否为联系人
  static bool _isContact(String text) {
    return text.startsWith('MECARD:') || 
           text.startsWith('VCARD:') ||
           text.startsWith('BEGIN:VCARD');
  }

  /// 判断是否为电话号码
  static bool _isPhone(String text) {
    return text.startsWith('tel:') ||
           RegExp(r'^[+]?[\d\s\-\(\)]+$').hasMatch(text.trim());
  }

  /// 判断是否为邮箱
  static bool _isEmail(String text) {
    return text.startsWith('mailto:') ||
           RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(text);
  }

  /// 判断是否为短信
  static bool _isSMS(String text) {
    return text.startsWith('smsto:') || text.startsWith('sms:');
  }

  /// 处理URL
  static Future<void> _handleURL(BuildContext context, String url) async {
    print('DEBUG: 处理URL: $url'); // 调试信息
    
    await _showActionDialog(
      context,
      title: '发现网址',
      content: url,
      icon: Icons.link,
      actions: [
        _DialogAction(
          label: '复制链接',
          icon: Icons.copy,
          onTap: () {
            print('DEBUG: 执行复制链接'); // 调试信息
            _copyToClipboard(context, url);
          },
        ),
        _DialogAction(
          label: '系统浏览器',
          icon: Icons.open_in_browser,
          onTap: () {
            print('DEBUG: 执行系统浏览器'); // 调试信息
            _openURL(url);
          },
        ),
      ],
    );
  }

  /// 处理WiFi
  static Future<void> _handleWiFi(BuildContext context, String wifiString) async {
    final wifiInfo = _parseWiFi(wifiString);
    
    await _showActionDialog(
      context,
      title: '发现WiFi信息',
      content: 'WiFi名称: ${wifiInfo['ssid']}\n加密方式: ${wifiInfo['security']}\n密码: ${wifiInfo['password']}',
      icon: Icons.wifi,
      actions: [
        _DialogAction(
          label: '复制密码',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, wifiInfo['password'] ?? ''),
        ),
        _DialogAction(
          label: '连接WiFi',
          icon: Icons.wifi_calling,
          onTap: () => _connectToWiFi(context, wifiInfo),
        ),
      ],
    );
  }

  /// 处理联系人
  static Future<void> _handleContact(BuildContext context, String contactString) async {
    final contactInfo = _parseContact(contactString);
    
    await _showActionDialog(
      context,
      title: '发现联系人',
      content: _formatContactInfo(contactInfo),
      icon: Icons.person,
      actions: [
        _DialogAction(
          label: '复制信息',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, _formatContactInfo(contactInfo)),
        ),
        _DialogAction(
          label: '保存联系人',
          icon: Icons.contact_phone,
          onTap: () => _saveContact(context, contactInfo),
        ),
      ],
    );
  }

  /// 处理电话号码
  static Future<void> _handlePhone(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll('tel:', '').trim();
    
    await _showActionDialog(
      context,
      title: '发现电话号码',
      content: cleanPhone,
      icon: Icons.phone,
      actions: [
        _DialogAction(
          label: '复制号码',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, cleanPhone),
        ),
        _DialogAction(
          label: '拨打电话',
          icon: Icons.call,
          onTap: () => _makePhoneCall(cleanPhone),
        ),
      ],
    );
  }

  /// 处理邮箱
  static Future<void> _handleEmail(BuildContext context, String email) async {
    final cleanEmail = email.replaceAll('mailto:', '').trim();
    
    await _showActionDialog(
      context,
      title: '发现邮箱地址',
      content: cleanEmail,
      icon: Icons.email,
      actions: [
        _DialogAction(
          label: '复制邮箱',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, cleanEmail),
        ),
        _DialogAction(
          label: '发送邮件',
          icon: Icons.send,
          onTap: () => _sendEmail(cleanEmail),
        ),
      ],
    );
  }

  /// 处理短信
  static Future<void> _handleSMS(BuildContext context, String sms) async {
    final parts = sms.replaceAll(RegExp(r'^(smsto?:|sms:)'), '').split(':');
    final phone = parts.isNotEmpty ? parts[0] : '';
    final message = parts.length > 1 ? parts[1] : '';
    
    await _showActionDialog(
      context,
      title: '发现短信信息',
      content: '号码: $phone${message.isNotEmpty ? '\n内容: $message' : ''}',
      icon: Icons.sms,
      actions: [
        _DialogAction(
          label: '复制信息',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, message.isNotEmpty ? message : phone),
        ),
        _DialogAction(
          label: '发送短信',
          icon: Icons.send,
          onTap: () => _sendSMS(phone, message),
        ),
      ],
    );
  }

  /// 处理普通文本
  static Future<void> _handleText(BuildContext context, String text) async {
    await _showActionDialog(
      context,
      title: '扫描到文本',
      content: text,
      icon: Icons.text_fields,
      actions: [
        _DialogAction(
          label: '复制文本',
          icon: Icons.copy,
          onTap: () => _copyToClipboard(context, text),
        ),
      ],
    );
  }

  /// 显示操作对话框
  static Future<void> _showActionDialog(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required List<_DialogAction> actions,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBtn.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.2,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SelectableText(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 分割线
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.border,
              ),
              // 操作按钮区域
              if (actions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actions.map((action) => SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('DEBUG: 点击了按钮: ${action.label}'); // 调试信息
                          Navigator.pop(context);
                          print('DEBUG: 对话框已关闭，准备执行操作'); // 调试信息
                          action.onTap();
                        },
                        icon: Icon(action.icon, size: 16),
                        label: Text(
                          action.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBtn,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              // 关闭按钮
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 复制到剪贴板
  static void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 使用隐私浏览器打开URL
  static Future<void> _openInPrivateBrowser(BuildContext context, String url) async {
    try {
      String formattedUrl = url;
      if (!url.toLowerCase().startsWith('http://') && 
          !url.toLowerCase().startsWith('https://')) {
        formattedUrl = 'https://$url';
      }
      
      print('DEBUG: 准备打开隐私浏览器，URL: $formattedUrl'); // 调试信息
      
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在打开隐私浏览器...'),
          backgroundColor: AppColors.secondary,
          duration: Duration(seconds: 1),
        ),
      );
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            print('DEBUG: 创建PrivateBrowserPage，initialUrl: $formattedUrl'); // 调试信息
            return PrivateBrowserPage(initialUrl: formattedUrl);
          },
        ),
      );
      
      print('DEBUG: 隐私浏览器页面已关闭'); // 调试信息
      
    } catch (e, stackTrace) {
      print('ERROR: 打开隐私浏览器失败: $e');
      print('STACK: $stackTrace');
      
      // 显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('打开隐私浏览器失败: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 打开URL
  static Future<void> _openURL(String url) async {
    String formattedUrl = url;
    if (!url.toLowerCase().startsWith('http://') && 
        !url.toLowerCase().startsWith('https://')) {
      formattedUrl = 'https://$url';
    }
    
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 拨打电话
  static Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 发送邮件
  static Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 发送短信
  static Future<void> _sendSMS(String phone, String message) async {
    final uri = Uri.parse('sms:$phone${message.isNotEmpty ? '?body=$message' : ''}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 解析WiFi信息
  static Map<String, String> _parseWiFi(String wifiString) {
    final result = <String, String>{};
    
    // WIFI:T:WPA;S:MyNetwork;P:MyPassword;H:false;;
    final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);H:([^;]*);');
    final match = regex.firstMatch(wifiString);
    
    if (match != null) {
      result['security'] = match.group(1) ?? '';
      result['ssid'] = match.group(2) ?? '';
      result['password'] = match.group(3) ?? '';
      result['hidden'] = match.group(4) ?? 'false';
    }
    
    return result;
  }

  /// 解析联系人信息
  static Map<String, String> _parseContact(String contactString) {
    final result = <String, String>{};
    
    if (contactString.startsWith('MECARD:')) {
      // MECARD格式: MECARD:N:John Doe;TEL:123456789;EMAIL:john@example.com;;
      final parts = contactString.substring(7).split(';');
      for (final part in parts) {
        if (part.contains(':')) {
          final keyValue = part.split(':');
          if (keyValue.length >= 2) {
            final key = keyValue[0];
            final value = keyValue.sublist(1).join(':');
            switch (key) {
              case 'N':
                result['name'] = value;
                break;
              case 'TEL':
                result['phone'] = value;
                break;
              case 'EMAIL':
                result['email'] = value;
                break;
              case 'ORG':
                result['organization'] = value;
                break;
              case 'URL':
                result['website'] = value;
                break;
            }
          }
        }
      }
    } else if (contactString.startsWith('BEGIN:VCARD') || contactString.startsWith('VCARD:')) {
      // VCARD格式处理
      final lines = contactString.split('\n');
      for (final line in lines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join(':').trim();
            
            if (key.startsWith('FN')) {
              result['name'] = value;
            } else if (key.startsWith('TEL')) {
              result['phone'] = value;
            } else if (key.startsWith('EMAIL')) {
              result['email'] = value;
            } else if (key.startsWith('ORG')) {
              result['organization'] = value;
            } else if (key.startsWith('URL')) {
              result['website'] = value;
            }
          }
        }
      }
    }
    
    return result;
  }

  /// 格式化联系人信息
  static String _formatContactInfo(Map<String, String> contactInfo) {
    final buffer = StringBuffer();
    
    if (contactInfo['name']?.isNotEmpty == true) {
      buffer.writeln('姓名: ${contactInfo['name']}');
    }
    if (contactInfo['phone']?.isNotEmpty == true) {
      buffer.writeln('电话: ${contactInfo['phone']}');
    }
    if (contactInfo['email']?.isNotEmpty == true) {
      buffer.writeln('邮箱: ${contactInfo['email']}');
    }
    if (contactInfo['organization']?.isNotEmpty == true) {
      buffer.writeln('公司: ${contactInfo['organization']}');
    }
    if (contactInfo['website']?.isNotEmpty == true) {
      buffer.writeln('网站: ${contactInfo['website']}');
    }
    
    return buffer.toString().trim();
  }

  /// 连接WiFi
  static Future<void> _connectToWiFi(BuildContext context, Map<String, String> wifiInfo) async {
    try {
      // 检查WiFi权限
      if (await Permission.location.request().isGranted) {
        final ssid = wifiInfo['ssid'] ?? '';
        final password = wifiInfo['password'] ?? '';
        final security = wifiInfo['security'] ?? 'WPA';
        
        NetworkSecurity networkSecurity;
        switch (security.toUpperCase()) {
          case 'WEP':
            networkSecurity = NetworkSecurity.WEP;
            break;
          case 'WPA':
          case 'WPA2':
            networkSecurity = NetworkSecurity.WPA;
            break;
          case 'NONE':
            networkSecurity = NetworkSecurity.NONE;
            break;
          default:
            networkSecurity = NetworkSecurity.WPA;
        }
        
        final result = await WiFiForIoTPlugin.connect(
          ssid,
          password: password,
          security: networkSecurity,
          joinOnce: false,
        );
        
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WiFi连接成功'),
              backgroundColor: AppColors.secondary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WiFi连接失败'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要位置权限才能连接WiFi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('连接WiFi时发生错误: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 保存联系人
  static Future<void> _saveContact(BuildContext context, Map<String, String> contactInfo) async {
    try {
      // 检查联系人权限
      if (await Permission.contacts.request().isGranted) {
        final contact = Contact(
          givenName: contactInfo['name'] ?? '',
          phones: contactInfo['phone']?.isNotEmpty == true 
              ? [Item(label: 'mobile', value: contactInfo['phone']!)]
              : [],
          emails: contactInfo['email']?.isNotEmpty == true
              ? [Item(label: 'work', value: contactInfo['email']!)]
              : [],
          company: contactInfo['organization'] ?? '',
        );
        
        await ContactsService.addContact(contact);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('联系人保存成功'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要联系人权限才能保存联系人'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存联系人时发生错误: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// 对话框操作类
class _DialogAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _DialogAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}