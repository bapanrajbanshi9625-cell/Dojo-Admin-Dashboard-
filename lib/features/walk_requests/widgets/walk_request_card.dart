import 'package:flutter/material.dart';

import 'request_status_badge.dart';

class WalkRequestCard extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  final VoidCallback onTap;
  final VoidCallback onAssign;
  final VoidCallback onCancel;

  const WalkRequestCard({
    super.key,
    required this.requestId,
    required this.data,
    required this.onTap,
    required this.onAssign,
    required this.onCancel,
  });

  // ==========================================================
  // VALUE
  // ==========================================================

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  String _status() {
    return _value('status').toLowerCase();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final status = _status();

    final isPending =
        status == 'searching' ||
        status == 'pending';

    final isAccepted =
        status == 'accepted';

    final isActive =
        status == 'active';

    final ownerName = _value('ownerName');

    final address = _value('address');

    final searchType = _value('searchType');

    final radius = _value('searchRadiusKm');

    final walkerName = _value('walkerName');

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: const Icon(
                      Icons.pets,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName.isEmpty
                              ? 'Unknown Owner'
                              : ownerName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Request: $requestId',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  RequestStatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ADDRESS
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      address.isEmpty
                          ? 'Pickup address unavailable'
                          : address,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // REQUEST INFO
              // ==================================================

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.pets_outlined,
                    label: searchType.isEmpty
                        ? 'Walk'
                        : searchType,
                  ),

                  _InfoChip(
                    icon: Icons.radar,
                    label: radius.isEmpty
                        ? '0.0 km'
                        : '$radius km',
                  ),
                ],
              ),

              // ==================================================
              // WALKER
              // ==================================================

              if (isAccepted || isActive) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          walkerName.isEmpty
                              ? 'Walker assigned'
                              : 'Walker: $walkerName',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ==================================================
              // VIEW + ASSIGN
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.visibility_outlined,
                      ),
                      label: const Text(
                        'View Details',
                      ),
                    ),
                  ),

                  if (isPending) ...[
                    const SizedBox(width: 8),

                    Expanded(
                      child:
                          FilledButton.icon(
                        onPressed: onAssign,
                        icon: const Icon(
                          Icons.person_add_alt_1,
                        ),
                        label: const Text(
                          'Assign',
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ==================================================
              // CANCEL
              // ==================================================

              if (isPending ||
                  isAccepted ||
                  isActive) ...[
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label: const Text(
                      'Cancel Request',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
