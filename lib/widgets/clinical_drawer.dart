import 'package:flutter/material.dart';

class ClinicalDrawer extends StatefulWidget {
  final String title;
  final List<String> predefinedItems;
  final Function(List<ClinicalItem>) onItemsSelected;

  const ClinicalDrawer({
    Key? key,
    required this.title,
    required this.predefinedItems,
    required this.onItemsSelected,
  }) : super(key: key);

  @override
  State<ClinicalDrawer> createState() => _ClinicalDrawerState();
}

class _ClinicalDrawerState extends State<ClinicalDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  List<String> _filteredItems = [];
  List<ClinicalItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.predefinedItems;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.predefinedItems;
      } else {
        _filteredItems = widget.predefinedItems
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addItem(String name) {
    setState(() {
      _selectedItems.add(ClinicalItem(
        name: name,
        value: '',
        forField: '',
        duration: 'Day',
        note: '',
      ));
    });
  }

  void _addCustomItem() {
    if (_customController.text.isNotEmpty) {
      _addItem(_customController.text);
      _customController.clear();
    }
  }

  void _updateItem(int index, ClinicalItem item) {
    setState(() {
      _selectedItems[index] = item;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _done() {
    widget.onItemsSelected(_selectedItems);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFE3001),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'ProductSans',
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _done,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFE3001),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Done'),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Predefined Items (Tags)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredItems.map((item) {
                return InkWell(
                  onTap: () => _addItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Custom Add
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    decoration: InputDecoration(
                      hintText: 'Type custom item...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addCustomItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE3001),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          // Selected Items Table
          if (_selectedItems.isNotEmpty) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Items',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedItems.asMap().entries.map((entry) {
                      return _buildItemRow(entry.key, entry.value);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildItemRow(int index, ClinicalItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _deleteItem(index),
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    _updateItem(index, item.copyWith(value: value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'For',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    _updateItem(index, item.copyWith(forField: value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: item.duration,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  items: ['Day', 'Week', 'Month', 'Year'].map((duration) {
                    return DropdownMenuItem(value: duration, child: Text(duration));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updateItem(index, item.copyWith(duration: value));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(8),
            ),
            maxLines: 2,
            onChanged: (value) {
              _updateItem(index, item.copyWith(note: value));
            },
          ),
        ],
      ),
    );
  }
}

class ClinicalItem {
  final String name;
  final String value;
  final String forField;
  final String duration;
  final String note;

  ClinicalItem({
    required this.name,
    required this.value,
    required this.forField,
    required this.duration,
    required this.note,
  });

  ClinicalItem copyWith({
    String? name,
    String? value,
    String? forField,
    String? duration,
    String? note,
  }) {
    return ClinicalItem(
      name: name ?? this.name,
      value: value ?? this.value,
      forField: forField ?? this.forField,
      duration: duration ?? this.duration,
      note: note ?? this.note,
    );
  }

  String toFormattedString() {
    List<String> parts = [name];
    if (value.isNotEmpty) parts.add(value);
    if (forField.isNotEmpty) parts.add('for $forField');
    if (duration.isNotEmpty && forField.isNotEmpty) parts.add(duration);
    if (note.isNotEmpty) parts.add('($note)');
    return parts.join(' ');
  }
}
