import 'package:flutter/material.dart';

class WalkerToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onClearSearch;

  const WalkerToolbar({
    super.key,
    required this.searchController,
    this.selectedStatus = 'All',
    required this.onStatusChanged,
    this.onSearchChanged,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search walkers...',
            prefixIcon: const Icon(
              Icons.search_rounded,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged?.call('');
                      onClearSearch?.call();
                    },
                    icon: const Icon(
                      Icons.clear_rounded,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(14),
              ),
              borderSide: BorderSide(
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
            children: [
              _FilterButton(
                label: 'All',
                selected: selectedStatus == 'All',
                onTap: () => onStatusChanged('All'),
              ),
              const SizedBox(width: 8),
              _FilterButton(
                label: 'Pending',
                selected: selectedStatus == 'Pending',
                onTap: () => onStatusChanged('Pending'),
              ),
              const SizedBox(width: 8),
              _FilterButton(
                label: 'Approved',
                selected: selectedStatus == 'Approved',
                onTap: () => onStatusChanged('Approved'),
              ),
              const SizedBox(width: 8),
              _FilterButton(
                label: 'Rejected',
                selected: selectedStatus == 'Rejected',
                onTap: () => onStatusChanged('Rejected'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF6600)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF6600)
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
