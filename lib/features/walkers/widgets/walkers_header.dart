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
    final statusColor = walkerDetailsStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: walkerDetailsBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: walkerDetailsTextDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      walkerId,
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

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

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

  Widget _avatar() {
    final hasImage = selfieUrl.trim().isNotEmpty;

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: walkerDetailsOrange.withValues(alpha: 0.10),
        border: Border.all(
          color: walkerDetailsOrange.withValues(alpha: 0.20),
        ),
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                selfieUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
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
