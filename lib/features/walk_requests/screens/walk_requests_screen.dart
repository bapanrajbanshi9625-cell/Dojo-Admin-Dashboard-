import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/walk_request_empty_state.dart';
import '../widgets/walk_request_stat_box.dart';

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

  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

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
      (value) => value
          .toLowerCase()
          .contains(query),
    );
  }

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
            final data = doc.data();

            return _matchesFilter(data) &&
                _matchesSearch(data);
          }).toList();

          return Column(
            children: [
              _buildTopSection(docs),

              Expanded(
                child:
                    filteredDocs.isEmpty
                        ? const WalkRequestEmptyState()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            itemCount:
                                filteredDocs.length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final doc =
                                  filteredDocs[
                                      index];

                              return _buildRequestCard(
                                doc.id,
                                doc.data(),
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

  Widget _buildTopSection(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    int pending = 0;
    int accepted = 0;
    int cancelled = 0;

    for (final doc in docs) {
      final status = _status(
        doc.data(),
      );

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
                child:
                    WalkRequestStatBox(
                  title: 'Pending',
                  value:
                      pending.toString(),
                  icon:
                      Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    WalkRequestStatBox(
                  title: 'Accepted',
                  value:
                      accepted.toString(),
                  icon: Icons
                      .check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    WalkRequestStatBox(
                  title: 'Cancelled',
                  value:
                      cancelled.toString(),
                  icon: Icons
                      .cancel_outlined,
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
              ].map((filter) {
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
                        _filter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    String requestId,
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    final ownerName =
        _string(data, 'ownerName');

    final address =
        _string(data, 'address');

    final walkerName =
        _string(data, 'walkerName');

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16),
        leading: const CircleAvatar(
          child: Icon(Icons.pets),
        ),
        title: Text(
          ownerName.isEmpty
              ? 'Unknown Owner'
              : ownerName,
          style: const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Request: $requestId',
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                address.isEmpty
                    ? 'Pickup address unavailable'
                    : address,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
              if (walkerName.isNotEmpty) ...[
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Walker: $walkerName',
                ),
              ],
            ],
          ),
        ),
        trailing: _StatusBadge(
          status: status,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

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
    final text = status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() +
            status.substring(1);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(30),
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(
          alpha: 0.10,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      ),
    );
  }
}
