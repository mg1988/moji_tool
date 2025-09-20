import 'package:flutter/material.dart';
import '../../components/base_tool_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class TodoItem {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final int priority;

  TodoItem({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 0,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoItem> _todoItems = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedPriority = 0;
  String _filter = 'all'; // 'all', 'completed', 'pending'

  @override
  void initState() {
    super.initState();
    // 初始化一些示例待办事项
    _addSampleTodos();
  }

  void _addSampleTodos() {
    _todoItems = [
      TodoItem(
        id: '1',
        title: '完成项目文档',
        description: '编写项目的API文档和使用说明',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        priority: 1,
      ),
      TodoItem(
        id: '2',
        title: '购物清单',
        description: '购买牛奶、面包和水果',
        dueDate: DateTime.now(),
        isCompleted: true,
        priority: 0,
      ),
      TodoItem(
        id: '3',
        title: '健身',
        description: '去健身房锻炼1小时',
        dueDate: DateTime.now().add(const Duration(hours: 3)),
        isCompleted: false,
        priority: 2,
      ),
    ];
  }

  void _addTodoItem() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          dueDate: _selectedDate,
          isCompleted: false,
          priority: _selectedPriority,
        ));
        // 清空表单
        _titleController.clear();
        _descriptionController.clear();
        _selectedDate = DateTime.now();
        _selectedPriority = 0;
      });
    }
  }

  void _toggleTodoStatus(String id) {
    setState(() {
      _todoItems = _todoItems.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();
    });
  }

  void _deleteTodoItem(String id) {
    setState(() {
      _todoItems = _todoItems.where((todo) => todo.id != id).toList();
    });
  }

  void _editTodoItem(TodoItem todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
    _selectedDate = todo.dueDate;
    _selectedPriority = todo.priority;

    // 删除原待办事项，准备添加修改后的版本
    _deleteTodoItem(todo.id);
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<TodoItem> _getFilteredTodos() {
    switch (_filter) {
      case 'completed':
        return _todoItems.where((todo) => todo.isCompleted).toList();
      case 'pending':
        return _todoItems.where((todo) => !todo.isCompleted).toList();
      default:
        return _todoItems;
    }
  }

  Widget _buildPriorityIndicator(int priority) {
    Color color;
    switch (priority) {
      case 1:
        color = Colors.orange;
        break;
      case 2:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _getFilteredTodos();

    return BaseToolPage(
      title: '待办事项',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 添加待办事项表单
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('添加新待办事项', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: '标题'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: '描述（可选）'),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _showDatePicker,
                            child: Text(
                              '截止日期: ${_selectedDate.toString().split(' ')[0]}',
                            ),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedPriority,
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('低优先级'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('中优先级'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('高优先级'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value ?? 0;
                              });
                            },
                            decoration: const InputDecoration(labelText: '优先级'),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _addTodoItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade100,
                      ),
                      child: const Text('添加待办'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 筛选器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text('全部'),
                  selected: _filter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'all';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('已完成'),
                  selected: _filter == 'completed',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'completed';
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('未完成'),
                  selected: _filter == 'pending',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'pending';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 待办事项列表
            filteredTodos.isEmpty
                ? const Center(child: Text('暂无待办事项'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: todo.isCompleted,
                                onChanged: (bool? value) {
                                  _toggleTodoStatus(todo.id);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildPriorityIndicator(todo.priority),
                                        const SizedBox(width: 4),
                                        Text(
                                          todo.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: todo.isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: todo.isCompleted ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (todo.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        todo.description!, 
                                        style: TextStyle(
                                          color: todo.isCompleted ? Colors.grey : Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '截止日期: ${todo.dueDate.toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('编辑'),
                                    onTap: () {
                                      _editTodoItem(todo);
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const Text('删除'),
                                    onTap: () {
                                      _deleteTodoItem(todo.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}