import 'package:flutter/material.dart';
import 'package:voice_to_text_app/components/colors.dart';
import 'package:voice_to_text_app/models/menu_category.dart';
import 'package:voice_to_text_app/utils/favorite_manager.dart';

// 收藏页面
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<MenuItem> _favoriteItems = [];
  int _currentCarouselIndex = 0;
  bool isEdit = false;
  // 轮播图数据
  final List<String> _carouselImages = [
    'images/banner1.png',
    'images/banner2.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
    
    // 设置收藏状态变化的回调，当收藏状态改变时刷新数据
    FavoriteManager.setOnFavoritesChangedCallback(() {
      _loadFavoriteItems();
    });
  }
  
  @override
  void dispose() {
    // 移除回调，避免内存泄漏
    FavoriteManager.setOnFavoritesChangedCallback(() {});
    super.dispose();
  }

  // 加载收藏的工具项
  Future<void> _loadFavoriteItems() async {
    final items = await FavoriteManager.getFavoriteItems(context);
    setState(() {
      // 直接使用真实的收藏数据，不使用测试数据
      _favoriteItems = items;
    });
  }

  // 取消收藏
  Future<void> _removeFromFavorites(String itemId) async {
    await FavoriteManager.instance.removeFromFavorite(itemId);
    _loadFavoriteItems();
  }

  // 重新排序收藏项
  Future<void> _reorderFavorites(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = _favoriteItems.removeAt(oldIndex);
    _favoriteItems.insert(newIndex, item);
    
    // 更新排序到存储
    await FavoriteManager.saveFavoriteItems(_favoriteItems);
    
    setState(() {});
  }

  // 构建轮播图组件
  Widget _buildCarousel() {
    return Container(
      height: 140,
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
          children:
            [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (_favoriteItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                // 编辑模式（如果需要）
                setState(() {
                  isEdit = !isEdit;
                });
              },
              tooltip: '编辑收藏',
            ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // 顶部轮播图
            SliverToBoxAdapter(
              child: _buildCarousel(),
            ),
            
            // 收藏列表
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: _favoriteItems.isNotEmpty 
                ? // 有收藏项时显示可拖拽列表
                  SliverReorderableList(
                    itemBuilder: (context, index) {
                      final item = _favoriteItems[index];
                      return Card(
                        key: Key(item.id),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                // 点击工具项执行操作
                                item.onTap.call(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // 拖动手柄
                                        if(isEdit)
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.drag_handle,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ),
                                        // 图标
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            item.icon,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 名称
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // 操作按钮
                                    if(isEdit)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                        ),
                                        onPressed: () {
                                          _removeFromFavorites(item.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('已取消收藏${item.name}')),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _favoriteItems.length,
                    onReorder: (oldIndex, newIndex) {
                      _reorderFavorites(oldIndex, newIndex);
                    },
                  )
                : // 空状态显示
                  SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border, size: 50, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text('还没有收藏的工具', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text('在首页长按工具项添加到收藏', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
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