import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/dashboard/dashboard_components.dart';
import '../widgets/dashboard/dashboard_header.dart';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // ORIGINAL FIRESTORE COLLECTIONS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> get _ownersStream {
    return _firestore.collection('owners').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _walkersStream {
    return _firestore.collection('walkers').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _activeWalksStream {
    return _firestore.collection('active_walks').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get _historyStream {
    return _firestore.collection('walk_history').snapshots();
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
          DashboardHeader(
            onLogout: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 20),
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
          _liveMapContainer(),
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
            final ownerCount = ownerSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _walkersStream,
              builder: (context, walkerSnapshot) {
                final walkerCount = walkerSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _activeWalksStream,
                  builder: (context, activeSnapshot) {
                    final activeCount =
                        _activeWalkCount(activeSnapshot.data?.docs);

                    return StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _historyStream,
                      builder: (context, historySnapshot) {
                        final historyDocs = _sortedHistoryDocs(
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
                              icon: Icons.people_outline,
                              iconColor: blue,
                            ),
                            StatCard(
                              title: 'Total Walkers',
                              value: '$walkerCount',
                              icon: Icons.badge_outlined,
                              iconColor: green,
                            ),
                            StatCard(
                              title: 'Active Walks',
                              value: '$activeCount',
                              icon: Icons.directions_walk_outlined,
                              iconColor: orange,
                            ),
                            StatCard(
                              title: 'Completed Walks',
                              value: '${historyDocs.length}',
                              icon: Icons.check_circle_outline,
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
      final status = _readString(doc.data(), 'status')?.toLowerCase();

      return status == 'active' ||
          status == 'on_the_way' ||
          status == 'walking' ||
          status == 'started';
    }).length;
  }

  // ============================================================
  // REAL OPENSTREETMAP
  // ============================================================

  Widget _liveMapContainer() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _firebaseErrorContainer(
            'Unable to load live walks.',
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final validLocations = <_WalkMapPoint>[];

        for (final doc in docs) {
          final data = doc.data();

          final location = _readGeoPoint(
            data,
            'walkerLocation',
          );

          if (location != null &&
              !(location.latitude == 0 &&
                  location.longitude == 0)) {
            validLocations.add(
              _WalkMapPoint(
                documentId: doc.id,
                data: data,
                location: location,
              ),
            );
          }
        }

        final center = validLocations.isNotEmpty
            ? LatLng(
                validLocations.first.location.latitude,
                validLocations.first.location.longitude,
              )
            : const LatLng(28.6139, 77.2090);

        return Container(
          height: 330,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom:
                        validLocations.isNotEmpty ? 14 : 11,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.doojowalker.app',
                    ),

                    MarkerLayer(
                      markers: validLocations
                          .map(
                            (item) => Marker(
                              point: LatLng(
                                item.location.latitude,
                                item.location.longitude,
                              ),
                              width: 150,
                              height: 85,
                              child: _LiveWalkerMarker(
                                data: item.data,
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 15,
                left: 15,
                child: _mapLabel(
                  validLocations.length,
                ),
              ),

              if (docs.isNotEmpty &&
                  validLocations.isEmpty)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(
                              alpha: .08,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Active walk found,\nbut walker location is unavailable.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              if (docs.isEmpty)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No active walks right now.',
                        style: TextStyle(
                          color: grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapLabel(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 10,
            color: green,
          ),
          const SizedBox(width: 7),
          Text(
            count == 0
                ? 'Live Walk Map'
                : '$count Live Walker${count == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: () => widget.onNavigate(4),
              ),
              ActionButton(
                title: 'Walkers',
                icon: Icons.badge_outlined,
                color: green,
                onTap: () => widget.onNavigate(5),
              ),
              ActionButton(
                title: 'Active Walks',
                icon: Icons.directions_walk_outlined,
                color: orange,
                onTap: () => widget.onNavigate(2),
              ),
              ActionButton(
                title: 'Walk History',
                icon: Icons.history_outlined,
                color: grey,
                onTap: () => widget.onNavigate(3),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            icon: Icons.directions_walk_outlined,
            color: orange,
            child: const EmptyMessage(
              text: 'Unable to load active walks.',
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return DataPanel(
          title: 'Active Walks',
          icon: Icons.directions_walk_outlined,
          color: orange,
          child: docs.isEmpty
              ? const EmptyMessage(
                  text: 'No active walks right now.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 4 ? 4 : docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 12),
                  itemBuilder: (context, index) {
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
      [
        'walkerUid',
        'walkerId',
      ],
    );

    final ownerUid = _firstString(
      data,
      [
        'ownerId',
      ],
    );

    final walkerName = _firstString(
      data,
      [
        'walkerName',
      ],
    );

    final ownerName = _firstString(
      data,
      [
        'ownerName',
      ],
    );

    final dogName = _firstString(
      data,
      [
        'dogName',
      ],
    );

    final distance = _firstValue(
          data,
          [
            'distanceKm',
          ],
        ) ??
        '0';

    final duration = _firstValue(
          data,
          [
            'durationMinutes',
          ],
        ) ??
        '0';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: orange.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
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
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: grey,
                ),
              ),
              if (dogName != null)
                Text(
                  dogName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
  // RECENT ACTIVITY
  // ============================================================

  Widget _recentActivityPanel() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DataPanel(
            title: 'Recent Activity',
            icon: Icons.history_outlined,
            color: blue,
            child: const EmptyMessage(
              text: 'Unable to load recent activity.',
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
                  text: 'No recent activity.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 4 ? 4 : docs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 12),
                  itemBuilder: (context, index) {
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
        _readString(data, 'dogName') ?? 'Dog';

    final walkerName =
        _readString(data, 'walkerName') ?? 'Walker';

    final distance = _firstValue(
          data,
          ['distanceKm'],
        ) ??
        '0';

    final duration = _firstValue(
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
            color: blue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
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
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                walkerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  // FINANCE
  // ============================================================

  Widget _financeTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: EmptyMessage(
              text: 'Unable to load finance data.',
            ),
          );
        }

        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        double total = 0;
        double today = 0;

        for (final doc in docs) {
          final data = doc.data();

          final payout = _firstDouble(
                data,
                [
                  'payoutAmount',
                  'paymentAmount',
                  'amount',
                  'totalAmount',
                ],
              ) ??
              0;

          total += payout;

          if (_isToday(
            _firstExistingValue(
              data,
              [
                'createdAt',
                'completedAt',
                'timestamp',
              ],
            ),
          )) {
            today += payout;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _financeStats(
                todayRevenue: today,
                totalPayments: total,
                pendingPayouts: 0,
              ),
              const SizedBox(height: 18),
              _financePanel(
                title: 'Revenue Overview',
                icon: Icons.trending_up,
                color: green,
                text: docs.isEmpty
                    ? 'No completed walk payments yet.'
                    : 'Total completed walk revenue: ₹${_money(total)}',
              ),
              const SizedBox(height: 14),
              _financePanel(
                title: 'Pending Payouts',
                icon: Icons.account_balance_wallet_outlined,
                color: orange,
                text:
                    'Pending payout data is not available yet.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _financeStats({
    required double todayRevenue,
    required double totalPayments,
    required double pendingPayouts,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 800 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 1 ? 3 : 2,
          children: [
            StatCard(
              title: 'Today Revenue',
              value: '₹${_money(todayRevenue)}',
              icon: Icons.currency_rupee,
              iconColor: green,
            ),
            StatCard(
              title: 'Total Payments',
              value: '₹${_money(totalPayments)}',
              icon: Icons.payments_outlined,
              iconColor: blue,
            ),
            StatCard(
              title: 'Pending Payouts',
              value: '₹${_money(pendingPayouts)}',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: orange,
            ),
          ],
        );
      },
    );
  }

  Widget _financePanel({
    required String title,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: grey,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE WALKS TAB
  // ============================================================

  Widget _liveWalksTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activeWalksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: EmptyMessage(
              text: 'Unable to load live walks.',
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _liveMapContainer(),
              const SizedBox(height: 18),
              DataPanel(
                title: 'Active Walks',
                icon: Icons.directions_walk_outlined,
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
                        separatorBuilder: (_, __) =>
                            const Divider(),
                        itemBuilder: (context, index) {
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
        _readString(data, 'ownerId') ?? '-';

    final walkerUid =
        _readString(data, 'walkerUid') ?? '-';

    final ownerName =
        _readString(data, 'ownerName');

    final walkerName =
        _readString(data, 'walkerName');

    final dogName =
        _readString(data, 'dogName');

    final location =
        _readGeoPoint(data, 'walkerLocation');

    final distance =
        _firstValue(data, ['distanceKm']) ?? '-';

    final duration =
        _firstValue(data, ['durationMinutes']) ?? '-';

    final pee = _firstInt(
          data,
          ['peeCount'],
        ) ??
        0;

    final poop = _firstInt(
          data,
          ['poopCount'],
        ) ??
        0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
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
                  location == null
                      ? 'Location unavailable'
                      : '📍 ${location.latitude.toStringAsFixed(5)}, '
                          '${location.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
              Text(
                'Pee $pee • Poop $poop',
                style: const TextStyle(
                  fontSize: 9,
                  color: grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY TAB
  // ============================================================

  Widget _recentActivityTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30),
            child: EmptyMessage(
              text:
                  'Unable to load recent activity.',
            ),
          );
        }

        final docs = _sortedHistoryDocs(
          snapshot.data?.docs,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              DataPanel(
                title: 'Recent Activity',
                icon: Icons.history_outlined,
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
                        separatorBuilder: (_, __) =>
                            const Divider(),
                        itemBuilder: (context, index) {
                          return _historyDetailedRow(
                            docs[index].data(),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 14),
              const DataPanel(
                title: 'System Activity',
                icon: Icons.receipt_long_outlined,
                color: green,
                child: EmptyMessage(
                  text:
                      'System activity logs are not connected yet.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _historyDetailedRow(
    Map<String, dynamic> data,
  ) {
    final dogName =
        _readString(data, 'dogName') ?? 'Dog';

    final walkerName =
        _readString(data, 'walkerName') ?? 'Walker';

    final ownerName =
        _readString(data, 'ownerName');

    final date =
        _readString(data, 'date') ?? '';

    final badge =
        _readString(data, 'badge');

    final distance =
        _firstDouble(data, ['distanceKm']);

    final duration =
        _firstDouble(data, ['durationMinutes']);

    final rating =
        _readInt(data, 'rating');

    final dogPhoto =
        _readString(data, 'dogPhoto');

    return Padding(
      padding: const EdgeInsets.symmetric(
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  walkerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: grey,
                  ),
                ),
                if (ownerName != null)
                  Text(
                    ownerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: grey,
                    ),
                  ),
                if (badge != null)
                  Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      color: orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
  // FIREBASE ERROR
  // ============================================================

  Widget _firebaseErrorContainer(String text) {
    return Container(
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: grey,
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LIVE MAP MODEL
// ============================================================

class _WalkMapPoint {
  final String documentId;
  final Map<String, dynamic> data;
  final GeoPoint location;

  const _WalkMapPoint({
    required this.documentId,
    required this.data,
    required this.location,
  });
}

// ============================================================
// LIVE WALKER MARKER
// ============================================================

class _LiveWalkerMarker extends StatelessWidget {
  final Map<String, dynamic> data;

  const _LiveWalkerMarker({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final walkerName =
        _readString(data, 'walkerName');

    final walkerUid =
        _readString(data, 'walkerUid');

    final name = walkerName ??
        (walkerUid != null
            ? 'Walker ${_shortId(walkerUid)}'
            : 'Walker');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints:
              const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: .15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: .18),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
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
    final value = _readString(data, key);

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
  final value = _firstExistingValue(
    data,
    keys,
  );

  if (value == null) {
    return null;
  }

  return value.toString();
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
    final value = _readDouble(
      data,
      key,
    );

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
    final value = _readInt(
      data,
      key,
    );

    if (value != null) {
      return value;
    }
  }

  return null;
}

GeoPoint? _readGeoPoint(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value is GeoPoint) {
    return value;
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
    return DateTime.fromMillisecondsSinceEpoch(
      value,
    );
  }

  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.toInt(),
    );
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

bool _isToday(dynamic value) {
  final date = _toDateTime(value);

  if (date == null) {
    return false;
  }

  final now = DateTime.now();

  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
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

// ============================================================
// MONEY
// ============================================================

String _money(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}
