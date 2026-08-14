import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBackground = Color(0xFFF7F8FA);
const Color dojoBorder = Color(0xFFE7E9ED);

class ActiveWalksScreen extends StatefulWidget {
  const ActiveWalksScreen({super.key});

  @override
  State<ActiveWalksScreen> createState() => _ActiveWalksScreenState();
}

class _ActiveWalksScreenState extends State<ActiveWalksScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
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
    );
  }

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

    final filtered = _filterWalks(walks);

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
        _filterButton('Live'),
        _filterButton('Paused'),
      ],
    );
  }

  Widget _filterButton(
    String title,
  ) {
    final bool selected =
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

  List<ActiveWalkData> _filterWalks(
    List<ActiveWalkData> walks,
  ) {
    final query =
        searchController.text.trim().toLowerCase();

    return walks.where((walk) {
      final matchesSearch =
          query.isEmpty ||
          walk.walkId
              .toLowerCase()
              .contains(query) ||
          walk.ownerName
              .toLowerCase()
              .contains(query) ||
          walk.walkerName
              .toLowerCase()
              .contains(query) ||
          walk.petName
              .toLowerCase()
              .contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Live' &&
              walk.status == 'active') ||
          (selectedFilter == 'Paused' &&
              walk.status == 'paused');

      return matchesSearch && matchesFilter;
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
    final bool live =
        walk.status == 'active';

    final Color statusColor =
        live
            ? dojoGreen
            : dojoOrange;

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
  // DESKTOP CARD
  // ==========================================================

  Widget _desktopWalkCard(
    ActiveWalkData walk,
    Color statusColor,
  ) {
    return Row(
      children: [
        _petAvatar(walk),

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
  // MOBILE CARD
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
            _petAvatar(walk),

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

        const SizedBox(height: 10),

        if (walk.hasLocation)
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: dojoGreen,
              ),
              const SizedBox(width: 5),
              Text(
                '${walk.lat!.toStringAsFixed(5)}, '
                '${walk.lng!.toStringAsFixed(5)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: dojoGrey,
                ),
              ),
            ],
          ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _detailsButton(walk),
        ),
      ],
    );
  }

  // ==========================================================
  // PET AVATAR
  // ==========================================================

  Widget _petAvatar(
    ActiveWalkData walk,
  ) {
    if (walk.dogPhoto.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: Image.network(
          walk.dogPhoto,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return _defaultPetAvatar();
          },
        ),
      );
    }

    return _defaultPetAvatar();
  }

  Widget _defaultPetAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFEEE9),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 25,
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
        Text(
          walk.walkId,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          walk.petName,
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
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.directions_walk_outlined,
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _detailRow(
                  'Owner',
                  walk.ownerName,
                ),
                _detailRow(
                  'Owner UID',
                  walk.ownerUid,
                ),
                _detailRow(
                  'Walker',
                  walk.walkerName,
                ),
                _detailRow(
                  'Walker UID',
                  walk.walkerUid,
                ),
                _detailRow(
                  'Pet',
                  walk.petName,
                ),
                _detailRow(
                  'Breed',
                  walk.dogBreed.isEmpty
                      ? '-'
                      : walk.dogBreed,
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
                _detailRow(
                  'Pee',
                  '${walk.peeCount}',
                ),
                _detailRow(
                  'Poop',
                  '${walk.poopCount}',
                ),
                _detailRow(
                  'Location',
                  walk.hasLocation
                      ? '${walk.lat!.toStringAsFixed(6)}, '
                          '${walk.lng!.toStringAsFixed(6)}'
                      : 'Unavailable',
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

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
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
              value,
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
              Icons.directions_walk_outlined,
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

  Widget _errorState(String error) {
    return Container(
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
          const Icon(
            Icons.error_outline,
            size: 45,
            color: dojoOrange,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load active walks',
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
    );
  }
}

// ============================================================
// FIREBASE DATA MODEL
// ============================================================

class ActiveWalkData {
  final String documentId;
  final String walkId;

  final String ownerUid;
  final String ownerName;

  final String walkerUid;
  final String walkerName;

  final String petName;
  final String dogBreed;
  final String dogPhoto;

  final String duration;
  final String distance;

  final String status;

  final double? lat;
  final double? lng;

  final int peeCount;
  final int poopCount;

  const ActiveWalkData({
    required this.documentId,
    required this.walkId,
    required this.ownerUid,
    required this.ownerName,
    required this.walkerUid,
    required this.walkerName,
    required this.petName,
    required this.dogBreed,
    required this.dogPhoto,
    required this.duration,
    required this.distance,
    required this.status,
    required this.lat,
    required this.lng,
    required this.peeCount,
    required this.poopCount,
  });

  factory ActiveWalkData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final walkId =
        _string(data, 'walkId') ??
        documentId;

    final ownerUid =
        _string(data, 'ownerUid') ??
        _string(data, 'ownerId') ??
        '-';

    final walkerUid =
        _string(data, 'walkerUid') ??
        _string(data, 'walkeruid') ??
        _string(data, 'walkerId') ??
        '-';

    final ownerName =
        _string(data, 'ownerName') ??
        'Owner';

    final walkerName =
        _string(data, 'walkerName') ??
        'Walker';

    final petName =
        _string(data, 'dogName') ??
        _string(data, 'petName') ??
        'Dog';

    final breed =
        _string(data, 'dogBreed') ?? '';

    final photo =
        _string(data, 'dogPhoto') ?? '';

    final distanceKm =
        _double(data['distanceKm']) ??
        _double(data['distance']) ??
        0;

    final durationMinutes =
        _int(data['durationMinutes']) ??
        _int(data['duration']) ??
        0;

    final rawStatus =
        (_string(data, 'status') ?? 'active')
            .toLowerCase();

    final status =
        rawStatus == 'paused'
            ? 'paused'
            : rawStatus == 'live'
                ? 'active'
                : rawStatus;

    return ActiveWalkData(
      documentId: documentId,
      walkId: walkId,
      ownerUid: ownerUid,
      ownerName: ownerName,
      walkerUid: walkerUid,
      walkerName: walkerName,
      petName: petName,
      dogBreed: breed,
      dogPhoto: photo,
      duration:
          '$durationMinutes min',
      distance:
          '${distanceKm.toStringAsFixed(1)} km',
      status: status,
      lat: _double(
        data['currentLat'] ??
            data['lat'] ??
            data['latitude'],
      ),
      lng: _double(
        data['currentLng'] ??
            data['lng'] ??
            data['longitude'],
      ),
      peeCount:
          _int(data['peeCount']) ?? 0,
      poopCount:
          _int(data['poopCount']) ?? 0,
    );
  }

  String get statusLabel {
    if (status == 'active') {
      return 'Live';
    }

    if (status == 'paused') {
      return 'Paused';
    }

    return status.isEmpty
        ? 'Live'
        : status;
  }

  bool get hasLocation =>
      lat != null && lng != null;
}

// ============================================================
// FIREBASE HELPERS
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
