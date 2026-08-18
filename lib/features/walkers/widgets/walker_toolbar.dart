import 'package:flutter/material.dart';

class WalkerToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String?> onFilterChanged;

  const WalkerToolbar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.onStatusChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = <String>[
      'All',
      'Online',
      'Pending',
      'Approved',
      'Rejected',
      'Offline',
    ];

    final safeFilter =
        filters.contains(selectedFilter) ? selectedFilter : 'All';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final searchField = TextField(
            controller: searchController,
            onChanged: onStatusChanged,
            decoration: InputDecoration(
              hintText: 'Search walkers...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF6B7280),
              ),
              suffixIcon:
                  ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      onStatusChanged('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  );
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
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
          );

          final filterField =
              DropdownButtonFormField<String>(
            value: safeFilter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(
                Icons.filter_list_rounded,
                color: Color(0xFF6B7280),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            items: filters
                .map(
                  (filter) => DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  ),
                )
                .toList(),
            onChanged: onFilterChanged,
          );

          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                searchField,
                const SizedBox(height: 12),
                filterField,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: filterField,
              ),
            ],
          );
        },
      ),
    );
  }
}
