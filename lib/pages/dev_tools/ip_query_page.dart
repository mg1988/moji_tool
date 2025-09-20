import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../components/base_tool_page.dart';

class IPQueryPage extends StatefulWidget {
  const IPQueryPage({super.key});

  @override
  State<IPQueryPage> createState() => _IPQueryPageState();
}

class _IPQueryPageState extends State<IPQueryPage> {
  final TextEditingController _ipController = TextEditingController();
  final List<IPInfo> _ipInfoList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 验证IP地址格式
  bool _validateIP(String ip) {
    final RegExp ipv4Regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    final RegExp ipv6Regex = RegExp(
      r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$',
    );
    return ipv4Regex.hasMatch(ip) || ipv6Regex.hasMatch(ip);
  }

  // 查询IP地址信息（使用实际API）
  Future<void> _queryIP() async {
    final String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() {
        _errorMessage = '请输入IP地址';
      });
      return;
    }

    if (!_validateIP(ip)) {
      setState(() {
        _errorMessage = '请输入有效的IP地址';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 检查是否是局域网IP
      bool isLocal = ip.startsWith('192.168') || ip.startsWith('10.') || 
                    (ip.startsWith('172.') && int.parse(ip.split('.')[1]) >= 16 && 
                     int.parse(ip.split('.')[1]) <= 31);

      if (isLocal) {
        // 局域网IP直接返回本地信息
        final IPInfo ipInfo = IPInfo(
          ip: ip,
          country: '局域网',
          region: '局域网',
          city: '局域网',
          isp: '局域网',
          asn: '局域网',
          location: '局域网',
          isLocal: true,
        );

        setState(() {
          // 检查是否已存在相同IP的信息，如果有则更新，否则添加
          final int existingIndex = _ipInfoList.indexWhere((info) => info.ip == ip);
          if (existingIndex >= 0) {
            _ipInfoList[existingIndex] = ipInfo;
          } else {
            _ipInfoList.insert(0, ipInfo);
            // 只保留最近5条查询记录
            if (_ipInfoList.length > 5) {
              _ipInfoList.removeLast();
            }
          }
        });
      } else {
        // 非局域网IP使用API查询
        final String apiUrl = 'http://ips.chataudit.net/api/IpV4NoAuth?ip=$ip';
        final response = await http.get(Uri.parse(apiUrl));
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          
          // 检查API返回状态
          if (data['code'] == -1) {
            setState(() {
              _errorMessage = '查询失败：${data['msg']}';
            });
            return;
          }
          
          // 构建IP信息
          final IPInfo ipInfo = IPInfo(
            ip: data['ip'] ?? ip,
            country: data['country'] ?? '未知',
            region: data['province'] ?? '未知',
            city: data['city'] ?? '未知',
            isp: data['isp'] ?? '未知',
            asn: '未知', // API没有返回ASN信息
            location: '未知', // API没有返回经纬度信息
            isLocal: false,
          );

          setState(() {
            // 检查是否已存在相同IP的信息，如果有则更新，否则添加
            final int existingIndex = _ipInfoList.indexWhere((info) => info.ip == ip);
            if (existingIndex >= 0) {
              _ipInfoList[existingIndex] = ipInfo;
            } else {
              _ipInfoList.insert(0, ipInfo);
              // 只保留最近5条查询记录
              if (_ipInfoList.length > 5) {
                _ipInfoList.removeLast();
              }
            }
          });
        } else {
          setState(() {
            _errorMessage = '查询失败：服务器响应错误';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '查询失败：${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 清空输入
  void _clearInput() {
    _ipController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  // 复制结果
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制$label到剪贴板')),
    );
  }

  // 从剪贴板粘贴
  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _ipController.text = data!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
        title: 'IP地址查询',
        actions: [
          IconButton(
            icon: const Icon(Icons.paste),
            onPressed: _pasteFromClipboard,
            tooltip: '从剪贴板粘贴',
          ),
        ],
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入区域
            _buildInputSection(),
            
            // 查询按钮
            _buildQueryButton(),
            
            // 错误提示
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children:
                    [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!, 
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            
            // 查询结果区域
            if (_ipInfoList.isNotEmpty)
              _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  // 构建输入区域
  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          const Text(
            '输入IP地址',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ipController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
              ),
              hintText: '例如：8.8.8.8 或 2001:db8::1',
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearInput,
                tooltip: '清空',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建查询按钮
  Widget _buildQueryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _queryIP,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  '查询',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white),
                ),
        ),
      ),
    );
  }

  // 构建结果区域
  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        const Text(
          '查询结果',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // 展示查询结果
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ipInfoList.length,
          itemBuilder: (context, index) {
            final IPInfo info = _ipInfoList[index];
            return IPInfoCard(
              info: info,
              onCopy: _copyToClipboard,
              isLast: index == _ipInfoList.length - 1,
            );
          },
        ),
        // 添加额外的底部空间，防止内容溢出
        const SizedBox(height: 30),
      ],
    );
  }
}

// IP信息数据模型
class IPInfo {
  final String ip;
  final String country;
  final String region;
  final String city;
  final String isp;
  final String asn;
  final String location;
  final bool isLocal;

  IPInfo({
    required this.ip,
    required this.country,
    required this.region,
    required this.city,
    required this.isp,
    required this.asn,
    required this.location,
    required this.isLocal,
  });
}

// IP信息卡片组件
class IPInfoCard extends StatelessWidget {
  final IPInfo info;
  final Function(String, String) onCopy;
  final bool isLast;

  const IPInfoCard({
    super.key,
    required this.info,
    required this.onCopy,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          // IP地址和本地网络标记
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            [
              Text(
                info.ip,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'monospace',
                ),
              ),
              if (info.isLocal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '局域网',
                    style: TextStyle(
                      fontSize: 12,
                      color:  Color(0xFF616161), // 使用灰色的 shade700 对应的十六进制值替代动态 shade 调用
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // IP详细信息
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 3,
            children:
            [
              InfoItem(label: '国家/地区', value: info.country, onCopy: onCopy),
              InfoItem(label: '省份/地区', value: info.region, onCopy: onCopy),
              InfoItem(label: '城市', value: info.city, onCopy: onCopy),
              InfoItem(label: '运营商', value: info.isp, onCopy: onCopy),
              InfoItem(label: 'AS号', value: info.asn, onCopy: onCopy, isLastRow: true),
              InfoItem(label: '经纬度', value: info.location, onCopy: onCopy, isLastRow: true),
            ],
          ),
        ],
      ),
    );
  }
}

// 信息项组件
class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Function(String, String) onCopy;
  final bool isLastRow;

  const InfoItem({
    super.key,
    required this.label,
    required this.value,
    required this.onCopy,
    this.isLastRow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
      [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
          [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // IconButton(
            //   icon: const Icon(Icons.copy, size: 16),
            //   onPressed: () => onCopy(value, label),
            //   tooltip: '复制$label',
            //   padding: EdgeInsets.zero,
            //   constraints: const BoxConstraints(
            //     minWidth: 24,
            //     minHeight: 24,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}