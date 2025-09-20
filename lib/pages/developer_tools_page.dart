import 'package:flutter/material.dart';
import 'dev_tools/json_formatter_page.dart';

class DeveloperToolsPage extends StatelessWidget {
  const DeveloperToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发者工具'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('JSON格式化'),
              subtitle: const Text('格式化和验证JSON数据'),
              leading: const Icon(Icons.code),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JsonFormatterPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
