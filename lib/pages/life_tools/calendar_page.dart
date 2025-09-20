import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  final TextEditingController _eventController = TextEditingController();
  Map<DateTime, List<String>> _eventMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime.now();
    // 初始化一些示例事件
    _addSampleEvents();
  }

  void _addSampleEvents() {
    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime dayAfterTomorrow = today.add(const Duration(days: 2));

    _eventMap[today] = ['今天的会议', '购物清单'];
    _eventMap[tomorrow] = ['约会', '看电影'];
    _eventMap[dayAfterTomorrow] = ['健身', '学习Flutter'];
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final int year = month.year;
    final int monthValue = month.month;
    final int daysInMonth = DateTime(year, monthValue + 1, 0).day;
    final int firstDayWeekday = DateTime(year, monthValue, 1).weekday;

    final List<DateTime> days = [];
    
    // 添加上个月的填充日期
    for (int i = firstDayWeekday - 1; i > 0; i--) {
      days.add(DateTime(year, monthValue, 1).subtract(Duration(days: i)));
    }

    // 添加当前月的日期
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, monthValue, i));
    }

    // 添加下个月的填充日期，直到填充满6行
    final int remainingDays = 42 - days.length; // 6行 × 7天 = 42
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(year, monthValue, daysInMonth).add(Duration(days: i)));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _addEvent() {
    if (_eventController.text.isNotEmpty) {
      setState(() {
        final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        if (_eventMap.containsKey(key)) {
          _eventMap[key]?.add(_eventController.text);
        } else {
          _eventMap[key] = [_eventController.text];
        }
        _eventController.clear();
      });
    }
  }

  void _deleteEvent(int index) {
    final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    setState(() {
      if (_eventMap.containsKey(key)) {
        _eventMap[key]?.removeAt(index);
        if (_eventMap[key]?.isEmpty ?? false) {
          _eventMap.remove(key);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _generateDaysInMonth(_currentMonth);
    final dayNames = ['日', '一', '二', '三', '四', '五', '六'];

    return BaseToolPage(
      title: '日历',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 月份选择器
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_currentMonth.year}年${_currentMonth.month}月',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ),

            // 星期标题
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: dayNames.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    dayNames[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),

            // 日历网格
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                final date = daysInMonth[index];
                final isCurrentMonth = date.month == _currentMonth.month;
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final hasEvent = _eventMap.containsKey(
                    DateTime(date.year, date.month, date.day));

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.teal.shade100
                          : isToday
                              ? Colors.blue.shade50
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: isSelected
                          ? Border.all(color: Colors.teal, width: 2.0)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isCurrentMonth
                                ? (isSelected ? Colors.teal : Colors.black)
                                : Colors.grey,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasEvent)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 选中日期的事件
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eventController,
                      decoration: InputDecoration(
                        labelText: '添加事件',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addEvent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '今日事件:',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    _buildEventList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final events = _eventMap[key];

    if (events == null || events.isEmpty) {
      return const Text('无事件');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(events[index]),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteEvent(index),
            color: Colors.red,
          ),
        );
      },
    );
  }
}