import 'package:flutter/material.dart';
import '../helpers/admin_colors.dart';

class AdminsToolbar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const AdminsToolbar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          _button('All'),
          _button('Active'),
          _button('Inactive'),
        ],
      ),
    );
  }

  Widget _button(String title) {
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onFilterChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : dojoBlack,
          ),
        ),
      ),
    );
  }
}
