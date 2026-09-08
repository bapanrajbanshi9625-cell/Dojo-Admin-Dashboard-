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

  static const Color _orange = Color(0xFFD35435);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _green = Color(0xFF16A34A);
  static const Color _danger = Color(0xFFDC2626);
  static const Color _dark = Color(0xFF0F172A);
  static const Color _grey = Color(0xFF64748B);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

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
          content: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

            final width =
                MediaQuery.sizeOf(context).width;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: width < 500 ? 16 : 40,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                22,
                20,
                22,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                22,
                8,
                22,
                4,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                14,
              ),
              title: const Text(
                'Cancel Walk Request',
                style: TextStyle(
                  color: _dark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight:
                      MediaQuery.sizeOf(context).height * 0.62,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please select a reason for cancelling this request.',
                        style: TextStyle(
                          color: _grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: selectedReason,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Cancellation reason',
                          filled: true,
                          fillColor: _background,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: _border,
                            ),
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: _border,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(
                              color: _orange,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: reasons.map(
                          (reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: Text(
                                reason,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
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
                          controller: otherController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration: InputDecoration(
                            labelText:
                                'Enter cancellation reason',
                            hintText:
                                'Please provide a reason...',
                            filled: true,
                            fillColor: _background,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: _border,
                              ),
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: _border,
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(
                                color: _orange,
                                width: 1.5,
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
                  child: const Text(
                    'Keep Request',
                    style: TextStyle(
                      color: _grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _danger,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (selectedReason == 'Other') {
                      final custom =
                          otherController.text.trim();

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
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
    // MOBILE DETAILS
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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: _orange,
              size: 23,
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Walk Requests',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _dark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
              child: CircularProgressIndicator(
                color: _orange,
              ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: _border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _danger.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: _danger,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load walk requests.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
        final width = constraints.maxWidth;
        final horizontalPadding =
            width >= 1200
                ? 32.0
                : width >= 700
                    ? 24.0
                    : 12.0;

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            10,
            horizontalPadding,
            24,
          ),
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
          itemBuilder: (
            context,
            index,
          ) {
            final doc = docs[index];
            final data = doc.data();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
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
        final width = constraints.maxWidth;
        final isMobile = width < 600;
        final horizontalPadding =
            width >= 1200
                ? 32.0
                : width >= 700
                    ? 24.0
                    : 12.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1160,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isMobile ? 12 : 18,
                horizontalPadding,
                8,
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
                          value: pending.toString(),
                          icon:
                              Icons.pending_actions_rounded,
                          iconColor: _orange,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? 7 : 12,
                      ),
                      Expanded(
                        child: _StatBox(
                          title: 'Accepted',
                          value: accepted.toString(),
                          icon:
                              Icons.check_circle_outline_rounded,
                          iconColor: _green,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? 7 : 12,
                      ),
                      Expanded(
                        child: _StatBox(
                          title: 'Cancelled',
                          value: cancelled.toString(),
                          icon:
                              Icons.cancel_outlined,
                          iconColor: _danger,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    textInputAction:
                        TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: isMobile
                          ? 'Search requests, owner, walker...'
                          : 'Search owner, request ID, walker, dog...',
                      hintStyle: const TextStyle(
                        color: _grey,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _grey,
                      ),
                      suffixIcon:
                          _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                  ),
                                ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: _border,
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: _border,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(
                          color: _blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // ==================================================
                  // FILTERS
                  // ==================================================

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection:
                          Axis.horizontal,
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount: _filters.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(width: 7),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final filter =
                            _filters[index];
                        final selected =
                            _filter == filter;

                        return ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : _dark,
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: _blue,
                          backgroundColor:
                              Colors.white,
                          side: BorderSide(
                            color: selected
                                ? _blue
                                : _border,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _filter = filter;
                            });
                          },
                        );
                      },
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: _border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _blue.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 34,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No walk requests found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Try changing the filter or search term.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
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
  final Color iconColor;

  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;

    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? 74 : 84,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 9 : 16,
        vertical: isMobile ? 9 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          isMobile ? 13 : 16,
        ),
        border: Border.all(
          color: _WalkRequestsScreenState._border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 34 : 42,
            height: isMobile ? 34 : 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                isMobile ? 10 : 12,
              ),
            ),
            child: Icon(
              icon,
              size: isMobile ? 18 : 21,
              color: iconColor,
            ),
          ),
          SizedBox(
            width: isMobile ? 7 : 12,
          ),
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
                    fontSize: isMobile ? 10 : 12,
                    color:
                        _WalkRequestsScreenState._grey,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        _WalkRequestsScreenState._dark,
                    fontSize: isMobile ? 18 : 22,
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

  static const Color _orange = Color(0xFFD35435);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _dark = Color(0xFF0F172A);
  static const Color _grey = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _background = Color(0xFFF8FAFC);

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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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

    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        14,
        6,
        14,
        4,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        14,
        4,
        14,
        12,
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _blue.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: _blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              changing
                  ? 'Change Walker'
                  : 'Assign Walker',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: _dark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: isMobile
            ? double.maxFinite
            : 520,
        height: isMobile
            ? size.height * 0.58
            : 500,
        child: widget.walkers.isEmpty
            ? const Center(
                child: Text(
                  'No walkers found.',
                  style: TextStyle(
                    color: _grey,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              )
            : ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                itemCount:
                    widget.walkers.length,
                separatorBuilder:
                    (_, __) =>
                        const SizedBox(
                  height: 7,
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

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      onTap: saving
                          ? null
                          : () {
                              setState(() {
                                selectedDocId =
                                    doc.id;
                              });
                            },
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 180,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 11,
                          vertical: 10,
                        ),
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? _blue.withValues(
                                  alpha: 0.06,
                                )
                              : _background,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: selected
                                ? _blue
                                : _border,
                            width:
                                selected
                                    ? 1.4
                                    : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration:
                                  BoxDecoration(
                                color: _orange
                                    .withValues(
                                  alpha: 0.10,
                                ),
                                shape:
                                    BoxShape.circle,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .person_outline_rounded,
                                color: _orange,
                                size: 22,
                              ),
                            ),
                            const SizedBox(
                              width: 11,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    name.isEmpty
                                        ? 'Walker'
                                        : name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color: _dark,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    walkerId.isEmpty
                                        ? doc.id
                                        : walkerId,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color: _grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Radio<String>(
                              value: doc.id,
                              groupValue:
                                  selectedDocId,
                              activeColor: _blue,
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
                          ],
                        ),
                      ),
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
            style: TextStyle(
              color: _grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(
              0,
              44,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
          onPressed:
              saving ? null : _assign,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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
