import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryManager {
  static const String _key = 'search_history';
  static const int _maxHistoryItems = 10;

  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    
    // 移除已存在的相同搜索词
    history.remove(term);
    // 添加到开头
    history.insert(0, term);
    
    // 保持历史记录不超过最大数量
    if (history.length > _maxHistoryItems) {
      history.removeLast();
    }
    
    await prefs.setStringList(_key, history);
  }

  static Future<void> removeSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    history.remove(term);
    await prefs.setStringList(_key, history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
