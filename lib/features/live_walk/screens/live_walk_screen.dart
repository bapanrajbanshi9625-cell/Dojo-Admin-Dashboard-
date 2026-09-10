import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'live_walk_details_screen.dart';

// ============================================================
// DOJO ADMIN COLORS
// ============================================================

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF2563EB);
const Color dojoGreen = Color(0xFF16A34A);
const Color dojoRed = Color(0xFFDC2626);
const Color dojoDark = Color(0xFF0F172A);
const Color dojoGrey = Color(0xFF64748B);
const Color dojoBackground = Color(0xFFF8FAFC);
const Color dojoBorder = Color(0xFFE2E8F0);

// ============================================================
// LIVE WALK SCREEN
// ============================================================

class LiveWalkScreen extends StatefulWidget {
  const LiveWalkScreen({super.key});

  @override
  State<LiveWalkScreen> createState() => _LiveWalkScreenState();
}

class _LiveWalkScreenState extends State<LiveWalkScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  // ==========================================================
  // FIRESTORE CONNECTION
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> get _liveWalkStream {
    return _firestore
        .collection('liveWalkSessions')
        .snapshots();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dojoBackground,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _liveWalkStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: dojoOrange,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return _buildContent(docs);
        },
      ),
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final walks = docs
        .map(
          (doc) => LiveWalkSessionData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    // ========================================================
    // FINAL SORTING
    // DATE + TIME
    // LATEST → OLDEST
    // ========================================================

    walks.sort((a, b) {
      final aTime =
          a.startedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final bTime =
          b.startedAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return bTime.compareTo(aTime);
    });

    final filtered = _filterWalks(walks);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 22),
          _summaryCards(walks),
          const SizedBox(height: 22),
          _toolbar(),
          const SizedBox(height: 16),
          _resultsHeader(
            total: filtered.length,
            all: walks.length,
          ),
          const SizedBox(height: 10),
          _liveList(filtered),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            compact ? 18 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dojoBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Container(
                width: compact ? 46 : 52,
                height: compact ? 46 : 52,
                decoration: BoxDecoration(
                  color: dojoOrange.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: dojoOrange,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Walks',
                      style: TextStyle(
                        fontSize: 27,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Monitor all currently active walks in real time',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dojoGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 15),
                _statusIndicator(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: dojoGreen.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: dojoGreen,
          ),
          SizedBox(width: 7),
          Text(
            'LIVE MONITORING',
            style: TextStyle(
              color: dojoGreen,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _summaryCards(
    List<LiveWalkSessionData> walks,
  ) {
    final totalDistance = walks.fold<double>(
      0,
      (sum, walk) => sum + walk.distanceKm,
    );

    final totalElapsed = walks.fold<int>(
      0,
      (sum, walk) => sum + walk.elapsedSeconds,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3.15 : 2.65,
          children: [
            _SummaryCard(
              title: 'Live Walks',
              value: '${walks.length}',
              subtitle: 'Currently active',
              icon: Icons.directions_walk_rounded,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Live Distance',
              value:
                  '${totalDistance.toStringAsFixed(1)} km',
              subtitle: 'Total distance',
              icon: Icons.route_rounded,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Total Time',
              value: _formatDuration(
                totalElapsed,
              ),
              subtitle: 'Combined duration',
              icon: Icons.timer_outlined,
              color: dojoGreen,
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // TOOLBAR
  // ==========================================================

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                _searchBox(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _filters(),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _searchBox(),
              ),
              const SizedBox(width: 14),
              _filters(),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(
        color: dojoDark,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText:
            'Search session, owner, walker or dog...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: dojoGrey,
                ),
              )
            : null,
        filled: true,
        fillColor: dojoBackground,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  Widget _filters() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('With Route'),
        _filterButton('Events'),
      ],
    );
  }

  Widget _filterButton(String title) {
    final selected =
        selectedFilter == title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(10),
        onTap: () {
          setState(() {
            selectedFilter = title;
          });
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? dojoBlue
                : dojoBackground,
            borderRadius:
                BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? dojoBlue
                  : dojoBorder,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: dojoBlue.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 8,
                      offset:
                          const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : dojoDark,
              fontSize: 12,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // RESULTS HEADER
  // ==========================================================

  Widget _resultsHeader({
    required int total,
    required int all,
  }) {
    return Row(
      children: [
        const Text(
          'Active Sessions',
          style: TextStyle(
            color: dojoDark,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: dojoBlue.withValues(
              alpha: 0.09,
            ),
            borderRadius:
                BorderRadius.circular(7),
          ),
          child: Text(
            '$total${total != all ? ' / $all' : ''}',
            style: const TextStyle(
              color: dojoBlue,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FILTER LOGIC
  // ==========================================================

  List<LiveWalkSessionData> _filterWalks(
    List<LiveWalkSessionData> walks,
  ) {
    final query = searchController.text
        .trim()
        .toLowerCase();

    return walks.where((walk) {
      final matchesSearch =
          query.isEmpty ||
          walk.documentId
              .toLowerCase()
              .contains(query) ||
          walk.sessionId
              .toLowerCase()
              .contains(query) ||
          walk.ownerId
              .toLowerCase()
              .contains(query) ||
          walk.ownerName
              .toLowerCase()
              .contains(query) ||
          walk.walkerId
              .toLowerCase()
              .contains(query) ||
          walk.walkerUid
              .toLowerCase()
              .contains(query) ||
          walk.walkerName
              .toLowerCase()
              .contains(query) ||
          walk.dogName
              .toLowerCase()
              .contains(query) ||
          walk.source
              .toLowerCase()
              .contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'With Route' &&
              walk.routeCoordinates.isNotEmpty) ||
          (selectedFilter == 'Events' &&
              walk.events.isNotEmpty);

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }

  // ==========================================================
  // LIVE LIST
  // ==========================================================

  Widget _liveList(
    List<LiveWalkSessionData> walks,
  ) {
    if (walks.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: walks.map((walk) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 10),
          child: _LiveWalkCard(
            walk: walk,
            onView: () {
              _showLiveDetails(walk);
            },
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showLiveDetails(
    LiveWalkSessionData data,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveWalkDetailsScreen(
          sessionId: data.documentId,
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_walk_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No live walks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: dojoDark,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Currently active walks will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _errorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: dojoBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: dojoRed.withValues(
                  alpha: 0.09,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: dojoRed,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load live walks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: dojoDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LIVE WALK CARD
// ============================================================

class _LiveWalkCard extends StatefulWidget {
  final LiveWalkSessionData walk;
  final VoidCallback onView;

  const _LiveWalkCard({
    required this.walk,
    required this.onView,
  });

  @override
  State<_LiveWalkCard> createState() =>
      _LiveWalkCardState();
}

class _LiveWalkCardState
    extends State<_LiveWalkCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() => hovered = true);
      },
      onExit: (_) {
        setState(() => hovered = false);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 170),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            hovered ? -2.0 : 0.0,
          ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: hovered
                ? dojoBlue.withValues(
                    alpha: 0.24,
                  )
                : dojoBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: hovered ? 0.055 : 0.025,
              ),
              blurRadius: hovered ? 16 : 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return _mobile();
            }

            return _desktop();
          },
        ),
      ),
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _desktop() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 145,
          child: _dateTime(),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: _personInfo(
            label: 'Dog',
            value: widget.walk.dogName.isEmpty
                ? 'Dog'
                : widget.walk.dogName,
            icon: Icons.pets_rounded,
          ),
        ),

        Expanded(
          flex: 2,
          child: _personInfo(
            label: 'Owner',
            value: widget.walk.ownerName.isEmpty
                ? '-'
                : widget.walk.ownerName,
            icon: Icons.person_outline_rounded,
          ),
        ),

        Expanded(
          flex: 2,
          child: _personInfo(
            label: 'Walker',
            value: widget.walk.walkerName.isEmpty
                ? '-'
                : widget.walk.walkerName,
            icon: Icons.directions_walk_rounded,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: _sessionInfo(),
        ),

        const SizedBox(width: 10),

        _sourceBadge(
          widget.walk.source,
        ),

        const SizedBox(width: 10),

        _statusBadge(
          widget.walk.status,
        ),

        const SizedBox(width: 10),

        _viewButton(),
      ],
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

  Widget _mobile() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dateTime(),
            ),
            const SizedBox(width: 8),
            _sourceBadge(
              widget.walk.source,
            ),
            const SizedBox(width: 7),
            _statusBadge(
              widget.walk.status,
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _personInfo(
                label: 'Dog',
                value:
                    widget.walk.dogName.isEmpty
                        ? 'Dog'
                        : widget.walk.dogName,
                icon: Icons.pets_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _personInfo(
                label: 'Owner',
                value:
                    widget.walk.ownerName.isEmpty
                        ? '-'
                        : widget.walk.ownerName,
                icon:
                    Icons.person_outline_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        _personInfo(
          label: 'Walker',
          value:
              widget.walk.walkerName.isEmpty
                  ? '-'
                  : widget.walk.walkerName,
          icon:
              Icons.directions_walk_rounded,
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _sessionInfo(),
            ),
            const SizedBox(width: 10),
            _viewButton(),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // DATE + TIME
  // ==========================================================

  Widget _dateTime() {
    final date = widget.walk.startedAt;

    if (date == null) {
      return const Text(
        'Date/Time unavailable',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: dojoGrey,
        ),
      );
    }

    final localDate = date.toLocal();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat(
            'dd MMM yyyy',
          ).format(localDate),
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 13,
              color: dojoGrey,
            ),
            const SizedBox(width: 4),
            Text(
              DateFormat(
                'hh:mm a',
              ).format(localDate),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // PERSON INFO
  // ==========================================================

  Widget _personInfo({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: dojoBackground,
            borderRadius:
                BorderRadius.circular(9),
            border: Border.all(
              color: dojoBorder,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: dojoBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: dojoGrey,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: dojoDark,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SESSION INFO
  // ==========================================================

  Widget _sessionInfo() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Session ID',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            color: dojoGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.walk.documentId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SOURCE BADGE
  // ==========================================================

  Widget _sourceBadge(String source) {
    final normalized =
        source.toLowerCase().trim();

    final isQr =
        normalized == 'qr' ||
        normalized == 'qr_walk' ||
        normalized == 'qrcode';

    final label = isQr ? 'QR' : 'INSTA';

    final color =
        isQr ? dojoOrange : dojoBlue;

    final background =
        isQr
            ? const Color(0xFFFFF3EE)
            : const Color(0xFFEFF6FF);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              color.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isQr
                ? Icons.qr_code_rounded
                : Icons.wifi_tethering_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATUS BADGE
  // ==========================================================

  Widget _statusBadge(String status) {
    final normalized =
        status.toLowerCase().trim();

    Color background;
    Color foreground;
    String label;

    switch (normalized) {
      case 'active':
      case 'in_progress':
      case 'started':
      case 'live':
        background =
            const Color(0xFFEAF8EF);
        foreground = dojoGreen;
        label = 'LIVE';
        break;

      case 'paused':
        background =
            const Color(0xFFFFF7E6);
        foreground =
            const Color(0xFFD97706);
        label = 'PAUSED';
        break;

      case 'completed':
      case 'complete':
      case 'finished':
        background =
            const Color(0xFFEFF6FF);
        foreground = dojoBlue;
        label = 'COMPLETED';
        break;

      case 'cancelled':
      case 'canceled':
        background =
            const Color(0xFFFEF2F2);
        foreground = dojoRed;
        label = 'CANCELLED';
        break;

      case 'pending':
        background =
            const Color(0xFFF5F3FF);
        foreground =
            const Color(0xFF7C3AED);
        label = 'PENDING';
        break;

      default:
        background = dojoBackground;
        foreground = dojoGrey;
        label = _titleCase(status);
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              foreground.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VIEW BUTTON
  // ==========================================================

  Widget _viewButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onView,
          borderRadius:
              BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: dojoBlue,
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'View Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  State<_SummaryCard> createState() =>
      _SummaryCardState();
}

class _SummaryCardState
    extends State<_SummaryCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => hovered = true);
      },
      onExit: (_) {
        setState(() => hovered = false);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 170),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            hovered ? -2.0 : 0.0,
          ),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: hovered
                ? widget.color.withValues(
                    alpha: 0.25,
                  )
                : dojoBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: hovered ? 0.065 : 0.03,
              ),
              blurRadius: hovered ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: dojoGrey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w900,
                      color: dojoDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: dojoGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class LiveWalkSessionData {
  final String documentId;
  final String sessionId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerUid;
  final String walkerName;

  final String dogName;
  final String dogBreed;

  final double distanceKm;
  final int elapsedSeconds;

  final int peeCount;
  final int poopCount;

  final double? locationLat;
  final double? locationLng;

  final List<Map<String, dynamic>>
      routeCoordinates;

  final List<Map<String, dynamic>> events;

  final String status;
  final String source;

  final DateTime? startedAt;

  const LiveWalkSessionData({
    required this.documentId,
    required this.sessionId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerUid,
    required this.walkerName,
    required this.dogName,
    required this.dogBreed,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.peeCount,
    required this.poopCount,
    required this.locationLat,
    required this.locationLng,
    required this.routeCoordinates,
    required this.events,
    required this.status,
    required this.source,
    required this.startedAt,
  });

  // ==========================================================
  // FIRESTORE MAPPING
  // ==========================================================

  factory LiveWalkSessionData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final location =
        _map(data['currentLocation']) ??
            _map(data['location']);

    return LiveWalkSessionData(
      documentId: documentId,

      sessionId:
          _string(data, 'sessionId') ??
              documentId,

      ownerId:
          _string(data, 'ownerId') ?? '-',

      ownerName:
          _string(data, 'ownerName') ??
              _string(data, 'customerName') ??
              _string(data, 'userName') ??
              _string(data, 'clientName') ??
              '',

      walkerId:
          _string(data, 'walkerId') ??
              _string(data, 'walkerid') ??
              '-',

      walkerUid:
          _string(data, 'walkerUid') ??
              _string(data, 'walkerUID') ??
              _string(data, 'walkeruid') ??
              '-',

      walkerName:
          _string(data, 'walkerName') ??
              _string(data, 'walkerFullName') ??
              _string(data, 'walkerDisplayName') ??
              '',

      dogName:
          _string(data, 'dogName') ??
              _string(data, 'petName') ??
              'Dog',

      dogBreed:
          _string(data, 'dogBreed') ?? '',

      distanceKm:
          _double(data['distanceKm']) ??
              _double(data['distance']) ??
              _double(data['totalDistanceKm']) ??
              _double(data['totalDistance']) ??
              0,

      elapsedSeconds:
          _int(data['elapsedSeconds']) ??
              _int(data['durationSeconds']) ??
              _int(data['totalSeconds']) ??
              _durationMinutesToSeconds(
                data['durationMinutes'],
              ) ??
              0,

      peeCount:
          _int(data['peeCount']) ??
              _int(data['peecount']) ??
              _int(data['pee']) ??
              _int(data['pCount']) ??
              _int(data['p']) ??
              0,

      poopCount:
          _int(data['poopCount']) ??
              _int(data['poopcount']) ??
              _int(data['poop']) ??
              _int(data['pooCount']) ??
              0,

      locationLat:
          _double(location?['lat']) ??
              _double(location?['latitude']) ??
              _double(data['currentLat']),

      locationLng:
          _double(location?['lng']) ??
              _double(location?['longitude']) ??
              _double(data['currentLng']),

      routeCoordinates:
          _list(data['routeCoordinates']).isNotEmpty
              ? _list(data['routeCoordinates'])
              : _list(data['route']),

      events:
          _list(data['events']).isNotEmpty
              ? _list(data['events'])
              : _list(data['walkEvents']),

      status:
          _string(data, 'status') ??
              _string(data, 'walkStatus') ??
              'live',

      // ======================================================
      // SOURCE
      // QR / INSTA
      // ======================================================

      source:
          _string(data, 'source') ??
              '',

      // ======================================================
      // DATE/TIME
      // ======================================================

      startedAt:
          _firstDateTime(
        data,
        [
          'startedAt',
          'startTime',
          'sessionStartedAt',
          'startTimestamp',
          'createdAt',
          'timestamp',
          'updatedAt',
        ],
      ),
    );
  }
}

// ============================================================
// STRING
// ============================================================

String? _string(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

// ============================================================
// DOUBLE
// ============================================================

double? _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

// ============================================================
// INT
// ============================================================

int? _int(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

// ============================================================
// DURATION MINUTES
// ============================================================

int? _durationMinutesToSeconds(
  dynamic value,
) {
  final minutes = _double(value);

  if (minutes == null) {
    return null;
  }

  return (minutes * 60).round();
}

// ============================================================
// MAP
// ============================================================

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

// ============================================================
// LIST
// ============================================================

List<Map<String, dynamic>> _list(
  dynamic value,
) {
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map(
        (item) =>
            Map<String, dynamic>.from(item),
      )
      .toList();
}

// ============================================================
// DATE/TIME
// ============================================================

DateTime? _firstDateTime(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];

    final parsed = _dateTimeFrom(value);

    if (parsed != null) {
      return parsed;
    }
  }

  return null;
}

DateTime? _dateTimeFrom(
  dynamic value,
) {
  if (value == null) {
    return null;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is int) {
    final millis =
        value > 100000000000
            ? value
            : value * 1000;

    return DateTime.fromMillisecondsSinceEpoch(
      millis,
    );
  }

  if (value is double) {
    final millis =
        value > 100000000000
            ? value.toInt()
            : (value * 1000).toInt();

    return DateTime.fromMillisecondsSinceEpoch(
      millis,
    );
  }

  if (value is String) {
    final parsed =
        DateTime.tryParse(value);

    return parsed?.toLocal();
  }

  return null;
}

// ============================================================
// TITLE CASE
// ============================================================

String _titleCase(String value) {
  final text = value.trim();

  if (text.isEmpty) {
    return 'UNKNOWN';
  }

  return text
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

// ============================================================
// DURATION
// ============================================================

String _formatDuration(int seconds) {
  if (seconds < 0) {
    seconds = 0;
  }

  final hours = seconds ~/ 3600;
  final minutes =
      (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m ${secs}s';
  }

  return '${secs}s';
}

// ============================================================
// END
// ============================================================
