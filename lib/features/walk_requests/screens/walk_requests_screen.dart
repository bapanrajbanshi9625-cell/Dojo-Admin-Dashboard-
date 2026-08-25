import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../services/walk_requests_service.dart';
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
  // ==========================================================
  // SERVICE
  // ==========================================================

  late final WalkRequestsService _service;

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController
      _searchController =
      TextEditingController();

  // ==========================================================
  // FILTER
  // ==========================================================

  String _filter = 'All';

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _service =
        WalkRequestsService();
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

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    final status =
        _status(data);

    switch (_filter) {
      case 'All':
        return true;

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

  bool _matchesSearch(
    Map<String, dynamic> data,
  ) {
    final query =
        _searchController.text
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
          value.toLowerCase().contains(
                query,
              ),
    );
  }

  // ==========================================================
  // CANCEL
  // ==========================================================

  Future<void> _cancelRequest(
    String requestId,
  ) async {
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
              child: const Text(
                'Keep',
              ),
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
      await _service.cancelRequest(
        requestId: requestId,
      );

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
    try {
      final walkers =
          await _service.getWalkers();

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return _AssignWalkerDialog(
            requestId: requestId,
            requestData: requestData,
            walkers: walkers,
            service: _service,
          );
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load walkers: $e',
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
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
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
        stream:
            _service.watchWalkRequests(),
        builder: (
          context,
          snapshot,
        ) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Unable to load walk requests.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================
          // DOCUMENTS
          // ==================================================

          final docs =
              snapshot.data?.docs ?? [];

          final filteredDocs =
              docs.where(
            (doc) {
              final data =
                  doc.data();

              return _matchesFilter(
                    data,
                  ) &&
                  _matchesSearch(
                    data,
                  );
            },
          ).toList();

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

                              return WalkRequestCard(
                                requestId:
                                    doc.id,
                                data:
                                    data,
                                onTap:
                                    () {
                                  _showDetails(
                                    doc.id,
                                    data,
                                  );
                                },
                                onAssign:
                                    () {
                                  _assignWalker(
                                    doc.id,
                                    data,
                                  );
                                },
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
  // TOP SECTION
  // ==========================================================

  Widget _buildTopSection(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        docs,
  ) {
    int pending = 0;
    int accepted = 0;
    int cancelled = 0;

    for (final doc in docs) {
      final status =
          _status(
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
          // ==================================================
          // STATS
          // ==================================================

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
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: _StatBox(
                  title: 'Accepted',
                  value:
                      accepted.toString(),
                  icon:
                      Icons.check_circle_outline,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
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

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // SEARCH
          // ==================================================

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
                  const Icon(
                Icons.search,
              ),
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

          const SizedBox(
            height: 14,
          ),

          // ==================================================
          // FILTER
          // ==================================================

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
                      _filter ==
                          filter;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),
                    child:
                        ChoiceChip(
                      label:
                          Text(
                        filter,
                      ),
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
  // EMPTY STATE
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
          SizedBox(
            height: 12,
          ),
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

class _StatBox
    extends StatelessWidget {
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
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
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

// ============================================================
// ASSIGN WALKER DIALOG
// ============================================================

class _AssignWalkerDialog
    extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic>
      requestData;

  final List<
          QueryDocumentSnapshot<
              Map<String, dynamic>>>
      walkers;

  final WalkRequestsService service;

  const _AssignWalkerDialog({
    required this.requestId,
    required this.requestData,
    required this.walkers,
    required this.service,
  });

  @override
  State<_AssignWalkerDialog>
      createState() =>
          _AssignWalkerDialogState();
}

class _AssignWalkerDialogState
    extends State<_AssignWalkerDialog> {
  String? selectedDocId;

  bool saving = false;

  String _value(
    Map<String, dynamic> data,
    String key,
  ) {
    final value =
        data[key];

    return value == null
        ? ''
        : value.toString();
  }

  // ==========================================================
  // ASSIGN
  // ==========================================================

  Future<void> _assign() async {
    if (selectedDocId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a walker.',
          ),
        ),
      );

      return;
    }

    final walker =
        widget.walkers.firstWhere(
      (doc) =>
          doc.id ==
          selectedDocId,
    );

    final data =
        walker.data();

    final walkerUid =
        _value(
          data,
          'authUid',
        ).isNotEmpty
            ? _value(
                data,
                'authUid',
              )
            : _value(
                data,
                'walkerUid',
              );

    final walkerId =
        _value(
      data,
      'walkerId',
    );

    final walkerName =
        _value(
          data,
          'name',
        ).isNotEmpty
            ? _value(
                data,
                'name',
              )
            : _value(
                data,
                'walkerName',
              );

    if (walkerUid.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selected walker has no valid UID.',
          ),
        ),
      );

      return;
    }

    if (walkerId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Selected walker has no Walker ID.',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await widget.service
          .assignWalker(
        requestId:
            widget.requestId,
        walkerUid:
            walkerUid,
        walkerId:
            walkerId,
        walkerName:
            walkerName,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Walker assigned successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to assign walker: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Text(
        'Assign Walker',
      ),
      content: SizedBox(
        width: 500,
        child:
            widget.walkers.isEmpty
                ? const Padding(
                    padding:
                        EdgeInsets.all(
                      20,
                    ),
                    child: Text(
                      'No walkers found.',
                    ),
                  )
                : ListView.builder(
                    shrinkWrap:
                        true,
                    itemCount:
                        widget.walkers
                            .length,
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final doc =
                          widget.walkers[
                              index];

                      final data =
                          doc.data();

                      final name =
                          _value(
                            data,
                            'name',
                          ).isNotEmpty
                              ? _value(
                                  data,
                                  'name',
                                )
                              : _value(
                                  data,
                                  'walkerName',
                                );

                      final walkerId =
                          _value(
                        data,
                        'walkerId',
                      );

                      final selected =
                          selectedDocId ==
                              doc.id;

                      return Card(
                        child:
                            ListTile(
                          leading:
                              const CircleAvatar(
                            child:
                                Icon(
                              Icons.person,
                            ),
                          ),
                          title:
                              Text(
                            name.isEmpty
                                ? 'Walker'
                                : name,
                          ),
                          subtitle:
                              Text(
                            walkerId
                                    .isEmpty
                                ? doc.id
                                : walkerId,
                          ),
                          trailing:
                              Radio<
                                  String>(
                            value:
                                doc.id,
                            groupValue:
                                selectedDocId,
                            onChanged:
                                (value) {
                              setState(
                                () {
                                  selectedDocId =
                                      value;
                                },
                              );
                            },
                          ),
                          selected:
                              selected,
                          onTap: () {
                            setState(
                              () {
                                selectedDocId =
                                    doc.id;
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed:
              saving
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                      );
                    },
          child:
              const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              saving
                  ? null
                  : _assign,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Assign Walker',
                ),
        ),
      ],
    );
  }
}
