import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  // FIRESTORE CONNECTION — UNCHANGED
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _liveWalkStream {
    return _firestore
        .collection('liveWalkSessions')
        .snapshots();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dojoBackground,
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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
            'Search walk, owner, walker or dog...',
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
  // FILTER LOGIC — UNCHANGED
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
          walk.id
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
              .contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'With Route' &&
              walk.routeCoordinates
                  .isNotEmpty) ||
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
              const EdgeInsets.only(bottom: 12),
          child: _LiveWalkCard(
            walk: walk,
            onView: () {
              _showLiveDetails(walk);
            },
            liveBadge: _liveBadge(),
            mainInfo: _mainInfo(walk),
            infoItem: _infoItem,
            miniStat: _miniStat,
            viewButton: _viewButton(walk),
            liveAvatar: _liveAvatar(),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // LIVE AVATAR
  // ==========================================================

  Widget _liveAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: dojoOrange.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: dojoOrange.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: const Icon(
        Icons.directions_walk_rounded,
        color: dojoOrange,
        size: 28,
      ),
    );
  }

  // ==========================================================
  // MAIN INFO
  // ==========================================================

  Widget _mainInfo(
    LiveWalkSessionData walk,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          walk.id.isEmpty
              ? walk.documentId
              : walk.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          walk.dogName.isEmpty
              ? 'Dog'
              : walk.dogName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: dojoDark,
          ),
        ),
        if (walk.dogBreed.isNotEmpty)
          Text(
            walk.dogBreed,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),
        const SizedBox(height: 3),
        Text(
          '${walk.ownerId} • ${walk.walkerId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
        if (walk.walkerName.isNotEmpty)
          Text(
            'Walker: ${walk.walkerName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // LIVE BADGE
  // ==========================================================

  Widget _liveBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: dojoGreen.withValues(
            alpha: 0.13,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: dojoGreen,
          ),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: dojoGreen,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INFO ITEM
  // ==========================================================

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      margin:
          const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: dojoBlue,
          ),
          const SizedBox(width: 7),
          Flexible(
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
                    fontWeight:
                        FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MINI STAT
  // ==========================================================

  Widget _miniStat(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 8,
      ),
      margin:
          const EdgeInsets.only(right: 7),
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: dojoBlue,
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  color: dojoGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  color: dojoDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VIEW BUTTON
  // ==========================================================

  Widget _viewButton(
    LiveWalkSessionData walk,
  ) {
    return FilledButton.icon(
      onPressed: () {
        _showLiveDetails(walk);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text(
        'View Live',
      ),
      style: FilledButton.styleFrom(
        backgroundColor: dojoOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showLiveDetails(
    LiveWalkSessionData data,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          titlePadding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            8,
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            10,
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      dojoOrange.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: dojoOrange,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.id.isEmpty
                      ? data.documentId
                      : data.id,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoDark,
                  ),
                ),
              ),
              _liveBadge(),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _detailSection(
                    'Walk',
                    [
                      _detailRow(
                        'Document ID',
                        data.documentId,
                      ),
                      _detailRow(
                        'Walk ID',
                        data.id,
                      ),
                      _detailRow(
                        'Owner ID',
                        data.ownerId,
                      ),
                      _detailRow(
                        'Owner Name',
                        data.ownerName,
                      ),
                      _detailRow(
                        'Walker ID',
                        data.walkerId,
                      ),
                      _detailRow(
                        'Walker UID',
                        data.walkerUid,
                      ),
                      _detailRow(
                        'Walker Name',
                        data.walkerName,
                      ),
                    ],
                  ),
                  _detailSection(
                    'Dog',
                    [
                      _detailRow(
                        'Dog Name',
                        data.dogName,
                      ),
                      _detailRow(
                        'Breed',
                        data.dogBreed,
                      ),
                    ],
                  ),
                  _detailSection(
                    'Live Stats',
                    [
                      _detailRow(
                        'Duration',
                        _formatDuration(
                          data.elapsedSeconds,
                        ),
                      ),
                      _detailRow(
                        'Distance',
                        '${data.distanceKm.toStringAsFixed(2)} km',
                      ),
                      _detailRow(
                        'Pee',
                        '${data.peeCount}',
                      ),
                      _detailRow(
                        'Poop',
                        '${data.poopCount}',
                      ),
                      _detailRow(
                        'Route Points',
                        '${data.routeCoordinates.length}',
                      ),
                      _detailRow(
                        'Events',
                        '${data.events.length}',
                      ),
                    ],
                  ),
                  _detailSection(
                    'Current Location',
                    [
                      _detailRow(
                        'Latitude',
                        data.locationLat == null
                            ? '-'
                            : data.locationLat!
                                .toStringAsFixed(
                                7,
                              ),
                      ),
                      _detailRow(
                        'Longitude',
                        data.locationLng == null
                            ? '-'
                            : data.locationLng!
                                .toStringAsFixed(
                                7,
                              ),
                      ),
                    ],
                  ),
                  _routeSection(data),
                  _eventsSection(data),
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
                'Close',
                style: TextStyle(
                  color: dojoBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // DETAIL SECTION
  // ==========================================================

  Widget _detailSection(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: dojoOrange,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: dojoDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ROUTE
  // ==========================================================

  Widget _routeSection(
    LiveWalkSessionData data,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dojoBlue.withValues(
          alpha: 0.045,
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBlue.withValues(
            alpha: 0.13,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 18,
                color: dojoBlue,
              ),
              SizedBox(width: 7),
              Text(
                'Route',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: dojoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${data.routeCoordinates.length} route points recorded',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dojoDark,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Map preview will be connected later with the Map API.',
            style: TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EVENTS
  // ==========================================================

  Widget _eventsSection(
    LiveWalkSessionData data,
  ) {
    if (data.events.isEmpty) {
      return _detailSection(
        'Events',
        const [
          Text(
            'No events recorded.',
            style: TextStyle(
              color: dojoGrey,
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Events',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: dojoOrange,
            ),
          ),
          const SizedBox(height: 10),
          ...data.events
              .take(20)
              .map(_eventTile),
        ],
      ),
    );
  }

  Widget _eventTile(
    Map<String, dynamic> event,
  ) {
    final type =
        _string(event, 'type') ?? 'Event';

    final note =
        _string(event, 'note') ?? '';

    final timestamp =
        _string(event, 'timestamp') ?? '';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dojoBackground,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: dojoBlue.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 17,
              color: dojoBlue,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: dojoDark,
                  ),
                ),
                if (note.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 2,
                    ),
                    child: Text(
                      note,
                      style:
                          const TextStyle(
                        fontSize: 10,
                        color: dojoGrey,
                      ),
                    ),
                  ),
                if (timestamp.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 2,
                    ),
                    child: Text(
                      timestamp,
                      style:
                          const TextStyle(
                        fontSize: 9,
                        color: dojoGrey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
  final Widget liveBadge;
  final Widget mainInfo;
  final Widget Function(
    IconData,
    String,
    String,
  ) infoItem;
  final Widget Function(
    IconData,
    String,
    String,
  ) miniStat;
  final Widget viewButton;
  final Widget liveAvatar;

  const _LiveWalkCard({
    required this.walk,
    required this.onView,
    required this.liveBadge,
    required this.mainInfo,
    required this.infoItem,
    required this.miniStat,
    required this.viewButton,
    required this.liveAvatar,
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
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(17),
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
                alpha: hovered ? 0.065 : 0.03,
              ),
              blurRadius: hovered ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return _mobile();
            }

            return _desktop();
          },
        ),
      ),
    );
  }

  Widget _desktop() {
    return Row(
      children: [
        widget.liveAvatar,
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: widget.mainInfo,
        ),
        Expanded(
          child: widget.infoItem(
            Icons.timer_outlined,
            'Duration',
            _formatDuration(
              widget.walk.elapsedSeconds,
            ),
          ),
        ),
        Expanded(
          child: widget.infoItem(
            Icons.route_outlined,
            'Distance',
            '${widget.walk.distanceKm.toStringAsFixed(1)} km',
          ),
        ),
        widget.liveBadge,
        const SizedBox(width: 12),
        widget.viewButton,
      ],
    );
  }

  Widget _mobile() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            widget.liveAvatar,
            const SizedBox(width: 12),
            Expanded(
              child: widget.mainInfo,
            ),
            widget.liveBadge,
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: widget.infoItem(
                Icons.timer_outlined,
                'Duration',
                _formatDuration(
                  widget.walk.elapsedSeconds,
                ),
              ),
            ),
            Expanded(
              child: widget.infoItem(
                Icons.route_outlined,
                'Distance',
                '${widget.walk.distanceKm.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: widget.miniStat(
                Icons.water_drop_outlined,
                'Pee',
                '${widget.walk.peeCount}',
              ),
            ),
            Expanded(
              child: widget.miniStat(
                Icons.pets,
                'Poop',
                '${widget.walk.poopCount}',
              ),
            ),
            Expanded(
              child: widget.miniStat(
                Icons.alt_route,
                'Route',
                '${widget.walk.routeCoordinates.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: widget.viewButton,
        ),
      ],
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
// MODEL — FIRESTORE FIELD MAPPING UNCHANGED
// ============================================================

class LiveWalkSessionData {
  final String documentId;
  final String id;

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

  const LiveWalkSessionData({
    required this.documentId,
    required this.id,
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
  });

  factory LiveWalkSessionData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final location =
        _map(data['location']);

    return LiveWalkSessionData(
      documentId: documentId,
      id: _string(data, 'id') ?? documentId,
      ownerId:
          _string(data, 'ownerId') ?? '-',
      ownerName:
          _string(data, 'ownerName') ?? '',
      walkerId:
          _string(data, 'walkerId') ??
              _string(data, 'walkerid') ??
              '-',
      walkerUid:
          _string(data, 'walkerUid') ??
              _string(data, 'walkeruid') ??
              '-',
      walkerName:
          _string(data, 'walkerName') ?? '',
      dogName:
          _string(data, 'dogName') ?? 'Dog',
      dogBreed:
          _string(data, 'dogBreed') ?? '',
      distanceKm:
          _double(data['distanceKm']) ?? 0,
      elapsedSeconds:
          _int(data['elapsedSeconds']) ?? 0,
      peeCount:
          _int(data['peeCount']) ?? 0,
      poopCount:
          _int(data['poopCount']) ?? 0,
      locationLat:
          _double(location?['lat']),
      locationLng:
          _double(location?['lng']),
      routeCoordinates:
          _list(data['routeCoordinates']),
      events:
          _list(data['events']),
    );
  }
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

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

double? _double(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

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

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}

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
