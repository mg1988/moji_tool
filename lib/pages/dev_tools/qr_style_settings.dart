import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../components/tool_card.dart';

class QRStyleSettings extends StatelessWidget {
  final Color qrColor;
  final Color backgroundColor;
  final bool hasLogo;
  final QrDataModuleShape dataModuleShape;
  final double eyeRadius;
  final QrEyeShape eyeShape;
  final Function({
    Color? qrColor,
    Color? backgroundColor,
    QrDataModuleShape? dataModuleShape,
    double? eyeRadius,
    QrEyeShape? eyeShape,
  }) onStyleChanged;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  const QRStyleSettings({
    Key? key,
    required this.qrColor,
    required this.backgroundColor,
    required this.hasLogo,
    required this.dataModuleShape,
    required this.eyeRadius,
    required this.eyeShape,
    required this.onStyleChanged,
    required this.onPickLogo,
    required this.onRemoveLogo,
  }) : super(key: key);

  Widget _buildColorPicker({
    required BuildContext context,
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 16),
        InkWell(
          onTap: () async {
            final Color? newColor = await showDialog<Color>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(label),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: color,
                      onColorChanged: onColorChanged,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('确定'),
                    ),
                  ],
                );
              },
            );
            if (newColor != null) {
              onColorChanged(newColor);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '样式设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            context: context,
            label: '二维码颜色',
            color: qrColor,
            onColorChanged: (color) => onStyleChanged(qrColor: color),
          ),
          const SizedBox(height: 12),
          _buildColorPicker(
            context: context,
            label: '背景颜色',
            color: backgroundColor,
            onColorChanged: (color) => onStyleChanged(backgroundColor: color),
          ),
          const SizedBox(height: 16),
          _buildShapeSettings(context),
          const SizedBox(height: 16),
          _buildLogoSettings(),
        ],
      ),
    );
  }

  Widget _buildShapeSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('二维码样式'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('方形'),
              selected: dataModuleShape == QrDataModuleShape.square,
              onSelected: (bool selected) {
                if (selected) {
                  onStyleChanged(dataModuleShape: QrDataModuleShape.square);
                }
              },
            ),
            ChoiceChip(
              label: const Text('圆形'),
              selected: dataModuleShape == QrDataModuleShape.circle,
              onSelected: (bool selected) {
                if (selected) {
                  onStyleChanged(dataModuleShape: QrDataModuleShape.circle);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('定位点样式'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('方形'),
              selected: eyeShape == QrEyeShape.square,
              onSelected: (bool selected) {
                if (selected) {
                  onStyleChanged(eyeShape: QrEyeShape.square);
                }
              },
            ),
            ChoiceChip(
              label: const Text('圆形'),
              selected: eyeShape == QrEyeShape.circle,
              onSelected: (bool selected) {
                if (selected) {
                  onStyleChanged(eyeShape: QrEyeShape.circle);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo设置'),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: hasLogo ? onRemoveLogo : onPickLogo,
              icon: Icon(hasLogo ? Icons.delete : Icons.add_photo_alternate),
              label: Text(hasLogo ? '移除Logo' : '添加Logo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasLogo ? Colors.red : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
