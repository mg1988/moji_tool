import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../components/base_tool_page.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取屏幕信息
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int screenWidthPx = (screenWidth * devicePixelRatio).round();
    final int screenHeightPx = (screenHeight * devicePixelRatio).round();
    
    // 获取操作系统信息
    final String platform = Platform.operatingSystem;
    final String platformVersion = Platform.operatingSystemVersion;
    
    // 获取Flutter框架信息
    final String flutterVersion = Platform.version;
    
    // 设备信息列表
    final List<DeviceInfoItem> infoItems = [
      DeviceInfoItem(title: '设备类型', value: platform),
      DeviceInfoItem(title: '系统版本', value: platformVersion),
      DeviceInfoItem(title: '屏幕尺寸', value: '${screenWidth.toStringAsFixed(2)} × ${screenHeight.toStringAsFixed(2)} 英寸'),
      DeviceInfoItem(title: '屏幕分辨率', value: '$screenWidthPx × $screenHeightPx 像素'),
      DeviceInfoItem(title: '像素密度', value: devicePixelRatio.toStringAsFixed(2)),
      DeviceInfoItem(title: 'Flutter版本', value: flutterVersion),
      DeviceInfoItem(title: '文字缩放因子', value: MediaQuery.of(context).textScaler.scale(1.0).toStringAsFixed(2)),
      DeviceInfoItem(title: '亮度', value: (MediaQuery.of(context).platformBrightness == Brightness.light ? '亮色模式' : '暗色模式')),
    ];

    return BaseToolPage(
      title: '设备信息',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 设备图标
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 30.0),
              child: const Icon(
                Icons.devices,
                size: 80.0,
                color: Colors.blue,
              ),
            ),
            
            // 设备信息列表
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: infoItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 3, // 允许最多3行
                            overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // 复制按钮
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _copyDeviceInfoToClipboard(infoItems);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('设备信息已复制到剪贴板'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  '复制设备信息',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // 注意：如需获取更详细的设备信息，请取消下面代码的注释并添加必要的导入
  // Future<void> _getDeviceInfo() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print('Running on ${androidInfo.model}');
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     print('Running on ${iosInfo.utsname.machine}');
  //   }
  // }
  // 复制设备信息到剪贴板
  void _copyDeviceInfoToClipboard(List<DeviceInfoItem> infoItems) {
    StringBuffer buffer = StringBuffer();
    for (var item in infoItems) {
      buffer.writeln('${item.title}: ${item.value}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}

// 设备信息项数据类
class DeviceInfoItem {
  final String title;
  final String value;

  const DeviceInfoItem({required this.title, required this.value});
}