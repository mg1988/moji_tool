import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';
import '../../components/image_tool_card.dart';
import '../../models/menu_item.dart';
import 'image_grid_cutter_page.dart';
import 'image_merger_page.dart';
import 'image_converter_page.dart';
import 'image_watermark_page.dart';
import 'image_dev_page.dart';
import 'image_resizer_page.dart';
import 'image_filter_page.dart';

class ImageToolsPage extends StatelessWidget {
  const ImageToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 图片工具子功能列表
    final List<MenuItem> imageTools = [
      MenuItem(
        id: 'image_grid_cutter',
        title: '九宫格切图',
        name: '九宫格切图',
        icon: Icons.grid_on,
        route: '/image_grid_cutter',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageGridCutterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_merger',
        title: '图片拼接',
        name: '图片拼接',
        icon: Icons.view_array,
        route: '/image_merger',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageMergerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_converter',
        title: '格式转换',
        name: '格式转换',
        icon: Icons.transform,
        route: '/image_converter',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageConverterPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_watermark',
        title: '图片水印',
        name: '图片水印',
        icon: Icons.water_drop,
        route: '/image_watermark',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageWatermarkPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_dev',
        title: '开发图生成',
        name: '开发图生成',
        icon: Icons.code,
        route: '/image_dev',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageDevPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_resizer',
        title: '修改尺寸',
        name: '修改尺寸',
        icon: Icons.photo_size_select_large,
        route: '/image_resizer',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageResizerPage(),
            ),
          );
        },
      ),
      MenuItem(
        id: 'image_filter',
        title: '图片滤镜',
        name: '图片滤镜',
        icon: Icons.filter,
        route: '/image_filter',
        categoryId: 'image',
        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImageFilterPage(),
            ),
          );
        },
      ),
    ];

    return BaseToolPage(
      title: '图片工具',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '提供丰富的图片处理功能，包括切图、拼接、格式转换等',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: imageTools.length,
                itemBuilder: (context, index) {
                  final tool = imageTools[index];
                  return ImageToolCard(
                    title: tool.name,
                    icon: tool.icon ?? Icons.image,
                    onTap: tool.onTap != null 
                        ? () => tool.onTap!(context) 
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}