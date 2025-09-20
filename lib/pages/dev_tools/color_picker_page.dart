import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';
import '../../components/tool_card.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({Key? key}) : super(key: key);

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  Color _selectedColor = Colors.blue;
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _rgbController = TextEditingController();
  final TextEditingController _hslController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateColorValues();
  }

  void _updateColorValues({bool updateHex = true, bool updateRgb = true, bool updateHsl = true}) {
    if (updateHex) {
      // 更新HEX值，包含透明度
      _hexController.text = '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}';
    }
    
    if (updateRgb) {
      // 更新RGBA值
      _rgbController.text = 'rgba(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}, ${(_selectedColor.alpha / 255).toStringAsFixed(2)})';
    }
    
    if (updateHsl) {
      // 更新HSLA值
      HSLColor hslColor = HSLColor.fromColor(_selectedColor);
      _hslController.text = 'hsla(${hslColor.hue.round()}°, ${(hslColor.saturation * 100).round()}%, ${(hslColor.lightness * 100).round()}%, ${(_selectedColor.alpha / 255).toStringAsFixed(2)})';
    }
  }

  Color? _parseHexColor(String hexString) {
    try {
      hexString = hexString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF' + hexString;
      } else if (hexString.length != 8) {
        return null;
      }
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Color? _parseRgbaColor(String rgbaString) {
    try {
      final regex = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)');
      final match = regex.firstMatch(rgbaString);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final a = match.group(4) != null 
          ? (double.parse(match.group(4)!) * 255).round() 
          : 255;
        return Color.fromARGB(a, r, g, b);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '颜色选择器',
      child: ListView(
        children: [
          // 颜色预览卡片
          ToolCard(
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                // 颜色滑块
                Column(
                  children: [
                    _buildColorSlider('透明', Colors.grey, _selectedColor.alpha),
                    _buildColorSlider('红', Colors.red, _selectedColor.red),
                    _buildColorSlider('绿', Colors.green, _selectedColor.green),
                    _buildColorSlider('蓝', Colors.blue, _selectedColor.blue),
                  ],
                ),
              ],
            ),
          ),

          // 颜色值卡片
          ToolCard(
            child: Column(
              children: [
                _buildColorValueField('HEX', _hexController),
                const Divider(height: 24),
                _buildColorValueField('RGB', _rgbController),
                const Divider(height: 24),
                _buildColorValueField('HSL', _hslController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider(String label, Color color, int value) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            activeColor: color,
            onChanged: (double value) {
              setState(() {
                if (label == '透明') {
                  _selectedColor = _selectedColor.withAlpha(value.round());
                } else {
                  _selectedColor = Color.fromARGB(
                    _selectedColor.alpha,
                    label == '红' ? value.round() : _selectedColor.red,
                    label == '绿' ? value.round() : _selectedColor.green,
                    label == '蓝' ? value.round() : _selectedColor.blue,
                  );
                }
                _updateColorValues();
              });
            },
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toString()),
        ),
      ],
    );
  }

  Widget _buildColorValueField(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: false,
            onChanged: (value) {
              Color? newColor;
              if (label == 'HEX') {
                newColor = _parseHexColor(value);
              } else if (label == 'RGB') {
                newColor = _parseRgbaColor(value);
              }
              
              if (newColor != null) {
                setState(() {
                  _selectedColor = newColor!;
                  _updateColorValues(
                    updateHex: label != 'HEX',
                    updateRgb: label != 'RGB',
                    updateHsl: true,
                  );
                });
              }
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(controller.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _hexController.dispose();
    _rgbController.dispose();
    _hslController.dispose();
    super.dispose();
  }
}
