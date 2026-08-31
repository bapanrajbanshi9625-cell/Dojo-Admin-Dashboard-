import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ============================================================
// DOJO COLORS
// ============================================================

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFD9534F);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

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
  // LIVE WALK SESSIONS
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _liveWalkStream {
    return _firestore
        .collection('liveWalkSessions')
        .snapshots();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

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

          const SizedBox(height: 20),

          _summaryCards(walks),

          const SizedBox(height: 20),

          _toolbar(),

          const SizedBox(height: 16),

          _liveList(filtered),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Walks',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Monitor all currently active walks',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
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
      builder: (
        context,
        constraints,
      ) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 550
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.5,
          children: [
            _SummaryCard(
              title: 'Live Walks',
              value: '${walks.length}',
              icon: Icons.directions_walk,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Live Distance',
              value:
                  '${totalDistance.toStringAsFixed(1)} km',
              icon: Icons.route_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Total Time',
              value: _formatDuration(totalElapsed),
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
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                _searchBox(),
                const SizedBox(height: 12),
                _filters(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _searchBox(),
              ),
              const SizedBox(width: 12),
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
      decoration: InputDecoration(
        hintText: 'Search walk, owner, walker or dog...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoOrange,
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
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? dojoOrange
                : dojoBorder,
          ),
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
          walk.documentId.toLowerCase().contains(query) ||
          walk.id.toLowerCase().contains(query) ||
          walk.ownerId.toLowerCase().contains(query) ||
          walk.ownerName.toLowerCase().contains(query) ||
          walk.walkerId.toLowerCase().contains(query) ||
          walk.walkerUid.toLowerCase().contains(query) ||
          walk.walkerName.toLowerCase().contains(query) ||
          walk.dogName.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'With Route' &&
              walk.routeCoordinates.isNotEmpty) ||
          (selectedFilter == 'Events' &&
              walk.events.isNotEmpty);

      return matchesSearch && matchesFilter;
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
          padding: const EdgeInsets.only(
            bottom: 12,
          ),
          child: _liveCard(walk),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // LIVE CARD
  // ==========================================================

  Widget _liveCard(
    LiveWalkSessionData walk,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          if (constraints.maxWidth < 650) {
            return _mobileCard(walk);
          }

          return _desktopCard(walk);
        },
      ),
    );
  }

  // ==========================================================
  // DESKTOP CARD
  // ==========================================================

  Widget _desktopCard(
    LiveWalkSessionData walk,
  ) {
    return Row(
      children: [
        _liveAvatar(),

        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _mainInfo(walk),
        ),

        Expanded(
          child: _infoItem(
            Icons.timer_outlined,
            'Duration',
            _formatDuration(
              walk.elapsedSeconds,
            ),
          ),
        ),

        Expanded(
          child: _infoItem(
            Icons.route_outlined,
            'Distance',
            '${walk.distanceKm.toStringAsFixed(1)} km',
          ),
        ),

        _liveBadge(),

        const SizedBox(width: 12),

        _viewButton(walk),
      ],
    );
  }

  // ==========================================================
  // MOBILE CARD
  // ==========================================================

  Widget _mobileCard(
    LiveWalkSessionData walk,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _liveAvatar(),

            const SizedBox(width: 12),

            Expanded(
              child: _mainInfo(walk),
            ),

            _liveBadge(),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _infoItem(
                Icons.timer_outlined,
                'Duration',
                _formatDuration(
                  walk.elapsedSeconds,
                ),
              ),
            ),
            Expanded(
              child: _infoItem(
                Icons.route_outlined,
                'Distance',
                '${walk.distanceKm.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _miniStat(
                Icons.water_drop_outlined,
                'Pee',
                '${walk.peeCount}',
              ),
            ),
            Expanded(
              child: _miniStat(
                Icons.pets,
                'Poop',
                '${walk.poopCount}',
              ),
            ),
            Expanded(
              child: _miniStat(
                Icons.alt_route,
                'Route',
                '${walk.routeCoordinates.length}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _viewButton(walk),
        ),
      ],
    );
  }

  // ==========================================================
  // LIVE AVATAR
  // ==========================================================

  Widget _liveAvatar() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.directions_walk,
        color: dojoOrange,
        size: 27,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
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
            ),

            const SizedBox(width: 7),

            _liveBadge(),
          ],
        ),

        const SizedBox(height: 5),

        Text(
          walk.dogName.isEmpty
              ? 'Dog'
              : walk.dogName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EF),
        borderRadius: BorderRadius.circular(8),
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
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: dojoBlue,
        ),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: dojoGrey,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
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
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: dojoBlue,
        ),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: dojoGrey,
              ),
            ),

            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // VIEW BUTTON
  // ==========================================================

  Widget _viewButton(
    LiveWalkSessionData walk,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showLiveDetails(walk);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View Live'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  // ==========================================================
  // SHOW LIVE DETAILS
  // ==========================================================

  void _showLiveDetails(
    LiveWalkSessionData data,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            10,
          ),
          title: Row(
            children: [
              const Icon(
                Icons.directions_walk,
                color: dojoOrange,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  data.id.isEmpty
                      ? data.documentId
                      : data.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
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
                                .toStringAsFixed(7),
                      ),
                      _detailRow(
                        'Longitude',
                        data.locationLng == null
                            ? '-'
                            : data.locationLng!
                                .toStringAsFixed(7),
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
                Navigator.pop(context);
              },
              child: const Text('Close'),
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
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(13),
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

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
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
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ROUTE SECTION
  // ==========================================================

  Widget _routeSection(
    LiveWalkSessionData data,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FB),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDCE7F2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.alt_route,
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
  // EVENTS SECTION
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
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
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

  // ==========================================================
  // EVENT TILE
  // ==========================================================

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
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 17,
            color: dojoBlue,
          ),

          const SizedBox(width: 8),

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
                  ),
                ),

                if (note.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 2),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 10,
                        color: dojoGrey,
                      ),
                    ),
                  ),

                if (timestamp.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 2),
                    child: Text(
                      timestamp,
                      style: const TextStyle(
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
        borderRadius: BorderRadius.circular(17),
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
  // ERROR STATE
  // ==========================================================

  Widget _errorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: dojoBorder,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: dojoOrange,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load live walks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
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
// LIVE SESSION MODEL
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

  final List<Map<String, dynamic>> routeCoordinates;

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
    final location = _map(data['location']);

    return LiveWalkSessionData(
      documentId: documentId,

      id: _string(data, 'id') ?? documentId,

      ownerId: _string(data, 'ownerId') ?? '-',

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
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: dojoGrey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
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

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map(
        (item) => Map<String, dynamic>.from(item),
      )
      .toList();
}

String _formatDuration(int seconds) {
  if (seconds < 0) {
    seconds = 0;
  }

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  if (minutes > 0) {
    return '${minutes}m ${secs}s';
  }

  return '${secs}s';
}
