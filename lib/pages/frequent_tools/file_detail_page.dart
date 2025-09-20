import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../models/received_file.dart';
import '../../utils/file_share_service.dart';
import '../../components/base_tool_page.dart';

class FileDetailPage extends StatefulWidget {
  final ReceivedFile file;
  
  const FileDetailPage({super.key, required this.file});
  
  @override
  State<FileDetailPage> createState() => _FileDetailPageState();
}

class _FileDetailPageState extends State<FileDetailPage> {
  final FileShareService _shareService = FileShareService();
  
  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '文件详情',
      actions: [
        IconButton(
          onPressed: _shareFile,
          icon: const Icon(Icons.share),
          tooltip: '分享文件',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件预览区域
            _buildFilePreview(),
            const SizedBox(height: 24),
            
            // 文件信息卡片
            _buildFileInfoCard(),
            const SizedBox(height: 16),
            
            // 文件属性卡片
            _buildFilePropertiesCard(),
            const SizedBox(height: 16),
            
            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildPreviewContent(),
      ),
    );
  }
  
  Widget _buildPreviewContent() {
    if (widget.file.hasThumbnail) {
      return Image.file(
        File(widget.file.thumbnailPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultPreview();
        },
      );
    } else if (widget.file.fileType == 'image' && widget.file.exists) {
      return Image.file(
        File(widget.file.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultPreview();
        },
      );
    } else {
      return _buildDefaultPreview();
    }
  }
  
  Widget _buildDefaultPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getFileTypeColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFileTypeIcon(),
              size: 48,
              color: _getFileTypeColor(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getFileTypeText(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getFileTypeIcon() {
    switch (widget.file.fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      case 'document':
        return Icons.description;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  Color _getFileTypeColor() {
    switch (widget.file.fileType) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      case 'document':
        return Colors.blue;
      case 'archive':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
  
  String _getFileTypeText() {
    switch (widget.file.fileType) {
      case 'image':
        return '图片文件';
      case 'video':
        return '视频文件';
      case 'audio':
        return '音频文件';
      case 'document':
        return '文档文件';
      case 'archive':
        return '压缩文件';
      default:
        return '其他文件';
    }
  }
  
  Widget _buildFileInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  '文件信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
                const Spacer(),
                if (widget.file.isLocalImport)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '本地',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('文件名', widget.file.name, Icons.label),
            _buildInfoRow('文件大小', widget.file.formattedSize, Icons.storage),
            _buildInfoRow('文件类型', _getFileTypeText(), Icons.category),
            _buildInfoRow('发送者', widget.file.senderName, Icons.person),
            if (!widget.file.isLocalImport)
              _buildInfoRow('发送IP', widget.file.senderIp, Icons.computer),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilePropertiesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '文件属性',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '接收时间',
              _formatDateTime(widget.file.receivedTime),
              Icons.access_time,
            ),
            _buildInfoRow(
              '文件路径',
              widget.file.path,
              Icons.folder,
              copyable: true,
            ),
            _buildInfoRow(
              '文件状态',
              widget.file.exists ? '存在' : '已删除',
              widget.file.exists ? Icons.check_circle : Icons.error,
              color: widget.file.exists ? Colors.green : Colors.red,
            ),
            if (widget.file.hasThumbnail)
              _buildInfoRow('缩略图', '已生成', Icons.image, color: Colors.green),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon, {bool copyable = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: copyable ? () => _copyToClipboard(value) : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color ?? Colors.black87,
                  decoration: copyable ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
          if (copyable)
            IconButton(
              onPressed: () => _copyToClipboard(value),
              icon: const Icon(Icons.copy, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareFile,
            icon: const Icon(Icons.share),
            label: const Text('分享文件'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.file.exists ? _openFile : null,
            icon: const Icon(Icons.open_in_new),
            label: Text(widget.file.exists ? '打开文件' : '文件不存在'),
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.file.exists ? Colors.green.shade600 : Colors.grey,
              side: BorderSide(
                color: widget.file.exists ? Colors.green.shade600 : Colors.grey,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _shareFile() async {
    try {
      HapticFeedback.lightImpact();
      
      // 检查文件是否存在
      if (!widget.file.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('文件不存在，无法分享'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      // 显示加载状态
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('正在准备分享...'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      
      // 使用FileShareService进行分享
      await _shareService.shareFiles([widget.file]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已分享文件: ${widget.file.name}'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: _shareFile,
            ),
          ),
        );
      }
    }
  }
  
  void _openFile() async {
    // TODO: 实现打开文件功能，可以使用open_file插件
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('打开文件功能暂未实现'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}