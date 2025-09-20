import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:voice_to_text_app/components/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:voice_to_text_app/data/daily_quotes.dart';
import 'package:voice_to_text_app/pages/private_browser_page.dart';
import 'package:voice_to_text_app/pages/markdown_viewer_page.dart';
import 'package:voice_to_text_app/pages/qr_scanner_page.dart';
import 'package:voice_to_text_app/pages/storage_manager_page.dart';

// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoSave = true;
  String _language = 'zh-CN';
  File? _avatarFile;
  String _cacheSize = '0 MB';
  String _appVersion = '1.2.0';
  String _todayQuote = '';
  int _avatarTapCount = 0; // 头像点击计数
  bool _showPrivateBrowser = false; // 隐私浏览器可见状态

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAvatar();
    _calculateCacheSize();
    _getAppVersion();
    _loadTodayQuote();
  }

  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSave = prefs.getBool('autoSave') ?? true;
      _language = prefs.getString('language') ?? 'zh-CN';
      _showPrivateBrowser = prefs.getBool('showPrivateBrowser') ?? false;
    });
  }

  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSave', _autoSave);
    await prefs.setString('language', _language);
    await prefs.setBool('showPrivateBrowser', _showPrivateBrowser);
  }

  // 处理头像点击
  void _handleAvatarTap() {
    setState(() {
      _avatarTapCount++;
      // 点击10次后显示隐私浏览器
      if (_avatarTapCount >= 10 && !_showPrivateBrowser) {
        _showPrivateBrowser = true;
        _saveSettings(); // 保存状态
        // 显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('隐藏功能已解锁：隐私浏览器'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }



  // 加载头像
  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarPath = prefs.getString('avatarPath');
    if (avatarPath != null && File(avatarPath).existsSync()) {
      setState(() {
        _avatarFile = File(avatarPath);
      });
    }
  }

  // 选择头像
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
        
        await prefs.setString('avatarPath', savedImage.path);
        setState(() {
          _avatarFile = savedImage;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('选择头像失败: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 计算缓存大小
  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;
      
      if (tempDir.existsSync()) {
        try {
          // 使用递归方式计算目录大小，增加异常处理
          totalSize = await _calculateDirectorySize(tempDir);
        } catch (e) {
          debugPrint('计算目录大小失败: $e');
        }
      }
      
      setState(() {
        _cacheSize = _formatBytes(totalSize);
      });
    } catch (e) {
      debugPrint('计算缓存大小失败: $e');
      setState(() {
        _cacheSize = '计算失败';
      });
    }
  }

  // 递归计算目录大小
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      await for (var entity in directory.list()) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (e) {
            // 在某些平台上，访问文件大小可能会失败，我们忽略这些错误
            debugPrint('无法获取文件大小: ${entity.path}, 错误: $e');
          }
        } else if (entity is Directory) {
          try {
            // 递归计算子目录大小
            totalSize += await _calculateDirectorySize(entity);
          } catch (e) {
            // 在某些平台上，访问目录可能会失败，我们忽略这些错误
            debugPrint('无法访问目录: ${entity.path}, 错误: $e');
          }
        }
      }
    } catch (e) {
      // 在某些平台上，列出目录内容可能会失败，我们忽略这些错误
      debugPrint('无法列出目录内容: ${directory.path}, 错误: $e');
    }
    return totalSize;
  }

  // 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    // 修复指数计算错误，使用 math.pow 而不是 ^ 运算符
    int i = (math.log(bytes) / math.log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    double size = bytes / math.pow(1024, i);
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }

  // 清除缓存
  Future<void> _clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        try {
          // 使用更安全的清除方式
          await _clearDirectory(tempDir);
        } catch (e) {
          debugPrint('清除目录失败: $e');
          // 即使清除失败也尝试重新计算缓存大小
          await _calculateCacheSize();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('部分缓存清除失败'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }
      
      // 显示清除成功的提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('缓存清除成功'),
            backgroundColor: AppColors.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      await _calculateCacheSize();
    } catch (e) {
      debugPrint('清除缓存失败: $e');
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('缓存清除失败'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
      // 即使失败也重新计算缓存大小
      await _calculateCacheSize();
    }
  }

  // 安全地清除目录内容
  Future<void> _clearDirectory(Directory directory) async {
    try {
      await for (var entity in directory.list()) {
        try {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            // 递归删除子目录
            await _clearDirectory(entity);
            // 删除空目录
            await entity.delete();
          }
        } catch (e) {
          // 在某些平台上，删除某些文件或目录可能会失败，我们记录错误但继续处理其他项目
          debugPrint('无法删除文件/目录: ${entity.path}, 错误: $e');
          // 不抛出异常，继续处理其他文件
        }
      }
    } catch (e) {
      // 在某些平台上，列出目录内容可能会失败，我们记录错误
      debugPrint('无法列出目录内容进行清除: ${directory.path}, 错误: $e');
      // 重新抛出异常让上层处理
      rethrow;
    }
  }

  // 获取应用版本
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.2.0';
      });
    }
  }

  // 加载今日一言
  void _loadTodayQuote() {
    setState(() {
      _todayQuote = DailyQuotes.getTodayQuote();
    });
  }

  // 打开扫一扫页面
  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );
  }

  // 显示确认对话框
  Future<void> _showConfirmDialog(String title, String content, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(AppColors.primaryBtn),
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  // 打开URL或本地文件
  void _openURL(String url) {
    // 检查是否是本地文件
    if (url == 'terms_of_service.txt' || url == 'privacy_policy.txt') {
      _showLocalFileContent(url);
    } else if (url == 'storage_manager') {
      // 打开空间管理页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StorageManagerPage(),
        ),
      );
    } else {
      // 显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('即将打开: $url'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 显示本地资产文件内容（Markdown格式）
  Future<void> _showLocalFileContent(String fileName) async {
    try {
      // 根据文件名确定标题
      String title = fileName == 'terms_of_service.txt' ? '使用协议' : '隐私政策';
      
      // 使用Markdown查看器打开文件
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarkdownViewerPage(
            fileName: fileName,
            title: title,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法打开文件: $fileName'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 显示反馈对话框
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('如有任何问题或建议，请发送邮件至：'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openURL('mailto:670966512@qq.com'),
              child: const Text(
                '670966512@qq.com',
                style: TextStyle(
                  color: AppColors.primaryBtn,
                  decoration: TextDecoration.underline,
                ),
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
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
            ),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 清除按钮
  Widget _buildClearButton() {
    return TextButton(
      onPressed: () {
        _showConfirmDialog(
          '清除缓存',
          '确定要清除所有缓存数据吗？这不会删除你的个人设置和历史记录。',
          _clearCache,
        );
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      ),
      child: const Text(
        '清除',
        style: TextStyle(
          color: AppColors.primaryBtn,
          fontSize: 14,
        ),
      ),
    );
  }

  // 设置项组件
  Widget _buildSettingItem({
    required String title,
    String? description,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          description,
                          style: AppTextStyles.hint,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
          ],
        ),
      ),
    );
  }

  // 设置区块
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: AppCardStyles.featureCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title, style: AppTextStyles.pageTitle),
          ),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.primary,
            ),
            onPressed: () => _openScanner(),
            tooltip: '扫一扫',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 用户头像区域
              Container(
                width: double.infinity,
                decoration: AppCardStyles.featureCard,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // 头像
                        InkWell(
                          onTap: _handleAvatarTap,
                          borderRadius: BorderRadius.circular(56),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                            child: _avatarFile == null
                                ? const Icon(
                                    Icons.person,
                                    size: 64,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                        // 编辑头像按钮 - 缩小并美化
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBtn,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _pickAvatar,
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '点击更换头像',
                      style: AppTextStyles.caption,
                    ),
                    // 每日一言
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                size: 16,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '每日一言',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.format_quote_rounded,
                                size: 16,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _todayQuote,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 功能设置
              _buildSettingsSection(
                '功能设置',
                [
                  _buildSettingItem(
                    title: '自动保存',
                    description: '自动保存你的设置和历史记录',
                    trailing: Switch(
                      value: _autoSave,
                      onChanged: (value) {
                        setState(() {
                          _autoSave = value;
                        });
                        _saveSettings();
                      },
                      activeColor: AppColors.primaryBtn,
                      inactiveTrackColor: AppColors.border,
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSettingItem(
                    title: '语言',
                    description: '选择应用语言',
                    trailing: Container(
                      width: 150,
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: _language,
                        icon: const Icon(Icons.arrow_right),
                        style: AppTextStyles.body,
                        underline: Container(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _language = newValue;
                            });
                            _saveSettings();
                          }
                        },
                        items: <String>['zh-CN']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // 只有当_showPrivateBrowser为true时才显示隐私浏览器选项
                  if (_showPrivateBrowser)
                    _buildSettingItem(
                      title: '隐私浏览器',
                      description: '安全、隐私的内置浏览器',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivateBrowserPage(),
                          ),
                        );
                      },
                    ),
                ],
              ),

              // 存储管理
              _buildSettingsSection(
                '存储管理',
                [
                  _buildSettingItem(
                    title: '空间管理',
                    description: '管理应用内部存储空间',
                    onTap: () => _openURL('storage_manager'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSettingItem(
                    title: '清除缓存',
                    description: '当前缓存大小: $_cacheSize',
                    trailing: _buildClearButton(),
                  ),
                ],
              ),

              // 关于我们
              _buildSettingsSection(
                '关于我们',
                [
                  _buildSettingItem(
                    title: '隐私政策',
                    onTap: () => _openURL('privacy_policy.txt'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSettingItem(
                    title: '使用协议',
                    onTap: () => _openURL('terms_of_service.txt'),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSettingItem(
                    title: '用户反馈',
                    onTap: _showFeedbackDialog,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildSettingItem(
                    title: '版本信息',
                    description: 'V$_appVersion',
                    trailing: const Icon(Icons.info_outline),
                  ),
                ],
              ),

              // 底部间距
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}