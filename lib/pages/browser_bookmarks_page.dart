import 'package:flutter/material.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 浏览器收藏页面
class BrowserBookmarksPage extends StatefulWidget {
  final Function(String)? onBookmarkTap; // 点击收藏项的回调
  final String? currentUrl; // 当前浏览的URL，用于判断是否已收藏
  final String? currentTitle; // 当前页面标题
  final VoidCallback? onAddBookmark; // 添加收藏的回调

  const BrowserBookmarksPage({
    super.key,
    this.onBookmarkTap,
    this.currentUrl,
    this.currentTitle,
    this.onAddBookmark,
  });

  @override
  State<BrowserBookmarksPage> createState() => _BrowserBookmarksPageState();
}

class _BrowserBookmarksPageState extends State<BrowserBookmarksPage> {
  // 默认收藏列表（无密码）
  List<Map<String, String>> _defaultBookmarks = [];
  // 私密收藏列表（多密码支持）- 密码 -> 收藏列表映射
  Map<String, List<Map<String, String>>> _privateBookmarksMap = {};
  
  // 当前查看的是否为私密收藏
  bool _isViewingPrivateBookmarks = false;
  // 当前查看的私密收藏密码
  String _currentPrivatePassword = '';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
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
      print('加载收藏失败: $e');
    }
  }

  // 保存默认收藏列表
  Future<void> _saveDefaultBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = json.encode(_defaultBookmarks);
      await prefs.setString('browser_default_bookmarks', bookmarksJson);
    } catch (e) {
      print('保存默认收藏失败: $e');
    }
  }
  
  // 保存私密收藏映射表
  Future<void> _savePrivateBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksMapJson = json.encode(_privateBookmarksMap);
      await prefs.setString('browser_private_bookmarks_map', bookmarksMapJson);
    } catch (e) {
      print('保存私密收藏失败: $e');
    }
  }
  
  // 为指定密码创建收藏列表
  void _createPrivateBookmarkList(String password) {
    if (!_privateBookmarksMap.containsKey(password)) {
      setState(() {
        _privateBookmarksMap[password] = [];
      });
      _savePrivateBookmarks();
    }
  }

  // 添加收藏到默认列表
  Future<void> _addBookmark() async {
    if (widget.currentUrl == null || widget.currentUrl!.isEmpty) {
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
    final isAlreadyBookmarked = _defaultBookmarks.any((bookmark) => bookmark['url'] == widget.currentUrl);
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
      'title': (widget.currentTitle?.isNotEmpty == true) ? widget.currentTitle! : widget.currentUrl!,
      'url': widget.currentUrl!,
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

    // 调用外部回调
    if (widget.onAddBookmark != null) {
      widget.onAddBookmark!();
    }
  }

  // 删除收藏
  Future<void> _removeBookmark(int index) async {
    final bookmarks = _isViewingPrivateBookmarks 
        ? (_privateBookmarksMap[_currentPrivatePassword] ?? [])
        : _defaultBookmarks;
    
    if (index < 0 || index >= bookmarks.length) return;
    
    final bookmark = bookmarks[index];
    setState(() {
      bookmarks.removeAt(index);
    });
    
    if (_isViewingPrivateBookmarks) {
      await _savePrivateBookmarks();
    } else {
      await _saveDefaultBookmarks();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ 已删除 "${bookmark['title']}"'),
          backgroundColor: AppColors.textSecondary,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: '撤销',
            textColor: AppColors.white,
            onPressed: () {
              setState(() {
                bookmarks.insert(index, bookmark);
              });
              if (_isViewingPrivateBookmarks) {
                _savePrivateBookmarks();
              } else {
                _saveDefaultBookmarks();
              }
            },
          ),
        ),
      );
    }
  }

  // 加锁到私密收藏（从默认收藏移动到私密收藏）
  Future<void> _lockBookmarkToPrivate(int index) async {
    if (index < 0 || index >= _defaultBookmarks.length) return;
    
    // 显示密码输入对话框来选择或创建私密收藏列表
    _showPasswordInputDialog((password) {
      _moveToPrivateBookmark(index, password);
    });
  }
  
  // 移动收藏到指定密码的私密列表
  Future<void> _moveToPrivateBookmark(int index, String password) async {
    final bookmark = _defaultBookmarks[index];
    
    // 确保该密码的收藏列表存在
    _createPrivateBookmarkList(password);
    
    setState(() {
      _defaultBookmarks.removeAt(index);
      _privateBookmarksMap[password]!.insert(0, bookmark);
    });
    
    await _saveDefaultBookmarks();
    await _savePrivateBookmarks();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 "${bookmark['title']}" 已加锁到私密收藏'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 显示私密收藏列表（需要密码验证）
  void _showPrivateBookmarks() {
    if (_privateBookmarksMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ℹ️ 还没有设置私密收藏密码'),
          backgroundColor: AppColors.textSecondary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => _BookmarkPasswordDialog(
        availablePasswords: _privateBookmarksMap.keys.toList(),
        onPasswordVerified: (password) {
          setState(() {
            _isViewingPrivateBookmarks = true;
            _currentPrivatePassword = password;
          });
        },
      ),
    );
  }

  // 显示密码输入对话框（用于加锁收藏到私密列表）
  void _showPasswordInputDialog(Function(String) onPasswordConfirmed) {
    showDialog(
      context: context,
      builder: (context) => _PasswordInputDialog(
        existingPasswords: _privateBookmarksMap.keys.toList(),
        onPasswordConfirmed: onPasswordConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果是私密收藏且密码为空，则显示空列表
    final bookmarks = (_isViewingPrivateBookmarks && _currentPrivatePassword.isNotEmpty) 
        ? (_privateBookmarksMap[_currentPrivatePassword] ?? [])
        : (_isViewingPrivateBookmarks 
            ? <Map<String, String>>[] // 错误密码时显示空列表
            : _defaultBookmarks);
    final isPrivate = _isViewingPrivateBookmarks;
    final isPasswordWrong = _isViewingPrivateBookmarks && _currentPrivatePassword.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 确保完全手动控制布局，避免系统干预
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          // 状态栏适配 - 使用viewPadding获取准确高度
          Container(
            height: MediaQuery.of(context).viewPadding.top,
            color: AppColors.white, // 状态栏背景色
          ),
          // 自定义AppBar - 增加高度适配
          Container(
            height: kToolbarHeight + 8, // 标准AppBar高度 + 额外间距
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  // 返回按钮
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                  // 标题区域
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isPrivate 
                                ? Colors.red.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPrivate ? Icons.lock : Icons.bookmarks,
                            color: isPrivate ? Colors.red : AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isPrivate ? '私密收藏' : '我的收藏',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                isPasswordWrong 
                                    ? '密码错误，无法显示数据'
                                    : '共 ${bookmarks.length} 个收藏网页',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isPasswordWrong ? AppColors.error : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 添加按钮（仅在默认收藏显示）
                  if (!isPrivate)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBtn,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: AppColors.white),
                        onPressed: _addBookmark,
                        tooltip: '添加当前网页',
                        iconSize: 16,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  // 解锁/加锁按钮（常驻显示）
                  if (_privateBookmarksMap.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isPrivate 
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPrivate 
                              ? AppColors.primary.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPrivate ? Icons.lock : Icons.lock_open,
                          color: isPrivate ? AppColors.primary : Colors.orange,
                        ),
                        onPressed: () {
                          if (isPrivate) {
                            setState(() {
                              _isViewingPrivateBookmarks = false;
                            });
                          } else {
                            _showPrivateBookmarks();
                          }
                        },
                        tooltip: isPrivate ? '返回默认收藏' : '查看私密收藏',
                        iconSize: 16,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 收藏列表内容
          Expanded(
            child: _buildBookmarksList(bookmarks, isPrivate, isPasswordWrong),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(List<Map<String, String>> bookmarks, bool isPrivate, bool isPasswordWrong) {
    return bookmarks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isPasswordWrong 
                        ? Icons.error_outline
                        : (isPrivate ? Icons.lock_outline : Icons.bookmark_border),
                    size: 40,
                    color: isPasswordWrong ? AppColors.error : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isPasswordWrong
                      ? '密码错误'
                      : (isPrivate ? '暂无私密收藏' : '暂无收藏网页'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPasswordWrong ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPasswordWrong
                      ? '输入的密码不正确，无法显示私密收藏内容\n请重新输入正确密码'
                      : (isPrivate 
                          ? '点击收藏项的加锁按钮来添加私密收藏'
                          : '点击右上角 + 号按钮来添加收藏'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isPasswordWrong ? AppColors.error.withOpacity(0.7) : AppColors.textHint,
                    height: 1.4,
                  ),
                ),
                // 密码错误时显示重试按钮
                if (isPasswordWrong)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        _showPrivateBookmarks(); // 重新弹出密码输入框
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBtn,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('重新输入密码'),
                    ),
                  ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bookmark['url']?.startsWith('https') == true
                          ? Colors.green.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      bookmark['url']?.startsWith('https') == true
                          ? Icons.security
                          : Icons.public,
                      color: bookmark['url']?.startsWith('https') == true
                          ? Colors.green
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    bookmark['title']?.isNotEmpty == true
                        ? bookmark['title']!
                        : '未命名网页',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bookmark['url'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 加锁按钮（只在默认收藏显示）
                      if (!isPrivate)
                        IconButton(
                          icon: const Icon(
                            Icons.lock_outline,
                            color: Colors.orange,
                          ),
                          onPressed: () => _lockBookmarkToPrivate(index),
                          tooltip: '加锁到私密收藏',
                          iconSize: 18,
                        ),
                      // 删除按钮
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () => _removeBookmark(index),
                        tooltip: '删除收藏',
                        iconSize: 18,
                      ),
                    ],
                  ),
                  onTap: () {
                    if (widget.onBookmarkTap != null) {
                      widget.onBookmarkTap!(bookmark['url'] ?? '');
                    }
                  },
                ),
              );
            },
          );
  }
}

