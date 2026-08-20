import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});

  @override
  State<WalkHistoryScreen> createState() =>
      _WalkHistoryScreenState();
}

class _WalkHistoryScreenState
    extends State<WalkHistoryScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _historyStream {
    return _firestore
        .collection('walkHistory')
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
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
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

        final docs =
            snapshot.data?.docs ?? [];

        return _buildContent(docs);
      },
    );
  }

  Widget _buildContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final histories = docs
        .map(
          (doc) => WalkHistoryData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();

    histories.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    final filtered =
        _filterHistory(histories);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(histories),

        const SizedBox(height: 20),

        _toolbar(),

        const SizedBox(height: 16),

        _historyList(filtered),
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
          'Walk History',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'View completed walks and their full history',
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
    List<WalkHistoryData> walks,
  ) {
    final totalDistance =
        walks.fold<double>(
      0,
      (sum, walk) =>
          sum + walk.distanceKm,
    );

    final averageRating =
        walks.isEmpty
            ? 0.0
            : walks.fold<int>(
                  0,
                  (sum, walk) =>
                      sum + walk.rating,
                ) /
                walks.length;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
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
              title: 'Total Walks',
              value: '${walks.length}',
              icon:
                  Icons.history_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total Distance',
              value:
                  '${totalDistance.toStringAsFixed(1)} km',
              icon:
                  Icons.route_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Average Rating',
              value:
                  averageRating.toStringAsFixed(1),
              icon:
                  Icons.star_outline,
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
      padding:
          const EdgeInsets.all(14),
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

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText:
            'Search walk, owner, walker or pet...',
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

  Widget _filters() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('Rated'),
        _filterButton('Unrated'),
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
            fontWeight:
                selected
                    ? FontWeight.w800
                    : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<WalkHistoryData> _filterHistory(
    List<WalkHistoryData> walks,
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
          walk.walkerUid
              .toLowerCase()
              .contains(query) ||
          walk.dogName
              .toLowerCase()
              .contains(query) ||
          walk.dogBreed
              .toLowerCase()
              .contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Rated' &&
              walk.rating > 0) ||
          (selectedFilter == 'Unrated' &&
              walk.rating == 0);

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }

  // ==========================================================
  // HISTORY LIST
  // ==========================================================

  Widget _historyList(
    List<WalkHistoryData> walks,
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
          child: _historyCard(walk),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // HISTORY CARD
  // ==========================================================

  Widget _historyCard(
    WalkHistoryData walk,
  ) {
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
            return _mobileHistoryCard(
              walk,
            );
          }

          return _desktopHistoryCard(
            walk,
          );
        },
      ),
    );
  }

  // ==========================================================
  // DESKTOP
  // ==========================================================

  Widget _desktopHistoryCard(
    WalkHistoryData walk,
  ) {
    return Row(
      children: [
        _dogAvatar(walk),

        const SizedBox(width: 14),

        Expanded(
          flex: 3,
          child: _mainInfo(walk),
        ),

        Expanded(
          child: _historyInfo(
            Icons.timer_outlined,
            'Duration',
            '${walk.durationMinutes} min',
          ),
        ),

        Expanded(
          child: _historyInfo(
            Icons.route_outlined,
            'Distance',
            '${walk.distanceKm.toStringAsFixed(1)} km',
          ),
        ),

        _ratingChip(walk.rating),

        const SizedBox(width: 12),

        _viewButton(walk),
      ],
    );
  }

  // ==========================================================
  // MOBILE
  // ==========================================================

  Widget _mobileHistoryCard(
    WalkHistoryData walk,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _dogAvatar(walk),

            const SizedBox(width: 12),

            Expanded(
              child: _mainInfo(walk),
            ),

            _ratingChip(
              walk.rating,
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _historyInfo(
                Icons.timer_outlined,
                'Duration',
                '${walk.durationMinutes} min',
              ),
            ),
            Expanded(
              child: _historyInfo(
                Icons.route_outlined,
                'Distance',
                '${walk.distanceKm.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: dojoBlue,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${walk.date} • ${walk.timeFormatted}',
                style:
                    const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
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
  // DOG AVATAR
  // ==========================================================

  Widget _dogAvatar(
    WalkHistoryData walk,
  ) {
    if (walk.dogPhoto.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: Image.network(
          walk.dogPhoto,
          width: 55,
          height: 55,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return _defaultDogAvatar();
          },
        ),
      );
    }

    return _defaultDogAvatar();
  }

  Widget _defaultDogAvatar() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFEEE9),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 27,
      ),
    );
  }

  // ==========================================================
  // MAIN INFO
  // ==========================================================

  Widget _mainInfo(
    WalkHistoryData walk,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                walk.walkId,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                  color: dojoDark,
                ),
              ),
            ),
            if (walk.badge.isNotEmpty) ...[
              const SizedBox(width: 7),
              _badge(walk.badge),
            ],
          ],
        ),

        const SizedBox(height: 4),

        Text(
          walk.dogName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (walk.dogBreed.isNotEmpty)
          Text(
            walk.dogBreed,
            style: const TextStyle(
              fontSize: 10,
              color: dojoGrey,
            ),
          ),

        const SizedBox(height: 3),

        Text(
          '${walk.ownerName} • ${walk.walkerName}',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '${walk.date} • ${walk.timeFormatted}',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BADGE
  // ==========================================================

  Widget _badge(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF3D9),
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow:
            TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF9A6A00),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ==========================================================
  // INFO
  // ==========================================================

  Widget _historyInfo(
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
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // RATING
  // ==========================================================

  Widget _ratingChip(int rating) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF7E6),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Color(0xFFD99A00),
          ),
          const SizedBox(width: 4),
          Text(
            rating > 0
                ? '$rating'
                : '-',
            style: const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              color:
                  Color(0xFF9A6A00),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VIEW BUTTON
  // ==========================================================

  Widget _viewButton(
    WalkHistoryData walk,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showWalkDetails(walk);
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
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
  // DETAILS
  // ==========================================================

  void _showWalkDetails(
    WalkHistoryData walk,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.history_outlined,
                color: dojoOrange,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  walk.walkId,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (walk.badge.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),
                    child: _badge(
                      walk.badge,
                    ),
                  ),

                _sectionTitle(
                  'Dog',
                ),

                _detailRow(
                  'Name',
                  walk.dogName,
                ),

                _detailRow(
                  'Breed',
                  walk.dogBreed.isEmpty
                      ? '-'
                      : walk.dogBreed,
                ),

                const SizedBox(height: 7),

                _sectionTitle(
                  'Owner',
                ),

                _detailRow(
                  'Name',
                  walk.ownerName,
                ),

                _detailRow(
                  'Owner ID',
                  walk.ownerId,
                ),

                const SizedBox(height: 7),

                _sectionTitle(
                  'Walker',
                ),

                _detailRow(
                  'Name',
                  walk.walkerName,
                ),

                _detailRow(
                  'Walker UID',
                  walk.walkerUid,
                ),

                if (walk.walkerNote.isNotEmpty)
                  _detailRow(
                    'Note',
                    walk.walkerNote,
                  ),

                const SizedBox(height: 7),

                _sectionTitle(
                  'Walk Summary',
                ),

                _detailRow(
                  'Date',
                  walk.date,
                ),

                _detailRow(
                  'Time',
                  walk.timeFormatted,
                ),

                _detailRow(
                  'Duration',
                  '${walk.durationMinutes} min',
                ),

                _detailRow(
                  'Distance',
                  '${walk.distanceKm.toStringAsFixed(2)} km',
                ),

                _detailRow(
                  'Pee',
                  '${walk.peeCount}',
                ),

                _detailRow(
                  'Poop',
                  '${walk.poopCount}',
                ),

                _detailRow(
                  'Rating',
                  walk.rating > 0
                      ? '${walk.rating}/5'
                      : '-',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: dojoOrange,
        ),
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty
                  ? '-'
                  : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
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
              Icons.history_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No walk history',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Completed walks will appear here.',
              textAlign:
                  TextAlign.center,
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
    return Container(
      width: double.infinity,
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
        children: [
          const Icon(
            Icons.error_outline,
            size: 45,
            color: dojoOrange,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load walk history',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FIRESTORE MODEL
// ============================================================

class WalkHistoryData {
  final String documentId;

  final String walkId;
  final String badge;

  final int createdAt;

  final String date;
  final String timeFormatted;

  final double distanceKm;
  final int durationMinutes;

  final String dogName;
  final String dogBreed;
  final String dogPhoto;

  final String ownerId;
  final String ownerName;

  final String walkerName;
  final String walkerUid;
  final String walkerNote;
  final String walkerProfileImage;

  final int peeCount;
  final int poopCount;
  final int rating;

  const WalkHistoryData({
    required this.documentId,
    required this.walkId,
    required this.badge,
    required this.createdAt,
    required this.date,
    required this.timeFormatted,
    required this.distanceKm,
    required this.durationMinutes,
    required this.dogName,
    required this.dogBreed,
    required this.dogPhoto,
    required this.ownerId,
    required this.ownerName,
    required this.walkerName,
    required this.walkerUid,
    required this.walkerNote,
    required this.walkerProfileImage,
    required this.peeCount,
    required this.poopCount,
    required this.rating,
  });

  factory WalkHistoryData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return WalkHistoryData(
      documentId: documentId,

      // Exact Firestore field:
      walkId:
          _string(data, 'id') ??
          documentId,

      badge:
          _string(data, 'badge') ?? '',

      createdAt:
          _int(data['createdAt']) ?? 0,

      date:
          _string(data, 'date') ?? '',

      timeFormatted:
          _string(
            data,
            'timeFormatted',
          ) ??
          '',

      distanceKm:
          _double(data['distanceKm']) ?? 0,

      durationMinutes:
          _int(data['durationMinutes']) ?? 0,

      dogName:
          _string(data, 'dogName') ?? 'Dog',

      dogBreed:
          _string(data, 'dogBreed') ?? '',

      dogPhoto:
          _string(data, 'dogPhoto') ?? '',

      ownerId:
          _string(data, 'ownerId') ?? '-',

      ownerName:
          _string(data, 'ownerName') ?? 'Owner',

      walkerName:
          _string(data, 'walkerName') ?? 'Walker',

      // Exact Firestore field is lowercase:
      walkerUid:
          _string(data, 'walkeruid') ?? '-',

      walkerNote:
          _string(data, 'walkerNote') ?? '',

      walkerProfileImage:
          _string(
            data,
            'walkerProfileImage',
          ) ??
          '',

      peeCount:
          _int(data['peeCount']) ?? 0,

      poopCount:
          _int(data['poopCount']) ?? 0,

      rating:
          _int(data['rating']) ?? 0,
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

int? _int(
  dynamic value,
) {
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
  Widget build(
    BuildContext context,
  ) {
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
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
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
