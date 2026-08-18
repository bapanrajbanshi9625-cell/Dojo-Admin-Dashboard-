import 'package:flutter/material.dart';

class WalkersToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback? onClearSearch;

  const WalkersToolbar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onClearSearch,
  });

  static const List<String> filters = <String>[
    'All',
    'Online',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: (_) {
            // Parent listens to controller changes through
            // its own listener / rebuild mechanism.
          },
          decoration: InputDecoration(
            hintText: 'Search walkers...',
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF6B7280),
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      onClearSearch?.call();
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF6600),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final selected = selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) {
                    onFilterChanged(filter);
                  },
                  selectedColor: const Color(0xFFFF6600),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFFF6600)
                        : const Color(0xFFE5E7EB),
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF374151),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
