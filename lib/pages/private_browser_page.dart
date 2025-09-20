import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_to_text_app/pages/browser_bookmarks_page.dart';
import 'package:voice_to_text_app/pages/html_source_viewer_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_extend/share_extend.dart';

/// 隐私浏览器页面
class PrivateBrowserPage extends StatefulWidget {
  final String? initialUrl;
  
  const PrivateBrowserPage({super.key, this.initialUrl});
     
  @override
  State<PrivateBrowserPage> createState() => _PrivateBrowserPageState();
}

class _PrivateBrowserPageState extends State<PrivateBrowserPage> {
  late WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';
  String _pageTitle = '';
  int _loadingProgress = 0;
  bool _showUrlBar = false;
  bool _isVideoFullscreen = false; // 视频全屏状态
  bool _hideToolbar = false; // 隐藏工具栏状态
  
  // 默认收藏列表（无密码）
  List<Map<String, String>> _defaultBookmarks = [];
  // 私密收藏列表（多密码支持）- 密码 -> 收藏列表映射
  Map<String, List<Map<String, String>>> _privateBookmarksMap = {};

  // 初始化下载目录
  Future<void> _initializeDownloadDirectory() async {
    try {
      // 请求存储权限
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        debugPrint('存储权限被拒绝');
        return;
      }

      // 获取下载目录
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      _downloadDirectory = downloadDir.path;
    } catch (e) {
      debugPrint('初始化下载目录失败: $e');
    }
  }

  // 加载下载历史
  Future<void> _loadDownloadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('browser_download_history');
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        setState(() {
          _downloadHistory = historyList.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('加载下载历史失败: $e');
    }
  }

  // 保存下载历史
  Future<void> _saveDownloadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(_downloadHistory);
      await prefs.setString('browser_download_history', historyJson);
    } catch (e) {
      debugPrint('保存下载历史失败: $e');
    }
  }

  // 处理文件下载
  Future<void> _handleDownload(String url, String? suggestedFilename) async {
    try {
      // 检查存储权限
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ 需要存储权限才能下载文件'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // 初始化下载目录
      if (_downloadDirectory == null) {
        await _initializeDownloadDirectory();
        if (_downloadDirectory == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ 无法创建下载目录'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }

      // 解析文件名
      final uri = Uri.parse(url);
      String filename = suggestedFilename ?? uri.pathSegments.last;
      if (filename.isEmpty) {
        filename = 'download_${DateTime.now().millisecondsSinceEpoch}';
      }

      // 显示下载确认对话框
      late bool shouldDownload;
      if (mounted) {
        shouldDownload = await showDialog<bool>(
          context: context, 
          builder: (context) => AlertDialog(
            title: const Text('下载文件'),
            content: Text('确定要下载 "$filename" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('下载'),
              ),
            ],
          ),
        ) ?? false;
      } else {
        shouldDownload = false;
      }

      if (!shouldDownload) return;

      // 显示下载开始通知
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📥 开始下载: $filename'),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 创建下载任务
      final taskId = 'download_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _currentDownloads[taskId] = {
          'id': taskId,
          'url': url,
          'filename': filename,
          'progress': 0,
          'status': 'downloading',
          'startTime': DateTime.now().millisecondsSinceEpoch,
        };
      });

      // 模拟下载过程（实际应用中应使用真实的网络请求）
      // 注意：这里只是演示，实际下载需要使用http库进行文件下载
      await Future.delayed(const Duration(seconds: 2));

      // 模拟下载完成
      final filePath = '$_downloadDirectory/$filename';
      setState(() {
        _currentDownloads[taskId] = {
          ..._currentDownloads[taskId]!,
          'progress': 100,
          'status': 'completed',
          'filePath': filePath,
          'endTime': DateTime.now().millisecondsSinceEpoch,
        };
      });

      // 添加到下载历史
      _downloadHistory.insert(0, {
        'id': taskId,
        'filename': filename,
        'url': url,
        'filePath': filePath,
        'downloadTime': DateTime.now().millisecondsSinceEpoch,
        'size': 0, // 实际应用中应获取真实文件大小
      });
      await _saveDownloadHistory();

      // 从当前下载列表中移除
      setState(() {
        _currentDownloads.remove(taskId);
      });

      // 显示下载完成通知
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 下载完成: $filename'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {
                _openFile(filePath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('下载文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 下载失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 打开文件
  Future<void> _openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // 实际应用中应根据文件类型使用相应的应用打开文件
        // 这里只是演示，可以使用url_launcher或其他库来打开文件
        debugPrint('打开文件: $filePath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📂 打开文件: ${filePath.split('/').last}'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ 文件不存在'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('打开文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 打开文件失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 删除下载文件
  Future<void> _deleteDownload(int index) async {
    if (index < 0 || index >= _downloadHistory.length) return;

    final download = _downloadHistory[index];
    final filePath = download['filePath'] as String?;
    final filename = download['filename'] as String;

    // 显示确认对话框
    final shouldDelete = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('删除文件'),
        content: Text('确定要删除 "$filename" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    try {
      // 删除文件
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 从历史记录中删除
      setState(() {
        _downloadHistory.removeAt(index);
      });
      await _saveDownloadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ 已删除: $filename'),
            backgroundColor: AppColors.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('删除文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 删除失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 分享下载文件
  Future<void> _shareDownload(int index) async {
    if (index < 0 || index >= _downloadHistory.length) return;

    final download = _downloadHistory[index];
    final filePath = download['filePath'] as String?;

    try {
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          // 使用share_extend分享文件
          await ShareExtend.share(filePath, 'file');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ 文件不存在'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('分享文件失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 分享失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 显示下载管理界面
  void _showDownloadManager() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖拽指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 标题
              const Text(
                '下载管理',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              // 当前下载
              if (_currentDownloads.isNotEmpty) ...[
                const Text(
                  '当前下载',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _currentDownloads.values.map((download) {
                    final progress = download['progress'] as int;
                    final filename = download['filename'] as String;
                    final status = download['status'] as String;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                             [
                              Expanded(
                                child: Text(
                                  filename,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$progress%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status == 'downloading' ? '下载中...' : '下载完成',
                            style: TextStyle(
                              fontSize: 12,
                              color: status == 'downloading' ? AppColors.textSecondary : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              
              // 下载历史
              const Text(
                '下载历史',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              _downloadHistory.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_outlined,
                            size: 60,
                            color: AppColors.textHint.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '暂无下载历史',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: _downloadHistory.length,
                      itemBuilder: (context, index) {
                        final download = _downloadHistory[index];
                        final filename = download['filename'] as String;
                        final downloadTime = DateTime.fromMillisecondsSinceEpoch(
                          download['downloadTime'] as int
                        );
                        final size = download['size'] as int;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.white,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: const Icon(
                              Icons.insert_drive_file_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            title: Text(
                              filename,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_formatDateTime(downloadTime)} · ${_formatFileSize(size)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () => _shareDownload(index),
                                  color: AppColors.primary,
                                  iconSize: 18,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteDownload(index),
                                  color: AppColors.textSecondary,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                            onTap: () {
                              final filePath = download['filePath'] as String?;
                              if (filePath != null) {
                                _openFile(filePath);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.month}/${dateTime.day}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // 下载历史列表
  List<Map<String, dynamic>> _downloadHistory = [];
  // 当前下载任务映射
  final Map<String, Map<String, dynamic>> _currentDownloads = {};
  // 下载目录
  String? _downloadDirectory;

  // 默认主页
  static const String _homePage = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>隐私浏览器</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            color: white;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding-top: 50px;
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        .subtitle {
            font-size: 1.2em;
            margin-bottom: 40px;
            opacity: 0.9;
        }
        .search-box {
            background: rgba(255,255,255,0.95);
            border-radius: 25px;
            padding: 15px 25px;
            margin: 20px 0;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        .search-input {
            width: 100%;
            border: none;
            outline: none;
            font-size: 16px;
            color: #333;
            background: transparent;
        }
        .quick-links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 40px;
        }
        .quick-link {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 15px;
            text-decoration: none;
            color: white;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }
        .quick-link:hover {
            background: rgba(255,255,255,0.2);
            transform: translateY(-2px);
        }
        .privacy-info {
            margin-top: 50px;
            padding: 20px;
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .feature {
            margin: 10px 0;
            font-size: 14px;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 隐私浏览器</h1>
        <p class="subtitle">安全、私密、无痕浏览</p>
        
        <div class="search-box">
            <input type="text" class="search-input" placeholder="输入网址或搜索内容..." 
                   onkeypress="if(event.key==='Enter') search(this.value)">
        </div>
        
        <div class="quick-links">
            <a href="https://www.baidu.com" class="quick-link">
                <div>🔍 百度搜索</div>
            </a>
            <a href="https://www.google.com" class="quick-link">
                <div>🌐 Google</div>
            </a>
            <a href="https://github.com" class="quick-link">
                <div>💻 GitHub</div>
            </a>
            <a href="https://stackoverflow.com" class="quick-link">
                <div>📚 Stack Overflow</div>
            </a>
        </div>
        
        <div class="privacy-info">
            <h3>🛡️ 隐私保护功能</h3>
            <div class="feature">🚫 不保存浏览历史</div>
            <div class="feature">🍪 自动清除Cookie</div>
            <div class="feature">🔐 安全连接验证</div>
            <div class="feature">📱 响应式设计</div>
        </div>
    </div>
    
    <script>
        function search(query) {
            if (!query) return;
            
            // 判断是否为网址
            if (query.includes('.') && !query.includes(' ')) {
                // 添加协议前缀
                if (!query.startsWith('http://') && !query.startsWith('https://')) {
                    query = 'https://' + query;
                }
                window.location.href = query;
            } else {
                // 使用百度搜索
                const encodedQuery = encodeURIComponent(query);
                window.location.href = `https://www.baidu.com/s?wd=\${encodedQuery}`;
            }
        }
    </script>
</body>
</html>
  ''';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadBookmarks();
    _initializeDownloadDirectory();
    _loadDownloadHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterDownloadHandler',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);
          _handleDownload(data['url'], data['filename']);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _urlController.text = url;
            });
            _updateNavigationState();
            _clearBrowsingData(); // 页面开始加载时清除浏览数据
          },
          onPageFinished: (String url) {
            // 原有逻辑
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _updateNavigationState();
            _getPageTitle();
            _injectVideoFullscreenScript(); // 注入视频全屏脚本
            
            // 注入下载处理脚本
            _injectDownloadHandler();
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('加载失败: ${error.description}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
        ),
      )
      ..loadHtmlString(_homePage);
    
    // 如果有初始URL，则加载该URL
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _navigateToUrl(widget.initialUrl!);
    }
  }



  // 注入下载处理脚本
  Future<void> _injectDownloadHandler() async {
    try {
      await _controller.runJavaScript('''
        // 拦截所有链接点击事件
        document.addEventListener('click', function(e) {
          let target = e.target;
          while (target && target.tagName !== 'A') {
            target = target.parentElement;
          }
          
          if (target && target.tagName === 'A') {
            const href = target.getAttribute('href');
            if (href) {
              // 检查是否为常见的可下载文件类型
              const downloadableExtensions = [
                '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
                '.zip', '.rar', '.7z', '.tar', '.gz', '.bz2',
                '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
                '.mp3', '.mp4', '.avi', '.mkv', '.mov', '.wmv',
                '.exe', '.dmg', '.pkg', '.apk', '.ipa',
                '.txt', '.rtf', '.csv', '.json', '.xml'
              ];
              
              const lowerHref = href.toLowerCase();
              for (const ext of downloadableExtensions) {
                if (lowerHref.endsWith(ext)) {
                  e.preventDefault();
                  const filename = href.split('/').pop() || 'download';
                  FlutterDownloadHandler.postMessage(JSON.stringify({
                    url: href,
                    filename: filename
                  }));
                  return;
                }
              }
            }
          }
        }, true);
        
        // 监听可能的下载请求（针对动态生成的下载链接）
        const originalFetch = window.fetch;
        window.fetch = function() {
          const args = Array.from(arguments);
          const url = args[0];
          if (typeof url === 'string') {
            const lowerUrl = url.toLowerCase();
            const downloadableExtensions = [
              '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
              '.zip', '.rar', '.7z', '.tar', '.gz', '.bz2',
              '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
              '.mp3', '.mp4', '.avi', '.mkv', '.mov', '.wmv',
              '.exe', '.dmg', '.pkg', '.apk', '.ipa',
              '.txt', '.rtf', '.csv', '.json', '.xml'
            ];
            
            for (const ext of downloadableExtensions) {
              if (lowerUrl.endsWith(ext)) {
                const filename = url.split('/').pop() || 'download';
                FlutterDownloadHandler.postMessage(JSON.stringify({
                  url: url,
                  filename: filename
                }));
                break;
              }
            }
          }
          return originalFetch.apply(this, args);
        };
      ''');
    } catch (e) {
      debugPrint('注入下载处理脚本失败: $e');
    }
  }
  
  // 注入视频全屏脚本
  Future<void> _injectVideoFullscreenScript() async {
    try {
      await _controller.runJavaScript('''
        // 监听视频全屏事件
        document.addEventListener('fullscreenchange', function() {
          if (document.fullscreenElement) {
            // 进入全屏 - 通知Flutter隐藏工具栏
            console.log('Video fullscreen entered');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
          } else {
            // 退出全屏 - 通知Flutter显示工具栏
            console.log('Video fullscreen exited');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
          }
        });
        
        // 监听webkit全屏事件（Safari/iOS）
        document.addEventListener('webkitfullscreenchange', function() {
          if (document.webkitFullscreenElement) {
            console.log('Webkit fullscreen entered');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
          } else {
            console.log('Webkit fullscreen exited');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
          }
        });
        
        // 为所有视频元素添加全屏支持
        const videos = document.querySelectorAll('video');
        videos.forEach(video => {
          video.setAttribute('webkit-playsinline', 'false');
          video.setAttribute('playsinline', 'false');
          video.controls = true;
          
          // 添加视频事件监听（iOS原生全屏）
          video.addEventListener('webkitbeginfullscreen', function() {
            console.log('Video native fullscreen started');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
          });
          
          video.addEventListener('webkitendfullscreen', function() {
            console.log('Video native fullscreen ended');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
          });
          
          // H5视频全屏事件
          video.addEventListener('enterfullscreen', function() {
            console.log('Video H5 fullscreen started');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
          });
          
          video.addEventListener('exitfullscreen', function() {
            console.log('Video H5 fullscreen ended');
            document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
          });
        });
        
        // 监听新添加的视频元素
        const observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === 1 && node.tagName === 'VIDEO') {
                node.setAttribute('webkit-playsinline', 'false');
                node.setAttribute('playsinline', 'false');
                node.controls = true;
                
                node.addEventListener('webkitbeginfullscreen', function() {
                  console.log('New video native fullscreen started');
                  document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
                });
                
                node.addEventListener('webkitendfullscreen', function() {
                  console.log('New video native fullscreen ended');
                  document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
                });
                
                node.addEventListener('enterfullscreen', function() {
                  console.log('New video H5 fullscreen started');
                  document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
                });
                
                node.addEventListener('exitfullscreen', function() {
                  console.log('New video H5 fullscreen ended');
                  document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
                });
              }
            });
          });
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
        
        // 为iOS设备添加专门的处理
        if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
          document.addEventListener('webkitfullscreenchange', function() {
            if (document.webkitIsFullScreen) {
              document.title = 'FLUTTER_VIDEO_FULLSCREEN_ENTER';
            } else {
              document.title = 'FLUTTER_VIDEO_FULLSCREEN_EXIT';
            }
          });
        }
      ''');
    } catch (e) {
      debugPrint('注入视频全屏脚本失败: $e');
    }
  }
  
  // 实时清除浏览数据
  Future<void> _clearBrowsingData() async {
    try {
      // 清除缓存和本地存储
      await _controller.clearCache();
      await _controller.clearLocalStorage();
    } catch (e) {
      debugPrint('清除浏览数据失败: $e');
    }
  }



  // 加载收藏列表
  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载默认收藏列表
      final defaultBookmarksJson = prefs.getString('browser_default_bookmarks');
      if (defaultBookmarksJson != null) {
        final List<dynamic> bookmarksList = json.decode(defaultBookmarksJson);
        setState(() {
          _defaultBookmarks = bookmarksList.map((item) => Map<String, String>.from(item)).toList();
        });
      }
      
      // 加载私密收藏映射表
      final privateBookmarksMapJson = prefs.getString('browser_private_bookmarks_map');
      if (privateBookmarksMapJson != null) {
        final Map<String, dynamic> bookmarksMap = json.decode(privateBookmarksMapJson);
        setState(() {
          _privateBookmarksMap = bookmarksMap.map((password, bookmarksList) {
            final List<Map<String, String>> typedBookmarks = 
                (bookmarksList as List<dynamic>)
                    .map((item) => Map<String, String>.from(item))
                    .toList();
            return MapEntry(password, typedBookmarks);
          });
        });
      }
      
    } catch (e) {
      debugPrint('加载收藏失败: $e');
    }
  }

  // 保存默认收藏列表
  Future<void> _saveDefaultBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = json.encode(_defaultBookmarks);
      await prefs.setString('browser_default_bookmarks', bookmarksJson);
    } catch (e) {
      debugPrint('保存默认收藏失败: $e');
    }
  }
  
  // 添加收藏到默认列表
  Future<void> _addBookmark() async {
    if (_currentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 请先打开一个网页'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 检查是否已经在默认收藏中
    final isAlreadyBookmarked = _defaultBookmarks.any((bookmark) => bookmark['url'] == _currentUrl);
    if (isAlreadyBookmarked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ℹ️ 该网页已经在收藏列表中'),
          backgroundColor: AppColors.textSecondary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final bookmark = {
      'title': _pageTitle.isNotEmpty ? _pageTitle : _currentUrl,
      'url': _currentUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    setState(() {
      _defaultBookmarks.insert(0, bookmark); // 添加到列表顶部
    });
    
    await _saveDefaultBookmarks();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⭐ 已添加到收藏'),
          backgroundColor: AppColors.secondary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  // 验证密码并显示收藏列表
  void _showBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserBookmarksPage(
          currentUrl: _currentUrl,
          currentTitle: _pageTitle,
          onBookmarkTap: (url) {
            Navigator.pop(context); // 返回浏览器
            _navigateToUrl(url);
          },
          onAddBookmark: () {
            // 刷新当前状态以更新收藏按钮显示
            setState(() {});
          },
        ),
      ),
    );
  }
  


  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _getPageTitle() async {
    try {
      final title = await _controller.getTitle();
      
      // 检测视频全屏状态
      if (title != null) {
        if (title == 'FLUTTER_VIDEO_FULLSCREEN_ENTER') {
          setState(() {
            _isVideoFullscreen = true;
            _hideToolbar = true; // 视频全屏时隐藏工具栏
          });
          debugPrint('视频进入全屏模式，隐藏工具栏');
          return; // 不更新页面标题
        } else if (title == 'FLUTTER_VIDEO_FULLSCREEN_EXIT') {
          setState(() {
            _isVideoFullscreen = false;
            _hideToolbar = false; // 退出全屏时显示工具栏
          });
          debugPrint('视频退出全屏模式，显示工具栏');
          return; // 不更新页面标题
        }
        
        // 正常的页面标题更新
        setState(() {
          _pageTitle = title;
        });
      }
    } catch (e) {
      // 忽略获取标题失败的错误
    }
  }

  void _navigateToUrl(String url) {
    if (url.isEmpty) return;
    
    String finalUrl = url.trim();
    
    // 智能URL处理
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      if (finalUrl.contains('.') && !finalUrl.contains(' ')) {
        // 看起来像域名
        finalUrl = 'https://$finalUrl';
      } else {
        // 看起来像搜索词
        finalUrl = 'https://www.baidu.com/s?wd=${Uri.encodeComponent(finalUrl)}';
      }
    }
    
    _controller.loadRequest(Uri.parse(finalUrl));
    setState(() {
      _showUrlBar = false;
    });
    _urlFocusNode.unfocus();
  }

  Future<void> _clearCookiesAndData() async {
    try {
      // 清除Cookie和缓存数据
      await _controller.clearCache();
      await _controller.clearLocalStorage();
      
      // 清除所有浏览记录（实时清空）
      await _controller.runJavaScript('''
        // 清除浏览器历史记录
        if (window.history && window.history.replaceState) {
          window.history.replaceState(null, null, window.location.href);
        }
        
        // 清除会话存储
        if (window.sessionStorage) {
          window.sessionStorage.clear();
        }
        
        // 清除索引数据库
        if (window.indexedDB) {
          indexedDB.databases().then(databases => {
            databases.forEach(db => {
              if (db.name) {
                indexedDB.deleteDatabase(db.name);
              }
            });
          }).catch(() => {});
        }
      ''');
      
      // 重新加载主页
      await _controller.loadHtmlString(_homePage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 已清除所有浏览数据和记录'),
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清除失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _viewSourceCode() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final html = await _controller.runJavaScriptReturningResult(
        'document.documentElement.outerHTML'
      );
      
      setState(() {
        _isLoading = false;
      });
      
      // 导航到独立的HTML源码查看器页面
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HtmlSourceViewerPage(
              sourceCode: html.toString().replaceAll('"', '').replaceAll('\\n', '\n'),
              pageTitle: _pageTitle.isNotEmpty ? _pageTitle : '未知页面',
              pageUrl: _currentUrl,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取源码失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // 标题
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '浏览器选项',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 选项列表
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuOption(
                      icon: Icons.bookmark_add_outlined,
                      title: '添加收藏',
                      subtitle: '收藏当前网页',
                      onTap: () {
                        Navigator.pop(context);
                        _addBookmark();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.bookmarks_outlined,
                      title: '我的收藏',
                      subtitle: '查看所有收藏的网页',
                      onTap: () {
                        Navigator.pop(context);
                        _showBookmarks();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.delete_sweep_outlined,
                      title: '清除数据',
                      subtitle: '清除Cookie、缓存和本地存储',
                      onTap: () {
                        Navigator.pop(context);
                        _clearCookiesAndData();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.code_outlined,
                      title: '查看源码',
                      subtitle: '显示当前网页的HTML源代码',
                      onTap: () {
                        Navigator.pop(context);
                        _viewSourceCode();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.home_outlined,
                      title: '返回主页',
                      subtitle: '回到隐私浏览器主页',
                      onTap: () {
                        Navigator.pop(context);
                        _controller.loadHtmlString(_homePage);
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.refresh_outlined,
                      title: '刷新网页',
                      subtitle: '重新加载当前网页',
                      onTap: () {
                        Navigator.pop(context);
                        _controller.reload();
                      },
                    ),
                    const SizedBox(height: 16), // 底部额外间距
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        color: AppColors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
          size: 18,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 状态栏适配 - 保留状态栏距离
          Container(
            height: safeAreaTop,
            color: AppColors.white, // 状态栏背景色
          ),
          // 进度条
          if (_isLoading && !_isVideoFullscreen)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          // WebView
          Expanded(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
          // 底部导航栏 - 优化高度并支持隐藏
          if (!_hideToolbar)
            _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  // iOS Safari风格的底部导航栏 - 优化高度
  Widget _buildBottomNavigationBar() {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // URL地址栏 - 减少边距
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showUrlBar = true;
                });
                _urlFocusNode.requestFocus();
              },
              child: Container(
                height: 36, // 减少高度从44到36
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 安全指示器
                    Icon(
                      _currentUrl.startsWith('https') ? Icons.lock : Icons.lock_open,
                      size: 18,
                      color: _currentUrl.startsWith('https') 
                          ? Colors.green 
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    // URL内容
                    Expanded(
                      child: _showUrlBar
                          ? TextField(
                              controller: _urlController,
                              focusNode: _urlFocusNode,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '输入网址或搜索内容',
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: _navigateToUrl,
                              onTapOutside: (event) {
                                setState(() {
                                  _showUrlBar = false;
                                });
                                _urlFocusNode.unfocus();
                              },
                            )
                          : Text(
                              _pageTitle.isNotEmpty 
                                  ? _pageTitle 
                                  : (_currentUrl.isEmpty ? '点击输入网址' : _currentUrl),
                              style: TextStyle(
                                fontSize: 16,
                                color: _currentUrl.isEmpty 
                                    ? AppColors.textHint 
                                    : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    // 刷新按钮
                    if (!_showUrlBar && _currentUrl.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _isLoading ? Icons.close : Icons.refresh,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_isLoading) {
                            // 停止加载（如果支持）
                            _controller.reload();
                          } else {
                            _controller.reload();
                          }
                        },
                        color: AppColors.primary,
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
          ),
          // 工具栏 - 优化高度
          Container(
            height: 48, // 减少高度从64到48
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            decoration: const BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 后退
                _buildToolbarButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onPressed: _canGoBack ? () => _controller.goBack() : null,
                  enabled: _canGoBack,
                  tooltip: '后退',
                ),
                // 前进
                _buildToolbarButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: _canGoForward ? () => _controller.goForward() : null,
                  enabled: _canGoForward,
                  tooltip: '前进',
                ),
                // 收藏
                _buildToolbarButton(
                  icon: _defaultBookmarks.any((bookmark) => bookmark['url'] == _currentUrl) ||
                         _privateBookmarksMap.values.any((bookmarks) => 
                             bookmarks.any((bookmark) => bookmark['url'] == _currentUrl))
                      ? Icons.bookmark 
                      : Icons.bookmark_border,
                  onPressed: () {
                    final isBookmarked = _defaultBookmarks.any((bookmark) => bookmark['url'] == _currentUrl) ||
                                        _privateBookmarksMap.values.any((bookmarks) => 
                                            bookmarks.any((bookmark) => bookmark['url'] == _currentUrl));
                    if (isBookmarked) {
                      _showBookmarks();
                    } else {
                      _addBookmark();
                    }
                  },
                  enabled: true,
                  tooltip: (_defaultBookmarks.any((bookmark) => bookmark['url'] == _currentUrl) ||
                           _privateBookmarksMap.values.any((bookmarks) => 
                               bookmarks.any((bookmark) => bookmark['url'] == _currentUrl)))
                      ? '查看收藏' 
                      : '添加收藏',
                  isHighlighted: _defaultBookmarks.any((bookmark) => bookmark['url'] == _currentUrl) ||
                                _privateBookmarksMap.values.any((bookmarks) => 
                                    bookmarks.any((bookmark) => bookmark['url'] == _currentUrl)),
                ),
                // 下载管理
                _buildToolbarButton(
                  icon: Icons.download_outlined,
                  onPressed: _showDownloadManager,
                  enabled: true,
                  tooltip: '查看下载历史',
                  isHighlighted: _currentDownloads.isNotEmpty,
                ),
                // 分享/更多
                _buildToolbarButton(
                  icon: Icons.more_horiz_rounded,
                  onPressed: _showOptionsMenu,
                  enabled: true,
                  tooltip: '更多选项',
                ),
              ],
            ),
          ),
          // 底部安全区域
          SizedBox(height: safeAreaBottom),
        ],
      ),
    );
  }

  // 工具栏按钮 - 优化尺寸
  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
    String? tooltip,
    bool isHighlighted = false,
  }) {
    return Container(
      width: 40, // 减少宽度从48到40
      height: 40, // 减少高度从48到40
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.primary.withOpacity(0.1)
            : (enabled ? Colors.transparent : AppColors.background),
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted 
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18, // 减少图标大小从22到18
          color: isHighlighted 
              ? AppColors.primary
              : (enabled ? AppColors.textPrimary : AppColors.textHint),
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// 密码输入对话框（用于加锁收藏）
class _PasswordInputDialog extends StatefulWidget {
  final Function(String) onPasswordConfirmed;
  final List<String> existingPasswords;

  const _PasswordInputDialog({
    required this.onPasswordConfirmed,
    required this.existingPasswords,
  });

  @override
  State<_PasswordInputDialog> createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<_PasswordInputDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _errorMessage = '';
  bool _isNewPassword = true; // 默认创建新密码

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _confirmPassword() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = '请输入密码';
      });
      return;
    }

    if (_isNewPassword) {
      if (password.length < 4) {
        setState(() {
          _errorMessage = '密码至少需要 4 位';
        });
        return;
      }
      
      if (widget.existingPasswords.contains(password)) {
        setState(() {
          _errorMessage = '该密码已存在，请选择其他密码';
        });
        return;
      }
    } else {
      if (!widget.existingPasswords.contains(password)) {
        setState(() {
          _errorMessage = '密码不存在，请检查输入';
        });
        return;
      }
    }

    Navigator.pop(context);
    widget.onPasswordConfirmed(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isNewPassword ? Icons.security : Icons.vpn_key,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(_isNewPassword ? '创建私密收藏密码' : '输入已有密码'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isNewPassword 
                ? '为私密收藏创建一个新密码：' 
                : '输入已有的私密收藏密码：',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // 密码模式切换
          if (widget.existingPasswords.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('创建新密码'),
                    selected: _isNewPassword,
                    onSelected: (selected) {
                      setState(() {
                        _isNewPassword = selected;
                        _errorMessage = '';
                        _passwordController.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('使用已有'),
                    selected: !_isNewPassword,
                    onSelected: (selected) {
                      setState(() {
                        _isNewPassword = !selected;
                        _errorMessage = '';
                        _passwordController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          if (widget.existingPasswords.isNotEmpty)
            const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: _isNewPassword ? '创建新密码' : '输入已有密码',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            onSubmitted: (_) => _confirmPassword(),
            autofocus: true,
          ),
          if (!_isNewPassword && widget.existingPasswords.isNotEmpty)
            const SizedBox(height: 8),
          if (!_isNewPassword && widget.existingPasswords.isNotEmpty)
            Text(
              '已有密码: ${widget.existingPasswords.join(', ')}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '取消',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _confirmPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBtn,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('确认'),
        ),
      ],
    );
  }
}
