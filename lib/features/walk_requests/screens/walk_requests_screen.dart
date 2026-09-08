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

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color green = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

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

  // ============================================================
  // HELPERS
  // ============================================================

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

  // ============================================================
  // FILTER
  // ============================================================

  bool _matchesFilter(
    Map<String, dynamic> data,
  ) {
    final status = _status(data);

    switch (_filter) {
      case 'All':
        return true;

      case 'Pending':
        return status == 'searching' || status == 'pending';

      case 'Accepted':
        return status == 'accepted';

      case 'Active':
        return status == 'active';

      case 'Completed':
        return status == 'completed';

      case 'Cancelled':
        return status == 'cancelled' || status == 'canceled';

      default:
        return true;
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool _matchesSearch(
    Map<String, dynamic> data,
  ) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final values = <String>[
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

  // ============================================================
  // MAPS
  // ============================================================

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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

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
        ),
      );
  }

  // ============================================================
  // CANCEL REQUEST
  // ============================================================

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

  // ============================================================
  // CANCELLATION DIALOG
  // ============================================================

  Future<String?> _showCancellationDialog() async {
    const reasons = <String>[
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
            final isOther = selectedReason == 'Other';

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.all(16),
              titlePadding: const EdgeInsets.fromLTRB(
                24,
                22,
                24,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                8,
              ),
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cancel Walk Request',
                      style: TextStyle(
                        color: dark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  maxHeight: 420,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please select a reason for cancelling this request.',
                        style: TextStyle(
                          color: grey,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: selectedReason,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Cancellation reason',
                          labelStyle: const TextStyle(
                            color: grey,
                          ),
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: orange,
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
                                overflow: TextOverflow.ellipsis,
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
                            labelText: 'Enter cancellation reason',
                            hintText:
                                'Please provide a reason...',
                            filled: true,
                            fillColor: background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: orange,
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
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Keep Request',
                    style: TextStyle(
                      color: grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (selectedReason == 'Other') {
                      final custom =
                          otherController.text.trim();

                      if (custom.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .hideCurrentSnackBar();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
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

  // ============================================================
  // ASSIGN / CHANGE WALKER
  // ============================================================

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
        builder: (dialogContext) {
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

  // ============================================================
  // DETAILS
  // ============================================================

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
            backgroundColor: Colors.white,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 20,
        title: const Text(
          'Walk Requests',
          style: TextStyle(
            color: dark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.watchWalkRequests(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: orange,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildError(
              snapshot.error,
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final filteredDocs = docs.where(
            (doc) {
              final data = doc.data();

              return _matchesFilter(data) &&
                  _matchesSearch(data);
            },
          ).toList();

          /*
           * IMPORTANT:
           * The entire page below is ONE vertical scroll view.
           *
           * This prevents:
           * - nested vertical scroll conflicts
           * - request cards getting trapped inside Expanded
           * - mobile screen clipping
           * - stats/search/filter taking fixed space
           */
          return _buildScrollableContent(
            docs,
            filteredDocs,
          );
        },
      ),
    );
  }

  // ============================================================
  // MAIN SCROLLABLE CONTENT
  // ============================================================

  Widget _buildScrollableContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final isWide = constraints.maxWidth >= 900;

        return Scrollbar(
          thumbVisibility: isWide,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: isWide ? 24 : 12,
              right: isWide ? 24 : 12,
              top: 4,
              bottom: 32,
            ),
            children: [
              _buildTopSection(
                docs,
              ),
              const SizedBox(height: 8),
              _buildResultHeader(
                filteredDocs.length,
                docs.length,
              ),
              const SizedBox(height: 4),
              _buildRequestCards(
                filteredDocs,
                isWide,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // RESULT HEADER
  // ============================================================

  Widget _buildResultHeader(
    int visibleCount,
    int totalCount,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1160,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            4,
            4,
            10,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.list_alt_outlined,
                size: 18,
                color: grey,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Requests',
                  style: TextStyle(
                    color: dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: blue.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '$visibleCount / $totalCount',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REQUEST CARDS
  // ============================================================

  Widget _buildRequestCards(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isWide,
  ) {
    if (docs.isEmpty) {
      return _buildEmptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1160,
        ),
        child: Column(
          children: [
            for (int index = 0; index < docs.length; index++) ...[
              _buildRequestItem(
                docs[index],
              ),
              if (index != docs.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return WalkRequestCard(
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
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    Object? error,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 30,
                    color: danger,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load walk requests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 13,
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

  // ============================================================
  // TOP SECTION
  // ============================================================

  Widget _buildTopSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int pending = 0;
    int accepted = 0;
    int cancelled = 0;

    for (final doc in docs) {
      final status = _status(
        doc.data(),
      );

      if (status == 'searching' || status == 'pending') {
        pending++;
      } else if (status == 'accepted') {
        accepted++;
      } else if (status == 'cancelled' ||
          status == 'canceled') {
        cancelled++;
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1160,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            14,
            4,
            8,
          ),
          child: Column(
            children: [
              _buildStats(
                pending,
                accepted,
                cancelled,
              ),
              const SizedBox(height: 16),
              _buildSearch(),
              const SizedBox(height: 12),
              _buildFilters(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(
    int pending,
    int accepted,
    int cancelled,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact = constraints.maxWidth < 520;

        if (compact) {
          return Column(
            children: [
              _StatBox(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.pending_actions,
                iconColor: orange,
              ),
              const SizedBox(height: 8),
              _StatBox(
                title: 'Accepted',
                value: accepted.toString(),
                icon: Icons.check_circle_outline,
                iconColor: green,
              ),
              const SizedBox(height: 8),
              _StatBox(
                title: 'Cancelled',
                value: cancelled.toString(),
                icon: Icons.cancel_outlined,
                iconColor: danger,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _StatBox(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.pending_actions,
                iconColor: orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                title: 'Accepted',
                value: accepted.toString(),
                icon: Icons.check_circle_outline,
                iconColor: green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                title: 'Cancelled',
                value: cancelled.toString(),
                icon: Icons.cancel_outlined,
                iconColor: danger,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText:
            'Search owner, request ID, walker, dog...',
        hintStyle: const TextStyle(
          color: grey,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: grey,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.clear,
                  color: grey,
                ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: blue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 2,
        ),
        child: Row(
          children: _filters.map(
            (filter) {
              final selected = _filter == filter;

              return Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                ),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : dark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: selected,
                  selectedColor: blue,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? blue
                        : border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        24,
        0,
        32,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 34,
                color: blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No walk requests found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try changing the filter or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grey,
                fontSize: 13,
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
    return Container(
      constraints: const BoxConstraints(
        minHeight: 82,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _WalkRequestsScreenState.border,
        ),
        boxShadow: [
          BoxShadow(
            color: _WalkRequestsScreenState.dark
                .withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _WalkRequestsScreenState.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _WalkRequestsScreenState.dark,
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

class _AssignWalkerDialog extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> walkers;
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

  static const Color orange = Color(0xFFD35435);
  static const Color blue = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  String _value(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    return value == null
        ? ''
        : value.toString();
  }

  String _currentWalkerId() {
    return _value(
      widget.requestData,
      'walkerId',
    );
  }

  Future<void> _assign() async {
    if (selectedDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a walker.',
          ),
        ),
      );

      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>> walker;

    try {
      walker = widget.walkers.firstWhere(
        (doc) => doc.id == selectedDocId,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected walker is no longer available.',
          ),
        ),
      );

      return;
    }

    final data = walker.data();

    final authUidValue = _value(
      data,
      'authUid',
    );

    final walkerUidValue = _value(
      data,
      'walkerUid',
    );

    final walkerUid = authUidValue.isNotEmpty
        ? authUidValue
        : walkerUidValue;

    final walkerId = _value(
      data,
      'walkerId',
    );

    final walkerNameValue = _value(
      data,
      'name',
    );

    final walkerName = walkerNameValue.isNotEmpty
        ? walkerNameValue
        : _value(
            data,
            'walkerName',
          );

    if (walkerUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selected walker has no valid UID.',
          ),
        ),
      );

      return;
    }

    if (walkerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      final wasChanging =
          _currentWalkerId().isNotEmpty;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasChanging
                ? 'Walker changed successfully.'
                : 'Walker assigned successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final changing =
        _currentWalkerId().isNotEmpty;

    final screenWidth =
        MediaQuery.sizeOf(context).width;

    final screenHeight =
        MediaQuery.sizeOf(context).height;

    final dialogWidth = screenWidth < 600
        ? screenWidth - 32
        : 540.0;

    final maxDialogHeight =
        screenHeight - 180;

    final dialogHeight =
        maxDialogHeight.clamp(
          300.0,
          520.0,
        );

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: blue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add_alt_1_outlined,
              color: blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              changing
                  ? 'Change Walker'
                  : 'Assign Walker',
              style: const TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight.toDouble(),
        child: widget.walkers.isEmpty
            ? const Center(
                child: Text(
                  'No walkers found.',
                  style: TextStyle(
                    color: grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Scrollbar(
                thumbVisibility: screenWidth >= 600,
                child: ListView.separated(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  itemCount: widget.walkers.length,
                  separatorBuilder: (
                    _,
                    __,
                  ) =>
                      const SizedBox(height: 8),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final doc =
                        widget.walkers[index];

                    final data = doc.data();

                    final nameValue = _value(
                      data,
                      'name',
                    );

                    final name = nameValue.isNotEmpty
                        ? nameValue
                        : _value(
                            data,
                            'walkerName',
                          );

                    final walkerId = _value(
                      data,
                      'walkerId',
                    );

                    final selected =
                        selectedDocId == doc.id;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(14),
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
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? blue.withValues(
                                    alpha: 0.06,
                                  )
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                            border: Border.all(
                              color: selected
                                  ? blue
                                  : border,
                              width: selected
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
                                  color: selected
                                      ? blue.withValues(
                                          alpha: 0.12,
                                        )
                                      : background,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: selected
                                      ? blue
                                      : grey,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
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
                                        color: dark,
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
                                        color: grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Radio<String>(
                                activeColor: blue,
                                value: doc.id,
                                groupValue:
                                    selectedDocId,
                                onChanged: saving
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
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
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
              color: grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                orange.withValues(alpha: 0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: saving
              ? null
              : _assign,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
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
