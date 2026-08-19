import 'package:flutter/material.dart';

import 'walkers_helpers.dart';

class WalkerDetailsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool selectable;

  const WalkerDetailsRow({
    super.key,
    required this.label,
    required this.value,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty
        ? 'Not available'
        : value;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: walkerDetailsTextGrey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          if (selectable)
            SelectableText(
              displayValue,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: walkerDetailsTextDark,
              ),
            )
          else
            Text(
              displayValue,
              softWrap: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: walkerDetailsTextDark,
              ),
            ),
        ],
      ),
    );
  }
}
