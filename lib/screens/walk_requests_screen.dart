import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/services/walk_requests_service.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkRequestsScreen extends StatefulWidget {
  const WalkRequestsScreen({
    super.key,
  });

  @override
  State<WalkRequestsScreen> createState() =>
      _WalkRequestsScreenState();
}

class _WalkRequestsScreenState
    extends State<WalkRequestsScreen> {
  final WalkRequestsService _service =
      WalkRequestsService.instance;

  String selectedFilter = 'All';

  final List<String> filters = const [
    'All',
    'Searching',
    'Accepted',
    'Rejected',
    'Cancelled',
    'Expired',
    'Locked',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.requestsStream,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: dojoOrange,
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorState(
            snapshot.error.toString(),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        final filtered =
            docs.where(_matchesFilter).toList();

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _header(docs.length),

            const SizedBox(height: 16),

            _filterBar(),

            const SizedBox(height: 16),

            if (filtered.isEmpty)
              Expanded(
                child: _emptyState(),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.only(
                    bottom: 30,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (
                    context,
                    index,
                  ) =>
                      const SizedBox(height: 12),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _requestCard(
                      filtered[index],
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border:
            Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE9),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.directions_walk_outlined,
              color: dojoOrange,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Walk Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$total total requests',
                  style: const TextStyle(
                    fontSize: 12,
                    color: dojoGrey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF7F0),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: dojoGreen,
                ),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _filterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final active =
              selectedFilter == filter;

          return Padding(
            padding:
                const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              label: Text(filter),
              selected: active,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor:
                  const Color(0xFFFFEEE9),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight:
                    active
                        ? FontWeight.w800
                        : FontWeight.w500,
                color: active
                    ? dojoOrange
                    : dojoDark,
              ),
              side: BorderSide(
                color: active
                    ? dojoOrange
                    : dojoBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  bool _matchesFilter(
    QueryDocumentSnapshot<
        Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final status =
        _string(data, 'status')
            ?.toLowerCase();

    final locked =
        data['locked'] == true;

    switch (selectedFilter) {
      case 'Searching':
        return status == 'searching' ||
            status == 'pending';

      case 'Accepted':
        return status == 'accepted';

      case 'Rejected':
        return status == 'rejected';

      case 'Cancelled':
        return status == 'cancelled';

      case 'Expired':
        return status == 'expired';

      case 'Locked':
        return locked;

      default:
        return true;
    }
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _requestCard(
    QueryDocumentSnapshot<
        Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final requestId =
        _string(data, 'requestId') ??
            doc.id;

    final ownerName =
        _firstString(data, [
          'ownerName',
          'ownerFullName',
        ]) ??
        'Owner';

    final dogName =
        _string(data, 'dogName') ??
            'Dog';

    final dogBreed =
        _string(data, 'dogBreed');

    final walkerName =
        _firstString(data, [
          'walkerName',
          'walkerFullName',
        ]);

    final walkerUid =
        _firstString(data, [
          'walkerUid',
          'walkerId',
        ]);

    final status =
        _string(data, 'status') ??
            'unknown';

    final locked =
        data['locked'] == true;

    final distance =
        _firstValue(data, [
          'distanceKm',
          'distance',
        ]);

    final radius =
        _firstValue(data, [
          'searchRadiusKm',
          'radiusKm',
        ]);

    final createdAt =
        _dateText(
      _firstExisting(data, [
        'createdAt',
        'searchStartedAt',
      ]),
    );

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: locked
              ? dojoOrange.withValues(
                  alpha: .45,
                )
              : dojoBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _dogAvatar(),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dogName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  dojoDark,
                            ),
                          ),
                        ),

                        if (locked) ...[
                          const SizedBox(
                            width: 7,
                          ),
                          const Icon(
                            Icons.lock,
                            size: 15,
                            color:
                                dojoOrange,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      dogBreed == null
                          ? 'Owner: $ownerName'
                          : '$dogBreed • Owner: $ownerName',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color: dojoGrey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Request: $requestId',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color: dojoGrey,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                status,
                locked,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dojoBackground,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _info(
                  'Walker',
                  walkerName ??
                      'Not assigned',
                ),
                _info(
                  'Distance',
                  distance ?? '-',
                ),
                _info(
                  'Radius',
                  radius == null
                      ? '-'
                      : '$radius km',
                ),
                _info(
                  'Created',
                  createdAt,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (walkerUid != null &&
              walkerUid.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 15,
                  color: dojoGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Assigned to ${walkerName ?? walkerUid}',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: dojoGreen,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: locked
                      ? null
                      : () =>
                          _unassignWalker(
                            doc.id,
                          ),
                  child:
                      const Text(
                    'Unassign',
                  ),
                ),
              ],
            ),

          const SizedBox(height: 5),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    _showDetails(
                  doc,
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                ),
                label:
                    const Text(
                  'View Details',
                ),
              ),

              if (walkerUid == null ||
                  walkerUid.isEmpty)
                ElevatedButton.icon(
                  onPressed: locked
                      ? null
                      : () =>
                          _showAssignWalker(
                        doc.id,
                      ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        dojoGreen,
                    foregroundColor:
                        Colors.white,
                  ),
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Assign Walker',
                  ),
                ),

              if (locked)
                OutlinedButton.icon(
                  onPressed: () =>
                      _unlock(doc.id),
                  icon: const Icon(
                    Icons.lock_open,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Unlock',
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () =>
                      _lock(doc.id),
                  icon: const Icon(
                    Icons.lock_outline,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Lock',
                  ),
                ),

              if (status !=
                      'accepted' &&
                  status !=
                      'cancelled' &&
                  status !=
                      'rejected' &&
                  status !=
                      'expired')
                ElevatedButton.icon(
                  onPressed: locked
                      ? null
                      : () =>
                          _accept(doc.id),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        dojoBlue,
                    foregroundColor:
                        Colors.white,
                  ),
                  icon: const Icon(
                    Icons.check,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Accept',
                  ),
                ),

              if (status !=
                      'rejected' &&
                  status !=
                      'cancelled' &&
                  status !=
                      'expired')
                OutlinedButton.icon(
                  onPressed: locked
                      ? null
                      : () =>
                          _reject(doc.id),
                  icon: const Icon(
                    Icons.close,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Reject',
                  ),
                ),

              if (status !=
                      'cancelled' &&
                  status !=
                      'expired')
                TextButton.icon(
                  onPressed: locked
                      ? null
                      : () =>
                          _cancel(doc.id),
                  icon: const Icon(
                    Icons.block,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Cancel',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOG AVATAR
  // ============================================================

  Widget _dogAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 24,
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
    String status,
    bool locked,
  ) {
    Color color = dojoGrey;

    switch (status.toLowerCase()) {
      case 'searching':
      case 'pending':
        color = dojoOrange;
        break;

      case 'accepted':
        color = dojoGreen;
        break;

      case 'rejected':
      case 'cancelled':
        color = Colors.redAccent;
        break;

      case 'expired':
        color = dojoGrey;
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            locked
                ? 'LOCKED'
                : status.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _info(
    String title,
    String value,
  ) {
    return SizedBox(
      width: 135,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 9,
              color: dojoGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color: dojoDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showDetails(
    QueryDocumentSnapshot<
        Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Walk Request Details',
          ),
          content:
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: data.entries.map(
                (entry) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: Text(
                      '${entry.key}: ${_displayValue(entry.value)}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ASSIGN WALKER
  // ============================================================

  Future<void> _showAssignWalker(
    String requestId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream:
              _service.walkersStream,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 60,
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color: dojoOrange,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title:
                    const Text(
                  'Unable to load walkers',
                ),
                content:
                    Text(
                  snapshot.error.toString(),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(
                      context,
                    ),
                    child:
                        const Text(
                      'Close',
                    ),
                  ),
                ],
              );
            }

            final walkers =
                snapshot.data?.docs ?? [];

            return AlertDialog(
              title:
                  const Text(
                'Assign Walker',
              ),
              content:
                  SizedBox(
                width: 420,
                child: walkers.isEmpty
                    ? const Text(
                        'No walkers found.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount:
                            walkers.length,
                        separatorBuilder:
                            (_, __) =>
                                const Divider(),
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final walker =
                              walkers[index]
                                  .data();

                          final uid =
                              walkers[index]
                                  .id;

                          final name =
                              _firstString(
                                    walker,
                                    [
                                      'name',
                                      'fullName',
                                      'walkerName',
                                    ],
                                  ) ??
                                  'Walker';

                          final available =
                              _isAvailable(
                            walker,
                          );

                          return ListTile(
                            leading:
                                CircleAvatar(
                              backgroundColor:
                                  const Color(
                                0xFFEAF7F0,
                              ),
                              child:
                                  const Icon(
                                Icons.person,
                                color:
                                    dojoGreen,
                              ),
                            ),
                            title:
                                Text(name),
                            subtitle:
                                Text(
                              available
                                  ? 'Available'
                                  : 'Not available',
                              style:
                                  TextStyle(
                                color: available
                                    ? dojoGreen
                                    : dojoGrey,
                                fontSize:
                                    11,
                              ),
                            ),
                            trailing:
                                ElevatedButton(
                              onPressed:
                                  available
                                      ? () async {
                                          Navigator.pop(
                                            context,
                                          );

                                          await _runAction(
                                            () => _service
                                                .assignWalker(
                                              requestId:
                                                  requestId,
                                              walkerUid:
                                                  uid,
                                              walkerName:
                                                  name,
                                            ),
                                            'Walker assigned successfully.',
                                          );
                                        }
                                      : null,
                              child:
                                  const Text(
                                'Assign',
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                  ),
                  child:
                      const Text(
                    'Close',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isAvailable(
    Map<String, dynamic> data,
  ) {
    final available =
        data['available'];

    final online =
        data['online'];

    final status =
        data['status']
            ?.toString()
            .toLowerCase();

    if (available == true) {
      return true;
    }

    if (online == true) {
      return true;
    }

    if (status == 'available' ||
        status == 'online') {
      return true;
    }

    return false;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _accept(
    String id,
  ) async {
    await _runAction(
      () => _service.acceptRequest(id),
      'Request accepted.',
    );
  }

  Future<void> _reject(
    String id,
  ) async {
    await _runAction(
      () => _service.rejectRequest(id),
      'Request rejected.',
    );
  }

  Future<void> _cancel(
    String id,
  ) async {
    await _runAction(
      () => _service.cancelRequest(id),
      'Request cancelled.',
    );
  }

  Future<void> _lock(
    String id,
  ) async {
    await _runAction(
      () => _service.lockRequest(id),
      'Request locked.',
    );
  }

  Future<void> _unlock(
    String id,
  ) async {
    await _runAction(
      () => _service.unlockRequest(id),
      'Request unlocked.',
    );
  }

  Future<void> _unassignWalker(
    String id,
  ) async {
    await _runAction(
      () => _service.unassignWalker(id),
      'Walker unassigned.',
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
  ) async {
    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(success),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Action failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 45,
            color: dojoGrey,
          ),
          const SizedBox(height: 10),
          const Text(
            'No walk requests found.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: dojoGrey,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load walk requests.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String? _string(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    return text.isEmpty
        ? null
        : text;
  }

  String? _firstString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value =
          _string(data, key);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  dynamic _firstExisting(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (data.containsKey(key) &&
          data[key] != null) {
        return data[key];
      }
    }

    return null;
  }

  String? _firstValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    final value =
        _firstExisting(
      data,
      keys,
    );

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      final date =
          value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    return value?.toString() ?? '-';
  }

  String _displayValue(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return _dateText(value);
    }

    return value?.toString() ?? 'null';
  }
}
