import 'package:flutter/material.dart';

class WalkersSummaryCards extends StatelessWidget {
  final int total;
  final int online;
  final int pending;
  final int approved;
  final int rejected;

  const WalkersSummaryCards({
    super.key,
    required this.total,
    required this.online,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_SummaryItem>[
      const _SummaryItem(
        title: 'Total',
        icon: Icons.people_alt_rounded,
        color: Color(0xFF2563EB),
      ),
      const _SummaryItem(
        title: 'Online',
        icon: Icons.circle,
        color: Color(0xFF16A34A),
      ),
      const _SummaryItem(
        title: 'Pending',
        icon: Icons.pending_actions_rounded,
        color: Color(0xFFF59E0B),
      ),
      const _SummaryItem(
        title: 'Approved',
        icon: Icons.verified_rounded,
        color: Color(0xFF059669),
      ),
      const _SummaryItem(
        title: 'Rejected',
        icon: Icons.cancel_rounded,
        color: Color(0xFFDC2626),
      ),
    ];

    final values = <int>[
      total,
      online,
      pending,
      approved,
      rejected,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns;

        if (width >= 1200) {
          columns = 5;
        } else if (width >= 800) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                width < 600 ? 1.55 : 2.0,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _SummaryCard(
              title: item.title,
              value: values[index],
              icon: item.icon,
              color: item.color,
            );
          },
        );
      },
    );
  }
}

class _SummaryItem {
  final String title;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
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
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
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
