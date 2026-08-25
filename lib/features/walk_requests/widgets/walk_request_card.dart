import 'package:flutter/material.dart';

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
  // RADIUS
  // ==========================================================

  String _radius() {
    final value = data['searchRadiusKm'];

    if (value == null) {
      return '0.0 km';
    }

    if (value is num) {
      return '${value.toStringAsFixed(1)} km';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '0.0 km';
    }

    return '$text km';
  }

  // ==========================================================
  // SEARCH TYPE
  // ==========================================================

  String _searchType() {
    final value =
        _value('searchType');

    if (value.isEmpty) {
      return 'Walk';
    }

    return value;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final status = _status();

    final pending =
        status == 'searching' ||
        status == 'pending';

    final accepted =
        status == 'accepted';

    final owner =
        _value('ownerName');

    final address =
        _value('address');

    final walkerName =
        _value('walkerName');

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(18),
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
                          owner.isEmpty
                              ? 'Unknown Owner'
                              : owner,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          'Request: $requestId',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  WalkRequestStatusBadge(
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
                  Chip(
                    avatar: const Icon(
                      Icons.directions_walk,
                      size: 17,
                    ),
                    label: Text(
                      _searchType(),
                    ),
                  ),

                  Chip(
                    avatar: const Icon(
                      Icons.radar,
                      size: 17,
                    ),
                    label: Text(
                      _radius(),
                    ),
                  ),
                ],
              ),

              // ==================================================
              // WALKER
              // ==================================================

              if (accepted) ...[
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 20,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          'Walker: '
                          '${walkerName.isEmpty ? 'Assigned' : walkerName}',
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
              // ACTIONS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: onTap,
                      icon:
                          const Icon(
                        Icons.visibility_outlined,
                      ),
                      label:
                          const Text(
                        'View Details',
                      ),
                    ),
                  ),

                  if (pending) ...[
                    const SizedBox(width: 8),

                    Expanded(
                      child:
                          FilledButton.icon(
                        onPressed: onAssign,
                        icon:
                            const Icon(
                          Icons
                              .person_add_alt_1,
                        ),
                        label:
                            const Text(
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

              if (pending ||
                  accepted) ...[
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child:
                      TextButton.icon(
                    onPressed: onCancel,
                    icon:
                        const Icon(
                      Icons.cancel_outlined,
                    ),
                    label:
                        const Text(
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
// STATUS BADGE
// ============================================================

class WalkRequestStatusBadge
    extends StatelessWidget {
  final String status;

  const WalkRequestStatusBadge({
    super.key,
    required this.status,
  });

  // ==========================================================
  // DISPLAY TEXT
  // ==========================================================

  String _displayStatus() {
    if (status.isEmpty) {
      return 'Unknown';
    }

    return status[0].toUpperCase() +
        status.substring(1);
  }

  // ==========================================================
  // ICON
  // ==========================================================

  IconData _icon() {
    switch (status) {
      case 'searching':
      case 'pending':
        return Icons.pending_actions;

      case 'accepted':
        return Icons.check_circle_outline;

      case 'active':
        return Icons.directions_walk;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel_outlined;

      default:
        return Icons.help_outline;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        color: colorScheme.primary
            .withValues(
          alpha: 0.10,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _icon(),
            size: 14,
            color:
                colorScheme.primary,
          ),

          const SizedBox(width: 5),

          Text(
            _displayStatus(),
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
              color:
                  colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
