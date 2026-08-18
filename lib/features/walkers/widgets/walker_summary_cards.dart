import 'package:flutter/material.dart';

class WalkerSummaryCards extends StatelessWidget {
  final int totalWalkers;
  final int pendingWalkers;
  final int approvedWalkers;
  final int rejectedWalkers;

  const WalkerSummaryCards({
    super.key,
    this.totalWalkers = 0,
    this.pendingWalkers = 0,
    this.approvedWalkers = 0,
    this.rejectedWalkers = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _SummaryCard(
          title: 'Total',
          value: totalWalkers,
          icon: Icons.people_alt_rounded,
          iconColor: const Color(0xFF1976D2),
        ),
        _SummaryCard(
          title: 'Pending',
          value: pendingWalkers,
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFF59E0B),
        ),
        _SummaryCard(
          title: 'Approved',
          value: approvedWalkers,
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF16A34A),
        ),
        _SummaryCard(
          title: 'Rejected',
          value: rejectedWalkers,
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
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
