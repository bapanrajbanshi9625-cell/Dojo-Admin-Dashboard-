import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/dashboard/dashboard_components.dart';
import '../widgets/dashboard/dashboard_live_map.dart';
import '../widgets/dashboard/dashboard_tabs.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // FIRESTORE COLLECTIONS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> get _ownersStream {
    return _firestore
        .collection('owners')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkersStream {
    return _firestore
        .collection('walkers')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _activeWalksStream {
    return _firestore
        .collection('active_walks')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _historyStream {
    return _firestore
        .collection('walk_history')
        .snapshots();
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: DashboardTabs.tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardTabs(
            controller: _tabController,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _overviewTab(),
                _financeTab(),
                _liveWalksTab(),
                _recentActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _overviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardLiveMap(
            activeWalksStream: _activeWalksStream,
          ),
          const SizedBox(height: 18),
          _statsGrid(),
          const SizedBox(height: 18),
          _quickActions(),
          const SizedBox(height: 18),
          _overviewPanels(),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 1000) {
          columns = 4;
        } else if (constraints.maxWidth >= 600) {
          columns = 2;
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _ownersStream,
          builder: (context, ownerSnapshot) {
            final ownerCount =
                ownerSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _walkersStream,
              builder: (context, walkerSnapshot) {
                final walkerCount =
                    walkerSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _activeWalksStream,
                  builder: (context, activeSnapshot) {
                    final activeCount =
                        _activeWalkCount(
                      activeSnapshot.data?.docs,
                    );

                    return StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _historyStream,
                      builder: (context, historySnapshot) {
                        final historyDocs =
                            _sortedHistoryDocs(
                          historySnapshot.data?.docs,
                        );

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio:
                              columns == 1 ? 3.3 : 2.2,
                          children: [
                            StatCard(
                              title: 'Total Owners',
                              value: '$ownerCount',
                              icon:
                                  Icons.people_outline,
                              iconColor: blue,
                            ),
                            StatCard(
                              title: 'Total Walkers',
                              value: '$walkerCount',
                              icon:
                                  Icons.badge_outlined,
                              iconColor: green,
                            ),
                            StatCard(
                              title: 'Active Walks',
                              value: '$activeCount',
                              icon: Icons
                                  .directions_walk_outlined,
                              iconColor: orange,
                            ),
                            StatCard(
                              title: 'Completed Walks',
                              value:
                                  '${historyDocs.length}',
                              icon: Icons
                                  .check_circle_outline,
                              iconColor: green,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  int _activeWalkCount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
  ) {
    final list = docs ?? const [];

    return list.where((doc) {
      final status = _readString(
        doc.data(),
        'status',
      )?.toLowerCase();

      return status == 'active' ||
          status == 'on_the_way' ||
          status == 'walking' ||
          status == 'started';
    }).length;
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionButton(
                title: 'Owners',
                icon: Icons.people_outline,
                color: blue,
                onTap: () =>
                    widget.onNavigate(4),
              ),
              ActionButton(
                title: 'Walkers',
                icon: Icons.badge_outlined,
                color: green,
                onTap: () =>
                    widget.onNavigate(5),
              ),
              ActionButton(
                title: 'Active Walks',
                icon: Icons
                    .directions_walk_outlined,
                color: orange,
                onTap: () =>
                    widget.onNavigate(2),
              ),
              ActionButton(
                title: 'Walk History',
                icon: Icons.history_outlined,
                color: grey,
                onTap: () =>
                    widget.onNavigate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW PANELS
  // ============================================================

  Widget _overviewPanels() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              _activeWalkPanel(),
              const SizedBox(height: 14),
              _recentActivityPanel(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _activeWalkPanel(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _recentActivityPanel(),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ACTIVE WALKS
  // ============================================================

  Widget _activeWalkPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataPanel(
            title: 'Active Walks',
            icon:
                Icons.directions_walk_outlined,
            color: orange,
            child: const EmptyMessage(
              text:
                  'Unable to load active walks.',
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return DataPanel(
          title: 'Active Walks',
          icon:
              Icons.directions_walk_outlined,
          color: orange,
          child: docs.isEmpty
              ? const EmptyMessage(
                  text:
                      'No active walks right now.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      docs.length > 4
                          ? 4
                          : docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 12),
                  itemBuilder:
                      (context, index) {
                    return _activeWalkRow(
                      docs[index].data(),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _activeWalkRow(
    Map<String, dynamic> data,
  ) {
    final walkerUid = _firstString(
      data,
      ['walkerUid', 'walkerId'],
    );

    final ownerUid = _firstString(
      data,
      ['ownerId'],
    );

    final walkerName = _firstString(
      data,
      ['walkerName'],
    );

    final ownerName = _firstString(
      data,
      ['ownerName'],
    );

    final dogName = _firstString(
      data,
      ['dogName'],
    );

    final distance =
        _firstValue(
          data,
          ['distanceKm'],
        ) ??
        '0';

    final duration =
        _firstValue(
          data,
          ['durationMinutes'],
        ) ??
        '0';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                orange.withValues(alpha: .10),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.pets,
            color: orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                walkerName ??
                    (walkerUid != null
                        ? 'Walker ${_shortId(walkerUid)}'
                        : 'Active Walk'),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                ownerName ??
                    (ownerUid != null
                        ? 'Owner ${_shortId(ownerUid)}'
                        : 'Live walk'),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
              if (dogName != null)
                Text(
                  dogName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '$distance km',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$duration min',
              style: const TextStyle(
                fontSize: 10,
                color: grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RECENT ACTIVITY PANEL
  // ============================================================

  Widget _recentActivityPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataPanel(
            title: 'Recent Activity',
            icon:
                Icons.history_outlined,
            color: blue,
            child: const EmptyMessage(
              text:
                  'Unable to load recent activity.',
            ),
          );
        }

        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        return DataPanel(
          title: 'Recent Activity',
          icon: Icons.history_outlined,
          color: blue,
          child: docs.isEmpty
              ? const EmptyMessage(
                  text:
                      'No recent activity.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      docs.length > 4
                          ? 4
                          : docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 12),
                  itemBuilder:
                      (context, index) {
                    return _historyRow(
                      docs[index].data(),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _historyRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(data, 'dogName') ??
            'Dog';

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final distance =
        _firstValue(
              data,
              ['distanceKm'],
            ) ??
            '0';

    final duration =
        _firstValue(
              data,
              ['durationMinutes'],
            ) ??
            '0';

    final rating = _readInt(
      data,
      'rating',
    );

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                blue.withValues(alpha: .10),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.history,
            color: blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                dogName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                walkerName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '$distance km',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$duration min',
              style: const TextStyle(
                fontSize: 10,
                color: grey,
              ),
            ),
            if (rating != null)
              Text(
                '★ $rating',
                style: const TextStyle(
                  fontSize: 10,
                  color: orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _financeTab() {
    return const Center(
      child: Text('Finance'),
    );
  }

  Widget _liveWalksTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding:
              const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              DashboardLiveMap(
                activeWalksStream:
                    _activeWalksStream,
              ),
              const SizedBox(height: 18),
              DataPanel(
                title: 'Active Walks',
                icon: Icons
                    .directions_walk_outlined,
                color: orange,
                child: docs.isEmpty
                    ? const EmptyMessage(
                        text:
                            'Live walks will appear here.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder:
                            (_, __) =>
                                const Divider(),
                        itemBuilder:
                            (context, index) {
                          return _liveWalkDetailedRow(
                            docs[index].data(),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _liveWalkDetailedRow(
    Map<String, dynamic> data,
  ) {
    final ownerUid =
        _readString(
              data,
              'ownerId',
            ) ??
            '-';

    final walkerUid =
        _readString(
              data,
              'walkerUid',
            ) ??
            '-';

    final ownerName =
        _readString(
          data,
          'ownerName',
        );

    final walkerName =
        _readString(
          data,
          'walkerName',
        );

    final dogName =
        _readString(
          data,
          'dogName',
        );

    final distance =
        _firstValue(
              data,
              ['distanceKm'],
            ) ??
            '-';

    final duration =
        _firstValue(
              data,
              ['durationMinutes'],
            ) ??
            '-';

    final pee =
        _firstInt(
              data,
              ['peeCount'],
            ) ??
            0;

    final poop =
        _firstInt(
              data,
              ['poopCount'],
            ) ??
            0;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
                  orange.withValues(alpha: .10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pets,
              color: orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  walkerName ??
                      'Walker ${_shortId(walkerUid)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ownerName ??
                      'Owner ${_shortId(ownerUid)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
                if (dogName != null)
                  Text(
                    dogName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  '$distance km • $duration min',
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Pee $pee • Poop $poop',
            style: const TextStyle(
              fontSize: 9,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivityTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        return SingleChildScrollView(
          padding:
              const EdgeInsets.only(bottom: 30),
          child: DataPanel(
            title: 'Recent Activity',
            icon:
                Icons.history_outlined,
            color: blue,
            child: docs.isEmpty
                ? const EmptyMessage(
                    text:
                        'Recent platform activity will appear here.',
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder:
                        (_, __) =>
                            const Divider(),
                    itemBuilder:
                        (context, index) {
                      return _historyDetailedRow(
                        docs[index].data(),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _historyDetailedRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(
              data,
              'dogName',
            ) ??
            'Dog';

    final walkerName =
        _readString(
              data,
              'walkerName',
            ) ??
            'Walker';

    final ownerName =
        _readString(
          data,
          'ownerName',
        );

    final date =
        _readString(
          data,
          'date',
        );

    final distance =
        _firstDouble(
          data,
          ['distanceKm'],
        );

    final duration =
        _firstDouble(
          data,
          ['durationMinutes'],
        );

    final rating =
        _readInt(
          data,
          'rating',
        );

    final dogPhoto =
        _readString(
          data,
          'dogPhoto',
        );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          photoAvatar(
            imageUrl: dogPhoto,
            icon: Icons.pets,
            color: blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  dogName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  walkerName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
                if (ownerName != null)
                  Text(
                    ownerName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),
                if (date != null &&
                    date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              if (distance != null)
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (duration != null)
                Text(
                  '${duration.toStringAsFixed(0)} min',
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
              if (rating != null)
                Text(
                  '★ $rating',
                  style: const TextStyle(
                    fontSize: 10,
                    color: orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIRESTORE HELPERS
  // ============================================================

  String? _readString(
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

  String? _firstString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value =
          _readString(data, key);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  dynamic _firstExistingValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (data.containsKey(key) &&
          data[key] != null) {
        return data[key];
      }
    }

    return null;
  }

  String? _firstValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    final value =
        _firstExistingValue(data, keys);

    return value?.toString();
  }

  double? _readDouble(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  double? _firstDouble(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value =
          _readDouble(data, key);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  int? _readInt(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

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

  int? _firstInt(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value =
          _readInt(data, key);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  // ============================================================
  // DATE
  // ============================================================

  DateTime? _toDateTime(dynamic value) {
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
      return DateTime
          .fromMillisecondsSinceEpoch(
        value,
      );
    }

    if (value is double) {
      return DateTime
          .fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // HISTORY SORT
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _sortedHistoryDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>?
        docs,
  ) {
    final result =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      docs ?? const [],
    );

    result.sort(
      (a, b) {
        final aDate = _toDateTime(
          _firstExistingValue(
            a.data(),
            [
              'completedAt',
              'startedAt',
              'createdAt',
            ],
          ),
        );

        final bDate = _toDateTime(
          _firstExistingValue(
            b.data(),
            [
              'completedAt',
              'startedAt',
              'createdAt',
            ],
          ),
        );

        if (aDate == null &&
            bDate == null) {
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

    return result;
  }

  // ============================================================
  // ID
  // ============================================================

  String _shortId(String value) {
    if (value.length <= 10) {
      return value;
    }

    return '${value.substring(0, 6)}...';
  }
}
