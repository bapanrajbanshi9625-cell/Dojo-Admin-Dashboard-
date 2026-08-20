import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFD64545);
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

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  // ==========================================================
  // FIRESTORE STREAMS
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _historyStream {
    return _firestore
        .collection('walkHistory')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _activeWalkStream {
    return _firestore
        .collection('activeWalk')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _liveSessionStream {
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, historySnapshot) {
        if (historySnapshot.hasError) {
          return _errorState(
            historySnapshot.error.toString(),
          );
        }

        if (historySnapshot.connectionState ==
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

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _activeWalkStream,
          builder: (context, activeSnapshot) {
            if (activeSnapshot.hasError) {
              return _errorState(
                activeSnapshot.error.toString(),
              );
            }

            if (activeSnapshot.connectionState ==
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

            return StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _liveSessionStream,
              builder: (context, liveSnapshot) {
                if (liveSnapshot.hasError) {
                  return _errorState(
                    liveSnapshot.error.toString(),
                  );
                }

                if (liveSnapshot.connectionState ==
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

                final histories =
                    _parseHistory(
                  historySnapshot.data?.docs ?? [],
                );

                final activeWalks =
                    _parseActiveWalks(
                  activeSnapshot.data?.docs ?? [],
                );

                final liveSessions =
                    _parseLiveSessions(
                  liveSnapshot.data?.docs ?? [],
                );

                histories.sort(
                  (a, b) => b.createdAt.compareTo(
                    a.createdAt,
                  ),
                );

                final filtered =
                    _filterHistory(histories);

                return _buildContent(
                  histories,
                  filtered,
                  activeWalks,
                  liveSessions,
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // PARSERS
  // ==========================================================

  List<WalkHistoryData> _parseHistory(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map(
          (doc) => WalkHistoryData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  List<ActiveWalkData> _parseActiveWalks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map(
          (doc) => ActiveWalkData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .where((walk) => walk.isActive)
        .toList();
  }

  List<LiveWalkSessionData> _parseLiveSessions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map(
          (doc) => LiveWalkSessionData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent(
    List<WalkHistoryData> histories,
    List<WalkHistoryData> filtered,
    List<ActiveWalkData> activeWalks,
    List<LiveWalkSessionData> liveSessions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),

        const SizedBox(height: 20),

        _summaryCards(
          histories,
          activeWalks.length,
        ),

        const SizedBox(height: 20),

        if (activeWalks.isNotEmpty) ...[
          _liveSection(
            activeWalks,
            liveSessions,
          ),
          const SizedBox(height: 22),
        ],

        _toolbar(),

        const SizedBox(height: 16),

        _historyHeader(filtered.length),

        const SizedBox(height: 10),

        _historyList(filtered),
      ],
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
          'Walk History',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Monitor live walks and view completed walk history',
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
    int liveCount,
  ) {
    final totalDistance = walks.fold<double>(
      0,
      (sum, walk) => sum + walk.distanceKm,
    );

    final averageRating = walks.isEmpty
        ? 0.0
        : walks.fold<int>(
              0,
              (sum, walk) => sum + walk.rating,
            ) /
            walks.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns =
            constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 700
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
              title: 'Live Walks',
              value: '$liveCount',
              icon: Icons.radio_button_checked,
              color: dojoRed,
            ),
            _SummaryCard(
              title: 'Total Walks',
              value: '${walks.length}',
              icon: Icons.history_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Total Distance',
              value:
                  '${totalDistance.toStringAsFixed(1)} km',
              icon: Icons.route_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Average Rating',
              value:
                  averageRating.toStringAsFixed(1),
              icon: Icons.star_outline,
              color: dojoGreen,
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // LIVE SECTION
  // ==========================================================

  Widget _liveSection(
    List<ActiveWalkData> activeWalks,
    List<LiveWalkSessionData> liveSessions,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: dojoRed.withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.radio_button_checked,
                  color: dojoRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Walks',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: dojoDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Currently active walks',
                      style: TextStyle(
                        fontSize: 11,
                        color: dojoGrey,
                      ),
                    ),
                  ],
                ),
              ),
              _liveCountBadge(
                activeWalks.length,
              ),
            ],
          ),

          const SizedBox(height: 15),

          ...activeWalks.map(
            (activeWalk) {
              final session =
                  _findSessionForActiveWalk(
                activeWalk,
                liveSessions,
              );

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                child: _liveWalkCard(
                  activeWalk,
                  session,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _liveCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: dojoRed.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: dojoRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count LIVE',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: dojoRed,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LIVE CARD
  // ==========================================================

  Widget _liveWalkCard(
    ActiveWalkData active,
    LiveWalkSessionData? session,
  ) {
    final dogName = _firstNonEmpty([
      session?.dogName,
      active.dogName,
    ], 'Dog');

    final ownerId = _firstNonEmpty([
      session?.ownerId,
      active.ownerId,
    ], '-');

    final walkerId = _firstNonEmpty([
      session?.walkerId,
      active.walkerId,
    ], '-');

    final distance =
        session?.distanceKm ??
        active.distanceKm;

    final elapsed =
        session?.elapsedSeconds ??
        active.elapsedSeconds;

    final pee =
        session?.peeCount ??
        active.peeCount;

    final poop =
        session?.poopCount ??
        active.poopCount;

    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap: () {
        _showLiveWalkDetails(
          active,
          session,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF8),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF0D9D2),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _mobileLiveCard(
                active,
                session,
                dogName,
                ownerId,
                walkerId,
                distance,
                elapsed,
                pee,
                poop,
              );
            }

            return _desktopLiveCard(
              active,
              session,
              dogName,
              ownerId,
              walkerId,
              distance,
              elapsed,
              pee,
              poop,
            );
          },
        ),
      ),
    );
  }

  Widget _desktopLiveCard(
    ActiveWalkData active,
    LiveWalkSessionData? session,
    String dogName,
    String ownerId,
    String walkerId,
    double distance,
    int elapsed,
    int pee,
    int poop,
  ) {
    return Row(
      children: [
        _liveDogAvatar(
          active.dogPhoto,
        ),

        const SizedBox(width: 13),

        Expanded(
          flex: 3,
          child: _liveMainInfo(
            dogName,
            ownerId,
            walkerId,
          ),
        ),

        Expanded(
          child: _liveMetric(
            Icons.timer_outlined,
            'Duration',
            _formatElapsed(elapsed),
          ),
        ),

        Expanded(
          child: _liveMetric(
            Icons.route_outlined,
            'Distance',
            '${distance.toStringAsFixed(1)} km',
          ),
        ),

        Expanded(
          child: _liveMetric(
            Icons.pets_outlined,
            'Pee / Poop',
            '$pee / $poop',
          ),
        ),

        const SizedBox(width: 10),

        _liveViewButton(
          active,
          session,
        ),
      ],
    );
  }

  Widget _mobileLiveCard(
    ActiveWalkData active,
    LiveWalkSessionData? session,
    String dogName,
    String ownerId,
    String walkerId,
    double distance,
    int elapsed,
    int pee,
    int poop,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _liveDogAvatar(
              active.dogPhoto,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _liveMainInfo(
                dogName,
                ownerId,
                walkerId,
              ),
            ),
            _liveStatusChip(),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _liveMetric(
                Icons.timer_outlined,
                'Duration',
                _formatElapsed(elapsed),
              ),
            ),
            Expanded(
              child: _liveMetric(
                Icons.route_outlined,
                'Distance',
                '${distance.toStringAsFixed(1)} km',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _liveMetric(
                Icons.water_drop_outlined,
                'Pee',
                '$pee',
              ),
            ),
            Expanded(
              child: _liveMetric(
                Icons.circle_outlined,
                'Poop',
                '$poop',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: _liveViewButton(
            active,
            session,
          ),
        ),
      ],
    );
  }

  Widget _liveDogAvatar(String url) {
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: Image.network(
          url,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return _defaultLiveAvatar();
          },
        ),
      );
    }

    return _defaultLiveAvatar();
  }

  Widget _defaultLiveAvatar() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.pets,
        color: dojoOrange,
        size: 26,
      ),
    );
  }

  Widget _liveMainInfo(
    String dogName,
    String ownerId,
    String walkerId,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                dogName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: dojoDark,
                ),
              ),
            ),
            const SizedBox(width: 7),
            _liveStatusChip(),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Owner: $ownerId',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Walker ID: $walkerId',
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

  Widget _liveStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: dojoRed.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: dojoRed,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _liveMetric(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
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
                fontSize: 9,
                color: dojoGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: dojoDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _liveViewButton(
    ActiveWalkData active,
    LiveWalkSessionData? session,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        _showLiveWalkDetails(
          active,
          session,
        );
      },
      icon: const Icon(
        Icons.visibility_outlined,
        size: 16,
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
          vertical: 10,
        ),
      ),
    );
  }

  // ==========================================================
  // FIND LIVE SESSION
  // ==========================================================

  LiveWalkSessionData? _findSessionForActiveWalk(
    ActiveWalkData active,
    List<LiveWalkSessionData> sessions,
  ) {
    for (final session in sessions) {
      if (active.sessionId.isNotEmpty &&
          session.id == active.sessionId) {
        return session;
      }

      if (active.walkId.isNotEmpty &&
          session.walkId == active.walkId) {
        return session;
      }

      if (active.ownerId.isNotEmpty &&
          session.ownerId == active.ownerId &&
          active.walkerId.isNotEmpty &&
          session.walkerId == active.walkerId) {
        return session;
      }

      if (active.ownerId.isNotEmpty &&
          session.ownerId == active.ownerId &&
          active.dogName.isNotEmpty &&
          session.dogName == active.dogName) {
        return session;
      }
    }

    return null;
  }

  // ==========================================================
  // LIVE DETAILS
  // ==========================================================

  void _showLiveWalkDetails(
    ActiveWalkData active,
    LiveWalkSessionData? session,
  ) {
    final dogName = _firstNonEmpty([
      session?.dogName,
      active.dogName,
    ], 'Dog');

    final ownerId = _firstNonEmpty([
      session?.ownerId,
      active.ownerId,
    ], '-');

    final walkerId = _firstNonEmpty([
      session?.walkerId,
      active.walkerId,
    ], '-');

    final distance =
        session?.distanceKm ??
        active.distanceKm;

    final elapsed =
        session?.elapsedSeconds ??
        active.elapsedSeconds;

    final pee =
        session?.peeCount ??
        active.peeCount;

    final poop =
        session?.poopCount ??
        active.poopCount;

    final location =
        session?.location ??
        active.location;

    final route =
        session?.routeCoordinates ??
        <RouteCoordinate>[];

    final events =
        session?.events ??
        <WalkEvent>[];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 600,
              maxHeight: 720,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              dojoRed.withOpacity(.10),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons
                              .radio_button_checked,
                          color: dojoRed,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              dogName,
                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w900,
                                color:
                                    dojoDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Live Walk Details',
                              style:
                                  TextStyle(
                                fontSize: 11,
                                color:
                                    dojoGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _liveStatusChip(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _liveDetailStats(
                            distance,
                            elapsed,
                            pee,
                            poop,
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          _detailSection(
                            'Participants',
                            [
                              _detailRow(
                                'Owner ID',
                                ownerId,
                              ),
                              _detailRow(
                                'Walker ID',
                                walkerId,
                              ),
                              _detailRow(
                                'Walker UID',
                                _firstNonEmpty([
                                  session
                                      ?.walkerUid,
                                  active.walkerUid,
                                ], '-'),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _detailSection(
                            'Current Location',
                            [
                              _detailRow(
                                'Latitude',
                                location == null
                                    ? '-'
                                    : location.lat
                                        .toStringAsFixed(
                                        7,
                                      ),
                              ),
                              _detailRow(
                                'Longitude',
                                location == null
                                    ? '-'
                                    : location.lng
                                        .toStringAsFixed(
                                        7,
                                      ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _detailSection(
                            'Route',
                            [
                              _detailRow(
                                'GPS Points',
                                '${route.length}',
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              if (route.isNotEmpty)
                                _routePreview(
                                  route,
                                )
                              else
                                const Text(
                                  'No route points available yet.',
                                  style:
                                      TextStyle(
                                    fontSize: 11,
                                    color:
                                        dojoGrey,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _detailSection(
                            'Events',
                            [
                              if (events.isEmpty)
                                const Text(
                                  'No events recorded.',
                                  style:
                                      TextStyle(
                                    fontSize: 11,
                                    color:
                                        dojoGrey,
                                  ),
                                )
                              else
                                ...events.map(
                                  _eventTile,
                                ),
                            ],
                          ),
                        ],
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

  Widget _liveDetailStats(
    double distance,
    int elapsed,
    int pee,
    int poop,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: [
        _LiveDetailStat(
          title: 'Distance',
          value:
              '${distance.toStringAsFixed(2)} km',
          icon: Icons.route_outlined,
          color: dojoBlue,
        ),
        _LiveDetailStat(
          title: 'Duration',
          value: _formatElapsed(elapsed),
          icon: Icons.timer_outlined,
          color: dojoOrange,
        ),
        _LiveDetailStat(
          title: 'Pee',
          value: '$pee',
          icon: Icons.water_drop_outlined,
          color: dojoBlue,
        ),
        _LiveDetailStat(
          title: 'Poop',
          value: '$poop',
          icon: Icons.circle_outlined,
          color: dojoGreen,
        ),
      ],
    );
  }

  Widget _detailSection(
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
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

  Widget _routePreview(
    List<RouteCoordinate> route,
  ) {
    final first = route.first;
    final last = route.last;

    return Container(
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.polyline_outlined,
            color: dojoBlue,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Route recorded: '
              '${route.length} points\n'
              'Start: ${first.lat.toStringAsFixed(5)}, '
              '${first.lng.toStringAsFixed(5)}\n'
              'Latest: ${last.lat.toStringAsFixed(5)}, '
              '${last.lng.toStringAsFixed(5)}',
              style: const TextStyle(
                fontSize: 10,
                height: 1.5,
                color: dojoGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventTile(WalkEvent event) {
    IconData icon;

    switch (event.type.toLowerCase()) {
      case 'pee':
        icon = Icons.water_drop_outlined;
        break;
      case 'poop':
        icon = Icons.circle_outlined;
        break;
      default:
        icon = Icons.event_note_outlined;
    }

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
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
                  event.type.isEmpty
                      ? 'Event'
                      : event.type,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                if (event.note.isNotEmpty)
                  Text(
                    event.note,
                    style:
                        const TextStyle(
                      fontSize: 10,
                      color: dojoGrey,
                    ),
                  ),
                if (event.timestamp.isNotEmpty)
                  Text(
                    event.timestamp,
                    style:
                        const TextStyle(
                      fontSize: 9,
                      color: dojoGrey,
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
          borderSide:
              const BorderSide(
            color: dojoBorder,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(11),
          borderSide:
              const BorderSide(
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

  Widget _filterButton(String title) {
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
  // HISTORY FILTER
  // ==========================================================

  List<WalkHistoryData> _filterHistory(
    List<WalkHistoryData> walks,
  ) {
    final query = searchController.text
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

  Widget _historyHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Completed Walks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: dojoDark,
            ),
          ),
        ),
        Text(
          '$count walks',
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
            _ratingChip(walk.rating),
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
                style: const TextStyle(
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
  // MAIN HISTORY INFO
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
            rating > 0 ? '$rating' : '-',
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
  // HISTORY DETAILS
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
                  style: const TextStyle(
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
                _sectionTitle('Dog'),
                _detailRow(
                  'Name',
                  walk.dogName,
                ),
                _detailRow(
                  'Breed',
                  walk.dogBreed,
                ),
                const SizedBox(height: 7),
                _sectionTitle('Owner'),
                _detailRow(
                  'Name',
                  walk.ownerName,
                ),
                _detailRow(
                  'Owner ID',
                  walk.ownerId,
                ),
                const SizedBox(height: 7),
                _sectionTitle('Walker'),
                _detailRow(
                  'Name',
                  walk.walkerName,
                ),
                _detailRow(
                  'Walker ID',
                  walk.walkerId,
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
                _sectionTitle('Walk Summary'),
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
              child:
                  const Text('Close'),
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

  Widget _errorState(String error) {
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
            'Unable to load walk data',
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
// ACTIVE WALK MODEL
// ============================================================

class ActiveWalkData {
  final String documentId;

  final String id;
  final String walkId;
  final String sessionId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerUid;

  final String dogName;
  final String dogPhoto;

  final bool isActive;

  final double distanceKm;
  final int elapsedSeconds;

  final int peeCount;
  final int poopCount;

  final LocationData? location;

  const ActiveWalkData({
    required this.documentId,
    required this.id,
    required this.walkId,
    required this.sessionId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerUid,
    required this.dogName,
    required this.dogPhoto,
    required this.isActive,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.peeCount,
    required this.poopCount,
    required this.location,
  });

  factory ActiveWalkData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return ActiveWalkData(
      documentId: documentId,
      id: _string(data, 'id') ?? documentId,
      walkId: _string(data, 'walkId') ??
          _string(data, 'id') ??
          '',
      sessionId:
          _string(data, 'sessionId') ?? '',
      ownerId:
          _string(data, 'ownerId') ?? '',
      ownerName:
          _string(data, 'ownerName') ?? '',
      walkerId:
          _string(data, 'walkerId') ??
          _string(data, 'walkerID') ??
          '',
      walkerUid:
          _string(data, 'walkerUid') ??
          _string(data, 'walkeruid') ??
          '',
      dogName:
          _string(data, 'dogName') ?? 'Dog',
      dogPhoto:
          _string(data, 'dogPhoto') ?? '',
      isActive:
          _bool(data, 'isActive') ??
              _bool(data, 'active') ??
              true,
      distanceKm:
          _double(data['distanceKm']) ?? 0,
      elapsedSeconds:
          _int(data['elapsedSeconds']) ?? 0,
      peeCount:
          _int(data['peeCount']) ?? 0,
      poopCount:
          _int(data['poopCount']) ?? 0,
      location:
          LocationData.fromDynamic(
        data['location'],
      ),
    );
  }
}

// ============================================================
// LIVE WALK SESSION MODEL
// ============================================================

class LiveWalkSessionData {
  final String documentId;

  final String id;
  final String walkId;

  final String ownerId;
  final String ownerName;

  final String walkerId;
  final String walkerUid;

  final String dogName;
  final String dogPhoto;

  final double distanceKm;
  final int elapsedSeconds;

  final int peeCount;
  final int poopCount;

  final LocationData? location;

  final List<RouteCoordinate>
      routeCoordinates;

  final List<WalkEvent> events;

  const LiveWalkSessionData({
    required this.documentId,
    required this.id,
    required this.walkId,
    required this.ownerId,
    required this.ownerName,
    required this.walkerId,
    required this.walkerUid,
    required this.dogName,
    required this.dogPhoto,
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.peeCount,
    required this.poopCount,
    required this.location,
    required this.routeCoordinates,
    required this.events,
  });

  factory LiveWalkSessionData.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final routeRaw =
        data['routeCoordinates'];

    final eventsRaw =
        data['events'];

    return LiveWalkSessionData(
      documentId: documentId,

      id:
          _string(data, 'id') ??
          documentId,

      walkId:
          _string(data, 'walkId') ??
          _string(data, 'id') ??
          '',

      ownerId:
          _string(data, 'ownerId') ?? '',

      ownerName:
          _string(data, 'ownerName') ?? '',

      walkerId:
          _string(data, 'walkerId') ??
          _string(data, 'walkerID') ??
          '',

      walkerUid:
          _string(data, 'walkerUid') ??
          _string(data, 'walkeruid') ??
          '',

      dogName:
          _string(data, 'dogName') ?? 'Dog',

      dogPhoto:
          _string(data, 'dogPhoto') ?? '',

      distanceKm:
          _double(data['distanceKm']) ?? 0,

      elapsedSeconds:
          _int(data['elapsedSeconds']) ?? 0,

      peeCount:
          _int(data['peeCount']) ?? 0,

      poopCount:
          _int(data['poopCount']) ?? 0,

      location:
          LocationData.fromDynamic(
        data['location'],
      ),

      routeCoordinates:
          _parseRouteCoordinates(
        routeRaw,
      ),

      events:
          _parseEvents(eventsRaw),
    );
  }
}

// ============================================================
// LOCATION MODEL
// ============================================================

class LocationData {
  final double lat;
  final double lng;

  const LocationData({
    required this.lat,
    required this.lng,
  });

  static LocationData? fromDynamic(
    dynamic value,
  ) {
    if (value is Map) {
      return LocationData(
        lat:
            _double(value['lat']) ?? 0,
        lng:
            _double(value['lng']) ?? 0,
      );
    }

    return null;
  }
}

// ============================================================
// ROUTE COORDINATE
// ============================================================

class RouteCoordinate {
  final double lat;
  final double lng;
  final int timestamp;

  const RouteCoordinate({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory RouteCoordinate.fromDynamic(
    dynamic value,
  ) {
    if (value is Map) {
      return RouteCoordinate(
        lat:
            _double(value['lat']) ?? 0,
        lng:
            _double(value['lng']) ?? 0,
        timestamp:
            _int(value['timestamp']) ?? 0,
      );
    }

    return const RouteCoordinate(
      lat: 0,
      lng: 0,
      timestamp: 0,
    );
  }
}

List<RouteCoordinate> _parseRouteCoordinates(
  dynamic value,
) {
  if (value is! List) {
    return [];
  }

  return value
      .map(
        RouteCoordinate.fromDynamic,
      )
      .where(
        (point) =>
            point.lat != 0 ||
            point.lng != 0,
      )
      .toList();
}

// ============================================================
// EVENTS
// ============================================================

class WalkEvent {
  final String id;
  final String type;
  final String note;
  final String timestamp;

  const WalkEvent({
    required this.id,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  factory WalkEvent.fromDynamic(
    dynamic value,
  ) {
    if (value is Map) {
      return WalkEvent(
        id:
            _string(
              Map<String, dynamic>.from(
                value,
              ),
              'id',
            ) ??
            '',
        type:
            _string(
              Map<String, dynamic>.from(
                value,
              ),
              'type',
            ) ??
            '',
        note:
            _string(
              Map<String, dynamic>.from(
                value,
              ),
              'note',
            ) ??
            '',
        timestamp:
            _string(
              Map<String, dynamic>.from(
                value,
              ),
              'timestamp',
            ) ??
            '',
      );
    }

    return const WalkEvent(
      id: '',
      type: '',
      note: '',
      timestamp: '',
    );
  }
}

List<WalkEvent> _parseEvents(
  dynamic value,
) {
  if (value is! List) {
    return [];
  }

  return value
      .map(
        WalkEvent.fromDynamic,
      )
      .where(
        (event) =>
            event.type.isNotEmpty ||
            event.note.isNotEmpty,
      )
      .toList();
}

// ============================================================
// WALK HISTORY MODEL
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
  final String walkerId;
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
    required this.walkerId,
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
          _string(data, 'dogName') ??
          'Dog',

      dogBreed:
          _string(data, 'dogBreed') ?? '',

      dogPhoto:
          _string(data, 'dogPhoto') ?? '',

      ownerId:
          _string(data, 'ownerId') ?? '-',

      ownerName:
          _string(data, 'ownerName') ??
          'Owner',

      walkerName:
          _string(data, 'walkerName') ??
          'Walker',

      walkerId:
          _string(data, 'walkerId') ??
          '',

      walkerUid:
          _string(data, 'walkeruid') ??
          _string(data, 'walkerUid') ??
          '-',

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

String _firstNonEmpty(
  List<String?> values,
  String fallback,
) {
  for (final value in values) {
    if (value != null &&
        value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return fallback;
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

bool? _bool(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  return null;
}

String _formatElapsed(int seconds) {
  if (seconds < 0) {
    seconds = 0;
  }

  final hours = seconds ~/ 3600;
  final minutes =
      (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${secs.toString().padLeft(2, '0')}';
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

// ============================================================
// LIVE DETAIL STAT
// ============================================================

class _LiveDetailStat
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _LiveDetailStat({
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
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
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
