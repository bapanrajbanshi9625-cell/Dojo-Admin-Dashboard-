import 'package:flutter/material.dart';

import 'walk_request_stat_box.dart';

class WalkRequestsTopSection extends StatelessWidget {
  final int pendingCount;
  final int acceptedCount;
  final int cancelledCount;

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const WalkRequestsTopSection({
    super.key,
    required this.pendingCount,
    required this.acceptedCount,
    required this.cancelledCount,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.searchController,
    required this.onSearchChanged,
  });

  static const List<String> filters = [
    'All',
    'Pending',
    'Accepted',
    'Active',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),
      child: Column(
        children: [
          // ====================================================
          // STATISTICS
          // ====================================================

          Row(
            children: [
              Expanded(
                child: WalkRequestStatBox(
                  title: 'Pending',
                  value: pendingCount.toString(),
                  icon: Icons.pending_actions,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: WalkRequestStatBox(
                  title: 'Accepted',
                  value: acceptedCount.toString(),
                  icon: Icons.check_circle_outline,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: WalkRequestStatBox(
                  title: 'Cancelled',
                  value: cancelledCount.toString(),
                  icon: Icons.cancel_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ====================================================
          // SEARCH
          // ====================================================

          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText:
                  'Search owner, request ID, walker...',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        ),
              filled: true,
              fillColor:
                  Theme.of(context)
                      .colorScheme
                      .surface,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      Theme.of(context)
                          .dividerColor,
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      Theme.of(context)
                          .dividerColor,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // FILTERS
          // ====================================================

          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map(
                  (filter) {
                    final selected =
                        selectedFilter == filter;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) {
                          onFilterChanged(filter);
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
