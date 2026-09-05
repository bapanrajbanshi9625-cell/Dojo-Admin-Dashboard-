import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _WalkRequestsScreenState extends State<WalkRequestsScreen> {
  late final WalkRequestsService _service;

  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  static const List<String> _filters = [
    'All',
    'Pending',
    'Accepted',
    'Active',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _service = WalkRequestsService();
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

  bool _isPending(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    return status == 'searching' ||
        status == 'pending';
  }

  bool _isAssigned(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    return status == 'accepted' ||
        status == 'active';
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

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

  // ==========================================================
  // SEARCH
  // ==========================================================

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
      _string(data, 'dogName'),
      _string(data, 'dogBreed'),
    ];

    return values.any(
      (value) => value.toLowerCase().contains(query),
    );
  }

  // ==========================================================
  // MAPS
  // ==========================================================

  Future<void> _openMaps(
    LatLng location,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${location.latitude},${location.longitude}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage(
          'Unable to open Google Maps.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to open Maps: $e',
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // CANCEL REQUEST
  // ==========================================================

  Future<void> _cancelRequest(
    String requestId,
  ) async {
    final reason = await _showCancellationDialog();

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    try {
      await _service.cancelRequest(
        requestId: requestId,
        reason: reason.trim(),
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Walk request cancelled.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to cancel request: $e',
      );
    }
  }

  // ==========================================================
  // CANCELLATION DIALOG
  // ==========================================================

  Future<String?> _showCancellationDialog() async {
    const reasons = [
      'No walker available',
      'Owner cancelled',
      'Walker unavailable',
      'Duplicate request',
      'Location issue',
      'Other',
    ];

    String selectedReason = reasons.first;
    final otherController = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final isOther =
                selectedReason == 'Other';

            return AlertDialog(
              title: const Text(
                'Cancel Walk Request',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please select a reason for cancelling this request.',
                      ),
                      const SizedBox(height: 18),

                      DropdownButtonFormField<String>(
                       value: selectedReason,
                       decoration: InputDecoration(
                        labelText: 'Cancellation reason',
                        border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                      ),
                        items: reasons.map(
                          (reason) {
                            return DropdownMenuItem<
                                String>(
                              value: reason,
                              child: Text(reason),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            selectedReason = value;
                          });
                        },
                      ),

                      if (isOther) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller:
                              otherController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Enter cancellation reason',
                            hintText:
                                'Please provide a reason...',
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Keep Request'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedReason == 'Other') {
                      final custom =
                          otherController.text
                              .trim();

                      if (custom.isEmpty) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a cancellation reason.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        custom,
                      );

                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      selectedReason,
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
      },
    );

    otherController.dispose();

    return result;
  }

  // ==========================================================
  // ASSIGN / CHANGE WALKER
  // ==========================================================

  Future<void> _assignWalker(
    String requestId,
    Map<String, dynamic> requestData,
  ) async {
    try {
      final walkers = await _service.getWalkers();

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

      _showMessage(
        'Unable to load walkers: $e',
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
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 700) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1050,
                maxHeight: 760,
              ),
              child: WalkRequestDetailsSheet(
                requestId: requestId,
                data: data,
                onAssign: () {
                  Navigator.pop(dialogContext);

                  _assignWalker(
                    requestId,
                    data,
                  );
                },
                onCancel: () {
                  Navigator.pop(dialogContext);

                  _cancelRequest(
                    requestId,
                  );
                },
                onOpenMaps: _openMaps,
              ),
            ),
          );
        },
      );

      return;
    }

    // ========================================================
    // MOBILE
    // ========================================================

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return WalkRequestDetailsSheet(
          requestId: requestId,
          data: data,
          onAssign: () {
            Navigator.pop(sheetContext);

            _assignWalker(
              requestId,
              data,
            );
          },
          onCancel: () {
            Navigator.pop(sheetContext);

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
  Widget build(
    BuildContext context,
  ) {
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
        stream: _service.watchWalkRequests(),
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
            return _buildError(
              snapshot.error,
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
                child: filteredDocs.isEmpty
                    ? _buildEmptyState()
                    : _buildRequestList(
                        filteredDocs,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _buildError(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: Theme.of(context)
                    .colorScheme
                    .error,
              ),
              const SizedBox(height: 14),
              const Text(
                'Unable to load walk requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // REQUEST LIST
  // ==========================================================

  Widget _buildRequestList(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        docs,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isWide =
            constraints.maxWidth >= 900;

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 18,
          ),
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (
            context,
            index,
          ) {
            final doc = docs[index];
            final data = doc.data();

            return Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: WalkRequestCard(
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
                ),
              ),
            );
          },
        );
      },
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
      final status = _status(
        doc.data(),
      );

      if (status == 'searching' ||
          status == 'pending') {
        pending++;
      } else if (status == 'accepted') {
        accepted++;
      } else if (status == 'cancelled' ||
          status == 'canceled') {
        cancelled++;
      }
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isWide =
            constraints.maxWidth >= 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1160,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 16,
                20,
                isWide ? 32 : 16,
                8,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // STATS
                  // ==================================================

                  if (isWide)
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
                            icon: Icons
                                .check_circle_outline,
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
                    )
                  else
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatBox(
                            title: 'Accepted',
                            value:
                                accepted.toString(),
                            icon: Icons
                                .check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 8),
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

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  TextField(
                    controller:
                        _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    textInputAction:
                        TextInputAction.search,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search owner, request ID, walker, dog...',
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
                      filled: true,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // FILTERS
                  // ==================================================

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child:
                        SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: Row(
                        children:
                            _filters.map(
                          (filter) {
                            final selected =
                                _filter ==
                                    filter;

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                right: 8,
                              ),
                              child:
                                  ChoiceChip(
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            const Text(
              'No walk requests found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing the filter or search term.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
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
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme
                  .primaryContainer,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme
                  .onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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

  final Map<String, dynamic> requestData;

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
  State<_AssignWalkerDialog> createState() =>
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
    final value = data[key];

    return value == null
        ? ''
        : value.toString();
  }

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

    final walker = widget.walkers.firstWhere(
      (doc) => doc.id == selectedDocId,
    );

    final data = walker.data();

    final walkerUid =
        _value(data, 'authUid').isNotEmpty
            ? _value(data, 'authUid')
            : _value(data, 'walkerUid');

    final walkerId =
        _value(data, 'walkerId');

    final walkerName =
        _value(data, 'name').isNotEmpty
            ? _value(data, 'name')
            : _value(data, 'walkerName');

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
      await widget.service.assignWalker(
        requestId: widget.requestId,
        walkerUid: walkerUid,
        walkerId: walkerId,
        walkerName: walkerName,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(
              _currentWalkerId().isEmpty
                  ? 'Walker assigned successfully.'
                  : 'Walker changed successfully.',
            ),
            behavior:
                SnackBarBehavior.floating,
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

  String _currentWalkerId() {
    return _value(
      widget.requestData,
      'walkerId',
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final changing =
        _currentWalkerId().isNotEmpty;

    return AlertDialog(
      title: Text(
        changing
            ? 'Change Walker'
            : 'Assign Walker',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 520,
        height: 500,
        child: widget.walkers.isEmpty
            ? const Center(
                child: Text(
                  'No walkers found.',
                ),
              )
            : ListView.separated(
                itemCount:
                    widget.walkers.length,
                separatorBuilder:
                    (_, __) =>
                        const SizedBox(
                  height: 8,
                ),
                itemBuilder: (
                  context,
                  index,
                ) {
                  final doc =
                      widget.walkers[index];

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
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person_outline,
                        ),
                      ),
                      title: Text(
                        name.isEmpty
                            ? 'Walker'
                            : name,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        walkerId.isEmpty
                            ? doc.id
                            : walkerId,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                      trailing:
                          Radio<String>(
                        value: doc.id,
                        groupValue:
                            selectedDocId,
                        onChanged:
                            saving
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedDocId =
                                          value;
                                    });
                                  },
                      ),
                      selected: selected,
                      onTap: saving
                          ? null
                          : () {
                              setState(() {
                                selectedDocId =
                                    doc.id;
                              });
                            },
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text(
            'Cancel',
          ),
        ),
        FilledButton(
          onPressed:
              saving ? null : _assign,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  changing
                      ? 'Change Walker'
                      : 'Assign Walker',
                ),
        ),
      ],
    );
  }
}
