import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ============================================================
// DOJO COLORS
// ============================================================

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

// ============================================================
// ACTIVE WALKS SCREEN
// ============================================================

class ActiveWalksScreen extends StatefulWidget {
  const ActiveWalksScreen({super.key});

  @override
  State<ActiveWalksScreen> createState() =>
      _ActiveWalksScreenState();
}

class _ActiveWalksScreenState
    extends State<ActiveWalksScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  // ==========================================================
  // FIRESTORE
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _activeWalksStream {
    return _firestore
        .collection('active_walk')
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
      child: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _activeWalksStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildContent(docs),
          );
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
          (doc) => ActiveWalkData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .where(
          (walk) => walk.status != 'completed',
        )
        .toList();

    final filtered =
        _filterWalks(walks);

    final activeCount = walks
        .where(
          (walk) => walk.status == 'active',
        )
        .length;

    final pausedCount = walks
        .where(
          (walk) => walk.status == 'paused',
        )
        .length;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(
          activeCount,
          pausedCount,
          walks.length,
        ),

        const SizedBox(height: 20),

        _toolbar(),

        const SizedBox(height: 16),

        _walkList(filtered),
      ],
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Active Walks',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Monitor all currently running walks',
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
    int activeCount,
    int pausedCount,
    int totalCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 550
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
              columns == 1 ? 3.2 : 2.5,
          children: [
            _SummaryCard(
              title: 'Active Now',
              value: '$activeCount',
              icon:
                  Icons.directions_walk_outlined,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Paused',
              value: '$pausedCount',
              icon:
                  Icons.pause_circle_outline,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total Running',
              value: '$totalCount',
              icon: Icons.route_outlined,
              color: dojoBlue,
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
        borderRadius:
            BorderRadius.circular(16),
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
        hintText:
            'Search Walk ID, owner, walker or pet...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon:
            searchController.text.isNotEmpty
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
        fillColor:
            const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: dojoBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide:
              const BorderSide(
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
        _filterButton('Live'),
        _filterButton('Paused'),
      ],
    );
  }

  Widget _filterButton(
    String title,
  ) {
    final selected =
        selectedFilter == title;

    return InkWell(
      borderRadius:
          BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : const Color(0xFFF8F9FA),
          borderRadius:
              BorderRadius.circular(10),
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

  List<ActiveWalkData> _filterWalks(
    List<ActiveWalkData> walks,
  ) {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    return walks.where((walk) {
      final matchesSearch =
          query.isEmpty ||
          walk.walkId
              .toLowerCase()
              .contains(query) ||
          walk.ownerName
              .toLowerCase()
              .contains(query) ||
          walk.ownerId
              .toLowerCase()
              .contains(query) ||
          walk.walkerName
              .toLowerCase()
              .contains(query) ||
          walk.walkerId
              .toLowerCase()
              .contains(query) ||
          walk.petName
              .toLowerCase()
              .contains(query) ||
          walk.petBreed
              .toLowerCase()
              .contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Live' &&
              walk.status == 'active') ||
          (selectedFilter == 'Paused' &&
              walk.status == 'paused');

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }

  // ==========================================================
  // WALK LIST
  // ==========================================================

  Widget _walkList(
    List<ActiveWalkData> walks,
  ) {
    if (walks.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: walks.map((walk) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 12,
          ),
          child: _walkCard(walk),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // WALK CARD
  // ==========================================================

  Widget _walkCard(
    ActiveWalkData walk,
  ) {
    final live =
        walk.status == 'active';

    final statusColor =
        live ? dojoGreen : dojoOrange;

    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
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
            return _mobileWalkCard(
              walk,
              statusColor,
            );
          }

          return _desktopWalkCard(
            walk,
            statusColor,
          );
        },
      ),
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _desktopWalkCard(
    ActiveWalkData walk,
    Color statusColor,
  ) {
    return Row(
      children: [
        _walkIcon(),

        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _walkMainInfo(walk),
        ),

        Expanded(
          child: _walkInfo(
            Icons.timer_outlined,
            'Duration',
            walk.duration,
          ),
        ),

        Expanded(
          child: _walkInfo(
            Icons.route_outlined,
            'Distance',
            walk.distance,
          ),
        ),

        _statusChip(
          walk.statusLabel,
          statusColor,
        ),

        const SizedBox(width: 12),

        _detailsButton(walk),
      ],
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

  Widget _mobileWalkCard(
    ActiveWalkData walk,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _walkIcon(),

            const SizedBox(width: 12),

            Expanded(
              child: _walkMainInfo(walk),
            ),

            _statusChip(
              walk.statusLabel,
              statusColor,
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _walkInfo(
                Icons.timer_outlined,
                'Duration',
                walk.duration,
              ),
            ),
            Expanded(
              child: _walkInfo(
                Icons.route_outlined,
                'Distance',
                walk.distance,
              ),
            ),
          ],
        ),

        if (walk.hasLocation) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: dojoGreen,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${walk.lat!.toStringAsFixed(5)}, '
                  '${walk.lng!.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: dojoGrey,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _detailsButton(walk),
        ),
      ],
    );
  }

  // ==========================================================
  // WALK ICON
  // ==========================================================

  Widget _walkIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: dojoOrange.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.directions_walk_outlined,
        color: dojoOrange,
        size: 26,
      ),
    );
  }

  // ==========================================================
  // MAIN INFO
  // ==========================================================

  Widget _walkMainInfo(
    ActiveWalkData walk,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // WALK ID
        InkWell(
          borderRadius:
              BorderRadius.circular(5),
          onTap: () {
            _showWalkDetails(walk);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: 2,
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tag,
                  size: 15,
                  color: dojoOrange,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    walk.walkId,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w900,
                      color: dojoOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons
                      .open_in_new_outlined,
                  size: 13,
                  color: dojoOrange,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 5),

        // PET
        Row(
          children: [
            const Icon(
              Icons.pets,
              size: 14,
              color: dojoOrange,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                walk.petName,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color: dojoDark,
                ),
              ),
            ),
          ],
        ),

        if (walk.petBreed.isNotEmpty)
          Text(
            walk.petBreed,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),

        const SizedBox(height: 3),

        // OWNER + WALKER
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 14,
              color: dojoOrange,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                walk.ownerName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.directions_walk_outlined,
              size: 14,
              color: dojoBlue,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                walk.walkerName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // INFO
  // ==========================================================

  Widget _walkInfo(
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
                color: dojoDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  Widget _statusChip(
    String status,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VIEW BUTTON
  // ==========================================================

  Widget _detailsButton(
    ActiveWalkData walk,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkDetails(walk);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text(
        'View',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  // ==========================================================
  // DETAILS DIALOG
  // ==========================================================

  void _showWalkDetails(
    ActiveWalkData walk,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      dojoOrange.withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons
                      .directions_walk_outlined,
                  color: dojoOrange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  walk.walkId,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoDark,
                  ),
                ),
              ),
            ],
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                _detailSection(
                  icon: Icons.person_outline,
                  color: dojoOrange,
                  title: 'Owner',
                  children: [
                    _detailRow(
                      'Owner Name',
                      walk.ownerName,
                    ),
                    _detailRow(
                      'Owner ID',
                      walk.ownerId,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _detailSection(
                  icon: Icons
                      .directions_walk_outlined,
                  color: dojoBlue,
                  title: 'Walker',
                  children: [
                    _detailRow(
                      'Walker Name',
                      walk.walkerName,
                    ),
                    _detailRow(
                      'Walker ID',
                      walk.walkerId,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _detailSection(
                  icon: Icons.pets,
                  color: dojoOrange,
                  title: 'Pet',
                  children: [
                    _detailRow(
                      'Pet Name',
                      walk.petName,
                    ),
                    _detailRow(
                      'Pet Breed',
                      walk.petBreed.isEmpty
                          ? '-'
                          : walk.petBreed,
                    ),
                    _detailRow(
                      'Pet Age',
                      walk.petAge.isEmpty
                          ? '-'
                          : walk.petAge,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _detailSection(
                  icon: Icons
                      .analytics_outlined,
                  color: dojoBlue,
                  title: 'Walk',
                  children: [
                    _detailRow(
                      'Walk ID',
                      walk.walkId,
                    ),
                    _detailRow(
                      'Duration',
                      walk.duration,
                    ),
                    _detailRow(
                      'Distance',
                      walk.distance,
                    ),
                    _detailRow(
                      'Status',
                      walk.statusLabel,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _detailSection(
                  icon: Icons
                      .location_on_outlined,
                  color: dojoGreen,
                  title: 'Live Location',
                  children: [
                    _detailRow(
                      'Latitude',
                      walk.lat != null
                          ? walk.lat!
                              .toStringAsFixed(6)
                          : 'Unavailable',
                    ),
                    _detailRow(
                      'Longitude',
                      walk.lng != null
                          ? walk.lng!
                              .toStringAsFixed(6)
                          : 'Unavailable',
                    ),
                  ],
                ),
              ],
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
                  color: dojoOrange,
                  fontWeight:
                      FontWeight.w700,
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

  Widget _detailSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
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
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                  color: dojoDark,
                ),
              ),
            ],
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
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style:
                  const TextStyle(
                color: dojoGrey,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
                color: dojoDark,
              ),
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
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .directions_walk_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No active walks',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
                color: dojoDark,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Active walks will appear here in real time.',
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

  Widget _errorState(
    String error,
  ) {
    return Center(
      child: Container(
        margin:
            const EdgeInsets.all(20),
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: dojoBorder,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: dojoOrange,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load active walks',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
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
// FIRESTORE DATA MODEL
// EXACT FIRESTORE FIELD NAMES
// ============================================================

class ActiveWalkData {
  final String documentId;

  final String walkId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerName;

  final String petName;
  final String petBreed;
  final String petAge;

  final String duration;
  final String distance;

  final String status;

  final double? lat;
  final double? lng;

  const ActiveWalkData({
    required this.documentId,
    required this.walkId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerName,
    required this.petName,
    required this.petBreed,
    required this.petAge,
    required this.duration,
    required this.distance,
    required this.status,
    required this.lat,
    required this.lng,
  });

  // ==========================================================
  // FROM FIRESTORE
  // ==========================================================

  factory ActiveWalkData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return ActiveWalkData(
      documentId: documentId,

      // EXACT FIELD
      walkId:
          _string(data, 'walkId') ??
              documentId,

      // EXACT FIELD
      ownerId:
          _string(data, 'ownerId') ??
              '-',

      // EXACT FIELD
      ownerName:
          _string(data, 'ownerName') ??
              'Owner',

      // EXACT FIELD
      walkerId:
          _string(data, 'walkerId') ??
              '-',

      // EXACT FIELD
      walkerName:
          _string(data, 'walkerName') ??
              'Walker',

      // EXACT FIELD
      petName:
          _string(data, 'petName') ??
              'Dog',

      // EXACT FIELD
      petBreed:
          _string(data, 'petBreed') ??
              '',

      // EXACT FIELD
      petAge:
          _string(data, 'petAge') ??
              '',

      // EXACT FIELD
      duration:
          _string(data, 'duration') ??
              '',

      // EXACT FIELD
      distance:
          _string(data, 'distance') ??
              '',

      // EXACT FIELD
      status:
          (_string(data, 'status') ??
                  'active')
              .toLowerCase(),

      // EXACT FIELD
      lat: _double(
        data['currentLat'],
      ),

      // EXACT FIELD
      lng: _double(
        data['currentLng'],
      ),
    );
  }

  // ==========================================================
  // STATUS LABEL
  // ==========================================================

  String get statusLabel {
    switch (status) {
      case 'active':
      case 'live':
        return 'Live';

      case 'paused':
        return 'Paused';

      case 'completed':
        return 'Completed';

      default:
        return status.isEmpty
            ? 'Live'
            : status;
    }
  }

  bool get hasLocation =>
      lat != null && lng != null;
}

// ============================================================
// FIRESTORE HELPERS
// ============================================================

String? _string(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  final text =
      value.toString().trim();

  return text.isEmpty
      ? null
      : text;
}

double? _double(
  dynamic value,
) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
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
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
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
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w900,
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
