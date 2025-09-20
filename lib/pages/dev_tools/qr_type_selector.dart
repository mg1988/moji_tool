import 'package:flutter/material.dart';
import '../../components/tool_card.dart';

class QRTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const QRTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '二维码类型',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(context, 'text', '文本', Icons.text_fields),
              _buildTypeChip(context, 'website', '网址', Icons.link),
              _buildTypeChip(context, 'vcard', '名片', Icons.contact_page),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, String label, IconData icon) {
    final isSelected = selectedType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          onTypeChanged(type);
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }
}
