import 'package:flutter/material.dart';

import 'walk_request_status_badge.dart';

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

    final hasWalker =
        _value('walkerName').isNotEmpty ||
        _value('walkerId').isNotEmpty ||
        _value('walkerUid').isNotEmpty;

    final ownerName = _value('ownerName');
    final address = _value('address');
    final searchType = _value('searchType');
    final radius = _value('searchRadiusKm');
    final walkerName = _value('walkerName');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                    ),
                    child: Icon(
                      Icons.pets,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        _RequestIdText(
                          requestId: requestId,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Align(
                      alignment:
                          Alignment.topRight,
                      child: RequestStatusBadge(
                        status: status,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // ADDRESS
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Location',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            address.isEmpty
                                ? 'Pickup address unavailable'
                                : address,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // WALK INFORMATION
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
                        : '$radius km radius',
                  ),
                ],
              ),

              // ==================================================
              // WALKER
              // ==================================================

              if ((isAccepted ||
                      isActive) &&
                  hasWalker) ...[
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Walker',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              walkerName.isEmpty
                                  ? 'Walker assigned'
                                  : walkerName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isAccepted || isActive)
                        TextButton(
                          onPressed: onAssign,
                          child: const Text(
                            'Change',
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ==================================================
              // ACTIONS
              // ==================================================

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final compact =
                      constraints.maxWidth < 430;

                  if (compact) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(
                            Icons.visibility_outlined,
                          ),
                          label: const Text(
                            'View Details',
                          ),
                        ),

                        if (isPending) ...[
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: onAssign,
                            icon: const Icon(
                              Icons.person_add_alt_1,
                            ),
                            label: const Text(
                              'Assign Walker',
                            ),
                          ),
                        ],

                        if (isAccepted) ...[
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: onAssign,
                            icon: const Icon(
                              Icons.swap_horiz,
                            ),
                            label: const Text(
                              'Change Walker',
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
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
                          child: FilledButton.icon(
                            onPressed: onAssign,
                            icon: const Icon(
                              Icons.person_add_alt_1,
                            ),
                            label: const Text(
                              'Assign Walker',
                            ),
                          ),
                        ),
                      ],

                      if (isAccepted) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              FilledButton.tonalIcon(
                            onPressed: onAssign,
                            icon: const Icon(
                              Icons.swap_horiz,
                            ),
                            label: const Text(
                              'Change Walker',
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              // ==================================================
              // CANCEL
              // ==================================================

              if (isPending ||
                  isAccepted ||
                  isActive) ...[
                const SizedBox(height: 7),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
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
// REQUEST ID
// ============================================================

class _RequestIdText extends StatelessWidget {
  final String requestId;

  const _RequestIdText({
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 14,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            requestId.isEmpty
                ? 'Request ID unavailable'
                : requestId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color,
            ),
          ),
        ),
      ],
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
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
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

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
