import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/assign_walker_dialog.dart';
import '../widgets/walk_request_card.dart';
import '../widgets/walk_request_details_sheet.dart';

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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController
      _searchController =
      TextEditingController();

  String _filter = 'All';

  // ==========================================================
  // FIRESTORE STREAM
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _requestsStream {
    return _firestore
        .collection('walk_requests')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  String _status(
    Map<String, dynamic> data,
  ) {
    final value = data['status'];

    if (value == null) {
      return '';
    }

    return value
        .toString()
        .trim()
        .toLowerCase();
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    switch (_filter) {
      case 'Pending':
        return status == 'searching' ||
            status == 'pending';

      case 'Accepted':
        return status == 'accepted';

      case 'Active':
        return status == 'active';

      case 'Completed':
        return status == 'completed';

      case 'Cancelled':
        return status == 'cancelled' ||
            status == 'canceled';

      default:
        return true;
    }
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  String _value(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  bool _matchesSearch(
    Map<String, dynamic> data,
  ) {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final values = [
      _value(data, 'requestId'),
      _value(data, 'ownerName'),
      _value(data, 'ownerId'),
      _value(data, 'ownerAuthUid'),
      _value(data, 'walkerName'),
      _value(data, 'walkerId'),
      _value(data, 'walkerUid'),
      _value(data, 'address'),
      _value(data, 'searchType'),
    ];

    return values.any(
      (value) => value
          .toLowerCase()
          .contains(query),
    );
  }

  // ==========================================================
  // CANCEL REQUEST
  // ==========================================================

  Future<void> _cancelRequest(
    String requestId,
  ) async {
    if (requestId.trim().isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel Walk Request?',
          ),
          content: const Text(
            'This request will be marked as cancelled.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Cancel Request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestore
          .collection('walk_requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Walk request cancelled.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to cancel request: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ASSIGN WALKER
  // ==========================================================

  Future<void> _assignWalker(
    String requestId,
    Map<String, dynamic> requestData,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AssignWalkerDialog(
          requestId: requestId,
          requestData: requestData,
        );
      },
    );
  }

  // ==========================================================
  // OPEN MAPS
  // ==========================================================

  Future<void> _openMaps(
    LatLng location,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/'
      '?api=1'
      '&query=${location.latitude},'
      '${location.longitude}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode:
              LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open Maps: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showDetails(
    String requestId,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return WalkRequestDetailsSheet(
          requestId: requestId,
          data: data,
          onAssign: () {
            Navigator.pop(context);

            _assignWalker(
              requestId,
              data,
            );
          },
          onCancel: () {
            Navigator.pop(context);

            _cancelRequest(
              requestId,
            );
          },
          onOpenMaps: _openMaps,
        );
      },
    );
  }

  // ==========================================================
  // TOP SECTION
  // ==========================================================

  Widget _buildTopSection(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    int pending = 0;
    int accepted = 0;
    int cancelled = 0;

    for (final doc in docs) {
      final status =
          _status(doc.data());

      if (status == 'searching' ||
          status == 'pending') {
        pending++;
      }

      if (status == 'accepted') {
        accepted++;
      }

      if (status == 'cancelled' ||
          status == 'canceled') {
        cancelled++;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),
      child: Column(
        children: [
          // ====================================================
          // STATS
          // ====================================================

          Row(
            children: [
              Expanded(
                child: _StatBox(
                  title: 'Pending',
                  value:
                      pending.toString(),
                  icon:
                      Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  title: 'Accepted',
                  value:
                      accepted.toString(),
                  icon:
                      Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  title: 'Cancelled',
                  value:
                      cancelled.toString(),
                  icon:
                      Icons.cancel_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ====================================================
          // SEARCH
          // ====================================================

          TextField(
            controller:
                _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration:
                InputDecoration(
              hintText:
                  'Search owner, request ID, walker...',
              prefixIcon:
                  const Icon(Icons.search),
              suffixIcon:
                  _searchController
                          .text
                          .isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController
                                .clear();

                            setState(() {});
                          },
                          icon:
                              const Icon(
                            Icons.clear,
                          ),
                        ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // FILTERS
          // ====================================================

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Pending',
                'Accepted',
                'Active',
                'Completed',
                'Cancelled',
              ].map(
                (filter) {
                  final selected =
                      _filter == filter;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label:
                          Text(filter),
                      selected:
                          selected,
                      onSelected: (_) {
                        setState(() {
                          _filter =
                              filter;
                        });
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
          ),
          SizedBox(height: 12),
          Text(
            'No walk requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Walk Requests',
          style: TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: _requestsStream,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'Unable to load walk requests.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          final filteredDocs =
              docs.where((doc) {
            final data =
                doc.data();

            return _matchesFilter(
                  data,
                ) &&
                _matchesSearch(
                  data,
                );
          }).toList();

          return Column(
            children: [
              _buildTopSection(
                docs,
              ),

              Expanded(
                child:
                    filteredDocs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            itemCount:
                                filteredDocs
                                    .length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final doc =
                                  filteredDocs[
                                      index];

                              final data =
                                  doc.data();

                              final status =
                                  _status(
                                data,
                              );

                              final pending =
                                  status ==
                                          'searching' ||
                                      status ==
                                          'pending';

                              return WalkRequestCard(
                                requestId:
                                    doc.id,
                                data: data,
                                onTap: () {
                                  _showDetails(
                                    doc.id,
                                    data,
                                  );
                                },
                                onAssign:
                                    pending
                                        ? () {
                                            _assignWalker(
                                              doc.id,
                                              data,
                                            );
                                          }
                                        : null,
                                onCancel:
                                    () {
                                  _cancelRequest(
                                    doc.id,
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ============================================================
// STAT BOX
// ============================================================

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
