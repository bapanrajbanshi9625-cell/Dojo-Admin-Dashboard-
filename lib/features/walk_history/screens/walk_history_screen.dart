import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/walk_history_models.dart';
import '../utils/walk_history_helpers.dart';
import '../widgets/walk_history_widgets.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({
    super.key,
  });

  @override
  State<WalkHistoryScreen> createState() =>
      _WalkHistoryScreenState();
}

class _WalkHistoryScreenState
    extends State<WalkHistoryScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  // ==========================================================
  // FIRESTORE
  // ==========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get historyStream {
    return _firestore
        .collection('walkHistory')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get activeWalkStream {
    return _firestore
        .collection('activeWalk')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get liveSessionStream {
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
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: historyStream,
      builder: (context, historySnapshot) {
        if (historySnapshot.hasError) {
          return _error(
            historySnapshot.error.toString(),
          );
        }

        if (historySnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: dojoOrange,
            ),
          );
        }

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: activeWalkStream,
          builder: (context, activeSnapshot) {
            if (activeSnapshot.hasError) {
              return _error(
                activeSnapshot.error.toString(),
              );
            }

            if (activeSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: dojoOrange,
                ),
              );
            }

            return StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: liveSessionStream,
              builder: (context, liveSnapshot) {
                if (liveSnapshot.hasError) {
                  return _error(
                    liveSnapshot.error.toString(),
                  );
                }

                if (liveSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: dojoOrange,
                    ),
                  );
                }

                final histories =
                    _parseHistory(
                  historySnapshot.data?.docs ?? [],
                );

                final activeWalks =
                    _parseActive(
                  activeSnapshot.data?.docs ?? [],
                );

                histories.sort(
                  (a, b) =>
                      b.createdAt.compareTo(
                    a.createdAt,
                  ),
                );

                final filtered =
                    _filterHistory(histories);

                return _content(
                  histories,
                  filtered,
                  activeWalks,
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // PARSE
  // ==========================================================

  List<WalkHistoryData> _parseHistory(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    return docs
        .map(
          (doc) =>
              WalkHistoryData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  List<ActiveWalkData> _parseActive(
    List<QueryDocumentSnapshot<
            Map<String, dynamic>>>
        docs,
  ) {
    return docs
        .map(
          (doc) =>
              ActiveWalkData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .where((walk) => walk.isActive)
        .toList();
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _content(
    List<WalkHistoryData> histories,
    List<WalkHistoryData> filtered,
    List<ActiveWalkData> activeWalks,
  ) {
    final totalDistance =
        histories.fold<double>(
      0,
      (sum, walk) => sum + walk.distanceKm,
    );

    final averageRating = histories.isEmpty
        ? 0.0
        : histories.fold<int>(
              0,
              (sum, walk) => sum + walk.rating,
            ) /
            histories.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Walk History',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: dojoDark,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Monitor live walks and view completed walk history',
            style: TextStyle(
              color: dojoGrey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
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
                  WalkSummaryCard(
                    title: 'Live Walks',
                    value:
                        '${activeWalks.length}',
                    icon: Icons
                        .radio_button_checked,
                    color: dojoRed,
                  ),
                  WalkSummaryCard(
                    title: 'Total Walks',
                    value:
                        '${histories.length}',
                    icon:
                        Icons.history_outlined,
                    color: dojoOrange,
                  ),
                  WalkSummaryCard(
                    title: 'Total Distance',
                    value:
                        '${totalDistance.toStringAsFixed(1)} km',
                    icon:
                        Icons.route_outlined,
                    color: dojoBlue,
                  ),
                  WalkSummaryCard(
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
          ),

          const SizedBox(height: 22),

          // ====================================================
          // SEARCH
          // ====================================================

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: dojoBorder,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller:
                      searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search walk, owner, walker or pet...',
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        searchController
                                .text
                                .isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController
                                      .clear();
                                  setState(
                                      () {});
                                },
                                icon:
                                    const Icon(
                                  Icons.close,
                                ),
                              )
                            : null,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 7,
                  children: [
                    _filter('All'),
                    _filter('Rated'),
                    _filter('Unrated'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Completed Walks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                    color: dojoDark,
                  ),
                ),
              ),
              Text(
                '${filtered.length} walks',
                style: const TextStyle(
                  color: dojoGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (filtered.isEmpty)
            const WalkHistoryEmpty()
          else
            Column(
              children:
                  filtered.map(
                (walk) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: WalkHistoryCard(
                      walk: walk,
                      onView: () {
                        _showDetails(walk);
                      },
                    ),
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  Widget _filter(String title) {
    final selected =
        selectedFilter == title;

    return InkWell(
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

  List<WalkHistoryData> _filterHistory(
    List<WalkHistoryData> walks,
  ) {
    final query = searchController.text
        .trim()
        .toLowerCase();

    return walks.where((walk) {
      final searchMatch =
          query.isEmpty ||
          walk.walkId
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
          walk.dogBreed
              .toLowerCase()
              .contains(query);

      final filterMatch =
          selectedFilter == 'All' ||
          (selectedFilter == 'Rated' &&
              walk.rating > 0) ||
          (selectedFilter == 'Unrated' &&
              walk.rating == 0);

      return searchMatch && filterMatch;
    }).toList();
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void _showDetails(
    WalkHistoryData walk,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _section(
                  'Dog',
                  [
                    _row(
                      'Name',
                      walk.dogName,
                    ),
                    _row(
                      'Breed',
                      walk.dogBreed,
                    ),
                  ],
                ),

                _section(
                  'Owner',
                  [
                    _row(
                      'Name',
                      walk.ownerName,
                    ),
                    _row(
                      'Owner ID',
                      walk.ownerId,
                    ),
                  ],
                ),

                _section(
                  'Walker',
                  [
                    _row(
                      'Name',
                      walk.walkerName,
                    ),
                    _row(
                      'Walker ID',
                      walk.walkerId,
                    ),
                    _row(
                      'Walker UID',
                      walk.walkerUid,
                    ),
                  ],
                ),

                _section(
                  'Walk',
                  [
                    _row(
                      'Date',
                      walk.date,
                    ),
                    _row(
                      'Time',
                      walk.timeFormatted,
                    ),
                    _row(
                      'Duration',
                      '${walk.durationMinutes} min',
                    ),
                    _row(
                      'Distance',
                      '${walk.distanceKm.toStringAsFixed(2)} km',
                    ),
                    _row(
                      'Pee',
                      '${walk.peeCount}',
                    ),
                    _row(
                      'Poop',
                      '${walk.poopCount}',
                    ),
                    _row(
                      'Rating',
                      walk.rating > 0
                          ? '${walk.rating}/5'
                          : '-',
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
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _section(
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: dojoOrange,
              fontSize: 13,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
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
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 11,
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
  // ERROR
  // ==========================================================

  Widget _error(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
      ),
    );
  }
}
