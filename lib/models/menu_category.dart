import 'package:flutter/material.dart';

class MenuCategory {
  final String id;
  final String name;
  final IconData icon;
  
  const MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class MenuItem {
  final String id;
  final String name;
  final IconData icon;
  final String categoryId;
  final Function(BuildContext context) onTap;

  const MenuItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
    required this.onTap,
  });
}