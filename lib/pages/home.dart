import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/collapsible_category_section.dart';
import '../components/smart_search_bar.dart';
import '../data/menu_data.dart';
import '../models/menu_category.dart';
import '../pages/qr_scanner_page.dart';
// 图标现在直接使用Icons类，不需要IconHelper
import 'package:flutter/services.dart';

// 语音转文字主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _HomePageState extends State<HomePage> {
  // 展开的分类ID列表
  final Map<String, bool> _expandedCategories = {};
  
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  
  // 搜索关键词
  String _searchKeyword = '';
  
  // 菜单项列表
  late List<MenuItem> _menuItems = [];
  
  // 数据加载状态
  bool _isLoading = false;
  
  // 搜索建议列表
  List<String> get _searchSuggestions => _menuItems
      .map((item) => item.name)
      .toList();
  
  // 轮播图当前索引
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // 移除启动时的重量级初始化，改为市面渲染后再加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 优化懒加载菜单项数据
      _loadMenuItemsOptimized();
    });
    _initializeSearch();
    
    // 初始化所有分类为展开状态
    for (var category in MenuData.categories) {
      _expandedCategories[category.id] = true;
    }
  }
  
  // 优化懒加载菜单项数据
  void _loadMenuItemsOptimized() {
    setState(() {
      _isLoading = true;
    });
    
    // 分批异步加载数据，提升响应速度
    _loadMenuItemsBatch();
  }
  
  Future<void> _loadMenuItemsBatch() async {
    try {
      // 第一批：优先加载常用工具
      final frequentItems = MenuData.getMenuItems(context)
          .where((item) => item.categoryId == 'frequent')
          .take(5) // 只加载前5个
          .toList();
      
      if (mounted) {
        setState(() {
          _menuItems = frequentItems;
          _isLoading = false;
        });
      }
      
      // 第二批：延迟加载其余工具
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        final allItems = MenuData.getMenuItems(context);
        setState(() {
          _menuItems = allItems;
        });
      }
    } catch (e) {
      print('加载菜单项失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _initializeSearch() {
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 根据分类过滤菜单项
  List<MenuItem> _getItemsByCategory(String categoryId) {
    return _menuItems.where((item) => item.categoryId == categoryId).toList();
  }
  
  // 切换分类展开/收起状态
  void _toggleCategory(String categoryId) {
    setState(() {
      _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    });
  }

  // 轮播图数据
  final List<String> _carouselImages = [
    'images/banner1.png',
    'images/banner3.png',
    'images/banner4.png',
    'images/banner2.png',
  ];
  void _navigateToNative(String methName, Map<String, dynamic> args) async {
    const platform = MethodChannel('com.mg.voice/native');
    try {
      var result = await platform.invokeMethod(methName, args);
      //弹窗提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString())),
      );
    } on PlatformException catch (e) {
      print("Failed to navigate: ${e.message}");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('默记工具箱'),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.pageTitle.copyWith(
          color: AppColors.primary,
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // 顶部轮播区
            SliverToBoxAdapter(
              child: _buildCarousel(),
            ),
            
            // 搜索栏
            SliverToBoxAdapter(
              child: SmartSearchBar(
                controller: _searchController,
                suggestions: _searchSuggestions,
                onSearch: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchKeyword = '';
                  });
                },
              ),
            ),
            
            // 数据加载状态显示
            _isLoading && _menuItems.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : // 功能区 - 可折叠分类布局
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_searchKeyword.isEmpty) {
                            // 显示分类列表
                            final category = MenuData.categories[index];
                            final items = _getItemsByCategory(category.id);
                            return CollapsibleCategorySection(
                              category: category,
                              items: items,
                              isExpanded: _expandedCategories[category.id] ?? true,
                              onToggle: (isExpanded) {
                                _toggleCategory(category.id);
                              },
                            );
                          } else {
                            // 搜索结果
                            if (index == 0) {
                              // 搜索结果标题
                              final searchResults = _menuItems.where((item) {
                                final searchTerms = _searchKeyword.toLowerCase().split(' ');
                                final itemText = '${item.name.toLowerCase()} ${item.categoryId.toLowerCase()}';
                                return searchTerms.every((term) => itemText.contains(term));
                              }).toList();
                               
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      '搜索结果 (${searchResults.length})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  // 搜索结果列表
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: searchResults.map((item) {
                                        return ToolItemButton(
                                          item: item,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return null;
                          }
                        },
                        childCount: _searchKeyword.isEmpty ? MenuData.categories.length : 1,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // 构建工具卡片 - 备用方法，目前未使用

  // 构建轮播图 - 优化样式
  Widget _buildCarousel() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 轮播图片
            Positioned.fill(
              child: PageView.builder(
                  itemCount: _carouselImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _carouselImages[index],
                      fit: BoxFit.cover,
                    );
                  }),
            ),

            // 轮播指示器
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _carouselImages.length,
                  (index) => Container(
                    width: index == _currentCarouselIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: index == _currentCarouselIndex ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: index == _currentCarouselIndex ? BorderRadius.circular(4) : null,
                      color: index == _currentCarouselIndex
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
