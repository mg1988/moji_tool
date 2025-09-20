import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_to_text_app/models/menu_category.dart';
import 'package:voice_to_text_app/data/menu_data.dart';
import 'package:flutter/material.dart';

// 收藏管理器 - 用于管理工具项的收藏状态
class FavoriteManager {
  static const String _favoritesKey = 'tool_favorites';
  static final FavoriteManager _instance = FavoriteManager._internal();
  late SharedPreferences _prefs;
  final Set<String> _favorites = {};
  bool _isInitialized = false;
  
  // 全局收藏状态变化回调
  static Function? _onFavoritesChanged;
  
  // 设置收藏状态变化回调
  static void setOnFavoritesChangedCallback(Function callback) {
    _onFavoritesChanged = callback;
  }
  
  // 触发收藏状态变化通知
  static void notifyFavoritesChanged() {
    _onFavoritesChanged?.call();
  }

  // 单例模式
  factory FavoriteManager() {
    return _instance;
  }

  FavoriteManager._internal();

  // 获取单例实例
  static FavoriteManager get instance => _instance;

  // 初始化收藏管理器
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    final savedFavorites = _prefs.getStringList(_favoritesKey) ?? [];
    _favorites.addAll(savedFavorites);
    _isInitialized = true;
  }

  // 检查是否已初始化
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // 添加到收藏
  Future<void> addToFavorite(String toolId) async {
    await _ensureInitialized();
    
    if (!_favorites.contains(toolId)) {
      _favorites.add(toolId);
      await _saveFavorites();
      notifyFavoritesChanged();
    }
  }

  // 从收藏中移除
  Future<void> removeFromFavorite(String toolId) async {
    await _ensureInitialized();
    
    if (_favorites.contains(toolId)) {
      _favorites.remove(toolId);
      await _saveFavorites();
      notifyFavoritesChanged();
    }
  }

  // 切换收藏状态
  Future<void> toggleFavorite(String toolId) async {
    await _ensureInitialized();
    
    if (isFavorite(toolId)) {
      await removeFromFavorite(toolId);
    } else {
      await addToFavorite(toolId);
    }
    // 通知已在addToFavorite/removeFromFavorite中触发，这里不需要重复触发
  }

  // 检查是否是收藏
  bool isFavorite(String toolId) {
    return _favorites.contains(toolId);
  }

  // 获取所有收藏的工具ID
  List<String> getAllFavorites() {
    return _favorites.toList();
  }

  // 保存收藏列表到SharedPreferences
  Future<void> _saveFavorites() async {
    await _prefs.setStringList(_favoritesKey, _favorites.toList());
  }

  // 获取所有收藏的工具项
  static Future<List<MenuItem>> getFavoriteItems(BuildContext context) async {
    // 确保单例已初始化
    await _instance._ensureInitialized();
    
    // 从MenuData获取真实的工具项列表，并通过单例的收藏ID筛选
    final allItems = MenuData.getMenuItems(context);
    return allItems.where((item) => _instance.isFavorite(item.id)).toList();
  }
  
  // 保存收藏项的顺序
  static Future<void> saveFavoriteItems(List<MenuItem> items) async {
    // 清空当前收藏列表
    _instance._favorites.clear();
    
    // 添加新的收藏项ID
    final favoriteIds = items.map((item) => item.id).toList();
    _instance._favorites.addAll(favoriteIds);
    
    // 保存到SharedPreferences
    await _instance._saveFavorites();
  }
  
  // 生成测试菜单项
  static List<MenuItem> _generateTestItems() {
    return [
      MenuItem(
        id: 'time_screen',
        name: '时间屏幕',
        icon: Icons.schedule_outlined,
        categoryId: 'frequent',
        onTap: (context) {},
      ),
      MenuItem(
        id: 'marquee',
        name: '手持弹幕',
        icon: Icons.text_rotate_vertical,
        categoryId: 'frequent',
        onTap: (context) {},
      ),
      MenuItem(
        id: 'food_decision',
        name: '食物决策',
        icon: Icons.food_bank_outlined,
        categoryId: 'frequent',
        onTap: (context) {},
      ),
    ];
  }
}