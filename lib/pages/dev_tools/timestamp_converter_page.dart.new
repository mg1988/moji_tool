import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/base_tool_page.dart';

class TimestampConverterPage extends StatefulWidget {
  const TimestampConverterPage({Key? key}) : super(key: key);

  @override
  State<TimestampConverterPage> createState() => _TimestampConverterPageState();
}

class _TimestampConverterPageState extends State<TimestampConverterPage> {
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _updateWithCurrentTime();
  }

  void _updateWithCurrentTime() {
    _selectedDateTime = DateTime.now();
    _updateAllFields();
  }

  void _updateAllFields() {
    if (_selectedDateTime != null) {
      // 更新毫秒时间戳
      _timestampController.text = _selectedDateTime!.millisecondsSinceEpoch.toString();
      
      // 更新日期时间字符串
      _dateTimeController.text = _formatDateTime(_selectedDateTime!);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}.'
        '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  void _convertFromTimestamp(String timestamp) {
    try {
      int milliseconds;
      // 如果长度大于10，认为是毫秒级时间戳，否则认为是秒级时间戳
      if (timestamp.length > 10) {
        milliseconds = int.parse(timestamp);
      } else {
        milliseconds = int.parse(timestamp) * 1000;
      }
      _selectedDateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      _dateTimeController.text = _formatDateTime(_selectedDateTime!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无效的时间戳')),
      );
    }
  }

  void _convertFromDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr.replaceAll(' ', 'T'));
      _selectedDateTime = dateTime;
      _timestampController.text = dateTime.millisecondsSinceEpoch.toString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无效的日期时间格式')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updateAllFields();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseToolPage(
      title: '时间戳转换',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _updateWithCurrentTime();
            });
          },
          tooltip: '使用当前时间',
        ),
      ],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                label: '时间戳',
                controller: _timestampController,
                onChanged: _convertFromTimestamp,
                keyboardType: TextInputType.number,
                helperText: '支持秒级或毫秒级时间戳',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: '日期时间',
                      controller: _dateTimeController,
                      onChanged: _convertFromDateTime,
                      helperText: '精确到毫秒',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDateTime,
                    tooltip: '选择日期时间',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_selectedDateTime != null) ...[
                _buildInfoCard('UTC时间', '${_selectedDateTime!.toUtc()}'),
                const SizedBox(height: 8),
                _buildInfoCard('本地时区', '${_selectedDateTime!.timeZoneName} (UTC${_selectedDateTime!.timeZoneOffset.isNegative ? '' : '+'}${_selectedDateTime!.timeZoneOffset.inHours}:${(_selectedDateTime!.timeZoneOffset.inMinutes % 60).toString().padLeft(2, '0')})'),
                const SizedBox(height: 8),
                _buildInfoCard('Unix时间戳（秒）', '${_selectedDateTime!.millisecondsSinceEpoch ~/ 1000}'),
                const SizedBox(height: 8),
                _buildInfoCard('Unix时间戳（毫秒）', '${_selectedDateTime!.millisecondsSinceEpoch}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(controller.text),
          tooltip: '复制',
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _copyToClipboard(value),
          tooltip: '复制',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timestampController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }
}
