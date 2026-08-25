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

  String _value(String key) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String _status() {
    return _value('status')
        .trim()
        .toLowerCase();
  }

  String _distance() {
    final value = data['searchRadiusKm'];

    if (value == null) {
      return '0.0 km';
    }

    if (value is num) {
      return '${value.toDouble().toStringAsFixed(1)} km';
    }

    final parsed =
        double.tryParse(value.toString());

    if (parsed == null) {
      return '0.0 km';
    }

    return '${parsed.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final status = _status();

    final pending =
        status == 'searching' ||
        status == 'pending';

    final accepted =
        status == 'accepted';

    final active =
        status == 'active';

    final ownerName =
        _value('ownerName');

    final address =
        _value('address');

    final walkerName =
        _value('walkerName');

    final searchType =
        _value('searchType');

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // HEADER
              // =================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 23,
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
                          style:
                              const TextStyle(
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
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .bodySmall,
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

              // =================================================
              // PICKUP
              // =================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 21,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
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
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =================================================
              // REQUEST INFO
              // =================================================

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
                      searchType.isEmpty
                          ? 'Walk'
                          : searchType,
                    ),
                  ),

                  Chip(
                    avatar: const Icon(
                      Icons.radar,
                      size: 17,
                    ),
                    label: Text(
                      _distance(),
                    ),
                  ),
                ],
              ),

              // =================================================
              // WALKER
              // =================================================

              if (accepted ||
                  active ||
                  walkerName.isNotEmpty) ...[
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                    color:
                        Colors.green.withValues(
                      alpha: 0.08,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.green,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          walkerName.isEmpty
                              ? 'Walker Assigned'
                              : 'Walker: $walkerName',
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

              // =================================================
              // ACTION BUTTONS
              // =================================================

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

                  if (pending) ...[
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

              // =================================================
              // CANCEL
              // =================================================

              if (pending ||
                  accepted ||
                  active) ...[
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
