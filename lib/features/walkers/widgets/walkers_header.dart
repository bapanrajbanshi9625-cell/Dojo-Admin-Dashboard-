import 'package:flutter/material.dart';

import 'walkers_helpers.dart';

class WalkerDetailsHeader extends StatelessWidget {
  final String name;
  final String walkerId;
  final String selfieUrl;
  final String status;
  final Widget actions;

  const WalkerDetailsHeader({
    super.key,
    required this.name,
    required this.walkerId,
    required this.selfieUrl,
    required this.status,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        walkerDetailsStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: walkerDetailsBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                imageUrl: selfieUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isEmpty
                          ? 'Unknown Walker'
                          : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: walkerDetailsTextDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      walkerId.trim().isEmpty
                          ? 'Walker ID unavailable'
                          : walkerId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: walkerDetailsTextGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                status: status,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(
            height: 1,
            color: walkerDetailsBorder,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: actions,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;

  const _Avatar({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl.trim().isNotEmpty;

    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: walkerDetailsOrange.withValues(
          alpha: 0.10,
        ),
        border: Border.all(
          color: walkerDetailsOrange.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: walkerDetailsOrange,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person_rounded,
              size: 32,
              color: walkerDetailsOrange,
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        status.trim().isEmpty
            ? 'Pending'
            : status;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
