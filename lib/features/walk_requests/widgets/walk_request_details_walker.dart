// File:
// lib/features/walk_requests/widgets/walk_request_details_walker.dart

import 'package:flutter/material.dart';

class WalkRequestDetailsWalker extends StatelessWidget {
  const WalkRequestDetailsWalker({
    super.key,
    required this.hasWalker,
    required this.walkerName,
    required this.walkerId,
    required this.walkerPhone,
    required this.onCall,
    required this.onCopy,
  });

  final bool hasWalker;
  final String walkerName;
  final String walkerId;
  final String walkerPhone;
  final VoidCallback onCall;
  final VoidCallback onCopy;

  static const Color blue = Color(0xFF2563EB);
  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Walker Details',
      icon: Icons.directions_walk_rounded,
      child: hasWalker
          ? Column(
              children: [
                _ProfileHeader(
                  name: walkerName,
                  subtitle: walkerId,
                ),
                const SizedBox(height: 14),
                _PhoneRow(
                  phone: walkerPhone,
                  onCall: onCall,
                ),
                const SizedBox(height: 10),
                _CopyRow(
                  label: 'Walker ID',
                  value: walkerId,
                  onCopy: onCopy,
                ),
              ],
            )
          : const _EmptyWalker(),
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
        border: Border.all(color: border),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String subtitle;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: blue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.directions_walk_rounded,
            color: blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.phone,
    required this.onCall,
  });

  final String phone;
  final VoidCallback onCall;

  static const Color green = Color(0xFF16A34A);
  static const Color dark = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final enabled =
        phone != '—' && phone.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_outlined,
            size: 18,
            color: green,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              phone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: dark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: enabled ? onCall : null,
            icon: const Icon(
              Icons.call_rounded,
              size: 16,
            ),
            label: const Text('Call'),
            style: TextButton.styleFrom(
              foregroundColor: green,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.copy_rounded,
              size: 16,
              color: blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWalker extends StatelessWidget {
  const _EmptyWalker();

  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.person_search_rounded,
            color: grey,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No walker assigned yet.',
              style: TextStyle(
                color: grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
