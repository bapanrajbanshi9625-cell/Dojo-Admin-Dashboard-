// File:
// lib/features/walk_requests/widgets/walk_request_details_information.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsInformation extends StatelessWidget {
  const WalkRequestDetailsInformation({
    super.key,
    required this.requestId,
    required this.ownerName,
    required this.dogName,
    required this.walkerName,
    required this.hasWalker,
    required this.status,
  });

  final String requestId;
  final String ownerName;
  final String dogName;
  final String walkerName;
  final bool hasWalker;
  final String status;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Walk Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _Row(
            label: 'Request ID',
            value: requestId,
          ),
          _Row(
            label: 'Owner',
            value: ownerName,
          ),
          _Row(
            label: 'Dog',
            value: dogName,
          ),
          _Row(
            label: 'Walker',
            value: hasWalker
                ? walkerName
                : 'Not assigned',
          ),
          _Row(
            label: 'Status',
            value: status.toUpperCase(),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: blue,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: dark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
