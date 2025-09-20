import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voice_to_text_app/utils/file_share_service.dart';
import 'package:voice_to_text_app/models/received_file.dart';
import 'package:voice_to_text_app/components/colors.dart';

/// 全屏图片预览组件
class FullscreenImagePreview extends StatefulWidget {
  final String imagePath;
  final String title;

  const FullscreenImagePreview({
    Key? key,
    required this.imagePath,
    this.title = '图片预览',
  }) : super(key: key);

  /// 显示全屏图片预览的便捷方法
  static Future<void> show(BuildContext context, String imagePath, {String title = '图片预览'}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenImagePreview(
          imagePath: imagePath,
          title: title,
        ),
      ),
    );
  }

  @override
  State<FullscreenImagePreview> createState() => _FullscreenImagePreviewState();
}

class _FullscreenImagePreviewState extends State<FullscreenImagePreview> {
  late PageController _pageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 保存图片到相册
  Future<void> _saveToGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 检查文件是否存在
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件不存在'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      // 读取图片数据
      final imageBytes = await file.readAsBytes();

      // 保存到相册
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "image_${DateTime.now().millisecondsSinceEpoch}",
      );

      setState(() {
        _isLoading = false;
      });

      if (result['isSuccess'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片已保存到相册'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: ${result['message'] ?? '未知错误'}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存过程中出现错误: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 分享图片
  Future<void> _shareImage() async {
    try {
      // 检查文件是否存在
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('文件不存在'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 获取文件信息
      final stat = await file.stat();
      final name = file.path.split(Platform.pathSeparator).last;

      // 创建ReceivedFile对象
      final receivedFile = ReceivedFile(
        id: widget.imagePath.hashCode.toString(),
        name: name,
        path: widget.imagePath,
        size: stat.size,
        receivedTime: stat.modified,
        senderName: '本地文件',
        senderIp: 'local',
        fileType: 'image',
      );

      // 使用FileShareService分享
      final shareService = FileShareService();
      await shareService.shareFiles([receivedFile]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已启动分享'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
            tooltip: '分享',
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveToGallery,
            tooltip: '保存到相册',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 点击图片时可以添加额外的交互，如隐藏/显示AppBar
        },
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '图片加载失败',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}