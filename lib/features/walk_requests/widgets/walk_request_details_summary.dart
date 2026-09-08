// File:
// lib/features/walk_requests/widgets/walk_request_details_summary.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsSummary extends StatelessWidget {
  const WalkRequestDetailsSummary({
    super.key,
    required this.requestId,
    required this.ownerName,
    required this.dogName,
    required this.walkerName,
    required this.status,
    required this.createdAt,
    required this.onCopy,
  });

  final String requestId;
  final String ownerName;
  final String dogName;
  final String walkerName;
  final String status;
  final String createdAt;
  final VoidCallback onCopy;

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: orange,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Request Summary',
                  style: TextStyle(
                    color: dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            label: 'Request ID',
            value: requestId,
            trailing: IconButton(
              tooltip: 'Copy Request ID',
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: blue,
              ),
            ),
          ),
          _SummaryRow(
            label: 'Owner',
            value: ownerName,
          ),
          _SummaryRow(
            label: 'Dog',
            value: dogName,
          ),
          _SummaryRow(
            label: 'Walker',
            value: walkerName.isEmpty
                ? 'Not assigned'
                : walkerName,
          ),
          _SummaryRow(
            label: 'Status',
            value: status.toUpperCase(),
          ),
          _SummaryRow(
            label: 'Created',
            value: createdAt,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
