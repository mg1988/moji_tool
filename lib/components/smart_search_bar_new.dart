import 'package:flutter/material.dart';
import '../utils/search_history_manager.dart';

class SmartSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final List<String> suggestions;

  const SmartSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.suggestions = const [],
  });

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  bool _showSuggestions = false;
  List<String> _searchHistory = [];
  List<String> _filteredSuggestions = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    widget.controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _loadSearchHistory() async {
    final history = await SearchHistoryManager.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _onSearchChanged() {
    final query = widget.controller.text;
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
      return;
    }

    final suggestions = [
      ...widget.suggestions,
      ..._searchHistory,
    ].where((suggestion) =>
      suggestion.toLowerCase().contains(query.toLowerCase())
    ).toList();

    setState(() {
      _showSuggestions = _focusNode.hasFocus;
      _filteredSuggestions = suggestions.toSet().toList();
    });
  }

  void _onSuggestionSelected(String suggestion) {
    widget.controller.text = suggestion;
    widget.onSearch(suggestion);
    SearchHistoryManager.addSearchTerm(suggestion);
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onSearch,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
              height: 1.0, // 设置行高为1.0以确保垂直居中
            ),
            textAlignVertical: TextAlignVertical.center, // 添加垂直居中对齐
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                SearchHistoryManager.addSearchTerm(value);
                _focusNode.unfocus();
              }
            },
            decoration: InputDecoration(
              hintText: '搜索工具',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear();
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, size: 18),
                  title: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _onSuggestionSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
