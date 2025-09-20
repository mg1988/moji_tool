import 'package:flutter/material.dart';
import '../models/menu_category.dart';
import 'colors.dart';
import '../utils/favorite_manager.dart';

// 可折叠分类区域组件
class CollapsibleCategorySection extends StatefulWidget {
  final MenuCategory category;
  final List<MenuItem> items;
  final bool isExpanded;
  final ValueChanged<bool>? onToggle;
  final int itemsPerRow;

  const CollapsibleCategorySection({
    Key? key,
    required this.category,
    required this.items,
    required this.isExpanded,
    this.onToggle,
    this.itemsPerRow = 4,
  }) : super(key: key);

  @override
  State<CollapsibleCategorySection> createState() => _CollapsibleCategorySectionState();
}

class _CollapsibleCategorySectionState extends State<CollapsibleCategorySection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
          // 分类标题栏
          [Column(
            children: [
              GestureDetector(
                onTap: () => widget.onToggle?.call(!widget.isExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                      // 分类图标和名称
                      [Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.category.id == 'voice' ? Colors.blue.shade100 :
                         widget.category.id == 'text' ? Colors.green.shade100 :
                         widget.category.id == 'dev' ? Colors.purple.shade100 :
                         widget.category.id == 'convert' ? Colors.orange.shade100 :
                         widget.category.id == 'encode' ? Colors.red.shade100 :
                         widget.category.id == 'life' ? Colors.teal.shade100 :
                         Colors.grey.shade100,
                            ),
                            child: Icon(
                              widget.category.icon,
                              size: 14,
                              color: widget.category.id == 'voice' ? Colors.blue :
                         widget.category.id == 'text' ? Colors.green :
                         widget.category.id == 'dev' ? Colors.purple :
                         widget.category.id == 'convert' ? Colors.orange :
                         widget.category.id == 'encode' ? Colors.red :
                         widget.category.id == 'life' ? Colors.teal :
                         Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.category.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.items.length})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // 展开/收起图标
                      Icon(
                        widget.isExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              // 分类下边框
              Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          // 工具项列表
          if (widget.isExpanded) 
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.items.map((item) {
                  return ToolItemButton(
                    item: item,
                  );
                }).toList() as List<Widget>,
              ),
            ),
          ],
      ),
    );
  }
}

// 工具项按钮组件
class ToolItemButton extends StatefulWidget {
  final MenuItem item;

  const ToolItemButton({Key? key, required this.item}) : super(key: key);

  @override
  State<ToolItemButton> createState() => _ToolItemButtonState();
}

class _ToolItemButtonState extends State<ToolItemButton> {
  final FavoriteManager _favoriteManager = FavoriteManager();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // 检查工具项是否已收藏
  Future<void> _checkFavoriteStatus() async {
    await _favoriteManager.initialize();
    setState(() {
      _isFavorite = _favoriteManager.isFavorite(widget.item.id);
    });
  }

  // 显示收藏/取消收藏的弹出菜单
  void _showFavoriteMenu(BuildContext context, Offset globalPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect menuPosition = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: menuPosition,
      items: [
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(_isFavorite ? '取消收藏' : '添加收藏'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'favorite') {
        _toggleFavorite();
      }
    });
  }

  // 切换收藏状态
  Future<void> _toggleFavorite() async {
    await _favoriteManager.toggleFavorite(widget.item.id);
    setState(() {
      _isFavorite = _favoriteManager.isFavorite(widget.item.id);
    });
    
    // 显示提示信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? '已添加到收藏' : '已取消收藏',
          style: const TextStyle(fontSize: 12),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.item.onTap?.call(context),
      onLongPressStart: (details) => _showFavoriteMenu(context, details.globalPosition),
      onLongPress: () {}, // 必须添加空的onLongPress，否则onLongPressStart不会生效
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 左边图标
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.item.categoryId == 'voice' ? Colors.blue.shade100 :
                       widget.item.categoryId == 'text' ? Colors.green.shade100 :
                       widget.item.categoryId == 'dev' ? Colors.purple.shade100 :
                       widget.item.categoryId == 'convert' ? Colors.orange.shade100 :
                       widget.item.categoryId == 'encode' ? Colors.red.shade100 :
                       widget.item.categoryId == 'life' ? Colors.teal.shade100 :
                       Colors.grey.shade100,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    size: 14,
                    color: widget.item.categoryId == 'voice' ? Colors.blue :
                           widget.item.categoryId == 'text' ? Colors.green :
                           widget.item.categoryId == 'dev' ? Colors.purple :
                           widget.item.categoryId == 'convert' ? Colors.orange :
                           widget.item.categoryId == 'encode' ? Colors.red :
                           widget.item.categoryId == 'life' ? Colors.teal :
                           Colors.grey,
                  ),
                  // 收藏图标指示器
                  if (_isFavorite) 
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Icon(
                        Icons.star,
                        size: 10,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
            // 右边文字
            const SizedBox(width: 8),
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}