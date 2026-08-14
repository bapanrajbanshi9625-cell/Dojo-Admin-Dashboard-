import 'package:flutter/material.dart';
import '../helpers/admin_colors.dart';

class AdminsSummary extends StatelessWidget {
  final int total;
  final int active;
  final int inactive;

  const AdminsSummary({
    super.key,
    required this.total,
    required this.active,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 550
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.4,
          children: [
            _SummaryCard(
              title: 'Total Admins',
              value: total.toString(),
              icon: Icons.admin_panel_settings_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Active Admins',
              value: active.toString(),
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Inactive Admins',
              value: inactive.toString(),
              icon: Icons.person_off_outlined,
              color: dojoRed,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: dojoBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