// 密码验证对话框（用于访问私密收藏）
class _BookmarkPasswordDialog extends StatefulWidget {
  final Function(String) onPasswordVerified;
  final List<String> availablePasswords;

  const _BookmarkPasswordDialog({
    required this.onPasswordVerified,
    required this.availablePasswords,
  });

  @override
  State<_BookmarkPasswordDialog> createState() => _BookmarkPasswordDialogState();
}

class _BookmarkPasswordDialogState extends State<_BookmarkPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isVerifying = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    // 模拟验证延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final enteredPassword = _passwordController.text;

    // 关闭对话框，始终进入列表页面
    Navigator.pop(context);
    
    // 检查密码是否正确
    final isPasswordCorrect = widget.availablePasswords.contains(enteredPassword);
    
    // 显示收藏列表（正确密码显示数据，错误密码显示空列表）
    widget.onPasswordVerified(isPasswordCorrect ? enteredPassword : '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.lock,
            color: AppColors.primary,
          ),
          SizedBox(width: 8),
          Text('私密收藏验证'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请输入私密收藏密码来查看隐私内容：',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: '请输入密码',
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
            onSubmitted: (_) => _verifyPassword(),
            autofocus: true,
          ),
          const SizedBox(height: 8),
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
          onPressed: _isVerifying ? null : _verifyPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBtn,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Text('确认'),
        ),
      ],
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