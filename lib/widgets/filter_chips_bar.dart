import 'package:flutter/material.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final String selected;
  final Map<String, int> counts; // 'All','New','Contacted','Converted'
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'New', 'Contacted', 'Converted'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: filters.map((f) {
          final count = counts[f] ?? 0;
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$f ($count)'),
              selected: isSelected,
              onSelected: (_) => onSelected(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}
