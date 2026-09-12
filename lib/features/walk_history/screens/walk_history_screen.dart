import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/walk_history_models.dart';
import '../widgets/walk_history_widgets.dart';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({
    super.key,
  });

  @override
  State<WalkHistoryScreen> createState() =>
      _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen> {
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
    // Do not filter status in Firestore.
    //
    // Firestore string comparison is case-sensitive.
    // Completed walks may contain:
    // "completed"
    //
    // We normalize the status locally below.
    return _firestore
        .collection('walk_history')
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
      stream: historyStream,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasError) {
          return _error(
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

        final histories = _parseHistory(
          snapshot.data?.docs ?? [],
        );

        histories.sort(
          (a, b) {
            final aDate =
                a.completedAt ?? a.startedAt;
            final bDate =
                b.completedAt ?? b.startedAt;

            if (aDate == null && bDate == null) {
              return 0;
            }

            if (aDate == null) {
              return 1;
            }

            if (bDate == null) {
              return -1;
            }

            return bDate.compareTo(aDate);
          },
        );

        // Only completed walks belong in Walk History.
        final completedHistories =
            histories.where(
          (walk) =>
              walk.status.trim().toLowerCase() ==
              'completed',
        ).toList();

        final filtered =
            _filterHistory(
          completedHistories,
        );

        return _content(
          completedHistories,
          filtered,
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
          (doc) => WalkHistoryData.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _content(
    List<WalkHistoryData> histories,
    List<WalkHistoryData> filtered,
  ) {
    final totalDistance =
        histories.fold<double>(
      0,
      (sum, walk) => sum + walk.distanceKm,
    );

    final ratedWalks = histories
        .where(
          (walk) =>
              _effectiveRating(walk) > 0,
        )
        .toList();

    final averageRating = ratedWalks.isEmpty
        ? 0.0
        : ratedWalks.fold<int>(
              0,
              (sum, walk) =>
                  sum + _effectiveRating(walk),
            ) /
            ratedWalks.length;

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

          // ====================================================
          // SUMMARY
          // ====================================================

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
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
                                    () {},
                                  );
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

          // ====================================================
          // LIST HEADER
          // ====================================================

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

          // ====================================================
          // LIST
          // ====================================================

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
  // EFFECTIVE RATING
  // ==========================================================

  int _effectiveRating(
    WalkHistoryData walk,
  ) {
    if (walk.ownerReviewRating > 0) {
      return walk.ownerReviewRating;
    }

    if (walk.walkerReviewRating > 0) {
      return walk.walkerReviewRating;
    }

    return walk.rating;
  }

  // ==========================================================
  // FILTER BUTTON
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

  // ==========================================================
  // LOCAL FILTER
  // ==========================================================

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

      final filterRating =
          _effectiveRating(walk);

      final filterMatch =
          selectedFilter == 'All' ||
          (selectedFilter == 'Rated' &&
              filterRating > 0) ||
          (selectedFilter == 'Unrated' &&
              filterRating == 0);

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
                  walk.walkId.isNotEmpty
                      ? walk.walkId
                      : walk.id,
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
                      '${walk.durationMinutes.toStringAsFixed(1)} min',
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
                  ],
                ),

                // ==================================================
                // OWNER REVIEW
                // Owner -> Walker
                // ==================================================

                _reviewSection(
                  title: 'Owner Review',
                  subtitle:
                      'Owner → Walker',
                  rating:
                      walk.ownerReviewRating,
                  note:
                      walk.ownerReviewNote,
                  submitted:
                      walk.ownerReviewSubmitted,
                  reviewedAt:
                      walk.ownerReviewedAt,
                  accent:
                      dojoOrange,
                ),

                // ==================================================
                // WALKER REVIEW
                // Walker -> Owner
                // ==================================================

                _reviewSection(
                  title: 'Walker Review',
                  subtitle:
                      'Walker → Owner',
                  rating:
                      walk.walkerReviewRating,
                  note:
                      walk.walkerReviewNote,
                  submitted:
                      walk.walkerReviewSubmitted,
                  reviewedAt:
                      walk.walkerReviewedAt,
                  accent:
                      dojoBlue,
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

  // ==========================================================
  // REVIEW SECTION
  // ==========================================================

  Widget _reviewSection({
    required String title,
    required String subtitle,
    required int rating,
    required String note,
    required bool submitted,
    required DateTime? reviewedAt,
    required Color accent,
  }) {
    final hasReview =
        submitted ||
        rating > 0 ||
        note.trim().isNotEmpty;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(13),
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
            Row(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(
                          color: dojoGrey,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: submitted
                        ? dojoGreen
                            .withValues(alpha: 0.10)
                        : dojoGrey
                            .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    submitted
                        ? 'Submitted'
                        : 'Not Submitted',
                    style: TextStyle(
                      color: submitted
                          ? dojoGreen
                          : dojoGrey,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 11),

            // Rating
            Row(
              children: [
                const SizedBox(
                  width: 85,
                  child: Text(
                    'Rating',
                    style: TextStyle(
                      color: dojoGrey,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (rating > 0)
                  Row(
                    children: List.generate(
                      5,
                      (index) {
                        return Icon(
                          index < rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 17,
                          color:
                              index < rating
                                  ? Colors.amber
                                  : dojoBorder,
                        );
                      },
                    ),
                  )
                else
                  const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Note
            _row(
              'Review',
              note,
            ),

            // Reviewed At
            if (reviewedAt != null)
              _row(
                'Reviewed At',
                _formatReviewDate(
                  reviewedAt,
                ),
              ),

            if (!hasReview)
              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 3,
                ),
                child: Text(
                  'No review submitted for this walk.',
                  style: TextStyle(
                    color: dojoGrey,
                    fontSize: 11,
                    fontStyle:
                        FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // REVIEW DATE
  // ==========================================================

  String _formatReviewDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final year =
        date.year.toString();

    final hour =
        date.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        date.minute.toString().padLeft(
              2,
              '0',
            );

    return '$day/$month/$year $hour:$minute';
  }

  // ==========================================================
  // SECTION
  // ==========================================================

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

  // ==========================================================
  // ROW
  // ==========================================================

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
              style:
                  const TextStyle(
                color: dojoGrey,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty
                  ? '-'
                  : value,
              style:
                  const TextStyle(
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

  Widget _error(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: dojoOrange,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Unable to load walk data',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              error,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
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
