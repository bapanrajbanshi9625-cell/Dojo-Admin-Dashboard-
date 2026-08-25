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

  String _value(String key) {
    final value = data[key];

    return value == null
        ? ''
        : value.toString();
  }

  String _status() {
    return _value('status')
        .trim()
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status();

    final pending =
        status == 'searching' ||
        status == 'pending';

    final accepted =
        status == 'accepted';

    final ownerName =
        _value('ownerName');

    final address =
        _value('address');

    final searchType =
        _value('searchType');

    final radius =
        _value('searchRadiusKm');

    final walkerName =
        _value('walkerName');

    return Card(
      margin: const EdgeInsets.only(
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
                children: [
                  const CircleAvatar(
                    child: Icon(
                      Icons.pets,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName.isEmpty
                              ? 'Unknown Owner'
                              : ownerName,
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
                            color:
                                Theme.of(
                              context,
                            )
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _StatusBadge(
                    status: status,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // LOCATION
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

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

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // REQUEST INFO
              // ==================================================

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar:
                        const Icon(
                      Icons.directions_walk,
                      size: 18,
                    ),
                    label: Text(
                      searchType.isEmpty
                          ? 'Walk'
                          : searchType,
                    ),
                  ),

                  if (radius.isNotEmpty)
                    Chip(
                      avatar:
                          const Icon(
                        Icons.radar,
                        size: 18,
                      ),
                      label: Text(
                        '$radius km',
                      ),
                    ),
                ],
              ),

              // ==================================================
              // WALKER
              // ==================================================

              if (accepted) ...[
                const SizedBox(
                  height: 4,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 19,
                    ),

                    const SizedBox(
                      width: 7,
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
              ],

              const SizedBox(
                height: 14,
              ),

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
                        Icons
                            .visibility_outlined,
                      ),
                      label:
                          const Text(
                        'View Details',
                      ),
                    ),
                  ),

                  if (pending) ...[
                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child:
                          FilledButton.icon(
                        onPressed:
                            onAssign,
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
                const SizedBox(
                  height: 8,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      TextButton.icon(
                    onPressed:
                        onCancel,
                    icon:
                        const Icon(
                      Icons
                          .cancel_outlined,
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

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final displayText =
        status.isEmpty
            ? 'Unknown'
            : status[0].toUpperCase() +
                status.substring(1);

    final colorScheme =
        Theme.of(context)
            .colorScheme;

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
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color:
              colorScheme.primary,
        ),
      ),
    );
  }
}
