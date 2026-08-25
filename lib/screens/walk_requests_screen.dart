import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/assign_walker_dialog.dart';
import 'widgets/request_card.dart';
import 'widgets/request_details_sheet.dart';
import 'widgets/stat_box.dart';

class WalkRequestsScreen extends StatefulWidget {
  const WalkRequestsScreen({super.key});

  @override
  State<WalkRequestsScreen> createState() =>
      _WalkRequestsScreenState();
}

class _WalkRequestsScreenState
    extends State<WalkRequestsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  // ==========================================================
  // FIRESTORE
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
  // HELPERS
  // ==========================================================

  String _string(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String _status(
    Map<String, dynamic> data,
  ) {
    return _string(
      data,
      'status',
    ).trim().toLowerCase();
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

      case 'All':
      default:
        return true;
    }
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
      _string(data, 'requestId'),
      _string(data, 'ownerName'),
      _string(data, 'ownerId'),
      _string(data, 'ownerAuthUid'),
      _string(data, 'walkerName'),
      _string(data, 'walkerId'),
      _string(data, 'walkerUid'),
      _string(data, 'address'),
      _string(data, 'searchType'),
    ];

    return values.any(
      (value) =>
          value.toLowerCase().contains(query),
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
              child: const Text(
                'Cancel Request',
              ),
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

      ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
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
    try {
      final walkersSnapshot =
          await _firestore
              .collection('walkers')
              .get();

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AssignWalkerDialog(
            requestId: requestId,
            requestData: requestData,
            walkers: walkersSnapshot.docs,
            firestore: _firestore,
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load walkers: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // OPEN MAPS
  // ==========================================================

  Future<void> _openMaps(
    LatLng location,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${location.latitude},${location.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RequestDetailsSheet(
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
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Walk Requests',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _requestsStream,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          final filteredDocs = docs.where(
            (doc) {
              final data = doc.data();

              return _matchesFilter(data) &&
                  _matchesSearch(data);
            },
          ).toList();

          return Column(
            children: [
              _buildTopSection(docs),

              Expanded(
                child: filteredDocs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(20),
                        itemCount:
                            filteredDocs.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final doc =
                              filteredDocs[index];

                          final data =
                              doc.data();

                          return RequestCard(
                            requestId: doc.id,
                            data: data,
                            onTap: () {
                              _showDetails(
                                doc.id,
                                data,
                              );
                            },
                            onAssign: () {
                              _assignWalker(
                                doc.id,
                                data,
                              );
                            },
                            onCancel: () {
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
  // TOP SECTION
  // ==========================================================

  Widget _buildTopSection(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    final pending = docs.where(
      (doc) {
        final status =
            _status(doc.data());

        return status == 'searching' ||
            status == 'pending';
      },
    ).length;

    final accepted = docs.where(
      (doc) =>
          _status(doc.data()) ==
          'accepted',
    ).length;

    final cancelled = docs.where(
      (doc) {
        final status =
            _status(doc.data());

        return status == 'cancelled' ||
            status == 'canceled';
      },
    ).length;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatBox(
                  title: 'Pending',
                  value: pending.toString(),
                  icon:
                      Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  title: 'Accepted',
                  value:
                      accepted.toString(),
                  icon:
                      Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
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
                      onSelected:
                          (_) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
