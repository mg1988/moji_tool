
import 'package:flutter/material.dart';

class MenuItem {
    final String id;
    final String title;
    final String name; // 用于与MenuData中的name保持一致
    final String? iconPath;
    final String route;
    final IconData? icon;
    final String? categoryId;
    final void Function(BuildContext)? onTap;

    MenuItem({
      required this.id,
      required this.title,
      required this.name,
      this.iconPath,
      required this.route,
      this.icon,
      this.categoryId,
      this.onTap,
    });
    static List<MenuItem> get items => [
         MenuItem(
        id: 'history',
        title: '历史记录',
        name: '历史记录',
        icon: Icons.history,
        route: '/history',
      ),
      MenuItem(
        id: 'home',
        title: '首页',
        name: '首页',
        icon: Icons.home,
        route: '/home',
      ),
   
      MenuItem(
        id: 'settings',
        title: '设置',
        name: '设置',
        icon: Icons.settings,
        route: '/settings',
      ),
    ];
  }